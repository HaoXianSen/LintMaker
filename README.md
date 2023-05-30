# GZLintMaker

## 前言
一键式安装iOS lint 工具 & 自动嵌入precommit时期lint检测脚本
## 介绍
###### GZLintMaker 功能命令介绍

GZLintMaker 主要包含紫色三部分功能， --install --clean --uninstall，我们先分别介绍一下这几个功能：

* **--install**  

  作为install 的flag命令。主要内容就是安装codeLint的所有内容。

  * 移动配置文件、hook 脚本文件

    首先它会去默认的存放配置文件、执行脚本的git仓库，去clone 仓库内容。clone 完成            之后，我们把仓库里的.clang-formate . swiftlint移动到工程目录下（根目录）；将.pre-commit 脚本文件移动到.git/hooks/目录下，当然我们要确保这是一个基于git的仓库。最后我们删除远程存放这些文件的目录。
            
    <img         src="https://cdn.jsdelivr.net/gh/HaoXianSen/HaoXianSen.github.io@master/screenshots/20230526111628image-20230526111628810.png" alt="image-20230526111628810" style="zoom:50%;" />
            

  * lint 工具检查

    检查项有：

    * homebrew，没有则安装
    * homebrew tap （https://github.com/haoxiansen/homebrew-private）安装/更新
    * Objective-CLint 安装/更新
    * swiftLint 安装/更新
    * coreutils 安装(用来脚本时长统计)

* **--clean**

  清理当前工作空间

  * 清理配置文件.clang-formate .swiftlint 
  * 清理脚本文件 pre-commit
  * 清理配置文件存放的git 仓库目录（如果有的话）

* **--uninstall**

  卸载Lint工具

  * ObjectiveC-lint
  * swiftLint

* **--project-path**

  安装工作目录， 如果未指定默认为当前目录为工作目录

  * 可以和所有一级命令配合使用，作为指定工作目录

* **--configure-git-path**

  * 配置文件、脚本的git仓库
  * 需要指定自己的git 仓库作为自适应配置。仓库必须包括.clang-format .swiftlint 配置文件以及pre-commit脚本文件
  * 如果没有指定，默认使用我们的git仓库的配置作为配置
  * 为什么要采用单独的一个库作为配置文件、脚本文件的存储呢？主要是在于更新快，如果我们的pre-commit脚本、或者配置文件有更新，只要执行lintMaker --install 就可以更新
## 使用
