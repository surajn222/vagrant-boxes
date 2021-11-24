#Install Kafka
update_system()
{
sudo apt update -y
#sudo apt install default-jdk -y
sudo apt-get install systemd -y

sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update -y
#sudo apt install openjdk-9-jre -y
sudo apt install openjdk-11-jdk -y

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
sudo systemctl stop zookeeper
sudo systemctl stop kafka

sudo systemctl start zookeeper
sleep 5
sudo systemctl start kafka


#sudo systemctl status kafka
#sudo systemctl status zookeeper
}

create_and_access_topics()
{
cd /usr/local/kafka
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic testTopic
bin/kafka-topics.sh --list --zookeeper localhost:2181
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic testTopic
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic testTopic --from-beginning
}


setup_kafka_gui()
{
git clone https://github.com/provectus/kafka-ui.git
cd kafka-ui
./mvnw spring-boot:run -Pprod

}

update_system
download_kafka
configure_system
restart_services
create_and_access_topics