#import "/modelo/estilo.typ": *

= Tempo, atualidade e frescor <cap-tempo>

#epigrafe(fonte: [Leslie Lamport, 1978])[O conceito de tempo é fundamental para a nossa maneira de pensar. Ele deriva do conceito mais básico da ordem em que os eventos ocorrem.]

"Está atualizado?" é talvez a pergunta mais frequente que um agente faz sobre o mundo, e uma das mais mal formuladas. Atualizado _em relação a quê_? A ponta do ramo, a versão aceita, a versão em execução, a última observação? _Para responder a que pergunta_? Uma observação de ontem é perfeitamente atual para saber se um repositório existe e inútil para saber qual revisão está em produção agora. E, num sistema distribuído, não existe sequer um "agora" global ao qual comparar.

Este capítulo dá forma precisa ao tempo no contexto de agentes. A @sec-tempo-pergunta mostra que "corrente" é uma pergunta, não um campo. A @sec-tempo-relogios distingue os relógios envolvidos em cada fato. A @sec-tempo-frescor define frescor condicionado à pergunta. A @sec-tempo-ordem apresenta a ordem causal, os relógios lógicos e vetoriais. A @sec-tempo-cortes trata de cortes consistentes e visões não atômicas. A @sec-tempo-honestidade discute a honestidade temporal: projetar o passado sem contaminá-lo com o presente.

== "Corrente" é uma pergunta <sec-tempo-pergunta>

Considere as afirmações que costumam ser resumidas por "o serviço está atualizado": a fonte contém a correção; a correção foi construída; o artefato foi implantado; o processo em execução usa o artefato novo; a versão foi aceita; a cópia local do ramo remoto está sincronizada; o ramo remoto foi consultado agora; a entrega chegou ao usuário; a observação que sustenta tudo isso é recente. São pelo menos nove afirmações independentes.

#definicao(titulo: [Dimensões de atualidade])[
  Uma _dimensão de atualidade_ é um par (sujeito, comparação) que define uma pergunta "o sujeito está atual em relação a esta referência?". Dimensões típicas incluem: fonte, construção, implantação, execução, candidato em desenvolvimento, prova (existe evidência sobre esta revisão?), promoção (é a aceita?), cópia local do remoto, remoto consultado agora, entrega, e frescor da própria observação.
] <def-dimensoes-atualidade>

#proposicao(titulo: [Um booleano não representa duas dimensões])[
  Se duas dimensões de atualidade $d_1, d_2$ são independentes — isto é, as quatro combinações de valores (atual/não atual) são possíveis —, nenhum campo booleano único "está atualizado" permite recuperar os dois valores. Em particular, qualquer decisão que dependa de $d_1$ e $d_2$ separadamente não pode ser tomada a partir do campo.
] <prop-booleano-atualidade>

#prova[
  Um campo booleano tem dois valores; as combinações possíveis são quatro. Pelo princípio da casa dos pombos, duas combinações distintas são mapeadas no mesmo valor do campo; uma decisão que as distinga não pode ser tomada a partir dele. (É um caso particular da @prop-colapso.)
]

#invariante(titulo: [Corrente é uma pergunta, não um campo])[
  Toda afirmação de atualidade declara seu sujeito, sua referência de comparação e a base da observação. Um campo "atual: sim/não" sem essas qualificações é um rótulo colapsado.
] <inv-corrente-pergunta>

#estudo-de-caso(titulo: [Três verdades simultâneas])[
  Um painel mostrava "serviço de execução: desatualizado". A investigação revelou três afirmações simultaneamente verdadeiras: a fonte estava atual (continha a correção); o artefato implantado estava atual (fora construído da fonte corrente); e o processo em execução estava desatualizado (fora iniciado antes da implantação e não recarregara). Além disso, a cópia local da máquina não estava disponível para consulta, mas a remota estava — e estar disponível não significava estar atual. O rótulo único escondia qual das ações era necessária: reiniciar o processo, e não reconstruir nem reimplantar.
] <caso-tres-verdades>

