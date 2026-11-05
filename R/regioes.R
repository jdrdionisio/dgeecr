# Catalogo de regioes e resolucao por nome ------------------------------

#' Catalogo de regioes do portal
#'
#' Devolve a lista de regioes aceites em `regioes=` por [DgeecClient]`$dados()`,
#' com o codigo e o nome, para nao ser necessario conhecer os codigos.
#'
#' @param pagina Pagina de onde ler a lista (o catalogo e igual em todas as
#'   paginas; ver [dgeec_paginas()]). Por omissao `"pre_escolar"`.
#' @param timeout Timeout por pedido, em segundos.
#' @return Um `tibble` com `regiao_codigo`, `regiao_nome`, `regiao_tipo` e
#'   `regiao_nivel` (0 = Portugal e NUTS I, 1 = NUTS II, 2 = NUTS III,
#'   3 = municipio).
#' @export
#' @examples
#' \donttest{
#' dgeec_regioes()
#' dgeec_regioes() |> subset(regiao_tipo == "Municipio")
#' }
dgeec_regioes <- function(pagina = "pre_escolar", timeout = 45L) {
  tb <- .dgeec_meta(pagina, timeout = timeout)$dimensoes
  tb <- tb[tb$select == "ListaRegiao", , drop = FALSE]
  if (nrow(tb) == 0) stop("Esta pagina nao tem lista de regioes.", call. = FALSE)

  out <- tibble::tibble(
    regiao_codigo = tb$codigo,
    regiao_nome   = stringr::str_squish(
      stringr::str_remove(tb$rotulo, "^NUTS (I|II|III):\\s*")),
    regiao_tipo   = .tipo_regiao(tb$rotulo),
    regiao_nivel  = as.integer(tb$nivel)
  )
  out[order(out$regiao_nivel, out$regiao_nome), , drop = FALSE]
}

# Chave de ligacao por nome: minusculas, sem acentos, sem o prefixo NUTS
# e sem qualificadores entre parenteses (curvos ou retos).
.chave_regiao <- function(x) {
  x <- .norm_txt(x)
  x <- stringr::str_remove(x, "^NUTS (I|II|III):\\s*")
  x <- stringr::str_to_lower(x)
  x <- stringr::str_remove_all(x, "\\([^)]*\\)")
  x <- stringr::str_remove_all(x, "\\[[^]]*\\]")
  y <- suppressWarnings(iconv(x, from = "UTF-8", to = "ASCII//TRANSLIT"))
  y[is.na(y)] <- x[is.na(y)]
  stringr::str_squish(stringr::str_remove_all(stringr::str_to_lower(y), "[^a-z0-9 ]+"))
}

# Traduz nomes (ou codigos) de regiao nos codigos DGEEC do formulario.
.resolver_regioes <- function(meta, pedido) {
  tb <- meta$dimensoes[meta$dimensoes$select == "ListaRegiao", , drop = FALSE]
  pedido <- as.character(pedido)
  codigos <- character(0); desconhecidas <- character(0); ambiguas <- character(0)
  tb_chave <- .chave_regiao(tb$rotulo)

  for (p in pedido) {
    if (p %in% tb$codigo) { codigos <- c(codigos, p); next }
    hit <- tb$codigo[tb_chave == .chave_regiao(p)]
    if (length(hit) == 1L) {
      codigos <- c(codigos, hit)
    } else if (length(hit) > 1L) {
      ambiguas <- c(ambiguas, sprintf("'%s' -> %s", p, paste(hit, collapse = " / ")))
    } else {
      desconhecidas <- c(desconhecidas, p)
    }
  }

  if (length(desconhecidas))
    stop(sprintf("Regiao(oes) desconhecida(s): %s.\nVer `dgeec_regioes()` para a lista de nomes.",
                 paste(desconhecidas, collapse = ", ")), call. = FALSE)
  if (length(ambiguas))
    stop(sprintf("Nome(s) ambiguo(s): %s.\nUse o codigo de `dgeec_regioes()`.",
                 paste(ambiguas, collapse = "; ")), call. = FALSE)
  unique(codigos)
}
