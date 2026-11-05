# Introdução ao dgeecr

## Introdução

O **dgeecr** dá acesso programático aos dados do portal *“Regiões em
Números - Educação”* da DGEEC
(<https://estatisticas-educacao.dgeec.medu.pt/regioesemnumeros/>).

Cada página do portal é um formulário HTML cuja tabela é atualizada por
`POST` para a própria página, filtrando por **uma** região e **uma**
combinação de natureza/género/orientação de cada vez. O `dgeecr`
percorre o produto cartesiano de opções, em paralelo (`httr2`), guarda o
HTML em cache (com retoma) e devolve uma tabela longa em que **1 linha =
1 observação**.

## Criar um cliente

``` r
library(dgeecr)

cli <- DgeecClient$new(concorrencia = 8L)
cli
```

## Páginas e dimensões

``` r
dgeec_paginas()

cli$dimensoes("pre_escolar")
```

## Extrair dados

``` r
# Portugal + Monção, apenas o nível desagregado (Público/Privado x H/M)
d <- cli$dados("pre_escolar", regioes = c("0", "101011604"))
d

# Incluir também os totais somados ("Público e Privado", "Homens e Mulheres")
cli$dados("pre_escolar", regioes = "0", incluir_totais = TRUE)
```

## Enriquecer com divisões administrativas e de saúde

``` r
d_geo <- enriquecer_geo(d)
d_geo |> dplyr::distinct(regiao_codigo, regiao_nome, uls_1, uls_2, regiao_2024)
```

Municípios cujo território é repartido por mais de uma ULS (Lisboa,
Porto, Gondomar, Loures, Funchal) ficam com `uls_1` **e** `uls_2`
preenchidos.

## Exportar

``` r
# dgeec_exportar(d, "output/dgeec_pre_escolar", formatos = c("csv", "parquet"))
```

O CSV e o Parquet suportam o conjunto completo; o XLSX só é gerado
quando o número de linhas cabe numa aba do Excel.
