#import "/modelo/estilo.typ": *

= O método empírico da engenharia de contexto <cap-metodo>

#epigrafe[Nenhuma fundação sem consumidor.]

Uma ciência nova precisa de um método. A engenharia de contexto lida com consumidores estocásticos, com sistemas que mudam enquanto são observados e com conceitos que só se revelam quando são usados. Neste cenário, duas tentações opostas são comuns: projetar uma teoria completa antes de qualquer uso, e acumular práticas sem nunca formalizá-las. Este capítulo descreve o método pelo qual a teoria deste livro foi construída — e que recomendamos para quem pretende estendê-la: começar pelo consumidor, medir antes de arquitetar, deixar a semântica emergir do uso e só então formalizar, mantendo uma fronteira explícita entre o que foi explorado e o que foi estabelecido.

A @sec-met-consumidor apresenta o princípio do consumidor primeiro. A @sec-met-pipeline descreve o caminho da intuição à semântica. A @sec-met-reflexivo discute o uso reflexivo como método e seus vieses. A @sec-met-promocao trata da fronteira de promoção do conhecimento. A @sec-met-disposicao apresenta a matriz de disposição de afirmações. A @sec-met-experimentos trata de experimentos de reconstituição e da verificação prévia. A @sec-met-disciplina trata da disciplina científica diante de hipóteses sedutoras.

== O consumidor primeiro <sec-met-consumidor>

#principio(titulo: [Nenhuma fundação sem consumidor])[
  Um mecanismo genérico só se justifica quando há um consumidor que dele precisa. O _sinal completo_ de uma funcionalidade é: um produtor que a gera, um dono semântico que a calcula, um consumidor que a usa e uma proveniência que permite verificar o resultado. Faltando qualquer um, o mecanismo é especulação.
] <pri-consumidor>

#principio(titulo: [Medir antes de arquitetar])[
  Uma lacuna arquitetural percebida é uma hipótese até ser medida no uso real. Marcar uma lacuna como confirmada antes de o sistema correto ter sido usado para a tarefa em questão transforma hipótese em dogma.
] <pri-medir>

#estudo-de-caso(titulo: [Lacunas confirmadas cedo demais])[
  Uma análise de arquitetura listou várias lacunas e as marcou como "confirmadas". Quando o sistema foi efetivamente usado nas tarefas correspondentes — com a versão correta e na configuração correta —, metade das lacunas não se manifestou, e duas lacunas não previstas apareceram. As marcadas foram reclassificadas como "lacunas candidatas", e o portão de aceitação passou a exigir uso real antes de confirmar uma lacuna.
] <caso-lacunas-cedo>

#principio(titulo: [O mecanismo não dirige o produto])[
  "A ferramenta de inicialização deixa tudo verde se tratarmos isto como um domínio; então tratemos isto como um domínio" é deixar a conveniência do mecanismo decidir a semântica. A pergunta correta é: o que faz $X$ merecer ser $Y$?
] <pri-mecanismo>

#exercicios[
  + Para um mecanismo de um sistema que você conhece, verifique os quatro elementos do sinal completo. Qual falta?
  + Dê um exemplo em que uma decisão semântica foi tomada pela conveniência de uma ferramenta. Qual foi a consequência?
  + Escolha uma funcionalidade "genérica" de um sistema que você conhece e verifique se ela tem o sinal completo (produtor, dono, consumidor, proveniência). O que aconteceria se ela fosse removida?
]

== Da intuição à semântica <sec-met-pipeline>

