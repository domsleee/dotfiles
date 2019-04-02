#!/bin/sh
alias reload!='exec "$SHELL" -l'
alias 2018s2="cd ~/Documents/2018s2"

# don't remember?
export DISPLAY=:0

PATH=$PATH:/opt/local/bin
alias rm='safe-rm'
PATH=$PATH:~/Documents/2018s2/COMP6741/assignments/a4/graph-viz
PATH=$PATH:/Applications/Isabelle2017.app/Isabelle/bin
PATH=$PATH:~/Documents/git/ch

function skim() {
    /Applications/Skim.app/Contents/MacOS/Skim $@ &
}
alias chrome='open -a "Google Chrome"'


