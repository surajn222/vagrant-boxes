from kafka import KafkaConsumer
import sys
bootstrap_servers = ['localhost:9093']
topicName = 'netrics-env-2'
consumer = KafkaConsumer(topicName, group_id = 'group3',bootstrap_servers = bootstrap_servers,
        auto_offset_reset = 'earliest')
try:
        for message in consumer:
                    print ("%s:%d:%d: key=%s value=%s" % (message.topic, message.partition,message.offset, message.key,message.value))
except KeyboardInterrupt:
        sys.exit()
