#!/bin/sh

showMenu(){
    echo "====== 你要搞咩？======"
    echo "1> remove trunk - 删除 .cocoaPods 文件夹下的 trunk 目录"
    echo "2> change repo  - 更换 repo 源为镜像源"
    echo "3> TODO: load git proxy"
    echo "4> TODO: unload git proxy"
    echo "5> TODO: feach & download gits"
    echo "0> exit"
}

removeTrunk(){
    echo "即将删除 trunk 文件夹..."
    echo "主要命令："
    echo "  rm -rf ~/.cocoapods/repos/trunk"
    read -p "确定执行？(y/n)" x
    if [ ${x} = "y" ]; then
        rm -rf ~/.cocoapods/repos/trunk
        echo "执行完毕..."
    fi
}

showChangeRepoMenu(){
    echo "======change repo======"
    echo "1> 更换 repo 源为清华大学镜像"
    echo "2> 还原 repo 源为官方地址"
    echo "3> TODO: 检测所有的 Podfile 文件 / 自动更换"
    echo "0> back"
}

changeRepo(){
    showChangeRepoMenu
    while read -p ">>>change repo>>>" idx
    do
        if [[ ${idx} == "0" ]]; then
            break
        elif [[ ${idx} == "1" ]]; then
            echo "即将更换 repo 源为清华大学镜像..."
            echo "主要命令："
            echo "  git remote set-url https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git"
            read -p "确定执行？(y/n)" x
            if [ ${x} == "y" ]; then
                if [ -d"~/.cocoapods/repos/master" ]; then
                    cd ~/.cocoapods/repos/master
                    git remote -v
                    git remote set-url https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git
                else
                    git clone https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git ~/.cocoapods/repos/master
                fi
                pod repo update
            fi
        elif [[ ${idx} == "2" ]]; then 
            echo "即将还原 repo 源为官方地址..."
            echo "主要命令："
            echo "  git remote set-url https://github.com/CocoaPods/Specs.git"
            read -p "确定执行？(y/n)" x
            if [ ${x} == "y" ]; then
                if [ -d"~/.cocoapods/repos/master" ]; then
                    cd ~/.cocoapods/repos/master
                    git remote -v
                    git remote set-url https://github.com/CocoaPods/Specs.git
                else
                    git clone https://github.com/CocoaPods/Specs.git ~/.cocoapods/repos/master
                fi
                pod repo update
            fi
        else
            showChangeRepoMenu
        fi
    done
}

showMenu
while read -p "podFuck>>>" idx
do
    if [[ ${idx} == "0" ]]
    then
        break
    elif [[ ${idx} == "1" ]]
    then
        removeTrunk
    elif [[ ${idx} == "2" ]] 
    then
        changeRepo
    else
        showMenu
    fi
done
