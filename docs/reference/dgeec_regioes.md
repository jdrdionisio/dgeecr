# Catalogo de regioes do portal

Devolve a lista de regioes aceites em `regioes=` por
[DgeecClient](https://jdrdionisio.github.io/dgeecr/reference/DgeecClient.md)`$dados()`,
com o codigo e o nome, para nao ser necessario conhecer os codigos.

## Usage

``` r
dgeec_regioes(pagina = "pre_escolar", timeout = 45L)
```

## Arguments

- pagina:

  Pagina de onde ler a lista (o catalogo e igual em todas as paginas;
  ver
  [`dgeec_paginas()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_paginas.md)).
  Por omissao `"pre_escolar"`.

- timeout:

  Timeout por pedido, em segundos.

## Value

Um `tibble` com `regiao_codigo`, `regiao_nome`, `regiao_tipo` e
`regiao_nivel` (0 = Portugal e NUTS I, 1 = NUTS II, 2 = NUTS III, 3 =
municipio).

## Examples

``` r
# \donttest{
dgeec_regioes()
#> # A tibble: 340 × 4
#>    regiao_codigo regiao_nome                regiao_tipo regiao_nivel
#>    <chr>         <chr>                      <chr>              <int>
#>  1 1             Continente                 NUTS I                 0
#>  2 0             Portugal                   Portugal               0
#>  3 3             Região Autónoma da Madeira NUTS I                 0
#>  4 2             Região Autónoma dos Açores NUTS I                 0
#>  5 106           Alentejo                   NUTS II                1
#>  6 107           Algarve                    NUTS II                1
#>  7 102           Centro                     NUTS II                1
#>  8 104           Grande Lisboa              NUTS II                1
#>  9 101           Norte                      NUTS II                1
#> 10 103           Oeste e Vale do Tejo       NUTS II                1
#> # ℹ 330 more rows
dgeec_regioes() |> subset(regiao_tipo == "Municipio")
#> # A tibble: 0 × 4
#> # ℹ 4 variables: regiao_codigo <chr>, regiao_nome <chr>, regiao_tipo <chr>,
#> #   regiao_nivel <int>
# }
```
