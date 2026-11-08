-- | Pequeno conjunto de dados para demonstração e testes.
module DadosTeste (armazemExemplo) where

import Model

armazemExemplo :: Armazem
armazemExemplo = Armazem
  { produtos =
      [ Produto 1 "Arroz 1kg"        Alimentar   89 120 50 1
      , Produto 2 "Detergente 2L"    Limpeza    349  15 20 2
      , Produto 3 "Caderno A4"       Papelaria  199  40 30 3
      , Produto 4 "Pen USB 64GB"     Eletronica 799   5 10 4
      , Produto 5 "Massa esparguete" Alimentar  105  80 40 1
      ]
  , fornecedores =
      [ Fornecedor 1 "Alimentar Norte, Lda" "alimentar@norte.pt"
      , Fornecedor 2 "Limpeza Total"        "geral@limpezatotal.pt"
      , Fornecedor 3 "Papelaria Central"    "vendas@papcentral.pt"
      , Fornecedor 4 "TechPorto"            "b2b@techporto.pt"
      ]
  , encomendas =
      [ Encomenda 1 2 [Linha 2 10]            Pendente
      , Encomenda 2 4 [Linha 4 20, Linha 3 5] Pendente
      , Encomenda 3 1 [Linha 1 30]            Recebida
      ]
  }
