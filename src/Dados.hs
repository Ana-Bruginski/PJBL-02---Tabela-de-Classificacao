-- Camada 1: o campeonato de teste, guardado como texto.

-- Os dados ficam no proprio codigo, e nao num arquivo, porque o playground nao tem entrada pelo teclado nem sistema de arquivos. 
-- Assim o mesmo programa roda no GHC local e no play.haskell.org .

-- Campeonato ficticio, montado para exercitar os casos de borda:
--   6 times, 5 rodadas, turno unico (cada time joga uma vez por rodada);
--   um empate em 0 x 0            (Londrina 0 x 0 Parana, rodada 1);
--   uma goleada de 4 gols         (Athletico 4 x 0 Londrina, rodada 2);
--   dois times empatados em pontos no fim (Coritiba e Parana, 5 pontos
--   cada, com 1 vitoria cada), separados pelo saldo de gols.

module Dados
  ( dadosCampeonato
  , dadosComErros
  ) where

-- Formato de cada linha: rodada;mandante;gols mandante;gols visitante;visitante
-- Linhas em branco e linhas comecando com # sao ignoradas na leitura.
dadosCampeonato :: String
dadosCampeonato = unlines
  [ "# rodada;mandante;gols mandante;gols visitante;visitante"
  , ""
  , "# Rodada 1"
  , "1;Athletico;2;1;Coritiba"
  , "1;Londrina;0;0;Parana"
  , "1;Maringa;1;3;Operario"
  , ""
  , "# Rodada 2"
  , "2;Athletico;4;0;Londrina"
  , "2;Maringa;2;2;Coritiba"
  , "2;Operario;1;0;Parana"
  , ""
  , "# Rodada 3"
  , "3;Athletico;1;1;Maringa"
  , "3;Operario;2;1;Londrina"
  , "3;Parana;3;2;Coritiba"
  , ""
  , "# Rodada 4"
  , "4;Athletico;0;1;Operario"
  , "4;Parana;2;2;Maringa"
  , "4;Coritiba;3;1;Londrina"
  , ""
  , "# Rodada 5"
  , "5;Athletico;2;0;Parana"
  , "5;Coritiba;1;1;Operario"
  , "5;Londrina;2;3;Maringa"
  ]

-- Entrada defeituosa, usada para demonstrar o tratamento de erros.
-- Ha uma linha para cada construtor de Erro:
--   campos de menos, placar que nao e numero, placar negativo, time jogando contra si mesmo e time escalado duas vezes na rodada.
dadosComErros :: String
dadosComErros = unlines
  [ "# rodada;mandante;gols mandante;gols visitante;visitante"
  , "1;Coritiba;2;1"
  , "1;Athletico;dois;0;Londrina"
  , "1;Maringa;-1;2;Operario"
  , "2;Parana;1;1;Parana"
  , "3;Coritiba;1;0;Londrina"
  , "3;Coritiba;2;2;Maringa"
  ]