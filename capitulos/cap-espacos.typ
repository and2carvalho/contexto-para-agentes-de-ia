#import "/modelo/estilo.typ": *

= Domínios soberanos, nós e composições <cap-espacos>

#epigrafe[Gestão central sem posse semântica central.]

O @cap-identidade tratou de _quais_ recursos existem; o @cap-autoridade tratará de _quem pode_ agir sobre eles. Este capítulo trata de _onde_ eles vivem — não no sentido físico de diretórios e máquinas, mas no sentido organizacional de fronteiras de soberania. Um agente que trabalha num ambiente com muitos repositórios, máquinas, serviços e equipes precisa de um mapa dessas fronteiras: qual domínio responde por quê, qual máquina materializa o quê, que agrupamentos existem e o que eles significam.

O erro característico deste tema é deixar a organização física ditar a organização semântica: tratar cada repositório como um domínio, cada diretório como um agrupamento, cada máquina como uma autoridade. A @sec-esp-soberania dá critérios para reconhecer um domínio soberano. A @sec-esp-acervo descreve o acervo de um domínio em camadas. A @sec-esp-nos define nós como universos de resolução. A @sec-esp-composicoes trata de composições. A @sec-esp-controle apresenta domínios de controle e objetivos de coordenação. A @sec-esp-grafos organiza tudo em grafos distintos — e explica por que confundi-los é a fonte de muitos erros. A @sec-esp-enderecamento propõe um esquema de endereçamento.

== O que merece ser um domínio soberano <sec-esp-soberania>

Um domínio é _soberano_ quando detém a autoridade última sobre os recursos que governa — sobre quem pode lê-los, alterá-los e decidir sua linha de base; o @cap-autoridade formaliza a noção (@def-soberania). Na prática, é preciso decidir _quais_ entidades merecem ser domínios soberanos. A resposta não é "todas as que têm um diretório" nem "todas as que têm um repositório".

#definicao(titulo: [Critérios de soberania])[
  Uma entidade merece ser tratada como _domínio soberano_ quando satisfaz, com justificativa registrada:
  + _perspectiva recomponível_: é possível calcular uma perspectiva sobre ela de forma independente, a partir de seu próprio acervo;
  + _posse de estado_: ela possui estado durável próprio (decisões, evidências, unidades de trabalho), que não pertence a nenhum outro domínio;
  + _posse de ciclo de vida_: suas unidades de trabalho e suas transições são governadas por ela;
  + _fronteira de governança_: suas regras de autoridade nascem nela;
  + _locus de conhecimento e evidência_: é o lugar onde a verdade sobre seus recursos é registrada;
  + _endereçabilidade independente_: pode ser designada e alcançada sem passar por outro domínio.
] <def-criterios-soberania>

#invariante(titulo: [Repositório não é domínio; materialização não é domínio])[
  Um repositório de código é um recurso, que um domínio pode referenciar, materializar e governar; não é, por existir, um domínio. Da mesma forma, uma materialização (uma cópia num diretório) não é um domínio. A presença de resíduos de inicialização num repositório não ratifica soberania; tornar cada repositório um domínio "para que a navegação funcione" reintroduz o acoplamento entre bytes e governança.
] <inv-repositorio-dominio>

#estudo-de-caso(titulo: [Dezessete repositórios num diretório])[
  Uma equipe mantinha dezessete repositórios independentes sob um mesmo diretório de uma máquina de desenvolvimento. Com o tempo, ferramentas diferentes haviam tratado o diretório como um domínio (havia um marcador de inicialização esquecido num dos repositórios e ponteiros antigos, num acervo, apontando para o diretório). Uma auditoria concluiu: o diretório não era domínio, nem composição, nem identidade de repositório — era um _coleção de materializações_, com marcadores residuais históricos. O modelo adotado foi: um único domínio de contexto, soberano, que _referencia_ os dezessete repositórios (e um décimo oitavo, sem materialização local) como recursos, com suas revisões e evidências; o diretório continua sendo apenas onde as cópias estão.
] <caso-dezessete>

#exercicios[
  + Aplique os critérios da @def-criterios-soberania a: (a) um repositório de biblioteca usado por vários projetos; (b) o espaço de trabalho de uma equipe que coordena esses projetos; (c) uma máquina de integração contínua. Quais merecem ser domínios soberanos?
  + No @caso-dezessete, por que criar um domínio para cada repositório seria um erro? E por que criar uma composição apenas para agrupá-los também seria?
  + Proponha um registro de decisão (@def-registro-decisao) que justifique a criação de um novo domínio soberano.
]

