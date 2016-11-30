#

# First build
# docker build -t apt-cacher-ng . &&  docker run --restart always -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw --name apt-cacher-ng -p 3142:3142 apt-cacher-ng

# Repeat
# docker build -t apt-cacher-ng . && docker kill apt-cacher-ng && docker rm apt-cacher-ng &&  docker run --restart always -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw --name apt-cacher-ng -p 3142:3142 apt-cacher-ng

from debian:latest

run set -uex; \
    apt-get update -y; \
    apt-get install apt-cacher-ng -y; \
    ln -sf /dev/stdout /var/log/apt-cacher-ng/apt-cacher.log; \
    ln -sf /dev/stderr /var/log/apt-cacher-ng/apt-cacher.err; \
    apt-get clean all;

copy acng.conf /etc/apt-cacher-ng/acng.conf
copy mirrors_alpine /etc/apt-cacher-ng/

expose 3142
volume ["/var/cache/apt-cacher-ng"]


entrypoint ["/usr/sbin/apt-cacher-ng"]
cmd ["-c","/etc/apt-cacher-ng"]

