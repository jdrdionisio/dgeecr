# Parsing do HTML -> tabela longa ---------------------------------------

# Carater nao-quebra (nbsp), construido sem escapes para manter o ficheiro
# em ASCII puro (requisito do R CMD check).
.nbsp_char <- intToUtf8(160L)

# Normaliza espacos, trocando nbsp por espaco comum.
.norm_txt <- function(x) {
  x <- stringr::str_replace_all(x, .nbsp_char, " ")
  stringr::str_squish(x)
}

# "8 786" / "259 850" / "90.6" -> numero (milhares separados por espaco nbsp).
.para_num <- function(x) {
  x <- stringr::str_remove_all(x, paste0("[", .nbsp_char, " ]"))
  x <- dplyr::na_if(x, "")
  suppressWarnings(as.numeric(x))
}

# Converte um documento HTML (xml_document ou bytes) num tibble longo:
#   dimensao | categoria_nivel | categoria | ano_letivo | valor
# `ctx` e um data.frame de 1 linha com os codigos/rotulos do pedido.
#
# Implementacao rapida: navega a arvore com xml2 (xml_children/xml_text),
# evitando html_text2/html_elements por celula (~3x mais rapido).
.parse_html <- function(html, ctx) {
  if (is.null(html)) return(NULL)
  if (is.raw(html) || is.character(html)) html <- xml2::read_html(html, encoding = "UTF-8")

  trs <- rvest::html_elements(html, "div.table-responsive tr")
  if (length(trs) == 0) trs <- rvest::html_elements(html, "tr")

  anos <- NULL; secao <- NA_character_; dim_linha <- NA_character_
  linhas <- vector("list", length(trs))
  k <- 0L
  re_ano <- "^\\d{4}/\\d{2}$"

  for (tr in trs) {
    cells <- xml2::xml_children(tr)
    if (length(cells) == 0) next

    nm  <- xml2::xml_name(cells)
    txt <- vapply(cells, function(c) .norm_txt(xml2::xml_text(c)), character(1))
    colspan <- xml2::xml_attr(cells[[1]], "colspan")
    classe1 <- xml2::xml_attr(cells[[1]], "class")
    if (is.na(classe1)) classe1 <- ""

    # (a) linha de seccao (celula unica com colspan)
    if (!is.na(colspan) && length(cells) == 1) { secao <- txt[1]; next }

    # (b) cabecalho com os anos letivos
    if (all(nm == "th") && any(stringr::str_detect(txt, re_ano))) {
      anos <- txt[stringr::str_detect(txt, re_ano)]
      if (is.na(dim_linha)) {
        dl <- stringr::str_squish(stringr::str_remove(txt[1], "^Ano letivo\\s*"))
        if (nzchar(dl) && dl != "Ano letivo") dim_linha <- dl
      }
      next
    }

    # (c) linha de dados (1.a celula com classe tdn*)
    if (!stringr::str_detect(classe1, "tdn")) next

    rotulo_raw <- xml2::xml_text(cells[[1]])          # preserva nbsp
    nb <- stringr::str_count(stringr::str_extract(rotulo_raw, paste0("^", .nbsp_char, "*")),
                             .nbsp_char)
    valores <- txt[-1]
    if (length(anos) == 0 || length(valores) != length(anos)) next

    k <- k + 1L
    linhas[[k]] <- tibble::tibble(
      dimensao        = dplyr::coalesce(secao, dim_linha),
      categoria_nivel = as.integer(nb %/% 3L) + 1L,
      categoria       = .norm_txt(rotulo_raw),
      ano_letivo      = anos,
      valor           = .para_num(valores)
    )
  }

  if (k == 0L) return(NULL)
  out <- dplyr::bind_rows(linhas[seq_len(k)])
  cbind(ctx[rep(1L, nrow(out)), , drop = FALSE], out) |> tibble::as_tibble()
}

# Sobrecarga para uma resposta httr2.
.parse_resposta <- function(resp, ctx) {
  if (!inherits(resp, "httr2_response")) return(NULL)
  if (httr2::resp_status(resp) != 200) return(NULL)
  html <- tryCatch(.resp_html(resp), error = function(e) NULL)
  .parse_html(html, ctx)
}
