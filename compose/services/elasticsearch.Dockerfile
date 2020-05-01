FROM docker.elastic.co/elasticsearch/elasticsearch:5.6.3
RUN bin/elasticsearch-plugin install ingest-attachment