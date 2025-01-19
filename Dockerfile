# Use the official PostgreSQL image
FROM postgres:latest

# stop caching please i beg you 
ARG CACHEBUST=1

# Copy the SQL scripts and initialization script into the container
COPY ./init.sh /docker-entrypoint-initdb.d/
COPY ./ddl /docker-entrypoint-initdb.d/ddl/
COPY ./dml /docker-entrypoint-initdb.d/dml/
COPY ./packages /docker-entrypoint-initdb.d/packages/

# Make the init.sh script executable
RUN chmod +x /docker-entrypoint-initdb.d/init.sh
RUN chmod +x /docker-entrypoint-initdb.d/init.sh
