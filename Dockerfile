FROM phusion/baseimage:0.9.22
MAINTAINER Alex Salt <alex.salt@e96.ru>

ENV USE_TELEGRAF 0
ENV USE_CONSUL 1
ENV CONSUL_VERSION 1.0.1
ENV DEBIAN_FRONTEND noninteractive


RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    ca-certificates bind9-host iproute2 \
    htop apt-transport-https unzip nano \
    tzdata \
    && curl -sSL https://dl.influxdata.com/telegraf/releases/telegraf_1.5.1-1_amd64.deb -o /tmp/telegraf.deb \
    && dpkg -i /tmp/telegraf.deb \
    && curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > /tmp/consul.zip \
    && curl -sSL https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux -o /usr/local/bin/ep && chmod +x /usr/local/bin/ep \
    && unzip -d /usr/local/bin /tmp/consul.zip && rm /tmp/consul.zip \
    && mkdir -p /etc/consul/conf.d \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /etc/my_init.d/00_regen_ssh_host_keys.sh /etc/service/sshd \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# consul config
COPY config/consul.json /etc/consul/consul.json

# install init scripts
COPY init.d/ /etc/my_init.d/

# install services
COPY services/consul.sh /etc/service/consul/run
COPY services/telegraf.sh /etc/service/telegraf/run
