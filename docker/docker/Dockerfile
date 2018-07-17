FROM phusion/baseimage:0.9.19

EXPOSE 80

ENV HOME /root
ONBUILD RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]

RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

### see also brutasse/graphite-api

VOLUME /srv/graphite

RUN apt-get update && apt-get upgrade -y

# Dependencies
RUN apt-get install -y libcairo2-dev nginx memcached python-dev libffi-dev
RUN rm -f /etc/nginx/sites-enabled/default

# add our default config and allow subsequent builds to add a different one
ADD graphite-api.yaml /etc/graphite-api.yaml
RUN chmod 0644 /etc/graphite-api.yaml
ONBUILD ADD graphite-api.yaml /etc/graphite-api.yaml
ONBUILD RUN chmod 0644 /etc/graphite-api.yaml

# Nginx service
ADD nginx.conf /etc/nginx/nginx.conf
ADD graphite_nginx.conf /etc/nginx/sites-available/graphite.conf
RUN ln -s /etc/nginx/sites-available/graphite.conf /etc/nginx/sites-enabled/
RUN mkdir /etc/service/nginx -p
ADD nginx.sh /etc/service/nginx/run

# Add docker host IP in hosts file on startup
ADD dockerhost.sh /etc/my_init.d/dockerhost.sh
RUN chmod +x /etc/my_init.d/dockerhost.sh

# Memcached service
RUN mkdir /etc/service/memcached -p
ADD memcached.sh /etc/service/memcached/run

RUN curl https://bootstrap.pypa.io/get-pip.py | python

# Update python build tools
RUN pip install -U pip -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
RUN pip install -U setuptools wheel -i http://pypi.douban.com/simple --trusted-host pypi.douban.com

# Install InfluxGraph, dependencies and tools for running webapp
RUN pip install -U gunicorn graphite-api influxgraph -i http://pypi.douban.com/simple --trusted-host pypi.douban.com

# init scripts
RUN mkdir /etc/service/graphite-api -p
ADD graphite-api.sh /etc/service/graphite-api/run
RUN chmod +x /etc/service/graphite-api/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /tmp/* /var/tmp/*