#exercicios[
  + Para a pergunta "posso promover a revisão $r$?", identifique quais dimensões de atualidade são relevantes e quais não são.
  + Reescreva o painel do @caso-tres-verdades com uma linha por dimensão.
  + Mostre, com um exemplo, a @prop-booleano-atualidade: duas observações com o mesmo valor do booleano "atual" que exigem decisões diferentes.
]

== Os relógios de um fato <sec-tempo-relogios>

Um único fato registrado no acervo envolve, em geral, vários instantes distintos.

#definicao(titulo: [Três relógios])[
  Para uma asserção $a$, distinguem-se: o _instante observado_ $t_"obs"(a)$, em que o fato foi medido no mundo; o _instante persistido_ $t_"per"(a)$, em que o registro foi gravado no acervo; e o _ponto de controle_ $t_"chk"(a)$, a marca da cadência de registro (sessão, ciclo, lote) a que o registro pertence.
] <def-tres-relogios>

#invariante(titulo: [Instante observado não é instante persistido])[
  Os três relógios não são inferíveis uns dos outros. Ordenar eventos do mundo pelo instante de gravação pode inverter a ordem real (uma observação antiga gravada tarde); atribuir a um fato o instante de seu ponto de controle esconde quando ele foi realmente medido.
] <inv-tres-relogios>

#exercicios[
  + Um agente observa o estado de um serviço às 10h00 e só grava o registro às 10h40, no ponto de controle de encerramento de sua sessão. Às 10h20, outro agente observou e gravou um estado diferente. Qual é a ordem correta dos fatos? Que ordem um sistema que usa o instante de gravação produziria?
  + Proponha os campos mínimos de tempo de uma asserção para que as perguntas de auditoria "quando foi verdade?" e "quando soubemos?" sejam respondíveis.
  + Uma observação foi persistida às 10h40 com instante observado 10h00, e outra foi persistida às 10h20 com instante observado 10h15. Qual delas é mais recente? Que erro cometeria um sistema que ordenasse pelo instante persistido?
]

== Frescor condicionado à pergunta <sec-tempo-frescor>

A política de validade do @cap-epistemologia (@def-atualidade) atribuía uma janela de validade a cada classe de predicado. Ela é um bom começo, mas ainda trata a atualidade como propriedade da observação. Na verdade, a mesma observação pode ser fresca o bastante para uma pergunta e insuficiente para outra.

#definicao(titulo: [Frescor condicionado])[
  O _frescor_ de uma observação $o$ para uma pergunta $q$, em comparação com uma referência $r$, é um valor de
  $ "Fresco"(o, r, q) in {#estado[suficiente], #estado[antiga mas responde], #estado[antiga e insuficiente], #est[desconhecido]}. $
  A relação factual "$o$ é anterior a $r$" é registrada separadamente da interpretação "$o$ não serve para $q$".
] <def-frescor-condicionado>

A política de validade do @cap-epistemologia (@def-atualidade) é um caso particular desta definição: quando a pergunta $q$ é "o valor de $p$ no presente" e o limiar de frescor é a janela $Delta_p$, uma observação #estado[atual] é #estado[suficiente], e uma #estado[vencida] é #estado[antiga e insuficiente]. Para perguntas sobre o passado, ou insensíveis ao tempo, a mesma observação vencida pode ser #estado[antiga mas responde].

#exemplo(titulo: [Uma observação, duas perguntas])[
  Uma observação de anteontem mostra que o repositório $R$ existe e contém o módulo $M$. Para a pergunta "o repositório existe?", ela é #estado[antiga mas responde]: repositórios raramente desaparecem, e sua existência é estável. Para a pergunta "qual revisão de $R$ está em produção agora?", ela é #estado[antiga e insuficiente]. A observação não mudou; a pergunta mudou.
] <ex-uma-observacao>

