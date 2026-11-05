# Testes de parsing offline, usando uma resposta guardada como fixture.

fixture <- function(nome) {
  testthat::test_path("fixtures", nome)
}

test_that("parse de uma resposta gera a tabela longa esperada", {
  html <- xml2::read_html(fixture("pre_escolar_pt.html"), encoding = "UTF-8")
  ctx <- tibble::tibble(
    pagina = "pre_escolar", grupo = "Alunos matriculados",
    regiao_codigo = "0", regiao_nome = "Portugal",
    natureza_codigo = "0", natureza_nome = "Público e Privado",
    genero_codigo = "0", genero_nome = "Homens e Mulheres",
    regiao_tipo = "Portugal", regiao_nivel = 0L
  )
  d <- dgeecr:::.parse_html(html, ctx)
  expect_s3_class(d, "tbl_df")
  expect_true(all(c("dimensao", "categoria", "ano_letivo", "valor") %in% names(d)))
  # 5 categorias x 10 anos
  expect_equal(nrow(d), 50)
  expect_equal(unique(d$dimensao), "Idade")
  expect_equal(d$valor[d$categoria == "Total" & d$ano_letivo == "2015/16"], 259850)
})

test_that("números com separador de milhares são lidos", {
  expect_equal(dgeecr:::.para_num(c("8 786", "259 850", "90.6", "")),
               c(8786, 259850, 90.6, NA))
})
