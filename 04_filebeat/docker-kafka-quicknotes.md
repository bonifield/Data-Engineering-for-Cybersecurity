# Quick Kafka Setup Using Docker

pull image (substitute latest version numbers)

	docker pull apache/kafka-native:X.Y.Z

launch container on host network

	docker run --network=host -p 9092:9092 apache/kafka:X.Y.Z

in another terminal, connect to the container

	docker exec -it `docker ps | grep kafka | cut -d ' ' -f 1` bash

inside the container, create the `filebeat` topic

	cd /opt/kafka/bin && ./kafka-topics.sh --create --topic filebeat --bootstrap-server localhost:9092

then connect Filebeat and Logstash using the rest of the steps in this chapter
