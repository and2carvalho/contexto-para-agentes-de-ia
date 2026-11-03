// Contexto para Agentes de IA — arquivo-mestre
// Compilar (a partir desta pasta):
//   typst compile --root . --font-path fontes livro.typ contexto-para-agentes.pdf
// ou execute ./build.sh

#import "/modelo/estilo.typ": *
#import "/modelo/capa.typ": *

// ---- Dados da obra (edite aqui) ----------------------------------------
#let titulo = "Contexto para Agentes de IA"
#let subtitulo = "Gerenciamento, Engenharia, Design e Administração — Fundamentos, Algoritmos e Sistemas"
#let autor = "André Antero de Carvalho"
#let autor-abnt = "ANTERO DE CARVALHO, André"
#let edicao = "Primeira edição"
#let ano = "2026"
#let versao = "1.0 (outubro de 2026)"
// Preencha depois de publicar (deixe "" enquanto não existir):
#let doi = "10.5281/zenodo.23933493"     // por exemplo, "10.5281/zenodo.1234567"
#let isbn = ""
// -------------------------------------------------------------------------

#show: livro.with(titulo: titulo, subtitulo: subtitulo, autor: autor, ano: ano)

// ===== Elementos pré-textuais =====
#capa(titulo: titulo, subtitulo: subtitulo, autor: autor, edicao: edicao)
#materia.update("pre")
#counter(page).update(1)

#folha-de-rosto(titulo: titulo, subtitulo: subtitulo, autor: autor, edicao: edicao, ano: ano)

#creditos[
  *#titulo* \
  #subtitulo \
  #edicao, #ano.

  Versão #versao.
  #if doi != "" [DOI: #link("https://doi.org/" + doi)[#doi]. ]
  #if isbn != "" [ISBN: #isbn.]

  © #ano #autor.

  Esta obra está licenciada sob a licença Creative Commons Atribuição-NãoComercial-SemDerivações 4.0 Internacional (CC BY-NC-ND 4.0). Você pode copiar e redistribuir o material em qualquer meio ou formato, desde que (i) atribua o devido crédito ao autor, (ii) não o use para fins comerciais e (iii) não distribua versões modificadas. Texto da licença: #link("https://creativecommons.org/licenses/by-nc-nd/4.0/deed.pt-br")[creativecommons.org/licenses/by-nc-nd/4.0]. Usos não cobertos pela licença — edições comerciais, traduções, adaptações, cursos e materiais derivados — dependem de autorização do autor.

  *Como citar:* #autor-abnt. #emph(titulo): #lower(subtitulo). 1. ed. \[#emph[S. l.]\]: Edição do autor, #ano. #if doi != "" [DOI: #doi.]

  Composto em Libertinus Serif, Libertinus Sans e JetBrains Mono com o sistema de tipografia Typst.

  Os estudos de caso deste livro foram anonimizados e generalizados; não se referem a nenhum produto, organização ou pessoa específicos. Nomes de produtos e marcas eventualmente citados nas referências pertencem a seus respectivos titulares.
]

#include "preliminares/prefacio.typ"

#heading(numbering: none, outlined: false)[Sumário]
#sumario()

// ===== Elementos textuais =====
#[#metadata("fim")<fim-bloco>]
#pagebreak(to: "odd", weak: true)
#materia.update("texto")
#counter(page).update(1)
#counter(heading).update(0)

#parte("Fundamentos")[
  A primeira parte apresenta o problema do contexto, descreve os modelos de linguagem como processadores de contexto, constrói o modelo formal que serve de espinha ao livro — acervo, coordenada, projeção, perspectiva e renderização — e estabelece seus fundamentos epistemológicos: a distinção entre prova, memória e conhecimento, e os estatutos que uma asserção pode ter.
]
#include "capitulos/cap01-introducao.typ"
#include "capitulos/cap02-llm.typ"
#include "capitulos/cap03-modelo.typ"
#include "capitulos/cap04-epistemologia.typ"

#parte("Gerenciamento de contexto")[
  O gerenciamento de contexto cuida do acervo: do que é verdade, de onde veio, se ainda vale e quem responde por ela. Esta parte trata da identidade dos recursos e de seus nomes, dos domínios soberanos e de suas composições, da localização do consumidor, do tempo e da atualidade, da proveniência e da evidência, da durabilidade e da memória.
]
#include "capitulos/cap-identidade.typ"
#include "capitulos/cap-espacos.typ"
#include "capitulos/cap-localizacao.typ"
#include "capitulos/cap-tempo.typ"
#include "capitulos/cap-proveniencia.typ"
#include "capitulos/cap-durabilidade.typ"
#include "capitulos/cap-memoria.typ"

