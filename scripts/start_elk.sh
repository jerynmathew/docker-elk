#! /bin/bash

CONTAINER="elk"

if [ ! -d "/opt/elk" ]; then
	mkdir /opt/elk
	mkdir -p /opt/elk/es /opt/elk/ls

	echo "Cloning docker-elk repo temporarily..."
	git clone https://github.com/jerynmathew/docker-elk.git /opt/docker_elk
	cp /opt/docker_elk/conf/elasticsearch.yml /opt/elk/es/.
	cp /opt/docker_elk/conf/logstash.conf /opt/elk/ls/.
	rm -rf /opt/docker_elk
	echo "Cleaning up..."
fi

RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)

if [ $? -eq 1 ]; then
  # Container does not exists. Create and run it.
  docker run -d -p 3333:3333/udp -p 3334:3334 -p 9200:9200 -p 9201:9201 -p 9300:9300 -p 80:80 -p 82:82 --name elk -v /opt/elk:/data jerynmathew/docker-elk 2> /dev/null
fi

if [ $RUNNING == "false" ]; then
	# Container create but not started
	docker start elk 2> /dev/null
fi

STARTED=$(docker inspect --format="{{ .State.StartedAt }}" $CONTAINER)
NETWORK=$(docker inspect --format="{{ .NetworkSettings.IPAddress }}" $CONTAINER)
SERVICES=$(docker port $CONTAINER 2> /dev/null)

echo ""
echo "ELK Docker started..."
echo ""
echo "Started At: $STARTED"
echo "IP Address: $NETWORK"
echo "Services Running as:"
echo $SERVICES
echo ""
echo "Kibana 3 running on :80"
echo "Kibana 4 running on :82"
echo "ES running on :9200"
echo "ES query running on :9201"
echo "Logstash (UDP) listening on :3333"
echo "Logstash listening on :3334"
