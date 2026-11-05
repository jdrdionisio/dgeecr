# Tabela de ligacao municipio -\> divisoes administrativas e de saude

Le o ficheiro de ligacao geografica incluido no pacote
(`inst/extdata/geo_linkage_2024_v8.csv`) e agrega-o ao nivel do
municipio, resolvendo as ULS que dividem um municipio ao nivel da
freguesia em `uls_1` e `uls_2`.

## Usage

``` r
dgeec_geo(path = NULL)
```

## Arguments

- path:

  Caminho alternativo para o CSV de ligacao.

## Value

Um `tibble` por municipio, com `uls_1`, `uls_2`, `n_uls`, `uls_todas`,
`uls_principal` (ULS com mais freguesias), `regiao_2024`, `nuts1`,
`nuts2`, `nuts3`, `aces_2022`, `ars_2022` e `freguesias`.
