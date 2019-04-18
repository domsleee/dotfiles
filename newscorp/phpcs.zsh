
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

phpcs_plugin() {
  if [[ $# != 1 ]]; then echo "usage: phpcs_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=/srv/www/wp-content/themes/vip/newscorpau-plugins/$1
  docker-compose run --rm ci bash -c "set -x && /srv/import/phpcs.phar --config-set installed_paths /srv/import/wpcs,/srv/import/vipcsc && /srv/import/phpcs.phar -psv  --standard=\"$pth/phpcs.ruleset.xml\" $pth"
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
  pth=/var/www/html/wp-content/plugins/newscorpau-plugins/$1
  docker-compose run --rm ci bash -c "phpcbf -psv --standard=/var/www/html/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml $pth"
  #docker-compose run --rm ci phpcs -p -s -v --standard="$pth/phpcs.ruleset.xml" --ignore={tests,vendor}/\* $pth

  if [[ $? != 0 ]]; then
    echo "ERROR. Check above"
  else
    echo "OKAY."
  fi
}

phpcsl_plugin() {
  if [[ $# != 1 ]]; then echo "usage: phpcsl_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=$VIP_PLUGINS/$1
  phpcsl_run phpcs2 "$VIP/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml" "$pth"
}

phpcsl_plugin_vipgo() {
  if [[ $# != 1 ]]; then echo "usage: phpcsl_plugin_vipgo plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=$VIPGO_PLUGINS/$1
  phpcsl_run phpcs3 "$VIPGO/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml" "$pth"
}

phpcsl_run() {
  if [[ $# != 3 ]]; then echo "usage: phpcs_run binary ruleset path"; return; fi
  local binary=$1
  local ruleset=$2
  local pth=$3

  $binary -psv --standard="$ruleset" "$pth"
  if [[ $? != 0 ]]; then
    echo "ERROR. Check above"
    exit 1
  else
    echo "OKAY."
  fi
}