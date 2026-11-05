# Constantes internas do pacote ----------------------------------------

.dgeec_base <- "https://estatisticas-educacao.dgeec.medu.pt/regioesemnumeros/"
.dgeec_ua   <- "Mozilla/5.0 (X11; Linux x86_64) R-httr2"

# <select> -> nome da coluna de saida, por ordem canonica.
.dgeec_dimensoes <- c(
  ListaRegiao     = "regiao",
  ListaNatureza   = "natureza",
  ListaGenero     = "genero",
  ListaOrientacao = "orientacao"
)

# Por omissao extrai-se apenas o nivel DESAGREGADO (sem os totais somados,
# que sao derivaveis): Publico/Privado x Homens/Mulheres x Jovens/Adultos.
.dgeec_desagregado <- list(
  ListaNatureza   = c("1", "2"),
  ListaGenero     = c("1", "2"),
  ListaOrientacao = c("10", "20")
)

# Primeiro digito do codigo DGEEC de regiao -> NUTS I.
.dgeec_nuts1 <- c(`1` = "Continente", `2` = "A\u00e7ores", `3` = "Madeira")

# Concatenacao segura (equivalente a `%||%`).
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L || all(is.na(x))) y else x
