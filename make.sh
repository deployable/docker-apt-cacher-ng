#!/usr/bin/env bash

set -uexo pipefail

which greadlink >/dev/null 2>/dev/null && readlink=greadlink || readlink=readlink
rundir=$($readlink -f "${0%/*}")
cd "$rundir"

NAME="apt-cacher-ng"
SCOPE="d"
SCOPE_NAME="${SCOPE}/${NAME}"
CONTAINER_NAME="${NAME}"

build(){
  docker build -t ${SCOPE_NAME} .
}

run(){
  docker run --restart always -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw --name ${CONTAINER_NAME} -p 3142:3142 ${SCOPE_NAME}
}

stop(){
  docker stop ${CONTAINER_NAME}
}

rm(){
  docker rm ${CONTAINER_NAME}
}

rebuild(){
  build
  stop
  rm
  run
}

ARG=${1:-build}
$ARG

