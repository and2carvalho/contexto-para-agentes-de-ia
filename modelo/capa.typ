// Capa, folha de rosto e página de créditos
#import "estilo.typ": *

#let capa(titulo: "", subtitulo: "", autor: "", edicao: "") = {
  set page(margin: 0pt, header: none, footer: none, fill: cor.primaria)
  materia.update("capa")
  let w = 17.6cm
  let h = 25cm
  // Motivo geométrico: anéis de projeção, nós e arestas
  place(top + left, {
    let cx = 12.2cm
    let cy = 9.2cm
    for (i, r) in (1.1cm, 2.2cm, 3.4cm, 4.7cm, 6.1cm, 7.6cm).enumerate() {
      place(top + left, dx: cx - r, dy: cy - r,
        circle(radius: r, stroke: (paint: rgb(255, 255, 255, 30 + 12 * (5 - i)), thickness: 0.6pt, dash: if calc.rem(i, 2) == 1 { "dashed" } else { none })))
    }
    // nós em anéis (posições determinísticas)
    let pontos = ()
    let raios = (1.1, 2.2, 3.4, 4.7, 6.1, 7.6)
    let k = 0
    for (j, r) in raios.enumerate() {
      let n = 3 + 2 * j
      for m in range(n) {
        let ang = (m / n) * 360deg + j * 23deg + calc.rem(m * 37, 17) * 1deg
        let x = cx + r * 1cm * calc.cos(ang)
        let y = cy + r * 1cm * calc.sin(ang)
        pontos.push((x, y, j))
        k += 1
      }
    }
    // arestas entre nós próximos (camadas adjacentes)
    for (a, p) in pontos.enumerate() {
      for (b, q) in pontos.enumerate() {
        if b > a and calc.abs(p.at(2) - q.at(2)) == 1 {
          let d = calc.sqrt(calc.pow((p.at(0) - q.at(0)) / 1cm, 2) + calc.pow((p.at(1) - q.at(1)) / 1cm, 2))
          if d < 1.45 {
            place(top + left, line(start: (p.at(0), p.at(1)), end: (q.at(0), q.at(1)),
              stroke: (paint: rgb(170, 200, 230, 150), thickness: 0.5pt)))
          }
        }
      }
    }
    for p in pontos {
      let destaque = p.at(2) <= 1
      let rr = if destaque { 2.6pt } else { 1.8pt }
      place(top + left, dx: p.at(0) - rr, dy: p.at(1) - rr,
        circle(radius: rr, fill: if destaque { rgb("#f2c46d") } else { rgb(210, 225, 240, 220) }, stroke: none))
    }
    // núcleo
    place(top + left, dx: cx - 5pt, dy: cy - 5pt, circle(radius: 5pt, fill: rgb("#f2c46d")))
  })
  // Textos
  place(top + left, dx: 1.7cm, dy: 15.6cm, block(width: 14.2cm, {
    set par(justify: false, first-line-indent: 0pt, leading: 0.5em)
    text(font: semserifa, size: 11pt, fill: rgb("#f2c46d"), tracking: 0.2em, upper(edicao))
    v(0.35cm)
    text(font: semserifa, size: 30pt, weight: "bold", fill: white, titulo)
    v(0.45cm)
    text(font: serifa, size: 13pt, style: "italic", fill: rgb("#d6e2ef"), subtitulo)
    v(1.4cm)
    line(length: 3.2cm, stroke: 1pt + rgb("#f2c46d"))
    v(0.3cm)
    text(font: semserifa, size: 12pt, fill: white, autor)
  }))
}

#let folha-de-rosto(titulo: "", subtitulo: "", autor: "", edicao: "", ano: "") = {
  pagebreak(to: "odd", weak: true)
  set par(first-line-indent: 0pt, justify: false)
  v(3.5cm)
  text(font: semserifa, size: 26pt, weight: "bold", fill: cor.primaria, titulo)
  v(0.5cm)
  text(font: serifa, size: 13pt, style: "italic", fill: cor.secundaria, subtitulo)
  v(0.4cm)
  line(length: 100%, stroke: 1pt + cor.primaria)
  v(1.2cm)
  text(font: semserifa, size: 13pt, autor)
  v(1fr)
  text(font: semserifa, size: 10pt, fill: cor.cinza)[#edicao · #ano]
}

#let creditos(corpo) = {
  pagebreak()
  set par(first-line-indent: 0pt, justify: false, spacing: 1.05em)
  set text(size: 8.4pt, fill: cor.cinza)
  v(1fr)
  corpo
}
