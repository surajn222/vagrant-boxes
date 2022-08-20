setup_variables(){
HOME="/home/hduser"
SPARK_HOME=$HOME/spark-3.1.2-bin-hadoop2.7
SHELL_PROFILE="$HOME/.bashrc"
SPARK_URL=https://mirrors.estointernet.in/apache/spark/spark-3.1.2/spark-3.1.2-bin-hadoop2.7.tgz
java -version
scala -version 
}

create_dirs(){

mkdir -p $HOME/scripts
mkdir -p $HOME/spark-3.1.2-bin-hadoop2.7
}


install_spark(){
sudo apt update -y
sudo apt install scala -y

cd $HOME
wget $SPARK_URL
tar -xvzf spark-3.1.2-bin-hadoop2.7.tgz
cp -R spark-3.1.2-bin-hadoop2.7/* $HOME/spark-3.1.2-bin-hadoop2.7
chown -R hduser:hduser $HOME/spark-3.1.2-bin-hadoop2.7
}

configure_env_vars(){
source $HOME/.bashrc

echo "export PATH=\$PATH:$HOME/scripts" >> $SHELL_PROFILE
echo "export SPARK_HOME=$HOME/spark-3.1.2-bin-hadoop2.7" >> $HOME/.bashrc
echo "export PATH=PATH:$HOME/spark-3.1.2-bin-hadoop2.7/bin:$HOME/spark-3.1.2-bin-hadoop2.7/sbin" >> $HOME/.bashrc
echo "export PYSPARK_PYTHON=/usr/bin/python3" >> $HOME/.bashrc
echo "#export PYSPARK_DRIVER_PYTHON=python3" >> $HOME/.bashrc
echo "#export PYSPARK_DRIVER_PYTHON_OPTS=\"notebook\"" >> $HOME/.bashrc
echo "alias pyspark=\"$HOME/spark-3.1.2-bin-hadoop2.7/bin/pyspark --conf spark.sql.warehouse.dir='file:///tmp/spark-warehouse' --packages com.databricks:spark-csv_2.11:1.5.0 --packages com.amazonaws:aws-java-sdk-pom:1.10.34 --packages org.apache.hadoop:hadoop-aws:2.7.3\" " >> $HOME/.bashrc
echo "export HADOOP_CONF_DIR=/usr/local/lib/hadoop/etc/hadoop" >> $HOME/.bashrc 
echo "export HADOOP_CONF_DIR=/usr/local/lib/hadoop/etc/hadoop" >> $HOME/spark-3.1.2-bin-hadoop2.7/bin/load-spark-env.sh
echo "export PATH=$PATH:/home/hduser/scripts" >> $HOME/.bashrc


source $HOME/.bashrc

}

start_spark()
{
sudo -u hduser $SPARK_HOME/sbin/start-master.sh
sudo -u hduser $SPARK_HOME/sbin/start-workers.sh spark://localhost:7077

sudo -u hduser $SPARK_HOME/bin/spark-submit --master yarn --executor-memory 1G --driver-memory 1G --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" --packages com.databricks:spark-csv_2.11:1.5.0 --packages com.amazonaws:aws-java-sdk-pom:1.10.34 --packages org.apache.hadoop:hadoop-aws:2.7.3 /vagrant/test_spark.py
sudo -u hduser $SPARK_HOME/bin/spark-submit --master yarn --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" --packages com.databricks:spark-csv_2.11:1.5.0 --packages com.amazonaws:aws-java-sdk-pom:1.10.34 --packages org.apache.hadoop:hadoop-aws:2.7.3 /vagrant/test_spark.py
sudo -u hduser $SPARK_HOME/bin/spark-submit --master yarn –-conf spark.logLineage=true --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\"  /vagrant/test_spark.py
sudo -u hduser $SPARK_HOME/bin/spark-submit --master yarn –-conf spark.logLineage=true --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" --packages za.co.absa.spline.agent.spark:spark-2.4-spline-agent-bundle_2.12:3.1 --conf "spark.sql.queryExecutionListeners=za.co.absa.spline.harvester.listener.SplineQueryExecutionListener" --conf "spark.spline.lineageDispatcher.http.producer.url=http://localhost:5000/spark" /vagrant/test_spark.py
sudo -u hduser $SPARK_HOME/bin/spark-submit --master yarn --packages za.co.absa.spline.agent.spark:spark-2.4-spline-agent-bundle_2.12:3.1 --conf spark.sql.queryExecutionListeners=za.co.absa.spline.harvester.listener.SplineQueryExecutionListener --conf spark.spline.lineageDispatcher=console --conf spark.spline.lineageDispatcher.console.className=za.co.absa.spline.harvester.dispatcher.ConsoleLineageDispatcher --conf spark.spline.lineageDispatcher.console.stream=OUT python_example.py



}

setup_variables
create_dirs
install_spark
configure_env_vars
start_spark

#spark-shell
#sudo apt install scala -y
#sudo apt install scala -y
