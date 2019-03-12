export VIP=/Users/sleed/Documents/vip-quickstart-dont-die
export wpd='pushd && cd $VIP && docker-compose up -d'
export webapp_name=vipquickstartdontdie_webapp_1

alias authoring='cd /Users/sleed/Documents/vip-quickstart-dont-die/www/wp-content/themes/vip/newscorpau-plugins/authoring'
alias dud="cd $VIP && docker-compose up --force-recreate -d"
alias dudd="cd $VIP && docker-compose -f docker-compose.dev.yml up --force-recreate -d"

webapp() {
  cd $VIP
  docker-compose exec webapp bash -c "echo 'wpr(){ wp --allow-root \"\$@\"; }' >> ~/.bashrc && bash"
}

phpunit_plugin () {
  if [[ $# != 1 ]]; then echo "usage: phpunit_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  set -x
  pth=/srv/www/wp-content/themes/vip/newscorpau-plugins/$1/phpunit.xml
  docker-compose run --rm ci phpunit -c "$pth" "${@:2}"
}

phpcs_plugin() {
  if [[ $# != 1 ]]; then echo "usage: phpcs_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=/srv/www/wp-content/themes/vip/newscorpau-plugins/$1
  docker-compose run --rm ci phpcs -p -s -v --standard="$pth/phpcs.ruleset.xml" --ignore={tests,vendor}/\* $pth
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

