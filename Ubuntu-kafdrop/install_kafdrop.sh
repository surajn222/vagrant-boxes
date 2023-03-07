#Login to the machine and run this script with root account
apt-get remove openjdk* -y
apt-get install openjdk-11-jdk -y
echo "export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64/" >> /root/.bashrc
echo "export JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64/" >> ~/.bashrc
cd /opt
git clone https://github.com/obsidiandynamics/kafdrop.git
ls
cd kafdrop/
ls
pwd
apt-get install maven -y
mvn clean -Dskiptests package install
mvn clean -Dskiptests package install
java --add-opens=java.base/sun.nio.ch=ALL-UNNAMED -jar target/kafdrop-3.28.0.jar.jar --kafka.brokerConnect=10.0.2.2:9093 &> kafdrop.log &

java --add-opens=java.base/sun.nio.ch=ALL-UNNAMED -jar target/kafdrop-3.30.0-SNAPSHOT.jar --kafka.brokerConnect=10.0.2.2:9093 &> kafdrop.log &

