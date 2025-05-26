FROM docker.io/library/php:8.4-fpm

ARG UID=1000
ARG GID=$UID
ARG TZ=UTC
ARG POSTGRES_VERSION=17

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=${TZ}
ENV SPOTWEB_COMMAND="php-fpm --nodaemonize -F"
ENV SPOTWEB_USER="docker"

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

RUN sed -i 's/^Components: main$/& contrib non-free/' /etc/apt/sources.list.d/debian.sources

RUN apt-get update && apt-get upgrade -y \
    && mkdir -p /etc/apt/keyrings \
    && apt-get install -y gnupg curl ca-certificates zip unzip git sqlite3 postgresql-common dnsutils fswatch \
    && apt-get install -y libpng-dev librsvg2-bin libjpeg-dev libfreetype6-dev libwebp-dev libxpm-dev \
    && apt-get install -y ffmpeg gifsicle jpegoptim optipng pngquant \
    && /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y \
    && apt-get install -y postgresql-client-${POSTGRES_VERSION}

ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && install-php-extensions @composer apcu bcmath bz2 calendar ev event exif gd \
    gettext igbinary imagick imap inotify intl msgpack opcache pcntl pcov \
    pdo_mysql pdo_pgsql pgsql redis sockets uv zip

COPY runtimes/container-entrypoint.sh /usr/local/bin/container-entrypoint.sh
COPY runtimes/php-production.ini /etc/php/8.4/fpm/conf.d/99-user.ini
COPY runtimes/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY runtimes/www.conf /usr/local/etc/php-fpm.d/www.conf

RUN chmod +x /usr/local/bin/container-entrypoint.sh

RUN groupadd --force -g ${GID} docker \
    && useradd -ms /bin/bash --no-user-group -g ${GID} -u ${UID} docker

RUN apt-get -y autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9000

ENTRYPOINT ["container-entrypoint.sh"]
