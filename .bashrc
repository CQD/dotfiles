# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# change default editor
export EDITOR=vim

#enables color in the terminal bash shell
export CLICOLOR=1

#sets up the color scheme for list
export LSCOLORS=ExFxCxDxBxegedabagacad

# for git branch display 
function git_branch {
    # do nothing if there is no git
    if ! type git &> /dev/null ; then
        return
    fi

    # do nothing if this is not a git repo
    local git_status="`git status -unormal 2>&1`"
    if [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
        return
    fi

    # print branch name or hash
    local ref=$(git symbolic-ref HEAD 2> /dev/null);
    if [ $ref ] ; then
        # print branch name
        local branch="${ref#refs/heads/}";
        local Color_on='\033[0;32m'
    else
        # print hash for detached HEAD
        local branch=$(git log --pretty=format:'%h' -n 1 2> /dev/null);
        local Color_on='\033[0;33m'
    fi

    # print status
    if [[ "$git_status" =~ nothing\ to\ commit ]]; then
        local stat=""
    elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
        local stat="\033[0;36m+\033[0m"
    else
        local stat="\033[1;31m*\033[0m"
    fi

    # output
    echo -ne "$Color_on($branch$stat$Color_on)\033[0m"
}

#sets up the prompt color (currently a green similar to linux terminal)
#PS1='\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '
PS1='\u@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;32m\]$(git_branch)\[\e[0m\]\$ '

#enables color for iTerm
#export TERM=xterm-color
export TERM=xterm-256color

#sets up proper alias commands when called
if [ "$(uname)" = "Linux" ]; then
    # set up color for linux
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias ls='ls --color=auto -vG'
elif [ "$(uname)" = "Darwin" ]; then
    alias ls='ls -vG'
else
    alias ls='ls -G'
fi

alias ll='ls -al'
alias la='ls -a'

# if tmux exists, set up alias and re-attatch
if  type tmux &> /dev/null ; then
    alias ta='tmux attach'
    tmux attach # always re-connect
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

# include machine depending settings that not to be included in dotfile repo
if [ -f ./.bashrc_local ] ; then
    source .bashrc_local
fi
