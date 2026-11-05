# Enriquecimento geográfico (ULS, NUTS, região 2024) --------------------

# Normaliza o nome do município para ligação (minúsculas, sem qualificadores).
.norm_mun <- function(x) {
  x <- stringr::str_to_lower(x)
  x <- stringr::str_remove_all(x, "\\([^)]*\\)")   # remove "(...)"
  x <- stringr::str_remove_all(x, "\\[[^]]*\\]")   # remove "[...]"
  stringr::str_squish(x)
}

#' Tabela de ligação município -> divisões administrativas e de saúde
#'
#' Lê o ficheiro de ligação geográfica incluído no pacote
#' (`inst/extdata/geo_linkage_2024_v8.csv`) e agrega-o ao nível do município,
#' resolvendo as ULS que dividem um município ao nível da freguesia em
#' `uls_1` e `uls_2`.
#'
#' @param path Caminho alternativo para o CSV de ligação.
#' @return Um `tibble` por município.
#' @export
dgeec_geo <- function(path = NULL) {
  path <- path %||% system.file("extdata", "geo_linkage_2024_v8.csv", package = "dgeecr")
  if (!nzchar(path) || !file.exists(path))
    stop("Ficheiro de ligação geográfica não encontrado.", call. = FALSE)

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
      uls = list(sort(unique(stats::na.omit(.data$uls)))),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      uls_1 = purrr::map_chr(.data$uls, ~ if (length(.x) >= 1) .x[[1]] else NA_character_),
      uls_2 = purrr::map_chr(.data$uls, ~ if (length(.x) >= 2) .x[[2]] else NA_character_),
      n_uls = purrr::map_int(.data$uls, length),
      uls_todas = purrr::map_chr(.data$uls, ~ paste(.x, collapse = " + "))
    ) |>
    dplyr::select(-"uls")
}

#' Enriquece dados DGEEC com divisões administrativas e de saúde
#'
#' Liga as linhas de nível "Município" ao ficheiro de ligação geográfica e
#' acrescenta `uls_1`, `uls_2`, `regiao_2024`, `nuts1`, `nuts2`, `nuts3`,
#' `aces_2022` e `ars_2022`. Municípios com várias ULS (Lisboa, Porto,
#' Gondomar, Loures, Funchal) ficam com `uls_1` e `uls_2` preenchidos.
#'
#' @param dados Um `tibble` produzido por [DgeecClient]`$dados()` /
#'   [dgeec_dados()], com as colunas `regiao_codigo`, `regiao_nome` e
#'   `regiao_tipo`.
#' @param geo Tabela de ligação (por omissão [dgeec_geo()]).
#' @return `dados` com as colunas geográficas acrescentadas.
#' @export
enriquecer_geo <- function(dados, geo = NULL) {
  geo <- geo %||% dgeec_geo()
  if (!all(c("regiao_codigo", "regiao_nome", "regiao_tipo") %in% names(dados)))
    stop("`dados` não tem as colunas de região esperadas.", call. = FALSE)

  chave <- dplyr::tibble(
    .mun   = ifelse(dados$regiao_tipo == "Município", .norm_mun(dados$regiao_nome), NA_character_),
    .nuts1 = unname(.dgeec_nuts1[substr(dados$regiao_codigo, 1, 1)])
  )

  geo2 <- dplyr::rename(geo, .mun = "municipio", .nuts1 = "nuts1")
  out <- dplyr::bind_cols(dados, chave) |>
    dplyr::left_join(geo2, by = c(".mun", ".nuts1")) |>
    dplyr::select(-".mun") |>
    dplyr::rename(nuts1 = ".nuts1")

  out
}
