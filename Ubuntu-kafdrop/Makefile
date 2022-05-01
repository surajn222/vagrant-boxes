.PHONY: run-vagrant-kafka
run-vagrant-kafka:
	-vagrant up
	-echo "Run vagrant ssh with password vagrant"

.PHONY: run-docker-kafka
run-docker-kafka:
	-echo "Works on Mac and not on Windows"
	-cd docker && docker-compose up -d
	-echo "Kafka will be available in 5 minutes on port 9092"
	-echo "Messages in resource/messages will be updated in kafka after you run the below command"
	-echo "Please run this command after kafka is up: cd Scripts && python producer1.py"

.PHONY: stop-docker-kafka
stop-docker-kafka:
	-echo "Kafka will be terminated"
	-cd docker && docker-compose down

