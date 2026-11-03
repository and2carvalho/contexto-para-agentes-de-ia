// Modelo das cartilhas (carrosséis em PDF para o LinkedIn), formato 4:5.
// Mesma identidade visual do livro: cores, fontes e o motivo de anéis da capa.
#import "/modelo/estilo.typ": cor, serifa, semserifa, mono

#let autor = "André Antero de Carvalho"
#let obra = "Contexto para Agentes de IA"
#let ouro = rgb("#f2c46d")
#let azul-claro = rgb("#d6e2ef")

#let _rodape(escuro: false) = context {
  let n = counter(page).get().first()
  let total = counter(page).final().first()
  let tinta = if escuro { azul-claro } else { cor.cinza }
  set text(font: semserifa, size: 11pt, fill: tinta)
  grid(
    columns: (1fr, auto),
    align: (left, right),
    [#autor #h(0.4em)·#h(0.4em) #emph(obra)],
    [#n / #total],
  )
}

#let cartilha(titulo: "", corpo) = {
  set document(title: titulo, author: autor)
  set page(
    width: 540pt, height: 675pt,
    margin: (x: 46pt, top: 56pt, bottom: 72pt),
    footer: _rodape(),
    footer-descent: 40%,
  )
  set text(font: serifa, size: 22pt, lang: "pt", region: "br", fill: rgb("#1f1f1f"), hyphenate: false)
  set par(justify: false, leading: 0.62em, spacing: 1.05em)
  set list(marker: text(fill: cor.secundaria)[•], indent: 2pt, body-indent: 9pt, spacing: 0.8em)
  set enum(indent: 2pt, body-indent: 9pt, spacing: 0.9em)
  set strong(delta: 200)
  corpo
}

// Motivo de anéis concêntricos com nós, como na capa do livro
#let _aneis(cx, cy, escala: 1) = {
  for (i, r) in (34pt, 68pt, 104pt, 144pt, 188pt, 236pt).enumerate() {
    let r = r * escala
    place(top + left, dx: cx - r, dy: cy - r,
      circle(radius: r, stroke: (paint: rgb(255, 255, 255, 34 + 12 * (5 - i)), thickness: 0.8pt,
        dash: if calc.rem(i, 2) == 1 { "dashed" } else { none })))
  }
  let raios = (34, 68, 104, 144, 188, 236)
  for (j, r) in raios.enumerate() {
    let n = 3 + 2 * j
    for m in range(n) {
      let ang = (m / n) * 360deg + j * 23deg + calc.rem(m * 37, 17) * 1deg
      let x = cx + r * escala * 1pt * calc.cos(ang)
      let y = cy + r * escala * 1pt * calc.sin(ang)
      let destaque = j <= 1
      let rr = if destaque { 4pt } else { 2.6pt }
      place(top + left, dx: x - rr, dy: y - rr,
        circle(radius: rr, fill: if destaque { ouro } else { rgb(210, 225, 240, 200) }, stroke: none))
    }
  }
  place(top + left, dx: cx - 7pt, dy: cy - 7pt, circle(radius: 7pt, fill: ouro))
}

// Capa do carrossel
#let capa(serie: "", titulo: [], subtitulo: []) = page(
  fill: cor.primaria,
  margin: (x: 46pt, top: 56pt, bottom: 72pt),
  footer: _rodape(escuro: true),
)[
  #place(top + left, dx: -46pt, dy: -56pt, _aneis(430pt, 120pt, escala: 0.85))
  #v(1fr)
  #text(font: semserifa, size: 13pt, fill: ouro, tracking: 0.18em, upper(serie))
  #v(10pt)
  #text(font: semserifa, size: 37pt, weight: "bold", fill: white, titulo)
  #v(14pt)
  #text(font: serifa, size: 21pt, style: "italic", fill: azul-claro, subtitulo)
  #v(26pt)
  #line(length: 70pt, stroke: 1.4pt + ouro)
  #v(8pt)
  #text(font: semserifa, size: 15pt, fill: white, autor)
  #v(8pt)
]

// Slide de conteúdo com título
#let slide(titulo: none, rotulo: none, corpo) = page[
  #if rotulo != none {
    text(font: semserifa, size: 13pt, fill: cor.secundaria, tracking: 0.14em, upper(rotulo))
    v(4pt)
  }
  #if titulo != none {
    block(below: 18pt, text(font: semserifa, size: 31pt, weight: "bold", fill: cor.primaria, titulo))
    line(length: 60pt, stroke: 1.8pt + ouro)
  }
  #v(1fr)
  #corpo
  #v(1.25fr)
]

// Destaque em caixa (regra, teste, conclusão)
#let caixa(titulo: none, cor-borda: cor.inv, fundo: cor.tinta-inv, corpo) = block(
  width: 100%, inset: (x: 18pt, y: 16pt), fill: fundo, radius: 3pt,
  stroke: (left: 3pt + cor-borda),
)[
  #if titulo != none {
    text(font: semserifa, size: 14.5pt, weight: "bold", fill: cor-borda, tracking: 0.08em, upper(titulo))
    v(3pt)
  }
  #corpo
]

// "A ≠ B" em destaque
#let distincao(a, b) = block(below: 20pt,
  text(font: mono, size: 27pt, weight: "bold", fill: cor.primaria)[#a #text(fill: cor.anti)[≠] #b])

// Estado epistêmico em versalete, como no livro
#let est(s) = text(font: serifa, smallcaps(s))

// Slide final com a chamada
#let chamada(fonte: [], proxima: none) = page(
  fill: cor.primaria,
  footer: _rodape(escuro: true),
)[
  #place(top + left, dx: -46pt, dy: -56pt, _aneis(540pt, 40pt, escala: 0.62))
  #set text(fill: white)
  #v(1fr)
  #text(font: semserifa, size: 13pt, fill: ouro, tracking: 0.18em)[DE ONDE VEM ESTE CONTEÚDO]
  #v(10pt)
  #text(size: 25pt)[Do livro #text(weight: "bold")[#emph(obra)], de #autor.]
  #v(6pt)
  #text(size: 19pt, fill: azul-claro, fonte)
  #if proxima == none {
    v(26pt)
    line(length: 70pt, stroke: 1.4pt + ouro)
    v(8pt)
    text(size: 21pt)[Siga #autor para acompanhar as próximas partes da série.]
  } else {
    v(26pt)
    line(length: 70pt, stroke: 1.4pt + ouro)
    v(8pt)
    text(font: semserifa, size: 13pt, fill: ouro, tracking: 0.18em)[NA PRÓXIMA PARTE]
    v(4pt)
    text(size: 23pt, proxima)
  }
  #v(1.4fr)
]
