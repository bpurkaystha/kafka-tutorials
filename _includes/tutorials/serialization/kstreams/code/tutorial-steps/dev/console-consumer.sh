docker exec -i schema-registry /usr/bin/kafka-protobuf-console-consumer --bootstrap-server broker:9092 --topic proto-movies --from-beginning