# MOONPods

> 本工程旨在试图彻底解决在天朝使用 CocoaPods 可能会出现的网络问题
>
> 本文结构按 CocoaPods 的安装与使用过程依次展开，假定读者已经具备使用 CocoaPods 的基础知识，并对 CocoaPods 的工作过程有一定了解
>
> 脚本执行方法：
>
> ```powershell
> chmod +x ./moon_pod.sh  #赋权
> sudo ./moon_pod.sh  #建议以管理员身份运行
> ```



#### Step1 - Install CocoaPods

​    CocoaPods 本身安装有多种途径，在这一步被墙的通常是如 gem， Homebrew 等工具本身，这里不再赘述。



#### Step2 - pod setup / pod repo update

* 背景
  * CocoaPods 在更新具体的第三方库源码之前，默认会去 GitHub 上下载一个约含 35 万个小文件的索引，默认存放在 ``~/.cocoapods/repos/`` 路径下的 ``master`` 文件夹中，后文用单词 repo 指代
  * 如果用户指定了某些特殊的 source，如某些私有仓库，也会将对应的索引下载到该路径中，与 ``master`` 平级
  * CocoaPods v1.7.x 开始开发官方 CDN，至 v1.8.x 开发完成，对应该路径下的 ``trunk`` 文件夹
* 问题
  * 如果以上任一仓库下载受阻，则会导致 ``pod setup / repo update / install / update`` 等命令报错
  * 加入 `` --verbose --no-repo-update`` 参数只是让 pod 不去更新 repo，本质上没有用处

* 解决方案

  * 针对 CDN

    * 如不使用 ，可直接删除 ``trunk`` 文件夹

      ```powershell
      cd ~/.cocoapods/repos/
      rm -rf trunk
      ```

    * 如果要用 CDN，整个 pods 工程的结构要做变化，暂不建议

  * 针对私有库

    * 具体工程的 Podfile 会有对应的 source，这个连通性自己排查，没什么好讲的

  * 针对 repo

    * 国内公共镜像，以[清华大学开源软件镜像站](<https://mirrors.tuna.tsinghua.edu.cn/help/CocoaPods/>)为例：

      * 更换 Podfile 里的官方 source

      ```powershell
      source 'https://github.com/CocoaPods/Specs.git'  #找到并删除
      source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'  #加入
      ```

      * 更换 repo 源，如果初次或重新安装可以直接 ``git clone``，否则可以直接更换 ``git remote``，不建议用 ``pod repo remove / add`` 系列命令

    	```powershell
    	# master 不存在 / 有问题 / 重新安装
    	git clone https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git master  
    	# 换源
    	cd ~/.cocoapods/repos/master
    	git remote -v
    	git remote set-url https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git
    	pod repo update
    	```




#### Step3 - pod install / pod update

* 背景
  * pods 会将具体的第三方库源码处理后放到 ``~/Library/Caches/CocoaPods/``路径下的 ``Pods``文件夹中，待全部下载完成后才会更新到开发工程中
* 问题
  * 如果任一三方库下载受阻，则会导致 ``pod install / update`` 等命令报错
  * 根据实际经验，有时会出现不特定仓库下载失败的情况，实验发现对该仓库 git clone / 网页下载源码 都会在某个进度上彻底卡住，认为可能是触发了墙的某些特殊规则，具体原因不明

* 解决方案
  * 方案一  团队的 Podfile 保持不变，团队成员利用自己的翻墙软件给 git 挂上代理
    * 注意浏览器 / 终端 / Git 代理设置一般均不通用
  * 方案二  通过自建的海外服务器 git clone 三方库源码，再从服务器把源码仓库下载至团队成员本地，约定好同一个路径，然后在 Podfile 内直接将对应的库指向本地路径。
  * **update 3.2  目前脚本初步实现了方案二，对应脚本的选项 4，流程如下：**
    * **用户编辑同目录下的 Fuckfile 文件，填入所有要更新仓库的 git 地址，每个仓库单独一行，前后无空格，使用 https 链接，以 .git 结尾**
    * **脚本将该文件上传至海外服务器，服务器会去依次 clone 相应仓库**
    * **待服务器 clone 完成后，脚本会依次去海外服务器将仓库下载至 ~/.moonPods 路径下**
    * **以上两步暂时需要多次填入服务器密码：``moongit``**
    * **用户修改工程内的 Podfile 文件，用 :file 的形式直接指向本地仓库，脚本会生成示例**



#### TODO LIST

* **[高] 海外服务器上的仓库目前不会保持更新**
* **[高] 目前没有国内中转服务器**
* **[高] 加入依赖包与命令判断，自动填充密码**
* **[中] 目前只会拉取一个 master**
* **[中] 应考虑 wget 取代 curl**
* **[中] Fuckfile 的团队协作，冲突/容错问题**
* **[高] 需要增加其他一大堆让睿智也能使用的代码**