FROM ubuntu:18.10

RUN  apt-get update -y
# apt install default-jdk -y
RUN  apt-get install systemd -y

RUN  add-apt-repository ppa:openjdk-r/ppa -y
RUN  apt-get update -y
# apt install openjdk-9-jre -y
RUN  apt install openjdk-11-jdk -y

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3
RUN  apt-get -y install python3-pip
RUN pip3 install kafka

RUN cd /opt/
RUN wget https://archive.apache.org/dist/kafka/2.7.0/kafka_2.13-2.7.0.tgz
RUN tar xzf kafka_2.13-2.7.0.tgz
RUN mv kafka_2.13-2.7.0 /usr/local/kafka

ENV JAVA_HOME "/usr/lib/jvm/java-1.11.0-openjdk-amd64"

CMD ["/usr/local/kafka/bin/zookeeper-server-start.sh","/usr/local/kafka/config/zookeeper.properties","/usr/local/kafka/bin/kafka-server-start.sh","/usr/local/kafka/config/server.properties"]
