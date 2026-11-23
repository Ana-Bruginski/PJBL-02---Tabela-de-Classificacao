-- Camada 3: leitura do texto, validacao com Maybe/Either e formatacao.
module Leitura
  ( Erro (..)
  , separar
  ) where

import Tipos

-- Tipo soma com os motivos possiveis de falha.
-- Cada construtor carrega onde o problema esta: o numero da linha, ou a rodada.
data Erro
  = CamposInvalidos Int String      -- linha, conteudo encontrado
  | NumeroInvalido Int String       -- linha, campo que nao e numero
  | PlacarNegativo Int Int          -- linha, valor negativo
  | MesmoTime Int Time              -- linha, time que joga contra si mesmo
  | TimeRepetidoNaRodada Int Time   -- rodada, time escalado duas vezes
  deriving (Show, Eq)

-- Quebra uma string nos separadores. "1;Coritiba;2" com ';' vira ["1","Coritiba","2"]. 
-- Dois separadores seguidos geram um campo vazio, que e justamente o que faz CamposInvalidos disparar.
separar :: Char -> String -> [String]
separar sep texto = case break (== sep) texto of
  (campo, [])           -> [campo]
  (campo, _ : restante) -> campo : separar sep restante