#import "/modelo/estilo.typ": *

= Apresentação: renderização honesta e affordances <cap-apresentacao>

#epigrafe[Uma boa apresentação de uma identidade errada é apenas um erro mais convincente.]

A renderização é o último passo antes do consumidor, e o mais visível. É também onde se perde, com facilidade, tudo o que as etapas anteriores garantiram. Uma perspectiva composta com rigor pode ser apresentada de modo que um campo truncado pareça negado, um desconhecido pareça falso, uma proximidade visual pareça relação, uma opção visível pareça executável e um dado pareça instrução. O @cap-modelo definiu formalmente a renderização honesta (@def-renderizacao); este capítulo trata de como praticá-la.

A @sec-apr-funcao discute a renderização como adaptador e a regra de não recalcular semântica. A @sec-apr-omissao trata de omissões e desconhecidos. A @sec-apr-conformidade define conformidade entre renderizações. A @sec-apr-forma trata de ordem, formato e de um esqueleto canônico de perspectiva. A @sec-apr-funcoes trata das funções dos segmentos e da separação entre contexto e instrução. A @sec-apr-acionabilidade trata de acionabilidade e affordances. A @sec-apr-visual discute representações visuais. A @sec-apr-comparacao apresenta a comparação de perspectivas como ferramenta de design.

== A renderização como adaptador <sec-apr-funcao>

A renderização $rho(P, B, u)$ adapta uma perspectiva a um orçamento e a uma superfície. Ela decide _como_ mostrar, nunca _o que é verdade_.

#invariante(titulo: [A renderização não recalcula semântica])[
  Toda informação semântica apresentada — estatutos, relações, aplicabilidade, seleção, desconhecidos — vem da perspectiva. A renderização pode omitir (declarando), reordenar, resumir com marcação explícita e formatar; não pode atribuir estatutos, inferir relações, preencher lacunas com valores padrão nem consultar outras fontes.
] <inv-renderizacao-semantica>

#invariante(titulo: [Apresentação derivada não é perspectiva canônica])[
  Uma superfície que obtém informação lendo a _apresentação_ de outra superfície — em vez da perspectiva canônica — herda as perdas daquela apresentação e acrescenta as suas. Toda superfície consome a saída canônica do compositor.
] <inv-apresentacao-derivada>

#estudo-de-caso(titulo: [O desconhecido que não era])[
  Uma interface gráfica mostrava "execução: desconhecida" para um serviço cujo estado estava perfeitamente estabelecido. A causa: a interface não consultava a perspectiva; executava a ferramenta de linha de comando e interpretava sua saída textual, que, por limite de espaço, truncava a seção de execução. A interface leu a ausência da seção como ausência de informação. A correção foi fazer a interface consumir a saída estruturada canônica — e não a apresentação de outra superfície.
] <caso-desconhecido-falso>

#exercicios[
  + Liste três operações que uma renderização pode fazer e três que ela não pode, segundo o @inv-renderizacao-semantica.
  + Descreva como o @caso-desconhecido-falso poderia ter sido detectado por um teste automatizado.
  + Uma interface exibe "runtime: desconhecido" porque lê a saída formatada de outra ferramenta que truncou o campo. Explique a falha em termos do @inv-apresentacao-derivada e proponha a correção arquitetural.
]

== Omissões e desconhecidos <sec-apr-omissao>

#invariante(titulo: [Perda na entrega não é negação])[
  Truncar não é negar. Uma lista cortada por orçamento, um campo omitido por espaço ou uma seção recolhida não afirmam que o conteúdo omitido não existe. Toda omissão é marcada, e o consumidor deve poder distinguir "não há" de "não coube".
] <inv-perda-negacao>

#invariante(titulo: [O desconhecido não é sintetizado])[
  Apenas a composição atribui estatuto. Se a perspectiva contém #est[desconhecido], a renderização o apresenta como desconhecido — em todas as superfícies. Ela não o substitui por um valor padrão, por "nenhum", por "falso" ou por uma mensagem de erro.
] <inv-desconhecido-sintetizado>

Na prática, a honestidade das omissões exige um pequeno vocabulário de marcas, usado consistentemente em todas as superfícies:

