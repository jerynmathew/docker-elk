#!/bin/bash

ES_HEAP_SIZE=${ES_HEAP_SIZE:-16g}

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
service nginx restart
supervisorctl stop all && service supervisor restart
