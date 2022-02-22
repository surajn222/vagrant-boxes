apt-get update -y
apt-get install mysql-server -y
sudo service mysql restart

#Make mysql listen on 0.0.0.0
#vim /etc/mysql/mysql.conf.d/mysqld.cnfi
#Change bind-address to 0.0.0.0
#sudo service mysql restart
#netstat -peanut | grep 3306

#Create new user
#mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY 'toor';"

