// =====================================================================
//  estilo.typ — modelo tipográfico do livro
//  Formato ISO B5 (17,6 × 25 cm), Libertinus (serifa, sem serifa, math)
//  e JetBrains Mono. Todos os ambientes do livro são definidos aqui.
// =====================================================================

#import "@preview/lovelace:0.3.1": pseudocode-list, indent, no-number
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// ---------------------------------------------------------------------
//  Paleta e fontes
// ---------------------------------------------------------------------
#let cor = (
  primaria: rgb("#1b3a63"),
  secundaria: rgb("#3c6e91"),
  clara: rgb("#e9eff6"),
  def: rgb("#1b3a63"),
  tinta-def: rgb("#eef3f9"),
  teo: rgb("#4a4a4a"),
  inv: rgb("#25634a"),
  tinta-inv: rgb("#edf5f0"),
  princ: rgb("#8a5a12"),
  tinta-princ: rgb("#fbf5e9"),
  anti: rgb("#9b2c2c"),
  tinta-anti: rgb("#fbeeee"),
  caso: rgb("#4f4f4f"),
  tinta-caso: rgb("#f4f3ef"),
  cinza: rgb("#6b6b6b"),
  cinza-claro: rgb("#d9d9d9"),
)

#let serifa = ("Libertinus Serif",)
#let semserifa = ("Libertinus Sans",)
#let mono = ("JetBrains Mono",)

// ---------------------------------------------------------------------
//  Estado global: matéria (pré-textual, textual, apêndice)
// ---------------------------------------------------------------------
#let materia = state("materia", "pre")

// Número do capítulo corrente formatado (1, 2, … ou A, B, … nos apêndices)
#let fmt-cap(n) = context {
  if materia.get() == "apendice" { numbering("A", n) } else { str(n) }
}
#let fmt-pagina() = if materia.get() == "pre" { "i" } else { "1" }

#let num-cap-str() = {
  let n = counter(heading).get().at(0, default: 0)
  if materia.get() == "apendice" { numbering("A", n) } else { str(n) }
}

// Numeração "capítulo.n" para figuras, tabelas, ambientes formais e equações.
// (Chamada sempre em contexto: o Typst avalia a numeração na posição do elemento.)
#let num-por-cap(..ns) = {
  let n = ns.pos().last()
  if materia.get() == "pre" { return str(n) }
  let c = counter(heading).get().at(0, default: 0)
  let cs = if materia.get() == "apendice" { numbering("A", c) } else { str(c) }
  cs + "." + str(n)
}

/// Equação numerada: #eqn($ ... $) <eq-rotulo>
#let eqn(corpo) = math.equation(corpo.body, block: true, numbering: (..n) => "(" + num-por-cap(..n) + ")")

// ---------------------------------------------------------------------
//  Índice remissivo (implementação própria, com colação em português)
// ---------------------------------------------------------------------
#let _sem-acento(s) = {
  let mapa = (
    "á": "a", "à": "a", "â": "a", "ã": "a", "ä": "a",
    "é": "e", "ê": "e", "è": "e", "ë": "e",
    "í": "i", "î": "i", "ì": "i", "ï": "i",
    "ó": "o", "ô": "o", "õ": "o", "ò": "o", "ö": "o",
    "ú": "u", "û": "u", "ù": "u", "ü": "u",
    "ç": "c", "ñ": "n",
  )
  let r = ""
  for ch in lower(s).clusters() {
    r += mapa.at(ch, default: ch)
  }
  r
}

/// Marca um termo para o índice remissivo. `sub` cria subentrada.
/// O conteúdo do termo NÃO é impresso no texto (marcador invisível).
#let ix(termo, sub: none) = [#metadata((termo: termo, sub: sub))<indice-entrada>]

/// Imprime o termo no texto e o marca no índice.
#let ixt(termo, sub: none, mostrar: none) = {
  ix(termo, sub: sub)
  if mostrar == none { termo } else { mostrar }
}

