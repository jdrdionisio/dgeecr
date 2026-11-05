# Enriquece dados DGEEC com divisoes administrativas e de saude

Liga as linhas de nivel "Municipio" ao ficheiro de ligacao geografica e
acrescenta `uls_1`, `uls_2`, `uls_principal`, `n_uls`, `regiao_2024`,
`nuts1`, `nuts2`, `nuts3`, `aces_2022` e `ars_2022`. Municipios com
varias ULS (Lisboa, Porto, Gondomar, Loures, Funchal) ficam com
`uls_1`/`uls_2`.

## Uso

``` r
enriquecer_geo(dados, geo = NULL)
```

## Argumentos

- dados:

  Um `tibble` produzido por
  [DgeecClient](https://jdrdionisio.github.io/dgeecr/reference/DgeecClient.md)`$dados()`
  /
  [`dgeec_dados()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_dados.md),
  com as colunas `regiao_codigo`, `regiao_nome` e `regiao_tipo`.

- geo:

  Tabela de ligacao (por omissao
  [`dgeec_geo()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_geo.md)).

## Valor

`dados` com as colunas geograficas acrescentadas.
