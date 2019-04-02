export VIP=/Users/sleed/Documents/vip-quickstart-dont-die
export VIPGO=/Users/sleed/Documents/vipGONE
export wpd='pushd && cd $VIP && docker-compose up -d'
export webapp_name=vipquickstartdontdie_webapp_1

alias authoring="cd $VIP/www/wp-content/themes/vip/newscorpau-plugins/authoring"
alias authoring_vipgo="cd $VIPGO/src/wp-content/plugins/newscorpau-plugins/authoring"

alias dd="docker-compose down"
alias dl="docker-compose logs -f webapp"
alias dud="docker-compose up --force-recreate -d"
alias dudd="docker-compose -f docker-compose.dev.yml up --force-recreate -d"
alias dudl="dud && dl"
alias dla='docker-compose logs -f'
alias dw="docker-compose exec webapp bash"
alias vip_dud="cd $VIP && dud"
alias vip_dudd="cd $VIP && dudd"
alias vipgo_dud="cd $VIPGO && dud"
alias vipgo_dudd="cd $VIPGO && dudd"
alias vipgo_dudl="cd $VIPGO && dudl"
alias vipgo_dw="cd $VIPGO && dw"

function dwe() {
  docker-compose exec webapp "$@"
}

phpunit_plugin () {
  if [[ $# != 1 ]]; then echo "usage: phpunit_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  set -x
  pth=/srv/www/wp-content/themes/vip/newscorpau-plugins/$1/phpunit.xml
  docker-compose run --rm ci phpunit -c "$pth" "${@:2}"
}
#export -f phpunit_plugin

phpcs_plugin() {
  if [[ $# != 1 ]]; then echo "usage: phpcs_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=/srv/www/wp-content/themes/vip/newscorpau-plugins/$1
  docker-compose run --rm ci bash -c "/srv/import/phpcs.phar --config-set installed_paths /srv/import/wpcs,/srv/import/vipcs,/srv/import/VariableAnalysis && /srv/import/phpcs.phar -p -s -v --standard=\"$pth/phpcs.ruleset.xml\" $pth"
  #docker-compose run --rm ci bash -c "/srv/import/phpcs.phar --config-set installed_paths /srv/import/wpcs,/srv/import/vipcs/WordPressVIPMinimum/,/srv/import/VariableAnalysis,/srv/import/phpcs-import-detection && /srv/import/phpcs.phar -p -s -v --standard=\"$pth/phpcs.ruleset.xml\" /srv/www/"

  #docker-compose run --rm ci phpcs -p -s -v --standard="$pth/phpcs.ruleset.xml" --ignore={tests,vendor}/\* $pth

  if [[ $? != 0 ]]; then
    echo "ERROR. Check above"
  else
    echo "OKAY."
  fi
}

phpcs_plugin_branch() {
  if [[ $# != 2 ]]; then echo "usage: phpcs_plugin plugin branch"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  co_test.py master
  plugin=$1
  branch=$2
  pth=/srv/www/wp-content/themes/vip/newscorpau-plugins/$plugin
  localpth=$VIP/www/wp-content/themes/vip/newscorpau-plugins/$plugin
  files=($(git -C "$localpth" diff master $branch --name-only))
  git -C "$localpth" checkout $branch
  for file in $files; do
    echo $file
    docker-compose run --rm ci phpcs -p -s -v --standard="$pth/phpcs.ruleset.xml" --ignore={tests,vendor}/\* $pth/$file
    if [[ $? != 0 ]]; then
      echo "FAILED."
      return
    fi
  done
  echo "OKAY."
}

is_plugin() {
  if [[ -d "$VIP/www/wp-content/themes/vip/newscorpau-plugins/$1" ]]; then
    echo 1
  else
    echo 0
  fi
}

gcot() {
  if [[ $# != 1 ]]; then echo "usage: gcot branch"; return; fi
  hub checkout --track "origin/$1"
}

co_test () {
  branch='test'
  if [[ $# > 0 ]]; then
    branch=$1
  fi
  if [[ -z $VIP ]]; then
    echo "please define VIP in bashrc"
    return
  fi
  if [[ ! -d $VIP ]]; then
    echo "Error: $VIP not a folder"
    return
  fi
  cd $VIP
  for file in $VIP/www/wp-content/themes/vip/newscorpau-plugins/*; do
    if [[ -d $file ]]; then
      echo $file
      echo "--------------"
      git -C "$file" checkout --track "origin/$branch" 2> /dev/null
      git -C "$file" status -s > /tmp/gds
      if [[ -n $(cat /tmp/gds) ]]; then
        cat /tmp/gds
        git -C "$file" add -A
        if [[ $(cat /tmp/gds | egrep "phpunit|phpcs" | wc -l) == $(cat /tmp/gds | wc -l) ]]; then
          echo "Only phpunit and phpcs"
          git -C "$file" reset HEAD --hard
        else
          echo "*** stashing changes ***"
          git -C "$file" stash push -m "Auto by co_test"
        fi
      fi
      git -C "$file" checkout $branch
      git -C "$file" pull
      echo .
    fi
  done
  # verification
  for file in $VIP/www/wp-content/themes/vip/newscorpau-plugins/*; do
    if [[ -d $file ]]; then
      if [[ $(git -C "$file" branch | egrep " $branch\$") != "* $branch" ]]; then
        echo "Not currect $file"
        git -C "$file" branch
      fi
    fi
  done
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
