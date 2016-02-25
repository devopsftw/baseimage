FROM phusion/baseimage
MAINTAINER Alex Salt <alex.salt@e96.ru>

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    ca-certificates bind9-host \
    htop apt-transport-https unzip nano \
    collectd

# do locales
RUN locale-gen ru_RU.UTF-8
COPY config/locale /etc/default/locale

# envplate
RUN curl -L https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux -o /usr/local/bin/ep && chmod +x /usr/local/bin/ep

# consul
RUN curl https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip > /tmp/consul.zip
RUN unzip /tmp/consul.zip
RUN mv consul /usr/local/bin/
RUN mkdir -p /etc/consul/conf.d
ADD config/consul.json /etc/consul/consul.json

# consul template
RUN curl -L -s https://github.com/hashicorp/consul-template/releases/download/v0.10.0/consul-template_0.10.0_linux_amd64.tar.gz | \
    tar -C /usr/local/bin --strip-components 1 -zxf -

# Setup Consul Template Files
RUN mkdir /etc/consul-templates

# collectd
RUN mkdir /etc/collectd/conf.d
RUN touch /etc/collectd/types.db
ADD config/collectd/collectd.conf /etc/collectd/

# install init scripts
ADD init.d/ /etc/my_init.d/

# install services
ADD services/consul.sh /etc/service/consul/run
ADD services/collectd.sh /etc/service/collectd/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
