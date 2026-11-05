# Exportar dados

Escreve um `data.frame` em disco. O CSV e o Parquet suportam o conjunto
completo; o XLSX so e gerado se o numero de linhas couber no limite de
uma aba do Excel (`limite_xlsx`), caso contrario e ignorado com aviso.

## Uso

``` r
dgeec_exportar(
  dados,
  ficheiro,
  formatos = c("csv", "parquet", "xlsx"),
  limite_xlsx = 1048575L
)
```

## Argumentos

- dados:

  `data.frame`/`tibble` a exportar.

- ficheiro:

  Caminho base, sem extensao.

- formatos:

  Formatos a escrever: qualquer subconjunto de `"csv"`, `"parquet"`,
  `"xlsx"`.

- limite_xlsx:

  Maximo de linhas para gerar XLSX (limite do Excel: 1 048 576; por
  seguranca usa-se 1 048 575).

## Valor

(invisivelmente) o vetor de ficheiros escritos.
