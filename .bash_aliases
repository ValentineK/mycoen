alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

if [ -n "$(command -v git)" ]; then
  alias gst='git status'
  alias gbr='git branch'
  alias gch='git checkout'
  alias gdf='git diff'
fi

if [ -d "$HOME/Development/experteer-dev/pjpp" ]; then
  alias pjpp="cd $HOME/Development/experteer-dev/pjpp"
  alias pjppr='crane run pjpp'
  alias pjppe='crane exec pjpp'
fi
