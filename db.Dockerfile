FROM postgis/postgis:16-3.4-alpine as db_build

RUN apk update
#RUN apk add gdal
#RUN apk add gdal-tools
#RUN apk add --no-cache python3 py3-pip
#RUN apk add build-base
#RUN apk add postgresql-dev gcc python3-dev musl-dev
#RUN pip install psycopg2-binary
#RUN pip install argparse
#RUN apt-get update -y
#RUN apt-get install -y yum
#RUN yum install postgis2_94
#RUN yum install postgis2_94-utils
#RUN yum install postgis2_94-client

# RUN time python3 /elt/2_load/db.py
# RUN time python3 /elt/2_load/commune_info.py
# RUN time python3 /elt/2_load/plu.py
# RUN time python3 /elt/3_transform/db.py

FROM postgis/postgis:16-3.4-alpine as db

RUN apk update
