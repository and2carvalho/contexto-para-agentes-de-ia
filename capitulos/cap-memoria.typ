#import "/modelo/estilo.typ": *

= Memória, continuidade e trajetória <cap-memoria>

#epigrafe[Lembrar não é saber: saber exige poder mostrar de onde veio.]

O @teo-continuidade-externa estabeleceu que um modelo de linguagem não lembra de nada entre chamadas: toda continuidade é externa. Sessões terminam, janelas são compactadas, agentes são substituídos, equipes mudam. O que sobrevive a essas descontinuidades é o que foi escrito — e a qualidade do que foi escrito determina se o próximo consumidor retoma o trabalho em minutos ou reconstrói, por arqueologia, o que já se sabia.

Este capítulo trata da memória como _infraestrutura de continuidade_. A @sec-mem-continuidade apresenta o problema e os tipos de memória. A @sec-mem-duravel descreve registros duráveis: decisões, pendências e orientações. A @sec-mem-continuacao introduz a _registro de continuação_, um registro só-para-frente do estado de uma exploração. A @sec-mem-trajetoria desenvolve a trajetória — o grafo do "por quê". A @sec-mem-navegacao combina três eixos de navegação: espacial, de trajetória e de proveniência. A @sec-mem-orientacao trata do _quadro de orientação inicial_ que um consumidor frio recebe ao chegar.

== O problema da continuidade <sec-mem-continuidade>

A literatura sobre agentes de linguagem distingue, inspirada na psicologia cognitiva, vários tipos de memória @sumers2024 @zhang2024memory: a _memória de trabalho_ (o que está na janela), a _episódica_ (registros de experiências passadas), a _semântica_ (conhecimento sobre o mundo) e a _procedimental_ (como fazer as coisas). Sistemas como agentes generativos @park2023 mantêm um fluxo de observações e reflexões de que recuperam, a cada passo, as mais relevantes; propostas inspiradas em sistemas operacionais paginam a memória entre a janela e um armazenamento externo @packer2023.

Essa taxonomia é útil, mas deixa de fora a distinção que este livro considera central: entre o que se _lembra_ e o que se _prova_ (@cap-epistemologia). Uma memória episódica de que "os testes passaram" não é evidência de que passaram; uma memória semântica de que "o serviço $X$ depende de $Y$" não é uma relação provada. Por isso, reorganizamos a memória por _função_, não por analogia psicológica.

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Elemento], [Papel], [O que não é]),
    [Conhecimento], [substrato: conteúdo semanticamente útil que _pode_ entrar em contexto], [verdade, autoridade, evidência],
    [Unidade de empacotamento], [endereço: forma de agrupar e referenciar conhecimento], [memória, evidência, autoridade, atualidade, nota de qualidade],
    [Memória], [orientação durável: decisões, razões, história, pendências], [prova; pode estar desatualizada],
    [Evidência], [âncora: por que uma afirmação pode ser sustentada], [conhecimento derivado; renderização],
    [Coordenada], [endereço semântico do que importa agora], [narrativa],
    [Perspectiva], [lente: composição do que importa para esta coordenada], [autoridade; fonte de verdade],
    [Trajetória], [caminho: como e por que o estado atual emergiu], [memória; evidência; verdade durável],
  ),
  caption: [Elementos da continuidade e seus papéis. Misturar esses papéis num único objeto — conteúdo, verificação, pontuação e ciclo de vida no mesmo pacote — produz ambiguidade que nenhuma seleção posterior desfaz.],
) <tab-elementos-continuidade>

#invariante(titulo: [Relevância não é verdade])[
  Uma alta pontuação de relevância indica que um item _pode interessar_ à coordenada; não indica que ele é verdadeiro, aplicável, atual ou autorizado. Relevância é sinal de descoberta e ordenação; as demais propriedades exigem suas próprias bases.
] <inv-relevancia-verdade>