#figure(
  diagram(
    spacing: (6mm, 6mm),
    node-stroke: 0.5pt + cor.primaria, node-fill: cor.tinta-def, node-corner-radius: 2pt,
    node((0, 0), text(size: 8pt)[intuição]),
    node((1, 0), text(size: 8pt)[hipótese]),
    node((2, 0), text(size: 8pt)[medição\ (arqueológica\ e corrente)]),
    node((3, 0), text(size: 8pt)[uso\ reflexivo]),
    node((4, 0), text(size: 8pt)[semântica]),
    node((5, 0), text(size: 8pt)[formalização]),
    edge((0, 0), (1, 0), "-|>"), edge((1, 0), (2, 0), "-|>"), edge((2, 0), (3, 0), "-|>"),
    edge((3, 0), (4, 0), "-|>"), edge((4, 0), (5, 0), "-|>"),
    edge((3, 0), (1, 0), "-|>", bend: -40deg, label: text(size: 7.5pt)[refutação], label-side: right),
  ),
  caption: [O caminho metodológico. A formalização vem por último; a refutação no uso devolve o trabalho à hipótese.],
) <fig-pipeline>

A ordem importa. Formalizar cedo demais congela distinções que o uso ainda não revelou; formalizar tarde demais deixa práticas sem fundamento, que se degradam em folclore. A sequência recomendada, dentro de cada ciclo, é: _preservar_ o material existente (sem reorganizá-lo prematuramente); _observar_ a estrutura que emerge naturalmente do uso; _projetar_ a partir dessa estrutura; _descobrir_ a semântica reutilizável; e só então _formalizar_.

#estudo-de-caso(titulo: [Três fatias que viraram dezenas de arestas])[
  Um plano de trabalho previa três fatias: implementar a descoberta de domínios, a projeção e a renderização. O uso reflexivo da primeira fatia a decompôs em dezenas de arestas não previstas: diretório corrente não é coordenada; repositório não é domínio; diretório não é agrupamento; a descoberta precisa distinguir domínio de composição; e assim por diante. O plano original não estava errado — estava incompleto de um modo que só o uso poderia revelar.
] <caso-tres-fatias>

#exercicios[
  + Reconstrua a trajetória de uma decisão de projeto de que você participou segundo a @fig-pipeline. Em que etapa ela entrou?
  + Por que "preservar antes de reorganizar" é uma regra metodológica e não apenas prudência?
  + Dê um exemplo de formalização prematura — uma distinção fixada antes de o uso a revelar — e do custo de desfazê-la.
]

== Uso reflexivo como método <sec-met-reflexivo>

#definicao(titulo: [Uso reflexivo])[
  _Uso reflexivo_ (do inglês _dogfooding_) é o uso do próprio sistema de contexto para conduzir o trabalho de construí-lo — orientar sessões, transferir trabalho, registrar decisões —, tratando as falhas encontradas como evidência sobre a teoria.
] <def-uso-reflexivo>

O uso reflexivo tem uma vantagem epistêmica forte: os construtores sentem diretamente as falhas, com custo real, em tarefas reais. Tem também vieses conhecidos:

/ Consumidor treinado: os construtores conhecem o sistema e contornam suas falhas sem perceber; um consumidor novo não contornaria.

/ Circularidade: o sistema é avaliado pelos critérios que ele mesmo incorpora; falhas fora desses critérios não são vistas.

/ Domínio único: o trabalho de construir um sistema de contexto é um domínio específico; o que funciona nele pode não generalizar.

#principio(titulo: [Uso reflexivo exige consumidores externos])[
  A evidência do uso reflexivo é complementada por consumidores frios (@def-consumidor-frio), por consumidores de outros domínios (@ex-genericidade) e por protocolos com falsificação bem-sucedida (@pri-experimento-falhar). O uso reflexivo descobre; os testes externos confirmam.
] <pri-reflexivo-externo>

Essa combinação tem paralelos na tradição de estudos de prática: o "profissional reflexivo" de #ct(<schon1983>), que aprende refletindo durante e sobre a ação, e os estudos de cognição situada e distribuída @suchman1987 @hutchins1995, que mostraram que a inteligência de um sistema de trabalho está tanto nos artefatos e nas práticas quanto nos indivíduos.

