#import "/modelo/estilo.typ": *

= O problema do contexto <cap-introducao>

#epigrafe[O sistema sabia a verdade. A descrição que ele produziu disse outra coisa.]

Agentes de inteligência artificial baseados em modelos de linguagem já escrevem código, investigam falhas, atendem clientes, conduzem pesquisas e operam sistemas reais. O que eles fazem depende, a cada passo, do que veem — do _contexto_ que recebem. Quando um agente erra, a causa, com frequência, não é falta de capacidade do modelo, mas o contexto — esta é a hipótese de trabalho do livro, sustentada pelos casos que ele relata e por estudos sistemáticos de falhas de sistemas de agentes @cemri2025. O agente viu informação desatualizada como se fosse atual; viu uma suposição como se fosse um fato; não viu algo que existia e concluiu que não existia; viu instruções de um documento e as tratou como ordens; recebeu um resumo que perdeu a única distinção que importava.

Este livro trata o contexto de agentes como objeto de uma disciplina técnica, com conceitos precisos, invariantes, algoritmos, métodos de avaliação e práticas de operação. Este primeiro capítulo motiva essa disciplina. A @sec-int-abertura apresenta um caso que resume o problema. A @sec-int-niveis distingue os níveis em que o contexto pode se perder. A @sec-int-industria discute as respostas usuais da indústria e seus limites. A @sec-int-tese apresenta a tese do livro. A @sec-int-disciplinas apresenta as quatro disciplinas. A @sec-int-linguagem introduz a linguagem de distinções que usaremos. A @sec-int-guia apresenta o exemplo-guia, e a @sec-int-mapa, o mapa do livro.

== Um agente que sabia a verdade e disse outra coisa <sec-int-abertura>

Considere um sistema que orienta agentes de programação no início de cada sessão. Ao receber um novo agente, o sistema calcula o estado do trabalho e lhe entrega uma orientação: em que projeto ele está, qual é a unidade de trabalho ativa, qual é o próximo passo.

Numa dessas entradas, o cálculo interno do sistema estava correto. Ele sabia que existia uma unidade de trabalho registrada; que ela era resolvível; que ela não se aplicava à perspectiva corrente (pertencia a outro objetivo); e que, portanto, nenhuma unidade havia sido selecionada para o agente. Mas a orientação, produzida por um componente de apresentação, dizia: "não há unidade de trabalho ativa" — e sugeria abrir uma nova.

O agente, razoavelmente, abriu uma nova unidade. Ela duplicava a existente. O trabalho dos dias seguintes foi feito em paralelo ao que já existia, até que alguém percebeu a duplicação.

#estudo-de-caso(titulo: [A orientação que apagou uma distinção])[
  O sistema distinguia internamente quatro situações: "não existe unidade"; "existe, mas não resolve"; "existe e resolve, mas não se aplica a esta perspectiva"; "existe, resolve, aplica-se e foi selecionada". A apresentação colapsou as três primeiras numa só frase — "não há unidade ativa" —, e o consumidor tomou a frase como a primeira situação. A falha não estava no cálculo do que era verdade, nem no modelo de linguagem que leu a orientação; estava na passagem entre o que o sistema sabia e o que ele disse.
] <caso-abertura>

O caso contém, em miniatura, quase todos os temas deste livro. Há um _acervo_ de informações sobre o trabalho, com estatutos (existe, resolve, aplica-se). Há uma _perspectiva_ calculada para um consumidor específico, numa coordenada específica. Há uma _renderização_ dessa perspectiva em texto. Há um _consumidor_ que age com base no que lê. E há uma distinção — "não selecionado" não é "não existe" — cuja perda, num único ponto da cadeia, produziu uma ação errada com consequências que duraram dias.

