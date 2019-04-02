#!/bin/bash
if [ ! -d ~/.safe-rm ]; then
  git clone git@github.com:kaelzhang/shell-safe-rm.git ~/.safe-rm
  cd ~/.safe-rm
  sudo cp ~/.safe-rm/bin/rm.sh /usr/local/bin/safe-rm
  chmod +x /usr/local/bin/safe-rm
else
  echo skipping install...
fi