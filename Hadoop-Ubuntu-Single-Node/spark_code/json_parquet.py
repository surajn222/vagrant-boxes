from pyspark.sql import DataFrame
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import StringType, MapType
from pyspark import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql.types import *
from pyspark.sql.functions import *

import argparse
import math

def main():
    """
    To run this spark code:
    $SPARK_HOME/bin/spark-submit --master yarn --conf spark.sql.warehouse.dir=\"file:///tmp/spark-warehouse\"  /vagrant/spark_code/json_parquet.py --input "file:///vagrant/example.json" --output "/
tmp/output/" --max_files 3

    :return:
    """
    parser = argparse.ArgumentParser('App')


    parser.add_argument('--input', help='Input', required=True)
    parser.add_argument('--output', help='Output', required=True)
    parser.add_argument('--max_files', help='Max files required', required=True)

    args = parser.parse_args()

    print(args.input)
    print(args.output)
    print(args.max_files)

    spark = SparkSession.builder.appName('Jso and parqut read').getOrCreate()

    sql_context = SQLContext(spark)

    # Read from s3
    df = sql_context.read.option("multiline", "true").json(args.input)
    df.printSchema()

    count_records = df.count()
    print(count_records)
    records_per_file = int(count_records)/int(args.max_files)
    df.show()

    # Write to file
    df.write.option("maxRecordsPerFile", math.ceil(records_per_file)).mode('overwrite').parquet(args.output)

main()