#antipadrao(titulo: [O pacote misto])[
  Um sistema agrupa conhecimento em pacotes que acumulam, num só objeto, conteúdo, metadados de verificação e uma pontuação agregada, e os seleciona por relevância para carregá-los no contexto. O consumidor recebe algo compacto e útil — mas não consegue distinguir, dentro de cada pacote, o que é prova, o que é memória e o que é opinião; e a seleção por relevância promove, implicitamente, o que é relevante a verdadeiro.
] <anti-modulo-misto>

O antipadrão merece ser estudado com respeito, porque arranjos desse tipo têm uma virtude real: tornam _barato_ orientar um consumidor frio. A @sec-mem-orientacao mostra como preservar essa virtude sem herdar a mistura.

#exercicios[
  + Classifique, segundo a @tab-elementos-continuidade, os itens de uma "memória de projeto" de um assistente que você conheça. Algum item desempenha vários papéis ao mesmo tempo?
  + Dê um exemplo em que um item muito relevante para uma pergunta é falso, e outro em que um item verdadeiro e aplicável tem baixa relevância lexical.
  + Separe, num "arquivo de memória" típico de um assistente de programação, os itens que são decisões, pendências, orientações, fatos observados e preferências. Que itens deveriam ter âncoras de prova?
]

== Registros duráveis: decisões, pendências e orientações <sec-mem-duravel>

Três tipos de registro carregam a maior parte da memória útil de um domínio.

#definicao(titulo: [Registro de decisão])[
  Um _registro de decisão_ contém: o _problema_ que motivou a decisão; as _alternativas_ consideradas; a _escolha_; a _razão_; a _autoridade_ que decidiu (quem, sob qual papel); as _evidências_ disponíveis no momento; as _condições de revisão_ (o que faria a decisão ser reaberta); e o instante. Decisões são imutáveis; uma decisão revista é suplantada por outra, que referencia a anterior.
] <def-registro-decisao>

A condição de revisão é o campo mais negligenciado e um dos mais valiosos: ela transforma a decisão de um fato estático num _contrato_ que diz quando a decisão deixa de valer, e permite a um consumidor futuro saber se a premissa ainda se sustenta.

#definicao(titulo: [Pendência])[
  Uma _pendência_ é o registro de uma possibilidade de trabalho futuro — uma ideia, uma hipótese, uma lacuna observada — sem compromisso de execução. Ela registra a observação que a originou, o contexto, e o critério que a tornaria prioritária. Uma pendência pode, por decisão de quem tem autoridade, dar origem a um ciclo de trabalho; até lá, não é trabalho aberto.
] <def-pendencia>

Pendências resolvem um problema prático de agentes e humanos: durante o trabalho, surgem dezenas de ideias laterais que não devem desviar o foco, mas que não podem simplesmente ser esquecidas. Registrá-las como pendências, e não como trabalho aberto, preserva a distinção entre _possibilidade_ e _compromisso_ — e evita que um consumidor futuro trate uma ideia de passagem como obrigação. (A palavra _semente_ fica reservada, neste livro, para a semente de continuação do @cap-compactacao: a menor projeção que permite a outro consumidor retomar um trabalho.)

#definicao(titulo: [Orientação durável])[
  Uma _orientação durável_ é um registro sobre _como operar_ num domínio — convenções, restrições, preferências do titular, armadilhas conhecidas — que deve informar o comportamento de todo consumidor que trabalhe ali. Orientações são memória procedimental com autoridade explícita: quem as estabeleceu e até quando valem.
] <def-orientacao>

#exercicios[
  + Escreva um registro de decisão completo para uma escolha técnica que você conheça, incluindo condições de revisão.
  + Por que pendências não devem ser registradas como itens de trabalho abertos? Descreva a falha que essa confusão produz quando um agente frio inventaria o trabalho a fazer.
  + Uma orientação diz "não altere o arquivo $F$ sem aprovação". Seis meses depois, $F$ foi removido do projeto. Que asserções devem ser registradas para que a orientação não continue confundindo consumidores?
]

== O registro de continuação <sec-mem-continuacao>

Explorações longas — pesquisa, desenho de produto, depuração difícil — têm um "estado" que não é capturado por nenhum registro isolado: qual era a fronteira anterior, que evidência mudou, por que a fronteira se moveu, qual é a próxima aresta justificável. Esse estado costuma viver na cabeça de quem conduz a exploração, e é o primeiro a se perder numa transferência.