== O acervo em camadas <sec-esp-acervo>

O acervo de um domínio não é uma coisa só. Diferentes tipos de verdade têm diferentes donos e diferentes ciclos de vida.

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Camada], [Guarda], [Natureza]),
    [Objetos imutáveis], [bytes exatos, endereçados por conteúdo], [retenção e reconstrução; nunca editados],
    [Estado vivo legível], [registros correntes do domínio (decisões, unidades, evidências), legíveis por humanos e máquinas], [autoritativo; alterado só por transições governadas],
    [Índices derivados], [índices de busca, caches, resumos, projeções materializadas], [regeneráveis a partir das camadas anteriores],
    [Marcador de identidade], [o identificador soberano do domínio], [estável; não editado],
  ),
  caption: [Camadas do acervo de um domínio. Controle de versão guarda a evolução da fonte; o armazenamento por conteúdo guarda bytes; o estado vivo guarda continuidade e relações; a projeção decide o que o consumidor vê. Nenhuma camada substitui outra.],
) <tab-camadas-acervo>

#invariante(titulo: [Só o derivado é regenerado])[
  Procedimentos de regeneração (reconstruir índices, recalcular projeções) atuam apenas sobre a camada derivada. Tratar o estado vivo como "derivado" e regenerá-lo por cima destrói informação; tratar uma experiência curada por humanos — uma descrição editada, uma organização deliberada — como projeção regenerável apaga trabalho humano.
] <inv-so-derivado>

#exercicios[
  + Classifique nas camadas da @tab-camadas-acervo: um resumo de sessão gerado automaticamente; o registro de uma decisão; o binário de uma versão aceita; o índice vetorial de documentos; o identificador do domínio.
  + Descreva um incidente em que um procedimento de "reconstruir índices" apagou estado vivo, e a salvaguarda que o teria evitado.
  + Para cada camada da @tab-camadas-acervo, indique o que acontece com o domínio se ela for perdida, e se a perda é recuperável a partir das demais.
]

== Nós: universos de resolução <sec-esp-nos>

Uma máquina — física, virtual ou contêiner — onde agentes e serviços executam e onde recursos são materializados é, no vocabulário deste livro, um _nó_.

#definicao(titulo: [Nó])[
  Um _nó_ é um locus de resolução, materialização e observação: o lugar onde identificadores de domínios são resolvidos para materializações locais, onde recursos são materializados e de onde o estado de processos é observado. Um nó tem uma _identidade de instalação_ — a continuidade de um locus através de processos e reinícios —, que não é a identidade física da máquina: uma reinstalação cria um novo locus.
] <def-no>

#invariante(titulo: [O nó resolve, não possui])[
  Um nó descobre e resolve domínios e recursos sem adquirir autoridade sobre seu conteúdo. Seu registro pode saber que "o domínio $X$ existe, tem conhecimento sobre $Y$ e está materializado aqui"; não deve guardar o conhecimento de $X$, nem decidir sobre ele. Registro de nó não é acervo de domínio.
] <inv-no-resolve>

O invariante resolve um problema que surge quando um serviço de contexto é iniciado num diretório e passa a tratar o domínio daquele diretório como o mundo inteiro. Com um nó explícito, o serviço pode perguntar ao registro do nó quais domínios existem e são alcançáveis, e abrir a perspectiva do domínio pedido, em vez de presumir que é o do lugar onde nasceu (@cap-localizacao).

#principio(titulo: [O nó sinaliza; a perspectiva seleciona])[
  O registro do nó oferece referências (quais domínios, quais superfícies de conhecimento, quais expansões); a seleção do que entra no contexto é feita pela projeção relativa à coordenada do consumidor (@pri-quem-seleciona).
] <pri-no-sinaliza>

#exercicios[
  + Um serviço de contexto, iniciado num diretório $D$, recebe um pedido sobre um domínio materializado em outro diretório da mesma máquina. Descreva como o serviço deveria resolver o pedido com e sem um registro de nó.
  + Por que a identidade de instalação deve mudar numa reinstalação? Que falsa continuidade seria criada se não mudasse?
  + Um mesmo domínio está materializado em dois nós. Descreva o que cada nó sabe e não sabe sobre o domínio e o que deve acontecer quando um agente pede, ao nó errado, uma operação que exige a materialização local.
]

== Composições <sec-esp-composicoes>

Domínios se agrupam: um produto pode envolver vários domínios; uma equipe pode coordenar vários. O agrupamento persistente de domínios é uma _composição_.

