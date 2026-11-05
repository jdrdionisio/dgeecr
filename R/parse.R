# Parsing do HTML -> tabela longa ---------------------------------------

# Normaliza espaços, trocando &nbsp; por espaço.
.norm_txt <- function(x) {
  x <- stringr::str_replace_all(x, "\u00a0", " ")
  stringr::str_squish(x)
}

# "8 786" / "259 850" / "90.6" -> número (milhares separados por espaço).
.para_num <- function(x) {
  x <- stringr::str_remove_all(x, "[\u00a0 ]")
  x <- dplyr::na_if(x, "")
  suppressWarnings(as.numeric(x))
}

# Converte um documento HTML (xml_document ou bytes) num tibble longo:
#   dimensao | categoria_nivel | categoria | ano_letivo | valor
# `ctx` é um data.frame de 1 linha com os códigos/rótulos do pedido.
.parse_html <- function(html, ctx) {
  if (is.null(html)) return(NULL)
  if (is.raw(html) || is.character(html))
    html <- xml2::read_html(html, encoding = "UTF-8")

  rows <- rvest::html_elements(html, "div.table-responsive tr")
  if (length(rows) == 0) rows <- rvest::html_elements(html, "tr")

  anos <- NULL; secao <- NA_character_; dim_linha <- NA_character_
  linhas <- list()

  for (tr in rows) {
    cells <- rvest::html_elements(tr, "th, td")
    if (length(cells) == 0) next

    txt <- .norm_txt(rvest::html_text2(cells))
    colspan <- rvest::html_attr(cells[[1]], "colspan")
    classe1 <- rvest::html_attr(cells[[1]], "class") %||% ""

    # (a) linha de secção (célula única com colspan)
    if (!is.na(colspan) && length(cells) == 1) { secao <- txt[1]; next }

    # (b) cabeçalho com os anos letivos
    if (all(rvest::html_name(cells) == "th") &&
        any(stringr::str_detect(txt, "^\\d{4}/\\d{2}$"))) {
      anos <- txt[stringr::str_detect(txt, "^\\d{4}/\\d{2}$")]
      if (is.na(dim_linha)) {
        dl <- stringr::str_remove(txt[1], "^Ano letivo\\s*") |> stringr::str_squish()
        if (nzchar(dl) && dl != "Ano letivo") dim_linha <- dl
      }
      next
    }

    # (c) linha de dados (1.ª célula com classe tdn*)
    if (!stringr::str_detect(classe1, "tdn")) next

    rotulo_raw <- xml2::xml_text(cells[[1]])          # preserva &nbsp;
    nb <- stringr::str_count(stringr::str_extract(rotulo_raw, "^\u00a0*"), "\u00a0")
    categoria <- .norm_txt(rotulo_raw)
    valores <- txt[-1]
    if (length(anos) == 0 || length(valores) != length(anos)) next

    linhas[[length(linhas) + 1]] <- tibble::tibble(
      dimensao        = dplyr::coalesce(secao, dim_linha),
      categoria_nivel = as.integer(nb %/% 3L) + 1L,
      categoria       = categoria,
      ano_letivo      = anos,
      valor           = .para_num(valores)
    )
  }

  if (length(linhas) == 0) return(NULL)
  out <- dplyr::bind_rows(linhas)
  cbind(ctx[rep(1L, nrow(out)), , drop = FALSE], out) |> tibble::as_tibble()
}

# Sobrecarga para uma resposta httr2.
.parse_resposta <- function(resp, ctx) {
  if (!inherits(resp, "httr2_response")) return(NULL)
  if (httr2::resp_status(resp) != 200) return(NULL)
  html <- tryCatch(.resp_html(resp), error = function(e) NULL)
  .parse_html(html, ctx)
}
