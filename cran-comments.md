# Comentários para a submissão à CRAN

## Versão

0.1.2 — **primeira submissão**.

## Verificação

`R CMD check --as-cran` (R 4.6.0, Linux x86_64): **0 ERROR, 0 WARNING, 1 NOTE**
(o NOTE é o "New submission" habitual numa primeira submissão).

```
* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Joao Dionisio <joaodrdionisio@gmail.com>'

New submission
* checking top-level files ... OK
* checking examples with --run-donttest ... OK
* checking tests ... OK
* checking re-building of vignette outputs ... OK
Status: 1 NOTE
```

## Notas de implementação

- O pacote descarrega dados do portal público "Regiões em Números - Educação"
  da DGEEC (<https://estatisticas-educacao.dgeec.medu.pt/regioesemnumeros/>).
  Toda a rede está em **exemplos `\dontrun`** e nos testes protegidos por
  `skip_on_cran()`, pelo que `R CMD check` não faz pedidos externos. Os testes
  usam fixtures HTML reais guardadas em `tests/testthat/fixtures/`.
- **Uso de cores**: conforme a política da CRAN ("never use more than two
  simultaneously"), quando `_R_CHECK_LIMIT_CORES_` está definido — como durante
  a verificação — o número de processos de parsing e de pedidos simultâneos é
  limitado a 2. Fora da verificação, os valores são os pedidos pelo utilizador
  (`nucleos`, por omissão cores-2; `concorrencia`, 8).
- O parsing em paralelo usa `parallel::mclapply` (fork), com recurso a `lapply`
  em plataformas sem fork (Windows).
- Os pedidos ao portal são feitos em lotes sequenciais com cache em disco, para
  minimizar o número de acessos ao serviço externo.

## Língua

O `Title` e o `Description` estão em inglês (é o que a CRAN mostra na página do
pacote). As páginas de ajuda, a vignette e o README estão em português, pelo que
o DESCRIPTION declara `Language: pt` (campo previsto no 'Writing R Extensions'
para documentação que não está em inglês).

## Propriedade intelectual dos componentes

Todo o código é do autor. O único componente de terceiros é o ficheiro de
ligação geográfica `inst/extdata/geo_linkage_2024_v8.csv`, compilado por
terceiros a partir de legislação e publicações oficiais portuguesas e incluído
com autorização de partilha. As fontes estão documentadas em `inst/COPYRIGHTS`
e referidas no campo `Copyright` do DESCRIPTION.

## Licença

Apache License (>= 2). O texto completo está em `LICENSE.md` no repositório;
o pacote identifica a licença pelo nome padrão, pelo que `LICENSE.md` é
excluído do tarball (`.Rbuildignore`), como é prática corrente.
