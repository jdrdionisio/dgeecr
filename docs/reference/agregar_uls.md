# Agrega dados ao nivel da ULS

Soma os valores dos municipios pertencentes a cada ULS.

## Usage

``` r
agregar_uls(dados, geo = NULL, multiplas = c("excluir", "duplicar", "maior"))
```

## Arguments

- dados:

  `tibble` de
  [DgeecClient](https://jdrdionisio.github.io/dgeecr/reference/DgeecClient.md)`$dados()`.

- geo:

  Tabela de ligacao (por omissao
  [`dgeec_geo()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_geo.md)).

- multiplas:

  Como tratar os municipios repartidos por varias ULS (Lisboa, Porto,
  Gondomar, Loures, Funchal), cujos dados o portal so publica ao nivel
  do municipio: `"excluir"` (por omissao) remove-os da soma e lista-os
  no atributo `municipios_excluidos`; `"duplicar"` atribui o valor a
  cada ULS (dupla contagem); `"maior"` atribui a ULS com mais
  freguesias.

## Value

Um `tibble` ao nivel da ULS (+ atributo `municipios_excluidos`).
