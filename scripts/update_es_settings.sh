#! /bin/bash

curl -XPUT 'http://localhost:9200/_template/template_logstash/' -d @logstash-template.json