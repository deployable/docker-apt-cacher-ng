FROM debian:buster-slim

LABEL maintainer='Yorick Poels'
LABEL org.label-schema.name="yorickps/apt-cacher-ng" \
      org.label-schema.version="1.6.0" \
      org.label-schema.vendor="yorickps" \
      org.label-schema.docker.cmd="docker run --restart on-failure -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw -p 3142:3142 yorickps/apt-cacher-ng" \
      org.label-schema.url="https://github.com/yorickps/docker-apt-cacher-ng" \
      org.label-schema.vcs-url="https://github.com/yorickps/docker-apt-cacher-ng.git" \
      org.label-schema.schema-version="1.0"

ENV APT_CACHER_NG_VERSION=3.2.1-1 \
    APT_CACHER_NG_CACHE_DIR=/var/cache/apt-cacher-ng \
    APT_CACHER_NG_LOG_DIR=/var/log/apt-cacher-ng \
    APT_CACHER_NG_USER=apt-cacher-ng

RUN apt-get update -y &&\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-cacher-ng="${APT_CACHER_NG_VERSION}" &&\
    mv /etc/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf.original &&\
    ln -sf /dev/stdout "${APT_CACHER_NG_LOG_DIR}"/apt-cacher.log &&\
    ln -sf /dev/stderr "${APT_CACHER_NG_LOG_DIR}"/apt-cacher.err &&\
    apt-get clean all  &&\
    rm -rf /var/lib/apt/lists/*

COPY files/* /etc/apt-cacher-ng/

EXPOSE 3142

VOLUME ["${APT_CACHER_NG_CACHE_DIR}"]

ENTRYPOINT ["/usr/sbin/apt-cacher-ng"]
CMD ["-c","/etc/apt-cacher-ng"]
