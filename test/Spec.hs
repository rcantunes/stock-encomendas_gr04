module Main (main) where

import Control.Monad (unless)
import System.Exit (exitFailure)

import Model
import Domain
import DadosTeste

data Resultado = Resultado String Bool

teste :: String -> Bool -> Resultado
teste = Resultado

a :: Armazem
a = armazemExemplo

stockDe :: ProdutoId -> Armazem -> Maybe Int
stockDe i x = fmap prodStock (procurarProduto i (produtos x))

estadoDe :: EncomendaId -> Armazem -> Maybe EstadoEncomenda
estadoDe i x = fmap encEstado (procurarEncomenda i (encomendas x))

isLeft :: Either a b -> Bool
isLeft (Left _) = True
isLeft _        = False

testes :: [Resultado]
testes =
  [ teste "procurarProduto existente"    (fmap prodNome (procurarProduto 3 (produtos a)) == Just "Caderno A4")
  , teste "procurarProduto inexistente"  (procurarProduto 99 (produtos a) == Nothing)
  , teste "procurarProduto lista vazia"  (procurarProduto 1 [] == Nothing)
  , teste "procurarFornecedor"           (fmap fornNome (procurarFornecedor 4 (fornecedores a)) == Just "TechPorto")
  , teste "valorStock"                   (valorStock (produtos a) == 89*120 + 349*15 + 199*40 + 799*5 + 105*80)
  , teste "valorStock vazio"             (valorStock [] == 0)
  , teste "abaixo do mínimo"             (map prodId (produtosAbaixoMinimo (produtos a)) == [2,4])
  , teste "produtos do fornecedor 1"     (map prodId (produtosDoFornecedor 1 (produtos a)) == [1,5])
  , teste "qtd em encomenda (pendente)"  (quantidadeEmEncomenda 4 (encomendas a) == 20)
  , teste "qtd ignora recebidas"         (quantidadeEmEncomenda 1 (encomendas a) == 0)
  , teste "a solicitar já coberto"       (fmap (quantidadeASolicitar (encomendas a)) (procurarProduto 4 (produtos a)) == Just 0)
  , teste "a solicitar produto 2 (sem encomendas)" (fmap (quantidadeASolicitar []) (procurarProduto 2 (produtos a)) == Just 5)
  , teste "totalEncomenda 2"             ((procurarEncomenda 2 (encomendas a) >>= totalEncomenda (produtos a)) == Just (799*20 + 199*5))
  , teste "totalLinhas produto inválido" (totalLinhas (produtos a) [Linha 99 1] == Nothing)
  , teste "totalLinhas vazio"            (totalLinhas (produtos a) [] == Just 0)
  , teste "ajustarStock positivo"        (fmap (map prodStock) (ajustarStock 4 10 (produtos a)) == Right [120,15,40,15,80])
  , teste "ajustarStock negativo falha"  (isLeft (ajustarStock 4 (-6) (produtos a)))
  , teste "ajustarStock até zero"        (fmap (map prodStock) (ajustarStock 4 (-5) (produtos a)) == Right [120,15,40,0,80])
  , teste "ajustarStock inexistente"     (isLeft (ajustarStock 99 1 (produtos a)))
  , teste "receber encomenda 1 (stock)"  (fmap (stockDe 2) (receberEncomenda 1 a) == Right (Just 25))
  , teste "receber marca Recebida"       (fmap (estadoDe 1) (receberEncomenda 1 a) == Right (Just Recebida))
  , teste "receber encomenda 2 (2 linhas)" (fmap (\x -> (stockDe 4 x, stockDe 3 x)) (receberEncomenda 2 a) == Right (Just 25, Just 45))
  , teste "receber já recebida falha"    (isLeft (receberEncomenda 3 a))
  , teste "receber inexistente falha"    (isLeft (receberEncomenda 99 a))
  , teste "cancelar encomenda"           (fmap (estadoDe 2) (cancelarEncomenda 2 a) == Right (Just Cancelada))
  , teste "cancelar não altera stock"    (fmap produtos (cancelarEncomenda 2 a) == Right (produtos a))
  , teste "cancelar recebida falha"      (isLeft (cancelarEncomenda 3 a))
  , teste "formatarEuros"                (formatarEuros 1234 == "12.34 EUR")
  , teste "formatarEuros cêntimos < 10"  (formatarEuros 705 == "7.05 EUR")
  , teste "formatarEuros zero"           (formatarEuros 0 == "0.00 EUR")
  ]

main :: IO ()
main = do
  let falhas = [n | Resultado n False <- testes]
  mapM_ (\n -> putStrLn ("FALHOU: " ++ n)) falhas
  putStrLn (show (length testes - length falhas) ++ "/" ++ show (length testes) ++ " testes passaram")
  unless (null falhas) exitFailure