#definicao(titulo: [Registro de continuação])[
  Um _registro de continuação_ é um registro só-para-frente (_forward-only_) que, a cada passo relevante de uma exploração, materializa: (i) a _fronteira anterior_; (ii) o _delta de evidência_ — o que foi entregue, provado, refutado ou encontrado ausente desde então, com âncoras; (iii) a _recomposição_ — como a fronteira mudou e por quê; (iv) a _fronteira corrente_; (v) a _próxima profundidade justificada_ e a necessidade real que a justifica; (vi) as _falhas_ observadas; e (vii) as _fronteiras preservadas_ — o que explicitamente não foi decidido ou criado.
] <def-projecao-continuacao>

#figure(
  block(width: 100%, inset: 8pt, stroke: 0.5pt + cor.cinza-claro, radius: 2pt, fill: rgb("#fafaf8"),
  align(left, text(size: 8.6pt, font: mono)[
    *FRONTEIRA ANTERIOR*\
    isolar por que o teste de integração T falha de forma intermitente\
    \
    *DELTA DE EVIDÊNCIA*\
    T executado isoladamente, 20 vezes ......... sempre passa (registro e1)\
    T executado após o teste U, 20 vezes ....... falha 6 vezes (registro e2)\
    hipótese "versão da dependência" ........... contradita (registro e3)\
    causa da falha ............................. desconhecida\
    \
    *RECOMPOSIÇÃO*\
    a falha depende de estado deixado por U; a hipótese de versão sai da fronteira\
    \
    *FRONTEIRA CORRENTE*\
    identificar o estado compartilhado entre T e U\
    \
    *PRÓXIMA PROFUNDIDADE JUSTIFICADA*\
    inspecionar os recursos temporários criados por U\
    necessidade: é a única diferença observável entre as duas condições\
    \
    *FALHAS OBSERVADAS*\
    um resumo anterior afirmou a causa sem evidência\
    "não reproduzido nesta máquina" foi lido como "não existe"\
    \
    *FRONTEIRAS PRESERVADAS*\
    nenhuma correção decidida; nenhuma unidade de trabalho nova aberta
  ])),
  caption: [Exemplo de registro de continuação numa depuração. Observe que as falhas são registradas junto com os sucessos, que o desconhecido permanece desconhecido, e que a próxima profundidade é justificada por uma necessidade concreta, não por um plano prévio.],
) <fig-projecao-continuacao>

Três propriedades distinguem o registro de continuação de um "roteiro" ou de um relatório de status.

/ Não é autoridade: ela registra o estado da exploração; não autoriza trabalho. A próxima profundidade "justificada" é uma proposta sustentada por evidência, a ser aprovada por quem tem autoridade.

/ É só-para-frente: projeções anteriores nunca são editadas. Se uma projeção contém um erro — por exemplo, atribui uma entrega à revisão errada —, a correção é uma _nova_ projeção, ligada à anterior, que registra o erro e o valor correto. Descobrir um erro não reescreve a história; a correção é uma nova observação ligada.

/ Registra falhas: uma transferência "aprovada" que, ainda assim, revelou generalizações indevidas por parte do consumidor deve registrar essas generalizações. Elas são os sentinelas dos próximos experimentos.

#invariante(titulo: [Erro descoberto não reescreve a história])[
  A descoberta de um erro num registro anterior gera um novo registro de correção, ligado ao original, que permanece como material histórico. Nenhum registro é editado retroativamente para "parecer certo".
] <inv-erro-historia>

#invariante(titulo: [Observado agora não é observado antes])[
  Uma expansão que registrou "não observado" continua verdadeira depois que uma observação posterior encontra o objeto. A nova observação é uma nova expansão, com seu próprio instante; ela não muta a anterior. Caso contrário, perde-se a informação de que, naquela perspectiva, o objeto não fora observado — e decisões tomadas a partir dela tornam-se inexplicáveis.
] <inv-observado-agora>

