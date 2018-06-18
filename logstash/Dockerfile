FROM docker.elastic.co/logstash/logstash:6.2.3
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
COPY pipeline/logstash.conf /usr/share/logstash/pipeline/
COPY config/logstash.yml /usr/share/logstash/config/
ENTRYPOINT /bin/bash
