#Install Kafka
update_and_setup_system()
{
sudo apt update -y
#sudo apt install default-jdk -y
sudo apt-get install systemd -y

sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update -y
#sudo apt install openjdk-9-jre -y
sudo apt install openjdk-11-jdk -y

update-alternatives --install /usr/bin/python python /usr/bin/python3
sudo apt-get -y install python3-pip
pip3 install kafka
}

download_kafka()
{
cd /opt/
wget https://archive.apache.org/dist/kafka/2.7.0/kafka_2.13-2.7.0.tgz
tar xzf kafka_2.13-2.7.0.tgz
mv kafka_2.13-2.7.0 /usr/local/kafka
}


configure_system()
{
cat > /etc/systemd/system/zookeeper.service << EOF
[Unit]
Description=Apache Zookeeper server
Documentation=http://zookeeper.apache.org
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
ExecStart=/usr/local/kafka/bin/zookeeper-server-start.sh /usr/local/kafka/config/zookeeper.properties
ExecStop=/usr/local/kafka/bin/zookeeper-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target


EOF




cat > /etc/systemd/system/kafka.service << EOF
[Unit]
Description=Apache Kafka Server
Documentation=http://kafka.apache.org/documentation.html
Requires=zookeeper.service

[Service]
Type=simple
Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64"
ExecStart=/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties
ExecStop=/usr/local/kafka/bin/kafka-server-stop.sh

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload

}

restart_services()
{
sudo systemctl stop kafka
echo "kafka stopped"
sudo systemctl stop zookeeper
echo "zookeeper stopped"
sudo systemctl start zookeeper
echo "zookeeper started"
sudo systemctl status zookeeper
sleep 1
sudo systemctl start kafka
echo "kafka started"
sudo systemctl status kafka

#sudo systemctl status kafka
#sudo systemctl status zookeeper
}

create_and_access_topics()
{
cd /usr/local/kafka
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic topic_1
bin/kafka-topics.sh --list --zookeeper localhost:2181
#bin/kafka-console-producer.sh --broker-list localhost:9092 --topic testTopic
#bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic testTopic --from-beginning
}


setup_kafka_gui()
{
git clone https://github.com/provectus/kafka-ui.git
cd kafka-ui
./mvnw spring-boot:run -Pprod

}

setup_kafdrop()
{
cd /opt
git clone https://github.com/obsidiandynamics/kafdrop.git
ls
cd kafdrop/
ls
pwd
sudo apt-get install maven -y
mvn clean -DskipTests=true package install
#java --add-opens=java.base/sun.nio.ch=ALL-UNNAMED -jar target/kafdrop-3.28.0-SNAPSHOT.jar --kafka.brokerConnect=10.0.2.2:9093 &> kafdrop.log &
}

add_data()
{
    echo "Cloning git repo and initializing producer"
    cd /opt
    rm -rf kafka
    git clone https://github.com/surajn222/kafka.git
    cd kafka/python
    python producer1.py &> producer.log &
    python consumer1.py &> consumer.log &
    echo "Please check /opt/kafka for logs of producer and consumer"

}

update_and_setup_system
download_kafka
configure_system
restart_services
echo "Kafka is installed. Setting up kafdrop"
setup_kafdrop
create_and_access_topics
##Initializing producers and consumers
add_data
echo "Access Kafdrop at port localhost:9000"