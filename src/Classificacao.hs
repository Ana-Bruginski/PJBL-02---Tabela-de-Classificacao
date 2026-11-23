-- Camada 2: a tabela de classificacao e as estatisticas do campeonato.

-- Nenhuma funcao desta camada usa recursao explicita: tudo sai de map, filter, dobras e composicao.
module Classificacao
  ( pontos
  , linhaDoTime
  , pontosLinha
  , saldo
  , aproveitamento
  ) where

import Data.List (foldl')
import Tipos

-- Pontuacao de cada resultado. Os numeros 3, 1 e 0 aparecem so aqui, todo o resto da camada deriva deles.
pontos :: Resultado -> Int
pontos Vitoria = 3
pontos Empate  = 1
pontos Derrota = 0

-- Linha de um time que ainda nao jogou nada: o valor inicial da dobra.
linhaVazia :: Time -> Linha
linhaVazia t = Linha
  { time       = t
  , jogos      = 0
  , vitorias   = 0
  , empates    = 0
  , derrotas   = 0
  , golsPro    = 0
  , golsContra = 0
  }

-- Incorpora uma partida na linha de um time.
-- Se o time nao jogou essa partida, resultadoPara devolve Nothing e a linha passa intacta.
acumular :: Time -> Linha -> Partida -> Linha
acumular t l p = case resultadoPara t p of
    Nothing  -> l
    Just res -> l
      { jogos      = jogos l + 1
      , vitorias   = vitorias l + marcar Vitoria res
      , empates    = empates l + marcar Empate res
      , derrotas   = derrotas l + marcar Derrota res
      , golsPro    = golsPro l + feitos
      , golsContra = golsContra l + sofridos
      }
  where
    marcar alvo obtido = if alvo == obtido then 1 else 0
    ehMandante = t == mandante p
    feitos     = if ehMandante then golsMandante p else golsVisitante p
    sofridos   = if ehMandante then golsVisitante p else golsMandante p

-- A linha da tabela de um time: filtra as partidas dele e dobra sobre elas.
-- foldl' em vez de foldl porque o acumulador e um valor, nao uma lista
-- a conta e feita a cada passo, sem deixar calculo pendente.
linhaDoTime :: [Partida] -> Time -> Linha
linhaDoTime ps t = foldl' (acumular t) (linhaVazia t) (filter (participou t) ps)

-- Pontos ganhos pelo time, calculados a partir de pontos/1.
pontosLinha :: Linha -> Int
pontosLinha l = vitorias l * pontos Vitoria
              + empates  l * pontos Empate
              + derrotas l * pontos Derrota

-- Saldo de gols: gols pro menos gols contra.
saldo :: Linha -> Int
saldo l = golsPro l - golsContra l

-- Percentual dos pontos disputados que o time conquistou.
-- fromIntegral faz a ponte entre Int e Double: (/) nao aceita Int, e div
-- truncaria o resultado.
aproveitamento :: Linha -> Double
aproveitamento l
  | jogos l == 0 = 0
  | otherwise    = 100 * fromIntegral (pontosLinha l)
                       / fromIntegral (jogos l * pontos Vitoria)