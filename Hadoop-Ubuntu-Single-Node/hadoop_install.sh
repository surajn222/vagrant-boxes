#1. Create a new user
#3. Update system
#2. Install Java
#4. Install ssh and create keys and
#5. Download Hadoop
#6. Install Hadoop
#7. Update the hadoop files
#8. Update Linux config files
#9. Start Hadoop

update_system()
{
	echo "Updating system"
	apt-get update -y
}

install_java()
{
	sudo apt-get autoremove java-common -y
	sudo apt-get install openjdk-8-jdk -y
	java -version
	echo $JAVA_HOME
	java_home=`echo $JAVA_HOME`
}


setup_new_user()
{
	echo -n "Enter the new 'GroupName' for new Hadoop user : Should be hduser"
	hdGroup="hduser"
	echo -n "Enter the new 'UserName' for Hadoop: Enter hduser"
	hdUserName="hduser"
	
	sudo addgroup $hdGroup
	#sudo adduser -ingroup $hdGroup $hdUserName
	# quietly add a user without password
	adduser --quiet --disabled-password --gecos "" -ingroup  $hdGroup $hdUserName
	# set password
	echo "hduser:P@ssw0rd123$" | chpasswd


}

setup_ssh()
{
hdUserName="hduser"
hdGroup="hduser"

#Create .ssh dir
mkdir -p /home/$hdUserName/.ssh
chown -R $hdUserName:$hdGroup /home/$hdUserName/.ssh

#Create ssh config
touch /home/$hdUserName/.ssh/config
cat <<EOT >> /home/$hdUserName/.ssh/config
Host *
    StrictHostKeyChecking no
EOT
chown $hdUserName:$hdGroup /home/$hdUserName/.ssh/config
chmod 400 /home/$hdUserName/.ssh/config

#Install ssh
sudo apt-get install ssh -y

#Create keygen
echo "--------Please press Enter when asking for file to save RSA keys -------------------------------"
sudo -u $hdUserName ssh-keygen -t rsa -f /home/$hdUserName/.ssh/id_rsa -q -P ""
sudo -u $hdUserName cat /home/$hdUserName/.ssh/id_rsa.pub >> /home/$hdUserName/.ssh/authorized_keys

}

download_hadoop()
{
#Download hadoop2.7.3 from apache
sudo wget https://archive.apache.org/dist/hadoop/core/hadoop-2.7.3/hadoop-2.7.3.tar.gz  
sudo tar xvfz hadoop-2.7.3.tar.gz

}


