prereq_env=('VIP', 'VIPGO')
# plugins
export VIP_PLUGINS=$VIP/www/wp-content/themes/vip/newscorpau-plugins
export VIPGO_PLUGINS=$VIPGO/src/wp-content/plugins/newscorpau-plugins
export VIP_DOCKER_PLUGINS=/srv/www/wp-content/themes/vip/newscorpau-plugins
export VIPGO_DOCKER_PLUGINS=/var/www/html/wp-content/plugins/newscorpau-plugins

# Themes
export VIP_THEMES=$VIP/www/wp-content/themes/vip
export VIPGO_THEMES=$VIPGO/src/wp-content/themes
export VIP_DOCKER_THEMES=/srv/www/wp-content/themes/vip
export VIPGO_DOCKER_THEMES=/var/www/html/wp-content/themes


function phpcs_run() {
  BASE=$1
  PLUGINS=$2
  DOCKER_PLUGINS=$3
  plugin=$4
  standard=$5
  binary=phpcs
  if [[ $# > 5 ]]; then binary="$6"; fi

  if [[ ! -d "$PLUGINS/$plugin" ]]; then
    echo "Invalid dir '$PLUGINS/$plugin'"
    return
  fi
  if [[ ! -d "$VIP" ]]; then return echo "VIP constant doesn't exist or isn't a folder: $VIP"; fi
  if [[ ! -d "$VIPGO" ]]; then return echo "VIPGO constant doesn't exist or isn't a folder: $VIPGO"; fi

  std=$(if [ -e "$PLUGINS/$plugin/phpcs.ruleset.xml" ]; then echo "phpcs.ruleset.xml"; else echo $standard; fi)
  cmd=$(echo "set -e && " \
  "cd '$DOCKER_PLUGINS/$plugin' && " \
  "$binary --standard='$std' .")
  >&2 echo "$standard: '$std'"
  docker-compose -f "$BASE/docker-compose.yml" run --rm ci bash -c "$cmd"
  if [[ $? != 0 ]]; then
    echo "ERROR. Check above"
  else
    echo "OKAY."
  fi
}


phpcs_plugin() {
  phpcs_run "$VIP" "$VIP_PLUGINS" "$VIP_DOCKER_PLUGINS" "$1" "WordPress-VIP"
}

phpcbf_plugin() {
  phpcs_run "$VIP" "$VIP_PLUGINS" "$VIP_DOCKER_PLUGINS" "$1" "WordPress-VIP" "phpcbf"
}

phpcs_theme() {
  phpcs_run "$VIP" "$VIP_THEMES" "$VIP_DOCKER_THEMES" "$1" "WordPress-VIP"
}

phpcs_plugin_vipgo() {
  phpcs_run "$VIPGO" "$VIPGO_PLUGINS" "$VIPGO_DOCKER_PLUGINS" "$1" "WordPress-VIP-Go"
}

phpcs_theme_vipgo() {
  phpcs_run "$VIPGO" "$VIPGO_THEMES" "$VIPGO_DOCKER_THEMES" "$1" "WordPress-VIP-Go"
}


phpunit_plugin () {
  if [[ $# < 1 ]]; then echo "usage: phpunit_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  set -x
  pth=$VIP_DOCKER_PLUGINS/$1/phpunit.xml
  docker-compose run --rm ci phpunit -c "$pth" "${@:2}"
}

phpunit_plugin_vipgo () {
  if [[ $# < 1 ]]; then echo "usage: phpunit_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  set -x
  pth=$VIPGO_DOCKER_PLUGINS/$1/phpunit.xml
  docker-compose run --rm ci phpunit -c "$pth" "${@:2}"
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