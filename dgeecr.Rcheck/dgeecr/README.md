# dgeecr

Pacote R para extrair os dados do portal **"Regiões em Números - Educação"**
da Direção-Geral de Estatísticas da Educação e Ciência (DGEEC)
(<https://estatisticas-educacao.dgeec.medu.pt/regioesemnumeros/>).

## O problema

Cada página do portal é um formulário que faz `POST` para si própria e
devolve a mesma tabela já filtrada — por **uma** região e **uma** combinação
de natureza/género/orientação de cada vez. Obter "tudo" obriga ao produto
cartesiano das opções de cada `<select>`, o que são dezenas de milhares de
pedidos. O `dgeecr` trata disso:

- **Paralelização** com `httr2::req_perform_parallel()` (curl multi).
- **Cache em disco com retoma** — o HTML cru de cada combinação é guardado;
  interromper e reexecutar continua de onde ficou.
- **Tabela longa** (1 linha = 1 observação) pronta a analisar.
- **Enriquecimento geográfico** opcional com divisões administrativas e de
  saúde (ULS, NUTS, região 2024) a partir de um ficheiro de ligação incluído.

## Instalação

```r
# a partir da pasta local
install.packages("dgeecr", repos = NULL, type = "source")
```

## Uso rápido

```r
library(dgeecr)

cli <- DgeecClient$new(concorrencia = 8L)

dgeec_paginas()                 # catálogo de tabelas
cli$dimensoes("pre_escolar")    # filtros e respetivos códigos

d <- cli$dados("pre_escolar", regioes = c("0", "101011604"))
d <- enriquecer_geo(d)          # + uls_1, uls_2, regiao_2024, nuts*

cli$exportar(d, "output/dgeec_pre_escolar", formatos = c("csv", "parquet", "xlsx"))
```

Extrair todas as páginas:

```r
dgeec_extrair_tudo("output", formatos = c("csv", "parquet"))
```

## Formato da saída

Uma linha por observação, com as colunas de contexto (`pagina`, `grupo`,
`regiao_*`, `natureza_*`, `genero_*`, `orientacao_*`), a dimensão da linha
(`dimensao`, `categoria_nivel`, `categoria`) e a medição
(`ano_letivo`, `valor`).

## Notas

- Por omissão extrai-se apenas o nível **desagregado**
  (Público/Privado × Homens/Mulheres × Jovens/Adultos); os totais somados
  ("Público e Privado", "Homens e Mulheres", "Todos os programas") são
  deriváveis. Usar `incluir_totais = TRUE` para os incluir.
- O **CSV** e o **Parquet** suportam o conjunto completo; o **XLSX** só é
  gerado quando o número de linhas cabe numa aba do Excel.
- Municípios divididos por ULS (Lisboa, Porto, Gondomar, Loures, Funchal)
  ficam com `uls_1` e `uls_2` (e `uls_todas` com as três quando aplicável).

## Ficheiros de ligação geográfica

`inst/extdata/geo_linkage_2024_v8.csv` — liga freguesia/município a ULS 2024,
ACES, ARS, NUTS 2013/2024 e região de saúde 2024.
