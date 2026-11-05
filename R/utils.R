# Constantes internas do pacote ----------------------------------------

.dgeec_base <- "https://estatisticas-educacao.dgeec.medu.pt/regioesemnumeros/"
.dgeec_ua   <- "Mozilla/5.0 (X11; Linux x86_64) R-httr2"

# <select> -> nome da coluna de saída, por ordem canónica.
.dgeec_dimensoes <- c(
  ListaRegiao     = "regiao",
  ListaNatureza   = "natureza",
  ListaGenero     = "genero",
  ListaOrientacao = "orientacao"
)

# Por omissão extrai-se apenas o nível DESAGREGADO (sem os totais somados,
# que são deriváveis): Público/Privado x Homens/Mulheres x Jovens/Adultos.
.dgeec_desagregado <- list(
  ListaNatureza   = c("1", "2"),
  ListaGenero     = c("1", "2"),
  ListaOrientacao = c("10", "20")
)

# Primeiro dígito do código DGEEC de região -> NUTS I.
.dgeec_nuts1 <- c(`1` = "Continente", `2` = "Açores", `3` = "Madeira")

# Concatenação segura (equivalente a `%||%`).
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L || all(is.na(x))) y else x
