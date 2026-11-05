test_that("durante a verificacao da CRAN o paralelismo e limitado a 2", {
  old <- Sys.getenv("_R_CHECK_LIMIT_CORES_", unset = NA_character_)
  on.exit({
    if (is.na(old)) Sys.unsetenv("_R_CHECK_LIMIT_CORES_")
    else Sys.setenv("_R_CHECK_LIMIT_CORES_" = old)
  }, add = TRUE)

  Sys.setenv("_R_CHECK_LIMIT_CORES_" = "true")
  cli <- DgeecClient$new(nucleos = 16L, concorrencia = 8L,
                         cache_dir = file.path(tempdir(), "cores"))
  expect_lte(cli$nucleos, 2L)
  expect_lte(cli$concorrencia, 2L)
  expect_true(dgeecr:::.limite_cores_cran())

  # fora da verificacao mantem-se o que o utilizador pediu
  Sys.unsetenv("_R_CHECK_LIMIT_CORES_")
  expect_false(dgeecr:::.limite_cores_cran())
  cli2 <- DgeecClient$new(nucleos = 16L, concorrencia = 8L,
                          cache_dir = file.path(tempdir(), "cores2"))
  expect_equal(cli2$nucleos, 16L)
  expect_equal(cli2$concorrencia, 8L)
})

test_that("dgeec_geo expoe a nomenclatura do BI-CSP", {
  g <- dgeec_geo()
  expect_true("uls_hierarquia_csp" %in% names(g))
  expect_true(any(!is.na(g$uls_hierarquia_csp)))
})
