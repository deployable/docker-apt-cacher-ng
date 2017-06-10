# Dockerised apt-cacher-ng

Apt-Cacher NG is a caching proxy for linux distribution packages, primarily Debian. https://www.unix-ag.uni-kl.de/~bloch/acng/

The containers apt-cacher-ng config adds support for Alpine Linux packages from http://dl-cdn.alpinelinux.org.

## Run

```
docker run \
  --restart always \
  --detach \
  --volume apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw \
  --publish 3142:3142 \
  deployable/apt-cacher-ng
```

## Build

Build the image

`./make.sh build`

Run the image

`./make.sh run`

Rebuild and run 

`./make.sh rebuild`

## About 

Matt Hoyle - code@deployable.co