#invariante(titulo: [Antigo não é falso])[
  Uma observação desatualizada não é, por isso, refutada. Ela continua verdadeira como registro do passado e pode continuar respondendo a perguntas para as quais o tempo não importa. Descartar observações antigas verdadeiras é tão errado quanto tratá-las como atuais.
] <inv-antigo-falso>

#proposicao(titulo: [Remover observações não aumenta o frescor])[
  Seja $"Melhor"(O, q) = arg max {t_"obs" (o) : o in O, o "responde a" q}$ a observação mais recente, num conjunto $O$, que responde à pergunta $q$. Para todo $O' subset.eq O$, $t_"obs" ("Melhor"(O', q)) lt.eq t_"obs" ("Melhor"(O, q))$.
] <prop-remover-frescor>

#prova[
  O máximo de um conjunto de instantes é ao menos o máximo de qualquer subconjunto.
]

A proposição diz que apagar registros nunca torna a melhor resposta mais recente. Com suplantação, diz-se ainda mais: apagar a observação que suplanta outra faz a antiga voltar a parecer atual — a resposta fica mais _antiga_ e, além disso, errada.

#exercicios[
  + Classifique o frescor de uma observação de uma semana atrás sobre: (a) a licença de um repositório; (b) a lista de membros de uma equipe; (c) a revisão implantada de um serviço com implantações diárias.
  + Proponha uma função $"Fresco"$ para três classes de pergunta e discuta como aprendê-la a partir de dados.
  + Mostre que a @prop-remover-frescor vale para a definição de frescor condicionado da @def-frescor-condicionado e dê um exemplo de política de frescor que a viola.
]

== Ordem causal e relógios lógicos <sec-tempo-ordem>

Em sistemas distribuídos — e um ambiente de vários agentes, máquinas e serviços é um —, os relógios físicos não são confiáveis para ordenar eventos. O que se pode estabelecer com segurança é a _ordem causal_.

#definicao(titulo: [Aconteceu-antes])[
  Num sistema de processos que trocam mensagens, a relação _aconteceu-antes_ $->$ é a menor relação transitiva tal que: (i) se $a$ e $b$ ocorrem no mesmo processo e $a$ ocorre antes de $b$, então $a -> b$; (ii) se $a$ é o envio de uma mensagem e $b$ sua recepção, então $a -> b$. Eventos $a$ e $b$ são _concorrentes_ ($a parallel b$) se nem $a -> b$ nem $b -> a$.
] <def-aconteceu-antes>

Os _relógios lógicos_ de #ct(<lamport1978>) atribuem a cada evento um número $C(a)$ tal que $a -> b$ implica $C(a) < C(b)$ — mas não o contrário: números menores não implicam precedência causal. Os _relógios vetoriais_ @fidge1988 @mattern1989 resolvem essa limitação.

#definicao(titulo: [Relógio vetorial])[
  Num sistema com $n$ processos, cada processo $p_i$ mantém um vetor $V_i in bb(N)^n$, inicialmente nulo. Todo evento — interno, envio ou recepção — incrementa $V_i [i]$. Ao enviar uma mensagem, o processo primeiro incrementa e depois anexa $V_i$. Ao receber uma mensagem com vetor $W$, faz $V_i [j] <- max(V_i [j], W[j])$ para todo $j$ e então incrementa $V_i [i]$. O vetor de um evento é o valor de $V_i$ logo após o evento. Vetores são comparados componente a componente: $V lt.eq W$ se $V[j] lt.eq W[j]$ para todo $j$, e $V < W$ se $V lt.eq W$ e $V != W$.
] <def-relogio-vetorial>

#lema(titulo: [Contagem causal])[
  Para todo evento $e$ e todo processo $p_i$, $V(e)[i]$ é o número de eventos de $p_i$ que precedem causalmente $e$ ou são o próprio $e$.
] <lem-contagem-causal>

#prova[
  Por indução na ordem dos eventos do processo de $e$. Num evento interno ou de envio de $p_j$, a componente $j$ cresce de 1 (o próprio evento) e as demais não mudam, assim como o conjunto de eventos de outros processos que o precedem. Numa recepção, o máximo componente a componente com o vetor da mensagem acrescenta exatamente os eventos que precedem o envio, e o incremento conta a própria recepção.
]

