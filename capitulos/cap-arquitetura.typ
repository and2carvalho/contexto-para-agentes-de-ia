#import "/modelo/estilo.typ": *

= Arquitetura de sistemas de contexto <cap-arquitetura>

#epigrafe[O sistema fornece operadores; o domínio põe o significado.]

Os capítulos anteriores trataram de conceitos, invariantes e algoritmos. Este trata de como organizá-los num sistema: que componentes existem, quem é dono de quê, como as superfícies se relacionam com o núcleo, onde termina o sistema genérico e começa o domínio de aplicação. Não se trata de descrever um produto — há muitas arquiteturas possíveis —, mas de extrair princípios de arquitetura que decorrem da teoria e que qualquer sistema de contexto sério precisa respeitar.

A @sec-arq-donos estabelece o princípio dos donos semânticos. A @sec-arq-camadas apresenta uma arquitetura em camadas. A @sec-arq-execucoes separa execuções de naturezas diferentes. A @sec-arq-superficies trata de superfícies e operações. A @sec-arq-kits trata da fronteira entre o núcleo genérico e os domínios. A @sec-arq-protocolo discute o que deve ser protocolo. A @sec-arq-ciclo descreve o ciclo de trabalho humano sobre o sistema.

== Donos semânticos <sec-arq-donos>

#definicao(titulo: [Dono semântico de componente])[
  O _dono semântico_ de uma dimensão — seleção de trabalho, aplicabilidade, autoridade, atualidade, divulgação — é o único componente canônico que a calcula. Os demais componentes a _consomem_ ou _adaptam_; nunca a recalculam.
] <def-dono-componente>

O @pri-dono-semantico aplicava a ideia a fontes de verdade no acervo; aqui ela se aplica ao código. As duas aplicações têm a mesma justificativa: duplicar um cálculo é criar duas verdades que divergirão.

#invariante(titulo: [Superfícies não são donas de semântica])[
  Linha de comando, servidor de ferramentas, interface gráfica, extensões de editor e ganchos de ciclo de vida são adaptadores de entrega. Nenhum compõe junções próprias, aplica padrões próprios ou corrige localmente um erro do núcleo. Um erro mascarado na superfície volta a aparecer na próxima superfície que não recebeu a máscara.
] <inv-superficies-donos>

#principio(titulo: [Costura neutra, não superfície chamando superfície])[
  Quando uma funcionalidade existe numa superfície e falta noutra, a correção é extrair a funcionalidade para um ponto neutro do núcleo, chamado por ambas — nunca fazer uma superfície chamar a outra. Superfícies que chamam superfícies herdam formatos de apresentação, perdas e defeitos (@inv-apresentacao-derivada).
] <pri-costura-neutra>

#estudo-de-caso(titulo: [Uma funcionalidade presente numa superfície e ausente noutra])[
  Uma operação de composição de contexto existia na ferramenta de linha de comando, mas não no servidor de ferramentas usado pelos agentes. A solução imediata seria o servidor invocar a ferramenta de linha de comando e interpretar sua saída. A solução adotada foi criar uma costura neutra no núcleo — uma função de resolução compartilhada —, com um adaptador para cada superfície. As duas passaram a ter, por construção, o mesmo comportamento (@teo-superficie).
] <caso-costura-neutra>

#exercicios[
  + Identifique, num sistema que você conhece, uma dimensão semântica calculada em dois lugares. Que divergência isso já causou ou pode causar?
  + Por que "corrigir no consumidor" um erro do núcleo é uma forma de dívida de contexto?
  + Uma interface gráfica calcula localmente se uma unidade de trabalho está "atrasada" a partir das datas. Que dono semântico deveria calcular isso, e que divergência surge se a linha de comando usar outra regra?
]

== Uma arquitetura em camadas <sec-arq-camadas>

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Camada], [Responsabilidade], [Não faz]),
    [Substrato semântico], [identidade, observação, asserções, projeção, diagnóstico, intenção, qualificação — a gramática reutilizável], [não exige infraestrutura gerenciada],
    [Mundo gerenciado], [domínios, nós, composições, autoridade, execução, efeitos governados], [não define a semântica do domínio de aplicação],
    [Protocolo], [o subconjunto que precisa de interoperabilidade entre implementações], [não congela detalhes internos],
    [Superfícies], [entrega: linha de comando, servidor de ferramentas, interface, ganchos], [não recalculam semântica],
    [Clientes], [qualquer consumidor que respeite os contratos], [não ganham privilégio semântico por serem "oficiais"],
  ),
  caption: [Camadas de um sistema de contexto. A riqueza de um cliente vem de acesso legítimo a fontes gerenciadas, não de privilégio semântico.],
) <tab-camadas-arquitetura>