setup_hadoop()
{
#Move hadoop

hdUserName="hduser"
hdGroup="hduser"
#Creating tmp folder for hadoop under hadoop/app/hadoop/tmp 
sudo mkdir -p /usr/local/lib/hadoop/app/hadoop/tmp
sudo chown -R $hdUserName:$hdGroup /usr/local/lib/hadoop/
#sudo -u $hdUserName chown -R $hdUserName:$hdGroup /usr/local/lib/hadoop/app/hadoop/tmp
sudo mv hadoop-2.7.3/* /usr/local/lib/hadoop/

}


create_hadoop_files_and_dirs ()
{
hdUserName="hduser"
hdGroup="hduser"
#Re naming  mapred-site.xml.template file to mapred-site.xml
sudo -u $hdUserName cp /usr/local/lib/hadoop/etc/hadoop/mapred-site.xml.template /usr/local/lib/hadoop/etc/hadoop/mapred-site.xml

#Creating hadoop storage location for NameNode and DataNode under hadoop/hadoop_store/hdfs
sudo -u $hdUserName mkdir -p /usr/local/lib/hadoop/hadoop_store/hdfs/namenode
sudo -u $hdUserName mkdir -p /usr/local/lib/hadoop/hadoop_store/hdfs/datanode

sudo -u $hdUserName chown -R $hdUserName:$hdGroup /usr/local/lib/hadoop/hadoop_store

#Giving permission to write the .bashrc, hadoop-env.sh core-site.xml, mapred-site.xml, hdfs-site.xml, yarn-site.xml.
sudo -u hduser chmod o+w /home/$hdUserName/.bashrc
sudo -u hduser chmod o+w /usr/local/lib/hadoop/etc/hadoop/hadoop-env.sh
sudo -u hduser chmod o+w /usr/local/lib/hadoop/etc/hadoop/core-site.xml
sudo -u hduser chmod o+w /usr/local/lib/hadoop/etc/hadoop/mapred-site.xml
sudo -u hduser chmod o+w /usr/local/lib/hadoop/etc/hadoop/hdfs-site.xml
sudo -u hduser chmod o+w /usr/local/lib/hadoop/etc/hadoop/yarn-site.xml

#sudo sed -i "s|\${JAVA_HOME}|$java_home|g" /usr/local/lib/hadoop/etc/hadoop/hadoop-env.sh

#echo -e '\n\n #Hadoop Variable START \n export HADOOP_HOME=/usr/local/lib/hadoop \n export HADOOP_INSTALL=$HADOOP_HOME \n export HADOOP_MAPRED_HOME=$HADOOP_HOME \n export HADOOP_COMMON_HOME=$HADOOP_HOME \n export HADOOP_HDFS_HOME=$HADOOP_HOME \n export YARN_HOME=$HADOOP_HOME \n export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native \n export PATH=$PATH:$HADOOP_HOME/sbin/:$HADOOP_HOME/bin \n #Hadoop Variable END\n\n' >> /home/$hdUserName/.bashrc

}

configure_hadoop()
{
hdUserName="hduser"
hdGroup="hduser"
#core-site.xml
sudo sed -i '/<configuration>/a <property>\n\t\t<name>hadoop.tmp.dir</name>\n\t\t<value>/home/hduser/hadoop/app/hadoop/tmp</value>\n</property>\n<property>\n\t\t<name>fs.default.name</name>\n\t\t<value>hdfs://localhost:50090</value>\n</property>' /usr/local/lib/hadoop/etc/hadoop/core-site.xml

#mapred-site.xml
sudo sed -i '/<configuration>/a <property>\n\t\t <name>mapreduce.framework.name</name>\n\t\t <value>yarn</value>\n</property>' /usr/local/lib/hadoop/etc/hadoop/mapred-site.xml

#Yarn-site.xml
sudo sed -i '/<configuration>/a <property>\n\t\t<name>yarn.nodemanager.aux-services</name>\n\t\t<value>mapreduce_shuffle</value>\n</property><property>\n\t\t<name>yarn.nodemanager.pmem-check-enabled</name>\n\t\t<value>false</value>\n</property><property>\n\t\t<name>yarn.nodemanager.vmem-check-enabled</name>\n\t\t<value>false</value>\n</property>' /usr/local/lib/hadoop/etc/hadoop/yarn-site.xml


JAVA_HOME="'/usr/lib/jvm/java-8-openjdk-amd64/'"
sudo sed -i "s|\${JAVA_HOME}|$JAVA_HOME|g" /usr/local/lib/hadoop/etc/hadoop/hadoop-env.sh
   
mkdir -p /home/hduser/hadoop/app/hadoop/tmp/dfs/namesecondary
mkdir -p /home/hduser/hadoop/app/hadoop/tmp/dfs/data
chown -R hduser:hduser /home/hduser/hadoop/

}

configure_bashrc()
{
hdUserName="hduser"
hdGroup="hduser"
HADOOP_HOME="/usr/local/lib/hadoop"

cat <<EOT >> /home/$hdUserName/.bashrc
export HADOOP_HOME='/usr/local/lib/hadoop'
HADOOP_HOME="/usr/local/lib/hadoop"
export PATH=$PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:/usr/local/lib/hadoop/bin/
export HADOOP_MAPRED_HOME=${HADOOP_HOME}
export HADOOP_COMMON_HOME=${HADOOP_HOME}
export HADOOP_HDFS_HOME=${HADOOP_HOME}
export YARN_HOME=${HADOOP_HOME}
EOT

source /home/$hdUserName/.bashrc
}


start_hadoop()
{
sudo -u hduser /usr/local/lib/hadoop/bin/hdfs namenode -format
sudo -u hduser /usr/local/lib/hadoop/sbin/start-dfs.sh
sudo -u hduser /usr/local/lib/hadoop/sbin/start-yarn.sh



}

update_system
install_java
setup_new_user
setup_ssh
download_hadoop
setup_hadoop
configure_hadoop
configure_bashrc
start_hadoop
