setup_system()
{
apt-get update -y
apt-get install python3.7 python3-dev -y
sudo apt-get install python3-pip -y
sudo apt install libpython3.7-dev
sudo apt-get install python3.7-dev
sudo apt install python-dev gcc
apt-get install libffi libffi-dev
update-alternatives --install /usr/bin/python python /usr/bin/python3.7 10
update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 10
}
#sed -i 's/\r//' setup.sh
#chmod 777 /vagrant/dags

install_airflow()
{
echo "Install Airflow"
pip3 install apache-airflow
pip3 install Cython
pip3 install numpy
pip3 install cffi

pip3 install apache-airflow[cryptography]
pip3 install apache-airflow[azure-storage-blob]
#pip3 install apache-airflow-providers-amazon
pip3 install setuptools_rust
pip3 install --upgrade pip
pip3 install apache-airflow[amazon]
pip3 install apache-airflow-providers-microsoft-azure



airflow db init
airflow users  create --role Admin --username admin --email admin --firstname admin --lastname admin --password admin

}
setup_system
install_airflow