#exercicios[
  + Escreva um registro de continuação para uma tarefa de depuração que você realizou, seguindo os sete campos da @def-projecao-continuacao.
  + Por que o registro de continuação deve justificar a próxima profundidade com uma necessidade real de consumidor? Que risco ela evita?
  + Explique, com um exemplo, como a violação do @inv-observado-agora pode tornar inexplicável uma decisão passada.
]

== Trajetória <sec-mem-trajetoria>

O @cap-proveniencia distinguiu proveniência ("como chegamos aqui de forma verdadeira") de trajetória ("por que viemos"). Aqui damos à trajetória uma forma precisa.

#definicao(titulo: [Grafo de trajetória])[
  Um _grafo de trajetória_ é um grafo dirigido cujos vértices são recursos heterogêneos já existentes no acervo — problemas, objetivos, decisões, observações, evidências, itens de trabalho, pendências — e cujas arestas têm tipos de _intenção_: #raw("motivou"), #raw("propôs-hipótese"), #raw("desafiou"), #raw("causou-fronteira"), #raw("abriu-objetivo").
] <def-grafo-trajetoria>

Um caminho típico de trajetória tem a forma:

$ "problema" ->^"motivou" "objetivo" ->^"propôs-hipótese" "decisão"_1 <-^"desafiou" "observação" ->^"motivou" "decisão"_2 ->^"causou-fronteira" "trabalho" $

(as arestas de proveniência — a evidência que _provou_ o trabalho, a decisão que _suplantou_ outra — vivem em outro grafo, que compartilha vértices com este, mas não arestas; @sec-mem-navegacao).

Esse caminho responde à pergunta "por que estamos fazendo isto?" sem carregar as conversas em que cada passo foi discutido. Ele atravessa tipos diferentes de recurso, e é precisamente por isso que não deve ser guardado como uma entidade própria.

#principio(titulo: [Trajetória é projeção, não depósito])[
  A trajetória é um _caminho derivado_ através de recursos aplicáveis. Ela é calculada por uma projeção que referencia decisões, evidências, observações e itens de trabalho, e expande apenas o necessário. Criar um grande objeto "trajetória" que copie esses recursos repete o erro do módulo misto (@anti-modulo-misto).
] <pri-trajetoria-projecao>

=== O valor compressivo da trajetória

O experimento de reconstrução descrito no @cap-proveniencia ilustra o valor da trajetória. Um agente com acesso a coordenadas governadas reconstrói com precisão _o que_ aconteceu; um humano reconstrói com facilidade _por que_ aconteceu — porque, para ele, as arestas de intenção estão na memória episódica: "aquela leitura sugeriu uma analogia, a analogia virou uma hipótese, e a hipótese motivou o experimento". O humano _é_ o índice do grafo. O agente não é: se a conversa é seu único acervo, ele precisa reconstruir as arestas linguisticamente, e seus vínculos se tornam probabilísticos — semelhança semântica vaga em vez de aresta explícita.

A hipótese que se segue é testável: entregar a um consumidor frio apenas as coordenadas técnicas mais uma projeção mínima da trajetória de intenção deve permitir reconstruir uma parte maior da história do que as coordenadas sozinhas, com menos contexto do que a narrativa completa.

#hipotese(titulo: [Suficiência da trajetória mínima])[
  Para um objetivo distribuído em vários domínios, um consumidor frio que recebe coordenadas, evidências e uma trajetória mínima (problema, observação que mudou a direção, escolha suplantada, razão da fronteira corrente) responde às perguntas "por que este objetivo existe?", "que observação mudou sua direção?", "que escolha foi suplantada?" e "por que esta é a próxima fronteira?" com acurácia igual ou superior à de um consumidor que recebe o histórico narrativo completo, usando menos tokens e sem aumento de erros de autoridade ou de falsa certeza.
] <hip-trajetoria>