#teorema(titulo: [Relógios vetoriais caracterizam a causalidade])[
  Para quaisquer eventos $a$ e $b$, $a -> b$ se e somente se $V(a) < V(b)$.
] <teo-relogio-vetorial>

#prova[
  (⇒) Por indução no comprimento da cadeia que estabelece $a -> b$. Num passo local, o processo incrementa sua própria componente, e as demais não diminuem, logo o vetor cresce estritamente. Num passo de mensagem, o receptor toma o máximo componente a componente com o vetor do envio e depois incrementa sua componente, logo o vetor da recepção é estritamente maior que o do envio. A transitividade de $<$ fecha a indução.

  (⇐) Suponha $V(a) < V(b)$, com $a$ no processo $p_i$. Pelo @lem-contagem-causal, $V(a)[i]$ é a posição de $a$ entre os eventos de $p_i$, e $V(b)[i] >= V(a)[i]$ significa que $b$ é precedido causalmente por (ou é) pelo menos $V(a)[i]$ eventos de $p_i$ — em particular, pelo evento de posição $V(a)[i]$, que é $a$. Como $V(a) != V(b)$, $b != a$; logo $a -> b$.
]

Para sistemas de contexto, o teorema tem uma leitura direta: se cada observação registrada carrega o vetor causal de quem a fez — o que ela "já tinha visto" —, é possível decidir, depois, se uma observação levou outra em conta ou se as duas foram concorrentes. Sem essa informação, duas observações contraditórias com instantes físicos próximos podem ser ordenadas de forma arbitrária.

#exercicios[
  + Calcule os relógios vetoriais de uma execução com três processos e quatro mensagens à sua escolha, e identifique um par de eventos concorrentes.
  + Mostre um exemplo em que relógios de Lamport atribuem $C(a) < C(b)$ a eventos concorrentes.
  + Proponha como anexar informação causal a observações de agentes que se comunicam por pacotes de transferência.
]

== Cortes consistentes e visões não atômicas <sec-tempo-cortes>

Uma visão do ambiente é composta de observações feitas em lugares e instantes diferentes. Quando ela é coerente?

#definicao(titulo: [Corte consistente])[
  Um _corte_ é um conjunto de eventos que contém, para cada processo, um prefixo de sua execução. Um corte $Z$ é _consistente_ se, para todo $b in Z$ e todo $a -> b$, também $a in Z$ — isto é, se ele não contém a recepção de uma mensagem sem conter seu envio.
] <def-corte-consistente>

#teorema(titulo: [Caracterização vetorial de cortes consistentes])[
  Seja $Z$ um corte cuja fronteira é formada pelos últimos eventos $e_1, dots, e_n$ de cada processo (com $e_i$ o evento inicial fictício quando $Z$ não contém eventos de $p_i$). $Z$ é consistente se e somente se, para todos $i, j$, $V(e_j)[i] lt.eq V(e_i)[i]$.
] <teo-corte-vetorial>

#prova[
  $V(e_j)[i]$ conta quantos eventos de $p_i$ precedem causalmente (ou são) $e_j$. Se $V(e_j)[i] > V(e_i)[i]$, então algum evento de $p_i$ posterior a $e_i$ — portanto fora de $Z$ — precede $e_j in Z$, e $Z$ não é consistente. Reciprocamente, se para todos $i, j$ vale $V(e_j)[i] lt.eq V(e_i)[i]$, todo evento de $p_i$ que precede algum evento de $Z$ é no máximo o $V(e_i)[i]$-ésimo de $p_i$, que está em $Z$; logo $Z$ é fechado para precedência.
]

O algoritmo de instantâneo distribuído de #ct(<chandy1985>) obtém, sem parar o sistema, um corte consistente — um "retrato" que poderia ter sido o estado global num instante, ainda que nenhum observador o tenha visto inteiro.

