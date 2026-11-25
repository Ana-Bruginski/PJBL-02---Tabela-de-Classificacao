-- Bateria de testes das tres camadas.

-- Cada teste compara o valor obtido com o esperado, conferido a mao a partir do campeonato de Dados.hs. Rodar com:
--   runghc -isrc tests/Testes.hs
module Main (main) where

import Classificacao
import Dados
import Leitura
import Tipos

-- Funcao auxiliar sugerida no enunciado.
-- Exige Eq para comparar e Show para conseguir mostrar o valor obtido quando o teste falha.
testar :: (Eq a, Show a) => String -> a -> a -> IO ()
testar nome obtido esperado
  | obtido == esperado = putStrLn ("OK      " ++ nome)
  | otherwise          = putStrLn ("FALHOU  " ++ nome ++ ": " ++ show obtido)

-- O campeonato ja lido.
-- Se a leitura falhasse, a lista viria vazia e os testes acusariam; nao ha head nem fromJust em lugar nenhum.
campeonato :: [Partida]
campeonato = case lerCampeonato dadosCampeonato of
  Right ps -> ps
  Left _   -> []

-- Partidas avulsas usadas nos testes da Camada 1.
jogoComVencedor :: Partida
jogoComVencedor = Partida 1 "Athletico" 2 1 "Coritiba"

jogoEmpatado :: Partida
jogoEmpatado = Partida 1 "Londrina" 0 0 "Parana"

main :: IO ()
main = do
  putStrLn "===== Camada 1: tipos e consultas basicas ====="
  testar "participou do mandante"
    (participou "Athletico" jogoComVencedor) True
  testar "participou de quem nao jogou"
    (participou "Maringa" jogoComVencedor) False
  testar "resultadoPara o mandante que venceu"
    (resultadoPara "Athletico" jogoComVencedor) (Just Vitoria)
  testar "resultadoPara o visitante que perdeu"
    (resultadoPara "Coritiba" jogoComVencedor) (Just Derrota)
  testar "resultadoPara quem nao jogou devolve Nothing"
    (resultadoPara "Maringa" jogoComVencedor) Nothing
  testar "resultadoPara num 0 x 0 devolve Empate"
    (resultadoPara "Londrina" jogoEmpatado) (Just Empate)
  testar "times do campeonato, sem repeticao e em ordem"
    (times campeonato)
    ["Athletico", "Coritiba", "Londrina", "Maringa", "Operario", "Parana"]
  testar "times nao repete mesmo com 15 partidas"
    (length (times campeonato)) 6

  putStrLn ""
  putStrLn "===== Camada 2: classificacao ====="
  testar "pontos por resultado"
    (map pontos [Vitoria, Empate, Derrota]) [3, 1, 0]
  testar "linhaDoTime do lider, conferida a mao"
    (linhaDoTime campeonato "Operario")
    (Linha "Operario" 5 4 1 0 8 3)
  testar "linhaDoTime do lanterna, conferida a mao"
    (linhaDoTime campeonato "Londrina")
    (Linha "Londrina" 5 0 1 4 4 12)
  testar "linhaDoTime de quem nao esta no campeonato"
    (linhaDoTime campeonato "Fantasma")
    (Linha "Fantasma" 0 0 0 0 0 0)
  testar "pontosLinha do lider: 4 vitorias e 1 empate"
    (pontosLinha (linhaDoTime campeonato "Operario")) 13
  testar "saldo do lanterna: 4 gols pro e 12 contra"
    (saldo (linhaDoTime campeonato "Londrina")) (-8)
  testar "aproveitamento do lider: 13 de 15 pontos disputados"
    (aproveitamento (linhaDoTime campeonato "Operario")) (1300 / 15)
  testar "aproveitamento de quem nao jogou e 0, sem dividir por zero"
    (aproveitamento (linhaDoTime [] "Fantasma")) 0
  testar "ordem da classificacao final"
    (map time (classificacao campeonato))
    ["Operario", "Athletico", "Maringa", "Coritiba", "Parana", "Londrina"]

  putStrLn ""
  putStrLn "--- desempate entre Coritiba e Parana ---"
  testar "os dois terminam com os mesmos pontos"
    ( pontosLinha (linhaDoTime campeonato "Coritiba")
    , pontosLinha (linhaDoTime campeonato "Parana") ) (5, 5)
  testar "e tambem com o mesmo numero de vitorias"
    ( vitorias (linhaDoTime campeonato "Coritiba")
    , vitorias (linhaDoTime campeonato "Parana") ) (1, 1)
  testar "o criterio que decide e o saldo de gols"
    ( saldo (linhaDoTime campeonato "Coritiba")
    , saldo (linhaDoTime campeonato "Parana") ) (0, -2)
  testar "por isso o Coritiba fica a frente do Parana"
    (take 2 (drop 3 (map time (classificacao campeonato))))
    ["Coritiba", "Parana"]

  putStrLn ""
  putStrLn "--- tabela parcial e estatisticas ---"
  testar "ateRodada 3 traz 9 das 15 partidas"
    (length (ateRodada 3 campeonato)) 9
  testar "a classificacao da rodada 3 e diferente da final"
    (map time (classificacao (ateRodada 3 campeonato)))
    ["Operario", "Athletico", "Parana", "Maringa", "Coritiba", "Londrina"]
  testar "a tabela parcial realmente difere da final"
    ( map time (classificacao (ateRodada 3 campeonato))
      == map time (classificacao campeonato) ) False
  testar "maiorGoleada do campeonato"
    (maiorGoleada campeonato)
    (Just (Partida 2 "Athletico" 4 0 "Londrina"))
  testar "maiorGoleada de lista vazia devolve Nothing"
    (maiorGoleada []) Nothing
  testar "mediaGols: 44 gols em 15 partidas"
    (mediaGols campeonato) (Just (44 / 15))
  testar "mediaGols de lista vazia devolve Nothing"
    (mediaGols []) Nothing