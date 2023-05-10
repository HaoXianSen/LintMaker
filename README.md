# GZLintMaker

## 前言
为了实现我们一键式安装iOS lint 工具 & 自动嵌入precommit时期lint检测，特意开发lint安装工具`GZLintMaker`。
## 介绍
####`GZLintMaker` 的install主要实现了以下几个功能：
1、[SwiftLint](https://github.com/realm/SwiftLint) 及 [ObjectiveC-Lint](https://github.com/HaoXianSen/Objective-CLint)的集成
2、并且实现了给予一个远程`configureGitPath`配置地址，或者使用默认配置地址中拉取配置文件，应用到工程项目中
3、将precommit hook文件移动到.git的hooks中，实现precommit code lint

####`GZLintMaker` 还实现了以下几个辅助功能：
1、clean 清理当前工作空间
2、uninstall 清理当前工作空间 & 移除swiftLint和ObjectiveC-Lint
## 使用