#exercicios[
  + Reescreva a orientação do @caso-abertura de modo que ela preserve as quatro situações distintas, em no máximo duas frases.
  + Descreva uma situação semelhante em ferramentas que você usa (por exemplo, "nenhum resultado encontrado" em uma busca com filtros ativos).
  + Liste as quatro situações distintas do @caso-abertura e, para cada uma, a ação correta de um agente que deseja continuar o trabalho. Em qual delas abrir uma unidade nova seria legítimo?
]

== Onde o contexto se perde <sec-int-niveis>

Entre o mundo e a decisão de um agente há uma cadeia de restrições. A cada elo, parte da informação fica para trás — às vezes por boas razões (orçamento, autoridade, relevância), às vezes por defeito.

#figure(
  block(width: 100%, {
    set text(size: 8.5pt, font: semserifa)
    let nivel(rotulo, corpo, cor-fundo) = block(width: 100%, inset: (x: 8pt, y: 5pt), fill: cor-fundo, stroke: 0.5pt + cor.secundaria, radius: 2pt, below: 0pt)[*#rotulo* — #corpo]
    let rec = 9pt
    nivel([Universo], [o que é potencialmente resolvível sobre o mundo], cor.clara)
    pad(left: rec, nivel([Ambiente], [o que foi observado a partir de onde o agente está], cor.tinta-def))
    pad(left: 2 * rec, nivel([Legível], [o que a autoridade do consumidor permite ver], cor.clara))
    pad(left: 3 * rec, nivel([Aplicável], [o que importa para esta coordenada (a perspectiva)], cor.tinta-def))
    pad(left: 4 * rec, nivel([Selecionado], [o que coube no orçamento], cor.clara))
    pad(left: 5 * rec, nivel([Entregue], [o que chegou de fato à janela do modelo], cor.tinta-def))
    pad(left: 6 * rec, nivel([Consumido], [o que o modelo efetivamente usou ao decidir], cor.clara))
  }),
  caption: [A cadeia de restrição do contexto (versão informal; a formal está no @cap-ambiente). Cada nível está contido no anterior; o que sai da cadeia sai por uma razão, que deveria ser declarada. A autoridade filtra antes da seleção: o que o consumidor não pode ver não deve disputar o orçamento com o que ele pode.],
) <fig-cadeia-informal>

Cada passagem da @fig-cadeia-informal é uma oportunidade de falha distinta:

- algo verdadeiro não é observável do lugar onde o agente está — e o agente conclui que não existe;
- algo observado não pode ser visto pelo consumidor — e o sistema, em vez de declarar a retenção, silencia;
- algo legível e aplicável não é selecionado — e o agente conclui que não importa;
- algo selecionado não chega à janela — por truncamento, por falha de entrega, por um adaptador que não foi executado;
- algo entregue não é usado — porque estava no meio de uma janela longa, posição em que modelos usam pior a informação @liu2024lost.

Em todos os casos, o efeito visível é o mesmo — o agente age como se a informação não existisse —, mas as causas, e portanto as correções, são diferentes. Uma disciplina de contexto começa por distinguir essas causas.

#invariante(titulo: [Poder ver não é ter visto])[
  Que uma informação estivesse disponível para o agente não implica que ele a tenha recebido, nem que a tenha usado. Cada nível da cadeia tem seu próprio recibo, e nenhum nível pode ser inferido do anterior.
] <inv-poder-ver>

#exercicios[
  + Para cada nível da @fig-cadeia-informal, dê um exemplo de informação que um agente de programação perde nesse nível.
  + Um agente afirma: "não há testes para este módulo". Liste as perguntas que você faria para descobrir em que nível da cadeia a afirmação pode estar errada.
  + Para cada passagem da @fig-cadeia-informal, proponha o "recibo" que permitiria a um auditor saber se a informação a atravessou. Qual dos recibos é o mais difícil de obter? Por quê?
  + #avancado Mostre que, se cada nível da cadeia é um subconjunto do anterior, então "o consumidor não usou $x$" não permite inferir em que nível $x$ foi perdido. Que informação adicional resolve a ambiguidade?
]

