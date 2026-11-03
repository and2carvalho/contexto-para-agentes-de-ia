#import "modelo-cartilha.typ": *

#show: cartilha.with(titulo: "Os quatro estados que todo agente precisa distinguir")

#capa(
  serie: "Contexto para agentes de IA · parte 3",
  titulo: [Sim, não, não sei — e "as fontes discordam"],
  subtitulo: [Os quatro estados que separam um agente confiável de um agente apenas confiante],
)

#slide(titulo: [Verdadeiro e falso não bastam])[
  A maioria dos sistemas registra fatos como verdadeiros ou falsos.

  Um agente trabalha com informação *incompleta* e com fontes que *se contradizem*. Para não inventar certezas, ele precisa de quatro estados.

  #v(6pt)
  #caixa(titulo: [A ideia], cor-borda: cor.primaria, fundo: cor.tinta-def)[
    O estado de um fato é _o que nos foi dito_ sobre ele — não o que gostaríamos que fosse.
  ]
]

#let no(nome, desc, fundo) = box(
  width: 150pt, inset: (x: 10pt, y: 10pt), radius: 3pt, fill: fundo, stroke: 0.8pt + cor.secundaria,
  align(center)[#text(size: 21pt, fill: cor.primaria, est(nome)) \ #text(font: semserifa, size: 13.5pt, fill: cor.cinza, desc)],
)

#slide(titulo: [O mapa dos quatro estados])[
  #let w = 448pt
  #let h = 330pt
  #box(width: w, height: h, {
    let cx = w / 2
    let topo = (cx - 75pt, 0pt)
    let esq = (0pt, 125pt)
    let dir = (w - 150pt, 125pt)
    let base = (cx - 75pt, 250pt)
    // arestas
    let lc(a, b) = place(top + left, line(start: a, end: b, stroke: 1.2pt + cor.cinza-claro))
    lc((cx, 66pt), (75pt, 125pt))
    lc((cx, 66pt), (w - 75pt, 125pt))
    lc((75pt, 191pt), (cx, 250pt))
    lc((w - 75pt, 191pt), (cx, 250pt))
    place(top + left, dx: topo.at(0), dy: topo.at(1), no([conflitante], [a favor e contra], cor.tinta-anti))
    place(top + left, dx: esq.at(0), dy: esq.at(1), no([provado], [só a favor], cor.tinta-inv))
    place(top + left, dx: dir.at(0), dy: dir.at(1), no([refutado], [só contra], cor.tinta-princ))
    place(top + left, dx: base.at(0), dy: base.at(1), no([desconhecido], [nada foi dito], cor.clara))
    // seta "mais informação"
    place(top + left, dx: cx - 1pt, dy: 200pt, line(start: (0pt, 0pt), end: (0pt, -110pt), stroke: (paint: cor.secundaria, thickness: 1.4pt, dash: "dashed")))
    place(top + left, dx: cx - 6pt, dy: 84pt, text(size: 16pt, fill: cor.secundaria)[▲])
    place(top + left, dx: cx + 8pt, dy: 140pt, text(font: semserifa, size: 12.5pt, fill: cor.secundaria)[mais\ informação])
  })
  #v(4pt)
  #text(size: 19pt)[Subir no mapa é receber mais informação — inclusive informação que contradiz a que já existia.]
]

#slide(rotulo: [Estado 1], titulo: [#est[Provado]])[
  Há evidência *a favor*, com âncora: de onde veio, quando, como foi obtida.

  #v(6pt)
  #caixa(titulo: [Cuidado], cor-borda: cor.princ, fundo: cor.tinta-princ)[
    Provado não é "verdadeiro para sempre". Vale para o *instante* e o *escopo* da evidência.
  ]
]

#slide(rotulo: [Estado 2], titulo: [#est[Refutado]])[
  Há evidência *explícita contra* — uma observação que mostra o contrário, com escopo declarado.

  #v(6pt)
  #caixa(titulo: [Cuidado], cor-borda: cor.princ, fundo: cor.tinta-princ)[
    "Não encontrei" *não* é refutado. É desconhecido — a menos que a busca tenha escopo e cobertura declarados.
  ]
]

#slide(rotulo: [Estado 3], titulo: [#est[Desconhecido]])[
  Não há evidência suficiente. É uma resposta *legítima* — e precisa aparecer escrita.

  #v(6pt)
  #caixa(titulo: [A falha mais comum], cor-borda: cor.anti, fundo: cor.tinta-anti)[
    Um "desconhecido" que vira campo vazio, "nenhum" ou "não" no caminho até o modelo.
  ]
]

#slide(rotulo: [Estado 4], titulo: [#est[Conflitante]])[
  As fontes discordam: uma diz que sim, outra diz que não.

  #v(6pt)
  #caixa(titulo: [O que fazer], cor-borda: cor.inv, fundo: cor.tinta-inv)[
    Não escolha a fonte mais recente em silêncio. *Exponha o conflito* a quem tem autoridade para resolvê-lo.
  ]
]

#slide(titulo: [Três regras práticas])[
  #set enum(numbering: n => text(font: semserifa, weight: "bold", fill: ouro.darken(25%))[#n.])
  + Nunca transforme #est[desconhecido] em falso ou em vazio.
  + Execute ações só sobre condições #est[provadas]. Na dúvida, não age — e diz o que falta saber.
  + Combine relatos sem depender da ordem de chegada: a favor + contra = #est[conflitante], nunca "o último vence".
]

#chamada(
  fonte: [Capítulos 3 e 4 e Apêndice B (a lógica de quatro valores de Belnap).],
  proxima: none,
)
