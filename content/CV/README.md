## My pagedown rendered CV

This repo contains the source-code and results of my CV built with the [pagedown package](https://pagedown.rbind.io) and a modified version of the 'resume' template. 

The main files are modified by Y叔:

- `index.Rmd`: Source template for the cv, contains a variable `PDF_EXPORT` in the header that changes styles for pdf vs html. 
- `index.html`: The final output of the template when the header variable `PDF_EXPORT` is set to `FALSE`. View it at [biozhangjn.github.io/cv](http://biozhangjn.github.io/cv).
- `Jiannan Zhang’s CV.pdf`: The final exported pdf. 
- `positions.csv`: A csv with columns encoding the various fields needed for a position entry in the CV. A column `section` is also available so different sections know which rows to use.
- add `order` column in `positions.csv` to adjust item order.
- remove `time` if it is identical to previous item.

The source code was derived from https://github.com/nstrayer/cv and https://github.com/GuangchuangYu/cv, with modifications:

Inside the styles.css

```
.pagedjs_page:not(:first-of-type) {
  --sidebar-width: 0rem;
  --sidebar-background-color: #ffffff;
  --main-width: calc(var(--content-width) - var(--sidebar-width));
  --decorator-horizontal-margin: 0.2in;
}
```

This trunk is to make only the first page has a side-bar and the rest of the page fill in the whole page.
see https://community.rstudio.com/t/pagedown-html-resume-with-aside-on-first-page-only/46351