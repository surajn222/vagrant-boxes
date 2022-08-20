import argparse
import io
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

    spark = SparkSession.builder.appName('Northstar Pricing Active IPs').getOrCreate()
    # hadoopConf = spark.sparkContext._jsc.hadoopConfiguration()
    # hadoopConf.set("fs.s3.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
    # hadoopConf.set("fs.s3a.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem")
    sql_context = SQLContext(spark)

    #Read from s3 here
    df = sql_context.read.parquet("file:///vagrant/spark_code/.snappy.parquet")

    df = df.toDF(*[c.upper() for c in df.columns])

    list_columns_df = KazDF.columns
    print(list_columns_df)

    import pandas
    df = pandas.read_csv('table_columns.csv')
    df = df[(df['TABLE_NAME'] == '')]
    print(df)
    list_columns_required = df['COLUMN_NAME'].tolist()
    print(list_columns_required)

    print("Null columns: ")
    null_columns_list = [x for x in list_columns_required if x not in list_columns_df]
    print(null_columns_list)

    for column in null_columns_list:
        df = df.withColumn(column, lit(None).cast(NullType()))

    df = df.select(list_columns_required)
    df.show()

    print("KazDF write to S3")

    sys.exit()

    json_content1 = KazDF.first()['UserAgentParsed']

    json_list = []
    json_list.append(json_content1)

    json_schema = spark.read.json(spark.sparkContext.parallelize(json_list)).schema
    #print(json_schema)

    KazJsonDF = KazDF.withColumn("json", from_json(col("UserAgentParsed"), json_schema))

    # Flatten array of structs and structs
    def flatten(df):
        # compute Complex Fields (Lists and Structs) in Schema
        complex_fields = dict([(field.name, field.dataType)
                               for field in df.schema.fields
                               if type(field.dataType) == ArrayType or type(field.dataType) == StructType])
        while len(complex_fields) != 0:
            col_name = list(complex_fields.keys())[0]
            print("Processing :" + col_name + " Type : " + str(type(complex_fields[col_name])))

            # if StructType then convert all sub element to columns.
            # i.e. flatten structs
            if (type(complex_fields[col_name]) == StructType):
                expanded = [col(col_name + '.' + k).alias(col_name + '_' + k) for k in
                            [n.name for n in complex_fields[col_name]]]
                df = df.select("*", *expanded).drop(col_name)

            # if ArrayType then add the Array Elements as Rows using the explode function
            # i.e. explode Arrays
            elif (type(complex_fields[col_name]) == ArrayType):
                df = df.withColumn(col_name, explode_outer(col_name))

            # recompute remaining Complex Fields in Schema
            complex_fields = dict([(field.name, field.dataType)
                                   for field in df.schema.fields
                                   if type(field.dataType) == ArrayType or type(field.dataType) == StructType])
        return df

    df = flatten(KazJsonDF)

    #Column names to upper case
    df = df.toDF(*[c.upper() for c in df.columns])

    list_columns_required = [""]

    df.printSchema()
    df.select(list_columns_required).show()

try:
    main()
except Exception as e:
    print(str(e))
    sys.exit(1)
        
        



    #KazDF.show(truncate=False)

    #KazDF = KazDF.withColumn("jsonSchema", schema_of_json(KazDF.select(col("UserAgentParsed")).first.getString(0)))



    #new_df = spark.read.json("""{"k": "v"}""")

    # json_content1 = "{'json_col1': 'hello', 'json_col2': 32}"
    # json_content2 = "{'json_col1': 'hello', 'json_col2': 'world'}"

    #print(KazDF.select("UserAgentParsed").collect()[0])

    #json_content = "This should be first row of the column"

    # json_list.append(json_content2)

    #df = spark.read.json(spark.sparkContext.parallelize(json_list))
    #df.show()
        #.select("json.*")
    #KazJsonDF.printSchema()
    #KazJsonDF.show(truncate=False)

    #json_schema = spark.read.json(KazDF.rdd.map(lambda row: row.UserAgentParsed)).schema

    #print(json_schema)

    #KazDF.show(truncate=False)
    #sys.exit()

    # import sys
    # sys.exit()
    #
    # from pyspark.sql.functions import explode
    #
    # KazJsonDF = KazDF.select(
    #     "UserAgentParsed",
    #     explode("UserAgentParsed").alias("UserAgentParsed_exploded")
    # ).select("UserAgentParsed", "UserAgentParsed_exploded.*")
    #
    # KazJsonDF.show()
    #
    #
    # import sys
    # sys.exit()
    #
    #
