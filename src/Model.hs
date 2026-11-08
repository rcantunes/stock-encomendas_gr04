-- | Modelo de domínio do sistema de Gestão de Stock e Encomendas.
-- Esta fase só define tipos; a lógica fica em "Domain".
module Model
  ( ProdutoId, FornecedorId, EncomendaId, Cents
  , Categoria(..)
  , Produto(..)
  , Fornecedor(..)
  , EstadoEncomenda(..)
  , Linha(..)
  , Encomenda(..)
  , Armazem(..)
  ) where

type ProdutoId    = Int
type FornecedorId = Int
type EncomendaId  = Int

-- | Valores monetários em cêntimos (evita erros de vírgula flutuante).
type Cents = Int

data Categoria
  = Alimentar
  | Limpeza
  | Papelaria
  | Eletronica
  | Outra
  deriving (Show, Eq, Ord, Enum, Bounded)

data Produto = Produto
  { prodId          :: ProdutoId
  , prodNome        :: String
  , prodCategoria   :: Categoria
  , prodPreco       :: Cents        -- ^ preço de custo unitário
  , prodStock       :: Int          -- ^ unidades em armazém
  , prodStockMinimo :: Int          -- ^ abaixo disto, é preciso repor
  , prodFornecedor  :: FornecedorId
  } deriving (Show, Eq)

data Fornecedor = Fornecedor
  { fornId       :: FornecedorId
  , fornNome     :: String
  , fornContacto :: String
  } deriving (Show, Eq)

-- | Ciclo de vida de uma encomenda de reposição.
data EstadoEncomenda
  = Pendente
  | Recebida
  | Cancelada
  deriving (Show, Eq)

-- | Uma linha de encomenda: produto e quantidade pedida.
data Linha = Linha
  { linhaProduto :: ProdutoId
  , linhaQtd     :: Int
  } deriving (Show, Eq)

data Encomenda = Encomenda
  { encId         :: EncomendaId
  , encFornecedor :: FornecedorId
  , encLinhas     :: [Linha]
  , encEstado     :: EstadoEncomenda
  } deriving (Show, Eq)

-- | Estado completo da aplicação.
data Armazem = Armazem
  { produtos     :: [Produto]
  , fornecedores :: [Fornecedor]
  , encomendas   :: [Encomenda]
  } deriving (Show, Eq)
