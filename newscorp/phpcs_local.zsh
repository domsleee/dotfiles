prereq_env=('VIP', 'VIPGO', 'VIP_PLUGINS', 'VIPGO_PLUGINS')
prereq_prog=('phpcs2', 'phpcbf2', 'phpcs3', 'phpcbf3')

echo
export VIP_PHPCS_STANDARD=$VIP/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml
export VIPGO_PHPCS_STANDARD=$VIPGO/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml


phpcsl_plugin() {
  if [[ $# != 1 ]]; then echo "usage: phpcsl_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=$VIP_PLUGINS/$1
  phpcsl_run phpcs2 "$VIP_PHPCS_STANDARD" "$pth"
}

phpcbfl_plugin() {
  if [[ $# != 1 ]]; then echo "usage: phpcsl_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=$VIP_PLUGINS/$1
  phpcsl_run phpcbf2 "$VIP_PHPCS_STANDARD" "$pth"
}

phpcsl_plugin_vipgo() {
  if [[ $# != 1 ]]; then echo "usage: phpcsl_plugin_vipgo plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=$VIPGO_PLUGINS/$1
  phpcsl_run phpcs3 "$VIPGO_PHPCS_STANDARD" "$pth"
}

phpcbfl_plugin_vipgo() {
  if [[ $# != 1 ]]; then echo "usage: phpbfl_plugin_vipgo plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  pth=$VIPGO_PLUGINS/$1
  phpcsl_run phpcbf3 "WordPress-VIP-Go" "$pth"
}

# helper for phpcsl_* functions
phpcsl_run() {
  if [[ $# != 3 ]]; then echo "usage: phpcs_run binary ruleset path"; return; fi
  binary="$1"
  ruleset="$2"
  pth="$3"

  if [[ $binary =~ "phpcs2|phpcbf2" ]]; then
    phpcs2 --config-set installed_paths $HOME/.phpcs/wpcsCLASSIC
  else
    phpcs2 --config-set installed_paths $HOME/.phpcs/wpcs,$HOME/.phpcs/vipcs
  fi

  $binary -psv --standard="$ruleset" "$pth"
  if [[ $? != 0 ]]; then
    echo "ERROR. Check above"
  else
    echo "OKAY."
  fi
}