#figure(
  tabela(
    colunas: (52%, 1fr),
    cabecalho: ([Marca], [Significado]),
    [#raw("[+12 omitidos: dependências; expandir: dep(x)]")], [há mais itens aplicáveis, omitidos por orçamento, com a alça para obtê-los],
    [#raw("desconhecido (motivo: serviço de autoridade indisponível)")], [o valor não pôde ser estabelecido, com a razão],
    [#raw("retido (fora do teto de autoridade)")], [existe, mas não pode ser mostrado a este consumidor],
    [#raw("nenhum (completo: registro R)")], [afirmação negativa sustentada por completude declarada],
  ),
  caption: [Exemplos de marcas de omissão e de estatuto. A última linha é a única que autoriza ler "não há".],
) <tab-marcas>

#exercicios[
  + Reescreva uma saída de ferramenta que você conhece de modo que toda omissão seja marcada.
  + Por que "nenhum" só deve aparecer com referência a uma declaração de completude? Relacione com o @inv-ausencia-negacao.
  + Escreva três marcas de omissão para uma perspectiva em que: (a) 12 dependências foram omitidas por orçamento; (b) 2 documentos foram retidos por autoridade; (c) o estado de um serviço não pôde ser observado. Indique o que cada marca autoriza o consumidor a concluir.
]

== Conformidade entre renderizações <sec-apr-conformidade>

Um sistema tem várias superfícies, cada uma com sua renderização. Elas não precisam mostrar as mesmas coisas — uma interface compacta mostra menos que um relatório —, mas não podem se contradizer.

Para comparar renderizações, é preciso dizer como se lê, num contexto renderizado, o estatuto que ele apresenta.

#definicao(titulo: [Leitura canônica])[
  Uma _leitura canônica_ é uma função "lê" que, a partir de um contexto renderizado e de um esquema de marcação (@tab-marcas), extrai a função parcial $v$ que associa a cada asserção apresentada o estatuto apresentado, e a $omega$ ("omitida, declarada") cada asserção declarada omitida. Escrevemos $v_rho^P$ para a leitura de $rho(P, B, u)$.
] <def-leitura-canonica>

A leitura canônica torna a honestidade (@def-renderizacao) verificável mecanicamente. A distância entre ela e o que o modelo de linguagem _efetivamente_ entende do texto é precisamente a passagem do entregue ao consumido na cadeia de restrição.

#definicao(titulo: [Refinamento entre renderizações])[
  Uma renderização $rho_1$ é _refinada_ por $rho_2$ (escrevemos $rho_1 subset.eq.sq rho_2$) se, para toda perspectiva $P$: (i) toda asserção no domínio de $v_(rho_1)^P$ está no domínio de $v_(rho_2)^P$; e (ii) se $v_(rho_1)^P (a) != omega$, então $v_(rho_2)^P (a) = v_(rho_1)^P (a)$. Isto é, $rho_2$ apresenta, com o mesmo estatuto, tudo o que $rho_1$ apresenta, e apresenta ou declara omitido o que $rho_1$ declara omitido.
] <def-refinamento>

#proposicao(titulo: [O refinamento é uma pré-ordem])[
  A relação $subset.eq.sq$ é reflexiva e transitiva.
] <prop-refinamento-preordem>

#prova[
  Reflexividade: imediata. Transitividade: sejam $rho_1 subset.eq.sq rho_2$ e $rho_2 subset.eq.sq rho_3$. Para (i), os domínios estão encadeados por inclusão. Para (ii), se $v_(rho_1)^P (a) != omega$, então $v_(rho_2)^P (a) = v_(rho_1)^P (a) != omega$, e, por $rho_2 subset.eq.sq rho_3$, $v_(rho_3)^P (a) = v_(rho_2)^P (a) = v_(rho_1)^P (a)$.
]

A cláusula (ii) é essencial. Uma versão mais fraca, que permitisse a $rho_2$ declarar omitido o que $rho_1$ apresenta, não seria transitiva — $rho_1$ apresentaria $a$ como #est[provado], $rho_2$ a declararia omitida, e $rho_3$ poderia apresentá-la como #est[refutado] — e faria da renderização que omite tudo um refinamento de qualquer outra.

#proposicao(titulo: [Renderizações honestas não se contradizem])[
  Se $rho_1$ e $rho_2$ são honestas para a mesma perspectiva $P$, nenhuma asserção é apresentada por uma com estatuto #est[provado] e pela outra com estatuto #est[refutado].
] <prop-honestas-compativeis>

#prova[
  Pela honestidade (@def-renderizacao), o estatuto apresentado por cada renderização é o estatuto em $P$ ou #est[desconhecido]. Se $rho_1$ apresenta #est[provado], o estatuto em $P$ é #est[provado]; se $rho_2$ apresenta #est[refutado], é #est[refutado] — contradição. Renderizações honestas podem omitir, mas não contradizer.
]

