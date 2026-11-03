#import "modelo-cartilha.typ": *

#show: cartilha.with(titulo: "Seu agente não vê o que você acha que ele vê")

#capa(
  serie: "Contexto para agentes de IA · parte 2",
  titulo: [Seu agente não vê o que você acha que ele vê],
  subtitulo: [A cadeia de restrição em sete níveis],
)

#slide(titulo: [Do mundo à decisão])[
  Entre *tudo o que existe* e *o que o modelo de fato usou* há uma sequência de filtros.

  A cada filtro, parte da informação fica para trás — às vezes por boas razões (autoridade, relevância, orçamento), às vezes por defeito.

  #v(6pt)
  #caixa(titulo: [A pergunta certa], cor-borda: cor.primaria, fundo: cor.tinta-def)[
    Quando um agente erra, não pergunte só "o que ele sabia?". Pergunte: *em que nível a informação se perdeu?*
  ]
]

#let niveis = (
  ([Universo], [o que existe sobre o mundo]),
  ([Ambiente], [o que foi observado daqui]),
  ([Legível], [o que a autoridade permite ver]),
  ([Aplicável], [o que vale para esta situação]),
  ([Selecionado], [o que coube no orçamento]),
  ([Entregue], [o que chegou à janela]),
  ([Consumido], [o que o modelo usou]),
)

#slide(titulo: [Os sete níveis])[
  #set text(font: semserifa, size: 18pt)
  #for (i, (nome, desc)) in niveis.enumerate() {
    pad(left: i * 13pt, block(
      width: 100%, inset: (x: 12pt, y: 10pt), below: 4pt, radius: 2pt,
      fill: if calc.rem(i, 2) == 0 { cor.clara } else { cor.tinta-def },
      stroke: 0.7pt + cor.secundaria,
    )[#text(weight: "bold", fill: cor.primaria, nome) — #desc])
  }
  #v(10pt)
  #text(font: serifa, size: 19pt)[Cada nível está contido no anterior. O que sai da cadeia sai por uma razão — que deveria ser *declarada*.]
]

#slide(rotulo: [Níveis 1 e 2], titulo: [Universo → Ambiente])[
  O que existe não é o que foi observado a partir de onde o agente está.

  Outra máquina, outro repositório, outro serviço: fora do ambiente, a informação simplesmente não chegou.

  #v(6pt)
  #caixa(titulo: [Diagnóstico])[Isso foi observado *daqui*? Com que instrumento, e quando?]
]

#slide(rotulo: [Nível 3], titulo: [Legível])[
  A autoridade filtra *antes* da seleção.

  O que o agente não pode ver não deve disputar espaço com o que ele pode — e a retenção deve ser declarada, não silenciada: "existe algo aqui que você não pode ler".

  #v(6pt)
  #caixa(titulo: [Diagnóstico])[O agente *podia* ler isso? Se não podia, ele sabia que algo foi retido?]
]

#slide(rotulo: [Nível 4], titulo: [Aplicável])[
  Verdadeiro não basta: a informação precisa *valer para esta situação* — este ramo, este objetivo, este momento.

  Uma informação correta de outro contexto é um erro esperando para acontecer.

  #v(6pt)
  #caixa(titulo: [Diagnóstico])[Isso se aplicava *aqui e agora*, ou era verdade em outro lugar?]
]

#slide(rotulo: [Nível 5], titulo: [Selecionado])[
  A janela do modelo tem orçamento. Nem tudo o que é aplicável cabe.

  O que fica de fora deve aparecer como *omitido* ("12 itens omitidos por espaço"), nunca simplesmente sumir. Omissão não é negação.

  #v(6pt)
  #caixa(titulo: [Diagnóstico])[A informação *coube*? Se não coube, o agente sabia que ela existia?]
]

#slide(rotulo: [Níveis 6 e 7], titulo: [Entregue → Consumido])[
  Truncamentos e falhas de entrega fazem o selecionado não chegar à janela.

  E o que chega pode não ser usado: modelos atendem mal ao meio de contextos longos.

  #v(6pt)
  #caixa(titulo: [Para lembrar], cor-borda: cor.primaria, fundo: cor.tinta-def)[*Poder ver não é ter visto.*]
]

#slide(titulo: [Quando o agente erra])[
  #set text(font: semserifa, size: 19.5pt)
  #table(
    columns: (1fr, auto),
    stroke: none,
    inset: (x: 8pt, y: 8pt),
    fill: (_, y) => if calc.rem(y, 2) == 1 { cor.clara } else { none },
    table.header(
      text(weight: "bold", fill: cor.primaria)[Sintoma],
      text(weight: "bold", fill: cor.primaria)[Nível],
    ),
    [Não existia], [universo],
    [Não foi observado daqui], [ambiente],
    [Não podia ler], [legível],
    [Não se aplicava], [aplicável],
    [Não coube], [selecionado],
    [Não chegou], [entregue],
    [Chegou e foi ignorado], [consumido],
  )
  #v(8pt)
  #text(font: serifa, size: 19pt)[Cada nível tem uma correção diferente. Corrigir o nível errado não resolve nada.]
]

#chamada(
  fonte: [Capítulo 1 e Capítulo 27 (a cadeia de restrição, com a versão formal).],
  proxima: [Sim, não, não sei — e "as fontes discordam": os quatro estados que todo agente precisa distinguir.],
)
