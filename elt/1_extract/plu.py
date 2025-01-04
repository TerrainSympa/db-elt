# Examples of requests that can be made to this API:
# https://wxs-gpu.mongeoportail.ign.fr/externe/39wtxmgtn23okfbbs1al2lz3/wfs/v?request=GetFeature&typeNames=wfs_du:zone_urba&count=10
#
# IT USES CQL FILTER
# https://wxs-gpu.mongeoportail.ign.fr/externe/39wtxmgtn23okfbbs1al2lz3/wfs/v?request=GetFeature&typeNames=wfs_du:zone_urba&count=10&cql_filter=partition%3D%27DU_01007%27
# partition='DU_....'
#
# https://wxs-gpu.mongeoportail.ign.fr/externe/39wtxmgtn23okfbbs1al2lz3/wfs/v?request=GetFeature&typeNames=wfs_du:zone_urba&count=10&cql_filter=partition%20LIKE%20%27DU_01%25%27
# partition LIKE 'DU_%'
#
# https://wxs-gpu.mongeoportail.ign.fr/externe/39wtxmgtn23okfbbs1al2lz3/wfs/v?request=GetFeature&outputFormat=application%2Fjson&typeNames=wfs_du:secteur_cc&count=10&cql_filter=partition%20LIKE%20%27DU_01%25%27

# Not DU
# https://wxs-gpu.mongeoportail.ign.fr/externe/39wtxmgtn23okfbbs1al2lz3/wfs/v?request=GetFeature&outputFormat=application%2Fjson&typeNames=wfs_du:zone_urba&count=10&cql_filter=partition%20NOT%20LIKE%20%27DU_%25%27

# Describe features
# https://wxs-gpu.mongeoportail.ign.fr/externe/39wtxmgtn23okfbbs1al2lz3/wfs/v?request=DescribeFeatureType&typeNames=wfs_du:zone_urba
# DU_V is document urbanisme ?

# Other usefull params:
# - outputFormat=application%2Fjson
# - startIndex and count for pagination

# Les coordonnées sont exprimées en WGS84 (longitude,latitude). (https://www.geoportail-urbanisme.gouv.fr/api/)

# In parcelle shapefile data, code_com correspond to the last 3 digits of insee_com

import os
import time
import random
from datetime import datetime
import json
import requests
import pathlib
from dotenv import load_dotenv, find_dotenv
import argparse

load_dotenv(find_dotenv())

data_path = f'{os.environ.get("DATA_PATH")}/datalake'  # No / at the end

apiKey = '39wtxmgtn23okfbbs1al2lz3' # Chill, this is a public key
base_url = f'https://wxs-gpu.mongeoportail.ign.fr/externe/{apiKey}/wfs/v'

wfs_types = ['secteur_cc', 'zone_urba']
count = 1000
init_params = {
    'request': 'GetFeature',
    'service': 'wfs',
    'outputFormat': 'application/json',
    'typeNames': 'wfs_du:{}',
    'count': count,
    'startIndex': 0,
    'cql_filter': "partition LIKE 'DU_{}%'",
    'sortBy': 'gid',
}
headers = {'User-Agent': 'apicarto'}

max_requests = 10000
nb_requests = 0
can_request = True
insert_in_db = False
status_init = {
    'status': 'processing',
    'tot_items': 0,
    'remaining_items': -1,
    'next_idx': 0,
    'first_update': datetime.now().strftime("%d/%m/%Y %H:%M:%S"),
    'last_update': datetime.now().strftime("%d/%m/%Y %H:%M:%S"),
}

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--deps', help='List of departments to download and extract (e.g 01,74)', type=str)
    args = parser.parse_args()
    if args.deps is None or len(args.deps) == 0:
        print('No department provided')
        exit(0)

    deps = [item for item in args.deps.split(',')]

    for dep in deps:
        sleep_a_bit = True
        for wfs_type in wfs_types:
            pathlib.Path(f'{data_path}/D{dep}/PLU').mkdir(parents=True, exist_ok=True)
            path = f'{data_path}/D{dep}/PLU/status_{wfs_type}.json'
            mode = 'r+' if os.path.exists(path) else 'w+'
            with open(path, mode=mode) as out:
                file_status = out.read()
                if len(file_status) > 0:
                    file_status_json = json.loads(file_status)
                else:
                    file_status_json = status_init.copy()
                    out.write(json.dumps(file_status_json))
            print(f'Dep {dep}: {file_status_json}')
            while True:
                if file_status_json['status'] == 'done':
                    print(f'Dep {dep}: Done for {wfs_type} !')
                    break

                if can_request:
                    params = init_params.copy()
                    params['startIndex'] = file_status_json['next_idx']
                    params['typeNames'] = init_params['typeNames'].format(wfs_type)
                    params['cql_filter'] = params['cql_filter'].format(dep)
                    print(f'Dep {dep}: Request with params: {json.dumps(params)}')
                    resp = requests.get(url=base_url, params=params, headers=headers)
                    data = resp.json()

                    nb_requests += 1

                    file_status_json['tot_items'] = data['totalFeatures']
                    file_status_json['next_idx'] = min(file_status_json['next_idx'] + count, file_status_json['tot_items'])
                    file_status_json['remaining_items'] = max(file_status_json['tot_items'] - file_status_json['next_idx'], 0)
                    file_status_json['last_update'] = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
                    print(f'Dep {dep}: {file_status_json["next_idx"]} / {data["totalFeatures"]} ({(file_status_json["next_idx"] / max(data["totalFeatures"], 1)) * 100:.2f}%)')
                    if file_status_json['remaining_items'] == 0:
                        file_status_json['status'] = 'done'
                    with open('{}/D{}/PLU/{}_{}_{}.json'.format(data_path, dep, wfs_type, params['startIndex'],
                                                                            file_status_json['next_idx'] - 1), 'w+') as out:
                        out.write(json.dumps(data))

                    with open(f'{data_path}/D{dep}/PLU/status_{wfs_type}.json', 'w+') as out:
                        out.write(json.dumps(file_status_json))

                if nb_requests >= max_requests:
                    print('Number of maximum request reached !')
                    can_request = False
                    sleep_a_bit = False
                    break
                if sleep_a_bit:
                    sleep_time = random.randint(15, 30)
                    print(f'Sleep for {sleep_time} sec...')
                    time.sleep(sleep_time)