#exercicios[
  + Mostre que o refinamento não é antissimétrico: dê duas renderizações diferentes (por exemplo, que diferem apenas na formatação) que se refinam mutuamente.
  + Escreva um teste de conformidade que verifique $rho_"compacta" subset.eq.sq rho_"relatório"$ para um conjunto de perspectivas.
  + #avancado Mostre que o refinamento entre renderizações não é, em geral, antissimétrico (duas renderizações diferentes podem refinar uma à outra) e, portanto, é uma pré-ordem e não uma ordem parcial. Que relação de equivalência ele induz?
]

== Ordem, formato e o esqueleto da perspectiva <sec-apr-forma>

O @cap-llm e o @cap-selecao trataram de ordem (estável antes de volátil, importante nas extremidades) e o @cap-compressao, de densidade e canonicidade. Há, além disso, uma estrutura que convém a quase toda perspectiva renderizada para um consumidor frio — uma lista de perguntas que ele precisa poder responder.

#definicao(titulo: [Esqueleto epistêmico da perspectiva])[
  Uma perspectiva renderizada para um consumidor frio permite responder, em seções identificáveis: _o que existe_ (no escopo); _o que este consumidor pode ver_; _o que ele efetivamente viu_ (na trajetória); _o que foi excluído ou não divulgado_; _o que é desconhecido_; _o que está desatualizado_; _o que é autoritativo_; _o que pode ser expandido_; _qual transição ele está considerando_; e _o que falta para essa transição_.
] <def-esqueleto>

#principio(titulo: [Estruturado para máquinas, prosa para intenção])[
  Estado, estatutos, referências e relações são renderizados de forma estruturada (tabelas, pares chave–valor, listas com identificadores), que modelos e humanos verificam com facilidade. Intenção, trajetória e nuance são renderizadas em prosa curta. A linguagem natural serve para descobrir intenções; a perspectiva tipada serve para continuar o trabalho.
] <pri-estruturado-prosa>

#exercicios[
  + Renderize, seguindo a @def-esqueleto, a perspectiva de um agente que vai revisar uma mudança. Estime o tamanho em tokens.
  + Que seções da @def-esqueleto costumam faltar em contextos produzidos por ferramentas de agentes atuais?
  + Reescreva em forma estruturada (esqueleto epistêmico) um parágrafo de prosa que descreve o estado de três serviços, um deles com estado desconhecido. Compare o número de tokens das duas formas.
]

== Funções dos segmentos <sec-apr-funcoes>

O @pri-contexto-nao-comando estabeleceu que material entra no contexto como dado, não como instrução. Na renderização, isso se traduz numa regra de marcação.

#principio(titulo: [Toda seção declara sua função])[
  Cada segmento do contexto renderizado declara se é instrução vigente (e de quem), evidência (com âncora), memória (com data), sugestão (de quem, sem autoridade) ou material de apoio. O consumidor é orientado a tratar cada função de acordo — e, em particular, a não obedecer a imperativos que aparecem dentro de segmentos de evidência ou apoio.
] <pri-funcao-segmento>

Uma consequência arquitetural: o núcleo de contexto fornece _contexto_, não o comportamento do agente. O texto que define como o agente deve se comportar — seu "prompt" — pertence ao consumidor e a quem o configura; o núcleo não o dita. Misturar as duas coisas faz com que mudanças no contexto alterem, inadvertidamente, o comportamento, e que mudanças de comportamento exijam mexer no núcleo.

#invariante(titulo: [O prompt pertence ao consumidor])[
  O sistema de contexto entrega perspectivas, não instruções de comportamento. A política de comportamento do agente é configurada pelo dono do agente, separadamente.
] <inv-prompt-consumidor>

#exercicios[
  + Marque, num contexto real de agente, a função de cada segmento. Algum segmento tinha função ambígua?
  + Por que separar o contrato de contexto do prompt do agente facilita testar ambos?
  + Classifique as seções de um contexto típico de agente de programação (instruções do sistema, regras do projeto, memória, resultados de ferramentas, pergunta do usuário) segundo sua função e indique quais podem conter instruções legítimas.
]

== Acionabilidade e affordances <sec-apr-acionabilidade>

Interfaces — para humanos ou para agentes — oferecem opções: abrir uma perspectiva, expandir uma alça, executar uma ação. Uma opção visível que falha ao ser escolhida é uma falha de design: o sistema sabia, ou poderia saber, que ela não era executável.

