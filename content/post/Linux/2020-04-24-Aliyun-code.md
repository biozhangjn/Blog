---
title: 阿里云服务新配置代码备存
author: Jiannan Zhang
date: '2020-04-24'
slug: 阿里云服务新配置代码备存
categories:
  - R
  - Linux
tags:
  - Academic
  - Linux
  - RNA-seq
subtitle: ''
summary: ''
authors: []
lastmod: '2020-04-24T22:34:49+08:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

新添了[阿里云服务器](https://www.aliyun.com/minisite/goods?userCode=tjxor43i)，超级推荐云翼计划，学生能享受的优惠真的很赞，可惜我没有机会了，只有等双11的活动了，点击链接进去即可选购~~

主要是为了解决frp走国外服务器的延迟问题，同时为实验室数据分享网址的建立练手，当然以后肯定还会有很多购新的事件，因此这里记录下相关代码和备注事项，方便以后的操作：

## SSH登陆

~~垃圾~~[阿里云](https://www.aliyun.com/minisite/goods?userCode=tjxor43i)，操作复杂，事项繁多，比Vutlr的界面复杂太多了，不过安全性上面确实可能要高一些，新手直接劝退吧，不过新手也不会上来就买CES，或者买来就是练手的，我就是新手，差点被劝退了~~~

首先重置密码，即设置新密码，为什么不能随机给个默认的，要这么麻烦，吐槽+1......
然后在安全组界面添加密钥，默认只能通过密钥登陆，安全性提高，然后记得重启CES，随便啥远程登陆进去~再次前排推荐`Visual Studio Code`！！！

## 虚拟内存

由于开启swap分区会导致硬盘IO性能下降，因此[阿里云服务器](https://www.aliyun.com/minisite/goods?userCode=tjxor43i)初始状态未配置swap，如果某些应用需要开启swap分区，自己设置即可。~~小鸡的烦恼，土豪随意~~

``` SHELL
sudo dd if=/dev/zero of=swapfile bs=1024 count=2048000
sudo mkswap -f swapfile
chmod 0600 swapfile
sudo swapon swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab #学到么？下面还有类似操作喔~
shutdown -r now #重启看下free
```

## R, Shiny and Rstudio

### [R install](https://cran.r-project.org/bin/linux/ubuntu/README.html)

``` SHELL
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
#根据系统选择合适的软件包，不确定记得去官网查看下最新记录
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran35/'
sudo add-apt-repository 'deb https://mirrors.tuna.tsinghua.edu.cn/CRAN/bin/linux/ubuntu bionic-cran35/'
sudo apt-get update
sudo apt-get install r-base
sudo apt-get install r-base-dev
sudo -i R
```

### [Rstudio server](https://rstudio.com/products/rstudio/download-server/debian-ubuntu/)

`116.62.102.124`

``` SHELL
# 视系统不同选择有差异，这里是ubuntu 18.04
sudo apt-get install gdebi-core
wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-1.2.5033-amd64.deb
sudo gdebi rstudio-server-1.2.5033-amd64.deb

echo "www-port=8787" | sudo tee -a  /etc/rstudio/rserver.conf #熟悉么~~

#查看是否安装正确
sudo rstudio-server verify-installation
#启动
sudo rstudio-server start
#查看状态
sudo rstudio-server status
#停止
sudo rstudio-server stop
#重启
sudo rstudio-server restart
#查看服务端ip地址
ifconfig
```

### Adduser

``` SHELL
sudo adduser zhangjn
usermod -aG sudo zhangjn
su zhangjn

# test the root privileges
sudo ls -la /root

# change password
passwd zhangjn

# copy ssh file and directory structure to  new user account in  existing session
rsync --archive --chown=zhangjn:zhangjn ~/.ssh /home/zhangjn
```

### [Shiny server](https://rstudio.com/products/shiny/download-server/ubuntu/)

``` SHELL
#  install the Shiny R package
sudo su - \
-c "R -e \"install.packages('shiny', repos='https://cran.rstudio.com/')\""

sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.13.944-amd64.deb
sudo gdebi shiny-server-1.5.13.944-amd64.deb
```

[Change user](https://www.zhangjn.xyz/post/shiny-server/)

``` SHELL
nano /etc/shiny-server/shiny-server.conf
```

Restart Shiny Server Pro so that the activated version will get started.

``` SHELL
sudo systemctl restart shiny-server
```

### Install Seurat package in Rstudio

``` SHELL
# Problem installing R packages that depends from "OpenSSL" library
sudo apt-get install libssl-dev

# Problem installing R packages that depends from "httr" library
sudo apt-get install libcurl4-openssl-dev

# Problem installing R packages that depends from "metap" library
# install package using BiocManager
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("multtest")
BiocManager::install("metap")
```

### [Configuring nginx on your server](https://support.rstudio.com/hc/en-us/articles/213733868-Running-Shiny-Server-with-a-Proxy)

``` SHELL

sudo apt-get -y install nginx

# make a backup of the nginx configuration
sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default-backup

# 配置自己摸索下
sudo nano /etc/nginx/sites-enabled/default

```

### `acme.sh` and `ssl`

``` SHELL
curl https://get.acme.sh | sh

# You’ll need to generate an API key at https://www.namesilo.com/account_api.php 
# Optionally you may restrict the access to an IP range there.
# for namesilo ssl

export Namesilo_Key="XXXXXXXXXXXXX"

~/.acme.sh/acme.sh --issue --dns dns_namesilo --dnssleep 2500 -d scrna.zhangjn.xyz

~/.acme.sh/acme.sh --issue --dns dns_namesilo --dnssleep 2500 -d shiny.zhangjn.xyz

~/.acme.sh/acme.sh  --installcert  -d  shiny.zhangjn.xyz   \
        --key-file   /etc/nginx/ssl/shiny.zhangjn.xyz.key \
        --fullchain-file /etc/nginx/ssl/fullchain.cer \
        --fullchain-file /etc/nginx/ssl/ca.cer \
        --reloadcmd  "systemctl restart nginx.service"   

`TLSv1`证书会导致不安全，记得修改下。

# for aliyun ssl

export Ali_Key="XXXXXXXXXXXXXXXX"
export Ali_Secret="XXXXXXXXXXXXXXXXXXXX"

~/.acme.sh/acme.sh --issue --dns dns_ali -d avianscu.com -d scrna.avianscu.com 

~/.acme.sh/acme.sh  --installcert  -d  avianscu.com   \
        --key-file   /etc/nginx/ssl2/avianscu.com.key \
        --fullchain-file /etc/nginx/ssl2/fullchain.cer \
        --reloadcmd  "systemctl restart nginx.service" 
```

## [Frp设置](https://github.com/fatedier/frp/blob/master/README_zh.md)

``` shell
# install
wget https://github.com/fatedier/frp/releases/download/v0.22.0/frp_0.22.0_linux_amd64.tar.gz

tar -zxvf frp_0.22.0_linux_amd64.tar.gz

# 设置frp服务的系统自启动等操作，很方便，frps和frpc注意切换

sudo nano /lib/systemd/system/frps.service

# 在frps.service里写入以下内容
[Unit]
Description=frps service
After=network.target syslog.target
Wants=network.target
[Service]
Type=simple
# 启动服务的命令（此处写你的frps的实际安装目录）
ExecStart=/root/soft/frp_0.32.1_linux_amd64/frps -c /root/soft/frp_0.32.1_linux_amd64/frps.ini
#ExecStart=/home/ubuntu/soft/frp_0.32.1_linux_amd64/frps -c /home/ubuntu/soft/frp_0.32.1_linux_amd64/frps.ini
[Install]
WantedBy=multi-user.target

# Ubuntu设置frp的系统控制
sudo systemctl start frps
sudo systemctl enable frps
sudo systemctl restart frps
sudo systemctl stop frps
sudo systemctl status frps

# 多个服务端连接同一个客户端，小技巧喔
./frpc -c ./frpc1.ini
./frpc -c ./frpc2.ini
./frpc -c ./frpc3.ini