#let indice-remissivo() = context {
  let entradas = query(<indice-entrada>)
  // termo -> (paginas, subs: dict sub -> paginas)
  let d = (:)
  for e in entradas {
    let v = e.value
    let pag = counter(page).at(e.location()).first()
    let loc = e.location()
    let k = v.termo
    if k not in d { d.insert(k, (pags: (), subs: (:))) }
    let item = d.at(k)
    if v.sub == none {
      if (pag, loc) not in item.pags { item.pags.push((pag, loc)) }
    } else {
      if v.sub not in item.subs { item.subs.insert(v.sub, ()) }
      let l = item.subs.at(v.sub)
      l.push((pag, loc))
      item.subs.insert(v.sub, l)
    }
    d.insert(k, item)
  }
  let chaves = d.keys().sorted(key: k => _sem-acento(k))
  let fmt-pags(lst) = {
    let vistos = ()
    let partes = ()
    for (p, loc) in lst {
      if p not in vistos {
        vistos.push(p)
        partes.push(link(loc, str(p)))
      }
    }
    partes.join(", ")
  }
  set text(size: 8.6pt)
  set par(justify: false, first-line-indent: 0pt, hanging-indent: 1.2em, spacing: 0.35em)
  columns(2, gutter: 1.4em, {
    let inicial-ant = ""
    for k in chaves {
      let ini = upper(_sem-acento(k).clusters().first())
      if ini != inicial-ant {
        if inicial-ant != "" { v(0.5em) }
        block(above: 0.8em, below: 0.4em, text(font: semserifa, weight: "bold", size: 10pt, fill: cor.primaria, ini))
        inicial-ant = ini
      }
      let item = d.at(k)
      par[#k#if item.pags.len() > 0 [, #fmt-pags(item.pags)]]
      for s in item.subs.keys().sorted(key: x => _sem-acento(x)) {
        par(hanging-indent: 2.4em)[#h(1.2em)#s, #fmt-pags(item.subs.at(s))]
      }
    }
  })
}

// ---------------------------------------------------------------------
//  Ambientes formais (definições, teoremas, invariantes, …)
//  Todos compartilham um contador por capítulo: "Teorema 3.4".
// ---------------------------------------------------------------------
#let _estilos-formais = (
  "Definição": (borda: cor.def, fundo: cor.tinta-def, italico: false),
  "Teorema": (borda: cor.teo, fundo: none, italico: true),
  "Lema": (borda: cor.teo, fundo: none, italico: true),
  "Corolário": (borda: cor.teo, fundo: none, italico: true),
  "Proposição": (borda: cor.teo, fundo: none, italico: true),
  "Conjectura": (borda: cor.teo, fundo: none, italico: true),
  "Fato": (borda: cor.teo, fundo: none, italico: false),
  "Invariante": (borda: cor.inv, fundo: cor.tinta-inv, italico: false),
  "Princípio": (borda: cor.princ, fundo: cor.tinta-princ, italico: false),
  "Antipadrão": (borda: cor.anti, fundo: cor.tinta-anti, italico: false),
  "Exemplo": (borda: cor.secundaria, fundo: none, italico: false),
  "Axioma": (borda: cor.def, fundo: cor.tinta-def, italico: true),
  "Hipótese": (borda: cor.princ, fundo: none, italico: true),
)

#let _formal(tipo, titulo, corpo) = figure(
  kind: "formal",
  supplement: tipo,
  numbering: num-por-cap,
  outlined: false,
  caption: if titulo == none { none } else { titulo },
  corpo,
)

