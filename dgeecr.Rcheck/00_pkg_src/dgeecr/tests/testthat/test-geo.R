test_that("dgeec_geo devolve um registo por município com ULS 1/2", {
  g <- dgeec_geo()
  expect_s3_class(g, "tbl_df")
  expect_true(all(c("uls_1", "uls_2", "regiao_2024", "nuts2", "nuts3") %in% names(g)))
  # Lisboa tem mais do que uma ULS
  lx <- g[g$municipio == "lisboa", ]
  expect_true(nrow(lx) >= 1)
  expect_true(all(lx$n_uls >= 2))
  expect_false(is.na(lx$uls_1[1]))
  expect_false(is.na(lx$uls_2[1]))
})

test_that("enriquecer_geo liga municípios e distingue Calheta/Lagoa", {
  dados <- tibble::tibble(
    regiao_codigo = c("1", "201014501", "301013101", "104011106"),
    regiao_nome   = c("Continente", "Calheta", "Calheta", "Lisboa"),
    regiao_tipo   = c("NUTS I", "Município", "Município", "Município")
  )
  out <- enriquecer_geo(dados)
  # NUTS I não é enriquecido
  expect_true(is.na(out$uls_1[out$regiao_codigo == "1"]))
  # as duas Calheta resolvem para NUTS diferentes
  expect_equal(out$nuts1[out$regiao_codigo == "201014501"], "Açores")
  expect_equal(out$nuts1[out$regiao_codigo == "301013101"], "Madeira")
  expect_equal(out$uls_1[out$regiao_codigo == "104011106"], "ULS de Lisboa Ocidental")
})
