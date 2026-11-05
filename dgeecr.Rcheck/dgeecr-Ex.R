pkgname <- "dgeecr"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('dgeecr')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("DgeecClient")
### * DgeecClient

flush(stderr()); flush(stdout())

### Name: DgeecClient
### Title: Cliente DGEEC
### Aliases: DgeecClient

### ** Examples




cleanEx()
nameEx("dgeec_dados")
### * dgeec_dados

flush(stderr()); flush(stdout())

### Name: dgeec_dados
### Title: Extrair dados de uma pagina (atalho)
### Aliases: dgeec_dados

### ** Examples




cleanEx()
nameEx("dgeec_dimensoes")
### * dgeec_dimensoes

flush(stderr()); flush(stdout())

### Name: dgeec_dimensoes
### Title: Dimensoes (filtros) de uma pagina
### Aliases: dgeec_dimensoes

### ** Examples




cleanEx()
nameEx("dgeec_paginas")
### * dgeec_paginas

flush(stderr()); flush(stdout())

### Name: dgeec_paginas
### Title: Catalogo de paginas disponiveis
### Aliases: dgeec_paginas

### ** Examples

dgeec_paginas()



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
