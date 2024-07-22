#!/bin/bash

# 获取当前登录的用户名
LOGGED_IN_USER=$(stat -f %Su /dev/console)

# 获取脚本参数值
DEPARTMENT_NAME="$4"

# 打开文件共享
open "smb://xxx.xxx.xxx/${DEPARTMENT_NAME}"

# 检查软链接是否已经存在
if [ -L "/Users/$LOGGED_IN_USER/Desktop/${DEPARTMENT_NAME}" ]; then
  echo "软链接已存在，跳过创建步骤。"
else
  ln -s "/Volumes/${DEPARTMENT_NAME}" "/Users/$LOGGED_IN_USER/Desktop/${DEPARTMENT_NAME}"
  echo "软链接创建成功。"
fi
