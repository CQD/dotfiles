# change default editor
export EDITOR=vim

#enables color in the terminal bash shell
export CLICOLOR=1

#sets up the color scheme for list
export LSCOLORS=ExFxCxDxBxegedabagacad

# for git branch display 
function git_branch {
    if ! type git &> /dev/null ; then
        return
    fi

    ref=$(git symbolic-ref HEAD 2> /dev/null);
    if [ $ref ] ; then
        echo "("${ref#refs/heads/}")";
        return
    fi

    hash=$(git log --pretty=format:'%h' -n 1 2> /dev/null);
    if [ $hash ] ; then
        echo "["$hash"]";
        return
    fi
}

#sets up the color scheme for list
export LSCOLORS=ExFxCxDxBxegedabagacad

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
    alias ls='ls --color=auto -G'
else
    alias ls='ls -G'
fi

alias ll='ls -al'
alias la='ls -a'

# if tmux exists, set up alias and re-attatch
if  type tmux &> /dev/null ; then
    alias ta='tmux attach'
    ta # always re-connect
fi
