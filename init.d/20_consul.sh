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
PAIR=$(curl -s http://$CONSUL_HOST:8500/v1/agent/self | python3 -c 'import json,sys;obj=json.load(sys.stdin);print ("%s %s" % (obj["Config"]["Datacenter"], obj["Config"]["Domain"]))' 2> /dev/null)
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

        # works nice with such nets as weave and other dns search providers
        DIG=$(dig $HOSTNAME +short)

        if [ $DIG ]; then
            ADVERTISE=$DIG
        echo "Detected adverising ip with dig: $DIG"
        else
            ADVERTISE=$(echo $NETS | head -n 1 | grep -E -o '[0-9a-f]+[\.:][0-9a-f\.:]+[^/]')
            echo "Dig failed, using first network ip: $ADVERTISE"
        fi
    fi

    echo "{\"advertise_addr\": \"$ADVERTISE\"}" > /etc/consul/conf.d/advertise.json
fi


ep /etc/consul/conf.d/*
ep /etc/consul/consul.json
