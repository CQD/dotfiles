#!/bin/sh

BASEDIR=`dirname $0`

#
umask 077

# get latest
git pull


#
#cp ${BASEDIR}/.profile ~/
cp ${BASEDIR}/.bash_profile ~/
cp ${BASEDIR}/.bashrc ~/

#
cp ${BASEDIR}/.tmux.conf ~/

# vim
cp ${BASEDIR}/.vimrc ~/
mkdir -p ~/.vim/
rsync -a ${BASEDIR}/.vim/ ~/.vim/
chmod 700 ~/.vim/
