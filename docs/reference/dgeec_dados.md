# Extrair dados de uma pagina (atalho)

Cria um
[DgeecClient](https://jdrdionisio.github.io/dgeecr/reference/DgeecClient.md)
e extrai os dados de uma pagina.

## Usage

``` r
dgeec_dados(pagina, ..., cliente = NULL)
```

## Arguments

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

## Value

Um `tibble` longo.

## Examples

``` r
# \donttest{
dgeec_dados("pre_escolar", regioes = "0")
#>   cache de dados: leitura do resultado interpretado.
#> # A tibble: 200 × 15
#>    pagina      grupo     regiao_codigo natureza_codigo genero_codigo regiao_nome
#>    <chr>       <chr>     <chr>         <chr>           <chr>         <chr>      
#>  1 pre_escolar Alunos m… 0             1               1             Portugal   
#>  2 pre_escolar Alunos m… 0             1               2             Portugal   
#>  3 pre_escolar Alunos m… 0             2               1             Portugal   
#>  4 pre_escolar Alunos m… 0             2               2             Portugal   
#>  5 pre_escolar Alunos m… 0             1               1             Portugal   
#>  6 pre_escolar Alunos m… 0             1               2             Portugal   
#>  7 pre_escolar Alunos m… 0             2               1             Portugal   
#>  8 pre_escolar Alunos m… 0             2               2             Portugal   
#>  9 pre_escolar Alunos m… 0             1               1             Portugal   
#> 10 pre_escolar Alunos m… 0             1               2             Portugal   
#> # ℹ 190 more rows
#> # ℹ 9 more variables: natureza_nome <chr>, genero_nome <chr>,
#> #   regiao_tipo <chr>, regiao_nivel <int>, dimensao <chr>,
#> #   categoria_nivel <int>, categoria <chr>, ano_letivo <chr>, valor <dbl>
# }
```
