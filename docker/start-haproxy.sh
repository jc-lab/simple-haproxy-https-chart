#!/bin/sh

until [ -e /var/run/haproxy/frontend-tls.pem ]; do
	echo "Waiting for ready TLS"
	sleep 1
done

cat <<EOF | tee /tmp/haproxy.conf
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    stats socket /var/run/haproxy/admin.sock level admin expose-fd listeners

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

frontend fe_main
    mode http
    option forwardfor
    bind *:443 ssl crt /var/run/haproxy/frontend-tls.pem
    default_backend be_main

backend be_main
$(cat /opt/config/backends | sed -E 's/^/    /g')
EOF

haproxy -f /tmp/haproxy.conf

