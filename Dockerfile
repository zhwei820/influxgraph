FROM phusion/baseimage:0.9.19

EXPOSE 80

ENV HOME /root
ONBUILD RUN /etc/my_init.d/00_regen_ssh_host_keys.sh
CMD ["/sbin/my_init"]



### see also brutasse/graphite-api

VOLUME /srv/graphite

RUN apt-get update && apt-get upgrade -y

# Dependencies
RUN apt-get install -y python-virtualenv libcairo2-dev nginx memcached python-dev libffi-dev
RUN rm -f /etc/nginx/sites-enabled/default

# add our default config and allow subsequent builds to add a different one
ADD docker/graphite-api.yaml /etc/graphite-api.yaml
RUN chmod 0644 /etc/graphite-api.yaml
ONBUILD ADD docker/graphite-api.yaml /etc/graphite-api.yaml
ONBUILD RUN chmod 0644 /etc/graphite-api.yaml

# Nginx service
ADD docker/nginx.conf /etc/nginx/nginx.conf
ADD docker/graphite_nginx.conf /etc/nginx/sites-available/graphite.conf
RUN ln -s /etc/nginx/sites-available/graphite.conf /etc/nginx/sites-enabled/
RUN mkdir /etc/service/nginx
ADD docker/nginx.sh /etc/service/nginx/run

# Add docker host IP in hosts file on startup
ADD docker/dockerhost.sh /etc/my_init.d/dockerhost.sh
RUN chmod +x /etc/my_init.d/dockerhost.sh

# Memcached service
RUN mkdir /etc/service/memcached
ADD docker/memcached.sh /etc/service/memcached/run

# Install in virtualenv
RUN virtualenv /srv/graphite-env

# Activate virtualenv and add in path
ENV VIRTUAL_ENV=/srv/graphite-env
ENV PATH=/srv/graphite-env/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ONBUILD ENV VIRTUAL_ENV=/srv/graphite-env
ONBUILD ENV PATH=/srv/graphite-env/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Update python build tools
RUN pip install -U pip
RUN pip install -U setuptools wheel


# Install InfluxGraph, dependencies and tools for running webapp
RUN pip install -U gunicorn graphite-api 

ADD ./ /root/influxgraph
RUN pip install -e /root/influxgraph

# init scripts
RUN mkdir /etc/service/graphite-api
ADD docker/graphite-api.sh /etc/service/graphite-api/run
RUN chmod +x /etc/service/graphite-api/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