#definicao(titulo: [Composição])[
  Uma _composição_ é uma identidade persistente que nomeia uma relação entre domínios soberanos, atribuindo a cada membro um _papel_ (por exemplo, controle, alvo, dependência), com proveniência da pertinência. Uma composição não inclui hospedeiros, autoridade, estado dos membros, vínculos de fonte nem perspectivas.
] <def-composicao>

#invariante(titulo: [Pertinência não é autoridade])[
  Ser membro de uma composição não concede autoridade sobre a composição, nem sobre outros membros, nem herda a autoridade da composição. Uma composição pode ver uma relação sem poder agir sobre ela; um domínio pode ser membro de várias composições.
] <inv-pertinencia-autoridade>

#invariante(titulo: [Composição não é coleção de repositórios; vários nós não são composição])[
  Uma composição relaciona domínios, não materializações. O fato de recursos estarem distribuídos por vários nós não cria uma composição; o fato de repositórios estarem num mesmo diretório também não.
] <inv-composicao-colecao>

Um caso obrigatório de teste para qualquer modelo de composição é: _uma identidade, uma materialização, várias pertinências_. Um mesmo domínio, materializado uma vez, participa de duas composições com papéis diferentes. Se o modelo não consegue representar isso sem duplicar o domínio ou sua materialização, ele confundiu pertinência com identidade ou com localização.

#exercicios[
  + Modele uma composição com três domínios, em que um deles tem papel de controle e os outros de alvo. O que o domínio de controle pode e não pode fazer sobre os alvos?
  + Construa o caso "uma identidade, uma materialização, duas pertinências" e mostre como um registro de nó que guarda um único campo "composição" por domínio falha em representá-lo.
  + Por que uma composição não deve ser usada para conceder escrita? Construa um cenário em que essa confusão permite a um agente alterar um domínio do qual ele só deveria ler.
]

== Domínios de controle e objetivos de coordenação <sec-esp-controle>

Em ambientes com muitos domínios, é útil ter um domínio cuja função é _observar e relacionar_ os demais.

#definicao(titulo: [Domínio de controle])[
  Um _domínio de controle_ é um papel — não uma identidade fixa — desempenhado por um domínio soberano que observa, referencia, contextualiza e demonstra relações entre recursos externos sem possuí-los. Ele sabe que um repositório existe, onde está materializado, qual revisão foi observada, que evidência sustenta essa observação e que relações o ligam a outros recursos; não é dono do repositório.
] <def-dominio-controle>

O domínio de controle realiza aquilo que a epígrafe resume: gestão central sem posse semântica central. Ele é o lugar natural para o inventário projetado do @cap-higiene e para a linha de base observacional.

#definicao(titulo: [Objetivo de coordenação])[
  Um _objetivo de coordenação_ agrupa contribuições de unidades de trabalho soberanas em domínios diferentes, para um fim comum, sem possuir o ciclo de vida dessas unidades. Sua perspectiva conhece as interfaces, as dependências, as contribuições requeridas, as provas de cada domínio e o conhecimento de trajetória que explica por que as partes pertencem juntas — e não os detalhes internos de cada subgrafo.
] <def-objetivo-coordenacao>

#principio(titulo: [Divisão e conquista contextual])[
  Em vez de um único item de trabalho gigante cujas faixas tocam vários domínios — em que toda nova relação interfere no grafo central —, use unidades soberanas em cada domínio e um objetivo de coordenação que as relaciona. A camada de coordenação precisa conhecer apenas interfaces, dependências, contribuições, provas e a trajetória crítica.
] <pri-divisao-conquista>

#exercicios[
  + Um objetivo exige mudanças em três domínios: uma interface no primeiro, sua implementação no segundo e um cliente no terceiro. Descreva o objetivo de coordenação e as três unidades soberanas. O que a prova de coordenação precisa referenciar?
  + Compare o custo de contexto de um consumidor que coordena por objetivo de coordenação com o de um que coordena por uma única unidade gigante.
  + #avancado Modele um objetivo de coordenação como um grafo de dependências entre unidades de trabalho em domínios diferentes. Mostre que a perspectiva de coordenação precisa conter, no mínimo, o caminho crítico desse grafo, e discuta o custo de calculá-lo.
]

== Os grafos do trabalho <sec-esp-grafos>

