# Metadados das paginas (dimensoes e <select>) --------------------------

# Resolve o `path` a partir do `id` (aceita tambem o proprio path).
.resolve_pagina <- function(pagina) {
  if (length(pagina) != 1L || is.na(pagina)) stop("`pagina` deve ser um \u00fanico id.", call. = FALSE)
  p <- .dgeec_paginas
  if (pagina %in% p$id) return(p[p$id == pagina, , drop = FALSE])
  if (pagina %in% p$path) return(p[p$path == pagina, , drop = FALSE])
  stop(sprintf("P\u00e1gina desconhecida: '%s'. Ver `dgeec_paginas()`.", pagina), call. = FALSE)
}

# GET simples com retry.
.dgeec_obter <- function(path, timeout = 45L, tentativas = 3L) {
  httr2::request(.dgeec_base) |>
    httr2::req_url_path_append(path) |>
    httr2::req_user_agent(.dgeec_ua) |>
    httr2::req_timeout(timeout) |>
    httr2::req_retry(max_tries = tentativas) |>
    httr2::req_perform()
}

# Converte uma resposta httr2 num documento xml2 (UTF-8).
.resp_html <- function(resp) {
  xml2::read_html(httr2::resp_body_raw(resp), encoding = "UTF-8")
}

#' Dimensoes (filtros) de uma pagina
#'
#' Le a pagina do portal e devolve os valores possiveis de cada `<select>`,
#' com o respetivo nivel hierarquico (no caso das regioes).
#'
#' @param pagina Id de pagina (ver [dgeec_paginas()]) ou o respetivo `path`.
#' @param timeout Timeout por pedido, em segundos.
#' @return Um `tibble` com `select`, `codigo`, `rotulo` e `nivel`.
#' @export
#' @examples
#' \donttest{
#' dgeec_dimensoes("pre_escolar")
#' }
dgeec_dimensoes <- function(pagina, timeout = 45L) {
  meta <- .dgeec_meta(pagina, timeout = timeout)
  meta$dimensoes
}

# Obtem os metadados completos de uma pagina.
.dgeec_meta <- function(pagina, timeout = 45L, tentativas = 3L) {
  info <- .resolve_pagina(pagina)
  html <- .dgeec_obter(info$path, timeout = timeout, tentativas = tentativas) |>
    .resp_html()

  nomes_sel <- rvest::html_elements(html, "form select") |> rvest::html_attr("name")

  dims <- purrr::map_dfr(nomes_sel, function(nm) {
    op <- rvest::html_elements(html, sprintf("select[name='%s'] option", nm))
    rotulo_raw <- rvest::html_text2(op)
    tibble::tibble(
      select = nm,
      codigo = rvest::html_attr(op, "value"),
      rotulo_raw = rotulo_raw,
      rotulo = .norm_txt(rotulo_raw),
      nivel = .nivel_regiao(rotulo_raw)
    )
  })

  hdr <- rvest::html_element(html, "table tr th") |> rvest::html_text2() |> .norm_txt()
  dim_linha <- hdr |> stringr::str_remove("^Ano letivo\\s*") |> stringr::str_squish() |>
    dplyr::na_if("") |> dplyr::na_if("Ano letivo")

  anos <- rvest::html_elements(html, "table tr") |>
    purrr::pluck(1) |> rvest::html_elements("th") |> rvest::html_text2() |> .norm_txt()
  anos <- anos[stringr::str_detect(anos, "^\\d{4}/\\d{2}$")]

  list(
    id = info$id, grupo = info$grupo, path = info$path,
    dimensoes = dims, dim_linha = dim_linha, anos = anos
  )
}

# Nivel hierarquico a partir do no de &nbsp; a esquerda do rotulo.
.nivel_regiao <- function(rotulo_raw) {
  nb <- stringr::str_count(stringr::str_extract(rotulo_raw, "^(?:&nbsp;|\u00a0)*"),
                           "&nbsp;|\u00a0")
  as.integer(nb %/% 2L)
}

# Tipo de regiao a partir do rotulo.
.tipo_regiao <- function(nome) {
  dplyr::case_when(
    nome == "Portugal" ~ "Portugal",
    stringr::str_starts(nome, "NUTS I:") ~ "NUTS I",
    stringr::str_starts(nome, "NUTS II:") ~ "NUTS II",
    stringr::str_starts(nome, "NUTS III:") ~ "NUTS III",
    TRUE ~ "Munic\u00edpio"
  )
}
