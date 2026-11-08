-- | Núcleo funcional (Fase 1): funções puras, pattern matching e recursão.
-- Sem IO. As funções de ordem superior (map/filter/foldr) ficam para a
-- Fase 2, onde estas definições recursivas serão refatoradas.
module Domain
  ( procurarProduto
  , procurarFornecedor
  , procurarEncomenda
  , valorStock
  , produtosAbaixoMinimo
  , produtosDoFornecedor
  , quantidadeEmEncomenda
  , quantidadeASolicitar
  , totalLinhas
  , totalEncomenda
  , ajustarStock
  , receberEncomenda
  , cancelarEncomenda
  , formatarEuros
  ) where

import Model

-- ---------------------------------------------------------------
-- Pesquisa
-- ---------------------------------------------------------------

procurarProduto :: ProdutoId -> [Produto] -> Maybe Produto
procurarProduto _ [] = Nothing
procurarProduto i (p:ps)
  | prodId p == i = Just p
  | otherwise     = procurarProduto i ps

procurarFornecedor :: FornecedorId -> [Fornecedor] -> Maybe Fornecedor
procurarFornecedor _ [] = Nothing
procurarFornecedor i (f:fs)
  | fornId f == i = Just f
  | otherwise     = procurarFornecedor i fs

procurarEncomenda :: EncomendaId -> [Encomenda] -> Maybe Encomenda
procurarEncomenda _ [] = Nothing
procurarEncomenda i (e:es)
  | encId e == i = Just e
  | otherwise    = procurarEncomenda i es

-- ---------------------------------------------------------------
-- Consultas sobre stock
-- ---------------------------------------------------------------

-- | Valor total do inventário (preço x quantidade), em cêntimos.
valorStock :: [Produto] -> Cents
valorStock []     = 0
valorStock (p:ps) = prodPreco p * prodStock p + valorStock ps

-- | Produtos cujo stock está abaixo do mínimo definido.
produtosAbaixoMinimo :: [Produto] -> [Produto]
produtosAbaixoMinimo [] = []
produtosAbaixoMinimo (p:ps)
  | prodStock p < prodStockMinimo p = p : resto
  | otherwise                       = resto
  where resto = produtosAbaixoMinimo ps

produtosDoFornecedor :: FornecedorId -> [Produto] -> [Produto]
produtosDoFornecedor _ [] = []
produtosDoFornecedor f (p:ps)
  | prodFornecedor p == f = p : resto
  | otherwise             = resto
  where resto = produtosDoFornecedor f ps

-- ---------------------------------------------------------------
-- Encomendas
-- ---------------------------------------------------------------

-- | Quantidade de um produto já pedida em encomendas Pendentes.
quantidadeEmEncomenda :: ProdutoId -> [Encomenda] -> Int
quantidadeEmEncomenda _ [] = 0
quantidadeEmEncomenda pid (e:es) =
  case encEstado e of
    Pendente -> qtdNasLinhas pid (encLinhas e) + quantidadeEmEncomenda pid es
    _        -> quantidadeEmEncomenda pid es

qtdNasLinhas :: ProdutoId -> [Linha] -> Int
qtdNasLinhas _ [] = 0
qtdNasLinhas pid (l:ls)
  | linhaProduto l == pid = linhaQtd l + qtdNasLinhas pid ls
  | otherwise             = qtdNasLinhas pid ls

-- | Unidades que faltam pedir para atingir o stock mínimo, tendo em conta
-- o que já está encomendado. Nunca é negativo.
quantidadeASolicitar :: [Encomenda] -> Produto -> Int
quantidadeASolicitar es p = max 0 (prodStockMinimo p - prodStock p - jaPedido)
  where jaPedido = quantidadeEmEncomenda (prodId p) es

-- | Custo de uma lista de linhas; Nothing se algum produto não existir.
totalLinhas :: [Produto] -> [Linha] -> Maybe Cents
totalLinhas _ [] = Just 0
totalLinhas ps (l:ls) =
  case procurarProduto (linhaProduto l) ps of
    Nothing -> Nothing
    Just p  -> case totalLinhas ps ls of
                 Nothing -> Nothing
                 Just r  -> Just (prodPreco p * linhaQtd l + r)

totalEncomenda :: [Produto] -> Encomenda -> Maybe Cents
totalEncomenda ps e = totalLinhas ps (encLinhas e)

-- ---------------------------------------------------------------
-- Alterações de estado (devolvem novos valores; nada é mutado)
-- ---------------------------------------------------------------

-- | Soma (ou subtrai, se negativo) unidades ao stock de um produto.
-- Falha se o produto não existe ou se o stock ficaria negativo.
ajustarStock :: ProdutoId -> Int -> [Produto] -> Either String [Produto]
ajustarStock pid _ [] = Left ("Produto inexistente: " ++ show pid)
ajustarStock pid delta (p:ps)
  | prodId p == pid =
      let novo = prodStock p + delta
      in if novo < 0
           then Left ("Stock insuficiente para o produto " ++ show pid)
           else Right (p { prodStock = novo } : ps)
  | otherwise = case ajustarStock pid delta ps of
      Left err  -> Left err
      Right ps' -> Right (p : ps')

-- | Aplica as linhas de uma encomenda ao stock.
aplicarLinhas :: [Linha] -> [Produto] -> Either String [Produto]
aplicarLinhas [] ps = Right ps
aplicarLinhas (l:ls) ps =
  case ajustarStock (linhaProduto l) (linhaQtd l) ps of
    Left err  -> Left err
    Right ps' -> aplicarLinhas ls ps'

atualizarEstado :: EncomendaId -> EstadoEncomenda -> [Encomenda] -> [Encomenda]
atualizarEstado _ _ [] = []
atualizarEstado i novo (e:es)
  | encId e == i = e { encEstado = novo } : es
  | otherwise    = e : atualizarEstado i novo es

-- | Marca a encomenda como Recebida e soma as quantidades ao stock.
receberEncomenda :: EncomendaId -> Armazem -> Either String Armazem
receberEncomenda i a =
  case procurarEncomenda i (encomendas a) of
    Nothing -> Left ("Encomenda inexistente: " ++ show i)
    Just e
      | encEstado e /= Pendente ->
          Left ("A encomenda " ++ show i ++ " não está pendente")
      | otherwise ->
          case aplicarLinhas (encLinhas e) (produtos a) of
            Left err -> Left err
            Right ps -> Right a { produtos   = ps
                                , encomendas = atualizarEstado i Recebida (encomendas a) }

cancelarEncomenda :: EncomendaId -> Armazem -> Either String Armazem
cancelarEncomenda i a =
  case procurarEncomenda i (encomendas a) of
    Nothing -> Left ("Encomenda inexistente: " ++ show i)
    Just e
      | encEstado e /= Pendente ->
          Left ("A encomenda " ++ show i ++ " não está pendente")
      | otherwise ->
          Right a { encomendas = atualizarEstado i Cancelada (encomendas a) }

-- ---------------------------------------------------------------
-- Apresentação
-- ---------------------------------------------------------------

-- | 1234 -> "12.34 EUR"
formatarEuros :: Cents -> String
formatarEuros c = sinal ++ show euros ++ "." ++ pad (show cents) ++ " EUR"
  where
    sinal = if c < 0 then "-" else ""
    (euros, cents) = abs c `divMod` 100
    pad s = if length s < 2 then '0' : s else s
