# Dockerised apt-cacher-ng

Apt-Cacher NG is a caching proxy for linux distribution packages, primarily Debian. https://www.unix-ag.uni-kl.de/~bloch/acng/

The container apt-cacher-ng config adds support for:

- Alpine Linux packages from http://dl-cdn.alpinelinux.org
- Centos from https://mirrors.centos.org/ - edit `files/backends_centos`
- Fedora from https://admin.fedoraproject.org/mirrormanager/mirrors/Fedora - edit `files/backends_fedora`
- Epel package from https://admin.fedoraproject.org/mirrormanager/mirrors/EPEL - edit `files/backends_epel` 
- Apache packages from https://www.apache.org/mirrors/dist.html - edit `files/backends_apache`
- NPM packages from https://registry.yarnpkg.com and https://registry.npmjs.org
- Downloads from http://nodejs.org


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


## Mirror and Backend lists

The latest mirrors can be fetched with `src/fetch-mirrors.js`. This script Requires Node.js 8+ 

It will download and parse the latest Centos, Fedora, Epel and Apache mirror lists into `files/*_mirrors` files for acng.

Configure your selected backends from those mirrors lists in `files/backends_{name}`. They are currently set to AU backends which may be slow for other regions. 

Delete the `backends_*` files if you don't want acng to push all request to selected mirrors. 


## About 

Matt Hoyle - code atat deployable.co

