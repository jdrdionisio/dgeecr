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
#' \dontrun{
#' # requer acesso a Internet
#' dgeec_dados("pre_escolar", regioes = "Portugal")
#' }
dgeec_dados <- function(pagina, ..., cliente = NULL) {
  cliente <- cliente %||% DgeecClient$new()
  cliente$dados(pagina, ...)
}