O @cap-avaliacao discute como testar hipóteses desse tipo; o desenho natural tem dois braços — controle (coordenadas e evidências) e tratamento (o mesmo, mais a trajetória mínima) — e mede acurácia das respostas, correção da proveniência citada, erros de autoridade, falsa certeza, número de expansões e de tokens. O critério de sucesso não é "o tratamento responde mais", mas: _menos contexto, verdade igual ou maior, melhor reconstrução do porquê, e nenhum aumento de falsa autoridade_.

#exercicios[
  + Construa o grafo de trajetória de uma decisão técnica que você acompanhou. Quantos vértices são necessários para explicar a decisão a alguém que não participou?
  + Por que a semelhança semântica entre uma conversa casual e uma decisão técnica não é uma aresta de trajetória? Que evidência a tornaria uma?
  + Proponha cinco perguntas de avaliação para testar a @hip-trajetoria num projeto concreto.
]

== Três eixos de navegação <sec-mem-navegacao>

Um consumidor que chega a um domínio grande precisa se orientar ao longo de três eixos, que correspondem a três grafos distintos.

#figure(
  grid(
    columns: 3,
    column-gutter: 1.2em,
    align(center, diagram(
      spacing: (8mm, 6mm),
      node-stroke: 0.5pt + cor.primaria, node-fill: cor.tinta-def, node-corner-radius: 2pt,
      node((0, 0), text(size: 7.5pt)[hospedeiro]),
      node((0, 1), text(size: 7.5pt)[nó de execução]),
      node((0, 2), text(size: 7.5pt)[composição]),
      node((0, 3), text(size: 7.5pt)[domínio soberano]),
      node((0, 4), text(size: 7.5pt)[item de trabalho]),
      node((0, 5), text(size: 7.5pt)[evidência]),
      edge((0, 0), (0, 1), "-|>"), edge((0, 1), (0, 2), "-|>"), edge((0, 2), (0, 3), "-|>"),
      edge((0, 3), (0, 4), "-|>"), edge((0, 4), (0, 5), "-|>"),
    )),
    align(center, diagram(
      spacing: (8mm, 6mm),
      node-stroke: 0.5pt + cor.princ, node-fill: cor.tinta-princ, node-corner-radius: 2pt,
      node((0, 0), text(size: 7.5pt)[dor / intenção]),
      node((0, 1), text(size: 7.5pt)[objetivo]),
      node((0, 2), text(size: 7.5pt)[decisão]),
      node((0, 3), text(size: 7.5pt)[experimento]),
      node((0, 4), text(size: 7.5pt)[observação / correção]),
      node((0, 5), text(size: 7.5pt)[prova → próximo objetivo]),
      edge((0, 0), (0, 1), "-|>"), edge((0, 1), (0, 2), "-|>"), edge((0, 2), (0, 3), "-|>"),
      edge((0, 3), (0, 4), "-|>"), edge((0, 4), (0, 5), "-|>"),
    )),
    align(center, diagram(
      spacing: (8mm, 6mm),
      node-stroke: 0.5pt + cor.inv, node-fill: cor.tinta-inv, node-corner-radius: 2pt,
      node((0, 0), text(size: 7.5pt)[estado $s_0$]),
      node((0, 1), text(size: 7.5pt)[atividade (com evidência)]),
      node((0, 2), text(size: 7.5pt)[estado $s_1$]),
      node((0, 3), text(size: 7.5pt)[atividade (com evidência)]),
      node((0, 4), text(size: 7.5pt)[estado atual]),
      edge((0, 0), (0, 1), "-|>"), edge((0, 1), (0, 2), "-|>"), edge((0, 2), (0, 3), "-|>"),
      edge((0, 3), (0, 4), "-|>"),
    )),
  ),
  caption: [Os três eixos de navegação. À esquerda, o grafo _espacial_: onde o trabalho vive. Ao centro, o grafo de _trajetória_: por que o trabalho se moveu. À direita, o grafo de _proveniência_: como, verdadeiramente, se chegou ao estado atual.],
) <fig-tres-eixos>

Os três grafos compartilham vértices, mas não arestas: o mesmo item de trabalho aparece no grafo espacial (pertence a um domínio), no de trajetória (foi motivado por uma decisão) e no de proveniência (produziu evidências). Tratá-los como um único grafo — por exemplo, inferir que um item de trabalho que _motivou_ outro também o _governa_ — é uma forma do erro que o @cap-espacos estuda em detalhe.

