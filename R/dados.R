# Conveniência (API funcional) ------------------------------------------

#' Extrair dados de uma página (atalho)
#'
#' Cria um [DgeecClient] e extrai os dados de uma página.
#'
#' @param pagina Id de página (ver [dgeec_paginas()]).
#' @param ... Argumentos passados a `DgeecClient$dados()` (p.ex. `regioes`,
#'   `natureza`, `incluir_totais`).
#' @param cliente Um [DgeecClient] opcional.
#' @return Um `tibble` longo.
#' @export
#' @examples
#' \donttest{
#' dgeec_dados("pre_escolar", regioes = "0")
#' }
dgeec_dados <- function(pagina, ..., cliente = NULL) {
  cliente <- cliente %||% DgeecClient$new()
  cliente$dados(pagina, ...)
}