Reunindo os conceitos, um mesmo conjunto de recursos admite vários grafos, com vértices compartilhados e arestas de tipos distintos.

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Grafo], [Pergunta], [Arestas típicas]),
    [Soberania], [quem é dono de quê?], [#raw("possui"), #raw("governa")],
    [Composição], [que domínios compõem esta unidade?], [#raw("é-membro-de") (com papel)],
    [Fonte], [onde vive a implementação?], [#raw("implementado-em"), #raw("depende-de")],
    [Execução e implantação], [onde está materializado e ativo agora?], [#raw("materializado-em"), #raw("executa-em")],
    [Consumo de contexto], [o que este consumidor vê e usa agora?], [#raw("consumiu"), #raw("expandiu"), #raw("selecionou")],
  ),
  caption: [Cinco grafos de topologia sobre os mesmos recursos. Não existe "a árvore correta"; existe um conjunto coerente de grafos tipados derivados da mesma realidade governada.],
) <tab-cinco-grafos>

Os cinco podem ser agrupados em três grafos de maior nível, que convém manter mentalmente separados: o de _materialização e topologia_ (onde algo vive e como se resolve), o de _governança e objetivos_ (unidades, decisões, aceitações, objetivos de coordenação) e o de _contexto e consumo_ (quem consumiu o quê, perspectivas, expansões).

#invariante(titulo: [Mesma entidade, relações e planos diferentes])[
  Aparecer em dois grafos não torna duas relações a mesma: um domínio pode ser membro de uma composição sem que ela seja sua autoridade; um item de trabalho pode governar mutações num repositório sem que o repositório seja membro de seu domínio; uma perspectiva pode enxergar uma relação sem poder agir sobre ela. Inferências que atravessam grafos — de pertinência para autoridade, de motivação para governança, de localização para pertinência — são inválidas sem uma aresta própria no grafo de destino.
] <inv-mesma-entidade>

Uma metáfora geométrica ajuda a ver o papel das perspectivas. Uma variedade, em geometria, em geral não admite uma carta global: ela é descrita por um _atlas_ de cartas locais, compatíveis onde se sobrepõem. Analogamente, não há uma perspectiva global de um ambiente complexo; há perspectivas locais — cartas —, cada uma relativa a uma coordenada, que devem concordar onde se sobrepõem (mesma afirmação, mesmo estatuto). A compatibilidade nas sobreposições é o que a honestidade das projeções (P4) garante para perspectivas calculadas no mesmo instante e sob o mesmo teto de autoridade: nesse caso, duas perspectivas honestas nunca apresentam o mesmo conteúdo com estatutos contraditórios. Com tetos diferentes, a honestidade é relativa ao legível de cada uma (@def-estatuto-sustentado), e a compatibilidade exige que a política de divulgação declare a informação retida que afeta o estatuto.

=== Veredito de um diretório

Ao encontrar um diretório, um agente frequentemente precisa decidir o que ele é. O procedimento a seguir evita tanto a promoção indevida (tratar como domínio) quanto o descarte indevido.

#algoritmo("Veredito-de-Diretório", params: $d$, legenda: [Classificação de um diretório quanto ao seu papel semântico.])[
  + $m <- $ marcadores de identidade de domínio em $d$ (resolvidos contra registros)
  + $c <- $ marcadores de composição em $d$
  + #kw[se] há marcadores que não resolvem ou se contradizem #kw[então] #kw[devolva] #estado[residual conflitante] com a lista #h(1fr) ▷ conflito primeiro
  + #kw[se] $m$ resolve para um domínio registrado e ratificado #kw[então] #kw[devolva] #estado[domínio ativo]
  + #kw[se] $c$ resolve para uma composição registrada #kw[então] #kw[devolva] #estado[composição ativa]
  + #kw[se] $d$ contém apenas materializações de recursos #kw[então] #kw[devolva] #estado[só coleção de materializações]
  + #kw[devolva] #est[desconhecido]
] <alg-veredito-diretorio>

#exercicios[
  + Escolha um recurso de um projeto e trace suas arestas em cada um dos cinco grafos da @tab-cinco-grafos.
  + Dê um exemplo de inferência inválida entre grafos que você já viu ser feita (por pessoa ou ferramenta).
  + Aplique o @alg-veredito-diretorio ao diretório do @caso-dezessete.
]

== Endereçamento <sec-esp-enderecamento>

Para que perspectivas, expansões e transferências refiram recursos de forma estável, é útil um esquema de endereçamento independente de localizadores.

