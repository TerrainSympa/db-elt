import json
import math

import psycopg2 as psycopg2
import os
import sys
import subprocess
import glob
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())
os.environ['PGPASSWORD'] = os.environ.get("PG_PASSWORD") or 'password'
psql_host = os.environ.get("PSQL_HOST") or 'localhost'
psql_exec = os.environ.get("PSQL_EXEC") or 'psql'

quote_or_null = lambda s: '\'' + s + '\'' if s is not None else 'NULL'

if __name__ == "__main__":

    base_dir_path = os.path.dirname(os.path.realpath(sys.argv[0]))
    queries_dir_path = f"{base_dir_path}/queries"
    query_file = f"{queries_dir_path}/commune_info.sql"

    data_dir_path = f'{os.environ.get("DATA_PATH")}/datalake'  # No / at the end
    commune_path = f'{data_dir_path}/all_latest'

    gouv_local = glob.glob(rf"{commune_path}/*.json")
    if len(gouv_local) == 0:
        print('Error: no json found')
        exit(1)
    with open(gouv_local[0], 'r', encoding='utf-8') as bf:
        gouv_local_data = json.load(bf)
        subprocess.run(f"""
        {psql_exec} -q -U admin -h {psql_host} -d "deps" -f "{query_file}"
        """, shell=True)

        conn = psycopg2.connect(
            host=psql_host,
            port=5432,
            database='deps',
            user="admin",
            password=os.environ['PGPASSWORD'])
        cur = conn.cursor()

        townhalls = [x for x in gouv_local_data['service'] if len(x['pivot']) > 0 and x['pivot'][0]['type_service_local'] == 'mairie']
        for i, townhall in enumerate(townhalls):
            print(f'Progress: {i}/{len(townhalls)} ({round(i/len(townhalls)*100, 1)}%)', end='\r')
            cur.execute(
                f"""
                    UPDATE communes
                    SET
                        numero = {quote_or_null(townhall['telephone'][0]['valeur'] if len(townhall['telephone']) > 0 else None)},
                        email = {quote_or_null(townhall['adresse_courriel'][0] if len(townhall['adresse_courriel']) > 0 else None)},
                        site = {quote_or_null(townhall['site_internet'][0]['valeur'] if len(townhall['site_internet']) > 0 else None)},
                        postal_code = {quote_or_null(townhall['adresse'][0]['code_postal'] if len(townhall['adresse']) > 0 else None)}
                    WHERE insee_com = {quote_or_null(townhall['code_insee_commune'])};
                """
            )
            conn.commit()

        cur.close()
        conn.close()
