# change default editor
export EDITOR=vim

#enables color in the terminal bash shell
export CLICOLOR=1

#sets up the color scheme for list
export LSCOLORS=ExFxCxDxBxegedabagacad

# for git branch display 
function git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return;
    echo "("${ref#refs/heads/}")";
}

#sets up the color scheme for list
export LSCOLORS=ExFxCxDxBxegedabagacad

#sets up the prompt color (currently a green similar to linux terminal)
#PS1='\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '
PS1='@\[\e[0;32m\]Kharak\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;32m\]$(git_branch)\[\e[0m\]\$ '

#enables color for iTerm
#export TERM=xterm-color
export TERM=xterm-256color

#sets up proper alias commands when called
alias ls='ls -vG'
alias ll='ls -al'
alias la='ls -a'
alias ta='tmux attach'