#exercicios[
  + Para cada viés do uso reflexivo, proponha uma salvaguarda concreta.
  + Por que o uso reflexivo é particularmente valioso para sistemas de contexto, comparado com outros tipos de software?
  + Proponha um protocolo para registrar falhas encontradas durante o uso reflexivo, de modo que elas possam depois ser testadas com consumidores externos.
]

== A fronteira de promoção do conhecimento <sec-met-promocao>

Um projeto de pesquisa produz conhecimento em vários lugares: cadernos de notas, conversas com colaboradores e com modelos, transferências entre sessões, registros governados, documentação derivada. Esses lugares têm estatutos diferentes.

#definicao(titulo: [Camadas de conhecimento de um projeto])[
  - _Exploração livre_: notas, hipóteses, conversas, rascunhos;
  - _Transporte_: transferências entre sessões e consumidores;
  - _Registro governado_: decisões, evidências, ciclos de vida, fatos aceitos;
  - _Continuidade derivada_: projeções e resumos calculados a partir do registro.
] <def-camadas-conhecimento>

#invariante(titulo: [As camadas não se promovem sozinhas])[
  Caderno de notas não é governança; conversa não é evidência; transferência não é autoridade; resumo não é verdade. Mas uma conversa pode conter uma decisão do titular, um relato pode conter uma medição, uma nota pode conter uma ideia valiosa. A passagem de uma camada à outra é uma _promoção_ explícita, com dono e destino definidos.
] <inv-promocao>

#figure(
  tabela(
    colunas: (1fr, 1.3fr, 1.4fr),
    cabecalho: ([Tipo de conteúdo], [Destino], [Observação]),
    [escolha do titular], [decisão], [com data, escopo e alternativas consideradas],
    [fato medido], [evidência], [com âncora, método e coordenada],
    [implementação], [registro de trabalho com referência de recuperação], [ligada a revisão ou artefato identificado por conteúdo],
    [fechamento de trabalho], [semente de continuação], [@def-semente-continuacao],
    [trajetória em andamento], [transferência ligada a referências canônicas], [@cap-handoff],
    [orientação corrente], [projeção derivada], [recalculável, nunca autoridade],
    [ideia], [registro de pesquisa], [sem projeção automática para o trabalho corrente],
    [desconhecido], [junto à afirmação a que se refere], [nunca numa lista separada esquecida],
  ),
  caption: [Fronteira de promoção: cada tipo de conteúdo tem um destino canônico.],
) <tab-promocao>

#principio(titulo: [Teste de continuidade fria do projeto])[
  Um projeto bem promovido sobrevive à perda de todas as conversas. O teste: descartar o histórico de conversas, iniciar uma sessão nova apenas com a entrada de contexto, a semente corrente, o registro governado, as evidências e as referências — e verificar se um orientador frio responde: por que chegamos aqui? Que invariante sustenta esta decisão? Que código produziu cada resultado? O que é verificável? O que é desconhecido? Qual é a próxima fronteira, e ela foi escolhida pelo titular?
] <pri-continuidade-projeto>

#exercicios[
  + Aplique a @tab-promocao a uma conversa longa de trabalho: liste o que deveria ser promovido e para onde.
  + Execute mentalmente o teste de continuidade fria para um projeto seu. Quais perguntas não teriam resposta?
  + Classifique, na @tab-promocao, dez trechos de uma conversa de trabalho com um assistente (decisões, medições, ideias, dúvidas), indicando o destino de cada um.
]

== A matriz de disposição de afirmações <sec-met-disposicao>

Ao fim de um trabalho, cada afirmação que ele produziu precisa ter destino. A _matriz de disposição_ torna esse fechamento explícito.

#definicao(titulo: [Matriz de disposição])[
  A _matriz de disposição_ de um trabalho tem uma linha por afirmação produzida e colunas: perspectiva afetada; autoridade; atualidade; aplicabilidade; referências; efeito sobre ciclos de vida; planos alterados; _planos explicitamente inalterados_; desconhecidos; efeito na fronteira de trabalho.
] <def-matriz-disposicao>

