module Main (main) where

import Model
import Domain
import DadosTeste

main :: IO ()
main = do
  let a = armazemExemplo
  putStrLn "=== Gestão de Stock e Encomendas (Fase 1) ==="
  putStrLn ("Valor do stock: " ++ formatarEuros (valorStock (produtos a)))

  putStrLn "\nProdutos abaixo do stock mínimo:"
  mostrarProdutos (encomendas a) (produtosAbaixoMinimo (produtos a))

  putStrLn "\nTotal da encomenda 2:"
  case procurarEncomenda 2 (encomendas a) of
    Nothing -> putStrLn "  encomenda não encontrada"
    Just e  -> putStrLn ("  " ++ maybe "produto inválido" formatarEuros
                                      (totalEncomenda (produtos a) e))

  putStrLn "\nReceber encomenda 2:"
  case receberEncomenda 2 a of
    Left err -> putStrLn ("  Erro: " ++ err)
    Right a' -> putStrLn ("  OK. Novo valor do stock: "
                          ++ formatarEuros (valorStock (produtos a')))

  putStrLn "\nReceber encomenda 3 (já recebida):"
  putStrLn (either ("  Erro: " ++) (const "  OK") (receberEncomenda 3 a))

mostrarProdutos :: [Encomenda] -> [Produto] -> IO ()
mostrarProdutos _ [] = return ()
mostrarProdutos es (p:ps) = do
  putStrLn ("  - " ++ prodNome p
            ++ " | stock " ++ show (prodStock p)
            ++ " / mín " ++ show (prodStockMinimo p)
            ++ " | a pedir: " ++ show (quantidadeASolicitar es p))
  mostrarProdutos es ps
