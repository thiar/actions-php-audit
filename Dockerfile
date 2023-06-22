FROM golang:1.14 as build

WORKDIR /go/src/app
COPY script .
RUN go build -o message

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
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install

WORKDIR /tmp
RUN wget https://github.com/sensiolabs/security-checker/archive/v${VERSION}.zip && \
    unzip v${VERSION}.zip && \
    mv security-checker-${VERSION} /opt/security-checker
WORKDIR /opt/security-checker
RUN composer install
ARG WORK_DIR=""
COPY entrypoint.sh /entrypoint.sh
COPY --from=build /go/src/app/message /opt
COPY script/*.php /opt
ENTRYPOINT ["/entrypoint.sh"]