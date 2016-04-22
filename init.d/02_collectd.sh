#!/bin/sh

if [ "$USE_COLLECTD" != 1 ]; then
    touch /etc/service/collectd/down
    exit 0
fi

ep /etc/collectd/collectd.conf
ep /etc/collectd/collectd.conf.d/*
