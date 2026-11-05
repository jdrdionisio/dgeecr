test_that("catálogo tem as páginas esperadas", {
  p <- dgeec_paginas()
  expect_s3_class(p, "tbl_df")
  expect_true(all(c("id", "grupo", "path", "descricao") %in% names(p)))
  expect_gte(nrow(p), 13)
  expect_true("pre_escolar" %in% p$id)
  expect_setequal(unique(p$grupo),
                  c("Alunos matriculados", "Caracterização geral", "Estabelecimentos",
                    "Indicadores", "Recursos humanos"))
})
