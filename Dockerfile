FROM ubuntu:trusty
MAINTAINER Jeryn Mathew <jerynmathew@gmail.com>


# Deps: Java, Curl, Supervisor
RUN apt-get update && \
    apt-get install -y curl wget openjdk-7-jre-headless supervisor apache2-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


# Elasticsearch
RUN cd /tmp && \
    wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.4.tar.gz && \
    tar -xvzf ./elasticsearch-1.3.4.tar.gz && \
    mv ./elasticsearch-1.3.4 /opt/elasticsearch && \
    rm ./elasticsearch-1.3.4.tar.gz


# Logstash
RUN cd /tmp && \
    wget https://download.elasticsearch.org/logstash/logstash/logstash-1.4.2.tar.gz && \
    tar -xvzf ./logstash-1.4.2.tar.gz && \
    mv ./logstash-1.4.2.tar.gz /opt/logstash && \
    rm ./logstash-1.4.2.tar.gz


# Define mountable directories.
VOLUME ["/data"]


# Copy conf across
ADD conf/elk.conf /etc/supervisor/conf.d/elk.conf
ADD conf/elasticsearch.yml /data/es/elasticsearch.yml
ADD conf/logstash.conf /data/ls/logstash.conf
ADD run.sh /run.sh
RUN chmod +x /*.sh


# ENV
ENV ES_HEAP_SIZE 4g


# ES Plugins
RUN /opt/elasticsearch/bin/plugin -i elasticsearch/marvel/latest && \
    /opt/elasticsearch/bin/plugin -i lukas-vlcek/bigdesk/2.5.0 && \
    /opt/elasticsearch/bin/plugin -i royrusso/elasticsearch-HQ


# Install contrib plugins
RUN /opt/logstash/bin/plugin install contrib


# Define default command.
CMD ["/run.sh"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
#   - 9292: Kibana
EXPOSE 3333/udp
EXPOSE 3334
EXPOSE 9200
EXPOSE 9300
EXPOSE 9292
