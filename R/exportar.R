# Exportação ------------------------------------------------------------

#' Exportar dados
#'
#' Escreve um `data.frame` em disco. O CSV e o Parquet suportam o conjunto
#' completo; o XLSX só é gerado se o número de linhas couber no limite de uma
#' aba do Excel (`limite_xlsx`), caso contrário é ignorado com aviso.
#'
#' @param dados `data.frame`/`tibble` a exportar.
#' @param ficheiro Caminho base, sem extensão.
#' @param formatos Formatos a escrever: qualquer subconjunto de
#'   `"csv"`, `"parquet"`, `"xlsx"`.
#' @param limite_xlsx Máximo de linhas para gerar XLSX (limite do Excel:
#'   1 048 576; por segurança usa-se 1 048 575).
#' @return (invisivelmente) o vetor de ficheiros escritos.
#' @export
dgeec_exportar <- function(dados, ficheiro, formatos = c("csv", "parquet", "xlsx"),
                           limite_xlsx = 1048575L) {
  dir.create(dirname(ficheiro), showWarnings = FALSE, recursive = TRUE)
  escritos <- character()

  if ("csv" %in% formatos) {
    f <- paste0(ficheiro, ".csv")
    readr::write_csv(dados, f, na = "")
    escritos <- c(escritos, f)
  }
  if ("parquet" %in% formatos) {
    f <- paste0(ficheiro, ".parquet")
    nanoparquet::write_parquet(dados, f)
    escritos <- c(escritos, f)
  }
  if ("xlsx" %in% formatos) {
    if (nrow(dados) <= limite_xlsx) {
      f <- paste0(ficheiro, ".xlsx")
      writexl::write_xlsx(dados, f)
      escritos <- c(escritos, f)
    } else {
      warning(sprintf(
        "XLSX ignorado para '%s': %d linhas excedem o limite do Excel (%d).",
        basename(ficheiro), nrow(dados), limite_xlsx), call. = FALSE)
    }
  }
  message("  -> ", paste(basename(escritos), collapse = ", "))
  invisible(escritos)
}

#' Extrair e exportar todas as páginas
#'
#' Percorre o catálogo, extrai cada página e escreve os formatos pedidos.
#'
#' @param dir Pasta de saída.
#' @param paginas Vetor de ids (NULL = todas).
#' @param formatos Formatos a escrever (ver [dgeec_exportar()]).
#' @param cliente Um [DgeecClient]. Se NULL, cria um.
#' @param ... Argumentos passados a `cliente$dados()`.
#' @return (invisivelmente) um `tibble` com `pagina` e `ficheiro`.
#' @export
dgeec_extrair_tudo <- function(dir, paginas = NULL, formatos = c("csv", "parquet"),
                               cliente = NULL, ...) {
  cliente <- cliente %||% DgeecClient$new()
  paginas <- paginas %||% cliente$paginas()$id
  res <- list()
  for (p in paginas) {
    dados <- cliente$dados(p, ...)
    f <- file.path(dir, paste0("dgeec_", p))
    if (nrow(dados) > 0) dgeec_exportar(dados, f, formatos = formatos)
    res[[p]] <- tibble::tibble(pagina = p, ficheiro = f, linhas = nrow(dados))
  }
  invisible(dplyr::bind_rows(res))
}