#invariante(titulo: [Não há instante atômico do ambiente])[
  Uma visão de ambiente composta de observações de vários planos e loci não é um retrato atômico do mundo num instante. Cada componente carrega seu próprio instante e sua própria base; a visão é uma composição não atômica, e só merece ser chamada de "estado em $t$" se for um corte consistente demonstrado.
] <inv-sem-instante-atomico>

Na prática, consistência global raramente é necessária. Basta que cada _pergunta_ declare de quais planos e componentes depende, e que esses componentes sejam suficientemente frescos para ela (@def-frescor-condicionado). Quando um plano está indisponível — o serviço de autoridade não responde —, o teorema CAP @gilbert2002 impede responder, sob partição, ao mesmo tempo com o valor mais recente e sempre com um valor. A escolha coerente com P4 é a de consistência: o sistema continua _respondendo_, mas responde #est[desconhecido] (com a razão "plano indisponível") em vez de um valor possivelmente desatualizado. Do ponto de vista do teorema, isso é sacrificar disponibilidade — recusar o valor —; do ponto de vista do consumidor, é preservar a honestidade.

#exercicios[
  + Verifique, pelo @teo-corte-vetorial, se o corte formado pelos terceiros eventos de cada processo, no exercício da seção anterior, é consistente.
  + Um painel compõe o estado de cinco serviços consultados sequencialmente ao longo de dez segundos. Em que condições essa composição pode apresentar um estado que nunca existiu? Dê um exemplo.
  + Proponha um protocolo para que um agente que consulta cinco serviços em sequência obtenha um corte consistente, ou, se isso não for possível, declare a visão como não atômica com a janela temporal correspondente.
]

== Honestidade temporal <sec-tempo-honestidade>

Uma pergunta frequente em auditoria e depuração é "o que o agente sabia quando decidiu?". Respondê-la exige projetar o acervo _como era_ num instante passado — sem contaminar a resposta com o que se sabe hoje.

#invariante(titulo: [Nunca reconstruir o passado com o presente])[
  Uma visão de um instante passado usa apenas asserções e regras de projeção daquele instante. Exibir o estado atual de um recurso como se fosse o estado de então — porque a observação antiga não foi retida — é falsificação temporal. Convergência presente não é certeza retroativa.
] <inv-passado-presente>

#definicao(titulo: [Inspetor temporal])[
  Um _inspetor temporal_ responde a perguntas sobre uma coordenada $(kappa, t)$ com um de três estados: #estado[exato], se o acervo, as regras de projeção e a coordenada daquele instante estão retidos e a perspectiva pôde ser recalculada; #estado[só metadados], se apenas parte foi retida (por exemplo, sabe-se qual revisão era a aceita, mas não seu conteúdo); #estado[não resolvido], se nem isso.
] <def-inspetor-temporal>

#proposicao(titulo: [Condição suficiente de reconstrução exata])[
  Se (i) o subconjunto de $Sigma_t$ lido pela projeção na coordenada do consumidor (seu _suporte de leitura_), (ii) a versão das regras de projeção e de renderização em uso em $t$, (iii) a coordenada em $t$ e (iv) o orçamento e o perfil de renderização estão retidos, então a perspectiva e o contexto renderizado em $t$ são reconstruíveis exatamente. A condição não é necessária: reter o próprio contexto renderizado basta para responder "o que o consumidor viu", embora não para responder "o que ele deveria ter visto".
] <prop-reconstrucao-exata>

#prova[
  Pelo axioma de determinismo (P2), a perspectiva é função do que a projeção lê, da coordenada e das regras; se todos estão retidos, recalcula-se. O contexto renderizado é função da perspectiva, do orçamento, do perfil e da versão de $rho$. Para a não necessidade, basta observar que o contexto retido responde diretamente à primeira pergunta.
]

A proposição liga este capítulo ao @cap-durabilidade: a capacidade de responder perguntas sobre o passado é uma questão de _retenção_, e precisa ser planejada — não é um subproduto automático de ter "guardado os logs".