A coluna mais importante é a menos óbvia: _planos explicitamente inalterados_. Quando um trabalho termina, é tentador registrar apenas o que mudou. Mas, para o próximo consumidor, saber que o trabalho _considerou_ um plano e decidiu não alterá-lo é informação distinta de não saber se o plano foi considerado. É a mesma distinção entre omissão declarada e silêncio (P5), aplicada ao fechamento de trabalho.

Um fechamento bem feito também evita um erro recorrente de orientação: recomendar como próximo passo uma pendência que continua formalmente "aberta" no registro, mas cujo estado vigente — derivado da junção com aceitação, critérios de concluído, evidência e linha de base (@def-estado-efetivo) — é "satisfeita". O estado vigente é derivado, não obtido por mutação do registro histórico.

#exercicios[
  + Preencha a matriz de disposição para um trabalho de correção de falha, incluindo pelo menos dois planos explicitamente inalterados.
  + Dê um exemplo de pendência formalmente aberta e efetivamente satisfeita. Como derivar o estado vigente?
  + Explique por que a coluna "planos explicitamente inalterados" é uma aplicação do axioma da omissão declarada (P5) ao fechamento de trabalho.
]

== Experimentos de reconstituição e verificação prévia <sec-met-experimentos>

Dois tipos de experimento revelam o que a teoria ainda não capturou.

/ Reconstituição: começa-se de um ambiente limpo e descartável, retendo apenas as coordenadas declaradas como duráveis, e reconstrói-se o trabalho (@def-reconstituicao). A pergunta de saída — "do que precisamos que não estava duravelmente declarado?" — revela conceitos ausentes: um perfil de ambiente, um módulo de funcionalidade, um agrupamento.

/ Verificação prévia do caminho vivo: antes de escrever código para uma funcionalidade, responde-se: que afirmação ela sustenta? Quem é o dono da semântica? Como ela é invocada no produto real? Como observamos a consequência? Como a aceitação vai prová-la? Não é mais governança; é menos suposição entre camadas.

#principio(titulo: [O observador também tem atualidade])[
  O instrumento de medição é uma variável epistêmica. Um verificador desatualizado pode classificar um alvo saudável como desconhecido, ou um alvo degradado como saudável. A funcionalidade do observador não é a funcionalidade observada; a atualidade do observador não é a atualidade do alvo.
] <pri-observador-atualidade>

#exercicios[
  + Planeje um experimento de reconstituição para um ambiente de desenvolvimento seu. Que pergunta de saída você espera que revele lacunas?
  + Aplique as cinco perguntas da verificação prévia a uma funcionalidade que você pretende implementar.
  + Aplique o @pri-observador-atualidade a um verificador de saúde que foi atualizado depois do sistema que verifica. Que tipo de erro ele pode cometer, e como detectá-lo?
]

== Disciplina científica <sec-met-disciplina>

A pesquisa em uma área nova produz muitas hipóteses sedutoras — analogias amplas, padrões que parecem se repetir, abstrações unificadoras. A disciplina consiste em mantê-las como hipóteses até que tenham um objeto matemático definido e um experimento capaz de refutá-las @popper1959 @lakatos1978.

#principio(titulo: [Hipóteses não são canonizadas])[
  Uma abstração candidata — "todos os participantes (humanos, agentes, aplicações, processos) são instâncias de um mesmo tipo"; "todas as funcionalidades são módulos que requerem e fornecem" — permanece registrada como hipótese até que a pressão do uso a revele necessária. Canonizar uma abstração antes disso cria um tipo sem consumidor, que precisará ser desfeito.
] <pri-hipoteses>

