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
docker exec -u 0 -it 容器id /bin/bash
docker exec -it 容器id /bin/bash
```

## 自建`collabora`服务器

哈哈，查了下资料，搞定`Docker`自建`collabora`了，神器，代码把上面的添加进去，然后打开服务器和VPS对应的端口，添加frp，然后你安装`Collabora Online`插件，接着在设置里面找到在线协作， 在`URL (and Port) of Collabora Online-server`里面配置`http://<your-ip>:9980/`，然后你的网盘就可以进行office系列操作了，SVEN这下NB了~~

### 那个，内测用户反馈意见赶紧处理下~

刚把网盘建立好，天花乱坠的吹嘘一通好处，让师弟成功加入，成为全新高级内测无限量空间用户，结果，打脸就是来得如此的快，这个`word`怎么网页不能协作编辑呢，`WOPI`权限是什么鬼...

用户一句话，编程一整天...

赶紧去`google`啊，重新安装`Docker`啥的，乱七八糟折腾了几遍，还是GG。果然用别人的轮子多好，非要自己折腾干嘛，腾讯文档不香吗？`OneDrive`不香吗？

省略一番折腾的过程，最终解决了，还是要去看英文文档和解决方案，中文资料那帮人大多还是只是个过时信息的搬运工，为啥每次都不信呢，自己看[英文文档](https://fribeiro.org/post/2018-12-19-collabora-nextcloud-15/)也很easy啊，浪费那么个时间干嘛...

问题的关键在于我没有`SSL`认证，还是`http`不安全链接，也没有对外网域名授权，那肯定不能访问我的`office online`服务器，所以最后的解决办法也不是去折腾`https`那些反向代理，会出人命的，我只是一个想建网盘的生物实验搬砖员，又不是搞IT的，所以直接进入`Collabora`里面去修改域名信任就好了，其实和`nextcloud`的操作类似。

``` SHELL
#以管理员身份进入Docker进行设置
docker exec -u 0 -it 你的容器ID /bin/bash
apt-get update #不更新安装不了nano
apt-get install nano
nano /etc/loolwsd/loolwsd.xml
```

然后在文档里面设置域名，记得反斜杠注释.号，保存重启Docker就ok了。

``` SHELL
File: /etc/loolwsd/loolwsd.xml
# [...]
    <storage desc="Backend storage">
        <filesystem allow="false" />
        <wopi desc="Allow/deny wopi storage. Mutually exclusive with webdav." allow="true">
            <host desc="Regex pattern of hostname to allow or deny." allow="true">localhost</host>
            <host desc="Regex pattern of hostname to allow or deny." allow="true">cloud\.example\.com</host>
# [...]
```

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

然后就可以开启你的私人网盘之旅了，发现安装MySQL之后初始下载速度慢了不少，当然速度会慢慢升起来，回头再学习下哪里出问题了，应该还有很多继续优化的策略，再说吧...其实还折腾了下文档协作处理，但是有腾讯文档这些专业的了，目前也没时间折腾了（最后还是忍不住折腾了，然后补充了相关坑），等待下一个学习期吧，单细胞的数据需要赶紧上传到NCBI了，还折腾这些干嘛...做正事去啦~~~
