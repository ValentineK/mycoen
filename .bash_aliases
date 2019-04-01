alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -n "$(command -v git)" ]; then
  alias gst='git status'
  alias gbr='git branch'
  alias gch='git checkout'
  alias gdf='git diff'
  alias gpl='git pull'
  if [ "$(type -t __git_complete)" = function ]; then
    __git_complete gch _git_checkout
    __git_complete gps _git_push
    __git_complete gbr _git_branch
    __git_complete gpl _git_pull
  fi
fi

if [ -d "$HOME/Development/experteer-dev/pjpp" ]; then
  alias pjpp="cd $HOME/Development/experteer-dev/pjpp"
  alias pjppr='crane run pjpp'
  alias pjppe='crane exec pjpp'
fi