A camada de substrato merece atenção: ela deve ser utilizável por uma aplicação qualquer, _sem_ a infraestrutura gerenciada — sem domínios registrados, sem servidor de autoridade, sem nós. Isso permite três níveis de adoção: _embutido_ (uma aplicação usa a gramática de projeção sobre seus próprios dados), _gerenciado_ (a aplicação participa de domínios, nós e autoridade) e _federado_ (vários domínios soberanos cooperam). Uma aplicação que usa o substrato não é, por isso, um domínio; e nem todo objeto de seu banco de dados é um recurso de domínio.

#invariante(titulo: [Um grafo de leitura, muitos modelos de escrita])[
  A leitura pode ser unificada numa perspectiva sobre todos os planos; a escrita é por relação, com dono e domínio de autoridade próprios (@pri-leitura-escrita). Uma arquitetura que oferece "editar qualquer aresta" com um executor genérico colapsou a separação.
] <inv-leitura-escrita-arq>

#exercicios[
  + Classifique nas camadas da @tab-camadas-arquitetura os componentes de um sistema de agentes que você conhece.
  + Descreva o que uma aplicação ganharia ao usar apenas o substrato semântico, sem a camada gerenciada.
  + Para uma aplicação de anotação de documentos que quer usar o substrato semântico de modo embutido, descreva o que ela ganha e o que não deve fingir ter (domínios, autoridade, nós).
]

== Execuções de naturezas diferentes <sec-arq-execucoes>

Uma tentação recorrente é construir "um núcleo para tudo": um motor que lê, compõe, decide, escreve e registra. A teoria mostra que essas funções têm naturezas opostas.

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Execução], [Natureza], [Exemplos]),
    [Projeção], [pura, sem estado, determinística; executável mil vezes sem efeito], [composição de perspectivas, renderização],
    [Transição], [com estado; diferenças, conflitos, planos], [laço de mutação governada, reconciliação],
    [Trajetória], [registro: resumos, pontos de controle, assinaturas, persistência], [registros de continuação, proveniência],
    [Domínio], [vínculo, injeção de contexto, ciclo de vida de sessões], [inicialização, entrada de contexto],
  ),
  caption: [Execuções ortogonais. Um componente que lê e muta ao mesmo tempo não pode satisfazer o axioma de somente leitura (P1) para suas próprias saídas.],
) <tab-execucoes>

#proposicao(titulo: [Projeção e transição não se fundem])[
  Um componente cujas leituras podem provocar mutações do acervo não satisfaz, em geral, o axioma P1, e anula a utilidade operacional de P2: duas chamadas sucessivas com a mesma coordenada, a partir do mesmo acervo inicial, podem produzir perspectivas diferentes, porque a primeira alterou o acervo visto pela segunda.
] <prop-projecao-transicao>

#prova[
  Seja uma leitura que, como efeito colateral, acrescenta uma asserção aplicável. A primeira chamada vê $Sigma$; a segunda vê $Sigma' = Sigma union {a}$; se $a$ é aplicável e legível, as perspectivas diferem — violando P1 (a projeção alterou o acervo). Formalmente P2 não é violado — as chamadas viram acervos diferentes —, mas sua utilidade operacional se perde: quem chama duas vezes "a mesma coisa" recebe respostas diferentes.
]

#antipadrao(titulo: [Unificação prematura])[
  Para simplificar, decide-se que a experiência curada por humanos (descrições editadas, organizações deliberadas) é "uma projeção de contexto", e que um único núcleo fará projeção e transição. A curadoria passa a ser regenerada por cima; a projeção passa a ter efeitos colaterais. A análise posterior mostra que as duas coisas tinham naturezas opostas — e que a unificação criou duas classes de defeitos.
] <anti-unificacao-prematura>

#principio(titulo: [Registro de eventos com epistemologia])[
  Registrar eventos em vez de estados — o acervo por acréscimo — é a base da reprodutibilidade; mas eventos de sistemas de contexto precisam carregar estatuto, proveniência e escopo. Um registro de eventos que só guarda "o que aconteceu", sem "como sabemos" e "com que certeza", reproduz o passado sem permitir auditá-lo.
] <pri-eventos-epistemologia>

