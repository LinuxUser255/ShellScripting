# .bashrc


# Set language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Aliases
# Template for creating aliases
# alias cmd=' '

#---Personal aliases---#
# Listing Directories
alias l='ls'
alias ll='ls -l'
alias LL='ls -l'
alias LLA='ls -la'
alias lla='ls -la'
alias lll='lsgrep'  # Ensure 'lsgrep' is available or define it in Bash
alias ppp='pwsearch'  # Ensure 'pwsearch' is available or define it in Bash
# List only the Directory names in bold red font
alias lsdir='ls -l | awk "{print \"\033[1;31m\"\$9\"\033[0m\"}"'

# Text editors
alias v='nvim'
alias n='nvim'
alias nn='nvim .'  # netrw
alias k='kate'

# ops & cmds
alias s='sudo su'
alias e='exit'
alias q='exit'
alias rr='ranger'
alias c='cat'
alias b='batcat'
alias p='pass'
alias pa='pass add'
alias up='sudo apt update'
alias upup='sudo apt update && sudo apt upgrade'
alias inst='sudo apt install'
alias remap='remap'  # Remaps caps lock to the escape key; ensure 'remap' is available

# Opening files and directories
alias down='cd ~/Downloads'
alias doc='cd ~/Documents'
alias pic='cd ~/Pictures'
alias music='cd ~/Music'
alias mus='cd ~/Music/Genres'
alias vid='cd ~/Videos'
alias opt='cd /opt'
alias proj='cd ~/Projects'
alias pythonproj='cd ~/Projects/Python'
alias temp='cd ~/Templates'
alias projects='cd ~/Projects'
alias proj='cd ~/Projects'
alias rand='cd ~/Documents/random/'

# dot file access
alias vb='vim ~/.bashrc'
alias vv='vim ~/.vimrc'
alias rc='nvim ~/.bashrc'  # Changed from ~/.zshrc to ~/.bashrc
alias bb='bat ~/.bashrc'  # Changed from ~/.zshrc to ~/.bashrc
alias late='ls -lt | head -n 10'  # Displays the most recent file added or edited in a directory
alias nvconf='cd ~/.config/nvim'
alias alconf='nvim ~/.config/alacritty/alacritty.toml'
alias vimprac='nvim ~/Projects/Primeagen/VimMotionsTraining'
alias gitstuff='cd ~/Projects/GitStuff'
alias prime='cd ~/Projects/Primeagen'
alias alaconf='cd ~/.config/alacritty'

# Removed ohmyzsh-related aliases and paths, as Oh My Zsh is Zsh-specific
# alias ohmyzsh="mate ~/.oh-my-zsh"
# alias ohmyzsh="cd ~/.oh-my-zsh"

# SOURCED software added to $PATH
# ----------------------------------------------------------------------------
# PATH="$HOME/graudit:${PATH:+:${PATH}}"; export PATH;
# export GRDIR=/path/to/graudit/signatures
# source /lfbundle/lfbundle.zshrc  # Check if a Bash-compatible version exists
# Removed fpath+=${ZDOTDIR:-~}/.zsh_functions as fpath is Zsh-specific

# ruff-lsp
#export PATH="$HOME/.local/bin:$PATH"
#
## tree sitter cli thing
#export PATH=$PATH:./node_modules/.bin
#
## pip to path
#export PATH=$PATH:/home/linux/.local/bin
#
## Go Lang Env to path
#export GOPATH=$HOME/go
#export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin
#
## NVM (Node Version Manager)
#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#
