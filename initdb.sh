#!/bin/bash

#Note: The script will only run if the data directory of PostgreSQL (/data/postgres in your case) is empty. If it's not the first time you are starting the container and you have already initialized the PostgreSQL data directory before, the script won't run. If you want to re-run the script, you'll need to delete the PostgreSQL volume or data and start the container again.


# When you bring up the PostgreSQL container with docker-compose up, the initdb.sh script will run and create the local database if it doesn't exist.

set -e

# Create the database if it doesn't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname template1 <<-EOSQL
    SELECT 'CREATE DATABASE localstack_db'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'localstack_db')\\gexec
EOSQL

# Create the user if it doesn't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    DO \$\$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'postgres') THEN
            CREATE USER postgres WITH PASSWORD 'postgres';
        END IF;
    END
    \$\$;
EOSQL
