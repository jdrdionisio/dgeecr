# Tamanho do cache em disco

Tamanho do cache em disco

## Usage

``` r
dgeec_tamanho_cache(dir = NULL)
```

## Arguments

- dir:

  Pasta de cache (NULL =
  [`dgeec_cache_dir()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_cache_dir.md)).

## Value

Um `tibble` por pagina (ou `"(outros)"`), com `n_ficheiros`, `bytes` e
`mb`, mais o total em atributo `total`.
