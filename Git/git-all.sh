#!bin/bash

_git_pull(){
    git pull origin $(echo $(git symbolic-ref --short HEAD))
}

_select_mode(){
    read -p "select command [f/p/b]" fp
    case "$fp" in
        f)  echo "fetch mode."
            $pflag = 0 
            $bflag = 0 ;;
        p)  echo "pull mode."
            $fflag = 0 
            $bflag = 0 ;;
        p)  echo "pull mode."
            $fflag = 0 
            $pflag = 0 ;;
        *)  echo "try again"
            _select_mode ;;
    esac
}

_select_pull(){
    local yn=''
    read -p "pull ok? (y/N): " yn
    echo "yn = $yn"
    if [[ $yn =~ y|Y ]]; then
        _git_pull
        return 1
    else
        return 0
    fi
}

_git_action(){
    ROOT_DIR=$(pwd)
    echo -e "\e[34mroot_dir : $ROOT_DIR\e[m\n"
    git_dirs=$(find -type d -name .git)
    if [ "$git_dirs" = "" ]; then
        echo "No such Git directory. Exit scripts."
        return 2> /dev/null
    fi
    dir_list=$(echo $(dirname $git_dirs))
    dir_array=($dir_list)
    i=0;
    for target_dir in ${dir_array[@]}; do
        echo -n "repository : " && echo -e "\e[33m$(echo $target_dir | sed -e 's/\.\///g')\e[m"
        cd $target_dir
        echo -n "branch :" && echo -e "\e[32m $(git symbolic-ref --short HEAD)\e[m"
        if [ "$1" = "f" ]; then
            echo -e '\e[36m fetch now...\e[m\n'
            if [ "$2" = "y" ]; then
                git fetch -p
            else
                git fetch -p #ひとまずfetchは問答無用
            fi
        elif [ "$1" = "p" ]; then
            echo -e '\e[31m pull now...\e[m\n'
            if [ "$2" = "y" ]; then
                _git_pull
            else
                _select_pull
            fi
        elif [ "$1" = "b" ]; then
            echo -e '\e[36m other branch...\e[m'
            git branch -l
            echo ""
        fi
        cd $ROOT_DIR
        let i++
    done
}

#option解析
declare -i argc=0
declare -a argv=()

#オプション解析
if [ $# = 0 ] ; then
    _git_action f y
fi
while (( $# > 0 ))
do
    case "$1" in
        -*)
            if [[ "$1" =~ 'f' ]]; then
                fflag='-f'
            fi
            if [[ "$1" =~ 'p' ]]; then
                pflag='-p'
            fi
            if [[ "$1" =~ 'b' ]]; then
                bflag='-b'
            fi
            if [[ "$1" =~ 'y' ]]; then
                yflag='-y'
            fi
            if [[ "$1" =~ 'h' ]]; then
                hflag='-h'
                echo -e "Option help \n -p : pull mode \n -f : fetch mode \n -b : show branch \n -h : show this help \n no option : fetch all"
            fi
            shift
            ;;
        *)
            ((++argc))
            argv=("${argv[@]}" "$1")
            shift
            ;;
    esac
done

if [ "$fflag" = "-f" -a "$pflag" = "-p" -a "$bflag" = "-b" ]; then
    _select_mode
fi

#実行部
if [ "$fflag" = "-f" ]; then
    if [ "$yflag" = "-y" ]; then
        _git_action f y
    else
        _git_action f
    fi
fi

if [ "$pflag" = "-p" ]; then
    if [ "$yflag" = "-y" ]; then
        _git_action p y
    else
        _git_action p
    fi
fi

if [ "$bflag" = "-b" ]; then
    _git_action b
fi

#変数掃除
unset fflag pflag yflag hflag bflag
