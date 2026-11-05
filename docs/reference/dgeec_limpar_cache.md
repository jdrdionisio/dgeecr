# Limpar o cache em disco

Remove o HTML cru descarregado e/ou o resultado ja interpretado (RDS).

## Uso

``` r
dgeec_limpar_cache(
  dir = NULL,
  html = TRUE,
  dados = TRUE,
  confirmar = interactive()
)
```

## Argumentos

- dir:

  Pasta de cache (NULL =
  [`dgeec_cache_dir()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_cache_dir.md)).

- html:

  Remover o HTML cru?

- dados:

  Remover os resultados interpretados (RDS)?

- confirmar:

  Pedir confirmacao (por omissao, apenas em sessao interativa).

## Valor

(invisivelmente) o numero de ficheiros removidos.
