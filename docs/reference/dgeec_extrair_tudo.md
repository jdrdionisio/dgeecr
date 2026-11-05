# Extrair e exportar todas as paginas

Percorre o catalogo, extrai cada pagina e escreve os formatos pedidos.

## Usage

``` r
dgeec_extrair_tudo(
  dir,
  paginas = NULL,
  formatos = c("csv", "parquet"),
  cliente = NULL,
  ...
)
```

## Arguments

- dir:

  Pasta de saida.

- paginas:

  Vetor de ids (NULL = todas).

- formatos:

  Formatos a escrever (ver
  [`dgeec_exportar()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_exportar.md)).

- cliente:

  Um
  [DgeecClient](https://jdrdionisio.github.io/dgeecr/reference/DgeecClient.md).
  Se NULL, cria um.

- ...:

  Argumentos passados a `cliente$dados()`.

## Value

(invisivelmente) um `tibble` com `pagina` e `ficheiro`.
