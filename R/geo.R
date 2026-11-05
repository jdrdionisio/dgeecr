# Enriquecimento geografico (ULS, NUTS, regiao 2024) --------------------

# Normaliza o nome do municipio para ligacao (minusculas, sem qualificadores).
.norm_mun <- function(x) {
  x <- stringr::str_to_lower(x)
  x <- stringr::str_remove_all(x, "\\([^)]*\\)")   # remove "(...)"
  x <- stringr::str_remove_all(x, "\\[[^]]*\\]")   # remove "[...]"
  stringr::str_squish(x)
}

#' Tabela de ligacao municipio -> divisoes administrativas e de saude
#'
#' Le o ficheiro de ligacao geografica incluido no pacote
#' (`inst/extdata/geo_linkage_2024_v8.csv`) e agrega-o ao nivel do municipio,
#' resolvendo as ULS que dividem um municipio ao nivel da freguesia em
#' `uls_1` e `uls_2`.
#'
#' @param path Caminho alternativo para o CSV de ligacao.
#' @return Um `tibble` por municipio, com `uls_1`, `uls_2`, `n_uls`,
#'   `uls_todas`, `uls_principal` (ULS com mais freguesias), `regiao_2024`,
#'   `nuts1`, `nuts2`, `nuts3`, `aces_2022`, `ars_2022` e `freguesias`.
#' @export
dgeec_geo <- function(path = NULL) {
  path <- path %||% system.file("extdata", "geo_linkage_2024_v8.csv", package = "dgeecr")
  if (!nzchar(path) || !file.exists(path))
    stop("Ficheiro de ligacao geografica nao encontrado.", call. = FALSE)

  geo <- readr::read_delim(path, delim = ";", show_col_types = FALSE,
                           locale = readr::locale(encoding = "UTF-8"))

  geo |>
    dplyr::transmute(
      municipio  = .norm_mun(.data$municipio_2013),
      nuts1      = .data$nuts1_2013,
      municipio_2024_cod = .data$municipio_2024_cod,
      nuts2      = .data$nuts2_2024,
      nuts3      = .data$nuts3_2024,
      regiao_2024 = .data$regiao_2024,
      aces_2022  = .data$aces_2022,
      ars_2022   = .data$ars_2022,
      uls        = .data$uls_2024
    ) |>
    dplyr::group_by(.data$municipio, .data$nuts1) |>
    dplyr::summarise(
      municipio_2024_cod = dplyr::first(.data$municipio_2024_cod),
      nuts2 = dplyr::first(.data$nuts2),
      nuts3 = dplyr::first(.data$nuts3),
      regiao_2024 = dplyr::first(.data$regiao_2024),
      aces_2022 = dplyr::first(.data$aces_2022),
      ars_2022 = dplyr::first(.data$ars_2022),
      freguesias = dplyr::n(),
      uls = list(sort(unique(stats::na.omit(.data$uls)))),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      uls_1 = purrr::map_chr(.data$uls, ~ if (length(.x) >= 1) .x[[1]] else NA_character_),
      uls_2 = purrr::map_chr(.data$uls, ~ if (length(.x) >= 2) .x[[2]] else NA_character_),
      n_uls = purrr::map_int(.data$uls, length),
      uls_todas = purrr::map_chr(.data$uls, ~ paste(.x, collapse = " + ")),
      uls_principal = purrr::map_chr(.data$uls, function(u) {
        if (length(u) == 0) return(NA_character_)
        if (length(u) == 1) return(u[[1]])
        u[[1]]   # ja ordenado; com 1 ULS e igual
      })
    ) |>
    dplyr::select(-"uls")
}

