# Gestao do cache em disco ----------------------------------------------

#' Pasta de cache por omissao
#'
#' @return O caminho da pasta de cache do pacote.
#' @export
dgeec_cache_dir <- function() tools::R_user_dir("dgeecr", which = "cache")

#' Tamanho do cache em disco
#'
#' @param dir Pasta de cache (NULL = [dgeec_cache_dir()]).
#' @return Um `tibble` por pagina (ou `"(outros)"`), com `n_ficheiros`,
#'   `bytes` e `mb`, mais o total em atributo `total`.
#' @export
dgeec_tamanho_cache <- function(dir = NULL) {
  dir <- dir %||% dgeec_cache_dir()
  vazio <- tibble::tibble(pagina = character(), n_ficheiros = integer(),
                          bytes = numeric(), mb = numeric())
  if (!dir.exists(dir)) { attr(vazio, "total") <- c(ficheiros = 0, mb = 0); return(vazio) }

  fs <- list.files(dir, recursive = TRUE, full.names = TRUE, all.files = TRUE)
  if (length(fs) == 0) { attr(vazio, "total") <- c(ficheiros = 0, mb = 0); return(vazio) }

  info <- file.info(fs)
  rel  <- sub(paste0(dir, "/"), "", fs, fixed = TRUE)
  pag  <- vapply(strsplit(rel, "/", fixed = TRUE),
                 function(x) if (length(x) > 1) x[1] else "(outros)", "")

  out <- tibble::tibble(pagina = pag, bytes = info$size) |>
    dplyr::group_by(.data$pagina) |>
    dplyr::summarise(n_ficheiros = dplyr::n(), bytes = sum(.data$bytes, na.rm = TRUE),
                     .groups = "drop") |>
    dplyr::mutate(mb = round(.data$bytes / 1024^2, 1)) |>
    dplyr::arrange(dplyr::desc(.data$bytes))
  attr(out, "total") <- c(ficheiros = nrow(info), mb = round(sum(info$size, na.rm = TRUE) / 1024^2, 1))
  out
}

#' Limpar o cache em disco
#'
#' Remove o HTML cru descarregado e/ou o resultado ja interpretado (RDS).
#'
#' @param dir Pasta de cache (NULL = [dgeec_cache_dir()]).
#' @param html Remover o HTML cru?
#' @param dados Remover os resultados interpretados (RDS)?
#' @param confirmar Pedir confirmacao (por omissao, apenas em sessao interativa).
#' @return (invisivelmente) o numero de ficheiros removidos.
#' @export
dgeec_limpar_cache <- function(dir = NULL, html = TRUE, dados = TRUE,
                               confirmar = interactive()) {
  dir <- dir %||% dgeec_cache_dir()
  if (!dir.exists(dir)) { message("Cache inexistente: ", dir); return(invisible(0L)) }

  pats <- c(if (isTRUE(html)) "\\.html$", if (isTRUE(dados)) "_dados_.*\\.rds$")
  if (length(pats) == 0) stop("Nada selecionado para limpar.", call. = FALSE)

  fs <- list.files(dir, recursive = TRUE, full.names = TRUE,
                   pattern = paste(pats, collapse = "|"))
  if (length(fs) == 0) { message("Nada a limpar em ", dir); return(invisible(0L)) }

  bytes <- sum(file.info(fs)$size, na.rm = TRUE)
  if (isTRUE(confirmar)) {
    ans <- utils::askYesNo(sprintf("Apagar %d ficheiros (%.1f MB) de %s?",
                                   length(fs), bytes / 1024^2, dir))
    if (!isTRUE(ans)) { message("Cancelado."); return(invisible(0L)) }
  }

  ok <- file.remove(fs)
  # remove diretorias que ficaram vazias
  dirs <- list.dirs(dir, recursive = TRUE)
  for (d in rev(dirs)) {
    if (identical(normalizePath(d), normalizePath(dir, mustWork = FALSE))) next
    if (length(list.files(d, all.files = TRUE, no.. = TRUE)) == 0) unlink(d, recursive = TRUE)
  }
  message(sprintf("Removidos %d ficheiros (%.1f MB).", sum(ok), bytes / 1024^2))
  invisible(sum(ok))
}
