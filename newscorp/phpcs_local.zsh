prereq_env=('VIP', 'VIPGO', 'VIP_PLUGINS', 'VIPGO_PLUGINS')
prereq_prog=('phpcs2', 'phpcbf2', 'phpcs3', 'phpcbf3')

export VIP_PHPCS_STANDARD=$VIP/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml
export VIPGO_PHPCS_STANDARD=$VIPGO/vendor/newscorpau/spp-dev-tools/phpcs.ruleset.xml


phpcsl_plugin() {
  if [[ $# != 1 ]]; then echo "usage: phpcsl_plugin plugin"; return; fi
  if [[ $(is_plugin $1) != 1 ]]; then echo "$1 is not a valid plugin!"; return; fi
  if [[ $(check_prereqs "$VIP_PLUGINS" "$VIP_PHPCS_STANDARD") != "1" ]]; then echo "prereqs"; return; fi
  pth=$VIP_PLUGINS/$1
  phpcsl_run "phpcs2" "WordPress-VIP" "$pth"
}

check_prereqs() {
  arr=("$@")
  for v in "${arr[@]}"; do
    if [[ $v == "" ]]; then
      echo "0"
      return
    fi
  done
  echo "1"
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

  #if [[ ! -f "$ruleset" ]]; then
  #  echo "Ruleset does not exist!"
  #  return
  #fi

  if [[ $binary == "phpcs2" || $binary == "phpcbf2" ]]; then
    echo "CLASSIC"
    $binary --config-set installed_paths $HOME/.phpcs/wpcsCLASSIC
  else
    $binary --config-set installed_paths $HOME/.phpcs/wpcs,$HOME/.phpcs/vipcs
  fi

  $binary -psv --standard="$ruleset" "$pth"
  if [[ $? != 0 ]]; then
    echo "ERROR. Check above"
  else
    echo "OKAY."
  fi
}
