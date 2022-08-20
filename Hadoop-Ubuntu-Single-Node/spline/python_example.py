from pyspark import SparkContext
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
import pyspark.sql.functions as sf
import logging
sc = SparkContext()

spark = SparkSession \
    .builder \
    .master("local[1]")\
    .appName("SparkByExamples.com")\
    .getOrCreate()

empsDF = spark.read \
    .option("header", "true") \
    .option("inferschema", "true") \
    .csv("file:///vagrant/spline/emp_data.csv")
#log.warn('empsDF created')
empsDF = empsDF.withColumnRenamed('name', 'Name')
empsDF = empsDF.withColumn('name_dup', col('Name'))
# empsDF1.show()
empsDF.show()


empsDF.write.csv( 'results_5.csv', header=True, mode="Overwrite")
import sys
sys.exit()

deptsDF = spark.read \
    .option("header", "true") \
    .option("inferschema", "true") \
    .csv("file:///vagrant/spline/dept.csv")
#log.warn('deptsDF created')

deptsDF.write.csv( 'results_4.csv', header=True)
# resultsDF = empsDF1.join(deptsDF, empsDF1.dept_id==deptsDF.dept_id1, "left_outer")

# xdf = empsDF.groupBy('manager_id')
# ydf = xdf.agg(sf.sum('salary').alias('total_salary'))
# ydf.show()
# #log.warn('dfs joined')
# ydf.coalesce(1).write.csv( 'agg.csv', header=True)
