---
title: Rstudio-server 相关汇总
author: Jiannan Zhang
date: '2020-04-08'
slug: rstudio-server-相关汇总
categories:
  - Linux
tags:
  - Linux
subtitle: ''
summary: ''
authors: []
lastmod: '2020-04-08T12:53:18+08:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

预期准备再入一个阿里云的CES做在线服务器，虽然买一个新的高性能服务器可能更理想，但是想着懒得维护另外一台服务器了，不如现在开始利用云服务，说不定以后有钱了在云上玩高性能服务器呢~~

下面就记录Rstudio server相关信息，持续更新~~

总的来说，信息是不断进步的，在随时关注官网等资源的同时，自己记录一些基本的操作，省去google的时间也是极好的，note就该发挥自己的作用~~

### 基本代码

``` shell
#查看是否安装正确
sudo rstudio-server verify-installation
## 启动
sudo rstudio-server start
## 查看状态
sudo rstudio-server status
## 停止
sudo rstudio-server stop
## 重启
sudo rstudio-server restart
## 查看服务端ip地址
ifconfig
```

### 卸载软件

``` shell
# 安装的信息还是直接去官网安装最新版本
sudo apt-get autoremove --purge rstudio-server
```

### 添加用户

``` shell
# 添加用户的命令是linux中的命令
# 添加用户组
groupadd Rstudiosrv
# 添加用户wdmd 在指定的组Rstudiosrv内
useradd zjn -g Rstudiosrv;
# 设置该用户的密码
passwd zjn
# 删除用户和组
userdel zjn
groupdel Rstudiosrv
# 显示用户信息
id user
cat /etc/passwd
```

### 修改端口 and 防火墙，写下来就不用翻onenote或者google了，都在自己的note里面。

``` shell
# 给 RStudio 分配访问端口
echo "www-port=8181" | sudo tee -a  /etc/rstudio/rserver.conf

# 将 R 软件路径告诉 RStudio Server，看情况设置
echo "rsession-which-r=/usr/local/bin/R-devel" | sudo tee -a /etc/rstudio/rserver.conf

# 安装 firewalld 防火墙管理工具
sudo apt-get install -y firewalld

# 查看端口情况
firewall-cmd --list-ports

# 打开8181端口
sudo firewall-cmd --zone=public --add-port=8181/tcp --permanent

# 重启防火墙使配置生效
sudo firewall-cmd --reload

# 重启你懂的
sudo rstudio-server restart
```

### 请合理利用Rstudio和github的关联功能，比如创建带版本控制的project

---

### 服务器安装R等相关

安装最新的 Git 和 libgit2-dev 库，所以添加两个源

``` shell
sudo add-apt-repository -y ppa:jeroen/libgit2
sudo add-apt-repository -y ppa:git-core/ppa

# 移除
sudo add-apt-repository --remove ppa:jeroen/libgit2
```

#### 解决系统依赖问题，重点，将r-base-dev 所需的依赖全部装上，有了 build-dep 就不用一个一个去找了

``` shell
# Ubuntu
sudo apt-get update && sudo apt-get build-dep r-base-dev
# Fedora
sudo dnf update && sudo dnf builddep R-devel
# CentOS
sudo yum update && sudo yum install -y yum-utils && sudo yum-builddep R-devel
```

其它的系统依赖，供常用的 R 包安装使用，常用的 R 包有 xml2、ssl、git2r、curl、openssl、magick、nloptr、igraph、RcppGSL。来来来，空间大的都装上~ 其实，最好还是安装错误提示缺啥安装啥比较好~

``` shell
sudo apt-get install -y libxml2-dev libssl-dev libgit2-dev \
  libnlopt-dev libxmu-dev libglpk-dev libgsl-dev \
  ghostscript imagemagick optipng subversion jags \
  libcurl4-openssl-dev libmagick++-dev \
  texlive-xetex texlive-lang-chinese
```

## 参考资料

* [从源码安装最新的开发版R](https://www.xiangyunhuang.com.cn/2019/05/r-devel-ubuntu/)

未完待续...