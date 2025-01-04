import glob
import os
import subprocess
import sys
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())
os.environ['PGPASSWORD'] = os.environ.get("PG_PASSWORD") or 'password'
psql_host = os.environ.get("PSQL_HOST") or 'localhost'
psql_exec = os.environ.get("PSQL_EXEC") or 'psql'

if __name__ == "__main__":
    base_dir_path = os.path.dirname(os.path.realpath(sys.argv[0]))
    data_dir_path = f'{os.environ.get("DATA_PATH")}/datalake'  # No / at the end
    queries_dir_path = f"{base_dir_path}/queries"
    init_script_excluded = []
    fill_script_excluded = ['1_altitude.sql']  # Too time consuming for now...
    clean_script_excluded = []
    # clean_script_excluded = ['clean.sql']

    init_scripts = glob.glob(rf"{queries_dir_path}/1_init/*.sql")
    fill_scripts = glob.glob(rf"{queries_dir_path}/2_fill/*.sql")
    clean_scripts = glob.glob(rf"{queries_dir_path}/3_clean/*.sql")
    custom_scripts = glob.glob(rf"{queries_dir_path}/3_clean/clean.sql")
    deps = glob.glob(rf"{data_dir_path}/D*")

    for dep in deps:
        depname = dep.split('/')[-1].lower()
        depno = depname[1:]

        subprocess.run(f"""
        {psql_exec} -U admin -h {psql_host} -c '\set AUTOCOMMIT off'
        """, shell=True)

        print(f"Filling database {depname}...")

        for scripts in [custom_scripts]:
        # for scripts in [init_scripts, fill_scripts, clean_scripts]:
            for script_path in scripts:
                script_name = script_path.split('/')[-1]
                if script_name in init_script_excluded or script_name in fill_script_excluded or script_name in clean_script_excluded:
                    print(f"{script_name} skipped")
                    continue

                print(f"Exec {script_name}")
                subprocess.run(f"""
            {psql_exec} -q -U admin -h {psql_host} -d "{depname}" -v depno="'{depno}'" -f "{script_path}"
            """, shell=True)

        subprocess.run(f"""
        {psql_exec} -U admin -h {psql_host} -c '\set AUTOCOMMIT on'
        """, shell=True)
