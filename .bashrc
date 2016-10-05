# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# change default editor
export EDITOR=vim

#enables color in the terminal bash shell
export CLICOLOR=1

#sets up the color scheme for list
export LSCOLORS=ExFxCxDxBxegedabagacad

###############################
#sets up the prompt
###############################

# for git branch display
function git_branch {
    # do nothing if there is no git
    if ! type git &> /dev/null ; then
        return
    fi

    ref=$(git symbolic-ref HEAD 2> /dev/null);
    if [ $ref ] ; then
        echo "b"${ref#refs/heads/};
        return;
    fi

    hash=$(git log --pretty=format:'%h' -n 1 2> /dev/null);
    if [ $hash ] ; then
        echo "h"$hash;
        return
    fi
}

# random choose host color according to input string
function rand_color {
    local r g b fgcode offset
    if [ -z "$2" ]; then
        offset=5
    else
        offset=$2
    fi

    r=-1; g=-1; b=-1

    RANDOM=$(num-from-string $1); #seed with input string
    until [ $(( $r + $g + $b )) -ge $offset ]; do
        r=$(($RANDOM % 6));
        g=$(($RANDOM % 6));
        b=$(($RANDOM % 6));
    done

    fgcode=$((16 + 36 * $r + 6 * $g + $b))
    echo $fgcode
}

function num-from-string {
    local out i a

    out=1
    for ((i=0;i<${#1};++i)); do
        printf -v a "%d\n" "'${1:i:1}"
        out+=$((a%10))
    done
    echo $(($out % 1000000))
}

function ps_path {
    echo '\[\e[48;5;75m\]\[\e[30m\] \w '
}
function ps_login {
    echo '\[\e[48;5;235m\] $(ps_status)\[\e[38;5;'$(rand_color `whoami`)'m\]\u\[\e[37m\]@\[\e[38;5;'$(rand_color `hostname`)'m\]\h '
}
function ps_status {
    ret=$?

    local symbols job_cnt gears
    symbols=''

    # last command failed
    if [ $ret -ne 0 ] ; then
        symbols+='\033[38;5;160m✘ \033[22m'
    fi

    # background job running
    job_cnt=$(jobs -l | wc -l)
    if [ $job_cnt -gt 0 ] ; then
        gears=$(yes '⌛' |head -n $job_cnt)
        symbols+='\033[38;5;208m'$gears' \033[22m'
    fi

    # output
    echo -e $symbols
}
function ps_git {
    local branch prefix color

    branch=$(git_branch)
    if [ "$branch" == "" ] ; then
        return
    fi
    prefix=${branch:0:1}
    branch=${branch:1}
    if [ "$prefix" == "b" ] ; then
        if [ "$branch" == "master" ] ; then
            color=106
        elif [ "$branch" == "develop" ] ; then
            color=114
        else
            color=$(rand_color $branch 6)
        fi
        echo -e '\033[0;30;48;5;'$color'm ⎇ '$branch' '
    else
        echo -e '\033[0;30;48;5;136m ➦ '$branch' '
    fi
}

PS1=$(ps_login)$(ps_path)'$(ps_git)\[\e[0m\]\n\[\e[33m\]$\[\e[0m\] '

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

alias ll='ls -l'
alias la='ls -a'
alias lla='ls -al'

# if tmux exists, set up alias and re-attatch
if  type tmux &> /dev/null ; then
    alias ta='tmux attach'
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

# ssh-agent manangement
[ -z "$HOSTNAME" ] && HOSTNAME=`uname -n`
[[ -f ~/.keychain/$HOSTNAME-sh ]]  && source $HOME/.keychain/$HOSTNAME-sh

# init phpbrew
[[ -f ~/.phpbrew/bashrc ]]  && source ~/.phpbrew/bashrc
