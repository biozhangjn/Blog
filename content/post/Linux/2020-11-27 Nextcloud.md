---
title: Nextcloud+Docker设置
author: Jiannan Zhang
date: '2020-11-08'
slug: Nextcloud
categories:
  - Linux
tags:
  - Linux
subtitle: ''
summary: ''
authors: []
lastmod: '2020-11-27T22:34:49+08:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

**Nextcloud**已经在新的腾讯云服务器安装使用了，加上手机客户端，高带宽的私人网盘确实很赞，但是50G的总空间还是不行的，毕竟也是拥有私人服务器的人，弄个frp穿透就搞定了...

理论上确实很简单，但是实际操作中问题就来了，准备供实验室多用户使用，数据库最好换MySQL，但是，我不会啊...所以感觉学习了下，2天就没了...不过也学到了`docker-compose`的用法，挺好的，之前更新的时候就是没学会，现在算是明白了这个的好处，一次设置，终身方便，尤其是更新的时候！

具体流程方法如下：

## 安装`docker-compose`和`nextcloud`及`mariadb`镜像

``` SHELL
apt install docker-compose
docker pull wonderfall/nextcloud #体积更小的nextcloud
docker pull mariadb
```

## 创建docker-compose文件并运行

我会将`nextcloud`的数据放到大硬盘，所以在外挂硬盘而不是系统盘里面新建了`nextcloud`文件夹，在该文件夹里面新建`docker-compose.yml`文件，输入设置内容：

``` R
version: '3'

services:
  nextcloud:
    image: wonderfall/nextcloud
    container_name: nextcloud_web
    depends_on:
      - nextcloud-db           # If using MySQL
    environment:
      - UID=1000
      - GID=1000
      - UPLOAD_MAX_SIZE=10G
      - APC_SHM_SIZE=128M
      - OPCACHE_MEM_SIZE=128
      - MEMORY_LIMIT=5120M
      - CRON_MEMORY_LIMIT=5120M
      - CRON_PERIOD=15m
      - TZ=Aisa/Shanghai
      - ADMIN_USER=你的管理员用户名
      - ADMIN_PASSWORD=管理员用户名密码
      - DOMAIN=localhost
      - DB_TYPE=mysql
      - DB_NAME=nextcloud
      - DB_USER=nextcloud
      - DB_PASSWORD=数据库密码
      - DB_HOST=nextcloud-db
    volumes:
      - /你的目录/nextcloud/data:/data
      - /你的目录/nextcloud/config:/config
      - /你的目录/nextcloud/apps:/apps2
      - /你的目录/nextcloud/themes:/nextcloud/themes 
      #将Docker里面的文件映射到硬盘空间，config映射出来后修改参数非常方便
    ports:
    - 0.0.0.0:你的端口:8888/tcp
    restart: always


  # If using MySQL
  nextcloud-db:
    image: mariadb
    container_name: nextcloud_db
    volumes:
      - /你的目录/nextcloud/db:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=密码
      - MYSQL_DATABASE=nextcloud
      - MYSQL_USER=nextcloud
      - MYSQL_PASSWORD=密码
    restart: always

  collabora:
        image: collabora/code
        container_name: collabora
        restart: always
        ports:
            - 9980:9980
        environment:
            - extra_params=--o:ssl.enable=false
```

``` SHELL
# 常用代码
docker-compose up -d
docker ps -a
docker logs nextcloud_db
docker logs nextcloud_web
```

## 自建`collabora`服务器

哈哈，查了下资料，搞定`Docker`自建`collabora`了，神器，代码把上面的添加进去，然后打开服务器和VPS对应的端口，添加frp，然后你安装`Collabora Online`插件，接着在设置里面找到在线协作， 在`URL (and Port) of Collabora Online-server`里面配置`http://<your-ip>:9980/`，然后你的网盘就可以进行office系列操作了，SVEN这下NB了~~

## 域名信任设置

frp的设置就是之前一样，端口到端口的连接，同时域名和服务器IP进行绑定，但是网页提示该ip不安全，需要在config.php中加入域名信任，刚开始折腾这个还要进入容器，超级麻烦，还是这种设置好了的更方便~~

打开到/你的目录/nextcloud/config目录

``` SHELL
nano config.php

'trusted_domains' =>
   array (
          0 => 'localhost',
          1 => '<你的IP或者域名>',
   ),
```

然后就可以开启你的私人网盘之旅了，发现安装MySQL之后初始下载速度慢了不少，当时速度会慢慢升起来，回头再学习下那里出问题了...其实还折腾了下文档协作处理，但是有腾讯文档这些专业的了，目前也没时间折腾了，等待下一个学习期吧，单细胞的数据需要赶紧上传到NCBI了，还折腾这些干嘛...做正事去啦~~~
