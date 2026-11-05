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
- O parsing em paralelo usa `parallel::mclapply` (fork), com recurso a `lapply`
  em plataformas sem fork (Windows).
- O ficheiro de ligação geográfica em `inst/extdata/` deriva de divisões
  administrativas e de saúde portuguesas (DICOFRE), sem dados pessoais.

## Licença

Apache License (>= 2). O texto completo está em `LICENSE.md` no repositório;
o pacote identifica a licença pelo nome padrão, pelo que `LICENSE.md` é
excluído do tarball (`.Rbuildignore`), como é prática corrente.
