#!/bin/sh
if ls ~/.zsh-git-prompt >/dev/null 2>&1; then
    echo already installed
else
    git clone git@github.com:olivierverdier/zsh-git-prompt.git ~/.zsh-git-prompt
    brew install stack
    stack setup
    cd ~/.zsh-git-prompt && stack build && stack install
fi
