#! /bin/bash

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

if [ $(docker inspect elk | python -c "import json, sys; res = json.loads(sys.stdin.read()); print 0 if len(res)>0 and res[0]['State']['Running'] else -1; ") -ne 0 ]; then
        docker run -d -p 3333:3333/udp -p 3334:3334 -p 9200:9200 -p 9201:9201 -p 80:80 -p 82:82 --name elk -v /opt/elk:/data jerynmathew/docker-elk

        echo .
        echo "ELK Docker started..."
        echo .
        echo "Kibana 3 running on :80"
        echo "Kibana 4 running on :82"
        echo "ES running on :9200"
        echo "ES query running on :9201"
        echo "Logstash (UDP) listening on :3333"
        echo "Logstash listening on :3334"
fi
