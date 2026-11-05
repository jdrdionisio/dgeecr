# Dimensoes (filtros) de uma pagina

Le a pagina do portal e devolve os valores possiveis de cada `<select>`,
com o respetivo nivel hierarquico (no caso das regioes).

## Usage

``` r
dgeec_dimensoes(pagina, timeout = 45L)
```

## Arguments

- pagina:

  Id de pagina (ver
  [`dgeec_paginas()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_paginas.md))
  ou o respetivo `path`.

- timeout:

  Timeout por pedido, em segundos.

## Value

Um `tibble` com `select`, `codigo`, `rotulo` e `nivel`.

## Examples

``` r
# \donttest{
dgeec_dimensoes("pre_escolar")
#> # A tibble: 346 × 5
#>    select      codigo    rotulo_raw               rotulo               nivel
#>    <chr>       <chr>     <chr>                    <chr>                <int>
#>  1 ListaRegiao 0         Portugal                 Portugal                 0
#>  2 ListaRegiao 1         NUTS I: Continente       NUTS I: Continente       0
#>  3 ListaRegiao 101         NUTS II: Norte         NUTS II: Norte           1
#>  4 ListaRegiao 10101         NUTS III: Alto Minho NUTS III: Alto Minho     2
#>  5 ListaRegiao 101011601       Arcos de Valdevez  Arcos de Valdevez        3
#>  6 ListaRegiao 101011602       Caminha            Caminha                  3
#>  7 ListaRegiao 101011603       Melgaço            Melgaço                  3
#>  8 ListaRegiao 101011604       Monção             Monção                   3
#>  9 ListaRegiao 101011605       Paredes de Coura   Paredes de Coura         3
#> 10 ListaRegiao 101011606       Ponte da Barca     Ponte da Barca           3
#> # ℹ 336 more rows
# }
```
