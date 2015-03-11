#!/bin/bash

# ES_HEAP_SIZE=${ES_HEAP_SIZE:-16g}

echo "========================================================================"
echo "You can now connect to this Elasticsearch Server using:"
echo ""
echo "    http://localhost:9201/_cat/health?v"
echo ""
echo "========================================================================"
echo "You can now connect to this Kibana on:"
echo ""
echo "    http://localhost:80"
echo ""
echo "========================================================================"
echo "You can now connect to this Kibana4 (EXPERIMENTAL) on:"
echo ""
echo "    http://localhost:82"
echo ""
echo "========================================================================"
service nginx restart
supervisorctl stop all && supervisorctl start all