#estudo-de-caso(titulo: [A hipótese da ressonância])[
  Durante a concepção da teoria, observou-se que certos princípios — "omissão não é negação", "memória não é prova", "projeção não é autoridade" — reapareciam, de forma independente, depois de mudanças radicais de arquitetura. A tentação era tratar essa "ressonância" como evidência de que esses princípios eram leis do domínio. A disciplina adotada foi registrá-la como hipótese e exigir, antes de qualquer conclusão, um objeto definido (o que conta como "reaparecimento independente"?) e um teste que a pudesse refutar (que princípios se esperaria ver reaparecer, e quais não, se a hipótese fosse falsa?). Sem isso, ela permanece uma observação interessante, registrada como tal — e por isso aparece neste livro como problema em aberto (@cap-abertos), não como teorema.
] <caso-ressonancia>

#exercicios[
  + Formule a hipótese da ressonância de forma refutável.
  + Escolha uma abstração "unificadora" popular em sistemas de agentes e avalie se ela tem consumidor e teste de refutação.
  + Escolha uma afirmação ampla sobre agentes (por exemplo, "mais contexto sempre ajuda") e reescreva-a como hipótese com objeto definido e experimento capaz de refutá-la.
]

#quadro[
  - Nenhuma fundação sem consumidor: produtor, dono semântico, consumidor e proveniência.
  - Meça antes de arquitetar; o mecanismo não dirige o produto.
  - Intuição, hipótese, medição, uso reflexivo, semântica, formalização — nessa ordem.
  - Uso reflexivo descobre; consumidores externos e falsificação confirmam.
  - Notas, conversas, transferências e resumos não se promovem sozinhos; cada conteúdo tem um destino canônico.
  - A matriz de disposição inclui planos explicitamente inalterados; estado vigente é derivado, não mutado.
  - Reconstituição e verificação prévia revelam o que falta; o observador também tem atualidade.
  - Hipóteses sedutoras ficam hipóteses até ter objeto e teste.
]

#problemas[
  #problema([Validade externa do uso reflexivo])[
    Proponha um desenho para estimar quanto da evidência obtida por uso reflexivo generaliza para outros domínios.
    + Defina as populações de tarefas e de consumidores.
    + Proponha como medir o efeito do "consumidor treinado".
    + Discuta o que um resultado negativo implicaria para a teoria.
  ]
  #problema([Promoção automática assistida])[
    Um sistema propõe automaticamente promoções de conteúdo de conversas para o registro governado.
    + Que tipos da @tab-promocao podem ser propostos com segurança, e quais exigem o titular?
    + Como evitar que propostas automáticas se tornem promoções silenciosas?
    + Relacione com o @anti-memoria-autoriza.
  ]
  #problema([Programas de pesquisa])[
    Na terminologia de #ct(<lakatos1978>), um programa de pesquisa tem um núcleo firme e um cinturão protetor de hipóteses auxiliares.
    + Identifique o que seria o núcleo firme da teoria deste livro.
    + Identifique hipóteses auxiliares que poderiam ser revistas sem abandonar o núcleo.
    + Proponha um resultado experimental que, se obtido, tornaria o programa "degenerativo".
  ]
]

#notas[
  O profissional reflexivo é de #ct(<schon1983>); a ação situada, de #ct(<suchman1987>); a cognição distribuída, de #ct(<hutchins1995>). A falsificabilidade é de #ct(<popper1959>), e a metodologia de programas de pesquisa, de #ct(<lakatos1978>). As leis de evolução de software de #ct(<lehman1980>) e a noção de dívida técnica @cunningham1992 @sculley2015 lembram que sistemas usados mudam, e que práticas não formalizadas acumulam custos.

  O método descrito neste capítulo combina tradições da pesquisa em ciência do projeto @hevner2004 e dos estudos de caso em engenharia de software @runeson2009 com a disciplina de não promover nada sem destino e de não canonizar nenhuma abstração sem consumidor.
]
