-- Camada 3: leitura do texto, validacao com Maybe/Either e formatacao.
--
-- Nenhuma funcao daqui lanca excecao: toda entrada invalida vira um Left
-- com um Erro que diz onde esta o problema. A conversao de texto para
-- numero usa readMaybe, e nao read, que quebraria em "dois" ou "2a".
module Leitura
  ( Erro (..)
  , separar
  , lerPartida
  ) where

import Data.Char (isSpace)
import Text.Read (readMaybe)
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

-- Remove os espacos das duas pontas, para "1; Coritiba ;2" funcionar.
aparar :: String -> String
aparar = reverse . dropWhile isSpace . reverse . dropWhile isSpace

-- Confere que a linha tem exatamente os cinco campos esperados.
cincoCampos :: Int -> String -> Either Erro (String, Time, String, String, Time)
cincoCampos n linha = case map aparar (separar ';' linha) of
  [a, b, c, d, e] -> Right (a, b, c, d, e)
  _               -> Left (CamposInvalidos n linha)

-- readMaybe devolve Nothing em vez de lancar excecao; o case transforma esse Nothing num erro que sabe dizer qual campo estava errado.
lerInteiro :: Int -> String -> Either Erro Int
lerInteiro n texto = case readMaybe texto of
  Just v  -> Right v
  Nothing -> Left (NumeroInvalido n texto)

naoNegativo :: Int -> Int -> Either Erro Int
naoNegativo n v
  | v < 0     = Left (PlacarNegativo n v)
  | otherwise = Right v

timesDistintos :: Int -> Time -> Time -> Either Erro ()
timesDistintos n casa fora
  | casa == fora = Left (MesmoTime n casa)
  | otherwise    = Right ()

-- Uma linha de texto vira uma partida. O bloco do na monada Either encadeia as validacoes: 
-- o primeiro Left interrompe tudo, e os passos seguintes nem chegam a ser executados.
lerPartida :: Int -> String -> Either Erro Partida
lerPartida n linha = do
  (txtRodada, casa, txtGolsCasa, txtGolsFora, fora) <- cincoCampos n linha
  r         <- lerInteiro n txtRodada
  golsCasa  <- lerInteiro n txtGolsCasa >>= naoNegativo n
  golsFora  <- lerInteiro n txtGolsFora >>= naoNegativo n
  timesDistintos n casa fora
  return (Partida r casa golsCasa golsFora fora)