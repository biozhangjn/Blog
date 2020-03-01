library(blogdown)
library(bookdown)

languageserver

rm(list = ls())

setwd("D:\\OneDrive\\git\\MyBlog\\")
options(repos=structure(c(CRAN="https://mirrors.tuna.tsinghua.edu.cn/CRAN/"))) 

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("MAST")

BiocManager::install("multtest")
install.packages("MAST")
install.packages('bookdown') 
blogdown::install_hugo()

blogdown::new_site(theme = 'gcushen/hugo-academic')

blogdown::hugo_build()

blogdown::hugo_version()

ssh-keygen -t rsa -b 4096 -C "$(git config user.email)" -f gh-pages -N ""

ssh-keygen -t rsa -b 4096 -C "bio_zhang@msn.com" -f gh-pages

git commit -m "Blog update"
git remote add origin https://github.com/biozhangjn/Blog/
git remote -v
git pull origin master --allow-unrelated-histories
git push -u origin master