# Import KafkaProducer from Kafka library
from kafka import KafkaProducer
import sys
# Define server with port
bootstrap_servers = ['localhost:9092']

#Read all messages from the resources folder, convert into dictionary
with open("../resources/messages") as file:
	content = file.read()

print(content.split("\n"))
messages_dict = {}

list_content = content.split("\n")
print(list_content)
for content in list_content:
	if content:
		topic = content.split(":")[0].strip()
		message = content.split(":")[1].strip()
		producer = KafkaProducer(bootstrap_servers=bootstrap_servers)
		print("Sending " + str(message) +  " to " + str(topic))
		producer.send(topic, str.encode(message))
		print("Sending " + str(message) + " to " + str(topic))

producer.flush()

