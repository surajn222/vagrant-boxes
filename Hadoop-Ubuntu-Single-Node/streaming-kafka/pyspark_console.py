# Need to import to use date time
from datetime import datetime, date

# need to import for working with pandas
#import pandas as pd

# need to import to use pyspark
from pyspark.sql import Row

# need to import for session creation
from pyspark.sql import SparkSession

# creating the session
spark = SparkSession.builder.master("local").getOrCreate()

# schema creation by passing list
df = spark.createDataFrame([
        Row(a=1, b=4., c='GFG1', d=date(2000, 8, 1),
                    e=datetime(2000, 8, 1, 12, 0)),

            Row(a=2, b=8., c='GFG2', d=date(2000, 6, 2),
                        e=datetime(2000, 6, 2, 12, 0)),

                Row(a=4, b=5., c='GFG3', d=date(2000, 5, 3),
                            e=datetime(2000, 5, 3, 12, 0))
                ])

# show table
df.show()

# show schema
df.printSchema()

from pyspark.sql import functions as F

df = spark.readStream.format("kafka").option("kafka.bootstrap.servers", "localhost:9092").option("subscribe", "topic_1").option("startingOffsets", "earliest").load().select(F.col("value").cast("string"))


df.writeStream.format("kafka").option("kafka.bootstrap.servers", "localhost:9092").option("checkpointLocation","hdfs:///tmp").option("topic", "topic_2").start().awaitTermination()

import sys
sys.exit()

df.writeStream.outputMode("update").format("console").start().awaitTermination()

import sys
sys.exit()








df = spark.readStream.format("kafka").option("kafka.bootstrap.servers", "localhost:9093").option("subscribe", "topic_1").option("startingOffsets", "earliest").load()
df.selectExpr("key", "value")
print(type(df))
#print(type(qry))


qry = df.writeStream.format("console").option("truncate","false").start()
qry.awaitTermination()

sys.exit()

df = spark.readStream.format("kafka").option("kafka.bootstrap.servers", "localhost:9092").option("subscribe", "topic_1").option("startingOffsets", "earliest").load()

#df.show()
print("Printing to console")

query = df.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)").writeStream.format("console").option("truncate","false").start()
query.awaitTermination()

sys.exit()

ds = df.selectExpr("CAST(value AS STRING)")
print(type(df))
print(type(ds))

rawQuery = ds.writeStream.queryName("qraw").format("memory").start()
raw = spark.sql("select * from qraw")
raw.show()

sys.exit()


df.writeStream.format("console").start()
df.show()
sys.exit()

query = df.limit(5).writeStream.foreachBatch(apply_pivot).start()

time.sleep(50)
spark.sql("select * from stream").show(20, False)
query.stop()

sys.exit()

readDF = df.selectExpr("CAST(key AS STRING)","CAST(value AS STRING)")

df.writeStream.format("console").start()
df.show()

sys.exit()

ds = df.selectExpr("CAST(value AS STRING)")
print(type(df))
print(type(ds))

rawQuery = ds.writeStream.queryName("qraw").format("memory").start()
raw = spark.sql("select * from qraw")
raw.show()
print("Complete")
