-- Camada 1: tipos do dominio e consultas basicas sobre uma partida.
module Tipos
  ( Time
  , Resultado (..)
  , Partida (..)
  , Linha (..)
  , participou
  , resultadoPara
  , times
  ) where

import Data.List (nub, sort)

-- Apelido para o nome de um time. Nao cria tipo novo, so deixa as assinaturas legiveis.
type Time = String

-- Tipo soma: um resultado e vitoria OU empate OU derrota, e nada mais.
-- Com String, um "v" minusculo compilaria; aqui o compilador rejeita.
data Resultado
  = Vitoria
  | Empate
  | Derrota
  deriving (Show, Eq)

-- Record: os campos tem nome, entao nao da para trocar sem querer os gols do mandante pelos do visitante, como aconteceria numa tupla de Ints.
data Partida = Partida
  { rodada        :: Int
  , mandante      :: Time
  , golsMandante  :: Int
  , golsVisitante :: Int
  , visitante     :: Time
  } deriving (Show, Eq)

-- Uma linha da tabela de classificacao.
-- Guarda so o que foi contado nas partidas; pontos e saldo sao derivados na Camada 2.
data Linha = Linha
  { time       :: Time
  , jogos      :: Int
  , vitorias   :: Int
  , empates    :: Int
  , derrotas   :: Int
  , golsPro    :: Int
  , golsContra :: Int
  } deriving (Show, Eq)

-- Verdadeiro se o time entrou em campo nessa partida, de qualquer lado.
participou :: Time -> Partida -> Bool
participou t p = mandante p == t || visitante p == t

-- O resultado do ponto de vista do time. Nothing quando ele nao jogou:
-- a ausencia de resposta fica no tipo, e quem chama e obrigado a tratar.
resultadoPara :: Time -> Partida -> Maybe Resultado
resultadoPara t p
  | t == mandante p  = Just (confronto (golsMandante p) (golsVisitante p))
  | t == visitante p = Just (confronto (golsVisitante p) (golsMandante p))
  | otherwise        = Nothing

-- Compara os gols ja na perspectiva de quem fez e de quem sofreu.
confronto :: Int -> Int -> Resultado
confronto feitos sofridos
  | feitos > sofridos  = Vitoria
  | feitos == sofridos = Empate
  | otherwise          = Derrota

-- Todos os times que aparecem nas partidas, sem repeticao e em ordem alfabetica.
-- A ordem fixa deixa o resultado previsivel nos testes.
times :: [Partida] -> [Time]
times ps = sort (nub (map mandante ps ++ map visitante ps))