#let definicao(titulo: none, corpo) = _formal("Definição", titulo, corpo)
#let teorema(titulo: none, corpo) = _formal("Teorema", titulo, corpo)
#let lema(titulo: none, corpo) = _formal("Lema", titulo, corpo)
#let corolario(titulo: none, corpo) = _formal("Corolário", titulo, corpo)
#let proposicao(titulo: none, corpo) = _formal("Proposição", titulo, corpo)
#let conjectura(titulo: none, corpo) = _formal("Conjectura", titulo, corpo)
/// Fato: consequência imediata das definições, registrada para referência.
#let fato(titulo: none, corpo) = _formal("Fato", titulo, corpo)
#let invariante(titulo: none, corpo) = _formal("Invariante", titulo, corpo)
#let principio(titulo: none, corpo) = _formal("Princípio", titulo, corpo)
#let antipadrao(titulo: none, corpo) = _formal("Antipadrão", titulo, corpo)
#let exemplo(titulo: none, corpo) = _formal("Exemplo", titulo, corpo)
#let axioma(titulo: none, corpo) = _formal("Axioma", titulo, corpo)
#let hipotese(titulo: none, corpo) = _formal("Hipótese", titulo, corpo)

/// Extrai o texto simples de um conteúdo (para o índice remissivo).
#let _texto(c) = {
  if c == none { "" }
  else if type(c) == str { c }
  else if c.func() == [ ].func() { " " }
  else if c.has("text") { c.text }
  else if c.has("children") { c.children.map(_texto).join("") }
  else if c.has("body") { _texto(c.body) }
  else if c.has("child") { _texto(c.child) }
  else { "" }
}

/// Termo de índice a partir do título de uma definição: minúscula inicial,
/// exceto quando a segunda letra também é maiúscula (siglas, nomes próprios).
#let _termo-indice(c) = {
  let t = _texto(c).trim()
  let cs = t.clusters()
  if cs.len() > 1 and lower(cs.at(1)) == cs.at(1) { lower(cs.first()) + cs.slice(1).join("") } else { t }
}

