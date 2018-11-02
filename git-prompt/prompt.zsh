source ~/.zsh-git-prompt/zshrc.sh
# this is a bit...
git_super_status >/dev/null
export ZSH_THEME_GIT_PROMPT_CACHE=1
PROMPT='%B%~%b%{$reset_color%}$(git_super_status) %# '
#PROMPT='%{$fg[green]%}%~%{$fg_bold[blue]%}$(git_super_status)%{$reset_color%} %# '