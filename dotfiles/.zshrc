# ULMIT -n 8192
# Prevent this Alacritty error:
# [ERROR] see log at /tmp/Alacritty-304237.log ($ALACRITTY_LOG):
# Unable to watch config file: Too many open files (os error 24)
ulimit -n 8192

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

fastfetch
#syntax
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="jispwoso"
ZSH_THEME="robbyrussell"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

#  update reminder zsh
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to change how often to auto-update (in days).
zstyle ':omz:update' frequeny 10

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
plugins=(alias-finder)

source $ZSH/oh-my-zsh.sh

# User configuration
export ZSH_2000_DISABLE_RVM='true'
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi


# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"
# Template for creating aliases
# alias cmd=' '

#---Personal aliases---#
# Listing Directories
alias l='ls'
alias ll='ls -l'
alias LL='ls -l'
alias LLA='ls -la'
alias lla='ls -la'
alias lll='lsgrep'
alias ppp='pwsearch'
# List only the Directory names in bold red font
alias lsdir='ls -l | awk "{print \"\033[1;31m\"\$9\"\033[0m\"}"'

# Text editors
alias v='nvim'
alias n='nvim'
alias nn='nvim .' # netrw
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
alias ifconfig='sudo ifconfig'
alias iwconfig='sudo iwconfig'
alias shut='sudo shutdown -P now'
alias png='ping 1.1.1.1'
alias shutdown='sudo shutdown -P now'
alias reboot='sudo reboot'
alias wifidown='ifconfig wlp4s0 down'
alias a='alacritty msg create-window'
alias yt='yt-dlp '
alias yta='yt-dlp --extract-audio --audio-format mp3 '
alias space='space'  # Double spaces lines of a text file.
alias remap='remap'   # Remaps caps lock to the escape key.

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
alias res='~/Documents/Resumes/Latex/2025/'
alias stratum='cd ~/Projects/StratumSec'
alias keymaps='nvim ~/Projects/Neovim/nvim-keymaps-tutor.md'
alias todo='cd ~/Documents/ToDos'
alias bsuite='cat ~/Documents/BSuitestuff/bsuite.txt'
alias gpt='nvim ~/Documents/random/gptchat/questions.txt'
alias emails='nvim ~/Documents/random/email-compose.txt'
alias hacking='cd ~/Projects/Hacking/'
alias apivids='cd ~/Downloads/old-downloads/Backups/ExternalHD-2TB/Crucial2TB/Tutorials'
alias tutor='cd ~/Downloads/old-downloads/Backups/ExternalHD-2TB/Crucial2TB/'
alias todo='cd ~/Documents/ToDo'
alias bots='cd ~/Projects/Bots'
alias nix='cd ~/Projects/LinuxThings'
alias hardn='cd ~/Projects/LinuxThings/Hardn-Project'
alias privaterepos='cd ~/Projects/LinuxThings/MyRepos-GitHub/PrivateRepos'
alias mysterylabs='cd ~/Projects/WebAcademy-MysteryLabs'

alias bsides='cd ~/Documents/BsidesTriad'
alias linuxthings='cd ~/Projects/LinuxThings/'


# dot file access
alias vb='vim ~/.bashrc'
alias vv="vim ~/.vimrc"
alias rc='nvim ~/.zshrc'
alias bb='bat ~/.zshrc'
alias late='ls -lt | head -n 10' # displays the most recent file added or edited in a directory.
alias ohmyzsh="cd ~/.oh-my-zsh"
alias nvconf="cd ~/.config/nvim"
alias alconf="nvim ~/.config/alacritty/alacritty.toml"
alias vimprac='nvim ~/Projects/Primeagen/VimMotionsTraining'
alias gitstuff='cd ~/Projects/GitStuff'
alias prime='cd ~/Projects/Primeagen'
alias alaconf='cd ~/.config/alacritty'

# alias cmd=' '
# alias cmd=' '

# SOURCED software added to $PATH
# ----------------------------------------------------------------------------
# PATH="$HOME/graudit:${PATH:+:${PATH}}"; export PATH;
# export GRDIR=/path/to/graudit/signatures
# source /lfbundle/lfbundle.zshrc
# fpath+=${ZDOTDIR:-~}/.zsh_functions

# ruff-lsp
export PATH="$HOME/.local/bin:$PATH"

# tree sitter cli thing
export PATH=$PATH:./node_modules/.bin

# pip to path
export PATH=$PATH:/home/linux/.local/bin

# Go Lang  Env to path
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ZSH Syntax highlighting
source /home/linux/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