== As respostas usuais e seus limites <sec-int-industria>

A indústria desenvolveu várias respostas aos problemas de contexto. Todas são úteis; nenhuma é suficiente.

/ Janelas maiores: modelos aceitam hoje de centenas de milhares a alguns milhões de tokens. Mas o desempenho degrada com o comprimento da entrada @hong2025, informação no meio de contextos longos é menos usada @liu2024lost, e informação irrelevante distrai @shi2023. Uma janela maior aumenta o que _pode_ ser entregue, não o que é _usado_ — e não distingue o verdadeiro do desatualizado.

/ Recuperação aumentada: buscar trechos relevantes num corpus e inseri-los no contexto @lewis2020 resolve parte do problema de seleção. Mas similaridade não é relação governada: o trecho mais parecido com a pergunta pode ser de uma versão antiga, de outro projeto, ou uma opinião registrada como fato. A recuperação não traz, por si, estatuto, atualidade nem autoridade.

/ Memória: armazenar informações entre sessões @packer2023 resolve a continuidade. Mas memória não é prova: o que foi verdade ontem pode não ser hoje, e uma memória gravada a partir de um documento adversarial pode se tornar comportamento permanente.

/ Sistemas multiagentes: dividir o trabalho entre agentes com janelas separadas @anthropic2025multiagent resolve a pressão de contexto de cada agente. Mas cada transferência entre agentes é uma oportunidade nova de perda, e a coerência entre perspectivas precisa ser garantida por alguém.

/ Engenharia de prompts: formular melhor as instruções @liu2023prompt melhora o comportamento do modelo dado o contexto. Mas não resolve o que entra no contexto.

O termo _engenharia de contexto_ passou a designar o conjunto dessas práticas — o trabalho de decidir o que entra na janela do modelo a cada passo @anthropic2025context @mei2025. Este livro concorda com a ênfase e propõe ir além: tratar o contexto não como um conjunto de técnicas para encher a janela, mas como objeto de uma teoria, com definições que permitam dizer, com precisão, quando um contexto está _certo_.

#exercicios[
  + Para cada resposta usual, descreva uma falha que ela não previne.
  + Por que "janelas maiores" e "recuperação aumentada" podem piorar o problema de distinguir informação atual de desatualizada?
  + Escolha um artigo ou documentação recente sobre "engenharia de contexto" e classifique as técnicas descritas segundo as cinco respostas usuais desta seção. Alguma técnica não se encaixa? O que ela sugere sobre os limites da classificação?
]

== A tese: contexto é projeção, não acúmulo <sec-int-tese>

A tese central do livro pode ser enunciada em uma frase:

#principio(titulo: [Tese do livro])[
  O contexto de um agente não é texto acumulado; é uma _projeção_ — determinística, limitada por autoridade e epistemicamente honesta — de um _acervo_ governado de asserções, calculada a partir de uma _coordenada_ que descreve quem consome, onde, quando, com que objetivo e com que autoridade.
] <pri-tese>

Cada termo da tese é desenvolvido no livro. _Acervo_ (@cap-modelo): o conjunto de asserções, cada uma com fonte, âncora e estatuto epistêmico. _Coordenada_ (@cap-modelo, @cap-localizacao): a posição do consumidor no espaço de domínios, objetivos, instantes e autoridades. _Projeção_ (@cap-perspectiva): a função que calcula, a partir do acervo e da coordenada, a perspectiva do consumidor. _Determinística_: mesma entrada, mesma perspectiva — o que torna o contexto reprodutível, depurável e auditável. _Limitada por autoridade_ (@cap-autoridade): o consumidor nunca vê mais do que pode. _Epistemicamente honesta_ (@cap-epistemologia, @cap-apresentacao): o que é desconhecido aparece como desconhecido, o que foi omitido aparece como omitido, e nada é apresentado com mais certeza do que tem.