#let _mostra-formal(it) = {
  let tipo = if type(it.supplement) == str { it.supplement } else if it.supplement.has("text") { it.supplement.text } else { "Definição" }
  if tipo == "Definição" and it.caption != none { ix(_termo-indice(it.caption.body)) }
  let est = _estilos-formais.at(tipo, default: _estilos-formais.at("Definição"))
  let numero = it.counter.display(it.numbering)
  let rotulo = text(font: semserifa, weight: "bold", fill: est.borda)[#it.supplement #numero]
  let titulo = if it.caption != none {
    text(font: semserifa, weight: "bold", fill: est.borda)[ (#it.caption.body)]
  }
  let corpo = if est.italico { emph(it.body) } else { it.body }
  let fim = if tipo == "Exemplo" { [#h(1fr)#text(fill: est.borda, size: 0.8em)[$triangle.l$]] }
  set align(left)
  set par(first-line-indent: 0pt)
  block(
    width: 100%,
    breakable: true,
    above: 1.1em,
    below: 1.1em,
    fill: est.fundo,
    inset: if est.fundo == none { (left: 9pt, rest: 2pt) } else { (left: 9pt, right: 8pt, top: 7pt, bottom: 7pt) },
    stroke: (left: (paint: est.borda, thickness: if est.fundo == none { 1pt } else { 2.4pt })),
    [#rotulo#titulo#text(font: semserifa, weight: "bold", fill: est.borda)[.] #corpo#fim],
  )
}

/// Prova, com quadrado de fim de demonstração.
#let prova(titulo: [Prova], corpo) = block(
  width: 100%,
  breakable: true,
  above: 0.7em,
  below: 1.2em,
  [#set par(first-line-indent: 0pt)
    #emph(titulo). #corpo#h(1fr)#box(baseline: 0pt, text(size: 0.9em)[$square.filled$])],
)

/// Observação curta, sem numeração.
#let observacao(titulo: [Observação], corpo) = block(
  width: 100%,
  breakable: true,
  above: 0.9em,
  below: 0.9em,
  [#set par(first-line-indent: 0pt)
    #text(font: semserifa, weight: "bold", fill: cor.secundaria)[#titulo.] #corpo],
)

/// Estudo de caso (moldura com faixa de título), numerado por capítulo.
#let estudo-de-caso(titulo: none, corpo) = figure(
  kind: "caso",
  supplement: [Estudo de caso],
  numbering: num-por-cap,
  outlined: false,
  caption: titulo,
  corpo,
)

#let _mostra-caso(it) = {
  set align(left)
  set par(first-line-indent: 0pt)
  let numero = it.counter.display(it.numbering)
  block(
    width: 100%,
    breakable: true,
    above: 1.3em,
    below: 1.3em,
    stroke: 0.6pt + cor.caso,
    radius: 2pt,
    clip: false,
    {
      block(
        width: 100%,
        fill: cor.caso,
        inset: (x: 8pt, y: 5pt),
        below: 0pt,
        text(font: semserifa, weight: "bold", fill: white, size: 9.5pt)[
          Estudo de caso #numero#if it.caption != none [ — #it.caption.body]
        ],
      )
      block(width: 100%, fill: cor.tinta-caso, inset: (x: 9pt, y: 8pt), above: 0pt, text(size: 0.96em, it.body))
    },
  )
}

/// Quadro "Em resumo" / pontos-chave.
#let quadro(titulo: [Pontos-chave], corpo) = block(
  width: 100%,
  breakable: true,
  above: 1.3em,
  below: 1.3em,
  fill: cor.clara,
  inset: 10pt,
  radius: 2pt,
  [#set par(first-line-indent: 0pt)
    #text(font: semserifa, weight: "bold", fill: cor.primaria)[#titulo]
    #v(0.2em)
    #corpo],
)

// ---------------------------------------------------------------------
//  Algoritmos (pseudocódigo com lovelace)
// ---------------------------------------------------------------------
#let proc(nome) = smallcaps(nome)

#let algoritmo(nome, params: none, legenda: none, corpo) = figure(
  kind: "algoritmo",
  supplement: [Algoritmo],
  numbering: num-por-cap,
  outlined: true,
  caption: legenda,
  block(
    width: 100%,
    breakable: false,
    stroke: (top: 0.9pt + cor.primaria, bottom: 0.9pt + cor.primaria),
    inset: (x: 2pt, top: 6pt, bottom: 6pt),
    {
      set align(left)
      set par(first-line-indent: 0pt, justify: false)
      set text(size: 9.6pt)
      block(below: 0.6em, text(weight: "regular")[#ix(nome)#proc(nome)#if params != none [(#params)]])
      line(length: 100%, stroke: 0.4pt + cor.cinza-claro)
      pseudocode-list(
        line-gap: 0.62em,
        indentation: 1.3em,
        stroke: 0.5pt + cor.cinza-claro,
        number-align: right,
        corpo,
      )
    },
  ),
)

// Palavras-chave do pseudocódigo
#let kw(s) = text(weight: "bold", s)

// ---------------------------------------------------------------------
//  Exercícios, problemas e notas
// ---------------------------------------------------------------------
#let exercicios(corpo) = context {
  let h = counter(heading).get()
  let c = h.at(0, default: 0)
  let cs = if materia.get() == "apendice" { numbering("A", c) } else { str(c) }
  let pref = cs + "." + str(h.at(1, default: 0))
  block(above: 1.6em, below: 1.2em, breakable: true, {
    block(below: 0.7em, sticky: true, {
      text(font: semserifa, weight: "bold", size: 10.5pt, fill: cor.primaria)[Exercícios]
    })
    set par(first-line-indent: 0pt)
    set enum(
      numbering: n => text(font: semserifa, weight: "bold", size: 0.92em, fill: cor.primaria)[#pref\-#n],
      body-indent: 0.7em,
      spacing: 1em,
      tight: false,
    )
    corpo
  })
}

/// Marca de exercício/seção avançada (★), como no CLRS.
#let avancado = text(fill: cor.princ)[★]

#let _cont-problema = counter("problema")

#let problemas(corpo) = {
  block(above: 2em, below: 1em, sticky: true, {
    line(length: 100%, stroke: 0.6pt + cor.primaria)
    v(-0.4em)
    text(font: semserifa, weight: "bold", size: 13pt, fill: cor.primaria)[Problemas]
  })
  _cont-problema.update(0)
  corpo
}

#let problema(titulo, corpo) = {
  _cont-problema.step()
  block(above: 1.4em, below: 1em, breakable: true, {
    block(below: 0.6em, sticky: true, context {
      let c = counter(heading).get().at(0, default: 0)
      let cs = if materia.get() == "apendice" { numbering("A", c) } else { str(c) }
      text(font: semserifa, weight: "bold", size: 10.5pt)[
        #text(fill: cor.primaria)[#cs\-#_cont-problema.display()]#h(0.7em)#titulo
      ]
    })
    set par(first-line-indent: 0pt)
    set enum(numbering: "a.", body-indent: 0.6em, spacing: 0.8em)
    corpo
  })
}

#let notas(corpo) = {
  block(above: 2em, below: 1em, sticky: true, {
    line(length: 100%, stroke: 0.6pt + cor.primaria)
    v(-0.4em)
    text(font: semserifa, weight: "bold", size: 13pt, fill: cor.primaria)[Notas do capítulo]
  })
  set par(first-line-indent: 0pt, spacing: 0.9em)
  corpo
}

// ---------------------------------------------------------------------
//  Tabelas no estilo "booktabs"
// ---------------------------------------------------------------------
#let tabela(colunas: auto, alinhamento: left, cabecalho: (), ..celulas) = {
  let n = if type(colunas) == int { colunas } else { colunas.len() }
  set par(justify: false)
  table(
    columns: colunas,
    align: alinhamento,
    stroke: none,
    inset: (x: 5pt, y: 4pt),
    table.header(
      table.hline(stroke: 0.9pt),
      ..cabecalho.map(c => text(font: semserifa, weight: "bold", size: 0.92em, c)),
      table.hline(stroke: 0.5pt),
    ),
    ..celulas,
    table.hline(stroke: 0.9pt),
  )
}

