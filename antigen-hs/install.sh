#!/bin/sh
if ls ~/.zsh/MyAntigen.hs >/dev/null 2>&1; then
    echo already installed
else
    #brew install ghc cabal-install
    git clone https://github.com/Tarrasch/antigen-hs.git ~/.zsh/antigen-hs/
fi

cp default.hs ~/.zsh/MyAntigen.hs
