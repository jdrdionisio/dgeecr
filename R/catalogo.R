# Catálogo de páginas ---------------------------------------------------

.dgeec_paginas <- tibble::tribble(
  ~id,                     ~grupo,                 ~path,                                    ~descricao,
  "pre_escolar",           "Alunos matriculados",  "alunos/pre_escolar.asp",                 "Crianças inscritas na educação pré-escolar, por ano letivo e idade",
  "basico_total",          "Alunos matriculados",  "alunos/ensino_basico/total.asp",         "Alunos matriculados no ensino básico (total)",
  "basico_1ciclo",         "Alunos matriculados",  "alunos/ensino_basico/1ciclo.asp",        "Alunos matriculados no 1.º ciclo do ensino básico",
  "basico_2ciclo",         "Alunos matriculados",  "alunos/ensino_basico/2ciclo.asp",        "Alunos matriculados no 2.º ciclo do ensino básico",
  "basico_3ciclo",         "Alunos matriculados",  "alunos/ensino_basico/3ciclo.asp",        "Alunos matriculados no 3.º ciclo do ensino básico",
  "secundario",            "Alunos matriculados",  "alunos/ensino_secundario.asp",           "Alunos matriculados no ensino secundário",
  "caracterizacao_geral",  "Caracterização geral", "caracterizacao_geral.asp",               "Caracterização geral da educação por região",
  "estabelecimentos",      "Estabelecimentos",     "estabelecimentos.asp",                   "Estabelecimentos de ensino por tipologia",
  "recursos_tecnologicos", "Indicadores",          "indicadores/recursos_tecnologicos.asp",  "Número médio de alunos por computador",
  "resultados_escolares",  "Indicadores",          "indicadores/resultados_escolares.asp",   "Resultados escolares por nível e oferta",
  "taxas_escolarizacao",   "Indicadores",          "indicadores/taxas_escolarizacao.asp",    "Taxas de escolarização",
  "pessoal_docente",       "Recursos humanos",     "recursos_humanos/pessoal_docente.asp",   "Pessoal docente",
  "pessoal_nao_docente",   "Recursos humanos",     "recursos_humanos/pessoal_nao_docente.asp","Pessoal não docente"
)

#' Catálogo de páginas disponíveis
#'
#' Devolve o conjunto de páginas (tabelas) publicadas no portal.
#'
#' @return Um `tibble` com as colunas `id`, `grupo`, `path` e `descricao`.
#' @export
#' @examples
#' dgeec_paginas()
dgeec_paginas <- function() {
  .dgeec_paginas
}
