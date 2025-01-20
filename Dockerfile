# Use the official PostgreSQL image
FROM postgres:latest

# Copy the SQL scripts and initialization script into the container
COPY ./init.sh ./ddl ./dml ./packages /docker-entrypoint-initdb.d/

# Make the init.sh script executable
RUN chmod +x /docker-entrypoint-initdb.d/init.sh
