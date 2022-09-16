#!bin/bash

_git_pull(){
    git pull origin $(echo $(git symbolic-ref --short HEAD))
}

_select_mode(){
    read -p "select command [f/p/b/s]" fp
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
        elif [ "$1" = "s" ]; then
            echo -e '\e[36m show status...\e[m'
            git status
            echo ""
        elif [ "$1" = "c" ]; then
            git checkout $checkout_branch
            echo ""
        elif [ "$1" = "m" ]; then
            git merge -m "merge from $merge_branch" --no-ff $merge_branch
            echo ""
        fi
        cd $ROOT_DIR
        let i++
    done
}

#option解析;
declare -i argc=0
declare -a argv=()

if [ $# = 0 ] ; then
    echo "no option"
    # _git_action f y
fi
while getopts fpbsyhm:c: OPTION
do
    case "$OPTION" in
        f)  fflag='true' ;;
        p)  pflag='true' ;;
        b)  bflag='true' ;;
        s)  sflag='true' ;;
        m)  mflag='true' ;
            merge_branch="$OPTARG" ;;
        c)  cflag='true' ;
            checkout_branch="$OPTARG" ;;
        y)  yflag='true' ;;
        h)  hflag='true' ;
            echo "Option help"
            echo "  -p : pull mode"
            echo "  -f : fetch mode"
            echo "  -b : show branch"
            echo "  -h : show this help"
            echo "  no option : fetch all" ;;
        *)
            echo $OPTION ;;
    esac
done
shift $((OPTIND - 1))

# if [ "$fflag" = "true" -a "$pflag" = "true" -a "$bflag" = "true" ]; then
#     _select_mode
# fi

#実行部
if [ "$fflag" = "true" ]; then
    if [ "$yflag" = "true" ]; then
        _git_action f y
    else
        _git_action f
    fi
fi

if [ "$pflag" = "true" ]; then
    if [ "$yflag" = "true" ]; then
        _git_action p y
    else
        _git_action p
    fi
fi

if [ "$bflag" = "true" ]; then
    _git_action b
fi

if [ "$sflag" = "true" ]; then
    _git_action s
fi

if [ "$cflag" = "true" ]; then
    echo "checkout mode"
    _git_action c
fi

if [ "$mflag" = "true" ]; then
    echo "merge mode"
    _git_action m
fi

#変数掃除
unset fflag pflag yflag hflag bflag sflag cflag mflag OPTION OPTARG OPTIND
