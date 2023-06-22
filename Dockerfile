FROM golang:1.14 as build

WORKDIR /go/src/app
COPY script .

FROM php:7.3 as run
ENV VERSION=6.0.3
RUN apt-get update && \
    apt-get install -y git zip wget && \
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/*
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

RUN apt install -y curl

WORKDIR /tmp
ARG WORK_DIR=""
COPY entrypoint.sh /entrypoint.sh
COPY script/*.php /opt/
ENTRYPOINT ["/entrypoint.sh"]