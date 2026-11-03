#import "modelo-cartilha.typ": *

#show: cartilha.with(titulo: "7 confusões que fazem agentes de IA errarem")

#capa(
  serie: "Contexto para agentes de IA · parte 1",
  titulo: [7 confusões que fazem agentes de IA errarem],
  subtitulo: [— e o teste que evita cada uma],
)

#slide(titulo: [Por que agentes erram?])[
  Na maioria das vezes, não é o modelo. É o *contexto*: o agente recebeu informação desatualizada, incompleta ou fora de escopo — ou recebeu a informação certa e a leu errado.

  Quase toda falha desse tipo é uma *confusão entre duas coisas parecidas*.

  #v(6pt)
  #caixa(titulo: [A ideia], cor-borda: cor.primaria, fundo: cor.tinta-def)[
    Dar nome à diferença é o primeiro passo para #box[testá-la].
  ]
]

#let confusao(n, a, b, erro, teste) = slide(rotulo: [Confusão #n de 7])[
  #distincao(a, b)
  #caixa(titulo: [O erro], cor-borda: cor.anti, fundo: cor.tinta-anti, erro)
  #v(10pt)
  #caixa(titulo: [O teste], teste)
]

#confusao(1, [PODE VER], [VIU],
  ["A informação estava disponível, então o agente sabia."],
  [Registre o que foi *efetivamente entregue* ao modelo em cada chamada — não o que estava disponível.])

#confusao(2, [DESCONHECIDO], [NENHUM],
  [Um "não sei" vira campo vazio, "nenhum" ou "não" no caminho até o modelo.],
  [O desconhecido aparece *escrito, literalmente*, em todo contexto e em toda tela.])

#confusao(3, [NÃO ENCONTREI], [NÃO EXISTE],
  [Uma busca que não achou nada é tratada como prova de que a coisa não existe.],
  [Toda negativa carrega o seu *escopo*: onde, como e quando se procurou.])

#confusao(4, [CONTEXTO], [COMANDO],
  [Um documento recuperado diz "ignore as instruções anteriores" — e o agente obedece.],
  [Conteúdo que entra como *dado* nunca autoriza uma ação nem grava uma orientação permanente.])

#confusao(5, [RECIBO], [EFEITO],
  ["O comando retornou sucesso" é tratado como "a mudança aconteceu".],
  [Observe a *pós-condição* por um canal independente de quem executou.])

#confusao(6, [MAIS RECENTE], [ACEITO],
  [A última versão é tratada como a aprovada.],
  [Aceitação é um *ato registrado*, com autor e data — não uma consequência da ordem.])

#confusao(7, [MÉDIA], [CRITÉRIO],
  ["95% de acerto médio" esconde uma falha crítica que acontece em todas as execuções.],
  [Relate o resultado *por dimensão*: uma falha crítica reprova, qualquer que seja a média.])

#slide(titulo: [A regra geral])[
  Quando duas coisas parecem iguais, pergunte:

  #v(4pt)
  #align(center, text(font: semserifa, size: 25pt, weight: "bold", fill: cor.primaria)[Que teste as distinguiria?])
  #v(4pt)

  Se nenhum teste distingue, o sistema vai confundi-las — e o agente também.

  #v(6pt)
  #caixa(titulo: [Para levar], cor-borda: cor.primaria, fundo: cor.tinta-def)[
    Cada confusão tem um modo de falha, um exemplo real e um teste. Sem o teste, a distinção é só opinião.
  ]
]

#chamada(
  fonte: [Capítulo 1 e Apêndice E (catálogo de distinções e invariantes).],
  proxima: [O que um agente de IA _realmente_ vê: a cadeia de restrição em sete níveis.],
)
