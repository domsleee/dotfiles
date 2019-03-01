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
  set -x
  pth=/srv/www/wp-content/themes/vip/newscorpau-plugins/$1/phpunit.xml
  docker-compose run --rm ci phpunit -c "$pth" "${@:2}"
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
  cd $VIP
  for file in $VIP/www/wp-content/themes/vip/newscorpau-plugins/*; do
    if [[ -d $file ]]; then
      echo $file
      echo "--------------"
      hub -C "$file" checkout --track "origin/$branch" 2> /dev/null
      hub -C "$file" status -s > /tmp/gds
      if [[ -n $(cat /tmp/gds) ]]; then
        cat /tmp/gds
        hub -C "$file" add -A
        if [[ $(cat /tmp/gds | egrep "phpunit|phpcs" | wc -l) == $(cat /tmp/gds | wc -l) ]]; then
          echo "Only phpunit and phpcs"
          hub -C "$file" reset HEAD --hard
        else
          echo "*** stashing changes ***"
          hub -C "$file" stash push -m "Auto by co_test"
        fi
      fi
      hub -C "$file" checkout $branch
      hub -C "$file" pull
      echo .
    fi
  done
  for file in $VIP/www/wp-content/themes/vip/newscorpau-plugins/*; do
    if [[ -d $file ]]; then
      if [[ $(git -C "$file" branch | egrep " $branch\$") != "* $branch" ]]; then
        echo "Not currect $file"
        hub -C "$file" branch
      fi
    fi
  done
}

