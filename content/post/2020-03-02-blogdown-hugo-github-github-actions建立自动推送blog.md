---
title: Blogdown+Hugo+Github+Github Actions建立自动推送Blog
author: Jiannan Zhang
date: '2020-03-02'
slug: blogdown-hugo-github-github-actions建立自动推送blog
categories:
  - R
tags:
  - Blog
  - R Markdown
subtitle: ''
summary: ''
authors: []
lastmod: '2020-03-02T23:21:59+08:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

## 使用 Blogdown+Hugo+Github+Github Actions博客

之前使用Hexo建了个人主页，但是速度越来越慢，而且部署比较繁琐，最近学习R相关知识，发现Rmarkdown、Bookdown和Blogdown全家桶超级好用，所以与时俱进也升级了方案。

* Blogdown可以非常方便的使用Hugo进行操作，尤其是Rstudio高度集成，非常方便。
* Hugo就不多说了，神器。
* Github也不解释，之前Hexo也是利用的Github pages作为个人主页，现在加上可以实现自动部署的Github Actions则更加方便。

整体流程建立后非常方便进行更新，速度也很快，所以非常推荐，下面简单记录下关键步骤。

## 一、建立Github Pages

本流程一共需要在Github账号里建立两个Repository，第一个是用于发布页面的仓库名必须为 [你的用户名].github.io，使用 master 分支，也是用于Github Pages的Repository，可以自定义域名，为了这个自定义域名可以用于Github系列网站，也就没有采用Blogdown的推荐流程。

## 二、建立Hugo文章仓库

为了实现自动部署，我们还需要建立一个命名随便（如MyBlog）的Repository用于储存Blog的原始文档，之后利用Github Actions自动部署推送到XXX.github.io中进行发布。

## 三、部署Github Actions 脚本

基本知识随便google就有了，利用别人的轮子，编辑yml文件，编写自己的workflow。

``` yml
name: CI #自动化的名称
on:
  push: # push的时候触发
    branches: # 那些分支需要触发
      - master
jobs:
  build:
    runs-on: ubuntu-latest # 镜像市场
    steps:
      - name: checkout # 步骤的名称
        uses: actions/checkout@v1 #软件市场的名称
        with: # 参数
          submodules: true
      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2.2.2
        with:
          hugo-version: '0.65.3'
          extended: true
      - name: Build
        run: hugo --minify
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v2.5.1
        env:
          ACTIONS_DEPLOY_KEY: ${{ secrets.ACTIONS_DEPLOY_KEY }}
          EXTERNAL_REPOSITORY: 你的用户名/你的用户名.github.io
          PUBLISH_BRANCH: master
          PUBLISH_DIR: ./public
```

> 注意替换**你的用户名**以及**hugo的版本号**。

## 四、部署工作

在VScode中的Powershell中输入密钥生成指令，提交到Github，实现两个仓库的关联，页面填写时注意修改名称为`ACTIONS_DEPLOY_KEY`。

``` shell
ssh-keygen -t rsa -b 4096 -C "$(git config user.email)" -f gh-pages -N ""
#   你会得到以下这两个文件:
#   gh-pages.pub (public key) for .github.io 发布仓库
#   gh-pages     (private key) for myBlog 储存仓库
```

## 五、提交代码自动部署

之后只需要push本地的Blog文件至储存仓库，Actions就会自动利用Hugo进行public文件编译，之后推送至github.io仓库，利用Github pages进行发布，实现全自动操作，只需要将本地文件push到储存仓库即可。

push可以写一个脚本`deploy.sh`

```shell
#!/bin/sh
# 哈哈，我把文件放置OneDrive里面的，算是备份吧，主要是换电脑可以非常方便的同步。
cd D:\OneDrive\git\MyBlog\
# 建立本地仓库
git init
# 关联到Github仓库
git remote add origin git@github.com:你的用户名/Blog.git
# 把目录下所有文件更改状况提交到暂存区
git add .
# 提交更改的说明
git commit -m "Blog update"
# 开始推送到Github
git push -u origin master
exit 0
```

>Tips：在Hugo文件content目录下新建一个CNAME文件（无任何后缀），内容为自定义域名，这样编译时会自动将CNAME文件生成至github.io根目录，不用每次部署后重新设置自定义域名。

## 六、Blogdown和Hugo建立本地文件

其实应该先写这块的，貌似这个才是重要的，不过Blogdown有一本书供参考，Hugo也是全网推荐，写多了也没有意义了，官网文档超级实用。看下面这篇[用 R 语言的 blogdown+hugo+netlify+github 建博客](https://cosx.org/2018/01/build-blog-with-blogdown-hugo-netlify-github/)就足够了，不过略有区别，托管网站的选择上，netlify可以替换为Github pages + Actions，更加方便，不需要第三方的程序实现自动部署。

下面是关键代码：（Git、Rstudio、R、VScode的安装 略）

``` r
setwd("D:\\OneDrive\\git\\MyBlog\\")
options(repos=structure(c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/")))

# 超级简单的代码-----------------------------------------
install.packages('blogdown')
blogdown::install_hugo()
# 下载太慢就自己下载再安装
#blogdown:::install_hugo_bin("d:/hugo.exe")

# 选择主题、查看hugo版本、建立新文档、本地发布文件、本地网页预览
blogdown::new_site(theme = 'gcushen/hugo-academic')
blogdown::hugo_version()
blogdown::new_post()
blogdown::hugo_build()
blogdown::serve_site()
```

其实使用Rstudio的话，上面代码都不用了，addins里面超级方便的按钮操作`New Post`、`Serve site`，同时shiny界面直接输入内容即可，非常赞的可视化操作界面。不过，我还是选择VScode + R执行blogdown代码，大爱VScode。
设置gitignore,点击.gitignore文件，修改如下（copy Yihui大神）：

``` r
.Rproj.user
.Rhistory
.RData
.Ruserdata
public
static/figures
blogdown
```

然后就可以改改改，写写写了~~

至于模板的修改，个性化的改动就看个人的能力了~~

## 七、参考资料

- [Blogdown](https://bookdown.org/yihui/blogdown/)  看完你就会尝试Bookdown了@@  
- [使用 Github Actions + Hugo + Github Pages搭建博客](https://owovo.xyz/post/%E4%BD%BF%E7%94%A8GithubActions+Hugo+GithubPages%E6%90%AD%E5%BB%BA%E5%8D%9A%E5%AE%A2.html)  
- [用 R 语言的 blogdown+hugo+netlify+github 建博客](https://cosx.org/2018/01/build-blog-with-blogdown-hugo-netlify-github/)  
- [从零开始搭建个人博客](https://gaolei.xyz/2019/08/%E4%BB%8E%E9%9B%B6%E5%BC%80%E5%A7%8B%E6%90%AD%E5%BB%BA%E4%B8%AA%E4%BA%BA%E5%8D%9A%E5%AE%A2/)  
