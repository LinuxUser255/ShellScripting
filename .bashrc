# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# This can be run on any Debian-based distro

# PRO TIP: use ufw to quickly manage ports
# example. open/allow traffic on port 25: sudo ufw allow 25

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

date

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=20000
HISTFILESIZE=40000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

export EDITOR=nvim
#export VISUAL=vim

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi
# Modified PS1 to show full path on one line, arrow on the next
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[1;94m\]\w\n\[\033[1;32m\]➜ \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\w\n➜ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# source /usr/share/bash-completion/bash_completion

# FZF (fuzzy finder) for Bash
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh  # Replaced with Bash version
[ -f ~/.fzf.bash ] && source ~/.fzf.bash  # Ensure ~/.fzf.bash exists; install fzf if needed





############## End Of File  ###############################################################



# PS1='\[\e[1;32m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[1;35m\]$(__git_ps1 " (%s

# what about a prompt the looks like this?
# full path is displayed above the current directory, with an arrorow
# like shown below
#~/Downloads/HARDN-merge-service-manager-integration
#➜







