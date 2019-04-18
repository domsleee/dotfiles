prereq_env=('VIP', 'VIPGO')
export VIP_DOCKER_PLUGINS=/srv/www/wp-content/themes/vip/newscorpau-plugins
export VIPGO_DOCKER_PLUGINS=/var/www/html/wp-content/plugins/newscorpau-plugins

phpcs_plugin() {
  if [[ $# != 1 ]]; then echo "usage: phpcs_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  docker_kill_all
  pth=$VIP_DOCKER_PLUGINS/$1
  docker-compose -f "$VIP/docker-compose.yml" run --rm ci bash -c "phpcs -psv --standard=\"/srv/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml\" $pth"
  #docker-compose run --rm ci bash -c "/srv/import/phpcs.phar --config-set installed_paths /srv/import/wpcs,/srv/import/vipcs/WordPressVIPMinimum/,/srv/import/VariableAnalysis,/srv/import/phpcs-import-detection && /srv/import/phpcs.phar -p -s -v --standard=WordPress-VIP-Go /srv/www/"
  #docker-compose run --rm ci phpcs -p -s -v --standard="$pth/phpcs.ruleset.xml" --ignore={tests,vendor}/\* $pth

  if [[ $? != 0 ]]; then
    echo "ERROR. Check above"
  else
    echo "OKAY."
  fi
}

phpcs_plugin_vipgo() {
  if [[ $# != 1 ]]; then echo "usage: phpcs_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  docker_kill_all
  pth=$VIPGO_DOCKER_PLUGINS/$1
  docker-compose -f "$VIPGO/docker-compose.yml" run --rm ci bash -c "phpcs -psv --standard=/var/www/html/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml $pth"
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
  pth=$VIP_DOCKER_PLUGINS/$plugin
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