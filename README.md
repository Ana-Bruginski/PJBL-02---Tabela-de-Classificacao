# PjBL 2 - Tabela de Classificação de Campeonato

Programação Lógica e Funcional - PUCPR
Ciência da Computação - 4º período

## Integrantes

- Ana Luiza Bruginski de Melo
- Hugo Souza Jamielniak
- João Pedro Macena Correa
- Nathan Bueno Catenacci Okazaki

## Sobre

O programa calcula a tabela de classificação de um campeonato de futebol a
partir dos resultados das partidas em texto, valida a entrada e imprime a
classificação final, a classificação parcial e as estatísticas.

## Ambiente

**GHC local, instalado via GHCup.** Desenvolvido e testado no GHC 9.4 e 9.10,
usando apenas a biblioteca padrão (`base`): `Data.List`, `Data.Char`,
`Data.Ord` e `Text.Read`.

## Estrutura

```
src/
  Tipos.hs          Camada 1: tipos algébricos e consultas básicas
  Dados.hs          Camada 1: campeonato de teste, como String
  Classificacao.hs  Camada 2: tabela e estatísticas, com ordem superior
  Leitura.hs        Camada 3: parsing, validação com Either e formatação
  Main.hs           Demonstração das três camadas
tests/
  Testes.hs         Bateria de testes com resultado esperado
docs/
  decisoes.md       Decisões de modelagem e limitações conhecidas
```

As dependências entre os módulos seguem as camadas, sem ciclos:

```
Tipos  ←  Classificacao  ←  Leitura  ←  Main
                                        ↑
                              Dados  ───┘
```

## Como compilar e executar

Na raiz do projeto:

```bash
ghc -Wall -isrc -o classificacao src/Main.hs
./classificacao
```

No Windows, o executável é `classificacao.exe`.

Para executar sem gerar o executável:

```bash
runghc -isrc src/Main.hs
```

## Como rodar os testes

```bash
runghc -isrc tests/Testes.hs
```

Cada linha começa com `OK` ou `FALHOU`. São 44 testes, cobrindo as três
camadas, cada construtor de `Erro` e os casos de borda (campeonato vazio,
time inexistente, texto só com comentários).

## O que o programa mostra

```
[Camada 1] Dados lidos           15 partidas, 6 times
[Camada 2] Classificação final   tabela ordenada pelos critérios de desempate
[Camada 2] Classificação após a rodada 3   tabela parcial, em outra ordem
[Camada 2] Estatísticas          maior goleada, média de gols, líder
[Camada 3] Entrada com erros     primeiro erro e relatório completo
```

## Campeonato de teste

Campeonato fictício em turno único, com seis times do Paraná e cinco
rodadas. Montado para exercitar os casos de borda exigidos:

| Exigência | Onde aparece |
|---|---|
| 6 times, 5 rodadas | turno único, cada time joga uma vez por rodada |
| Empate em 0 x 0 | Londrina 0 x 0 Paraná, rodada 1 |
| Vitória por 3+ gols | Athletico 4 x 0 Londrina, rodada 2 |
| Empate em pontos | Coritiba e Paraná, 5 pontos e 1 vitória cada |

A ordem entre Coritiba e Paraná é decidida pelo saldo de gols (0 contra -2).

## Formato da entrada

```
# rodada;mandante;gols mandante;gols visitante;visitante
1;Athletico;2;1;Coritiba
1;Londrina;0;0;Parana
```

Linhas em branco e linhas iniciadas por `#` são ignoradas, mas continuam
contando na numeração, para que a mensagem de erro aponte a linha correta.

## Erros detectados

| Construtor | Quando ocorre |
|---|---|
| `CamposInvalidos` | a linha não tem exatamente 5 campos |
| `NumeroInvalido` | rodada ou placar que não é número inteiro |
| `PlacarNegativo` | placar menor que zero |
| `MesmoTime` | um time aparece como mandante e visitante |
| `TimeRepetidoNaRodada` | um time joga mais de uma vez na mesma rodada |

Nenhuma entrada inválida encerra o programa com exceção: toda falha vira um
`Left` com o motivo e a localização.

## Documentação

As decisões de modelagem e as limitações conhecidas estão em
[`docs/decisoes.md`](docs/decisoes.md).