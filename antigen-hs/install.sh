#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

if ls ~/.zsh/MyAntigen.hs >/dev/null 2>&1; then
    echo already installed
else
    #brew install ghc cabal-install
    git clone https://github.com/Tarrasch/antigen-hs.git ~/.zsh/antigen-hs/
fi

cp $DIR/default.hs ~/.zsh/MyAntigen.hs