#exercicios[
  + Classifique nas execuções da @tab-execucoes: calcular a seleção de trabalho; gravar uma evidência; aplicar uma migração; registrar um registro de continuação.
  + Mostre um exemplo em que um "comando de leitura" com cache violou P2.
  + Mostre que uma projeção pura pode ser cacheada pela chave (acervo, coordenada, versão de $pi$) e explique por que uma execução de transição não pode.
]

== Superfícies e operações <sec-arq-superficies>

#definicao(titulo: [Superfície de entrega e affordance])[
  Uma _superfície de entrega_ materializa _affordances_ apropriadas ao consumidor — uma ferramenta para um agente, um botão ou uma prévia para um humano — sem redefinir semântica. Funcionalidade semântica, ferramenta, botão e autorização são coisas distintas: a posse de uma ferramenta não é autoridade (@tab-imitacoes).
] <def-superficie>

Algumas funcionalidades do sistema são _operações_ — intenções que podem produzir efeitos. Elas merecem um tratamento uniforme entre superfícies.

#definicao(titulo: [Operação])[
  Uma _operação_ é uma funcionalidade descobrível, tipada e invocável, comum a todas as superfícies, com seis elementos: identidade da operação; pedido tipado; qualificação (disponível? aplicável? atual? que autoridade exige?); invocação (com correlação); recibo; e pós-condição observada. Nem toda funcionalidade é operação: a entrega de contexto, por exemplo, é transporte de ciclo de vida, não operação com efeito.
] <def-operacao>

#invariante(titulo: [Um contrato de entrada, muitos adaptadores])[
  A entrada de contexto (@def-entrada-contexto) é uma só; cada cliente tem um adaptador de ciclo de vida que a entrega pelo mecanismo que o cliente suporta. Adaptadores diferem em mecânica, não em semântica. Um cliente que apenas lê um arquivo de compatibilidade não está, por isso, num ciclo de vida governado.
] <inv-contrato-entrada>

=== Descobribilidade

#invariante(titulo: [Existir não é ser descobrível])[
  Uma funcionalidade que existe, mas que a entrada de contexto e as buscas do consumidor não tornam descobrível, é, para o consumidor, inexistente: ele conclui que ela falta, e pode reimplementá-la. A descobribilidade é testada por recuperação a partir do vocabulário de intenção do consumidor ("como faço para…?"), não do vocabulário interno do sistema.
] <inv-descobrivel>

Uma forma de garantir descobribilidade é a _projeção de contexto de execução_: a composição, sem duplicar autoridade, da configuração, dos manifestos, da linha de base, dos vínculos locais, do estado do controle de versão, das ferramentas e da política de verificação, que permite a um agente operar sem arqueologia. A diferença entre "o agente consegue reconstruir o ambiente" e "o sistema expõe o ambiente" é a diferença entre dívida e infraestrutura.

#exercicios[
  + Escolha uma funcionalidade de um sistema que você usa e avalie seus seis elementos de operação. Qual falta?
  + Proponha um teste de descobribilidade para três funcionalidades, usando frases de intenção de usuários.
  + Escreva os seis elementos de operação (@def-operacao) para a operação "promover revisão" e indique quais deles devem ser idênticos em todas as superfícies.
]

== Núcleo genérico e domínios <sec-arq-kits>

Um sistema de contexto genérico precisa servir domínios de aplicação muito diferentes — engenharia de software, atendimento, pesquisa, finanças. A fronteira entre o genérico e o específico é decisiva.

#figure(
  tabela(
    colunas: (1fr, 1fr),
    cabecalho: ([O núcleo possui], [O domínio possui]),
    [identidade, contexto, projeção, evidência, ciclo de vida, aplicabilidade, expansão], [objetos e linguagem do domínio, autorização de domínio, comandos, renderização específica, perfis, resolvedores],
  ),
  caption: [Fronteira entre núcleo e domínio. O núcleo fornece operadores; o domínio põe o significado.],
) <tab-nucleo-dominio>

#definicao(titulo: [Contrato de consumidor e kit de domínio])[
  Um _contrato de consumidor_ é uma perspectiva base — coordenada, escopo, relações, estatutos, desconhecidos, autoridade e divulgação, fronteira, referências — mais uma família de expansões tipadas; ele permite expansão sem antecipar todas as necessidades. Um _kit de domínio_ é uma fronteira de integração autodescritiva: o consumidor sabe integrar-se por ele; o mantenedor sabe onde cada mudança pertence; e um banco de testes sabe verificar se a fronteira foi respeitada.
] <def-kit-dominio>

