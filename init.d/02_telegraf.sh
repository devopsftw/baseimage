#!/bin/sh

if [ "$USE_TELEGRAF" != 1 ]; then
    touch /etc/service/telegraf/down
    exit 0
fi
