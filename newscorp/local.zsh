export VIP=/Users/sleed/Documents/vip-quickstart-dont-die
export VIP_PLUGINS=$VIP/www/wp-content/themes/vip/newscorpau-plugins
export VIPGO=/Users/sleed/Documents/vipGONE
export VIPGO_PLUGINS=$VIPGO/src/wp-content/plugins/newscorpau-plugins
export wpd='pushd && cd $VIP && docker-compose up -d'
export webapp_name=vipquickstartdontdie_webapp_1

alias authoring="cd $VIP/www/wp-content/themes/vip/newscorpau-plugins/authoring"
alias authoring_vipgo="cd $VIPGO/src/wp-content/plugins/newscorpau-plugins/authoring"

alias dd="docker-compose down --remove-orphans"
alias dl="docker-compose logs -f webapp"
alias dud="docker-compose up --force-recreate -d"
alias dudd="docker-compose -f docker-compose.dev.yml up --force-recreate -d && $VIP/utils/bin/docker-xdebug.darwin-amd64"
alias dudl="dud && dl"
alias dla='docker-compose logs -f'
alias dw="docker-compose exec webapp bash"
alias vip_dud="cd $VIP && dud"
alias vip_dudd="cd $VIP && dudd"
alias vipgo_dud="cd $VIPGO && dud"
alias vipgo_dudd="cd $VIPGO && dudd"
alias vipgo_dudl="cd $VIPGO && dudl"
alias vipgo_dw="cd $VIPGO && dw"
alias dde="dd && docker-compose -f $VIPGO/xdebug-docker-compose.yml up -d && $VIPGO/utils/docker-xdebug.darwin-amd64"

function dwe() {
  docker-compose exec webapp "$@"
}

function docker_kill_all() {
  echo "Stopping containers..."
  if [[ $(docker ps -a -q) != "" ]]; then
    docker stop $(docker ps -a -q)
  fi
}

phpunit_plugin () {
  if [[ $# < 1 ]]; then echo "usage: phpunit_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  set -x
  pth=/srv/www/wp-content/themes/vip/newscorpau-plugins/$1/phpunit.xml
  docker-compose run --rm ci phpunit -c "$pth" "${@:2}"
}
#export -f phpunit_plugin


is_plugin() {
  if [[ -d "$VIP_PLUGINS/$1" ]]; then
    echo 1
  else
    echo 0
  fi
}


gcot() {
  if [[ $# != 1 ]]; then echo "usage: gcot branch"; return; fi
  hub checkout --track "origin/$1"
}

function dcp() {
  path1=$1
  path2=$2

  if [[ $# != 2 ]]; then
    echo "usage: $0 path1 path2"
    exit 1
  fi

  if [[ $path1 == *":"* && $path2 == *":"* ]]; then
    echo wrong
    exit 1
  elif [[ $path1 == *":"* ]]; then
    container=$(echo $path1 | cut -d ':' -f 1)
    containerPath=$(echo $path1 | cut -d ':' -f 2)
    docker cp "$(docker-compose ps -q $container):$containerPath" $path2
  else
    container=$(echo $path2 | cut -d ':' -f 1)
    containerPath=$(echo $path2 | cut -d ':' -f 2)
    docker cp $path1 "$(docker-compose ps -q $container):$path2"
  fi
}

alias ci_ex="$VIPGO/.docker/ci/ci-example.sh"
