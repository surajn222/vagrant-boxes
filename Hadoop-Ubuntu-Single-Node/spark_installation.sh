#!/bin/bash

# Run this by typing `bash spark-install.sh`

HOME="/home/hduser"
echo "DOWNLOADING SPARK"

# Specify your shell config file
# Aliases will be appended to this file
SHELL_PROFILE="$HOME/.bashrc"

# Set the install location, $HOME is set by default
SPARK_INSTALL_LOCATION=$HOME

# Specify the URL to download Spark from
SPARK_URL=http://apache.mirrors.tds.net/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz

# The Spark folder name should be the same as the name of the file being downloaded as specified in the SPARK_URL
SPARK_FOLDER_NAME=spark-2.4.7-bin-hadoop2.7.tgz

# Find the proper md5 hash from the Apache site
SPARK_MD5=50e73f255f9bde50789ad5bd657c7a71

# Create scripts folder for storing jupyspark.sh and localsparksubmit.sh
mkdir $HOME/scripts
echo "export PATH=\$PATH:$HOME/scripts" >> $SHELL_PROFILE


cat > $HOME/scripts/jupyspark.sh << EOF
#!/bin/bash \
export PYSPARK_DRIVER_PYTHON=jupyter \
export PYSPARK_DRIVER_PYTHON_OPTS=\"notebook --NotebookApp.open_browser=True --NotebookApp.ip='localhost' --NotebookApp.port=8888\" \

\${SPARK_HOME}/bin/pyspark \
--master local[4] \
--executor-memory 1G \
--driver-memory 1G \
--conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" \
--packages com.databricks:spark-csv_2.11:1.5.0 \
--packages com.amazonaws:aws-java-sdk-pom:1.10.34 \
--packages org.apache.hadoop:hadoop-aws:2.7.3
EOF

chmod +x $HOME/scripts/jupyspark.sh

cat > $HOME/scripts/localsparksubmit.sh << EOF
#!/bin/bash
\${SPARK_HOME}/bin/spark-submit \
--master local[4] \
--executor-memory 1G \
--driver-memory 1G \
--conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\" \
--packages com.databricks:spark-csv_2.11:1.5.0 \
--packages com.amazonaws:aws-java-sdk-pom:1.10.34 \
--packages org.apache.hadoop:hadoop-aws:2.7.3 \
\$1

EOF



chmod +x $HOME/scripts/localsparksubmit.sh

# Check to see if JDK is installed
javac -version 2> /dev/null
if [ ! $? -eq 0 ]
then
    # Install JDK
    if [[ $(uname -s) = "Darwin" ]]
    then
        echo "Downloading JDK..."
        brew install Caskroom/cask/java
    elif [[ $(uname -s) = "Linux" ]]
    then
        echo "Downloading JDK..."
        sudo add-apt-repository ppa:webupd8team/java
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
        sudo apt-get update
        sudo apt-get install oracle-java8-installer
    fi
fi

SUCCESSFUL_SPARK_INSTALL=0
SPARK_INSTALL_TRY=0

if [[ $(uname -s) = "Darwin" ]]
then
    echo -e "\n\tDetected Mac OS X as the Operating System\n"

    while [ $SUCCESSFUL_SPARK_INSTALL -eq 0 ]
    do
        curl $SPARK_URL > $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME
        # Check MD5 Hash
		# Unzip
		tar -xzf $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME -C $SPARK_INSTALL_LOCATION
		# Remove the compressed file
		#rm $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME
		# Install py4j
		pip install py4j
		SUCCESSFUL_SPARK_INSTALL=1

    done
elif [[ $(uname -s) = "Linux" ]]
then
    echo -e "\n\tDetected Linux as the Operating System\n"

    while [ $SUCCESSFUL_SPARK_INSTALL -eq 0 ]
    do
        #curl $SPARK_URL > $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME
        # Check MD5 Hash
		# Unzip
		tar -xzf $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME -C $SPARK_INSTALL_LOCATION
		# Remove the compressed file
		#rm $SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME
		# Install py4j
		pip install py4j
		SUCCESSFUL_SPARK_INSTALL=1

    done
else
    echo "Unable to detect Operating System"
    exit 1
fi

# Remove extension from spark folder name
SPARK_FOLDER_NAME=$(echo $SPARK_FOLDER_NAME | sed -e "s/.tgz$//")



cat > $SHELL_PROFILE << EOF
# Spark variables
export SPARK_HOME=\"$SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME\"
export PYTHONPATH=\"$SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME/python/:$PYTHONPATH\"

# Spark 2
export PYSPARK_DRIVER_PYTHON=ipython
export PATH=\$SPARK_HOME/bin:\$PATH
alias pyspark=\"$SPARK_INSTALL_LOCATION/$SPARK_FOLDER_NAME/bin/pyspark \
    --conf spark.sql.warehouse.dir='file:///tmp/spark-warehouse' \
    --packages com.databricks:spark-csv_2.11:1.5.0 \
    --packages com.amazonaws:aws-java-sdk-pom:1.10.34 \
    --packages org.apache.hadoop:hadoop-aws:2.7.3\"

EOF



source $SHELL_PROFILE

echo "INSTALL COMPLETE"
echo "Please refer to Step 4 at https://github.com/zipfian/spark-install for testing your installation"