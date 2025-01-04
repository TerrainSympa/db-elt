import argparse
import glob
import os
import subprocess

from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())
os.environ['PGPASSWORD'] = os.environ.get("PG_PASSWORD") or 'password'
os.environ['PG_USE_COPY'] = 'YES'
psql_exec = os.environ.get("PSQL_EXEC") or 'psql'
psql_host = os.environ.get("PSQL_HOST") or 'localhost'
ogr2ogr_exec = os.environ.get("OGR2OGR_EXEC") or 'ogr2ogr'
raster2pgsql_exec = os.environ.get("RASTER2PGSQL_EXEC") or 'raster2pgsql'

if __name__ == "__main__":

    data_path = f'{os.environ.get("DATA_PATH")}/datalake'  # No / at the end
    deps = glob.glob(rf"{data_path}/D*")

    tables = [
        # {
        #     "path": "/**/BDFORET/**/FORMATION_VEGETALE.shp",
        #     "name": "forest",
        #     "type": "MULTIPOLYGON"
        # },
        {
            "path": "/**/PARCELLE.SHP",
            "name": "parcelle",
            "type": "MULTIPOLYGON"
        },
        # {
        #     "path": "/**/BDTOPO/**/BATIMENT.shp",
        #     "name": "building",
        #     "type": "MULTIPOLYGON"
        # },
        # {
        #     "path": "/**/BDTOPO/**/COURS_D_EAU.shp",
        #     "name": "river",
        #     "type": "MULTILINESTRING"
        # },
        # {
        #     "path": "/**/BDALTIV2*/**/1_*/**/BDALTIV2_MNT_25M_ASC_LAMB93_IGN69_D*",
        #     "name": "altitude",
        #     "type": "raster"
        # }
    ]

    tables_deps = [
        {
            "path": "/**/COMMUNE.shp",
            "name": "communes",
            "type": "MULTIPOLYGON"
        },
        {
            "path": "/**/DEPARTEMENT.shp",
            "name": "departements",
            "type": "MULTIPOLYGON"
        },
    ]

    print('Start databases initialization...')

    for dep in deps:
        depname = dep.split('/')[-1].lower()
        depno = depname[1:]
        if depname not in ['d02','d03','d04','d05','d06','d08','d09','d10','d11','d12','d13','d14','d15','d16','d17','d18','d19','d21','d22','d23','d24','d25','d27','d28','d29','d2A','d2B','d30','d31','d32','d33','d34','d35','d36','d37','d39','d40','d41','d43','d44','d45','d46','d47','d48','d49','d50','d51','d52','d53','d54','d55','d56','d57','d58','d59','d60','d61','d62','d63','d64','d65','d66','d67','d68','d70','d71','d72','d75','d76','d77','d78','d79','d80','d81','d82','d83','d84','d85','d86','d87','d88','d89','d90','d91','d92','d93','d94','d95']:
            continue
        # print(f"Creating (if not exists) database for {depname}")
        #
        # subprocess.run(f"""
        #   {psql_exec} -U admin -h {psql_host} -tc "\\l" | grep -q "{depname}" || {psql_exec} -U admin -h {psql_host} -c "CREATE DATABASE {depname} WITH TEMPLATE template_postgis OWNER admin;"
        #   """, shell=True)
        #
        # print("Adding raster support...")
        # subprocess.run(f"""
        # {psql_exec} -q -U admin -h {psql_host} -d "{depname}" -c "CREATE EXTENSION postgis_raster;"
        # """, shell=True)

        for table in tables:
            paths = sorted(glob.glob(fr'{dep}{table["path"]}', recursive=True))  # Sort for raster type
            if len(paths) == 0:
                print(f'No path found for {dep}{table["path"]}, skipping...')
                continue
            path = paths[0]
            print(f"Creating table {table['name']} with {path} ...")
            if table['type'] == 'raster':
                subprocess.run(f"""
                {raster2pgsql_exec} -t 64x64 -c -C -I -s 2154 {path}/* public.{table['name']} | psql -U admin -h {psql_host} -d {depname}
                """, shell=True)
                continue
            subprocess.run(f"""
            {ogr2ogr_exec} -progress -f "PostgreSQL" PG:"host={psql_host} port=5432 dbname={depname} user=admin" "{path}" -nln "{table['name']}" -nlt "{table['type']}" -lco geometry_name=geom -lco SPATIAL_INDEX=GIST -lco FID=gid -lco GEOM_TYPE=geometry -gt 8192
            """, shell=True)

            print(f"Table {table['name']} created and filled !")
        print(f"Database {depname} done !")

    # Deps database
    # print(f"Creating (if not exists) database for deps")

    # subprocess.run(f"""
    #   {psql_exec} -U admin -h {psql_host} -tc "\\l" | grep -q "deps" || psql -U admin -h {psql_host} -c "CREATE DATABASE deps WITH TEMPLATE template_postgis OWNER admin;"
    #   """, shell=True)
    #
    # for table_dep in tables_deps:
    #     paths = glob.glob(fr"{data_path}/deps{table_dep['path']}", recursive=True)
    #     if len(paths) == 0:
    #         print(f"No path found for deps{table_dep['path']}, skipping...")
    #     else:
    #         path = paths[0]
    #         subprocess.run(f"""
    #         {ogr2ogr_exec} -progress -f "PostgreSQL" PG:"host={psql_host} port=5432 dbname=deps user=admin" "{path}" -nln "{table_dep['name']}" -nlt "{table_dep['type']}" -lco geometry_name=geom -lco SPATIAL_INDEX=GIST -lco FID=gid -lco GEOM_TYPE=geometry
    #         """, shell=True)
    #
    # print(f"Table deps created and filled !")

    print("Databases initialization done !")
