#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER redash PASSWORD '$REDASH_PASSWORD';
    CREATE DATABASE redash;
    GRANT ALL PRIVILEGES ON DATABASE redash TO redash;
EOSQL

echo "Dumping redash schema into the redash database"
psql -v --username redash redash < /docker-entrypoint-initdb.d/redash.dump