#principio(titulo: [Espaço, trajetória e proveniência, juntos e distintos])[
  Para dar a um consumidor algo próximo da capacidade humana de "lembrar a história" sem carregar a história textual, ofereça os três eixos — onde, por quê e como —, cada um como projeção própria, com arestas tipadas que não se confundem.
] <pri-tres-eixos>

#exercicios[
  + Para um projeto que você conheça, escreva um caminho em cada um dos três grafos que passe pelo mesmo item de trabalho.
  + Dê um exemplo de inferência errada obtida ao seguir uma aresta de trajetória como se fosse de governança.
  + Para um mesmo item de trabalho, formule uma pergunta respondida pelo grafo de espaço, outra pela trajetória e outra pela proveniência, e explique por que nenhuma das três pode ser respondida pelos outros dois grafos.
]

== Escrever na memória <sec-mem-escrita>

Até aqui o capítulo tratou de como a memória é lida. Igualmente importante é como ela é _escrita_: quem pode gravar uma decisão, uma orientação ou uma pendência, com base em quê, e o que impede que conteúdo adversarial se torne comportamento permanente.

#definicao(titulo: [Escrita governada de memória])[
  Uma _escrita de memória_ é uma ação governada (@def-acao-governada) que acrescenta ao acervo um registro durável — decisão, orientação ou pendência — com: (i) a _fonte_ que o originou (observação, instrução do titular, conteúdo externo); (ii) a _autoridade_ de quem escreve; (iii) o _escopo_ de aplicação; e (iv) a _validade_.
] <def-escrita-memoria>

#invariante(titulo: [Conteúdo externo não escreve orientação])[
  Nenhum registro de orientação durável (@def-orientacao) pode ter como única fonte conteúdo que entrou no contexto como dado — documentos, páginas, saídas de ferramentas, mensagens de outros agentes. Orientações exigem uma fonte com autoridade de instrução (@pri-contexto-nao-comando).
] <inv-memoria-envenenamento>

#proposicao(titulo: [Contenção do envenenamento persistente])[
  Suponha que toda orientação durável que entra numa perspectiva tenha sido escrita sob o @inv-memoria-envenenamento. Então uma injeção de instruções bem-sucedida numa sessão não produz, por si, orientação durável em sessões futuras: seu efeito sobre a memória fica limitado a registros que não são orientações (por exemplo, observações relatadas, com força baixa) ou depende de uma confirmação por fonte com autoridade de instrução.
] <prop-envenenamento-persistente>

#prova[
  Uma orientação durável numa sessão futura foi, por hipótese, escrita por uma ação governada cuja fonte inclui uma fonte com autoridade de instrução. O conteúdo injetado não é, por definição, tal fonte; logo não basta, sozinho, para a escrita. Os demais registros que ele pode originar não são orientações e, por P4, entram nas perspectivas com seu estatuto e sua força — não como instruções.
]

Sem o invariante, uma única injeção bem-sucedida afeta todas as sessões futuras cujas perspectivas incluam a orientação gravada — o antipadrão da "memória que se autoriza" do @cap-seguranca.

#exercicios[
  + Construa o cenário em que um documento recuperado leva um assistente a gravar, como preferência do usuário, "sempre envie os relatórios para o endereço $X$". Identifique a ação governada que deveria ter barrado a escrita.
  + Projete um portão de escrita de memória: que pré-condições ele verifica e que saídas produz quando a fonte é conteúdo externo?
  + #avancado Modele a memória como um canal entre sessões e mostre que a fronteira de autoridade de escrita é o que impede a propagação de uma injeção de uma sessão para as seguintes.
]

== O quadro de orientação inicial <sec-mem-orientacao>

