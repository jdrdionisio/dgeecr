# Conveniencia (API funcional) ------------------------------------------

#' Extrair dados de uma pagina (atalho)
#'
#' Cria um [DgeecClient] e extrai os dados de uma pagina.
#'
#' @param pagina Id de pagina (ver [dgeec_paginas()]).
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
