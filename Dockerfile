FROM debian:9

RUN set -uex; \
    apt-get update -y; \
    apt-get install apt-cacher-ng -y; \
    ln -sf /dev/stdout /var/log/apt-cacher-ng/apt-cacher.log; \
    ln -sf /dev/stderr /var/log/apt-cacher-ng/apt-cacher.err; \
    apt-get clean all;

COPY files/acng.conf files/mirrors_alpine /etc/apt-cacher-ng/

LABEL org.label-schema.name="deployable/apt-cacher-ng" \
      org.label-schema.version="1.2.0" \
      org.label-schema.vendor="Deployable" \
      org.label-schema.docker.cmd="docker run --restart always -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw -p 3142:3142 deployable/apt-cacher-ng" \
      org.label-schema.url="https://github.com/deployable/docker-apt-cacher-ng" \
      org.label-schema.vcs-url="https://github.com/deployable/docker-apt-cacher-ng.git" \
      org.label-schema.schema-version="1.0" 

EXPOSE 3142
VOLUME ["/var/cache/apt-cacher-ng"]

ENTRYPOINT ["/usr/sbin/apt-cacher-ng"]
CMD ["-c","/etc/apt-cacher-ng"]

