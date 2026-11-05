# Cliente principal -----------------------------------------------------

# Constroi as combinacoes de codigos a pedir para uma pagina.
.construir_combinacoes <- function(meta, regioes = NULL, natureza = NULL,
                                   genero = NULL, orientacao = NULL,
                                   incluir_totais = FALSE) {
  dims <- intersect(names(.dgeec_dimensoes), unique(meta$dimensoes$select))
  escolhas <- list(ListaRegiao = regioes, ListaNatureza = natureza,
                   ListaGenero = genero, ListaOrientacao = orientacao)

  lst <- list()
  for (d in dims) {
    disp <- meta$dimensoes$codigo[meta$dimensoes$select == d]
    escolha <- escolhas[[d]]
    if (is.null(escolha)) {
      escolha <- if (d == "ListaRegiao" || incluir_totais) disp
                 else intersect(.dgeec_desagregado[[d]], disp)
    }
    escolha <- as.character(escolha)
    faltam <- setdiff(escolha, disp)
    if (length(faltam))
      stop(sprintf("Codigo(s) invalido(s) para %s: %s", d, paste(faltam, collapse = ", ")),
           call. = FALSE)
    if (length(escolha) == 0)
      stop(sprintf("Sem codigos para %s.", d), call. = FALSE)
    lst[[d]] <- escolha
  }
  tidyr::expand_grid(!!!lst)
}

# Junta rotulos e deriva tipo/nivel da regiao.
.rotular_combos <- function(combos, meta) {
  out <- combos
  for (d in names(.dgeec_dimensoes)) {
    if (!d %in% names(combos)) next
    dim <- .dgeec_dimensoes[[d]]
    tb <- meta$dimensoes[meta$dimensoes$select == d, ]
    out[[paste0(dim, "_codigo")]] <- combos[[d]]
    out[[paste0(dim, "_nome")]]   <- tb$rotulo[match(combos[[d]], tb$codigo)]
  }
  if ("regiao_nome" %in% names(out)) {
    out$regiao_tipo  <- .tipo_regiao(out$regiao_nome)
    out$regiao_nivel <- match(out$regiao_tipo,
                              c("Portugal", "NUTS I", "NUTS II", "NUTS III", .lbl_municipio)) - 1L
    out$regiao_nome  <- stringr::str_remove(out$regiao_nome, "^NUTS (I|II|III):\\s*") |>
      stringr::str_squish()
  }
  out
}

# Chave de cache (ficheiro) para uma combinacao.
.chave_cache <- function(cache_dir, pagina, codigos) {
  file.path(cache_dir, pagina,
            paste(sprintf("%s-%s", names(codigos), unlist(codigos)), collapse = "_")) |>
    paste0(".html")
}

# Um pedido POST para o formulario da pagina.
.dgeec_pedido <- function(path, combo, timeout, tentativas) {
  args <- as.list(combo); args$Submit <- "Atualizar"
  do.call(httr2::req_body_form, c(list(
    httr2::request(.dgeec_base) |>
      httr2::req_url_path_append(path) |>
      httr2::req_user_agent(.dgeec_ua) |>
      httr2::req_timeout(timeout) |>
      httr2::req_retry(max_tries = tentativas)
  ), args))
}