A tese tem uma consequência prática: a maior parte das falhas de contexto vem de _confundir dimensões que a projeção deveria manter separadas_. O agente do @caso-abertura confundiu "não selecionado" com "não existe". Outros confundem "registrado como aberto" com "ainda pendente", "o nome é o mesmo" com "o recurso é o mesmo", "o comando retornou sucesso" com "o efeito ocorreu", "o modelo pode chamar a ferramenta" com "o modelo está autorizado a agir". O livro dá nome a essas distinções, mostra por que cada uma importa e ensina a preservá-las.

#exercicios[
  + Para cada termo da @pri-tese — acervo, coordenada, projeção, determinística, limitada por autoridade, epistemicamente honesta —, descreva uma falha concreta de um agente que ocorre quando aquela propriedade é abandonada.
  + Reescreva cinco falhas da lista do fim desta seção ("registrado como aberto" versus "ainda pendente" etc.) como distinções $X != Y$, indicando para cada uma o capítulo do livro que a trata (use a @tab-guia como guia).
  + Um colega argumenta que "contexto é simplesmente o que cabe na janela". Escreva um contra-argumento de um parágrafo baseado na tese, usando um exemplo em que dois agentes recebem o mesmo texto e deveriam receber perspectivas diferentes.
]

== Quatro disciplinas <sec-int-disciplinas>

O trabalho com contexto se divide em quatro disciplinas, que dão subtítulo ao livro e organizam suas partes.

/ Gerenciamento: cuida do acervo — identidade, lugar, tempo, proveniência, durabilidade, memória. Pergunta: o que é verdade, de onde veio, ainda vale, e quem responde por ela? (Parte II.)

/ Engenharia: cuida da projeção — seleção, conjunto de trabalho, núcleo de projeção, fronteira, compressão, compactação. Pergunta: qual é o menor conjunto verdadeiro suficiente para esta coordenada? (Parte III.)

/ Design: cuida da apresentação — relevância, divulgação, renderização, entrada. Pergunta: como esta perspectiva deve ser apresentada para ser usada corretamente? (Parte IV.)

/ Administração: cuida da mudança — autoridade, portões, ciclo da ação, unidades de trabalho, reconciliação, higiene. Pergunta: como o sistema muda sem perder a verdade, e quem autoriza cada mudança? (Parte V.)

#figure(
  box(width: 9.4cm, height: 6.6cm, {
    let r = 2.05cm
    let circ(cx, cy, tinta, traco) = place(top + left, dx: cx - r, dy: cy - r, circle(radius: r, fill: tinta.transparentize(35%), stroke: 0.7pt + traco))
    circ(3.75cm, 2.35cm, cor.tinta-def, cor.primaria)
    circ(5.65cm, 2.35cm, cor.tinta-inv, cor.inv)
    circ(3.75cm, 4.25cm, cor.tinta-princ, cor.princ)
    circ(5.65cm, 4.25cm, cor.tinta-anti, cor.anti)
    set text(size: 8pt, font: semserifa, weight: "bold")
    place(top + left, dx: 0.2cm, dy: 0.35cm, text(fill: cor.primaria)[Gerenciamento])
    place(top + right, dx: -0.2cm, dy: 0.35cm, text(fill: cor.inv)[Engenharia])
    place(bottom + left, dx: 0.9cm, dy: -0.35cm, text(fill: cor.princ)[Design])
    place(bottom + right, dx: -0.2cm, dy: -0.35cm, text(fill: cor.anti)[Administração])
    place(top + left, dx: 4.7cm - 1.05cm, dy: 3.3cm - 0.25cm, box(width: 2.1cm, height: 0.5cm, fill: white, inset: 2pt, radius: 2pt, stroke: 0.5pt + cor.cinza, align(center + horizon, text(weight: "regular")[acionabilidade])))
  }),
  caption: [As quatro disciplinas e sua interseção. Uma ação é _acionável_ apenas quando o acervo a sustenta (gerenciamento), a projeção a seleciona (engenharia), a apresentação a torna visível e compreensível (design) e a governança a autoriza (administração).],
) <fig-disciplinas>

