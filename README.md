# Gestão de Stock e Encomendas

Projeto semestral de Programação Funcional (Haskell). 

## Descrição

Sistema que gere o inventário de um armazém e as encomendas de reposição a
fornecedores: sabe que produtos estão abaixo do stock mínimo, quanto falta
pedir, quanto custa uma encomenda e atualiza o stock quando uma encomenda é
recebida.

**Utilizadores:** responsável de armazém / compras de uma pequena empresa.

## Estado: Fase 1 — Modelação e núcleo funcional

Implementado:

- Modelo de domínio (`Model.hs`): `Produto`, `Fornecedor`, `Encomenda`,
  `Linha`, `EstadoEncomenda`, `Categoria`, `Armazem`.
- Núcleo funcional puro (`Domain.hs`), com pattern matching, guards e recursão:
  pesquisa, valor de stock, produtos abaixo do mínimo, quantidade a solicitar,
  total de encomendas, receber/cancelar encomendas.
- Dados de demonstração (`DadosTeste.hs`).
- Testes (`test/Spec.hs`, 30 casos, sem dependências externas).

Previsto para as fases seguintes:

| Fase | Evolução |
|------|----------|
| 2 | Refatorar com `map`/`filter`/`foldr`, composição, estatísticas e rankings, validação com `Either`, mais testes |
| 3 | Leitura/escrita de ficheiros, parsing e validação, menu em terminal, relatórios, relatório final |

## Requisitos

- GHC (≥ 9.0) e Cabal (≥ 3.0). Não são necessárias bibliotecas além da `base`.

## Compilar e executar

```bash
cabal build
cabal run stock-encomendas     # demonstração
cabal test                     # testes
```

Sem Cabal:

```bash
ghc -isrc -outputdir build -o demo app/Main.hs && ./demo
ghc -isrc -outputdir build -o spec test/Spec.hs && ./spec
```

> No Windows, se os acentos aparecerem mal, execute `chcp 65001` antes.

## Estrutura

```
├── README.md
├── cabal.project
├── stock-encomendas.cabal
├── src/
│   ├── Model.hs        tipos do domínio
│   ├── Domain.hs       lógica pura (recursão, pattern matching)
│   └── DadosTeste.hs   dados de demonstração
├── app/Main.hs         demonstração (único módulo com IO)
├── test/Spec.hs        testes
├── data/               ficheiros de dados (Fase 3)
└── docs/               relatório (Fase 3)
```

## Decisões de modelação

- Preços em **cêntimos** (`Int`) para evitar erros de vírgula flutuante.
- Estado do armazém como um valor imutável (`Armazem`); cada operação devolve
  um novo `Armazem`.
- `Maybe` para ausência (pesquisas, total com produto inexistente) e `Either String`
  para operações que podem falhar com motivo (receber/cancelar, ajustar stock).
- Todo o `IO` está confinado a `app/Main.hs`.

## Grupo

(Preencher: nomes e números dos elementos)