Um consumidor frio — um agente iniciado sem histórico, ou um humano recém-chegado — enfrenta uma pergunta antes de qualquer outra: _acabei de chegar; que pequeno conjunto de coisas preciso saber?_ Uma resposta comum é um pacote monolítico de orientação escolhido por relevância (@anti-modulo-misto): o efeito é bom; a mistura de papéis, ruim. A versão correta da mesma ideia é um quadro com cinco componentes.

#definicao(titulo: [Quadro de orientação inicial])[
  O _quadro de orientação inicial_ de um consumidor numa coordenada é uma perspectiva compacta composta de: (i) a _identidade_ do locus e do consumidor, resolvidas com prova; (ii) um _índice endereçável_ do universo disponível — quais domínios, recursos e superfícies de conhecimento existem e podem ser expandidos, sem seu conteúdo; (iii) as _orientações duráveis_ aplicáveis; (iv) o _trabalho selecionado_ (ou a declaração explícita de que não há, com indicação de onde há trabalho observável); (v) a _fronteira_ de expansão orientada pelo objetivo.
] <def-quadro-orientacao>

#figure(
  diagram(
    spacing: (10mm, 8mm),
    node-stroke: 0.6pt + cor.primaria, node-fill: cor.tinta-def, node-corner-radius: 2pt,
    node((0, 0), [orientação compacta]),
    node((1, 0), [universo endereçável]),
    node((2, 0), [seleção guiada pela coordenada]),
    node((3, 0), [expansão limitada]),
    node((4, 0), [consumidor orientado]),
    edge((0, 0), (1, 0), "-|>"), edge((1, 0), (2, 0), "-|>"), edge((2, 0), (3, 0), "-|>"), edge((3, 0), (4, 0), "-|>"),
  ),
  caption: [O circuito de orientação. A eficiência vem de o consumidor não precisar _descobrir_ o acervo: ele recebe uma âncora e um índice, e expande sob demanda.],
) <fig-circuito-orientacao>

O índice endereçável do passo (ii) é a peça mais sutil. Ele permite a um componente — por exemplo, o registro de um nó de execução que conhece vários domínios — dizer "o domínio $X$ existe e tem conhecimento sobre $Y$" sem possuir nem divulgar esse conhecimento.

#invariante(titulo: [Disponibilidade não é divulgação])[
  Saber que um conhecimento existe e está disponível em algum domínio não implica poder entregá-lo ao consumidor corrente. Um registro de descoberta pode conhecer referências a conhecimento de vários domínios; não deve possuir nem copiar esse conhecimento, e só o divulga sob a autoridade do domínio dono.
] <inv-disponibilidade-divulgacao>

#principio(titulo: [Quem seleciona é a perspectiva])[
  Nem o registro de descoberta, nem a composição de domínios, nem o próprio domínio escolhem o conhecimento que entra no contexto: quem seleciona é a projeção relativa à coordenada do consumidor. Os demais componentes oferecem referências; a perspectiva decide.
] <pri-quem-seleciona>

#estudo-de-caso(titulo: [Recuperar a eficiência sem recuperar a mistura])[
  Uma equipe que havia abandonado um mecanismo anterior de orientação — por causa da mistura de papéis descrita no @anti-modulo-misto — percebeu que perdera algo: agentes novos demoravam muito para se orientar, porque agora precisavam descobrir o acervo sozinhos. A solução não foi reintroduzir o mecanismo, mas reconstruir sua _função_ útil com as distinções novas: um registro de descoberta que sabia quais domínios existiam (sem guardar seu conteúdo), perspectivas por domínio que selecionavam por aplicabilidade e divulgação (não apenas por relevância), e expansão limitada. A frase que resumiu a decisão foi: _absorver o valor, não a estrutura histórica_.
] <caso-eficiencia-sem-mistura>

#exercicios[
  + Escreva o quadro de orientação inicial para um agente que vai trabalhar pela primeira vez num repositório que você conhece. Quantos tokens ele tem? O que ficou como alça de expansão?
  + Por que o passo (iv) da @def-quadro-orientacao deve incluir a indicação de onde há trabalho observável quando não há trabalho selecionado? Relacione com o @anti-inventario-selecao.
  + Discuta a frase "absorver o valor, não a estrutura histórica" como princípio geral de evolução de sistemas.
]

