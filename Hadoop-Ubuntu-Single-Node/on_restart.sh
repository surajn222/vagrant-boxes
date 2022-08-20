start_hadoop()
{
sudo -u hduser rm -rf /home/hduser/hadoop/app/hadoop/tmp/dfs/data/current/VERSION
sudo -u hduser /usr/local/lib/hadoop/bin/hdfs namenode -format -clusterID CID-5f7e9b58-607c-4795-81d3-ccd60e654ae5
#sudo -u hduser /usr/local/lib/hadoop/bin/hdfs datanode -format -regular -clusterID CID-5f7e9b58-607c-4795-81d3-ccd60e654ae5
sudo -u hduser /usr/local/lib/hadoop/sbin/stop-all.sh
sudo -u hduser /usr/local/lib/hadoop/sbin/start-dfs.sh
sudo -u hduser /usr/local/lib/hadoop/sbin/start-yarn.sh
#sudo -u hduser /usr/local/lib/hadoop/sbin/hadoop-daemon.sh start datanode
}


start_spark()
{

sudo -u hduser $SPARK_HOME/sbin/stop-master.sh
sudo -u hduser $SPARK_HOME/sbin/stop-workers.sh
sudo -u hduser $SPARK_HOME/sbin/start-master.sh
sudo -u hduser $SPARK_HOME/sbin/start-workers.sh spark://localhost:7077

#sudo -u hduser $SPARK_HOME/bin/spark-submit --master yarn --executor-memory 1G --driver-memory 1G --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" --packages com.databricks:spark-csv_2.11:1.5.0 --packages com.amazonaws:aws-java-sdk-pom:1.10.34 --packages org.apache.hadoop:hadoop-aws:2.7.3 /vagrant/test_spark.py
#sudo -u hduser $SPARK_HOME/bin/spark-submit --master yarn --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" --packages com.databricks:spark-csv_2.11:1.5.0 --packages com.amazonaws:aws-java-sdk-pom:1.10.34 --packages org.apache.hadoop:hadoop-aws:2.7.3 /vagrant/test_spark.py
#sudo -u hduser $SPARK_HOME/bin/spark-submit --master yarn --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" /vagrant/test_spark.py
}


start_hadoop
start_spark
