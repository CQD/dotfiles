#!/bin/bash

############################################################
function wg {
    file_name=$1;
    remote_url=$2;
    is_force=$3;

    local_path=~/bin/$file_name

    if [ ! -d ~/bin ]; then
        mkdir ~/bin
    fi

    if [ "$is_force" != 'f' ] && [ -f "$local_path" ]; then
        echo Skipping "$file_name"
        return;
    fi

    echo Installing "$file_name" from "$remote_url"
    wget -q "$remote_url" -O $local_path

    chmod +x $local_path
}

############################################################

BASEDIR=`dirname $0`

#
umask 077

#
echo == Installing bashrc
#cp ${BASEDIR}/.profile ~/
cp ${BASEDIR}/.bash_profile ~/
cp ${BASEDIR}/.bashrc ~/

#
echo == Installing tmux config
cp ${BASEDIR}/.tmux.conf ~/

#
echo == Installing git config
cp ${BASEDIR}/.gitconfig ~/
cp ${BASEDIR}/.gitignore_global ~/

# vim
echo == Installing vim config
cp ${BASEDIR}/.vimrc ~/
mkdir -p ~/.vim/
rsync -a ${BASEDIR}/.vim/ ~/.vim/
chmod 700 ~/.vim/

# ~/bin/
echo "== Setup ~/bin/"
PS3='Select operation: '
options=("Setup" "Override" "Skip" )
select opt in "${options[@]}"
do
  case $opt in
    "Setup")
      wg cps https://getcomposer.org/composer.phar
      wg csf http://get.sensiolabs.org/php-cs-fixer.phar
      wg psysh http://psysh.org/psysh
      wg pcs http://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar
      # todo: colordiff
      break;
      ;;
    "Override")
      wg cps https://getcomposer.org/composer.phar f
      wg csf http://get.sensiolabs.org/php-cs-fixer.phar f
      wg psysh http://psysh.org/psysh f
      wg pcs http://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar f
      # todo: colordiff
      break;
      ;;
    *)
      break;
      ;;
  esac
done

echo
echo == All done