#definicao(titulo: [Endereço de domínio])[
  Um _endereço de domínio_ tem a forma
  #align(center, raw("urn:dominio:<id>[:rev:<revisão>][?superficie=<nome>][&perfil=<nome>]"))
  — um nome uniforme de recurso no sentido usual da web —, em que `<id>` é o identificador soberano, a revisão é opcional, e os componentes de consulta designam, respectivamente, uma superfície pública do domínio e um perfil de renderização. Cada operação exige um subconjunto de componentes: obter a fonte exige identificador e revisão; importar uma superfície exige identificador e superfície. Projetar uma perspectiva exige, além do endereço, uma coordenada $kappa$; o perfil parametriza apenas a renderização.
] <def-endereco-dominio>

O endereço não contém caminho nem máquina: o localizador é resolvido, em cada nó, a partir do endereço, pela cadeia de resolução do @cap-localizacao. Endereços de rede (para alcançar o domínio) são relativos à coordenada de quem pergunta.

#exercicios[
  + Escreva endereços para: a revisão aceita de um domínio; a superfície de documentação exportada por ele; a perspectiva "revisão de mudança" sobre a revisão corrente.
  + Por que o endereço não deve conter o nome da máquina onde o domínio está materializado?
  + Mostre que, se os endereços de domínio não contêm localizadores, então mover um domínio de máquina não invalida nenhum endereço registrado. Que informação precisa ser atualizada, e onde?
]

#quadro[
  - Soberania exige critérios: perspectiva recomponível, posse de estado e ciclo de vida, fronteira de governança, locus de evidência, endereçabilidade.
  - Repositório não é domínio; materialização não é domínio; diretório não é composição.
  - O acervo tem camadas (objetos imutáveis, estado vivo, índices derivados, marcador de identidade); só o derivado se regenera.
  - Nós resolvem, não possuem; o nó sinaliza, a perspectiva seleciona.
  - Composição é relação nomeada entre domínios com papéis; pertinência não é autoridade.
  - Domínios de controle fazem gestão central sem posse; objetivos de coordenação relacionam unidades soberanas.
  - Cinco grafos de topologia sobre os mesmos recursos; inferências entre grafos exigem arestas próprias; perspectivas são cartas de um atlas.
]

#problemas[
  #problema([Migração de "um diretório = um domínio"])[
    Uma organização trata cada diretório de projeto como um domínio, com acervo dentro do diretório.
    + Projete a migração para um modelo com acervo lógico e materializações independentes.
    + Identifique os registros que precisam de equivalências provadas (@cap-identidade) e os que podem ser marcados como históricos.
    + Descreva como verificar, ao final, que nenhuma identidade foi duplicada nem perdida.
  ]
  #problema([Atlas de perspectivas])[
    Formalize a metáfora do atlas.
    + Defina "sobreposição" entre duas perspectivas e "compatibilidade" na sobreposição.
    + Mostre que, se todas as perspectivas são projeções honestas do mesmo acervo, calculadas no mesmo instante e sob o mesmo teto, então são compatíveis; construa um contraexemplo com tetos diferentes.
    + Dê um exemplo de duas perspectivas compatíveis cujas renderizações, ainda assim, sugerem conclusões diferentes, e discuta o que isso diz sobre o design de contexto.
  ]
  #problema([Registro de nó sem posse])[
    Projete o registro de um nó que permita descobrir domínios, superfícies de conhecimento e expansões possíveis sem guardar conteúdo de domínios.
    + Especifique os campos.
    + Mostre como um consumidor frio usaria o registro para abrir a perspectiva certa.
    + Identifique que informações do registro podem vazar conhecimento e como a divulgação deve tratá-las (@pri-conhecer-divulgar).
  ]
]

#notas[
  A separação entre armazenamento endereçado por conteúdo, estado vivo e índices derivados é a arquitetura de sistemas de controle de versão distribuídos @chacon2014, baseada em árvores de Merkle @merkle1987; a distinção entre estado desejado, observado e a ação de controladores é central nos orquestradores de contêineres @burns2016. A lei de #ct(<conway1968>) — sistemas tendem a espelhar as estruturas de comunicação das organizações que os projetam — sugere por que fronteiras de soberania bem escolhidas costumam coincidir com fronteiras de responsabilidade humana. #ct(<kleppmann2017>) discute em detalhe a diferença entre sistemas de registro e dados derivados, que corresponde à distinção entre estado vivo e camada derivada.

  Os critérios de soberania, o papel de domínio de controle, os objetivos de coordenação, o veredito de diretório e o caso dos dezessete repositórios são propostas deste livro; não conhecemos tratamento anterior com essa forma. A metáfora do atlas, emprestada da geometria diferencial, explica por que não existe uma perspectiva global correta, mas apenas perspectivas locais compatíveis.
]