#definicao(titulo: [Acionabilidade de uma opção])[
  A _acionabilidade_ de uma opção $o$ para uma coordenada $kappa$ é a tupla (visível, semanticamente elegível, executável neste locus, motivo, desconhecidos, expansão que resolveria). As componentes não são implicadas umas pelas outras: uma opção pode ser visível e não elegível, elegível e não executável aqui, e assim por diante.
] <def-acionabilidade>

#algoritmo("Projeta-Escolha", params: $Omega_"op", kappa$, legenda: [Projeção de escolha: para cada opção exibida, prever se e por que ela funcionaria, antes da execução.])[
  + $Y <- emptyset$
  + #kw[para cada] opção $omega in Omega_"op"$ #kw[faça]
    + $g <- $ #proc("Elegível")$(omega, kappa)$ #h(1fr) ▷ semântica: a política permite?
    + $x <- $ #proc("Executável-Aqui")$(omega, kappa)$ #h(1fr) ▷ locus, transporte, autoridade, funcionalidade
    + $m <- $ motivo, se $g$ ou $x$ não valem
    + $U_omega <- $ desconhecidos que impedem decidir $g$ ou $x$
    + $h <- $ alça de expansão que resolveria $U_omega$
    + $Y <- Y union {(omega, "visível", g, x, m, U_omega, h)}$
  + #kw[devolva] $Y$
] <alg-projeta-escolha>

#invariante(titulo: [Navegável em princípio não é navegável agora])[
  Uma política que diz que um tipo de relação é navegável não garante que a instância concreta seja navegável neste locus, agora. Elegibilidade semântica não é executabilidade local, e visibilidade não é acionabilidade.
] <inv-navegavel>

O vocabulário de _affordances_ — propriedades de um objeto que sugerem como ele pode ser usado @gibson1979 @norman2013 — ajuda aqui: uma boa apresentação faz com que cada opção _pareça_ tão acionável quanto _é_. Opções não executáveis podem continuar visíveis, com o motivo (o que é mais informativo que escondê-las), mas não devem parecer executáveis. A _revelação progressiva_ — mostrar primeiro o essencial e os detalhes sob demanda @shneiderman1996 — é o equivalente, na interface, da fronteira de expansão.

#exercicios[
  + Aplique o @alg-projeta-escolha a quatro opções de uma interface que você conhece.
  + Proponha uma renderização para uma opção visível, elegível e não executável neste locus, que deixe claro o motivo e o que fazer.
  + Aplique o @alg-projeta-escolha a um menu de cinco ações de implantação, das quais duas exigem autoridade que o usuário não tem e uma tem pré-condição desconhecida. Escreva o que a interface deve mostrar para cada ação.
]

== Representações visuais <sec-apr-visual>

Grafos, mapas de topologia e painéis são formas poderosas de apresentação — e também as mais propensas a afirmar o que não sabem.

#invariante(titulo: [Representação visual não é verdade])[
  A posição, a proximidade, o agrupamento e a cor num desenho não são fatos. Nenhuma relação é criada pelo desenho; toda linha corresponde a uma aresta tipada com proveniência; e nenhum agrupamento visual sugere pertinência que não exista no acervo. Estado puramente visual (posições, cores escolhidas pelo usuário) vive fora do acervo.
] <inv-visual-verdade>

#principio(titulo: [Experiência integrada, arquitetura separada])[
  A interface pode unir, numa experiência coesa, o que a arquitetura mantém separado — perspectiva, execução, observabilidade. Unir na experiência não autoriza fundir donos na arquitetura para "simplificar a interface".
] <pri-experiencia-integrada>

A epígrafe do capítulo resume o risco maior: investir em apresentação antes de resolver identidade, proveniência e autoridade produz interfaces convincentes sobre fundações erradas. A ordem é: verdade, depois projeção, depois apresentação.

#exercicios[
  + Descreva um diagrama de arquitetura que você já viu e que sugeria relações inexistentes. Como redesenhá-lo respeitando o @inv-visual-verdade?
  + Por que posições de nós num grafo, escolhidas por um usuário, não devem ser guardadas no acervo do domínio?
  + Um diagrama agrupa serviços por equipe responsável usando cores. Que relação o diagrama afirma visualmente, e que evidência deve existir no acervo para que a afirmação seja legítima?
]

== Comparação de perspectivas <sec-apr-comparacao>

Uma ferramenta de design particularmente útil é colocar lado a lado as perspectivas de consumidores diferentes sobre o mesmo trabalho — o titular, um agente executor, um agente supervisor — e compará-las.

