# db-elt
This project aims to extract raw data from gouv data websites, load it in the postgis and transform it to fit TS database format.
Each of these steps are clearly separeted in the `elt` folder.

## Requirements

**python 3.12**
```bash
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.12 python3.12-venv python3.12-dev python3.12-distutils libpq-dev
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.12
python3.12 -m venv .venv
source .venv/bin/activate
pip3 install psycopg2-binary
pip3 install setuptools
pip3 install psycopg2
```
**poetry**
```bash
sudo apt install python3-poetry
```
**psql**
```bash
sudo apt install postgresql-client
```
**raster2pgsql**
```bash
sudo apt-get install postgis
```
**ogr2ogr**
```bash
sudo apt install gdal-bin
```

## Install
```bash
poetry install
```

## Setup python
```bash
source .venv/bin/activate
```


## Extract data
Scripts for this step are in the `elt/1_extract` folder.

Raw data that will be extract comes from these sources:
- Databases can be founded at: https://geoservices.ign.fr/documentation/donnees
- PARCELLAIRE_EXPRESS: https://geoservices.ign.fr/documentation/donnees/parcellaire/parcellaire-express-pci
- DBFORET: https://geoservices.ign.fr/documentation/donnees/vecteur/bdforet
- DBTOPO: https://geoservices.ign.fr/documentation/donnees/vecteur/bdtopo
- Annuaire (all_latest.tar.bz2): https://www.data.gouv.fr/fr/datasets/service-public-fr-annuaire-de-l-administration-base-de-donnees-locales/
- Code postaux: https://www.data.gouv.fr/fr/datasets/base-officielle-des-codes-postaux/
- Valeur foncieres: https://www.data.gouv.fr/fr/datasets/demandes-de-valeurs-foncieres/ (not used for now)
- Departments: https://geoservices.ign.fr/adminexpress

## Load data

Scripts for this step are in the `elt/2_load` folder.

- `db.py` will load shapefile data
- `plu.py` will load plu json data
- `commune_info.py` will load commune information

## Transform data
Scripts for this step are in the `elt/3_transform` folder.

All is done by one script `db.py` that will run SQL scripts in `queries` folder.

- Folder `1_init` will initialized new table for transformed data
- Folder `2_fill` will filled new tables with data
- Folder `3_clean` will clean up the database by removing unwanted table and columns to optimized space.
