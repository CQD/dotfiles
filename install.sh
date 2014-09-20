#!/bin/sh

BASEDIR=`dirname $0`

#
umask 077

#
echo installing bashrc
#cp ${BASEDIR}/.profile ~/
cp ${BASEDIR}/.bash_profile ~/
cp ${BASEDIR}/.bashrc ~/

#
echo installing tmux config
cp ${BASEDIR}/.tmux.conf ~/

#
echo installing git config
cp ${BASEDIR}/.gitconfig ~/
cp ${BASEDIR}/.gitignore_global ~/

# vim
echo installing vim config
cp ${BASEDIR}/.vimrc ~/
mkdir -p ~/.vim/
rsync -a ${BASEDIR}/.vim/ ~/.vim/
chmod 700 ~/.vim/

echo all done
