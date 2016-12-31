FROM phusion/baseimage
MAINTAINER Alex Salt <alex.salt@e96.ru>

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    ca-certificates bind9-host \
    htop apt-transport-https unzip nano \
    collectd dnsutils iproute

# do locales
RUN locale-gen ru_RU.UTF-8
COPY config/locale /etc/default/locale

# envplate
RUN curl -Ls https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux -o /usr/local/bin/ep && \
    chmod +x /usr/local/bin/ep

# consul
RUN curl -Ls https://releases.hashicorp.com/consul/0.7.2/consul_0.7.2_linux_amd64.zip -o /tmp/consul.zip && \
    unzip /tmp/consul.zip -d /usr/local/bin/ && rm /tmp/consul.zip && \
    mkdir -p /etc/consul/conf.d

ADD config/consul.json /etc/consul/consul.json

# install init scripts
ADD init.d/ /etc/my_init.d/

# install services
ADD services/consul.sh /etc/service/consul/run

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 8600 8600/udp

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
