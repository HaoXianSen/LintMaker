#!/bin/bash

echo "正在检查安装必要工具..."
# 检测是否安装了homebrew
if [ "$(command -v brew -v)" ]; then
    echo "✅homebrew 已经安装"
else 
    echo "正在安装brew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   echo '✅安装完成homebrew 🍺🍺🍺 /n'
   
fi

# 检测是否安装了pre-commit
if [ "$(command -v pre-commit)" ]; then
    echo "✅pre-commit 已经安装"
else
    echo "正在安装pre-commit..."
    brew install pre-commit
    echo '✅安装完成pre-commit 🍺🍺🍺/n'
fi


if [ ! -f ".pre-commit-config.yaml" ]; then
    echo "\033[31m❎文件 \".pre-commit-config.yaml\" 不存在， 请添加.pre-commit-config.yaml\033[0m"
    exit 1
fi

pre-commit install
echo "\033[36m ...................所有工具都安装成功😁😁😁 \033[0m"