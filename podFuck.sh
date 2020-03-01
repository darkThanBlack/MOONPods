#!/bin/sh

export MOON_FILE=Fuckfile
export MOON_PATH=~/.moonPods

export MOON_SERVER=47.74.8.253
export MOON_SERVER_PASSWORD="moongit"

showMenu(){
    echo "====== 你要搞咩？======"
    echo "1> remove trunk - 删除 trunk 目录"
    echo "2> change repo  - 更换 repo 源为镜像源"
    echo "3> TODO: setup git proxy"
    echo "4> moon gits    - 海外服务器下载相应仓库，本机再去拉取，详见 README.md 说明"
    echo "5> help"
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
    while read -p "podFuck>>>change repo>>>" idx
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

showGitProxysMenu(){
    echo "====== git proxy ======"
    echo "1> TODO: 设置 git 代理"
    echo "2> TODO: 取消 git 代理"
    echo "0> back"
}

gitProxys(){
    showGitProxysMenu
    while read -p "podFuck>>>git proxy>>>" idx
    do
        if [[ ${idx} == "0" ]]
        then
            break
        elif [[ ${idx} == "1" ]]
        then
            break
        elif [[ ${idx} == "2" ]]
        then
            break
        else
            showGitProxysMenu
        fi
    done
}

fuckGits(){
    if [ ! -d ${MOON_PATH} ]; then
        echo "正在创建 ~/.moonPods 文件夹，可能需要输入您的管理员密码..."
        mkdir -p ${MOON_PATH}
    fi
    cp ./Fuckfile ${MOON_PATH}/Fuckfile
    scp ./Fuckfile git@${MOON_SERVER}:/git/Fuckfile
    ssh -o StrictHostKeyChecking=no git@${MOON_SERVER} <<eeooff
    cd /git
    ./updateGits.sh
    exit
eeooff
    echo "东京服务器仓库下载完成..."
    cd ${MOON_PATH}
    rm ${MOON_PATH}/Podfile
    while read line
    do
        resName=${line##*/}
        simpleName=${resName%%.git*}
        git clone git@${MOON_SERVER}:/git/${simpleName}
        # pod 'AFNetworking', :path => '~/Documents/AFNetworking', :branch => 'dev', :tag => '1.0.0'
        echo "pod '${simpleName}', :path => '~/.moonPods/${simpleName}'" >> Podfile
    done < ${MOON_PATH}/Fuckfile
    rm ${MOON_PATH}/Fuckfile
    echo "#本文件路径为 ${MOON_PATH}/Podfile ，方便用户替换工程中 Podfile 的相应内容，输入 :wq 退出..." >> Podfile
    vi ${MOON_PATH}/Podfile
    cd -
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
    elif [[ ${idx} == "3" ]]
    then
        gitProxys
    elif [[ ${idx} == "4" ]]
    then
        fuckGits
    elif [[ ${idx} == "5" ]]
    then
        open README.md
    else
        showMenu
    fi
done
