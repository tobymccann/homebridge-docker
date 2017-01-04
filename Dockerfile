FROM nodesource/jessie
MAINTAINER Jason Kennemer <jason@kennemers.com>

##################################################
# Set environment variables                      #
##################################################

ENV HOMEBRIDGE_USER="homebridge" \
    HOMEBRIDGE_GROUP="homebridge" \
    HOMEBRIDGE_HOME="/var/homebridge" \
    HOMEBRIDGE_LOG_DIR="/var/log/homebridge"

ENV HOMEBRIDGE_INSTALL_DIR="${HOMEBRIDGE_HOME}/.homebridge"

ENV HOMEBRIDGE_CONFIG="${HOMEBRIDGE_INSTALL_DIR}/config.json" \
    HOMEBRIDGE_PLUGINS="${HOMEBRIDGE_INSTALL_DIR}/plugins.txt" \
    HOMEBRIDGE_PERSIST_DIR="${HOMEBRIDGE_INSTALL_DIR}/persist"

##################################################
# Install tools                                  #
##################################################

RUN apt-get -y update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     avahi-daemon \
     avahi-discover \
     build-essential \
     libavahi-compat-libdnssd-dev \
     libnss-mdns \
     net-tools \
     nano \
     apt-utils \
     locales \
  && update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX \
  && locale-gen en_US.UTF-8 \
  && DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

##################################################
# Install homebridge                             #
##################################################

RUN npm install -g --unsafe-perm \
        homebridge \
        hap-nodejs \
        node-gyp && \
    cd /usr/lib/node_modules/homebridge/ && \
    npm install --unsafe-perm bignum && \
    cd /usr/lib/node_modules/hap-nodejs/node_modules/mdns && \
    node-gyp BUILDTYPE=Release rebuild

##################################################
# Add Homebridge User                            #
##################################################

USER root
RUN mkdir -p /var/run/dbus
RUN mkdir -p ${HOMEBRIDGE_HOME} && chmod 777 -R ${HOMEBRIDGE_HOME}

RUN groupadd -r ${HOMEBRIDGE_USER} -g 433 \
 && useradd -u 431 -r -g ${HOMEBRIDGE_USER} -d ${HOMEBRIDGE_HOME} -s /sbin/nologin -c "Docker image user" ${HOMEBRIDGE_USER} \
 && chown -R ${HOMEBRIDGE_USER}:${HOMEBRIDGE_GROUP} ${HOMEBRIDGE_HOME}

##################################################
# Start                                          #
##################################################

EXPOSE 5353 51826
COPY ./start.sh ${HOMEBRIDGE_HOME}/start.sh
RUN chmod 755 ${HOMEBRIDGE_HOME}/start.sh

USER ${HOMEBRIDGE_USER}
RUN mkdir -p ${HOMEBRIDGE_INSTALL_DIR}
VOLUME ["${HOMEBRIDGE_CONFIG}", "${HOMEBRIDGE_PLUGINS}", "${HOMEBRIDGE_PERSIST_DIR}"]
WORKDIR ${HOMEBRIDGE_HOME}

ENTRYPOINT ["/var/homebridge/start.sh"]
