#!bin/bash

select_pull(){
    local yn=''
    read -p "pull ok? (y/N): " yn
    echo "yn = $yn"
    if [[ $yn =~ y|Y ]]; then
        git pull
        return 1
    else
        return 0
    fi
}

git_action(){
    ROOT_DIR=$(pwd)
    echo -e "\e[34mroot_dir : $ROOT_DIR\e[m\n"
    dir_list=$(echo $(dirname $(find -type d -name .git)))
    dir_array=($dir_list)
    i=0;
    for target_dir in ${dir_array[@]}; do
        echo -n "repository : " && echo -e "\e[32m$(echo $target_dir | sed -e 's/\.\///g')\e[m"
        cd $target_dir
        echo -n "branch :" && echo -e "\e[33m $(git symbolic-ref --short HEAD)\e[m"
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
                git pull
            else
                select_pull
            fi
        fi
        cd $ROOT_DIR
        let i++
    done
}

#option解析
declare -i argc=0
declare -a argv=()


if [ $# = 0 ] ; then
    git_action f y
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
            if [[ "$1" =~ 'y' ]]; then
                yflag='-y'
            fi
            if [[ "$1" =~ 'h' ]]; then
                hflag='-h'
                echo -e "Option help \n -p : pull mode \n -f : fetch mode \n -h : show this help \n no option : fetch all"
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

#実行部
if [ "$fflag" = "-f" ]; then
    if [ "$yflag" = "-y" ]; then
        git_action f y
    else
        git_action f
    fi
fi

if [ "$pflag" = "-p" ]; then
    if [ "$yflag" = "-y" ]; then
        git_action p y
    else
        git_action p
    fi
fi

#変数掃除
unset fflag pflag yflag hflag