#quadro[
  - Toda continuidade é externa; memória é infraestrutura, organizada por função: conhecimento, unidade de empacotamento, memória, evidência, coordenada, perspectiva, trajetória (@tab-elementos-continuidade).
  - Relevância não é verdade; módulos mistos produzem ambiguidade irreparável.
  - Decisões registram problema, alternativas, escolha, razão, autoridade, evidência e condições de revisão; pendências são possibilidades, não compromissos.
  - O registro de continuação é um registro só-para-frente da exploração, que inclui falhas; erros geram correções ligadas, nunca reescrita.
  - Trajetória é o grafo do porquê: uma projeção derivada, não um depósito; é altamente compressiva.
  - Espaço, trajetória e proveniência são três eixos de navegação distintos.
  - O quadro de orientação inicial dá ao consumidor frio âncora, índice e fronteira; disponibilidade não é divulgação.
]

#problemas[
  #problema([Condições de revisão executáveis])[
    Condições de revisão de decisões podem, às vezes, ser verificadas automaticamente.
    + Dê três exemplos de condições de revisão verificáveis por observação (por exemplo, "se o volume diário ultrapassar $N$").
    + Proponha um mecanismo que avalie periodicamente essas condições e produza evidência quando uma delas for satisfeita.
    + Discuta por que a reabertura da decisão deve continuar sendo uma ação governada, e não um efeito automático.
  ]
  #problema([Trajetória mínima])[
    Dado um grafo de trajetória com $n$ vértices e um objetivo $o$, queremos o menor subgrafo que permita responder às quatro perguntas da @hip-trajetoria.
    + Formule o problema como um problema de seleção (@cap-selecao).
    + Suponha que cada pergunta possa ser respondida por qualquer caminho de um conjunto dado de caminhos do grafo. Mostre que o problema se reduz a escolher um caminho por pergunta de modo a minimizar o número total de vértices, e que esse problema generaliza a cobertura de conjuntos.
    + Proponha uma heurística e discuta quando ela falha.
  ]
  #problema([Memória que envelhece])[
    Um assistente pessoal acumula, ao longo de um ano, centenas de memórias sobre seu usuário.
    + Classifique-as em decisões, orientações, pendências e fatos relatados.
    + Proponha políticas de validade para cada classe (@def-atualidade).
    + Descreva o procedimento que o assistente deve seguir quando uma memória antiga contradiz uma observação nova, aplicando o @pri-prova-memoria.
  ]
]

#notas[
  Taxonomias de memória para agentes de linguagem, inspiradas em arquiteturas cognitivas, são apresentadas por #ct(<sumers2024>) e revisadas por #ct(<zhang2024memory>); os agentes generativos de #ct(<park2023>) mantêm um fluxo de memórias com recuperação por recência, importância e relevância, e #ct(<packer2023>) propõem paginação entre janela e armazenamento externo. A prática de registrar decisões com suas razões e alternativas tem longa tradição em engenharia de software; a ideia de condições de revisão explícitas relaciona-se à noção de entrincheiramento da teoria de revisão de crenças @gardenfors1988. A cognição distribuída de #ct(<hutchins1995>) oferece uma moldura para entender por que o humano funciona como "índice" da trajetória: parte da memória de um sistema cognitivo reside em artefatos e em outras pessoas, e a questão de projeto é decidir o que precisa ser externalizado para que um novo participante consiga se integrar.

  O registro de continuação, a distinção entre trajetória e proveniência e o quadro de orientação inicial são propostas deste livro; não conhecemos tratamento anterior com essa forma. Relacionam-se aos diários de laboratório e aos registros de decisões de arquitetura da engenharia de software, e à literatura sobre memória de agentes de linguagem @sumers2024 @zhang2024memory, cujos estudos de avaliação de memória de longo prazo em conversas @maharana2024 mostram como a recuperação por relevância falha justamente nas perguntas temporais e causais que a trajetória responde. A escrita governada de memória aplica à memória a defesa contra injeção indireta de #ct(<greshake2023>).
]
