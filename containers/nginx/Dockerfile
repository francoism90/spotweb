FROM docker.io/library/nginx:mainline

ARG UID=1000
ARG GID=$UID
ARG TZ=UTC

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=${TZ}
ENV NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

RUN apt-get install -y \
    gnupg \
    curl \
    ca-certificates \
    zip \
    unzip \
    git \
    dnsutils

RUN usermod --non-unique --uid ${UID} nginx \
    && groupmod --non-unique --gid ${GID} nginx

COPY --chown=${UID}:${GID} runtimes/ /etc/nginx

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 8080
EXPOSE 8081
EXPOSE 8082

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
