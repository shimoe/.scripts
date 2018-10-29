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
    echo "root_dir : $ROOT_DIR"
    dir_list=$(echo $(dirname $(find -type d -name .git)))
    dir_array=($dir_list)
    i=0;
    for e in ${dir_array[@]}; do
        echo $e
        cd $e
        echo -n "branch" && git branch --contains | sed -e 's/\*/:/'
        if [ "$1" = "f" ]; then
            if [ "$2" = "y" ]; then
                echo -e '\e[36m fetch now...\e[m'
                git fetch -p
            else
                echo -e '\e[36m fetch now...\e[m'
                git fetch -p #ひとまずfetchは問答無用
            fi
        elif [ "$1" = "p" ]; then
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
