import logging
import time
import traceback
import yaml
import sys
from datetime import datetime, timedelta, date
from functools import reduce
from pyspark.sql import DataFrame
from pyspark.sql import SparkSession
from pyspark.sql import Window
from pyspark.sql.functions import *
from pyspark.sql.types import StringType, MapType
from pyspark import SparkContext
from pyspark.sql import SQLContext
from pyspark.sql.types import *
from pyspark.sql.functions import *

from pyspark.sql.functions import col,from_json

def main():

    spark = SparkSession.builder.appName('IPs').getOrCreate()
    # df1 = spark.sparkContext.parallelize([[1,2,3], [2,3,4]]).toDF(("a", "b", "c"))
    # df1.show()
    # df1.write.mode('overwrite').partitionBy("a","b").parquet("/tmp/output/")
    df1_read = spark.read.parquet("/tmp/output/a=1/")

    df1_read.show()


main()