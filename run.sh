#!/bin/bash

ES_HEAP_SIZE=${ES_HEAP_SIZE:-16g}
LOGSTASH_ROOT=/opt/logstash

echo "========================================================================"
echo "You can now connect to this Elasticsearch Server using:"
echo ""
echo "    curl localhost:9200"
echo ""
echo "========================================================================"
echo "You can now connect to this Kibana on:"
echo ""
echo "    http://localhost:9292"
echo ""
echo "========================================================================"
service supervisor restart
