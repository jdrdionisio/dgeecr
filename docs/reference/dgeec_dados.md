# Extrair dados de uma pagina (atalho)

Cria um
[DgeecClient](https://jdrdionisio.github.io/dgeecr/reference/DgeecClient.md)
e extrai os dados de uma pagina.

## Uso

``` r
dgeec_dados(pagina, ..., cliente = NULL)
```

## Argumentos

- pagina:

  Id de pagina (ver
  [`dgeec_paginas()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_paginas.md)).

- ...:

  Argumentos passados a `DgeecClient$dados()` (p.ex. `regioes`,
  `natureza`, `incluir_totais`).

- cliente:

  Um
  [DgeecClient](https://jdrdionisio.github.io/dgeecr/reference/DgeecClient.md)
  opcional.

## Valor

Um `tibble` longo.

## Exemplos

``` r
if (FALSE) { # \dontrun{
# requer acesso a Internet
dgeec_dados("pre_escolar", regioes = "Portugal")
} # }
```