Cada disciplina falha de um modo característico quando as outras estão ausentes. Design sem gerenciamento produz _contexto bonito e falso_: apresentações convincentes de informação desatualizada. Engenharia sem design produz _contexto correto e inutilizável_: tudo o que é necessário está lá, mas o consumidor não encontra. Gerenciamento sem engenharia produz _um arquivo, não um contexto_: tudo é guardado, nada é selecionado. Administração sem as demais produz _burocracia_: portões que não sabem o que verificar.

As Partes VI a VIII tratam de temas que atravessam as quatro disciplinas: ambientes, execução, federação e segurança (Parte VI); sistemas com vários agentes e arquitetura (Parte VII); avaliação e método (Parte VIII).

#exercicios[
  + Para cada uma das quatro combinações "disciplina $A$ sem disciplina $B$" descritas no texto, dê um exemplo de produto ou ferramenta (real ou hipotético) que sofra do modo de falha correspondente.
  + Classifique em gerenciamento, engenharia, design ou administração: (a) decidir quantos tokens dedicar a resultados de ferramentas; (b) registrar quem aprovou a promoção de uma versão; (c) mostrar ao agente que três documentos foram omitidos por orçamento; (d) detectar que dois nomes designam o mesmo recurso.
  + Por que a acionabilidade está na _interseção_ das quatro disciplinas, e não em uma delas? Dê um exemplo de ação que é sustentada, selecionada e visível, mas não acionável.
]

== A linguagem das distinções <sec-int-linguagem>

Ao longo do livro, muitos invariantes têm a forma de uma distinção: duas coisas que costumam ser confundidas e que precisam ser mantidas separadas. Para torná-las visíveis, usaremos, além do enunciado em prosa, uma notação compacta:

#align(center, block(inset: 6pt)[
  #neq[MEMÓRIA][PROVA] #h(1.2em) #neq[OMISSÃO][NEGAÇÃO] #h(1.2em) #neq[NOME][IDENTIDADE] \
  #v(0.3em)
  #neq[RECIBO][EFEITO] #h(1.2em) #neq[FERRAMENTA][AUTORIDADE] #h(1.2em) #neq[CONTEXTO][COMANDO]
])

Uma distinção $X != Y$ não é uma afirmação de que $X$ e $Y$ nunca coincidem — às vezes coincidem. É uma afirmação de que a coincidência não pode ser _suposta_: precisa ser estabelecida, com evidência, em cada caso. Sempre que possível, cada distinção vem acompanhada de três coisas: o modo de falha que ela previne; um exemplo em que a confusão causou dano; e um teste ou salvaguarda que verifica se um sistema a preserva. O Apêndice E reúne o catálogo completo.

#exercicios[
  + Reescreva como distinções $X != Y$ cinco falhas de software que você já presenciou.
  + Para a distinção #neq[RECIBO][EFEITO], descreva um teste que verifique se um sistema a preserva.
  + A distinção #neq[CONTEXTO][COMANDO] parece contradizer a prática de colocar instruções no contexto do modelo. Explique por que não há contradição, distinguindo segmentos com funções diferentes.
]

== O exemplo-guia <sec-int-guia>

Um exemplo acompanha o livro inteiro. Um agente trabalha num ambiente com vários projetos, repositórios e serviços. O titular lhe pede:

#align(center, block(width: 88%, inset: 8pt, fill: cor.clara, radius: 2pt)[
  _"Qual é a fonte corrente do recurso $X$? Ela se aplica ao meu objetivo atual? Posso alterá-la?"_
])

A pergunta parece simples. Respondê-la corretamente exige responder, antes, uma série de perguntas que cada parte do livro torna precisas:

#figure(
  tabela(
    colunas: (auto, 1fr, auto),
    cabecalho: ([Pergunta], [Por que é difícil], [Onde]),
    [o que é $X$?], [o nome pode designar recursos diferentes; o mesmo recurso pode ter vários nomes], [@cap-identidade],
    [onde está $X$?], [pode haver várias cópias; a mais próxima pode não ser a canônica], [@cap-espacos, @cap-localizacao],
    [qual versão é "a corrente"?], [a mais recente, a aceita e a entregue podem ser diferentes], [@cap-tempo],
    [de onde vem essa informação?], [um relato não é uma observação ancorada], [@cap-proveniencia],
    [isso ainda é verdade?], [memória não é prova], [@cap-epistemologia, @cap-memoria],
    [aplica-se ao meu objetivo?], [aplicabilidade depende da coordenada], [@cap-modelo, @cap-relevancia],
    [o que o agente precisa ver?], [seleção sob orçamento, sem omitir em silêncio], [@cap-selecao, @cap-perspectiva],
    [como apresentar a resposta?], [sem promover desconhecidos nem negar por omissão], [@cap-apresentacao],
    [posso alterar?], [ter a ferramenta não é ter autoridade], [@cap-autoridade, @cap-portoes],
    [como alterar com segurança?], [o recibo não é o efeito], [@cap-ciclo-acao],
    [e se outro agente continuar?], [a transferência carrega a coordenada, não a conversa], [@cap-handoff],
  ),
  caption: [O exemplo-guia decomposto nas perguntas que o livro trata.],
) <tab-guia>

#quadro(titulo: [Vocabulário mínimo])[
  Alguns termos aparecem nos primeiros capítulos antes de sua definição completa:
  - _titular_: o humano com autoridade última sobre um domínio (@cap-autoridade);
  - _unidade de trabalho_: um trabalho com objetivo, ciclo de vida e evidência de conclusão (@cap-trabalho);
  - _portão_: uma decisão que só deixa uma ação prosseguir se suas pré-condições estão provadas (@cap-portoes);
  - _linha de base_, _candidato_ e _promoção_: a versão aceita, uma versão proposta e o ato que torna a segunda a primeira (@cap-trabalho);
  - _consumidor frio_: um consumidor sem memória específica do trabalho, usado para testar se o contexto basta (@cap-avaliacao);
  - _superfície_: um meio de entrega de contexto ou de operações — uma linha de comando, uma interface, um servidor de ferramentas (@cap-arquitetura).
]

Um agente sem disciplina de contexto responde à pergunta em segundos — e frequentemente erra: encontra a cópia mais próxima, lê a versão mais recente, conclui que se aplica porque o nome bate, e altera porque tem a ferramenta. Um agente com disciplina de contexto pode responder com a mesma rapidez, desde que o sistema que o serve tenha feito o trabalho descrito neste livro.

#exercicios[
  + Responda à pergunta do exemplo-guia para um recurso de um projeto seu, registrando, para cada linha da @tab-guia, a informação que você usou e de onde ela veio. Quantas respostas você teve de supor?
  + Acrescente à @tab-guia duas perguntas que o exemplo-guia esconde e que um agente cuidadoso também deveria responder. Em que parte do livro você esperaria encontrá-las?
  + Descreva a sequência de erros de um agente "sem disciplina de contexto" no exemplo-guia, desde encontrar a cópia mais próxima até alterar o recurso, e indique, para cada erro, qual invariante do livro ele viola.
]

== Mapa do livro e como lê-lo <sec-int-mapa>

O livro tem oito partes e oito apêndices.

