test_that("dgeec_regioes devolve codigo e nome das regioes", {
  skip_on_cran()
  r <- try(dgeec_regioes(), silent = TRUE)
  skip_if(inherits(r, "try-error"), "sem rede")
  expect_true(all(c("regiao_codigo", "regiao_nome", "regiao_tipo", "regiao_nivel") %in% names(r)))
  expect_true("Portugal" %in% r$regiao_nome)
  expect_true(any(r$regiao_tipo == dgeecr:::.lbl_municipio))
  expect_equal(r$regiao_codigo[r$regiao_nome == "Portugal"], "0")
})

test_that("nomes resolvem para o mesmo codigo que os codigos", {
  # usa uma tabela de dimensoes sintetica para nao depender da rede
  meta <- list(dimensoes = tibble::tibble(
    select = rep("ListaRegiao", 5),
    codigo = c("0", "1", "11", "101011604", "104011106"),
    rotulo = c("Portugal", "NUTS I: Continente", "NUTS II: Norte",
               "Moncao", "Lisboa"),
    nivel  = c(0L, 0L, 1L, 3L, 3L)
  ))

  expect_equal(dgeecr:::.resolver_regioes(meta, "Portugal"), "0")
  expect_equal(dgeecr:::.resolver_regioes(meta, "moncao"), "101011604")
  # acentos (construido sem literais non-ASCII)
  expect_equal(dgeecr:::.resolver_regioes(meta, paste0("Mon", intToUtf8(0xE7), "ao")), "101011604")
  expect_equal(dgeecr:::.resolver_regioes(meta, "Norte"), "11")
  expect_equal(dgeecr:::.resolver_regioes(meta, "NUTS II: Norte"), "11")
  expect_equal(dgeecr:::.resolver_regioes(meta, "101011604"), "101011604") # codigo passa
  expect_equal(dgeecr:::.resolver_regioes(meta, c("Portugal", "Lisboa")), c("0", "104011106"))
})

test_that("nomes desconhecidos ou ambiguos dao erro claro", {
  meta <- list(dimensoes = tibble::tibble(
    select = rep("ListaRegiao", 3),
    codigo = c("0", "301011601", "302011601"),
    rotulo = c("Portugal", "Calheta", "Calheta"),
    nivel  = c(0L, 3L, 3L)
  ))
  expect_error(dgeecr:::.resolver_regioes(meta, "Vila Nova"), "desconhecida")
  expect_error(dgeecr:::.resolver_regioes(meta, "Calheta"), "ambiguo")
})
