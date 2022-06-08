#!/bin/bash

FRONTEND_TLS_PATH=/secret/frontend-tls
FRONTEND_TLS_OUT=/var/run/haproxy/frontend-tls.pem

log() {
  date_time="$(date +%Y-%m-%d\ %H:%M:%S)"
  if [ -z $2 ]; then
    echo "${date_time} nginx: $1"
  else
    (>&2 echo "${date_time} nginx: ERROR: $1")
  fi
}

update_tls() {
	cat ${FRONTEND_TLS_PATH}/tls.key ${FRONTEND_TLS_PATH}/tls.crt >> ${FRONTEND_TLS_OUT}
}

find_pid() {
	ps -a | grep ' haproxy ' | grep -v grep | sed -E 's/^\s*//g' | cut -d' ' -f1
}

update_tls

#until [ -f /var/run/haproxy/haproxy.pid ]; do
until find_pid; do
	log "waiting for ready haproxy"
	sleep 1
done

#haproxy_pid=$(cat /var/run/haproxy/haproxy.pid)
haproxy_pid=$(find_pid)

inotifywait -r -q -e modify,move,create,delete --format '%w %e %T' -m --timefmt '%H%M%S' \
${FRONTEND_TLS_PATH} | while read file event tm; do
	current=$(date +'%H%M%S')
	delta=`expr $current - $tm`
	log "at ${tm} config file ${file} update detected (${event})"
	if [ $delta -lt 2 -a $delta -gt -2 ] ; then
		sleep 1
		update_tls
		kill -HUP ${haproxy_pid}
	fi
done


