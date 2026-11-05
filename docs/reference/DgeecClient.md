# Cliente DGEEC

Cliente R6 para o portal "Regioes em Numeros - Educacao". Gere a
paralelizacao (httr2 na rede, `parallel` no parsing), o cache em disco
(com resume) e a conversao em tabela longa.

## Public fields

- `cache_dir`:

  Pasta de cache (NULL = `tools::R_user_dir("dgeecr","cache")`).

- `concorrencia`:

  No de pedidos simultaneos (rede).

- `nucleos`:

  No de processos para o parsing (NULL = todos menos 2, ou 2 durante a
  verificacao da CRAN).

- `timeout`:

  Timeout por pedido (s).

- `tentativas`:

  Tentativas por pedido.

- `usar_cache`:

  Reutilizar HTML ja descarregado?

- `cache_dados`:

  Guardar/ler tambem o resultado ja interpretado (RDS)?

- `lote`:

  No de pedidos por lote.

## Methods

### Public methods

- [`DgeecClient$new()`](#method-DgeecClient-initialize)

- [`DgeecClient$paginas()`](#method-DgeecClient-paginas)

- [`DgeecClient$dimensoes()`](#method-DgeecClient-dimensoes)

- [`DgeecClient$regioes()`](#method-DgeecClient-regioes)

- [`DgeecClient$dados()`](#method-DgeecClient-dados)

- [`DgeecClient$exportar()`](#method-DgeecClient-exportar)

- [`DgeecClient$tamanho_cache()`](#method-DgeecClient-tamanho_cache)

- [`DgeecClient$limpar_cache()`](#method-DgeecClient-limpar_cache)

- [`DgeecClient$.parsear()`](#method-DgeecClient-.parsear)

- [`DgeecClient$.descarregar()`](#method-DgeecClient-.descarregar)

- [`DgeecClient$clone()`](#method-DgeecClient-clone)

------------------------------------------------------------------------

### `DgeecClient$new()`

Cria um cliente.

#### Usage

    DgeecClient$new(
      cache_dir = NULL,
      concorrencia = 8L,
      nucleos = NULL,
      timeout = 45L,
      tentativas = 3L,
      usar_cache = TRUE,
      cache_dados = TRUE,
      lote = 250L
    )

#### Arguments

- `cache_dir`:

  Pasta de cache.

- `concorrencia`:

  No de pedidos simultaneos.

- `nucleos`:

  No de processos para o parsing.

- `timeout`:

  Timeout por pedido (s).

- `tentativas`:

  Tentativas por pedido.

- `usar_cache`:

  Reutilizar cache em disco.

- `cache_dados`:

  Guardar/ler o resultado interpretado.

- `lote`:

  No de pedidos por lote.

------------------------------------------------------------------------

### `DgeecClient$paginas()`

Catalogo de paginas.

#### Usage

    DgeecClient$paginas()

------------------------------------------------------------------------

### `DgeecClient$dimensoes()`

Dimensoes (filtros) de uma pagina.

#### Usage

    DgeecClient$dimensoes(pagina)

#### Arguments

- `pagina`:

  Id de pagina.

------------------------------------------------------------------------

### `DgeecClient$regioes()`

Catalogo de regioes (codigo e nome).

#### Usage

    DgeecClient$regioes(pagina = "pre_escolar")

#### Arguments

- `pagina`:

  Pagina de onde ler a lista.

------------------------------------------------------------------------

### `DgeecClient$dados()`

Extrai dados de uma pagina.

#### Usage

    DgeecClient$dados(
      pagina,
      regioes = NULL,
      uls = NULL,
      regiao_saude = NULL,
      natureza = NULL,
      genero = NULL,
      orientacao = NULL,
      incluir_totais = FALSE,
      progress = TRUE
    )

#### Arguments

- `pagina`:

  Id de pagina (ver
  [`dgeec_paginas()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_paginas.md)).

- `regioes`:

  Codigos **ou nomes** de regiao (NULL = todas). Os nomes podem ser de
  Portugal, NUTS I/II/III ou municipio; ver
  [`dgeec_regioes()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_regioes.md).
  Ex.: `regioes = c("Portugal", "Moncao")`.

- `uls`:

  Nome(s) de ULS (ver
  [`dgeec_uls()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_uls.md))
  a que restringir a extracao.

- `regiao_saude`:

  Nome(s) de regiao de saude 2024 (ver
  [`dgeec_regioes_saude()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_regioes_saude.md)).

- `natureza`:

  Codigos de natureza (NULL = desagregado 1/2, ou todos se
  `incluir_totais`).

- `genero`:

  Codigos de genero (NULL = desagregado 1/2, ou todos se
  `incluir_totais`).

- `orientacao`:

  Codigos de orientacao (NULL = desagregado 10/20, ou todos se
  `incluir_totais`).

- `incluir_totais`:

  Incluir tambem os niveis totais (0/...)?

- `progress`:

  Mostrar progresso.

#### Returns

Um `tibble` longo (1 linha = 1 observacao).

------------------------------------------------------------------------

### `DgeecClient$exportar()`

Exporta um data frame em CSV/Parquet/XLSX.

#### Usage

    DgeecClient$exportar(
      dados,
      ficheiro,
      formatos = c("csv", "parquet", "xlsx"),
      limite_xlsx = 1048575L
    )

#### Arguments

- `dados`:

  `tibble` a exportar.

- `ficheiro`:

  Caminho base (sem extensao).

- `formatos`:

  Formatos a escrever.

- `limite_xlsx`:

  Maximo de linhas para gerar XLSX (limite do Excel).

------------------------------------------------------------------------

### `DgeecClient$tamanho_cache()`

Tamanho do cache em disco.

#### Usage

    DgeecClient$tamanho_cache()

------------------------------------------------------------------------

### `DgeecClient$limpar_cache()`

Limpa o cache em disco.

#### Usage

    DgeecClient$limpar_cache(...)

#### Arguments

- `...`:

  Passado a
  [`dgeec_limpar_cache()`](https://jdrdionisio.github.io/dgeecr/reference/dgeec_limpar_cache.md)
  (`html`, `dados`, `confirmar`).

------------------------------------------------------------------------

### `DgeecClient$.parsear()`

#### Usage

    DgeecClient$.parsear(chaves, ctx)

------------------------------------------------------------------------

### `DgeecClient$.descarregar()`

#### Usage

    DgeecClient$.descarregar(path, combos, chaves, progress = TRUE)

------------------------------------------------------------------------

### `DgeecClient$clone()`

The objects of this class are cloneable with this method.

#### Usage

    DgeecClient$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Exemplos

``` r
if (FALSE) { # \dontrun{
# requer acesso a Internet
cli <- DgeecClient$new()
d <- cli$dados("pre_escolar", regioes = c("Portugal", "Moncao"))
} # }
```
