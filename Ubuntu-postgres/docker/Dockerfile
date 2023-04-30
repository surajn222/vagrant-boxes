FROM postgres:9.4

#Get database sample
RUN apt-get update -y
RUN apt-get install git -y
RUN cd /opt
RUN git clone https://github.com/surajn222/postgresDBSamples
#Edit this dockerfile to add any sql file to the below location, and that sql file will be executed on startup
RUN cp postgresDBSamples/worldDB-1.0/world.sql /docker-entrypoint-initdb.d/

#Set username and password
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
#COPY resources/*.sql /docker-entrypoint-initdb.d/


psql -U postgres -d test -f world.sql