#parte("Engenharia de contexto")[
  A engenharia de contexto cuida da projeção: do menor conjunto verdadeiro suficiente para uma coordenada. Esta parte trata da seleção sob orçamento e de sua complexidade, do conjunto de trabalho e das hierarquias de contexto, do núcleo de projeção como cálculo de ponto fixo, da fronteira e da expansão dirigida, da compressão por coordenadas e da compactação de contextos que crescem.
]
#include "capitulos/cap-selecao.typ"
#include "capitulos/cap-working-set.typ"
#include "capitulos/cap-perspectiva.typ"
#include "capitulos/cap-fronteira.typ"
#include "capitulos/cap-compressao.typ"
#include "capitulos/cap-compactacao.typ"

#parte("Design de contexto")[
  O design de contexto cuida da apresentação: de como uma perspectiva deve ser mostrada para ser usada corretamente. Esta parte trata de objetivos, requisitos, relevância e divulgação; da renderização honesta e das affordances; e da entrada de contexto, isto é, de como um consumidor é inicializado e orientado.
]
#include "capitulos/cap-relevancia.typ"
#include "capitulos/cap-apresentacao.typ"
#include "capitulos/cap-entrada.typ"

#parte("Administração de contexto")[
  A administração de contexto cuida da mudança: de como o sistema evolui sem perder a verdade e de quem autoriza cada mudança. Esta parte trata de autoridade, capacidades e soberania; de portões e prontidão; do ciclo de vida da ação governada; das unidades de trabalho; da reconciliação entre o desejado e o observado; e da higiene que impede o acúmulo de dívida de contexto.
]
#include "capitulos/cap-autoridade.typ"
#include "capitulos/cap-portoes.typ"
#include "capitulos/cap-ciclo-acao.typ"
#include "capitulos/cap-trabalho.typ"
#include "capitulos/cap-reconciliacao.typ"
#include "capitulos/cap-higiene.typ"

#parte("Ambientes, execução, federação e segurança")[
  Esta parte leva a teoria aos sistemas reais: ao ambiente de contexto e à configuração; à execução, aos artefatos e à convergência; à federação entre domínios soberanos e à autoridade distribuída; e à segurança, isto é, ao contexto visto do ponto de vista de um adversário.
]
#include "capitulos/cap-ambiente.typ"
#include "capitulos/cap-runtime.typ"
#include "capitulos/cap-federacao.typ"
#include "capitulos/cap-seguranca.typ"

#parte("Sistemas de agentes")[
  Quando vários agentes cooperam, o contexto precisa atravessar fronteiras entre eles. Esta parte trata da orquestração de agentes, das transferências de trabalho e dos relatos de resultado, da arquitetura de sistemas de contexto e da observabilidade que permite saber o que cada agente estava vendo.
]
#include "capitulos/cap-orquestracao.typ"
#include "capitulos/cap-handoff.typ"
#include "capitulos/cap-arquitetura.typ"
#include "capitulos/cap-observabilidade.typ"

#parte("Avaliação e método")[
  A última parte trata de como saber se um sistema de contexto funciona — avaliação empírica com consumidores estocásticos e verificação de sistemas —, do método pelo qual a teoria foi construída e pode ser estendida, e dos problemas que permanecem em aberto.
]
#include "capitulos/cap-avaliacao.typ"
#include "capitulos/cap-metodo.typ"
#include "capitulos/cap-abertos.typ"

// ===== Apêndices =====
#materia.update("apendice")
#counter(heading).update(0)
#include "apendices/apA-matematica.typ"
#include "apendices/apB-logica.typ"
#include "apendices/apC-informacao.typ"
#include "apendices/apD-distribuidos.typ"
#include "apendices/apE-invariantes.typ"
#include "apendices/apF-procedimentos.typ"
#include "apendices/apG-modelos.typ"
#include "apendices/apH-glossario.typ"

// ===== Elementos pós-textuais =====
#materia.update("pos")
#bibliography("referencias.yml", style: "modelo/apa-livro.csl", title: "Referências")

#heading(numbering: none)[Índice remissivo]
#indice-remissivo()

// ===== Apoio à pesquisa aberta =====
#pagebreak(to: "odd")
#v(1fr)
#align(center)[
  #text(font: semserifa, size: 13pt, weight: "bold", fill: cor.primaria)[Apoie a Pesquisa Aberta e Independente] \
  #v(0.5cm)
  #block(width: 84%)[
    #set par(justify: true, first-line-indent: 0pt, leading: 0.65em)
    #text(font: serifa, size: 10pt, fill: cor.teo)[
      Este livro-texto é distribuído gratuitamente sob a licença aberta Creative Commons Atribuição-NãoComercial-SemDerivações 4.0 Internacional (CC BY-NC-ND 4.0), com o compromisso de disseminar fundamentos rigorosos de arquitetura e engenharia de contexto para agentes de inteligência artificial.

      Se esta obra agregou valor ao seu aprendizado, pesquisa ou trabalho profissional e você deseja incentivar a continuidade deste projeto e de novas publicações abertas, considere fazer uma contribuição voluntária ao autor:
    ]
    #v(0.7cm)
    #text(font: semserifa, size: 11pt, weight: "bold", fill: cor.primaria)[
      #link("https://ko-fi.com/and2carvalho")[ko-fi.com/and2carvalho]
    ]
  ]
]
#v(1fr)
