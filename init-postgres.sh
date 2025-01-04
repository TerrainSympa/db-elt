#!/bin/bash
# Small script to increase some configuration settings for better loading and transform performance
set -e

echo "host all all all md5" >> "/var/lib/postgresql/data/pg_hba.conf"
echo "max_parallel_workers = 6" >> "/var/lib/postgresql/data/postgresql.conf"
echo "max_worker_processes = 8" >> "/var/lib/postgresql/data/postgresql.conf"
echo "max_parallel_workers_per_gather = 8" >> "/var/lib/postgresql/data/postgresql.conf"
echo "min_parallel_table_scan_size = '8MB'" >> "/var/lib/postgresql/data/postgresql.conf"
echo "min_parallel_index_scan_size = '8MB'" >> "/var/lib/postgresql/data/postgresql.conf"
echo "work_mem = '64MB'" >> "/var/lib/postgresql/data/postgresql.conf"
echo "shared_buffers = '8GB'" >> "/var/lib/postgresql/data/postgresql.conf"
echo "effective_cache_size = '16GB'" >> "/var/lib/postgresql/data/postgresql.conf"
echo "maintenance_work_mem = '1GB'" >> "/var/lib/postgresql/data/postgresql.conf"
