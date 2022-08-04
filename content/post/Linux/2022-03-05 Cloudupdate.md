---
title: Nextcloud update
author: Jiannan Zhang
date: '2022-03-05'
slug: Nextcloud
categories:
  - R
  - Linux
tags:
  - Nextcloud
subtitle: ''
summary: ''
authors: []
lastmod: '2022-03-05T21:14:49+08:00'
featured: false
image:
  caption: ''
  focal_point: ''
  placement: 
  preview_only: false
projects: []
# Is this an unpublished draft?
draft: false
---
本来是紧张的写本子时节，其实也是，不过看的头大了，图也不想改了...但是时间越来越少了...那还写啥Blog...滚回去改本子...

但是，Nextcloud成为日常最高频的软件了，已经很久很久没有更新了，还是21版本，现在都23了，所以还是需要升级换代了，今天周六，不打羽毛球了，就把这个时间利用起来更新下nextcloud...开始挖坑和填坑之旅~~

仍然是以前的docker-compose进行升级

首先我直接从21升级到23版本，完全不行，跳版本更新是禁止的，需要重新修改php文件，我懒，就升级2次...其实就是不会...不学...不练...(后面升级发现最好先把config文件清空，再补充，不然也会出错)

```shell

#更新源
sudo nano /etc/docker/daemon.json #新建文件输入下面内容

{
    "registry-mirrors":[
        "http://hub-mirror.c.163.com",
        "https://docker.mirrors.ustc.edu.cn"
    ]
}

sudo systemctl daemon-reload #重载
sudo systemctl restart docker #重启

#升级容器的程序 不修改yml文件
sudo docker ps -a
sudo docker-compose stop
sudo docker rm 容器ID
sudo docker-compose pull 
#修改yml文件版本到最新，或者默认就是最新的，作者修改了源：ghcr.io/wonderfall/nextcloud:latesd
#volumes:
      #- /data/nextcloud/data:/data
      #- /data/nextcloud/config:/nextcloud/config
      #- /data/nextcloud/apps:/nextcloud/apps2
      #- /data/nextcloud/themes:/nextcloud/themes
sudo docker-compose up -d

#我在之前设定中修改了其他设定，有没有自己重新设置过，所以把之前的设置重新修订下，进入nextcloud即可

#非网页版更新apps，网页出现修复的按照建议修改即可。
sudo docker exec -it 容器ID /bin/sh
occ upgrade 

#不进入docker直接更新apps的代码
sudo docker exec -ti nextcloud_web occ upgrade
```

走了些许弯路，进入nextcloud容器不是 `/bin/bash`而是修改成 `/bash/sh`，你敢信！！

很多APP都升级了，不少优秀的改动，所以还是要升级啊，差不多以后一年升级2次吧~

## 哎，onlyoffcie也出错了

最后发现就是remote少了个e，哎...

顺便记录下修改字体：

```shell
sudo docker exec -it 5fbb8bcd62fe /bin/bash #进入onlyoffice 
cd /var/www/onlyoffice/documentserver/core-fonts #进入字体文件夹，全部删除

#容器之外操作
sudo docker cp /data/nextcloud/fonts/* 5fbb8bcd62fe:/var/www/onlyoffice/documentserver/core-fonts/ #这样不易丢失字体

/usr/bin/documentserver-generate-allfonts.sh #重新载入字体操作

sudo docker restart 5fbb8bcd62fe #重启容器
```

换成常用的字体，字体库就放网盘公共资料里面了，减少载入时间，其实这次升级就发现速度比之前快了非常多，nice~所以还是需要及时更新和备份的。