- A *Parte I — Fundamentos* apresenta o problema (este capítulo), os modelos de linguagem como processadores de contexto (@cap-llm), o modelo formal que serve de espinha ao livro (@cap-modelo) e os fundamentos epistemológicos (@cap-epistemologia).
- A *Parte II — Gerenciamento* trata de identidade, domínios, localização, tempo, proveniência, durabilidade e memória.
- A *Parte III — Engenharia* trata de seleção, conjunto de trabalho, o núcleo de projeção, fronteira, compressão e compactação.
- A *Parte IV — Design* trata de relevância e divulgação, apresentação e entrada.
- A *Parte V — Administração* trata de autoridade, portões, o ciclo da ação, unidades de trabalho, reconciliação e higiene.
- A *Parte VI — Ambientes, execução, federação e segurança* trata do contexto em sistemas reais e distribuídos.
- A *Parte VII — Sistemas de agentes* trata de orquestração, transferência, arquitetura e observabilidade.
- A *Parte VIII — Avaliação e método* trata de como avaliar sistemas de contexto, do método empírico e dos problemas em aberto.

Os apêndices revisam a matemática (A), a lógica (B), a probabilidade e a teoria da informação (C) e os sistemas distribuídos (D) necessários, e reúnem o catálogo de invariantes (E), os procedimentos operacionais (F), modelos de pacotes (G) e um glossário português–inglês (H).

O Prefácio descreve trilhas de leitura para diferentes públicos. Em resumo: o leitor iniciante pode ler os Capítulos 1 a 4 e, depois, os capítulos de sua área de interesse, saltando as seções marcadas com ★; o leitor intermediário deve ler as Partes I a V em ordem; o leitor avançado encontrará nas seções ★, nos problemas de fim de capítulo e no @cap-abertos o material de pesquisa.

#quadro[
  - A maior parte das falhas de agentes vem do contexto: informação desatualizada, suposta, ausente, adversarial ou mal resumida.
  - O contexto se perde em níveis distintos — universo, ambiente, legível, aplicável, selecionado, entregue, consumido —, com causas e correções distintas; poder ver não é ter visto.
  - Janelas maiores, recuperação, memória, multiagentes e prompts melhores ajudam, mas não definem quando um contexto está certo.
  - Tese: contexto é projeção determinística, limitada por autoridade e epistemicamente honesta de um acervo governado, a partir de uma coordenada.
  - Quatro disciplinas: gerenciamento (acervo), engenharia (projeção), design (apresentação), administração (mudança); a acionabilidade está na interseção.
  - Invariantes de distinção $X != Y$: a coincidência nunca é suposta.
]

#problemas[
  #problema([Anatomia de uma transcrição])[
    Obtenha a transcrição de uma sessão de trabalho de um agente de programação (sua ou pública).
    + Marque cada decisão do agente e identifique a informação em que ela se baseou.
    + Para cada decisão errada, identifique em que nível da @fig-cadeia-informal a informação necessária se perdeu.
    + Proponha, para cada caso, uma correção no sistema de contexto (e não no modelo).
  ]
  #problema([Disciplinas ausentes])[
    Escolha um produto de software com funcionalidades de agentes.
    + Classifique suas funcionalidades de contexto nas quatro disciplinas.
    + Identifique a disciplina mais fraca e descreva o modo de falha característico que você esperaria observar.
    + Projete um teste que exponha esse modo de falha.
  ]
]

#notas[
  O termo "engenharia de contexto" ganhou circulação em 2025 para designar o trabalho de curar o que entra na janela de modelos usados como agentes @anthropic2025context; um levantamento amplo da área é o de #ct(<mei2025>). A degradação com o comprimento da entrada é documentada por #ct(<liu2024lost>) e #ct(<hong2025>), e a sensibilidade a informação irrelevante, por #ct(<shi2023>). A recuperação aumentada é de #ct(<lewis2020>); a memória hierárquica para modelos, de #ct(<packer2023>); os sistemas multiagentes de pesquisa, de #ct(<anthropic2025multiagent>). Para o conceito de agente em inteligência artificial, ver #ct(<russell2021>) e #ct(<wooldridge2009>).

  O caso que abre o capítulo generaliza uma falha recorrente de sistemas de orientação de agentes e motiva várias das distinções deste livro: entre existir, resolver, aplicar-se e ser selecionado; entre o cálculo da perspectiva e sua apresentação; e entre o que o sistema sabe e o que ele diz.
]
