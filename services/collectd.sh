#!/bin/sh

if [ "$START_COLLECTD" != "1" ]; then
    sv down collectd
    exit 0
fi

exec collectd -f -C /etc/collectd/collectd.conf
