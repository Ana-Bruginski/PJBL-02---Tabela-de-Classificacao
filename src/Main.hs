-- Demonstracao das tres camadas.

-- main e a unica funcao com IO do projeto inteiro: todo o relatorio e montado como uma String pura e so no fim vai para a tela.
-- E essa separacao entre nucleo puro e casca de IO que deixa o programa igual no GHC local e no playground, e testavel sem rodar nada na tela.
module Main (main) where

import Classificacao
import Dados
import Leitura
import Tipos

main :: IO ()
main = putStr relatorio

relatorio :: String
relatorio = unlines
  (  [ "======================================="
     , " PjBL 2 - Tabela de Classificacao"
     , "======================================="
     , ""
     ]
  ++ secaoCampeonato dadosCampeonato
  ++ [ "" ]
  ++ secaoErros dadosComErros
  )

-- Camadas 1 e 2, a partir de uma entrada que deve ser valida.
secaoCampeonato :: String -> [String]
secaoCampeonato texto = case lerCampeonato texto of
  Left e   -> [ "Nao foi possivel ler o campeonato:"
              , "  " ++ descreverErro e
              ]
  Right ps ->
       [ "[Camada 1] Dados lidos"
       , "  Partidas: " ++ show (length ps)
       , "  Times:    " ++ listar (times ps)
       , ""
       , "[Camada 2] Classificacao final"
       ]
    ++ lines (tabelaFormatada (classificacao ps))
    ++ [ "" , "[Camada 2] Classificacao apos a rodada 3" ]
    ++ lines (tabelaFormatada (classificacao (ateRodada 3 ps)))
    ++ [ ""
       , "[Camada 2] Estatisticas"
       , "  Maior goleada:    " ++ descreverGoleada (maiorGoleada ps)
       , "  Media de gols:    " ++ descreverMedia (mediaGols ps)
       , "  Lider:            " ++ descreverLider (classificacao ps)
       ]

-- Camada 3: a mesma entrada defeituosa vista de duas formas, parando no primeiro erro e listando todos.
secaoErros :: String -> [String]
secaoErros texto =
     [ "[Camada 3] Entrada com erros"
     , ""
     , "  lerCampeonato para no primeiro erro:"
     , "    " ++ primeiroErro
     , ""
     , "  todosOsErros lista o relatorio completo:"
     ]
  ++ map (\e -> "    " ++ descreverErro e) (todosOsErros texto)
  where
    primeiroErro = case lerCampeonato texto of
      Left e  -> descreverErro e
      Right _ -> "(nenhum erro encontrado)"

-- Junta nomes com virgula. A dobra comeca pelo primeiro nome, entao nao sobra virgula no comeco.
listar :: [Time] -> String
listar []       = "(nenhum)"
listar (t : ts) = foldl (\acc outro -> acc ++ ", " ++ outro) t ts

-- maybe trata o Nothing sem abrir a caixa a mao.
descreverGoleada :: Maybe Partida -> String
descreverGoleada = maybe "(nenhuma partida)" placar
  where
    placar p = mandante p ++ " " ++ show (golsMandante p) ++ " x "
            ++ show (golsVisitante p) ++ " " ++ visitante p
            ++ "  (rodada " ++ show (rodada p) ++ ")"

-- Aqui o Maybe e usado como functor: <$> aplica a formatacao dentro da caixa, e so depois o case decide o que mostrar.
descreverMedia :: Maybe Double -> String
descreverMedia m = case duasCasas <$> m of
  Nothing  -> "(nao ha partidas)"
  Just txt -> txt ++ " gols por partida"

-- O lider e o primeiro da tabela. O casamento de padrao cobre a tabela vazia, em vez de usar head.
descreverLider :: [Linha] -> String
descreverLider []      = "(nao ha times)"
descreverLider (l : _) = time l ++ " com " ++ show (pontosLinha l)
                      ++ " pontos e " ++ duasCasas (aproveitamento l)
                      ++ "% de aproveitamento"

duasCasas :: Double -> String
duasCasas x = show (fromIntegral (round (x * 100) :: Int) / 100 :: Double)