#' Cliente DGEEC
#'
#' Cliente R6 para o portal "Regioes em Numeros - Educacao". Gere a
#' paralelizacao (httr2 na rede, `parallel` no parsing), o cache em disco
#' (com resume) e a conversao em tabela longa.
#'
#' @export
#' @examples
#' \donttest{
#' cli <- DgeecClient$new()
#' d <- cli$dados("pre_escolar", regioes = c("0", "101011604"))
#' }
DgeecClient <- R6Class(
  "DgeecClient",
  public = list(
    #' @field cache_dir Pasta de cache (NULL = `tools::R_user_dir("dgeecr","cache")`).
    cache_dir = NULL,
    #' @field concorrencia No de pedidos simultaneos (rede).
    concorrencia = 8L,
    #' @field nucleos No de processos para o parsing (NULL = todos menos 2).
    nucleos = NULL,
    #' @field timeout Timeout por pedido (s).
    timeout = 45L,
    #' @field tentativas Tentativas por pedido.
    tentativas = 3L,
    #' @field usar_cache Reutilizar HTML ja descarregado?
    usar_cache = TRUE,
    #' @field cache_dados Guardar/ler tambem o resultado ja interpretado (RDS)?
    cache_dados = TRUE,
    #' @field lote No de pedidos por lote.
    lote = 250L,

    #' @description Cria um cliente.
    #' @param cache_dir Pasta de cache.
    #' @param concorrencia No de pedidos simultaneos.
    #' @param nucleos No de processos para o parsing.
    #' @param timeout Timeout por pedido (s).
    #' @param tentativas Tentativas por pedido.
    #' @param usar_cache Reutilizar cache em disco.
    #' @param cache_dados Guardar/ler o resultado interpretado.
    #' @param lote No de pedidos por lote.
    initialize = function(cache_dir = NULL, concorrencia = 8L, nucleos = NULL,
                          timeout = 45L, tentativas = 3L, usar_cache = TRUE,
                          cache_dados = TRUE, lote = 250L) {
      self$cache_dir    <- cache_dir %||% tools::R_user_dir("dgeecr", which = "cache")
      self$concorrencia <- as.integer(concorrencia)
      self$nucleos      <- nucleos %||%
        max(1L, detectCores(logical = TRUE) - 2L)
      self$timeout      <- as.integer(timeout)
      self$tentativas   <- as.integer(tentativas)
      self$usar_cache   <- isTRUE(usar_cache)
      self$cache_dados  <- isTRUE(cache_dados)
      self$lote         <- as.integer(lote)
      dir.create(self$cache_dir, showWarnings = FALSE, recursive = TRUE)
      invisible(self)
    },

    #' @description Catalogo de paginas.
    paginas = function() dgeec_paginas(),

    #' @description Dimensoes (filtros) de uma pagina.
    #' @param pagina Id de pagina.
    dimensoes = function(pagina) dgeec_dimensoes(pagina, timeout = self$timeout),

    #' @description Catalogo de regioes (codigo e nome).
    #' @param pagina Pagina de onde ler a lista.
    regioes = function(pagina = "pre_escolar") dgeec_regioes(pagina, timeout = self$timeout),

    #' @description Extrai dados de uma pagina.
    #' @param pagina Id de pagina (ver [dgeec_paginas()]).
    #' @param regioes Codigos **ou nomes** de regiao (NULL = todas). Os nomes
    #'   podem ser de Portugal, NUTS I/II/III ou municipio; ver
    #'   [dgeec_regioes()]. Ex.: `regioes = c("Portugal", "Moncao")`.
    #' @param uls Nome(s) de ULS (ver [dgeec_uls()]) a que restringir a extracao.
    #' @param regiao_saude Nome(s) de regiao de saude 2024 (ver [dgeec_regioes_saude()]).
    #' @param natureza Codigos de natureza (NULL = desagregado 1/2, ou todos se `incluir_totais`).
    #' @param genero Codigos de genero (NULL = desagregado 1/2, ou todos se `incluir_totais`).
    #' @param orientacao Codigos de orientacao (NULL = desagregado 10/20, ou todos se `incluir_totais`).
    #' @param incluir_totais Incluir tambem os niveis totais (0/...)?
    #' @param progress Mostrar progresso.
    #' @return Um `tibble` longo (1 linha = 1 observacao).
    dados = function(pagina, regioes = NULL, uls = NULL, regiao_saude = NULL,
                     natureza = NULL, genero = NULL, orientacao = NULL,
                     incluir_totais = FALSE, progress = TRUE) {
      meta  <- .dgeec_meta(pagina, timeout = self$timeout, tentativas = self$tentativas)

      if (!is.null(uls) || !is.null(regiao_saude)) {
        regioes <- .regioes_alvo(meta, dgeec_geo(), uls = uls, regiao_saude = regiao_saude)
        if (length(regioes) == 0)
          stop("Nenhum municipio corresponde a ULS/regiao pedida.", call. = FALSE)
      }

      # aceita nomes (ex. "Moncao", "Norte", "Portugal") ou codigos
      if (!is.null(regioes)) regioes <- .resolver_regioes(meta, regioes)

      combos <- .construir_combinacoes(meta, regioes, natureza, genero, orientacao,
                                       incluir_totais)
      rot <- .rotular_combos(combos, meta)

      ctx <- dplyr::bind_cols(
        tibble::tibble(pagina = meta$id, grupo = meta$grupo),
        rot |> dplyr::select(dplyr::any_of(c(
          paste0(.dgeec_dimensoes, "_codigo"),
          paste0(.dgeec_dimensoes, "_nome"),
          "regiao_tipo", "regiao_nivel")))
      )

      # Cache do resultado ja interpretado (evita reler/parsear HTML).
      f_dados <- file.path(self$cache_dir, meta$id,
                           paste0("_dados_", rlang::hash(combos), ".rds"))
      if (self$usar_cache && self$cache_dados && file.exists(f_dados)) {
        if (progress) message("  cache de dados: leitura do resultado interpretado.")
        return(readRDS(f_dados))
      }

      chaves <- purrr::pmap_chr(combos, function(...) {
        codigos <- c(...); .chave_cache(self$cache_dir, meta$id, codigos)
      })

      n_reg <- if ("ListaRegiao" %in% names(combos)) length(unique(combos$ListaRegiao)) else 1L
      if (progress) message(sprintf("[%s] %d combinacoes | regioes: %d | nucleos: %d",
                                    meta$id, nrow(combos), n_reg, self$nucleos))

      self$.descarregar(meta$path, combos, chaves, progress = progress)

      if (progress) message("  a interpretar respostas (paralelo)...")
      dados <- self$.parsear(chaves, ctx)

      dados <- dplyr::bind_rows(dados)
      if (nrow(dados) == 0) return(dados)

      dados <- dados |>
        dplyr::mutate(pagina = as.character(pagina), grupo = as.character(grupo)) |>
        dplyr::arrange(pagina, dplyr::across(dplyr::any_of(c("regiao_nivel", "regiao_nome"))),
                       categoria_nivel, categoria, ano_letivo)

      if (self$usar_cache && self$cache_dados) {
        dir.create(dirname(f_dados), showWarnings = FALSE, recursive = TRUE)
        saveRDS(dados, f_dados)
      }
      dados
    },

    #' @description Exporta um data frame em CSV/Parquet/XLSX.
    #' @param dados `tibble` a exportar.
    #' @param ficheiro Caminho base (sem extensao).
    #' @param formatos Formatos a escrever.
    #' @param limite_xlsx Maximo de linhas para gerar XLSX (limite do Excel).
    exportar = function(dados, ficheiro, formatos = c("csv", "parquet", "xlsx"),
                        limite_xlsx = 1048575L) {
      dgeec_exportar(dados, ficheiro, formatos = formatos, limite_xlsx = limite_xlsx)
    },

    #' @description Tamanho do cache em disco.
    tamanho_cache = function() dgeec_tamanho_cache(self$cache_dir),

    #' @description Limpa o cache em disco.
    #' @param ... Passado a [dgeec_limpar_cache()] (`html`, `dados`, `confirmar`).
    limpar_cache = function(...) dgeec_limpar_cache(self$cache_dir, ...),

    # interno: interpreta os HTML do cache, em paralelo
    .parsear = function(chaves, ctx) {
      uma <- function(i) {
        f <- chaves[i]
        if (!file.exists(f) || file.info(f)$size < 1) return(NULL)
        html <- tryCatch(xml2::read_html(f, encoding = "UTF-8"), error = function(e) NULL)
        .parse_html(html, ctx[i, , drop = FALSE])
      }
      idx <- seq_len(nrow(ctx))
      if (self$nucleos > 1L && .Platform$OS.type == "unix") {
        mclapply(idx, uma, mc.cores = self$nucleos, mc.preschedule = FALSE)
      } else {
        lapply(idx, uma)
      }
    },

    # interno: descarrega o que falta para o cache, em paralelo
    .descarregar = function(path, combos, chaves, progress = TRUE) {
      existe <- file.exists(chaves) & file.info(chaves)$size > 0
      existe[is.na(existe)] <- FALSE
      faltam <- which(!existe)
      if (self$usar_cache && length(faltam) == 0) {
        if (progress) message("  cache completo; nada a descarregar.")
        return(invisible(NULL))
      }
      alvo <- if (self$usar_cache) faltam else seq_len(nrow(combos))
      dir.create(dirname(chaves[1]), showWarnings = FALSE, recursive = TRUE)

      lotes <- split(alvo, ceiling(seq_along(alvo) / self$lote))
      for (li in seq_along(lotes)) {
        idx <- lotes[[li]]
        if (progress) message(sprintf("  lote %d/%d (%d pedidos)", li, length(lotes), length(idx)))
        reqs <- purrr::map(idx, function(i) .dgeec_pedido(path, combos[i, ], self$timeout, self$tentativas))
        res  <- httr2::req_perform_parallel(reqs, on_error = "continue",
                                            max_active = self$concorrencia, progress = FALSE)
        for (j in seq_along(idx)) {
          r <- res[[j]]
          if (!inherits(r, "httr2_response") || httr2::resp_status(r) != 200) next
          con <- file(chaves[idx[j]], "wb")
          writeBin(httr2::resp_body_raw(r), con)
          close(con)
        }
      }
      invisible(NULL)
    }
  )
)