# Reconstroi, por municipio, a ULS com mais freguesias (usado em `maior`).
.uls_principal_map <- function(path = NULL) {
  path <- path %||% system.file("extdata", "geo_linkage_2024_v8.csv", package = "dgeecr")
  geo <- readr::read_delim(path, delim = ";", show_col_types = FALSE,
                           locale = readr::locale(encoding = "UTF-8"))
  geo |>
    dplyr::mutate(municipio = .norm_mun(.data$municipio_2013)) |>
    dplyr::filter(!is.na(.data$uls_2024)) |>
    dplyr::count(.data$municipio, .data$uls_2024) |>
    dplyr::group_by(.data$municipio) |>
    dplyr::slice_max(.data$n, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::select(municipio = "municipio", uls_principal = "uls_2024")
}

#' Catalogo de ULS (2024)
#'
#' @param geo Tabela de ligacao (por omissao [dgeec_geo()]).
#' @return Um `tibble` com `uls`, `regiao_2024`, `n_municipios` e `municipios`.
#' @export
dgeec_uls <- function(geo = NULL) {
  geo <- geo %||% dgeec_geo()
  dplyr::bind_rows(
    dplyr::transmute(geo, municipio = .data$municipio, regiao_2024 = .data$regiao_2024,
                     uls = .data$uls_1),
    dplyr::filter(geo, .data$n_uls > 1) |>
      dplyr::transmute(municipio = .data$municipio, regiao_2024 = .data$regiao_2024,
                       uls = .data$uls_2)
  ) |>
    dplyr::filter(!is.na(.data$uls)) |>
    dplyr::group_by(.data$uls) |>
    dplyr::summarise(
      regiao_2024 = paste(sort(unique(.data$regiao_2024)), collapse = "; "),
      n_municipios = dplyr::n_distinct(.data$municipio),
      municipios = paste(sort(unique(.data$municipio)), collapse = "; "),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$uls)
}

#' Catalogo de regioes de saude 2024
#'
#' @param geo Tabela de ligacao (por omissao [dgeec_geo()]).
#' @return Um `tibble` com `regiao_2024`, `n_municipios` e `municipios`.
#' @export
dgeec_regioes_saude <- function(geo = NULL) {
  geo <- geo %||% dgeec_geo()
  geo |>
    dplyr::filter(!is.na(.data$regiao_2024)) |>
    dplyr::group_by(.data$regiao_2024) |>
    dplyr::summarise(
      n_municipios = dplyr::n_distinct(.data$municipio),
      municipios = paste(sort(unique(.data$municipio)), collapse = "; "),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$regiao_2024)
}

# Codigos DGEEC (ListaRegiao) dos municipios que pertencem as ULS/regioes dadas.
.regioes_alvo <- function(meta, geo, uls = NULL, regiao_saude = NULL) {
  alvo <- geo
  if (!is.null(uls)) alvo <- dplyr::filter(alvo, .data$uls_1 %in% uls | .data$uls_2 %in% uls)
  if (!is.null(regiao_saude)) alvo <- dplyr::filter(alvo, .data$regiao_2024 %in% regiao_saude)

  chaves <- paste(alvo$municipio, alvo$nuts1, sep = "|")

  tb <- meta$dimensoes[meta$dimensoes$select == "ListaRegiao" & meta$dimensoes$nivel == 3L, ]
  tb_key <- paste(.norm_mun(tb$rotulo), unname(.dgeec_nuts1[substr(tb$codigo, 1, 1)]), sep = "|")
  tb$codigo[tb_key %in% chaves]
}

#' Enriquece dados DGEEC com divisoes administrativas e de saude
#'
#' Liga as linhas de nivel "Municipio" ao ficheiro de ligacao geografica e
#' acrescenta `uls_1`, `uls_2`, `uls_principal`, `n_uls`, `regiao_2024`,
#' `nuts1`, `nuts2`, `nuts3`, `aces_2022` e `ars_2022`. Municipios com varias
#' ULS (Lisboa, Porto, Gondomar, Loures, Funchal) ficam com `uls_1`/`uls_2`.
#'
#' @param dados Um `tibble` produzido por [DgeecClient]`$dados()` /
#'   [dgeec_dados()], com as colunas `regiao_codigo`, `regiao_nome` e
#'   `regiao_tipo`.
#' @param geo Tabela de ligacao (por omissao [dgeec_geo()]).
#' @return `dados` com as colunas geograficas acrescentadas.
#' @export
enriquecer_geo <- function(dados, geo = NULL) {
  geo <- geo %||% dgeec_geo()
  if (!all(c("regiao_codigo", "regiao_nome", "regiao_tipo") %in% names(dados)))
    stop("`dados` nao tem as colunas de regiao esperadas.", call. = FALSE)

  chave <- dplyr::tibble(
    .mun   = ifelse(dados$regiao_tipo == .lbl_municipio, .norm_mun(dados$regiao_nome), NA_character_),
    .nuts1 = unname(.dgeec_nuts1[substr(dados$regiao_codigo, 1, 1)])
  )

  geo2 <- dplyr::rename(geo, .mun = "municipio", .nuts1 = "nuts1")
  dplyr::bind_cols(dados, chave) |>
    dplyr::left_join(geo2, by = c(".mun", ".nuts1")) |>
    dplyr::select(-".mun") |>
    dplyr::rename(nuts1 = ".nuts1")
}

# Soma `valor` por entidade geografica, preservando as colunas de contexto.
.somar_geo <- function(d, entidade) {
  ctx <- intersect(c(
    "pagina", "grupo",
    "natureza_codigo", "natureza_nome", "genero_codigo", "genero_nome",
    "orientacao_codigo", "orientacao_nome",
    "dimensao", "categoria_nivel", "categoria", "ano_letivo"
  ), names(d))
  d |>
    dplyr::group_by(!!!rlang::syms(c(entidade, ctx))) |>
    dplyr::summarise(
      valor = sum(.data$valor, na.rm = TRUE),
      n_municipios = dplyr::n_distinct(.data$regiao_codigo),
      .groups = "drop"
    ) |>
    dplyr::arrange(!!!rlang::syms(c(entidade, "categoria_nivel", "categoria", "ano_letivo")))
}

#' Agrega dados ao nivel da ULS
#'
#' Soma os valores dos municipios pertencentes a cada ULS.
#'
#' @param dados `tibble` de [DgeecClient]`$dados()`.
#' @param geo Tabela de ligacao (por omissao [dgeec_geo()]).
#' @param multiplas Como tratar os municipios repartidos por varias ULS
#'   (Lisboa, Porto, Gondomar, Loures, Funchal), cujos dados o portal so
#'   publica ao nivel do municipio:
#'   `"excluir"` (por omissao) remove-os da soma e lista-os no atributo
#'   `municipios_excluidos`; `"duplicar"` atribui o valor a cada ULS
#'   (dupla contagem); `"maior"` atribui a ULS com mais freguesias.
#' @return Um `tibble` ao nivel da ULS (+ atributo `municipios_excluidos`).
#' @export
agregar_uls <- function(dados, geo = NULL, multiplas = c("excluir", "duplicar", "maior")) {
  multiplas <- match.arg(multiplas)
  geo <- geo %||% dgeec_geo()
  d <- enriquecer_geo(dados, geo)
  d <- dplyr::filter(d, .data$regiao_tipo == .lbl_municipio, !is.na(.data$uls_1))

  excluidos <- character(0)
  if (multiplas == "excluir") {
    excluidos <- sort(unique(d$regiao_nome[d$n_uls > 1]))
    d <- dplyr::filter(d, .data$n_uls == 1)
    d$uls <- d$uls_1
  } else if (multiplas == "maior") {
    mapa <- .uls_principal_map()
    d <- dplyr::left_join(d, mapa, by = c("regiao_nome" = "municipio"))
    d$uls <- d$uls_principal
  } else {
    d1 <- d; d1$uls <- d1$uls_1
    d2 <- dplyr::filter(d, .data$n_uls > 1)
    if (nrow(d2)) { d2$uls <- d2$uls_2; d <- dplyr::bind_rows(d1, d2) } else d <- d1
  }

  res <- .somar_geo(d, "uls")
  attr(res, "municipios_excluidos") <- excluidos
  res
}

#' Agrega dados ao nivel da regiao de saude 2024
#'
#' @param dados `tibble` de [DgeecClient]`$dados()`.
#' @param geo Tabela de ligacao (por omissao [dgeec_geo()]).
#' @return Um `tibble` ao nivel da regiao de saude.
#' @export
agregar_regiao_saude <- function(dados, geo = NULL) {
  geo <- geo %||% dgeec_geo()
  d <- enriquecer_geo(dados, geo)
  d <- dplyr::filter(d, .data$regiao_tipo == .lbl_municipio, !is.na(.data$regiao_2024))
  .somar_geo(d, "regiao_2024")
}
