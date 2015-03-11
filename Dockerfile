FROM ubuntu:trusty
MAINTAINER Jeryn Mathew <jerynmathew@gmail.com>


# Deps: Java, Curl, Supervisor
RUN apt-get update && \
    apt-get install -y curl wget openjdk-7-jre-headless supervisor nginx nano && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Elasticsearch, logstash, kibana
RUN cd /tmp && \
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.4.tar.gz && \
    tar -xvzf ./elasticsearch-1.4.4.tar.gz && \
    mv ./elasticsearch-1.4.4 /opt/elasticsearch && \
    rm ./elasticsearch-1.4.4.tar.gz && \
    wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz && \
    tar -xvzf ./logstash-1.4.2.tar.gz && \
    mv ./logstash-1.4.2 /opt/logstash && \
    rm ./logstash-1.4.2.tar.gz && \
    wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.2.tar.gz && \
    tar -xvzf ./kibana-3.1.2.tar.gz && \
    mv ./kibana-3.1.2 /opt/kibana && \
    rm ./kibana-3.1.2.tar.gz && \
    wget https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz && \
    tar -xvzf ./kibana-4.0.1-linux-x64.tar.gz && \
    mv ./kibana-4.0.1-linux-x64 /opt/kibana4 && \
    rm ./kibana-4.0.1-linux-x64.tar.gz


# Define mountable directories.
VOLUME ["/data"]


# Copy conf across
ADD conf/elk.conf /etc/supervisor/conf.d/elk.conf
ADD conf/elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
ADD conf/logstash.conf /data/ls/logstash.conf
ADD conf/kibana-config.js /opt/kibana/config.js
ADD conf/kibana.yml /opt/kibana4/config/kibana.yml
ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/kibana-nginx.conf /etc/nginx/conf.d/kibana.conf
ADD conf/es-nginx.conf /etc/nginx/conf.d/es.conf
ADD run.sh /run.sh
RUN chmod +x /*.sh


# ENV
# ENV ES_HEAP_SIZE 16g
ENV ES_MIN_MEM 18g
ENV ES_MAX_MEM 18g

# ES Plugins
#RUN /opt/elasticsearch/bin/plugin -i elasticsearch/marvel/latest && \
RUN /opt/elasticsearch/bin/plugin -i lukas-vlcek/bigdesk/2.5.0 && \
    /opt/elasticsearch/bin/plugin -i royrusso/elasticsearch-HQ


# Install contrib plugins
RUN /opt/logstash/bin/plugin install contrib


# Define default command.
CMD ["/run.sh"]

# Expose ports.
#   - 9200: HTTP
#   - 9201: HTTP Ngnix reverse proxy (Gzip stream for APIs)
#   - 9300: transport
#   - 80: Kibana
#   - 82: Kibana 4 (Beta 2)
EXPOSE 3333/udp
EXPOSE 3334
EXPOSE 9200
EXPOSE 9201
EXPOSE 9300
EXPOSE 80
EXPOSE 82
