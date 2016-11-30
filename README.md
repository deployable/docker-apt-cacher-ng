# Dockerised apt-cacher-ng

Apt-Cacher NG is a caching proxy for linux distribution packages, primarily Debian. https://www.unix-ag.uni-kl.de/~bloch/acng/

The container config adds support for alpine packages.

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

