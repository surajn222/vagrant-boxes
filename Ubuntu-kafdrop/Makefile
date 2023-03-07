.PHONY: run-kafka-vagrant
run-kafka-vagrant:
	-vagrant up
	-echo "Run vagrant ssh with password vagrant"

.PHONY: run-kafka-docker
run-kafka-docker:
	-echo "Works on Mac and not on Windows"
	-cd docker && docker-compose up -d
	-echo "Kafka will be available in 5 minutes on port 9092"
	-echo "Messages in resource/messages will be updated in kafka after you run the below command"
	-echo "Please run this command after kafka is up: source ../venv/bin/activate && cd Scripts && python producer1.py"

.PHONY: stop-docker-kafka
stop-docker-kafka:
	-echo "Kafka will be terminated"
	-cd docker && docker-compose down

