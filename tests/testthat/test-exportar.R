test_that("exportação escreve CSV e Parquet e ignora XLSX acima do limite", {
  df <- tibble::tibble(a = 1:3, b = letters[1:3])
  d <- tempfile()
  f <- dgeec_exportar(df, d, formatos = c("csv", "parquet", "xlsx"))
  expect_true(file.exists(paste0(d, ".csv")))
  expect_true(file.exists(paste0(d, ".parquet")))
  expect_true(file.exists(paste0(d, ".xlsx")))

  d2 <- tempfile()
  expect_warning(dgeec_exportar(df, d2, formatos = "xlsx", limite_xlsx = 1L))
  expect_false(file.exists(paste0(d2, ".xlsx")))
})
