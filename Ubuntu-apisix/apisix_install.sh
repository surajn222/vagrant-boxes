cd /opt
yum update -y
yum install wget yum-utils net-tools -y
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -ivh epel-release-latest-7.noarch.rpm
sudo yum install etcd curl
sudo yum install git gcc luarocks lua-devel wget -y
ETCD_VERSION='3.4.13'
wget https://github.com/etcd-io/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz
tar -xvf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz &&   cd etcd-v${ETCD_VERSION}-linux-amd64 &&   sudo cp -a etcd etcdctl /usr/bin/
nohup etcd >/tmp/etcd.log 2>&1 &
nohup etcd --max-request-bytes 1572864000 >/tmp/etcd.log 2>&1 &
nohup etcd --max-request-bytes 157286400000 --proxy-write-timeout 0 >/tmp/etcd.log 2>&1 &
sudo yum install -y https://repos.apiseven.com/packages/centos/apache-apisix-repo-1.0-1.noarch.rpm
sudo yum-config-manager --add-repo https://repos.apiseven.com/packages/centos/apache-apisix.repo
yum install apisix -y
yum install apisix-dashboard.x86_64 -y
wget https://raw.githubusercontent.com/surajn222/vagrant-boxes/main/Ubuntu-apisix/conf/conf.yaml
cp /opt/conf.yaml /usr/local/apisix/dashboard/conf/
sudo service apisix status
sudo service apisix stop
sudo service apisix start
sudo /usr/local/apisix/dashboard/manager-api -p /usr/local/apisix/dashboard/ -f &> /usr/local/apisix/dashboard/log.log &
/opt/etcd-browser
node server.js