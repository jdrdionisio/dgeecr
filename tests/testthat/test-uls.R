test_that("dgeec_uls e dgeec_regioes_saude devolvem catalogos coerentes", {
  u <- dgeec_uls()
  expect_s3_class(u, "tbl_df")
  expect_true(all(c("uls", "regiao_2024", "n_municipios", "municipios") %in% names(u)))
  expect_true("ULS do Alto Minho" %in% u$uls)

  r <- dgeec_regioes_saude()
  expect_equal(nrow(r), 7)
  expect_true(all(c("Norte", "Centro", "Lisboa e Vale do Tejo", "Alentejo",
                    "Algarve", "Açores", "Madeira") %in% r$regiao_2024))
})

test_that("dgeec_geo identifica ULS principal e n_uls", {
  g <- dgeec_geo()
  lx <- g[g$municipio == "lisboa", ]
  expect_true(lx$n_uls >= 2)
  expect_false(is.na(lx$uls_principal))
  expect_true(lx$uls_principal %in% c(lx$uls_1, lx$uls_2))
})

test_that("agregar_uls soma municipios e trata os repartidos", {
  dados <- tibble::tibble(
    pagina = "x", grupo = "g",
    regiao_codigo = c("101011601", "101011602", "104011106"),
    regiao_nome   = c("Arcos de Valdevez", "Caminha", "Lisboa"),
    regiao_tipo   = rep(dgeecr:::.lbl_municipio, 3),
    natureza_codigo = "1", natureza_nome = "Publico",
    genero_codigo = "1", genero_nome = "Homens",
    dimensao = "Idade", categoria_nivel = 1L, categoria = "Total",
    ano_letivo = "2024/25", valor = c(100, 200, 999)
  )
  a <- agregar_uls(dados, multiplas = "excluir")
  # Lisboa (repartida) e excluida; so a ULS do Alto Minho fica, com 300
  expect_equal(nrow(a), 1)
  expect_equal(a$valor, 300)
  expect_equal(a$n_municipios, 2)
  expect_true("Lisboa" %in% attr(a, "municipios_excluidos"))

  d <- agregar_uls(dados, multiplas = "duplicar")
  expect_gt(nrow(d), nrow(a))          # Lisboa aparece em varias ULS
})

test_that("agregar_regiao_saude agrega por regiao 2024", {
  dados <- tibble::tibble(
    pagina = "x", grupo = "g",
    regiao_codigo = c("101011601", "102030105"),
    regiao_nome   = c("Arcos de Valdevez", "Aveiro"),
    regiao_tipo   = rep(dgeecr:::.lbl_municipio, 2),
    natureza_codigo = "1", natureza_nome = "Publico",
    genero_codigo = "1", genero_nome = "Homens",
    dimensao = "Idade", categoria_nivel = 1L, categoria = "Total",
    ano_letivo = "2024/25", valor = c(100, 50)
  )
  rs <- agregar_regiao_saude(dados)
  expect_true("Norte" %in% rs$regiao_2024)
  expect_true("Centro" %in% rs$regiao_2024)
})
