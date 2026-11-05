## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", eval = FALSE)

## -----------------------------------------------------------------------------
# library(dgeecr)
# 
# cli <- DgeecClient$new(concorrencia = 8L)
# cli

## -----------------------------------------------------------------------------
# dgeec_paginas()
# 
# cli$dimensoes("pre_escolar")

## -----------------------------------------------------------------------------
# # Portugal + Monção, apenas o nível desagregado (Público/Privado x H/M)
# d <- cli$dados("pre_escolar", regioes = c("0", "101011604"))
# d
# 
# # Incluir também os totais somados ("Público e Privado", "Homens e Mulheres")
# cli$dados("pre_escolar", regioes = "0", incluir_totais = TRUE)

## -----------------------------------------------------------------------------
# d_geo <- enriquecer_geo(d)
# d_geo |> dplyr::distinct(regiao_codigo, regiao_nome, uls_1, uls_2, regiao_2024)

## -----------------------------------------------------------------------------
# # dgeec_exportar(d, "output/dgeec_pre_escolar", formatos = c("csv", "parquet"))

