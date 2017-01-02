FROM nodesource/jessie

MAINTAINER Jason Kennemer <jason@kennemers.com>

##################################################
# Set environment variables                      #
##################################################

ENV DEBIAN_FRONTEND noninteractive
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV TERM xterm

##################################################
# Install tools                                  #
##################################################

RUN apt-get -y update && apt-get install -y --no-install-recommends \
  avahi-daemon \
  avahi-discover \
  build-essential \
  libavahi-compat-libdnssd-dev \
  libnss-mdns \
  net-tools \
  nano \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN alias ll='ls -alG'

##################################################
# Install homebridge                             #
##################################################

RUN npm install -g --unsafe-perm \
        homebridge \
        hap-nodejs \
        node-gyp && \
    cd /usr/local/lib/node_modules/homebridge/ && \
    npm install --unsafe-perm bignum && \
    cd /usr/local/lib/node_modules/hap-nodejs/node_modules/mdns && \
    node-gyp BUILDTYPE=Release rebuild

##################################################
# Add Homebridge User                            #
##################################################

USER root
RUN mkdir -p /var/run/dbus
RUN mkdir -p /var/homebridge && chmod 777 -R /var/homebridge

RUN groupadd -r homebridge -g 433 && \
useradd -u 431 -r -g homebridge -d /var/homebridge -s /sbin/nologin -c "Docker image user" homebridge && \
chown -R homebridge:homebridge /var/homebridge

##################################################
# Start                                          #
##################################################

USER homebridge
RUN mkdir -p /var/homebridge/.homebridge
VOLUME /var/homebridge/.homebridge
WORKDIR /var/homebridge/.homebridge

ADD image/run.sh /var/homebridge/run.sh

EXPOSE 5353 51826
CMD ["/var/homebridge/run.sh"]
