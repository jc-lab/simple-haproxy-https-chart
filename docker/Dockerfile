FROM haproxytech/haproxy-alpine

RUN apk update && \
    apk add bash netcat-openbsd

COPY ["start-watch.sh", "start-haproxy.sh", "/opt/"]

RUN chmod +x /opt/start-*.sh


