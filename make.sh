#!/usr/bin/env bash

set -uexo pipefail

which greadlink >/dev/null 2>/dev/null && readlink=greadlink || readlink=readlink
rundir=$($readlink -f "${0%/*}")
cd "$rundir"

NAME="apt-cacher-ng"
SCOPE="deployable"
SCOPE_NAME="${SCOPE}/${NAME}"
CONTAINER_NAME="${NAME}"

cmd=${1:-build}
shift

####

run_build(){
  docker build -t ${SCOPE_NAME} .
}


run_build_mirrors(){
  node src/fetch-mirrors.js
}
run_build_backends_centos(){
  curl -s https://mirrors.centos.org/release=7&arch=x86_64&repo=extras&infra=container
}

run_run(){
  docker run --restart always -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw --name ${CONTAINER_NAME} -p 3142:3142 ${SCOPE_NAME}
}

run_stop(){
  docker stop ${CONTAINER_NAME}
}

run_rm(){
  docker rm ${CONTAINER_NAME}
}

run_logs(){
  docker logs -f ${CONTAINER_NAME}
}

run_rebuild(){
  run_build
  run_stop
  run_rm
  run_run
}

label_vcsref(){
  git_revision=$(git rev-parse --verify HEAD)
  perl -i -pane 's!org\.label-schema\.vcs-ref.*!org.label-schema.vcs-ref = "'$git_revision'" \\!g;' Dockerfile
}

git_tag(){
  git tag -f $(date +%Y%m%d) && git push -f --tags
}

####

run_help(){
  echo "Commands:"
  awk '/  ".*"/{ print "  "substr($1,2,length($1)-3) }' make.sh
}

set -x

case $cmd in
  "build")         run_build "$@";;
  "build:mirrors") run_build_mirrors "$@";;
  "rebuild")       run_rebuild "$@";;
  "template")      run_template "$@";;
  "run")           run_run "$@";;
  "stop")          run_stop "$@";;
  "rm")            run_rm "$@";;
  "logs")          run_logs "$@";;
  '-h'|'--help'|'h'|'help') run_help;;
esac