#principio(titulo: [O kit está fechado quando um consumidor frio integra só por ele])[
  Se, para integrar um novo consumidor, é preciso ler a implementação de outro consumidor "como exemplo", o conhecimento está tribal e o kit está aberto. O teste de genericidade é um consumidor ortogonal e frio — de outro domínio, sem acesso ao código dos demais — que integra apenas pelo kit.
] <pri-kit-fechado>

#exemplo(titulo: [Um teste de genericidade])[
  Para verificar que o substrato de projeção é genérico, constrói-se uma aplicação externa fictícia — por exemplo, um grafo de conhecimento com documentos, conceitos e citações; um perfil "responder pergunta"; facetas; uma expansão "carregar citação"; uma renderização em formato estruturado; e um modelo de linguagem falso, injetado. Critérios: usar apenas interfaces públicas; não conhecer nenhum domínio existente; não usar identificadores de domínios, nós, composições ou serviços; não depender de controle de versão, linha de comando ou serviços residentes; produzir projeção determinística e expansão limitada; preservar desconhecidos, atualidade e proveniência; permitir trocar o modelo sem alterar a projeção.
] <ex-genericidade>

#exercicios[
  + Defina um contrato de consumidor para um domínio de atendimento ao cliente.
  + Por que o teste de genericidade usa um modelo de linguagem _falso_? O que ele isola?
  + Proponha o conteúdo mínimo de um kit de domínio para integrar um domínio de atendimento ao cliente e descreva o teste com consumidor ortogonal frio que verificaria se o kit está fechado.
]

== O que deve ser protocolo <sec-arq-protocolo>

#principio(titulo: [Protocolo só para interoperabilidade])[
  Torne protocolo apenas o que genuinamente precisa ser interpretado por implementações independentes. Modelos internos de leitura, mesmo versionados, não são protocolo; promovê-los congela detalhes internos e transforma toda mudança em quebra de compatibilidade. O critério de promoção é a existência de um segundo implementador real.
] <pri-protocolo-minimo>

Uma consequência de projeto: objetos semânticos e suas representações em trânsito são coisas distintas. Dentro de um processo, trabalha-se com objetos; entre processos, transmite-se uma projeção limitada deles. Acoplar o modelo semântico ao formato de serialização torna impossível evoluir um sem quebrar o outro.

#exercicios[
  + Dê um exemplo de estrutura interna que foi prematuramente transformada em protocolo e o custo que isso gerou.
  + Proponha um critério operacional para decidir quando um formato interno deve virar protocolo.
  + Dê um exemplo de formato que deveria ser protocolo desde o início (por haver implementadores independentes) e outro que deveria permanecer interno. Justifique pelo @pri-protocolo-minimo.
]

== O ciclo de trabalho humano <sec-arq-ciclo>

Para humanos, um sistema de contexto se apresenta como um ciclo de perguntas, cada uma atendida por uma função de interface diferente.

#figure(
  diagram(
    spacing: (9mm, 8mm),
    node-stroke: 0.5pt + cor.primaria, node-fill: cor.tinta-def, node-corner-radius: 2pt,
    node((0, 0), text(size: 8pt)[escolher domínio\ em que mundos\ posso entrar?]),
    node((1, 0), text(size: 8pt)[explorar\ o que estou\ vendo?]),
    node((2, 0), text(size: 8pt)[declarar intenção\ o que quero\ mudar?]),
    node((3, 0), text(size: 8pt)[planejar\ o que satisfaria\ isso?]),
    node((3, 1), text(size: 8pt)[autorizar\ isso pode\ acontecer?]),
    node((2, 1), text(size: 8pt)[executar\ (dono do efeito)]),
    node((1, 1), text(size: 8pt)[registrar evidência\ o que\ aconteceu?]),
    node((0, 1), text(size: 8pt)[recompor\ o que é verdade\ agora?]),
    edge((0, 0), (1, 0), "-|>"), edge((1, 0), (2, 0), "-|>"), edge((2, 0), (3, 0), "-|>"),
    edge((3, 0), (3, 1), "-|>"), edge((3, 1), (2, 1), "-|>"), edge((2, 1), (1, 1), "-|>"),
    edge((1, 1), (0, 1), "-|>"), edge((0, 1), (0, 0), "-|>"),
  ),
  caption: [O ciclo de trabalho humano sobre um sistema de contexto. Quem edita declara _intenção_, não estado; o planejamento propõe; a autoridade decide; o dono do efeito executa; a evidência registra; a recomposição recalcula a verdade.],
) <fig-ciclo-humano>

