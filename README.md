# apt-cacher-ng docker image

[![Docker Automated build](https://img.shields.io/docker/automated/yorickps/apt-cacher-ng.svg)](https://hub.docker.com/r/yorickps/apt-cacher-ng/builds/)
[![Build Status](https://travis-ci.org/yorickps/docker-apt-cacher-ng.svg?branch=master)](https://travis-ci.org/yorickps/docker-apt-cacher-ng)
[![Docker Repository on Quay](https://quay.io/repository/yorickps/apt-cacher-ng/status "Docker Repository on Quay")](https://quay.io/repository/yorickps/apt-cacher-ng)

Apt-Cacher NG is a caching proxy for linux distribution packages, primarily Debian. https://www.unix-ag.uni-kl.de/~bloch/acng/

This image for apt-cacher-ng config adds support for:

- Alpine Linux packages from http://dl-cdn.alpinelinux.org
- Centos mirrors from https://mirrors.centos.org/
- Fedora mirrors from https://admin.fedoraproject.org/mirrormanager/mirrors/Fedora
- Epel mirrors from https://admin.fedoraproject.org/mirrormanager/mirrors/EPEL
- Apache releases from https://www.apache.org/mirrors/dist.html
- NPM packages from https://registry.yarnpkg.com and https://registry.npmjs.org (proxied CONNECT only)
- Downloads from http://nodejs.org

The `au`, `uk` and `us` images configure local mirror backends when geo mirrors are not available.

## Docker Registry Images

The [`yorickps/acng` repository is available on Docker hub](https://hub.docker.com/r/yorickps/acng/).

The image tags available to install are:
```
yorickps/acng
yorickps/acng:latest-au
yorickps/acng:latest-uk
yorickps/acng:latest-us
```

## Run

```
docker run \
  --restart on-failure \
  --detach \
  --volume apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw \
  --publish 3142:3142 \
  yorickps/acng
```


## Build

Build the image

```bash
./make.sh build
```

Run the image

```bash
./make.sh run
```

Run a localised image (au, uk, us)

```bash
./make.sh run:us
```

Rebuild and run

```bash
./make.sh rebuild
```

Build a locale image with local backends configured (`au`, `uk`, `us`)

```bash
./make.sh build
./make.sh build:au
```

## Mirror and Backend lists

The latest mirrors can be fetched with `src/fetch-mirrors.js`. This script Requires Node.js 8+

It will download and parse the latest Centos, Fedora, Epel and Apache mirror lists into `files/*_mirrors` files for acng.

Configure your selected backends from those mirrors lists in `files/backends_{name}`.
There are packaged au, uk and us backends

The default acng config in the `yorickps/acng:latest` tag has no opinion on backends
`yorickps/acng:latest-au` includes the AU backends, `:latest-uk` and `:latest-us` tags are built as well.


## About

Docker Hub: https://hub.docker.com/r/yorickps/acng/
GitHub: https://github.com/yorickps/docker-apt-cacher-ng
