-- Camada 3: leitura do texto, validacao com Maybe/Either e formatacao.

-- Nenhuma funcao daqui lanca excecao: 
-- toda entrada invalida vira um Left com um Erro que diz onde esta o problema.
-- A conversao de texto para numero usa readMaybe, e nao read, que quebraria em "dois" ou "2a".
module Leitura
  ( Erro (..)
  , separar
  , lerPartida
  , lerCampeonato
  , todosOsErros
  ) where

import Data.Char (isSpace)
import Data.List (nub)
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

-- As linhas que descrevem partidas, numeradas a partir de 1.
-- Linhas em branco e comentarios (#) ficam de fora, mas ainda contam na numeracao, para que o numero mostrado no erro seja o da linha no arquivo.
linhasUteis :: String -> [(Int, String)]
linhasUteis texto =
  [ (n, l) | (n, l) <- zip [1 ..] (lines texto), aproveitavel l ]

aproveitavel :: String -> Bool
aproveitavel l = not (null limpa) && take 1 limpa /= "#"
  where limpa = aparar l

-- Todas as participacoes repetidas dentro de uma mesma rodada.
-- Compara cada participacao com as que vieram antes dela.
repeticoesNaRodada :: [Partida] -> [(Int, Time)]
repeticoesNaRodada ps = nub
  [ atual
  | (i, atual) <- zip [0 :: Int ..] participacoes
  , atual `elem` take i participacoes
  ]
  where
    participacoes = [ (rodada p, t) | p <- ps, t <- [mandante p, visitante p] ]

semRepeticaoNaRodada :: [Partida] -> Either Erro ()
semRepeticaoNaRodada ps = case repeticoesNaRodada ps of
  []           -> Right ()
  ((r, t) : _) -> Left (TimeRepetidoNaRodada r t)

-- Le o texto inteiro, parando no primeiro erro.
-- traverse aplica lerPartida a cada linha e "vira a lista do avesso":
-- em vez de uma lista de Either, devolve um Either de lista. Depois confere a regra da rodada.
lerCampeonato :: String -> Either Erro [Partida]
lerCampeonato texto = do
  ps <- traverse (\(n, l) -> lerPartida n l) (linhasUteis texto)
  semRepeticaoNaRodada ps
  return ps

-- Relatorio completo: em vez de parar no primeiro erro, junta todos.
-- As linhas validas ainda sao conferidas contra a regra da rodada.
todosOsErros :: String -> [Erro]
todosOsErros texto = errosDeLinha ++ errosDeRodada
  where
    resultados    = map (\(n, l) -> lerPartida n l) (linhasUteis texto)
    errosDeLinha  = [ e | Left e  <- resultados ]
    partidasOk    = [ p | Right p <- resultados ]
    errosDeRodada = map (\(r, t) -> TimeRepetidoNaRodada r t)
                        (repeticoesNaRodada partidasOk)