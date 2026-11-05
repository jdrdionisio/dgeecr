# Dimensoes (filtros) de uma pagina

Le a pagina do portal e devolve os valores possiveis de cada `<select>`,
com o respetivo nivel hierarquico (no caso das regioes).

## Uso

``` r
dgeec_dimensoes(pagina, timeout = 45L)
```

## Argumentos

- pagina:

  Id de pagina (ver
  [`dgeec_paginas()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_paginas.md))
  ou o respetivo `path`.

- timeout:

  Timeout por pedido, em segundos.

## Valor

Um `tibble` com `select`, `codigo`, `rotulo` e `nivel`.

## Exemplos

``` r
if (FALSE) { # \dontrun{
# requer acesso a Internet
dgeec_dimensoes("pre_escolar")
} # }
```
