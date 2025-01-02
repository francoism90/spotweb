FROM docker.io/php:8.3-fpm-alpine

ARG UID=1000
ARG GID=$UID

ENV TZ=UTC
ENV PHP_INI_SCAN_DIR="${PHP_INI_DIR}/conf.d"
ENV SUPERVISOR_PHP_USER="www-data"

WORKDIR /app

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone

RUN apk update --no-cache \
    && apk upgrade --no-cache

RUN apk add --no-cache --virtual .build-deps ${PHPIZE_DEPS} \
    shadow \
    alpine-sdk \
    linux-headers \
    python3

RUN usermod --non-unique --uid ${UID} www-data \
    && groupmod --non-unique --gid ${GID} www-data

RUN apk add --no-cache --virtual .run-deps \
    gnupg \
    curl \
    wget \
    nano \
    git \
    tzdata \
    nss-tools \
    ca-certificates \
    libsodium-dev \
    sqlite \
    supervisor \
    mariadb-client \
    nodejs \
    npm \
    libavif \
    libogg \
    libpng \
    librsvg \
    libwebp \
    openjpeg \
    unzip \
    zip

RUN cp ${PHP_INI_DIR}/php.ini-production ${PHP_INI_DIR}/php.ini \
    && curl -sSLf \
    -o /usr/local/bin/install-php-extensions \
    https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions \
    @composer \
    apcu \
    bcmath \
    bz2 \
    event \
    exif \
    ffi \
    gettext \
    intl \
    mbstring \
    msgpack \
    opcache \
    pcntl \
    pcov \
    pdo_mysql \
    mysqli \
    zip \
    igbinary \
    gd

COPY --chown=${UID}:${GID} runtimes/php-production.ini ${PHP_INI_DIR}/conf.d/99-user.ini
COPY --chown=${UID}:${GID} runtimes/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY --chown=${UID}:${GID} runtimes/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chown=${UID}:${GID} runtimes/start-container /usr/local/bin/start-container

RUN chmod +x /usr/local/bin/start-container

RUN apk del .build-deps \
    && docker-php-source delete \
    && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

USER ${UID}

EXPOSE 8000
EXPOSE 9000

ENTRYPOINT ["start-container"]
