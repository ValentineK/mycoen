# My Console Environment initial
source $HOME/.bashrc
export PATH="/usr/local/opt/python@3.8/bin:$PATH"
source "$HOME/.cargo/env"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/tin/Downloads/google-cloud-sdk/path.bash.inc' ]; then . '/Users/tin/Downloads/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/tin/Downloads/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/tin/Downloads/google-cloud-sdk/completion.bash.inc'; fi
