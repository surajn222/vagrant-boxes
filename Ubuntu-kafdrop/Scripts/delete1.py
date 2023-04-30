# Import KafkaProducer from Kafka library
from kafka import KafkaProducer
from kafka.admin import KafkaAdminClient, NewTopic
from kafka import KafkaProducer
import sys
# Define server with port

admin_client = KafkaAdminClient(bootstrap_servers='localhost:9092')

topic = NewTopic(
    name="topic3",
    num_partitions=1,
    replication_factor=1,
)

admin_client.delete_topics([topic.name])


