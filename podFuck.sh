#!/bin/sh

MOON_PATH=~/.moonPods
MOON_FILE=MOONFile

MOON_SERVER=47.74.8.253
MOON_SERVER_PASSWORD=moongit

showMenu() {
    echo "====== 你要搞咩？======"
    echo "1> remove trunk - 删除 trunk 目录"
    echo "2> change repo  - 更换 repo 源为镜像源"
    echo "3> TODO: setup git proxy"
    echo "4> moon gits    - 海外服务器下载相应仓库，本机再去拉取，详见 README.md 说明"
    echo "5> help"
    echo "0> exit"
}

removeTrunk() {
    echo "即将删除 trunk 文件夹..."
    echo "主要命令："
    echo "  rm -rf ~/.cocoapods/repos/trunk"
    read -p "确定执行？(y/n)" x
    if [[ ${x} == "y" ]]; then
        rm -rf ~/.cocoapods/repos/trunk
        echo "执行完毕..."
    fi
}

showChangeRepoMenu() {
    echo "======change repo======"
    echo "1> 更换 repo 源为清华大学镜像"
    echo "2> 还原 repo 源为官方地址"
    echo "3> 显示当前 repo 源地址"
    echo "4> TODO: 检测所有的 Podfile 文件 / 自动更换"
    echo "0> back"
}

changeRepo() {
    showChangeRepoMenu
    while read -p "podFuck>>>change repo>>>" idx; do
        if [[ ${idx} == "0" ]]; then
            break
        elif [[ ${idx} == "1" ]]; then
            echo "即将更换 repo 源为清华大学镜像..."
            echo "主要命令："
            echo "  git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git"
            read -p "确定执行？(y/n)" x
            if [[ ${x} == "y" ]]; then
                if [[ -d ~/.cocoapods/repos/master ]]; then
                    cd ~/.cocoapods/repos/master
                    git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git
                    git remote -v
                else
                    git clone https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git ~/.cocoapods/repos/master
                fi
                echo "请自行执行 pod repo update"
            fi
        elif [[ ${idx} == "2" ]]; then
            echo "即将还原 repo 源为官方地址..."
            echo "主要命令："
            echo "  git remote set-url https://github.com/CocoaPods/Specs.git"
            read -p "确定执行？(y/n)" x
            if [[ ${x} == "y" ]]; then
                if [[ -d ~/.cocoapods/repos/master ]]; then
                    cd ~/.cocoapods/repos/master
                    git remote set-url origin https://github.com/CocoaPods/Specs.git
                    git remote -v
                else
                    git clone https://github.com/CocoaPods/Specs.git ~/.cocoapods/repos/master
                fi
                echo "请自行执行 pod repo update"
            fi
        elif [[ ${idx} == "3" ]]; then
            if [[ -d ~/.cocoapods/repos/master ]]; then
                cd ~/.cocoapods/repos/master
                git remote -v
                cd -
            else
                echo "~/.cocoapods/repos/master 路径不存在"
            fi
        else
            showChangeRepoMenu
        fi
    done
}

showGitProxysMenu() {
    echo "====== git proxy ======"
    echo "1> TODO: 设置 git 代理"
    echo "2> TODO: 取消 git 代理"
    echo "0> back"
}

gitProxys() {
    showGitProxysMenu
    while read -p "podFuck>>>git proxy>>>" idx; do
        if [[ ${idx} == "0" ]]; then
            break
        elif [[ ${idx} == "1" ]]; then
            break
        elif [[ ${idx} == "2" ]]; then
            break
        else
            showGitProxysMenu
        fi
    done
}

serverUpdate() {
    if [[ -x /usr/bin/expect ]]; then
        echo "expect exist..."
        /usr/bin/expect <<EOF
        spawn scp ./${MOON_FILE} git@${MOON_SERVER}:/git/${MOON_FILE}
        expect "password:"
        send "${MOON_SERVER_PASSWORD}\r"
        expect eof
EOF
        /usr/bin/expect <<EOF
        spawn ssh -o StrictHostKeyChecking=no git@${MOON_SERVER} "cd /git; ./updateGits.sh ${MOON_FILE}; exit;"
        expect "password:"
        send "${MOON_SERVER_PASSWORD}\r"
        expect eof
EOF
        echo "东京服务器仓库下载完成..."
        return 0
    else
        echo "未安装 expect "
        return 1
    fi
}

checkFiles() {
    if [ ! -d ${MOON_PATH} ]; then
        echo "正在创建 ~/.moonPods 文件夹..."
        mkdir -p ${MOON_PATH}
    fi
    if [ ! -d ${MOON_PATH} ]; then
        echo "${MOON_PATH} 可能创建失败，请以管理员身份运行脚本..."
        return 1
    else
        return 0
    fi
}

fuckGits() {
    serverUpdate
    if checkFiles; then
        cp ./${MOON_FILE} ${MOON_PATH}/${MOON_FILE}
        cd ${MOON_PATH}
        rm ${MOON_PATH}/Podfile
        echo "${MOON_PATH}/${MOON_FILE}"
        cat ${MOON_PATH}/${MOON_FILE} | while read line; do
            resName=${line##*/}
            simpleName=${resName%%.git*}
            git clone git@${MOON_SERVER}:/git/${simpleName}
            echo "pod '${simpleName}', :path => '~/.moonPods/${simpleName}', :branch => 'master'" >>Podfile
        done
        rm ${MOON_PATH}/${MOON_FILE}
        echo "#本文件路径为 ${MOON_PATH}/Podfile ，方便用户替换工程中 Podfile 的相应内容..." >>Podfile
        vi ${MOON_PATH}/Podfile
        cd -
    fi
}

test() {
    cd ~/.moonPods
    git clone https://github.com/darkThanBlack/MOONAssistiveTouch
    sleep 2
    /usr/bin/expect <<EOF
    expect "password:"
    send "moongit\r"
    expect eof
EOF
}

showMenu
while read -p "podFuck>>>" idx; do
    if [[ ${idx} == "0" ]]; then
        break
    elif [[ ${idx} == "1" ]]; then
        removeTrunk
    elif [[ ${idx} == "2" ]]; then
        changeRepo
    elif [[ ${idx} == "3" ]]; then
        gitProxys
    elif [[ ${idx} == "4" ]]; then
        fuckGits
    elif [[ ${idx} == "5" ]]; then
        test
        # open README.md
    else
        showMenu
    fi
done