// Desigualdade conceitual em destaque: A ≠ B
#let neq(a, b) = box(text(font: mono, size: 0.84em)[#a #text(fill: cor.anti)[≠] #b])

// ---------------------------------------------------------------------
//  Partes do livro
// ---------------------------------------------------------------------
#let cont-parte = counter("parte")

#let parte(titulo, intro) = {
  [#metadata("fim")<fim-bloco>]
  pagebreak(to: "odd", weak: true)
  cont-parte.step()
  context {
    let n = cont-parte.get().first()
    [#metadata((tipo: "parte", numero: n, titulo: titulo))<marca-parte>]
  }
  v(5.5cm)
  align(right, context {
    let n = cont-parte.get().first()
    text(font: semserifa, size: 13pt, fill: cor.secundaria, tracking: 0.25em)[PARTE]
    linebreak()
    text(font: serifa, size: 72pt, fill: cor.primaria, numbering("I", n))
  })
  v(0.3cm)
  line(length: 100%, stroke: 1.2pt + cor.primaria)
  v(0.3cm)
  align(right, text(font: semserifa, size: 24pt, weight: "bold", fill: cor.primaria, titulo))
  v(1.2cm)
  set par(first-line-indent: 0pt, justify: true)
  text(size: 10.5pt, intro)
}

// ---------------------------------------------------------------------
//  Cabeçalhos e rodapés
// ---------------------------------------------------------------------
#let _cabecalho = context {
  let pg = here().page()
  let mat = materia.get()
  if mat == "capa" { return }
  // Sem cabeçalho em página que abre capítulo
  let abertos = query(heading.where(level: 1)).filter(h => h.location().page() == pg)
  if abertos.len() > 0 { return }
  let partes = query(<marca-parte>).filter(m => m.location().page() == pg)
  if partes.len() > 0 { return }
  // Página em branco (inserida para abrir capítulo em página ímpar)?
  let fins = query(selector(<fim-bloco>).before(here()))
  if fins.len() > 0 {
    let m = fins.last()
    if m.location().page() < pg {
      let prox = query(selector(heading.where(level: 1)).or(<marca-parte>).after(m.location()))
      if prox.len() > 0 and prox.first().location().page() > pg { return }
    }
  }
  let antes = query(heading.where(level: 1).before(here()))
  if antes.len() == 0 { return }
  let cap = antes.last()
  let numpag = counter(page).display(fmt-pagina())
  set text(font: semserifa, size: 8.6pt, fill: cor.cinza)
  if calc.even(pg) {
    let rot = if cap.numbering != none {
      let c = counter(heading).at(cap.location()).first()
      let cs = if materia.at(cap.location()) == "apendice" { [Apêndice #numbering("A", c)] } else { [Capítulo #c] }
      [#cs#h(0.8em)#cap.body]
    } else { cap.body }
    grid(columns: (auto, 1fr), text(weight: "bold", fill: cor.primaria, numpag), align(right, rot))
  } else {
    let secs = query(heading.where(level: 2).before(here())).filter(s => s.location().position().page >= cap.location().page())
    let rot = if secs.len() > 0 and secs.last().numbering != none {
      let s = secs.last()
      let hs = counter(heading).at(s.location())
      let cs = if materia.at(s.location()) == "apendice" { numbering("A", hs.at(0)) } else { str(hs.at(0)) }
      [#cs.#hs.at(1)#h(0.8em)#s.body]
    } else if secs.len() > 0 { secs.last().body } else { cap.body }
    grid(columns: (1fr, auto), rot, text(weight: "bold", fill: cor.primaria, numpag))
  }
  v(-0.3em)
  line(length: 100%, stroke: 0.4pt + cor.cinza-claro)
}

// Exemplar personalizado (materiais pagos): compile com --input licenciado="nome ou e-mail"
#let _licenciado = sys.inputs.at("licenciado", default: none)

#let _rodape = context {
  let pg = here().page()
  let abertos = query(heading.where(level: 1)).filter(h => h.location().page() == pg)
  if abertos.len() > 0 {
    align(center, text(font: semserifa, size: 8.6pt, fill: cor.cinza, counter(page).display(fmt-pagina())))
  }
  if _licenciado != none {
    align(center, text(font: semserifa, size: 6.4pt, fill: cor.cinza)[Exemplar licenciado para #_licenciado])
  }
}

// ---------------------------------------------------------------------
//  Sumário próprio (partes, capítulos, seções)
// ---------------------------------------------------------------------
#let sumario(profundidade: 2) = context {
  let sel = selector(<marca-parte>).or(heading.where(level: 1)).or(heading.where(level: 2))
  let itens = query(sel).filter(it => it.func() == metadata or it.outlined)
  set par(first-line-indent: 0pt, justify: false)
  let pontilhado = box(width: 1fr, repeat(text(fill: cor.cinza-claro)[.#h(4pt)]))
  for it in itens {
    let loc = it.location()
    let pag = counter(page).at(loc).first()
    let mat = materia.at(loc)
    let pag-fmt = if mat == "pre" { numbering("i", pag) } else { str(pag) }
    if it.func() == metadata {
      v(0.9em)
      block(below: 0.5em, link(loc, text(font: semserifa, weight: "bold", size: 11pt, fill: cor.primaria)[
        Parte #numbering("I", it.value.numero)#h(0.6em)#it.value.titulo
      ]))
    } else if it.level == 1 {
      let rot = if it.numbering != none {
        let c = counter(heading).at(loc).first()
        if mat == "apendice" { numbering("A", c) } else { str(c) }
      } else { none }
      block(above: 0.75em, below: 0.35em, link(loc, text(font: semserifa, weight: "bold", size: 10pt, fill: black)[
        #box(width: 2.2em, rot)#it.body #pontilhado #pag-fmt
      ]))
    } else if profundidade >= 2 and it.numbering != none {
      let hs = counter(heading).at(loc)
      let cs = if mat == "apendice" { numbering("A", hs.at(0)) } else { str(hs.at(0)) }
      block(above: 0.25em, below: 0.25em, link(loc, text(size: 9.4pt, fill: black)[
        #h(2.2em)#box(width: 2.6em, [#cs.#hs.at(1)])#it.body #pontilhado #pag-fmt
      ]))
    }
  }
}

// ---------------------------------------------------------------------
//  Regra principal do documento
// ---------------------------------------------------------------------
#let livro(titulo: "", subtitulo: "", autor: "", ano: "", corpo) = {
  set document(title: titulo, author: autor)
  set page(
    paper: "iso-b5",
    margin: (inside: 2.1cm, outside: 2.3cm, top: 2.5cm, bottom: 2.4cm),
    header: _cabecalho,
    footer: _rodape,
    header-ascent: 35%,
  )
  set text(font: serifa, size: 10.4pt, lang: "pt", region: "br", hyphenate: true, number-type: "lining")
  set par(justify: true, leading: 0.64em, first-line-indent: 1.1em, spacing: 0.64em)
  set heading(numbering: "1.1")
  show heading: set text(font: semserifa, fill: cor.primaria)

  // Matemática
  show math.equation: set text(font: "Libertinus Math")
  // Equações de bloco não são numeradas por padrão; use #eqn(...) <rotulo>
  set math.equation(numbering: none, supplement: [Equação])

  // Código
  show raw: set text(font: mono, size: 0.84em)
  show raw.where(block: true): it => block(
    width: 100%,
    fill: rgb("#f6f6f4"),
    inset: (x: 8pt, y: 7pt),
    radius: 2pt,
    stroke: 0.4pt + cor.cinza-claro,
    it,
  )

  // Listas
  set list(indent: 0.6em, body-indent: 0.5em, marker: ([•], [–], [·]))
  set enum(indent: 0.6em, body-indent: 0.5em)

  // Links e referências
  show link: set text(fill: cor.secundaria)
  show ref: set text(fill: cor.secundaria)
  show cite: set text(fill: cor.secundaria)
  // Referências a capítulos/seções: "Capítulo 3", "Seção 3.2", "Apêndice A"
  show ref: it => {
    let el = it.element
    if el != none and el.func() == heading and el.numbering != none {
      let loc = el.location()
      let hs = counter(heading).at(loc)
      let ap = materia.at(loc) == "apendice"
      let c = if ap { numbering("A", hs.at(0)) } else { str(hs.at(0)) }
      let txt = if el.level == 1 {
        (if ap { "Apêndice " } else { "Capítulo " }) + c
      } else {
        "Seção " + c + "." + str(hs.at(1))
      }
      link(loc, text(fill: cor.secundaria, txt))
    } else { it }
  }

  // Notas de rodapé
  set footnote.entry(separator: line(length: 30%, stroke: 0.4pt + cor.cinza-claro), gap: 0.5em, indent: 0.6em)
  show footnote.entry: set text(size: 8.4pt)

  // Figuras
  set figure(numbering: num-por-cap, gap: 0.8em)
  set figure.caption(separator: [. ])
  show figure.caption: it => {
    set align(left)
    set text(size: 9pt)
    set par(justify: true, first-line-indent: 0pt)
    let sup = it.supplement
    [#text(font: semserifa, weight: "bold", fill: cor.primaria)[#sup #context it.counter.display(it.numbering)]#it.separator#it.body]
  }
  show figure.where(kind: image): set block(above: 1.5em, below: 1.5em)
  show figure.where(kind: table): set block(above: 1.5em, below: 1.5em, breakable: true)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(supplement: [Tabela])
  show figure.where(kind: image): set figure(supplement: [Figura])
  show figure.where(kind: "formal"): set block(breakable: true)
  show figure.where(kind: "formal"): _mostra-formal
  show figure.where(kind: "caso"): set block(breakable: true)
  show figure.where(kind: "caso"): _mostra-caso
  show figure.where(kind: "algoritmo"): set block(breakable: false)
  show figure.where(kind: "algoritmo"): it => {
    set align(left)
    block(above: 1.3em, below: 1.2em, breakable: false, {
      block(sticky: true, below: 0.35em, {
        set par(justify: false, first-line-indent: 0pt)
        text(size: 8.8pt)[#text(font: semserifa, weight: "bold", fill: cor.primaria)[Algoritmo #it.counter.display(it.numbering)]#if it.caption != none [. #it.caption.body]]
      })
      it.body
    })
  }

  // Capítulos (nível 1)
  show heading.where(level: 1): it => {
    // reinicia contadores por capítulo
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "formal")).update(0)
    counter(figure.where(kind: "caso")).update(0)
    counter(figure.where(kind: "algoritmo")).update(0)
    counter(math.equation).update(0)
    [#metadata("fim")<fim-bloco>]
    pagebreak(to: "odd", weak: true)
    set par(first-line-indent: 0pt, justify: false)
    v(2.2cm)
    if it.numbering != none {
      context {
        let c = counter(heading).get().first()
        let ap = materia.get() == "apendice"
        let rot = if ap { "APÊNDICE" } else { "CAPÍTULO" }
        let num = if ap { numbering("A", c) } else { str(c) }
        align(right, {
          text(font: semserifa, size: 11pt, fill: cor.secundaria, tracking: 0.25em, rot)
          linebreak()
          v(-0.25cm)
          text(font: serifa, size: 64pt, fill: cor.primaria, num)
        })
      }
      v(0.1cm)
    }
    line(length: 100%, stroke: 1.2pt + cor.primaria)
    v(0.25cm)
    block(below: 1.6cm, text(font: semserifa, size: 22pt, weight: "bold", fill: cor.primaria, hyphenate: false, it.body))
  }

  // Seções (nível 2)
  show heading.where(level: 2): it => {
    set par(first-line-indent: 0pt, justify: false)
    block(above: 2em, below: 1em, sticky: true, {
      set text(size: 13pt, weight: "bold", hyphenate: false)
      if it.numbering != none {
        context {
          let hs = counter(heading).get()
          let cs = if materia.get() == "apendice" { numbering("A", hs.at(0)) } else { str(hs.at(0)) }
          box(width: 2.6em, text(fill: cor.secundaria)[#cs.#hs.at(1)])
        }
      }
      it.body
    })
  }

  // Subseções (nível 3, sem número, como no CLRS)
  set heading(numbering: (..n) => if n.pos().len() <= 2 { numbering("1.1", ..n) })
  show heading.where(level: 3): it => block(above: 1.5em, below: 0.7em, sticky: true,
    text(size: 10.8pt, weight: "bold", fill: cor.primaria, hyphenate: false, it.body))
  show heading.where(level: 4): it => block(above: 1.2em, below: 0.6em, sticky: true,
    text(size: 10.4pt, weight: "bold", style: "italic", fill: cor.teo, it.body))

  // Termos em destaque na primeira ocorrência
  show strong: set text(weight: "semibold")

  corpo
}

// Termo definido: negrito-itálico + entrada no índice
#let termo(t, ix-como: none) = {
  ix(if ix-como == none { t } else { ix-como })
  text(weight: "semibold", style: "italic", fill: cor.primaria, t)
}

// Epígrafe de abertura de capítulo
#let epigrafe(texto, fonte: none) = align(right, block(width: 72%, {
  set par(justify: false, first-line-indent: 0pt)
  set text(size: 9.4pt, style: "italic")
  texto
  if fonte != none {
    v(0.2em)
    text(style: "normal", size: 8.8pt, fill: cor.cinza)[— #fonte]
  }
  v(0.8cm)
}))

// Citação narrativa: #ct(<chave>) -> "Autor (ano)"
#let ct(chave, ..args) = cite(chave, form: "prose", ..args)

// Estatuto epistêmico em versalete (funciona também dentro de fórmulas)
#let est(s) = box(text(font: serifa, smallcaps(s)))

// Estado operacional ou valor de um vocabulário fechado que NÃO é estatuto
// epistêmico (estados de entrega, de verificação, operações de portão, classes
// de afetação…): itálico sem serifa, para não se confundir com #est.
#let estado(s) = box(text(font: semserifa, style: "italic", size: 0.94em, s))
