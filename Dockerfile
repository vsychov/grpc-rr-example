ARG ROADRUNNER_VERSION=1.9.1
ARG PHP_VERSION=7.4

#build application assets
#FROM node:lts-alpine as nodejs
#
#WORKDIR /var/www
#
#RUN apk add yarn
#
#COPY package.* yarn.lock /var/www/
#
#RUN yarn install
#
#COPY ./assets/ /var/www/assets
#
#COPY webpack.config.js  /var/www/
#
#RUN NODE_ENV=production yarn build && yarn checker

## roadrunner image
FROM spiralscout/roadrunner:$ROADRUNNER_VERSION as rr

##------------------
## rr grpc
FROM golang:alpine as rr-grpc-builder

RUN apk update && apk add git

WORKDIR /build

RUN git clone https://github.com/spiral/php-grpc.git .

RUN cd cmd/rr-grpc && go build

RUN cd cmd/protoc-gen-php-grpc && go build

##-----------------
FROM alpine as protobuf-sources

RUN apk update && apk add git

WORKDIR /build

RUN git clone https://github.com/protocolbuffers/protobuf.git .

##-------------------------- Dev image --------------------------
FROM php:${PHP_VERSION}-alpine AS dev
WORKDIR /var/www/

## Install system dependencies
RUN apk update && apk add npm yarn postgresql-dev icu-dev bash $PHPIZE_DEPS gettext protoc

RUN docker-php-ext-install sockets intl pdo_pgsql opcache && pecl install apcu && docker-php-ext-enable apcu

RUN docker-php-ext-enable sockets intl pdo_pgsql opcache apcu

RUN echo "opcache.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    echo "apc.enabled=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini && \
    echo "apc.enable_cli=1" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

## Install symfony
COPY --from=symfonycorp/cli /symfony /usr/local/bin/symfony

## Install composer
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

COPY --from=rr /usr/bin/rr /usr/bin/rr

COPY --from=rr-grpc-builder /build/cmd/protoc-gen-php-grpc/protoc-gen-php-grpc /usr/bin/protoc-gen-php-grpc

COPY --from=rr-grpc-builder /build/cmd/rr-grpc/rr-grpc /usr/bin/rr-grpc

COPY --from=protobuf-sources /build/src/google/protobuf /var/proto/google/protobuf/

COPY ./composer.json ./composer.lock /var/www/

## Install application dependencies
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction --optimize-autoloader

##-------------------------- Prod image --------------------------
FROM php:${PHP_VERSION}-alpine AS prod
WORKDIR /var/www

ARG BUILD_VERSION=empty

EXPOSE ${HTTP_PORT}
EXPOSE ${APP_HEALTH_PORT}
EXPOSE ${PROMETHEUS_CLIENT_PORT}

RUN apk update && \
    apk add --no-cache libintl postgresql-dev icu-dev protoc

RUN mkdir /var/www/var && chown -R www-data:www-data /var/www/var

COPY --from=rr /usr/bin/rr /usr/bin/rr
COPY --from=rr-grpc-builder /build/cmd/protoc-gen-php-grpc/protoc-gen-php-grpc /usr/bin/protoc-gen-php-grpc
COPY --from=rr-grpc-builder /build/cmd/rr-grpc/rr-grpc /usr/bin/rr-grpc

COPY --from=dev /usr/bin/envsubst /usr/bin/envsubst
COPY --from=dev /usr/local/lib/php/ /usr/local/lib/php/
COPY --from=dev /usr/local/etc/php/ /usr/local/etc/php/
COPY --from=dev /var/www/vendor/ /var/www/vendor/

#COPY --from=nodejs /var/www/public/dist /var/www/public/dist

COPY . /var/www/

RUN touch .env

RUN echo ${BUILD_VERSION} > /var/www/public/.version

CMD [ "sh", "-c", "envsubst < .rr.template.yaml > .rr.yaml && rr serve -d -l json" ]