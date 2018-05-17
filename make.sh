#!/usr/bin/env bash

set -uexo pipefail

which greadlink >/dev/null 2>/dev/null && readlink=greadlink || readlink=readlink
rundir=$($readlink -f "${0%/*}")
cd "$rundir"

NAME="acng"
SCOPE="deployable"
SCOPE_NAME="${SCOPE}/${NAME}"
CONTAINER_NAME="${NAME}"

cmd=${1:-build}
shift

####

run_release(){
  git tag $(date +%Y%m%d)
  git push
  git push --tags
}

run_build(){
  docker pull debian:9
  run_build_mirrors
  run_build_plain
  run_build_au
  run_build_uk
  run_build_us
}
run_build_plain(){
  local tag=${1:-latest}
  docker build -t ${SCOPE_NAME}:latest .
}
run_build_au(){
  local tag=${1:-latest-au}
  docker build -f Dockerfile.au -t ${SCOPE_NAME}:$tag .
}
run_build_uk(){
  local tag=${1:-latest-uk}
  docker build -f Dockerfile.uk -t ${SCOPE_NAME}:$tag .
}
run_build_us(){
  local tag=${1:-latest-us}
  docker build -f Dockerfile.us -t ${SCOPE_NAME}:$tag .
}

run_build_mirrors(){
  node src/fetch-mirrors.js
}
run_build_mirrors_build(){
  babel src/fetch-mirrors.es2017 > src/fetch-mirrors.js
}


run_run(){
  run_run_tag=$1
  run_run_image=${SCOPE_NAME}
  if [ -n "$run_run_tag" ]; then
    run_run_image="${run_run_image}:$run_run_tag"
  fi
  docker run --restart always -d -v apt-cacher-ng-vol:/var/cache/apt-cacher-ng:rw --name ${CONTAINER_NAME} -p 3142:3142 ${run_run_image}
}

run_run_au(){
  run_run latest-au
}
run_run_uk(){
  run_run latest-uk
}
run_run_us(){
  run_run latest-us
}

run_stop(){
  if docker inspect ${CONTAINER_NAME}; then
    docker stop ${CONTAINER_NAME};
  fi
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
  "release")           run_release "$@";;
  "build")             run_build "$@";;
  "build:plain")       run_build_plain "$@";;
  "build:au")          run_build_au "$@";;
  "build:us")          run_build_us "$@";;
  "build:uk")          run_build_uk "$@";;
  "build:mirrors")     run_build_mirrors "$@";;
  "build:mirrors:src") run_build_mirrors_build "$@";;
  "rebuild")           run_rebuild "$@";;
  "template")          run_template "$@";;
  "start")             run_run "$@";;
  "run")               run_run "$@";;
  "run:au")            run_run_au "$@";;
  "run:uk")            run_run_uk "$@";;
  "run:us")            run_run_us "$@";;
  "stop")              run_stop "$@";;
  "rm")                run_rm "$@";;
  "logs")              run_logs "$@";;
  '-h'|'--help'|'h'|'help') run_help;;
esac
