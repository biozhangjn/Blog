library(blogdown)
library(bookdown)
library("biomaRt")
library(org.Gg.eg.db)
library(org.Hs.eg.db)
library(clusterProfiler)
library(DOSE)

languageserver

rm(list = ls())

setwd("D:\\OneDrive\\git\\MyBlog\\")
options(repos=structure(c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))) 

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install(c("org.Hs.eg.db","clusterProfiler","DOSE"))

BiocManager::install("rvcheck")
ninstall.packages("shiny")
install.packages('blogdown') 
blogdown::install_hugo()

#blogdown::new_site(theme = 'gcushen/hugo-academic')
#blogdown::hugo_version()
blogdown::new_post()
blogdown::hugo_build()
blogdown::serve_site()


ssh-keygen -t rsa -b 4096 -C "$(git config user.email)" -f gh-pages -N ""

ssh-keygen -t rsa -b 4096 -C "bio_zhang@msn.com" -f gh-pages

git init
git add .
git commit -m 'Blog update'
git remote add origin git@github.com:biozhangjn/Blog.git
git pull --rebase origin master
git push -u origin master



<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-162031575-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-162031575-1');
</script>
