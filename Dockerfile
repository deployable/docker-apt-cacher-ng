from debian:latest

run set -uex; \
    apt-get update -y; \
    apt-get install apt-cacher-ng -y; \
    ln -sf /dev/stdout /var/log/apt-cacher-ng/apt-cacher.log; \
    ln -sf /dev/stderr /var/log/apt-cacher-ng/apt-cacher.err; \
    apt-get clean all;

copy acng.conf /etc/apt-cacher-ng/acng.conf
copy mirrors_alpine /etc/apt-cacher-ng/


label org.label-schema.name = "deployable/apt-cacher-ng" \
      org.label-schema.version="1.0.0"
      org.label-schema.vendor="Deployable" \
      org.label-schema.docker.cmd="docker run --restart always -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw -p 3142:3142 deployable/apt-cacher-ng
      org.label-schema.url="https://github.com/deployable/docker-apt-cacher-ng" \
      org.label-schema.vcs-url="https://github.com/deployable/docker-apt-cacher-ng.git" \
      org.label-schema.vcs-ref = ""\
      org.label-schema.schema-version="1.0" \

expose 3142
volume ["/var/cache/apt-cacher-ng"]

entrypoint ["/usr/sbin/apt-cacher-ng"]
cmd ["-c","/etc/apt-cacher-ng"]

