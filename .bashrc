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

    ref=$(git symbolic-ref HEAD 2> /dev/null);
    if [ $ref ] ; then
        echo "("${ref#refs/heads/}")";
        return;
    fi

    hash=$(git log --pretty=format:'%h' -n 1 2> /dev/null);
    if [ $hash ] ; then
        echo "["$hash"]";
        return
    fi
}

# random choose host color according to hostname
function rand_color {
    local r g b fgcode
    RANDOM=$(num-from-string $1); #seed with hostname
    r=$(($RANDOM % 5 + 1)); # 1~5
    g=$(($RANDOM % 5 + 1)); # 1~5
    b=$(($RANDOM % 5 + 1)); # 1~5
    fgcode=$((16 + 36 * $r + 6 * $g + $b))
    echo '38;5;'"$fgcode"
}

function num-from-string {
    local out i a
    for ((i=0;i<${#1};++i)); do
        printf -v a "%d\n" "'${1:i:1}"
        out+=$((a%10))
    done
    echo "$out"0
}

#sets up the prompt color (currently a green similar to linux terminal)
PS1='\[\e[0;33m\]-=[\[\e[m\] \e['$(rand_color `whoami`)'m\]\u\[\e[0m\]@\[\e['$(rand_color `hostname`)'m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;32m\]$(git_branch)\[\e[0m\] \[\e[0;33m]\]=-\[\e[m\]\n\$ '

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
