setup_system()
{
sudo apt-get update

packages=('git' 'unzip', 'wget', 'ca-certificates')
sudo apt-get install ${packages[@]} -y

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update


}

install_postgres()
{
sudo apt-get install postgresql postgresql-contrib -y
sudo service postgresql stop
sudo service postgresql start
apt show postgresql
}


allow_connections()
{
  echo "This is a manual step, please make sure you do this"
  echo '
  In the file /etc/postgresql/14/main/postgresql.conf, edit to reflect this = listen_addresses = "*"
  In the file /etc/postgresql/14/main/pg_hba.conf, edit to reflect this:
  host    all             all             192.168.33.33/24        md5

  Then, access via psql -h localhost -p 5432 -U postgres
  '

}

set_password()
{
#This is a manual step
sudo su - postgres
psql

ALTER USER postgres PASSWORD 'postgres';
\conninfo
}


setup_database()
{
cd /opt/
git clone https://github.com/surajn222/postgresDBSamples.git
cd postgresDBSamples/adventureworks
#These are manual steps
#psql -U postgres -h 127.0.0.1 -c "CREATE DATABASE \"adventureworks\";" --password is postgres
#psql -U postgres -h 127.0.0.1 -c "\l;" --password is postgres
#psql -U postgres -h 127.0.0.1 -d adventureworks < install.sql --password is postgres
}

create_mysql_fdw()
{
 apt-get install postgresql-14-mysql-fdw -y

#CREATE EXTENSION mysql_fdw;
#CREATE SERVER mysql_server_2 FOREIGN DATA WRAPPER mysql_fdw OPTIONS (host '10.0.2.15', port '3306');
#CREATE USER MAPPING FOR postgres SERVER mysql_server_2 OPTIONS (username 'root', password 'toor');
#IMPORT FOREIGN SCHEMA employees LIMIT TO (titles) FROM SERVER mysql_server_2 INTO public;

}

create_file_fdw()
{
echo "Manual run"
#CREATE EXTENSION file_fdw;
#CREATE SERVER pglog FOREIGN DATA WRAPPER file_fdw;
#CREATE FOREIGN TABLE pglog (
#  column_a integer,
#  column_b text
#) SERVER pglog
#OPTIONS ( filename '/vagrant/test-fdw.csv', format 'csv', header 'true' );
}


setup_system
install_postgres
setup_database
create_file_fdw
create_mysql_fdw
allow_connections

echo -e "\n\n\nPlease check the functions of set_password and setup_database and create_file_fdw and create_mysql_fdw and allow_connections"