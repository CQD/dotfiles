#!/bin/bash

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

function git_config_user {
    config_file="${HOME}/.gitconfig"
    if [ ! -f $config_file ]; then
        return
    fi

    section=0
    while  read -r line || [[ -n "$line" ]]; do
        if [ "" = "$line" ]; then continue; fi;

        linelen=${#line}
        if [ "[" = "${line:0:1}" ] && [ "]" = "${line:$linelen-1}" ]; then
            section=${line:1:${#line}-2}
            if [ "user" = "$section" ]; then echo "[$section]"; fi;
            continue;
        fi;

        if [ "user" = "$section" ]; then
            echo $line
        fi;
    done < <(cat $config_file | grep -o '^[^#]*' )

    echo
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
gitconfig=$(cat <(git_config_user) ${BASEDIR}/.gitconfig)
echo "$gitconfig" > ~/.gitconfig
cp ${BASEDIR}/.gitignore_global ~/

# vim
echo "== Installing vim config"
cp ${BASEDIR}/.vimrc ~/
if [ -d ~/.vim ]; then
    echo "~/.vim exists, remove it?"
    PS3='Select operation: '
    options=("Remove" "Don't remove" )
    select opt in "${options[@]}"
    do
        case $opt in
            "Remove")
                rm -rf ~/.vim
                echo "~/.vim removed"
                break;
                ;;
            *)
                break;
                ;;
        esac
    done
fi

# ~/bin/
echo "== Setup ~/bin/"

mkdir -p ~/bin

PS3='Select operation: '
options=("Setup" "Override" "Skip" )
select opt in "${options[@]}"
do
  case $opt in
    "Setup")
      wg cps https://getcomposer.org/composer.phar
      wg psysh https://psysh.org/psysh
      wg icdiff https://raw.githubusercontent.com/jeffkaufman/icdiff/master/icdiff
      wg git-cdi https://raw.githubusercontent.com/jeffkaufman/icdiff/master/git-icdiff
      break;
      ;;
    "Override")
      wg cps https://getcomposer.org/composer.phar f
      wg psysh https://psysh.org/psysh f
      wg icdiff https://raw.githubusercontent.com/jeffkaufman/icdiff/master/icdiff f
      wg git-cdi https://raw.githubusercontent.com/jeffkaufman/icdiff/master/git-icdiff f
      break;
      ;;
    *)
      break;
      ;;
  esac
done
cp -R bin/ ~/bin/ # always overide my scripts

echo
echo "== All done"
