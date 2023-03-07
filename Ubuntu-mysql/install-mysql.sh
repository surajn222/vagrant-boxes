apt-get update -y
apt-get install mysql-server -y
sudo service mysql restart

#Make mysql listen on 0.0.0.0
#vim /etc/mysql/mysql.conf.d/mysqld.cnf
#Change bind-address to 0.0.0.0
#sudo service mysql restart
#netstat -peanut | grep 3306

# GRANT ALL PRIVILEGES ON metrics.* TO 'root'@'%'

#Create new user
#mysql -e "CREATE USER 'root'@'%' IDENTIFIED BY 'toor';"

