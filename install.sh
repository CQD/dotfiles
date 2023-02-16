#!/usr/bin/env bash

set -e

BASEDIR=$(dirname $0)

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

    echo 下載 "$file_name" （"$remote_url"）
    curl -s -o "$local_path" "$remote_url"

    chmod +x $local_path
}

function mkln {
    src=$1
    dst=$2

    if [ ! -f "$src" ]; then
        echo $src 不存在！
        false
    fi

    if [ -f ~/$dst ] || [ -L ~/$dst ]; then
        echo "取代 $dst"
        rm ~/$dst
    else
        echo "建立 $dst"
    fi

    ln -s $(realpath $src) ~/$dst
}

function mkdln {
    mkln $BASEDIR/conf/$1 .$1
}

############################################################

umask 077

echo "== Config files =="
mkdln bash_profile
mkdln bashrc
mkdln tmux.conf
mkdln gitconfig
mkdln gitignore_global
mkdln vimrc

touch -a ~/.bashrc_local
touch -a ~/.gitconfig_local

if [ -d ~/.vim ]; then
    echo "~/.vim 已存在，必要時手動移除之"
fi


echo
echo "== ~/bin/ =="

mkdir -p ~/bin/

for src in $(ls $BASEDIR/bin ); do
    mkln $BASEDIR/bin/$src bin/$src
done
wg cps        https://getcomposer.org/composer.phar f
wg psysh      https://psysh.org/psysh f
wg icdiff     https://raw.githubusercontent.com/jeffkaufman/icdiff/master/icdiff f
wg git-cdi    https://raw.githubusercontent.com/jeffkaufman/icdiff/master/git-icdiff f


echo
echo "== All done =="
