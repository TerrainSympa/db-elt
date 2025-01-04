import argparse
import os
import re
import tarfile
from typing import Dict, List

import requests
from bs4 import BeautifulSoup
import py7zr
import progressbar
import urllib.request
import ssl
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())

ign_url = 'https://geoservices.ign.fr'
parcellaire_endpoint = 'parcellaire-express-pci'
foret_endpoint = 'bdforet'
topo_endpoint = 'bdtopo'
admin_endpoint = 'adminexpress'
data_path = os.environ.get("DATA_PATH")  # No / at the end
headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:124.0) Gecko/20100101 Firefox/124.0'}


# class ScrapInfos(TypedDict):
#     type: str
#     title: str
#     url: str
#     regex_title: Pattern[str]


urls_to_scrap: List[Dict] = [
    {
        'type': parcellaire_endpoint,
        'title': 'Parcellaire express',
        'url': f'{ign_url}/{parcellaire_endpoint}',
        'regex_title': re.compile("Parcellaire Express.*")
    },
    {
        'type': foret_endpoint,
        'title': 'DB Foret',
        'url': f'{ign_url}/{foret_endpoint}',
        'regex_title': re.compile("BD FORET.*V2.*")
    },
    {
        'type': topo_endpoint,
        'title': 'DB Topo',
        'url': f'{ign_url}/{topo_endpoint}',
        'regex_title': re.compile("BD TOPO.*format Shapefile.*")
    },

]

pbar = None


def show_progress(block_num, block_size, total_size):
    global pbar
    if pbar is None:
        pbar = progressbar.ProgressBar(maxval=total_size)
        pbar.start()

    downloaded = block_num * block_size
    if downloaded < total_size:
        pbar.update(downloaded)
    else:
        pbar.finish()
        pbar = None


def get_links(scrap: Dict) -> Dict[str, str]:
    print(f"{scrap['title']}: scraping for links...")
    page = requests.get(scrap['url'], headers=headers, timeout=5)
    soup = BeautifulSoup(page.content, 'html.parser')
    links = {}

    h3 = soup.find("h3", text=scrap['regex_title'])

    if not h3:
        print(f"{scrap['title']}: h3 not found")
        return {}

    for sibling in h3.find_next_siblings(['h3', 'p']):
        if sibling.name == 'h3':
            break
        if sibling.name == 'p':
            dl_url = sibling.find_next_sibling('ul').find("a")["href"]
            if len(sibling.text) > 10: # Remove empty lines
                links[sibling.text.split(" ")[1]] = dl_url

    print(f"{scrap['title']}: {len(links)} links founded")
    return links


def download_links(folder: str, link: str, output_name: str, title: str, override: bool):
    path = f'{data_path}/datalake/{folder}'
    path_exists = os.path.exists(path)
    if not path_exists:
        os.makedirs(path)

    dl_path = f"{path}/{output_name}.7z"
    extract_path = f"{path}/{output_name}"
    extract_exists = os.path.exists(extract_path)
    dl_exists = os.path.isfile(dl_path)

    if not override and (extract_exists or dl_exists):
        print(f"{title}: Not downloading, file or folder already exists and override option is not enabled")
    else:
        if override and dl_exists:
            print(f"{title}: File already exists, deleting it")
            os.remove(dl_path)
        print(f"{title}: Downloading {link}...")
        ssl._create_default_https_context = ssl._create_unverified_context
        urllib.request.urlretrieve(link, dl_path, show_progress)  # 3 mins, have progress bar
        print(f"{title}: Download {link} done !")

    if not override and extract_exists:
        print(f"{title}: Not extracting, folder already exists and override option is not enabled")
    else:
        if override and extract_exists:
            print(f"{title}: Folder already exists, deleting it")
            os.rmdir(extract_path)
        print(f"{title}: Extracting...")
        with py7zr.SevenZipFile(os.path.abspath(dl_path), mode='r') as z:
            z.extractall(path=os.path.abspath(extract_path))
        print(f"{title}: Extract done !")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--deps', help='List of departments to download and extract (e.g 01,74)', type=str)
    parser.add_argument('-o', '--override', default=False, help='Override existing data', action='store_true')
    args = parser.parse_args()
    if args.deps is None or len(args.deps) == 0:
        print('No department provided')
        exit(0)

    departments = [item for item in args.deps.split(',')]
    for url_to_scrap in urls_to_scrap:
        links = get_links(url_to_scrap)

        for department in departments:
            download_links(f'D{department}', links[department], url_to_scrap['type'], f"{url_to_scrap['title']}|{department}", args.override)

        print(f"{url_to_scrap['title']}: Everything done !")

    # Edges cases
    print(f"Moving to edges cases...")
    ## Deps admin
    print(f"Admin: scraping for links...")
    page = requests.get(f'{ign_url}/{admin_endpoint}', headers=headers, timeout=5)
    soup = BeautifulSoup(page.content, 'html.parser')
    h3s = soup.findAll(string=re.compile("ADMIN-EXPRESS .* France Métropolitaine"))
    if len(h3s) == 0:
        print(f"Admin: h3 not found")
    admin_links = h3s[0].parent.find_next_siblings()[0].find('a').contents[0]
    download_links('deps', admin_links, admin_endpoint, f"Admin DB|deps", args.override)

    extract_path = f'{data_path}/datalake/all_latest'
    if not args.override and os.path.exists(extract_path):
        print(f"Admin: Not extracting, folder already exists and override option is not enabled")
    else:
        ## Commune infos
        # From 'https://www.data.gouv.fr/fr/datasets/service-public-fr-annuaire-de-l-administration-base-de-donnees-locales/', should scrap at some point...
        ssl._create_default_https_context = ssl._create_unverified_context
        urllib.request.urlretrieve('https://www.data.gouv.fr/fr/datasets/r/73302880-e4df-4d4c-8676-1a61bb997f3d', f'{data_path}/datalake/all_latest.tar.bz2', show_progress)
        tar: tarfile.TarFile = tarfile.open(f'{data_path}/datalake/all_latest.tar.bz2', "r:bz2")
        tar.extractall(extract_path)
        tar.close()

    print(f"Admin: Done !")
