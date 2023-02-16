#!/bin/bash

set -e

############################################################
function wg {
    file_name=$1;
    remote_url=$2;
    is_force=$3;

    local_path=~/bin/$file_name

    if [ "$is_force" != 'f' ] && [ -f "$local_path" ]; then
        echo Skipping "$file_name"
        return;
    fi

    echo Installing "$file_name" from "$remote_url"
    curl -s -o "$local_path" "$remote_url"

    chmod +x $local_path
}

############################################################

BASEDIR=`dirname $0`

#
umask 077

#
echo "== Installing bashrc"
#cp ${BASEDIR}/.profile ~/
cp ${BASEDIR}/.bash_profile ~/
cp ${BASEDIR}/.bashrc ~/

#
echo "== Installing tmux config"
cp ${BASEDIR}/.tmux.conf ~/

#
echo "== Installing git config"
cp ${BASEDIR}/.gitconfig ~/
cp ${BASEDIR}/.gitignore_global ~/
touch ~/.gitconfig_local

# vim
echo "== Installing vim config"
cp ${BASEDIR}/.vimrc ~/
if [ -d ~/.vim ]; then
    echo "~/.vim 已存在，必要時手動移除之"
fi

# ~/bin/
echo "== Setup ~/bin/"

mkdir -p ~/bin

wg cps https://getcomposer.org/composer.phar f
wg psysh https://psysh.org/psysh f
wg icdiff https://raw.githubusercontent.com/jeffkaufman/icdiff/master/icdiff f
wg git-cdi https://raw.githubusercontent.com/jeffkaufman/icdiff/master/git-icdiff f

cp -R bin/ ~/bin/ # always overide my scripts

echo
echo "== All done"
