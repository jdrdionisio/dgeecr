#' dgeecr: dados de "Regioes em Numeros - Educacao" (DGEEC)
#'
#' Cliente R para extrair os dados do portal
#' <https://estatisticas-educacao.dgeec.medu.pt/regioesemnumeros/>, em paralelo
#' e com cache em disco, devolvendo tabelas longas (1 linha = 1 observacao) e
#' permitindo enriquecimento geografico (ULS, NUTS, regiao 2024).
#'
#' @keywords internal
#' @importFrom rlang .data
#' @importFrom R6 R6Class
#' @importFrom parallel mclapply detectCores
"_PACKAGE"
