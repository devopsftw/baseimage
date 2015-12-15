#!/bin/sh

if [ !$CONSUL_HOST ]; then
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

DC=$(echo $PAIR | cut -f1 -d " ")
DOMAIN=$(echo $PAIR | cut -f2 -d " ")
echo $DC > /etc/container_environment/CONSUL_DC
echo $DOMAIN > /etc/container_environment/CONSUL_DOMAIN
