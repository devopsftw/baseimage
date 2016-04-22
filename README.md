WHAT IS IT?
===========
Base Image for application with consul agent

CONSUL
------
Consul host resolved either from `CONSUL_HOST` env var or default gateway
Put your .json configuration files to `/etc/consul/conf.d/`
set `USE_CONSUL=0` if you dont want it

COLLECTD
--------
set `USE_COLLECTD=1`
set `MONITORING_HOST` to grafana host
Put your collectd config to /etc/collectd/collectd.conf.d/
