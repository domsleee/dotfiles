#!/bin/sh
if ls ~/.zsh-git-prompt >/dev/null 2>&1; then
    echo already installed
else
    git clone git@github.com:olivierverdier/zsh-git-prompt.git ~/.zsh-git-prompt
fi
