---
title: Shiny Server
author: ZJN
date: '2020-03-11'
slug: shiny-server
categories:
  - R
tags:
  - Academic
  - Shiny
subtitle: ''
summary: ''
authors: []
lastmod: '2020-03-11T22:44:39+08:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

## 单细胞数据展示

最近一段时间，实验室测了不少单细胞数据，为了方便实验室成员预览数据和调用数据，之前利用Shiny在服务器后台运行`Rscript XX.R`进行数据在线展示，但是现在一下子增加很多数据，就开始考虑部署服务器版的Shiny Server了。未发表数据肯定不能托管，而且数据量也较大，VPS那点能力也hold不了，最后决定在自己服务器上面部署。

### 需求：单细胞数据实验室内部展示

### 下载安装Shiny Server

[官网安装](https://rstudio.com/products/shiny/shiny-server/)服务器版本，参考官网步骤即可，提前安装好`R`和`shiny`等包。

``` r
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.13.944-amd64.deb
sudo gdebi shiny-server-1.5.13.944-amd64.deb
```

### 软件参数调试

``` R
#打开配置文件，直接在VScode中打开编辑即可。  
大赞VScode！！！！！！VScode YES！！！！！

/etc/shiny-server/shiny-server.conf

# Instruct Shiny Server to run applications as the user "shiny"
# 我改成了自己的账户，不需要新建立一个"shiny"用户
run_as 自己的用户名;

access_log /var/log/shiny-server/access.log default;  # 增加记录访问
preserve_logs true;                                   # 禁止自动清除日志

# Define a server that listens on port 3838
# 中国人喜欢的8888，哈哈哈~~
server {
  listen 8888;

  # Define a location at the base URL
  location / {

    # Host the directory of Shiny Apps stored in this directory
    site_dir /srv/shiny-server;

    # Log all Shiny output to files in this directory
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;
  }
    #指向app.R代码位置
    location /demo1{                     #/demo1 访问app.R的网址后缀
        app_dir /home/uu/shinyapp/demo1; #app.R所在文件夹
        log_dir /var/log/shiny-server/demo1;#app.R日志所在文件夹
    }

#重启服务器
sudo systemctl restart shiny-server

#应用启动失败，一般是依赖包问题，好好查看报错信息
#日志
sudo cat /var/log/shiny-server/demo/
#重启
sudo systemctl restart shiny-server;
#文件配置
sudo vim /etc/shiny-server/shiny-server.conf
```

### 服务器相关代码，官网文档，不用再去翻官网了~~

To start or stop the server manually, you can use the following commands.

``` R
sudo systemctl start shiny-server
sudo systemctl stop shiny-server
```

You can restart the server with:

``` R
sudo systemctl restart shiny-server
```

This command will shutdown all running Shiny processes, disconnect all open connections, and re-initialize the server.

If you wish to reload the configuration but keep the server and all Shiny processes running without interruption, you can use the systemctl command to send a SIGHUP signal:

``` R
sudo systemctl kill -s HUP --kill-who=main shiny-server
```

This will cause the server to re-initialize, but will not interrupt the current processes or any of the open connections to the server.

You can check the status of the shiny-server service using:

``` R
sudo systemctl status shiny-server
```

And finally, you can use the enable/disable commands to control whether Shiny Server should be run automatically at boot time:

``` R
sudo systemctl enable shiny-server
sudo systemctl disable shiny-server
```

### Shiny单独运行的代码备存

``` r
#! /usr/bin/env Rscript

setwd("/home/labwang/Rstudio")

options(repos=structure(c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/")))

library(shiny)
library(shinymanager)
runApp('/home/labwang/Rstudio/liver', port = 8887)
```

### 页面调试

确定代码没错，网页正常打开后，`index.html`就根据自己的水平进行修改美化了，我就不停的删删删删了~~

### ~~参考资料~~