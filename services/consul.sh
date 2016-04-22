#!/bin/sh

_term() {
    kill -INT $pid
    wait $pid
}
# trap term for gracefully stopping consul
trap _term TERM

/usr/local/bin/consul agent \
    -join $CONSUL_HOST \
    -dc $CONSUL_DC \
    -domain $CONSUL_DOMAIN \
    -config-file /etc/consul/consul.json \
    -config-dir /etc/consul/conf.d &
pid=$!
wait $pid