#exercicios[
  + Um agente tomou uma decisão errada há duas semanas. Liste o que precisa estar retido para responder "o que ele viu?" com estado #estado[exato].
  + Explique por que mudar as regras de projeção (uma nova versão do sistema) pode tornar inexata a reconstrução de perspectivas passadas, mesmo com o acervo intacto.
  + Use o inspetor temporal (@def-inspetor-temporal) para descrever como responder: "o agente sabia, no momento da decisão, que a revisão $r$ tinha falhado nos testes?".
]

#quadro[
  - "Corrente" é uma pergunta com sujeito, comparação e base; um booleano não representa duas dimensões independentes.
  - Instante observado, persistido e ponto de controle são relógios distintos.
  - Frescor é condicionado à pergunta; antigo não é falso; remover observações não aumenta o frescor.
  - Relógios vetoriais caracterizam a causalidade (@teo-relogio-vetorial); cortes consistentes têm caracterização vetorial (@teo-corte-vetorial).
  - Não há instante atômico do ambiente; com plano indisponível, prefira #est[desconhecido] a valor inventado.
  - Nunca reconstrua o passado com o presente; reconstrução exata exige reter acervo, regras e coordenada.
]

#problemas[
  #problema([Axiomatizando o frescor])[
    Proponha axiomas para a função $"Fresco"$ da @def-frescor-condicionado.
    + Um axioma de monotonicidade temporal: uma observação mais recente do mesmo sujeito, pelo mesmo método, nunca é menos fresca para a mesma pergunta.
    + Um axioma de estabilidade: para perguntas sobre propriedades imutáveis, toda observação é suficiente.
    + Mostre que seus axiomas são consistentes exibindo um modelo, e discuta um caso que eles não decidem.
  ]
  #problema([Bitemporalidade])[
    Bancos de dados _bitemporais_ registram, para cada fato, o intervalo em que ele foi verdadeiro no mundo e o intervalo em que esteve registrado no banco.
    + Mapeie os três relógios da @def-tres-relogios para esse modelo.
    + Mostre como responder, num acervo bitemporal, a "o que sabíamos em $t_1$ sobre o estado em $t_0$?".
    + Discuta o custo de armazenamento e por que ele é aceitável para decisões de agentes auditáveis.
  ]
  #problema([Causalidade em transferências entre agentes])[
    Agentes trocam pacotes de transferência em vez de mensagens de baixo nível.
    + Proponha como atribuir relógios vetoriais a observações registradas por agentes que se comunicam por pacotes.
    + Mostre como detectar, com eles, que um relatório foi escrito sem conhecer uma observação anterior que o contradiz.
    + Discuta o tamanho dos vetores em sistemas com muitos agentes efêmeros e alternativas compactas.
  ]
]

#notas[
  A relação aconteceu-antes e os relógios lógicos são de #ct(<lamport1978>); os relógios vetoriais foram propostos independentemente por #ct(<fidge1988>) e #ct(<mattern1989>), e o algoritmo de instantâneo distribuído é de #ct(<chandy1985>). O teorema CAP, conjecturado por Brewer, foi demonstrado por #ct(<gilbert2002>); #ct(<vogels2009>) e #ct(<terry1994>) tratam de consistência eventual e de garantias de sessão, e #ct(<kleppmann2017>) oferece uma síntese didática. A linearizabilidade @herlihy1990 é a noção forte de consistência que, em geral, sistemas de contexto _não_ precisam garantir — basta que cada pergunta declare seus componentes e seu frescor.

  A multiplicidade de dimensões de atualidade, os três relógios, o frescor condicionado à pergunta e o inspetor temporal são propostas deste livro, motivadas pela confusão recorrente entre "a ponta do ramo", "a versão aceita" e "a versão em execução", e pela exibição do estado atual de recursos como se fosse o de semanas antes. A distinção entre o instante a que um fato se refere e o instante de seu registro é a dos bancos de dados bitemporais @snodgrass1999.
]
