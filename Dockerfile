FROM balenalib/rpi-raspbian
MAINTAINER moo ba <m00ba@protonmail.com>
EXPOSE 10000
WORKDIR /


# Update image apt repos and install requirements
RUN apt-get update && apt-get upgrade -y
RUN apt-get install apt-transport-https wget gnupg2 net-tools cron apt-utils -y

RUN echo "Creating /data/webmin" && mkdir /data/webmin -p

VOLUME /etc/webmin

# Install Webmin
RUN echo "deb https://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list && \
    cd /root && \
    wget http://www.webmin.com/jcameron-key.asc && \
    apt-key add jcameron-key.asc

# Clean-Up Apt
RUN rm /etc/apt/apt.conf.d/docker-gzip-indexes && \
    apt-get purge apt-show-versions -y && \
    rm /var/lib/apt/lists/*lz4 && \
    apt-get -o Acquire::GzipIndexes=false update -y

# Install Webmin
RUN apt-get update && apt-get install webmin -y

# Disable SSL
# RUN sed -i 's/ssl=1/ssl=0/g' /data/miniserv.conf

# Set the root password
RUN echo root:webmin | chpasswd

ENV LC_ALL C.UTF-8

CMD /usr/bin/touch /var/webmin/miniserv.log && /usr/sbin/service webmin restart && /usr/bin/tail -f /var/webmin/miniserv.log