#figure(
  tabela(
    colunas: (1fr, auto, auto, auto),
    cabecalho: ([Pergunta], [Titular], [Agente 1], [Agente 2]),
    [mesmo fato?], [✓], [✓], [✗],
    [mesmo ponto de controle?], [✓], [✓], [✓],
    [mesma autoridade?], [—], [leitura], [escrita],
    [mesmas expansões?], [—], [3], [0],
    [mesmos desconhecidos?], [2], [2], [5],
    [mesma transição considerada?], [promover], [promover], [corrigir],
    [conclusões diferentes?], [], [], [sim],
  ),
  caption: [Esquema de comparação de perspectivas (valores ilustrativos). Divergências entre perspectivas de consumidores que trabalham no mesmo objetivo explicam, muitas vezes, divergências de conclusão.],
) <tab-comparacao>

A comparação torna observável algo que, de outro modo, só se percebe pelos efeitos: dois agentes chegaram a conclusões diferentes porque viram coisas diferentes, com autoridades diferentes, em momentos diferentes. O @cap-observabilidade retoma a ideia como instrumento de depuração.

#exercicios[
  + Construa a comparação de perspectivas para dois agentes que discordam sobre se um teste falha por regressão ou por dívida herdada.
  + Que pergunta da @tab-comparacao é mais frequentemente responsável por divergências na sua experiência?
  + Dois agentes recebem a mesma pergunta por superfícies diferentes e respondem de modo diferente. Use a noção de refinamento entre renderizações para decidir se a diferença é aceitável ou indica um defeito de conformidade.
]

#quadro[
  - A renderização adapta; não recalcula semântica; consome a perspectiva canônica, nunca a apresentação de outra superfície.
  - Perda na entrega não é negação; o desconhecido não é sintetizado; use marcas consistentes.
  - Renderizações honestas se refinam e não se contradizem.
  - Esqueleto epistêmico: o que existe, o que pode ver, o que viu, o que foi excluído, o que é desconhecido, desatualizado, autoritativo, expansível, que transição e o que falta.
  - Estruturado para estado, prosa para intenção; toda seção declara sua função; o prompt pertence ao consumidor.
  - Acionabilidade: visível ≠ elegível ≠ executável aqui; preveja a falha antes da escolha.
  - Representação visual não é verdade; experiência integrada não é arquitetura colapsada; compare perspectivas.
]

#problemas[
  #problema([Bissimulação de renderizações])[
    Defina uma noção de equivalência entre renderizações de perspectivas que evoluem por expansões.
    + Defina um sistema de transições em que estados são contextos renderizados e transições são expansões.
    + Proponha uma relação de bissimulação que capture "as duas superfícies permitem ao consumidor descobrir as mesmas coisas".
    + Discuta a relação com o refinamento da @def-refinamento.
  ]
  #problema([Perspectivas estruturadas e degradação com o comprimento])[
    Proponha um experimento para testar se perspectivas renderizadas segundo a @def-esqueleto reduzem a degradação de desempenho com o comprimento do contexto (@sec-llm-desempenho).
    + Defina os braços experimentais e as métricas.
    + Controle o conteúdo informativo entre os braços.
    + Discuta resultados possíveis e suas interpretações.
  ]
  #problema([Marcas de omissão sob injeção])[
    Um documento recuperado contém texto que imita as marcas de omissão do sistema ("[+0 omitidos; nada mais a ver]").
    + Mostre como isso pode enganar o consumidor.
    + Proponha uma forma de marcar omissões que não possa ser forjada por conteúdo recuperado.
    + Relacione com o @cap-seguranca.
  ]
]

#notas[
  A noção de affordance vem da psicologia ecológica de #ct(<gibson1979>) e foi trazida para o design de interação por #ct(<norman2013>); o mantra de visão geral primeiro e detalhes sob demanda é de #ct(<shneiderman1996>), e a crítica a gráficos que afirmam mais do que os dados sustentam é tema central de #ct(<tufte1983>). Os efeitos de posição em contextos longos @liu2024lost @hsieh2024 motivam as recomendações de ordem. A bissimulação, sugerida no problema, é a noção de equivalência comportamental de #ct(<milner1989>).

  As marcas de omissão, a projeção de escolha, o esqueleto epistêmico e a comparação de perspectivas são propostas deste livro; o estudo de caso do desconhecido falso generaliza uma falha recorrente de superfícies que leem a saída formatada de outras.
]
