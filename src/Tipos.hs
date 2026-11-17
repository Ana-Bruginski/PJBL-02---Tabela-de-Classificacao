-- Camada 1: tipos do dominio do campeonato.
module Tipos
  ( Time
  , Resultado (..)
  , Partida (..)
  , Linha (..)
  ) where

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