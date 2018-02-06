#!/bin/sh

exec /usr/local/bin/consul agent \
    -retry-join $CONSUL_HOST \
    -bind "{{ $CONSUL_BIND_EXPR }}" \
    -datacenter $CONSUL_DC \
    -domain $CONSUL_DOMAIN \
    -config-file /etc/consul/consul.json \
    -config-dir /etc/consul/conf.d
