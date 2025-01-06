#!/bin/bash

RUN_DML_SCRIPTS="${RUN_DML_SCRIPTS:-true}"

# Start PostgreSQL if not running (assuming it's running in a Docker container)
# Avoid using -h localhost here, as I attempted it and it didn't work
echo "Waiting for PostgreSQL to start..."
until pg_isready -p 5432 -U ${POSTGRES_USER}; do
    sleep 1
done

# Create the database (if it doesn't already exist)
# I had to define the command as shown below because PostgreSQL doesn't natively support the `CREATE DATABASE IF NOT EXISTS` syntax
# Ref: https://stackoverflow.com/questions/18389124/simulate-create-database-if-not-exists-for-postgresql
echo "SELECT 'CREATE DATABASE ${POSTGRES_DB}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${POSTGRES_DB}')\gexec" | psql -U ${POSTGRES_USER}

echo "Running DDL scripts..."
for script in /docker-entrypoint-initdb.d/ddl/*.sql; do
    psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f "$script"
done

echo "Running PL/pgSQL scripts..."
for script in /docker-entrypoint-initdb.d/packages/*.sql; do
    psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f "$script"
done

# Optionally run DML scripts to insert data
if [[ "$RUN_DML_SCRIPTS" == "true" ]]; then
    echo "Running DML scripts..."
    for script in /docker-entrypoint-initdb.d/dml/*.sql; do
        psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} -f "$script"
    done
else
    echo "Skipping DML scripts."
fi

echo "Initialization complete!"
