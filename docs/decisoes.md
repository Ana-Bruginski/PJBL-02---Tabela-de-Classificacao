# Decisões de modelagem e limitações conhecidas

Este documento registra as escolhas de modelagem que o enunciado deixou em
aberto, o motivo de cada uma, e o que o sistema reconhecidamente não faz.

## Escolha do esporte

Usamos futebol. O enunciado permite outro esporte, mas as oito funções
obrigatórias já estão descritas em termos de futebol (3/1/0, saldo de gols,
goleada), e trocar exigiria reinterpretar os critérios de desempate.

O campeonato de teste é fictício, em turno único, com seis times do Paraná.
Seis times jogando uma vez contra cada adversário dão exatamente cinco rodadas,
que é o mínimo pedido, sem nenhuma rodada incompleta.

## Camada 1

**`Partida` é um record, não uma tupla.** Numa tupla, os dois campos `Int` dos
gols ficam adjacentes e trocar um pelo outro compila. Com campos nomeados,
`golsMandante p` e `golsVisitante p` não se confundem.

**`Resultado` é um tipo soma, não `String`.** Com `String`, um `"v"` minúsculo
só quebraria em tempo de execução. Com três construtores o conjunto de valores
está fechado, e o `-Wall` aponta qualquer função que esqueça um caso.

**`resultadoPara` devolve `Maybe Resultado`.** Um time que não jogou a partida
não tem vitória, empate nem derrota ali. A ausência fica no tipo, em vez de
virar um quarto valor inventado, e é o que permite que `acumular` ignore
partidas de outros times.

**`Linha` guarda contagens, não pontos.** Pontos, saldo e aproveitamento são
derivados na Camada 2. Guardar só o que foi observado evita uma linha
internamente inconsistente, com pontos que não correspondem às vitórias.

**`times` ordena alfabeticamente.** Sem isso a ordem dependeria de como as
partidas aparecem no texto, e os testes ficariam instáveis.

## Camada 2

**`linhaDoTime` usa `foldl'`, não `foldl`.** O acumulador é um valor único
construído na ordem das partidas, então a dobra à esquerda é a natural. A
variante com apóstrofo resolve os cálculos a cada passo em vez de acumulá-los
pendentes (aula 12). Para quinze partidas é irrelevante, mas não custa nada.

**Os números 3, 1 e 0 aparecem só em `pontos`.** `pontosLinha` e
`aproveitamento` chamam `pontos Vitoria` em vez de escrever `3`. Se a pontuação
mudar, muda um lugar só.

**Critérios de desempate, nesta ordem:** pontos, vitórias, saldo de gols, gols
pró e ordem alfabética. Os quatro primeiros são os usuais do futebol
brasileiro. O quinto existe para que a tabela nunca seja ambígua: sem ele, dois
times idênticos em tudo ficariam na ordem de digitação dos resultados.

A comparação é uma função só, montada com `comparing` e encadeada com `<>`.
Encadear vários `sortBy` não funcionaria, porque cada ordenação desfaz o
critério anterior em caso de empate. No campeonato de teste, Coritiba e Paraná
terminam com 5 pontos e 1 vitória cada, e quem decide é o saldo (0 contra -2).

**`maiorGoleada` usa uma dobra com `Maybe` no acumulador.** `maximumBy` é
parcial e lança exceção em lista vazia. Carregando o `Maybe` desde o valor
inicial, a função é total sem um `if null` na frente.

**`aproveitamento` usa `fromIntegral`.** `div` truncaria e `/` não aceita
`Int`. O caso de zero jogos é tratado por guarda, antes da divisão.

**Nenhuma recursão explícita e nenhuma função parcial nesta camada**, como o
enunciado exige. Um campeonato vazio produz uma tabela vazia, não uma exceção.

## Camada 3

**`Either Erro`, não `Maybe`.** `Maybe` diria apenas que a leitura falhou. Cada
construtor de `Erro` carrega a linha (ou a rodada) e o conteúdo problemático,
que é o que quem digitou o arquivo precisa para corrigir.

**`lerPartida` é um bloco `do` na mônada `Either`.** Sem ela, as cinco
validações encadeadas virariam `case` aninhados, uma escadinha de `Left erro ->
Left erro`. Na notação `do`, o primeiro `Left` interrompe o bloco.

**`lerCampeonato` usa `traverse`.** Em vez de uma lista de `Either`, devolve um
`Either` de lista. Basta uma linha falhar para o resultado inteiro ser `Left`,
que é o comportamento pedido.

**`todosOsErros` não é `lerCampeonato` repetido.** Ele avalia todas as linhas
independentemente, junta os `Left` e acrescenta as repetições de time
encontradas entre as linhas que passaram. Uma linha inválida não impede que o
relatório encontre os problemas das seguintes.

**`readMaybe` em vez de `read`.** `read "dois"` derruba o programa com
`Prelude.read: no parse`. `readMaybe` devolve `Nothing`, que vira
`NumeroInvalido`, mantendo a função total.

**A numeração conta as linhas ignoradas.** Comentários e linhas em branco não
viram partidas, mas continuam contando, para que o número na mensagem de erro
seja o da linha real no arquivo.

**Os dados ficam no código, como `String`.** O playground não tem entrada
padrão nem sistema de arquivos, e um `main` com `getLine` termina em
`hGetLine: end of file`. Com os dados em `Dados.hs` o mesmo programa roda nos
dois ambientes, e trocar para `readFile` exigiria mudar só o `main`.

**`main` é a única função com `IO` em todo o projeto.** O relatório inteiro é
montado como uma `String` pura por `relatorio`, e só o `putStr` final toca a
tela. Isso torna a saída testável sem executar nada.

**Texto sem acentos nos arquivos `.hs`.** No Windows o terminal nem sempre está
em UTF-8, e imprimir um caractere acentuado derruba o programa com
`commitBuffer: invalid argument`. Como o critério de corte do enunciado é o
programa executar, preferimos não depender da codificação da máquina de quem
for avaliar.

## Limitações conhecidas

- **Não há validação de calendário.** Conferimos que um time não joga duas
  vezes na mesma rodada, como o enunciado pede, mas não que todos jogaram em
  todas as rodadas, nem que dois times se enfrentam uma vez só.

- **A rodada não é validada.** Uma rodada `0` ou negativa é aceita, porque
  `PlacarNegativo` é definido no enunciado apenas para o placar.

- **`todosOsErros` reporta no máximo um erro por linha.** O bloco `do` para no
  primeiro problema de cada linha. Reportar os dois exigiria um acumulador de
  erros em vez de `Either`.

- **A largura das colunas é fixa.** Um nome com mais de 12 caracteres desalinha
  a coluna seguinte, sem quebrar o programa.

- **Empates na maior goleada não são todos mostrados.** Se duas partidas
  tiverem a mesma diferença, fica a primeira da lista.

- **`aproveitamento` não é usado na ordenação.** É calculado e exibido para o
  líder, mas o desempate segue a prática do futebol brasileiro.