FROM phusion/baseimage:0.9.19
MAINTAINER Alex Salt <alex.salt@e96.ru>

ENV USE_CONSUL 1
ENV USE_COLLECTD 0
ENV CONSUL_VERSION 0.9.3
ENV DEBIAN_FRONTEND noninteractive

# remove ssh
RUN rm -rf /etc/my_init.d/00_regen_ssh_host_keys.sh /etc/service/sshd

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    ca-certificates bind9-host iproute2 \
    htop apt-transport-https unzip nano \
    tzdata \
    collectd libpython2.7 \

    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# do locales
RUN locale-gen ru_RU.UTF-8
COPY config/locale /etc/default/locale

# envplate
RUN curl -L https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux -o /usr/local/bin/ep && chmod +x /usr/local/bin/ep

# consul
RUN curl https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > /tmp/consul.zip && \
    unzip -d /usr/local/bin /tmp/consul.zip && \
    rm /tmp/consul.zip && \
    mkdir -p /etc/consul/conf.d
ADD config/consul.json /etc/consul/consul.json

# collectd
RUN mkdir /etc/collectd/conf.d
RUN touch /etc/collectd/types.db
ADD config/collectd/collectd.conf /etc/collectd/

# install init scripts
ADD init.d/ /etc/my_init.d/

# install services
ADD services/consul.sh /etc/service/consul/run
ADD services/collectd.sh /etc/service/collectd/run