#invariante(titulo: [Quem edita declara intenção, não estado])[
  Interfaces de edição registram o que o humano deseja; não alteram diretamente o estado dos domínios. A passagem da intenção ao estado segue o laço de mutação governada, com seus portões.
] <inv-editor-intencao>

#principio(titulo: [Boa projeção de identidade ruim é produto ruim])[
  A ordem de construção é: verdade (identidade, proveniência, autoridade), depois projeção, depois interface. Investir em interface antes de fechar identidade produz um produto convincente sobre fundações erradas.
] <pri-ordem-construcao>

#exercicios[
  + Mapeie as funções da @fig-ciclo-humano para uma ferramenta de gestão de infraestrutura que você conhece. Onde o ciclo é atalhado?
  + Por que a interface de edição não deve alterar estado diretamente? Relacione com o @inv-recomendar-executar.
  + Mapeie as funções da @fig-ciclo-humano para um processo de mudança de configuração em produção numa organização que você conhece, e identifique onde o ciclo é atalhado.
]

#quadro[
  - Um dono semântico por dimensão; superfícies adaptam, não recalculam; costura neutra em vez de superfície chamando superfície.
  - Camadas: substrato semântico, mundo gerenciado, protocolo, superfícies, clientes; adoção embutida, gerenciada ou federada.
  - Projeção, transição, trajetória e domínio são execuções de naturezas diferentes; não as funda.
  - Operações têm identidade, pedido tipado, qualificação, invocação, recibo e pós-condição; existir não é ser descobrível.
  - O núcleo fornece operadores; o domínio põe significado; o kit está fechado quando um consumidor frio integra só por ele.
  - Protocolo só para interoperabilidade real.
  - Ciclo humano: escolher domínio, explorar, declarar intenção, planejar, autorizar, executar, registrar evidência, recompor.
]

#problemas[
  #problema([Arquitetura mínima completa])[
    Projete um sistema de contexto mínimo, mas completo, para um domínio de sua escolha.
    + Defina os donos semânticos, as camadas e as execuções.
    + Especifique as operações e a entrada de contexto.
    + Mostre como o sistema satisfaz os axiomas P1–P6 e os invariantes de autoridade.
  ]
  #problema([Conformidade entre superfícies])[
    Projete um procedimento de conformidade entre superfícies baseado num "vetor semântico".
    + Para a mesma coordenada, extraia de cada superfície o vetor de valores semânticos (seleção, aplicabilidade, estatutos, desconhecidos, autoridade).
    + Separe campos que pertencem só à entrega (formatação) e normalize-os.
    + Defina as sentinelas que devem ser preservadas por todas (desconhecido, autoridade, aplicabilidade, proveniência, omissão não é negação) e como detectar violações.
  ]
  #problema([Descobribilidade mensurável])[
    Proponha uma métrica de descobribilidade de funcionalidades.
    + Defina um conjunto de intenções de usuários e o procedimento de busca a avaliar.
    + Meça a revocação das funcionalidades corretas.
    + Discuta como evitar que a métrica seja otimizada por palavras-chave artificiais (lei de Goodhart).
  ]
]

#notas[
  O princípio de ocultação de informação e decomposição por decisões de projeto é de #ct(<parnas1972>); a separação de preocupações, de #ct(<dijkstra1982>); a observação de que sistemas espelham a estrutura de comunicação de quem os constrói, de #ct(<conway1968>); e o lembrete de que adicionar complexidade de coordenação tem custos não lineares, de #ct(<brooks1975>). A distinção entre sistemas de registro e dados derivados, base da separação entre transição e projeção, é discutida em #ct(<kleppmann2017>). Protocolos abertos para conectar aplicações a modelos @anthropic2024mcp @mcp2025spec ilustram a delimitação discutida na @sec-arq-protocolo: padronizam a exposição de ferramentas, recursos e instruções, e deixam a semântica de cada domínio a quem o possui; modelos que aprendem a usar ferramentas @schick2023 tornam a qualidade das descrições de ferramentas parte da arquitetura.

  Os princípios deste capítulo — donos semânticos, costura neutra, execuções ortogonais, contrato de entrada único, teste de genericidade por consumidor ortogonal frio, protocolo mínimo e o ciclo de trabalho humano — são propostas deste livro; respondem a problemas recorrentes de sistemas com várias superfícies: divergência entre elas, tentações de um núcleo "para tudo" e integrações que só se fazem lendo o código de integrações anteriores.
]
