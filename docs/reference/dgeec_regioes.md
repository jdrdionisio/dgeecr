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
if (FALSE) { # \dontrun{
# requer acesso a Internet
dgeec_regioes()
dgeec_regioes() |> subset(regiao_nivel == 3)   # so municipios
} # }
```
