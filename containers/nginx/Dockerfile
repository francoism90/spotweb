FROM docker.io/library/nginx:mainline

ARG UID=1000
ARG GID=$UID
ARG TZ=UTC

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=${TZ}
ENV NGINX_ENTRYPOINT_LOCAL_RESOLVERS=1

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

RUN apt-get update && apt-get upgrade -y \
    && mkdir -p /etc/apt/keyrings \
    && apt-get install -y build-essential gnupg curl ca-certificates zip unzip git dnsutils libssl-dev

RUN usermod --non-unique --uid ${UID} nginx \
    && groupmod --non-unique --gid ${GID} nginx

COPY --chown=${UID}:${GID} runtimes/ /etc/nginx

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/local/src/*

EXPOSE 8080

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
