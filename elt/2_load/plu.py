import glob
import json
import psycopg2
import re
import os
import sys
import subprocess
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())
os.environ['PGPASSWORD'] = os.environ.get("PG_PASSWORD") or 'password'
psql_host = os.environ.get("PSQL_HOST") or 'localhost'
psql_exec = os.environ.get("PSQL_EXEC") or 'psql'

wfs_types = ['zone_urba', 'secteur_cc']

if __name__ == "__main__":

    base_dir_path = os.path.dirname(os.path.realpath(sys.argv[0]))
    queries_dir_path = f"{base_dir_path}/queries"
    query_file = f"{queries_dir_path}/plu.sql"

    data_dir_path = f'{os.environ.get("DATA_PATH")}/datalake'  # No / at the end
    deps = glob.glob(rf"{data_dir_path}/D*")

    for dep in deps:
        depname = dep.split('/')[-1].lower()
        depno = depname[1:]
        subprocess.run(f"""
        {psql_exec} -q -U admin -h {psql_host} -d "{depname}" -f "{query_file}"
        """, shell=True)

        conn = psycopg2.connect(
            host=psql_host,
            port=5432,
            database=depname,
            user="admin",
            password=os.environ['PGPASSWORD'])
        cur = conn.cursor()

        for wfs_type in wfs_types:
            files_path = glob.glob(f"{dep}/PLU/{wfs_type}_*.json")
            for global_progress, file_path in enumerate(files_path):
                print(f'Doing {file_path} {global_progress + 1}/{len(files_path)}...')
                with open(file_path, 'r') as out:
                    file_data = out.read()
                    data = json.loads(file_data)
                    nb_features = len(data['features'])
                    if nb_features == 0:
                        break
                    query = 'INSERT INTO plu (gid, gid_part, wfs_type, part, insee_com, libelle, libelong, typezone, geom) VALUES '
                    for progress, feature in enumerate(data['features']):
                        nb_coords = len(feature['geometry']['coordinates'])
                        for idx, geom in enumerate(feature['geometry']['coordinates']):
                            query += "({}, {}, '{}', '{}', '{}', '{}', '{}', '{}',ST_Transform(ST_SetSRID(ST_CollectionExtract(ST_MakeValid(ST_GeomFromGeoJSON('{}'))), 4326), 2154)){}".format(
                                            feature['properties']['gid'],
                                            idx,
                                            wfs_type,
                                            feature['properties']['partition'],
                                            feature['properties']['insee'] if 'insee' in feature['properties'] else re.search(r"\d{5}", feature['properties']['partition'])[0],
                                            feature['properties']['libelle'].replace('\'', ''),
                                            (feature['properties']['libelong'] or '').replace('\'', '\'\''),
                                            (feature['properties']['typezone'] if 'typezone' in feature['properties'] else ''),
                                            str({'type': feature['geometry']['type'], 'coordinates': [geom]}).replace('\'', '"'),
                                            ';' if progress == nb_features - 1 and idx == nb_coords - 1 else ','
                                            )
                    # print(query)
                    cur.execute(query)
                    conn.commit()
        print(f'Dep {dep} Done !')

        cur.close()
        conn.close()
