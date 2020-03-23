#!/bin/sh

#cd d:OneDrive/git/MyBlog
#git config --global user.name "biozhangjn"
#git config --global user.email "biozhangjn@gmail.com"

#清除之前的SSH设置，4需要管理员权限
#git config --global -l
#git config --system -l
#git config --global --unset credential.helper
#git config --system --unset credential.helper

#建立本地仓库
git init
#关联到Github仓库
git remote add origin git@github.com:biozhangjn/Blog.git
#把目录下所有文件更改状况提交到暂存区
git add .
#提交更改的说明
git commit -m "Blog update"
#开始推送到Github
git pull --rebase origin master
git push -u origin master
exit 0