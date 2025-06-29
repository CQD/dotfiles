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

function mac_install {
    if ! command -v brew &> /dev/null; then
        echo "安裝 Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew update
    brew install pyenv bash

    ########################################
    # mac 預設 shell 是 bash 3.x
    # 安裝新版 bash 並設為預設 shell
    ########################################
    shell_path=$SHELL
    brew_shell_path=$(brew --prefix)/bin/bash

    # 設定
    if [ "$shell_path" != "$brew_shell_path" ]; then
        echo "將 $brew_shell_path 設為預設 shell"
        # sudo bash -c "echo $brew_shell_path >> /etc/shells"
        chsh -s $brew_shell_path
    fi
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
mkdln tigrc

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


# install brew if macOS
if [ "$(uname)" == "Darwin" ]; then
    echo "== mac =="
    mac_install || true
fi


echo
echo "== All done =="
