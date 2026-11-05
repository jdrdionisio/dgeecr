# Catalogo de paginas ---------------------------------------------------

.dgeec_paginas <- tibble::tribble(
  ~id,                     ~grupo,                 ~path,                                    ~descricao,
  "pre_escolar",           "Alunos matriculados",  "alunos/pre_escolar.asp",                 "Crian\u00e7as inscritas na educa\u00e7\u00e3o pr\u00e9-escolar, por ano letivo e idade",
  "basico_total",          "Alunos matriculados",  "alunos/ensino_basico/total.asp",         "Alunos matriculados no ensino b\u00e1sico (total)",
  "basico_1ciclo",         "Alunos matriculados",  "alunos/ensino_basico/1ciclo.asp",        "Alunos matriculados no 1.\u00ba ciclo do ensino b\u00e1sico",
  "basico_2ciclo",         "Alunos matriculados",  "alunos/ensino_basico/2ciclo.asp",        "Alunos matriculados no 2.\u00ba ciclo do ensino b\u00e1sico",
  "basico_3ciclo",         "Alunos matriculados",  "alunos/ensino_basico/3ciclo.asp",        "Alunos matriculados no 3.\u00ba ciclo do ensino b\u00e1sico",
  "secundario",            "Alunos matriculados",  "alunos/ensino_secundario.asp",           "Alunos matriculados no ensino secund\u00e1rio",
  "caracterizacao_geral",  "Caracteriza\u00e7\u00e3o geral", "caracterizacao_geral.asp",               "Caracteriza\u00e7\u00e3o geral da educa\u00e7\u00e3o por regi\u00e3o",
  "estabelecimentos",      "Estabelecimentos",     "estabelecimentos.asp",                   "Estabelecimentos de ensino por tipologia",
  "recursos_tecnologicos", "Indicadores",          "indicadores/recursos_tecnologicos.asp",  "N\u00famero m\u00e9dio de alunos por computador",
  "resultados_escolares",  "Indicadores",          "indicadores/resultados_escolares.asp",   "Resultados escolares por n\u00edvel e oferta",
  "taxas_escolarizacao",   "Indicadores",          "indicadores/taxas_escolarizacao.asp",    "Taxas de escolariza\u00e7\u00e3o",
  "pessoal_docente",       "Recursos humanos",     "recursos_humanos/pessoal_docente.asp",   "Pessoal docente",
  "pessoal_nao_docente",   "Recursos humanos",     "recursos_humanos/pessoal_nao_docente.asp","Pessoal n\u00e3o docente"
)

#' Catalogo de paginas disponiveis
#'
#' Devolve o conjunto de paginas (tabelas) publicadas no portal.
#'
#' @return Um `tibble` com as colunas `id`, `grupo`, `path` e `descricao`.
#' @export
#' @examples
#' dgeec_paginas()
dgeec_paginas <- function() {
  .dgeec_paginas
}
