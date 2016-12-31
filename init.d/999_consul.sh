#!/bin/sh

if [ -z $CONSUL_HOST ]; then
    echo "CONSUL_HOST not set, discovering from route"
    CONSUL_HOST=$(ip route show 0.0.0.0/0 | grep -Eo 'via \S+' | awk '{ print $2 }')
    if [ $CONSUL_HOST = "" ]; then
        echo "CONSUL_HOST discovery from ip route failed. Quitting.."
        exit 1
    fi
    echo $CONSUL_HOST > /etc/container_environment/CONSUL_HOST
fi

echo "Consul host is: $CONSUL_HOST"
PAIR=$(curl -s http://$CONSUL_HOST:8500/v1/agent/self | jq '.Config| .Datacenter + " " + .Domain')
if [ "$PAIR" = "" ]; then
    echo "Consul DC and domain discovery failed. Quitting.."
    exit 1
fi

CONSUL_DC=$(echo $PAIR | cut -f1 -d " ")
CONSUL_DOMAIN=$(echo $PAIR | cut -f2 -d " ")
echo $CONSUL_DC > /etc/container_environment/CONSUL_DC
echo $CONSUL_DOMAIN > /etc/container_environment/CONSUL_DOMAIN

NETS=$(ip a | grep "scope global")
NETS_COUNT=$(ip a | grep "scope global" | wc -l)
if [ -z $ADVERTISE ] && [ $NETS_COUNT -gt 1 ]; then
    if [ ! -z $ADVERTISE_INTERFACE ]; then
        ADDR=$(ip addr show dev ethwe | grep "inet " | grep -E -o '[0-9a-f]+[\.:][0-9a-f\.:]+[^/]')
        if [ $ADDR ]; then
            ADVERTISE=$ADDR
        fi
    fi
    if [ -z $ADVERTISE ]; then
        echo "No ADVERTISE or ADVERTISE_INTERFACE adress set, and more than 2 global scope networks available, trying to detect."
        ADVERTISE=127.0.0.1

        CONSUL_IP=$(getent hosts $CONSUL_HOST | awk '{print $1}')
        ADVERTISE=$(ip -o route get $CONSUL_IP | grep -oE 'src ([^\s]*)' | awk '{print $2}')

        echo "Using default route to consul interface: $ADVERTISE"
    fi

    echo "{\"advertise_addr\": \"$ADVERTISE\"}" > /etc/consul/conf.d/advertise.json
fi

ep /etc/consul/conf.d/*
ep /etc/consul/consul.json
