FROM docker.io/library/ubuntu:latest

ARG UID=1000
ARG GID=$UID
ARG TZ=UTC

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=${TZ}
ENV PIP_BREAK_SYSTEM_PACKAGES=1
ENV SPOTWEB_COMMAND="/usr/sbin/php-fpm8.4"
ENV SPOTWEB_USER="www-data"

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

RUN echo "Acquire::http::Pipeline-Depth 0;" > /etc/apt/apt.conf.d/99custom && \
    echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99custom && \
    echo "Acquire::BrokenProxy    true;" >> /etc/apt/apt.conf.d/99custom

RUN apt-get update && apt-get upgrade -y \
    && mkdir -p /etc/apt/keyrings \
    && apt-get install -y gnupg curl ca-certificates zip unzip git sqlite3 libcap2-bin libpng-dev python3 python3-pip dnsutils librsvg2-bin fswatch nano \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xb8dc7e53946656efbce4c1dd71daeaab4ad4cab6' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu noble main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
    && apt-get update \
    && apt-get install -y php8.4-cli php8.4-dev \
       php8.4-curl php8.4-fpm \
       php8.4-pgsql php8.4-sqlite3 php8.4-gd \
       php8.4-imap php8.4-mysql php8.4-mbstring \
       php8.4-xml php8.4-zip php8.4-bcmath php8.4-soap \
       php8.4-intl php8.4-readline php8.4-ldap \
       php8.4-msgpack php8.4-igbinary php8.4-redis php8.4-swoole \
       php8.4-memcached php8.4-pcov php8.4-imagick php8.4-xdebug \
    && curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
    && apt-get install -y mariadb-client

RUN usermod --non-unique --uid ${UID} www-data \
    && groupmod --non-unique --gid ${GID} www-data

COPY runtimes/container-entrypoint.sh /usr/local/bin/container-entrypoint.sh
COPY runtimes/php-production.ini /etc/php/8.4/fpm/conf.d/99-user.ini
COPY runtimes/php-fpm.conf /etc/php/8.4/fpm/php-fpm.conf
COPY runtimes/www.conf /etc/php/8.4/fpm/pool.d/www.conf

RUN setcap "cap_net_bind_service=+ep" /usr/bin/php8.4
RUN chmod +x /usr/local/bin/container-entrypoint.sh

RUN apt-get -y autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9000

ENTRYPOINT ["container-entrypoint.sh"]
