#import "/modelo/estilo.typ": *

= Fundamentos epistemológicos: prova, memória e conhecimento <cap-epistemologia>

#epigrafe(fonte: [Máxima de autoria disputada])[A ausência de evidência não é evidência de ausência.]

Um agente que trabalha num ambiente real está permanentemente diante de três perguntas distintas, que a linguagem cotidiana mistura numa só. A primeira é _o que consigo demonstrar?_ — que afirmações posso sustentar com uma âncora verificável, aqui e agora. A segunda é _o que preciso lembrar?_ — que decisões, histórias e interpretações anteriores devo levar em conta para continuar raciocinando. A terceira é _no que acredito, afinal?_ — dado meu objetivo, o que posso demonstrar e o que lembro, qual é o estado efetivo das coisas. Chamamos as três de _prova_, _memória_ e _conhecimento_.

Este capítulo trata as três com cuidado, porque quase todas as falhas de contexto que um agente comete podem ser descritas como confusões entre elas: tomar memória por prova, apresentar conhecimento derivado como se fosse observação, ou ler ausência de prova como prova de ausência. A @sec-epi-lentes apresenta prova, memória e conhecimento como _lentes_ sobre o acervo — papéis epistêmicos, não tipos de objeto. A @sec-epi-estatutos aprofunda os estatutos epistêmicos e a hipótese de mundo aberto. A @sec-epi-atualidade trata do tempo: atualidade, validade e obsolescência. A @sec-epi-relacoes classifica relações segundo seu estatuto. A @sec-epi-memoria distingue memória corrente, histórica e arqueológica. A @sec-epi-conhecimento descreve o conhecimento como derivação. A @sec-epi-honestidade reúne regras práticas de honestidade epistêmica para agentes.

== Três lentes sobre o acervo <sec-epi-lentes>

#definicao(titulo: [Prova, memória e conhecimento])[
  Relativamente a um acervo $Sigma$ e a uma coordenada $kappa$:
  - _Prova_ é o conjunto das asserções de $Sigma$ que podem ser _demonstradas mecanicamente_ a partir de âncoras verificáveis acessíveis em $kappa$: revisões de código, resumos criptográficos de conteúdo, registros de execução, observações assinadas, identidades efetivamente resolvidas.
  - _Memória_ é o conjunto das asserções de $Sigma$ que o domínio _precisa lembrar para continuar raciocinando_: decisões e suas razões, itens de trabalho e sua história, interpretações anteriores, relações conhecidas, pendências e sementes de continuação. Memória pode estar desatualizada e não é prova.
  - _Conhecimento_ é o resultado de uma _derivação_: dado o objetivo de $kappa$, a prova, a memória e as observações correntes, o que se conclui ser o estado efetivo — acompanhado de proveniência, atualidade, contradições e desconhecidos. Conhecimento não é autoridade.
] <def-prova-memoria-conhecimento>

A definição foi escrita com cuidado para que nenhum dos três termos designe um _tipo de objeto_. Não existe um "nó de prova" ou uma "tabela de memória". Uma mesma asserção pode ser prova numa coordenada (porque sua âncora é verificável ali) e apenas memória noutra (porque, ali, a âncora não é acessível). Uma decisão registrada é memória; o registro de que foi tomada por quem tinha autoridade, com assinatura verificável, é prova de que foi tomada — mas não prova de que continua válida. Prova, memória e conhecimento são _papéis epistêmicos_ que asserções desempenham em relação a uma coordenada. Tratá-los como tipos de entidade introduziria uma metafísica desnecessária no acervo e, pior, convidaria a confundir o papel com o objeto.

As três lentes se relacionam de forma assimétrica, que convém guardar como princípio.

#principio(titulo: [Prova desafia memória; memória guia a prova; conhecimento se reconstrói de ambas])[
  Quando prova e memória divergem, a prova prevalece sobre o que a memória afirma a respeito do presente (a memória continua válida como registro do passado). A memória, por sua vez, é o melhor guia sobre _onde procurar_ prova. E o conhecimento não é guardado: é recalculado a partir de prova e memória sempre que a coordenada ou o acervo mudam.
] <pri-prova-memoria>

#figure(
  diagram(
    spacing: (18mm, 14mm),
    node-stroke: 0.6pt + cor.primaria,
    node-corner-radius: 2pt,
    node((1, 0), [*Conhecimento*\ #text(size: 8pt)[visão derivada corrente]], fill: cor.tinta-def, name: <k>),
    node((0, 1), [*Memória*\ #text(size: 8pt)[continuidade: decisões,\ história, pendências]], fill: cor.tinta-princ, name: <m>),
    node((2, 1), [*Prova*\ #text(size: 8pt)[âncoras: revisões, resumos,\ registros, observações]], fill: cor.tinta-inv, name: <p>),
    edge(<m>, <k>, "-|>", label: [contribui], label-side: left),
    edge(<p>, <k>, "-|>", label: [sustenta], label-side: right),
    edge(<p>, <m>, "-|>", bend: 18deg, label: text(size: 8pt)[desafia], label-side: left),
    edge(<m>, <p>, "-|>", bend: -48deg, label: text(size: 8pt)[indica onde procurar], label-side: right),
  ),
  caption: [As três lentes epistêmicas. O conhecimento é derivado; a prova desafia a memória; a memória orienta a busca de prova.],
) <fig-lentes>

#antipadrao(titulo: [Memória apresentada como prova])[
  Um agente inicia uma sessão lendo um resumo produzido por outro agente dias antes: "a versão em produção é a 2.3; os testes de integração passam". Sem reobservar, ele apresenta essas afirmações como estado atual e toma decisões com base nelas. O resumo era memória — uma afirmação relatada, sem âncora e com data — e foi promovido a prova pelo simples fato de estar no contexto: a força "declarado" foi apresentada como "medido", e a data foi omitida.
] <anti-memoria-como-prova>

O antipadrão não é impedido apenas pelo valor de Belnap — a asserção relatada pode, de fato, ter valor #est[provado], no sentido de que há suporte registrado e nenhum contra-suporte. O que ele viola é a _força_ e a _atualidade_ do suporte, que a @sec-epi-estatutos e a @sec-epi-atualidade tornam explícitas e que o axioma de honestidade (P4) proíbe exagerar.

#exercicios[
  + Classifique como prova, memória ou nenhuma das duas, numa coordenada em que o agente tem acesso de leitura ao repositório e ao sistema de integração contínua: (a) o resumo criptográfico da revisão atual do ramo principal; (b) uma nota "decidimos não suportar a versão 1 da API"; (c) o registro completo da última execução de testes; (d) a afirmação, num resumo de sessão, de que os testes passaram. Como muda a classificação se o agente perder acesso ao sistema de integração contínua?
  + Explique por que tratar "prova", "memória" e "conhecimento" como tipos de objeto, com tabelas próprias, levaria a duplicação e inconsistência.
  + Dê um exemplo em que a memória é indispensável para encontrar a prova, e outro em que confiar na memória impede de encontrá-la.
]

== Estatutos epistêmicos e o mundo aberto <sec-epi-estatutos>

O @cap-modelo definiu os estatutos #est[desconhecido], #est[provado], #est[refutado] e #est[conflitante], ordenados pela ordem de informação do bireticulado de Belnap. Esta seção examina o que cada um significa operacionalmente e que erros sua confusão produz.

=== Não provado não é refutado

O erro mais frequente é ler a ausência de prova como prova do contrário. Um agente que não encontrou o registro de execução dos testes não sabe que eles falharam; sabe apenas que não sabe se passaram. Na linguagem do @cap-modelo, a asserção "os testes passaram" tem estatuto #est[desconhecido], não #est[refutado].

#invariante(titulo: [Ausência não é negação])[
  Salvo declaração explícita e fundamentada de completude, a ausência de uma asserção no acervo, ou a impossibilidade de prová-la na coordenada corrente, é tratada como #est[desconhecido]. Nenhuma decisão que exija #est[refutado] pode ser tomada com base em ausência.
] <inv-ausencia-negacao>

#observacao(titulo: [Ausência de evidência como evidência fraca])[
  A máxima da epígrafe precisa de uma qualificação. Seja $H$ a hipótese "o registro existe" e $N$ o evento "uma busca não o encontrou". Se a busca encontra o registro, quando ele existe, com probabilidade $d$ (sua _probabilidade de detecção_), então
  $ Pr(H | N) = ((1 - d) Pr(H)) / ((1 - d) Pr(H) + 1 - Pr(H)) < Pr(H) "sempre que" d > 0. $
  Ausência de evidência é, portanto, evidência _fraca_ de ausência, e sua força cresce com $d$. A declaração de completude corresponde ao caso limite $d = 1$; o escopo da negação (@lem-escopo-negacao) corresponde a $d = 0$ fora dos loci examinados. Nos extremos, a conclusão é lógica; entre eles, é probabilística e deve ser apresentada como tal — nunca como #est[refutado].
]

A exceção — "salvo declaração explícita de completude" — corresponde aos domínios em que a hipótese de mundo fechado é legítima (@sec-ap-mundo-fechado). Num registro de autorizações projetado de modo que nenhuma autorização exista fora dele, a ausência de uma autorização é, de fato, negação. A completude é, então, ela mesma uma asserção do acervo, com proveniência: "o registro $R$ é completo para o predicado $p$ no domínio $D$". A literatura de bancos de dados chama isso de _completude local_ @motro1989 @levy1996.

#proposicao(titulo: [Negação sob completude local])[
  Se o acervo contém a declaração vigente "$R$ é completo para $p$ no domínio $D$" e $x in D$, então a ausência de $(x, p, y)$ em $R$ sustenta $(x, p, y)$ com estatuto #est[refutado]; para $x in.not D$, a ausência sustenta apenas #est[desconhecido].
] <prop-completude-local>

#prova[
  Para $x in D$, a declaração de completude afirma que toda tupla verdadeira $(x, p, y)$ está em $R$; a ausência contrapõe-se, portanto, a $(x, p, y)$. Para $x in.not D$, a declaração não diz nada, e vale o @inv-ausencia-negacao.
]

=== Provado em quê, por quem, quando

Um estatuto #est[provado] sem qualificação é quase sempre um exagero. O que se prova é sempre relativo:

- a uma _âncora_: provado _por_ um registro, um resumo criptográfico, uma observação;
- a um _locus_: provado _no_ espaço de trabalho, máquina ou serviço onde a observação foi feita;
- a um _instante_: provado _em_ $t_"obs"$;
- a um _escopo_: provado para _esta_ revisão, _esta_ configuração, _este_ conjunto de testes.

#definicao(titulo: [Afirmação qualificada])[
  Uma _afirmação qualificada_ é uma asserção acompanhada do quádruplo (âncora, locus, instante, escopo) que delimita sua prova. Duas afirmações com o mesmo conteúdo e qualificações diferentes são afirmações diferentes.
] <def-afirmacao-qualificada>

#exemplo(titulo: [O mesmo "passou", três afirmações])[
  "Os testes passaram" pode significar: (a) os testes unitários passaram na revisão $r$, na máquina do desenvolvedor, ontem; (b) a suíte completa passou na revisão $r$, no servidor de integração, há uma hora; (c) a suíte completa passou na revisão $r'$, que difere de $r$ por uma alteração de configuração. Um portão de promoção (@cap-portoes) que exige "testes passaram" precisa saber de qual dessas afirmações se trata; (a) e (c) não sustentam a promoção de $r$ a produção.
] <ex-tres-passou>

=== Estatuto composto: valor, força e base

O estatuto de Belnap diz _o que_ se sabe sobre uma asserção — se ela tem suporte, contra-suporte, ambos ou nenhum. Não diz _com que força_ nem _por que meio_. Duas asserções #est[provado] podem ter suportes muito diferentes: uma, um teste executado agora no ambiente alvo; outra, uma declaração de um colaborador registrada na semana passada.

#definicao(titulo: [Estatuto composto])[
  O _estatuto composto_ de uma asserção é a tripla $(v, f, b)$ em que $v$ é o valor no reticulado de Belnap; $f$ é a _força do suporte_, numa escala como
  $ "demonstrado" > "medido" > "observado" > "declarado" > "inferido" $
  — respectivamente: demonstrado por procedimento verificável; medido por instrumento; observado diretamente sem medição formal; declarado por uma fonte sem âncora; inferido por um consumidor sem regra explícita —; e $b$ é a _base_, isto é, o conjunto de âncoras e regras que sustentam $f$. A força de uma asserção _derivada_ por regra é a menor força entre suas premissas.
] <def-estatuto-composto>

A força não é um quinto valor de verdade (@sec-modelo-aplicabilidade): uma asserção declarada continua tendo valor #est[provado] se a declaração é o seu único suporte, mas um portão pode exigir força mínima "medido" e, então, recusá-la. Para evitar a ambiguidade entre o valor #est[provado] ("há suporte") e o topo da escala de força ("demonstrado por procedimento verificável"), os dois recebem nomes diferentes. Se a escala de força é uma ordem total ou apenas parcial — uma medição num ambiente compara-se a uma prova noutro? — é um dos problemas em aberto do @cap-abertos.

=== Desconhecido explicado

Um #est[desconhecido] nu é pouco útil: o consumidor não sabe se deve esperar, perguntar, investigar ou desistir. A honestidade epistêmica exige mais.

#principio(titulo: [Todo desconhecido é explicado])[
  Cada desconhecido que entra numa perspectiva traz três informações: a _razão_ (por que não se sabe: não observado, fonte indisponível, conflito, fora do teto de autoridade, fora do escopo), o _dono_ (quem pode resolvê-lo) e o _caminho_ (que observação, expansão ou decisão o resolveria). Um desconhecido explicado é acionável; um desconhecido nu é apenas uma lacuna.
] <pri-desconhecido-explicado>

=== Conflito como fato

Quando duas fontes sustentam afirmações incompatíveis, o estatuto correto é #est[conflitante]. Há uma condição para que haja conflito: as afirmações precisam ser _sobre o mesmo conteúdo_, ou ligadas por uma restrição. "A versão em produção é a 2.3" e "a versão em produção é a 2.4" são conteúdos diferentes; só entram em conflito porque o predicado "versão em produção" é _funcional_ — no máximo um objeto por sujeito e instante. Com a restrição declarada, o suporte de uma é contra-suporte da outra, e ambas passam a #est[conflitante]; sem ela, o acervo teria duas asserções #est[provado] e nenhum conflito. É o papel das restrições de integridade dos bancos de dados. É tentador resolver o conflito silenciosamente — escolher a fonte mais recente, a mais confiável ou a que favorece a ação pretendida. A @prop-ap-belnap-semirreticulado mostra por que registrar o conflito é a escolha algebricamente correta: a combinação de relatos pelo supremo de informação independe da ordem de chegada, enquanto "a mais recente vence" não. Resolver o conflito é uma _ação_ — com autoridade, evidência e registro —, não um efeito colateral da leitura.

#exercicios[
  + Reescreva cada uma das afirmações a seguir como afirmação qualificada, inventando qualificações plausíveis: "o serviço está saudável"; "a migração foi aplicada"; "o usuário aprovou a mudança".
  + Um agente não encontra, no repositório, nenhum arquivo de configuração que habilite um recurso. Sob que condições ele pode concluir que o recurso está desabilitado?
  + Duas fontes informam versões diferentes de um componente em produção. Descreva o que deve aparecer na perspectiva de um agente que precisa decidir se aplica uma correção.
  + Atribua um estatuto composto $(v, f, b)$ a cada uma das afirmações: "o teste $T$ passou" (com registro anexo); "o titular aprovou a mudança" (relatado por um agente); "a configuração $C$ está ativa" (deduzida da revisão implantada).
  + Para cada razão de desconhecimento do @pri-desconhecido-explicado, dê o dono e o caminho típicos num sistema de agentes de programação.
]

== Atualidade, validade e obsolescência <sec-epi-atualidade>

Uma asserção provada ontem pode ser falsa hoje. A dimensão temporal do conhecimento é tratada separadamente do estatuto porque ela tem dinâmica própria: estatutos mudam por novas observações; a atualidade muda pela simples passagem do tempo.

#definicao(titulo: [Política de validade e atualidade])[
  Uma _política de validade_ associa a cada classe de predicados uma janela de validade $Delta_p$ — o intervalo durante o qual uma observação de $p$ pode ser considerada representativa do presente. A _atualidade_ de uma asserção $a$ com predicado $p$, observada em $t_"obs"$, no instante $t$, é
  $ "atual"(a, t) = cases(
    #estado[atual] & "se" t - t_"obs" lt.eq Delta_p "e nenhuma asserção posterior a suplanta",
    #estado[suplantada] & "se uma asserção posterior a revoga ou corrige",
    #estado[vencida] & "caso contrário".
  ) $
] <def-atualidade>

Janelas de validade variam por ordens de grandeza. O identificador imutável de uma revisão de código tem validade infinita: uma vez que se sabe que $r$ contém um arquivo com certo conteúdo, isso nunca deixa de ser verdade. O estado de execução de um processo tem validade de segundos ou minutos. A configuração efetiva de um serviço tem validade até a próxima implantação. Tratar todas as asserções com a mesma validade é um erro em qualquer direção: validade curta demais obriga a reobservar o imutável; validade longa demais apresenta o volátil como atual.

#principio(titulo: [Identificadores imutáveis como âncoras de longo prazo])[
  Prefira ancorar afirmações em identificadores imutáveis (revisões, resumos de conteúdo, versões) em vez de nomes mutáveis (ramos, rótulos "mais recente", caminhos). Uma afirmação sobre "o ramo principal" vence na próxima integração; uma afirmação sobre a revisão $r$ do ramo principal vale para sempre — embora a afirmação "$r$ é a ponta do ramo principal" vença.
] <pri-imutavel>

=== Obsolescência também precisa de prova

Declarar uma asserção obsoleta é, ela mesma, uma afirmação. A tentação de rotular como "velho" ou "abandonado" tudo o que parece estranho é tão perigosa quanto a de tratar tudo como atual.

#invariante(titulo: [Estranho não é obsoleto])[
  Um item que parece desconectado do trabalho corrente — um ponteiro de "trabalho ativo" que aponta para algo inesperado, um ramo sem atividade recente, um diretório que ninguém parece usar — não é, por isso, obsoleto, abandonado ou descartável. Antes de classificá-lo, é preciso descobrir a razão mecânica e histórica de sua existência.
] <inv-estranho-obsoleto>

#estudo-de-caso(titulo: [O ponteiro estranho])[
  Numa auditoria do estado de um ambiente de desenvolvimento, um agente encontrou um ponteiro de "trabalho ativo" apontando para um item vazio, sem relação aparente com os objetivos correntes, enquanto vários outros itens de trabalho estavam abertos. A recomendação inicial foi classificar o item como obsoleto e redirecionar o ponteiro. Um revisor objetou: o relatório provava que o ponteiro existia e que _parecia_ desconectado; não provava _por que_ continuava ali. A distinção levou a duas formulações separadas: "ponteiro ativo não é objetivo corrente pretendido" (o que estava provado) e "ponteiro estranho não é ponteiro obsoleto" (o que impedia a conclusão apressada). A investigação subsequente mostrou que o ponteiro era resíduo de uma convenção antiga de nomeação, que fazia um mecanismo automático selecioná-lo; corrigir o mecanismo, e não apenas o ponteiro, eliminou uma classe inteira de seleções erradas.
] <caso-ponteiro-estranho>

=== Trabalhos que "parecem abandonados"

O mesmo raciocínio vale para artefatos de trabalho — ramos, cópias de trabalho, registros de experimentos. Um artefato pode conter trabalho ativo, um candidato comprovado ainda não promovido, um candidato aguardando promoção, uma retenção deliberada de bytes para recuperação, trabalho já integrado ou trabalho genuinamente superado. A aparência é a mesma; as disposições corretas são opostas. O @cap-higiene desenvolve uma taxonomia dessas disposições e um procedimento para decidi-las com evidência.

#exercicios[
  + Proponha janelas de validade para: a lista de processos em execução numa máquina; o conteúdo de um arquivo numa revisão identificada por resumo criptográfico; a lista de membros de uma equipe; a configuração de permissões de um repositório. Justifique.
  + Mostre que, se a validade de $p$ é $Delta_p = infinity$ e $a$ nunca é suplantada, então $a$ permanece #estado[atual] para sempre. Que propriedade do predicado justifica $Delta_p = infinity$?
  + Descreva um procedimento para decidir se um ramo de código sem atividade há três meses pode ser removido. Que perguntas ele precisa responder, e com que evidência?
]

== Relações e seu estatuto <sec-epi-relacoes>

Relações merecem atenção especial porque são o tipo de asserção mais fácil de _inventar_. Dois itens com nomes parecidos, tratando de assuntos próximos, produzidos na mesma semana, parecem relacionados; um modelo de linguagem, treinado para encontrar padrões, será o primeiro a sugerir a ligação. Mas semelhança não é relação.

#definicao(titulo: [Classificação de relações])[
  Dada uma pergunta "existe uma relação do tipo $p$ entre $x$ e $y$?", a resposta é classificada em uma de cinco categorias:
  + _Provada_: existe no acervo uma aresta tipada $(x, p, y)$ com proveniência que a sustenta (ou um caminho de arestas provadas cuja composição implica $p$).
  + _Implícita não representada_: há evidência de que a relação existe — por exemplo, ela pode ser reconstruída a partir de outros fatos —, mas nenhuma aresta a representa.
  + _Somente semelhança_: há semelhança semântica (de nomes, temas, épocas), mas nenhuma evidência de relação governada.
  + _Somente histórica_: a relação existiu e foi registrada, mas foi suplantada.
  + _Ausente_: nenhuma evidência de relação; o estatuto é #est[desconhecido] ou, sob completude declarada, #est[refutado].
] <def-classificacao-relacoes>

#algoritmo("Classifica-Relação", params: $Sigma, x, p, y$, legenda: [Classificação de uma relação candidata. A ordem dos testes importa: só se declara semelhança depois de esgotar as formas de prova.])[
  + #kw[se] existe aresta $(x, p, y)$ atual em $Sigma$ com proveniência válida #kw[então] #kw[devolva] #est[provada] com o caminho
  + #kw[se] existe caminho de arestas provadas cuja composição implica $p$ #kw[então] #kw[devolva] #est[provada] com o caminho composto
  + #kw[se] existe aresta $(x, p, y)$ vencida e não suplantada #kw[então] #kw[devolva] #est[provada], #estado[vencida], com a aresta e sua idade
  + #kw[se] existe aresta $(x, p, y)$ suplantada #kw[então] #kw[devolva] #estado[somente histórica] com a aresta e quem a suplantou
  + #kw[se] a relação pode ser reconstruída a partir de outras asserções de $Sigma$ #kw[então] #kw[devolva] #estado[implícita não representada] com a reconstrução
  + #kw[se] há completude declarada para $p$ cobrindo $x$ #kw[então] #kw[devolva] #estado[ausente] com estatuto #est[refutado] #h(1fr) ▷ @prop-completude-local
  + #kw[se] $x$ e $y$ são semanticamente semelhantes #kw[então] #kw[devolva] #estado[somente semelhança]
  + #kw[devolva] #estado[ausente] com estatuto #est[desconhecido]
] <alg-classifica-relacao>

A "reconstrução" da linha 5 é a derivação por regras do @cap-perspectiva; seu custo depende da álgebra de composição de tipos — consultas de caminho regulares são polinomiais — e domina o custo do algoritmo.

O valor do procedimento está menos nos testes do que na _recusa_ que ele impõe: em nenhum ponto a semelhança é promovida a relação. E dois de seus resultados merecem destaque.

O resultado "implícita não representada" é um _achado de gerenciamento_: significa que o acervo sabe o suficiente para reconstruir a relação, mas não a registra — e, portanto, nenhuma projeção conseguirá apresentá-la diretamente. É o caso típico em que "a verdade existe, um humano consegue reconstruí-la, um agente sem histórico às vezes consegue, mas o sistema não consegue projetar a aresta". A ausência da aresta é evidência de uma lacuna de descoberta, e o remédio é registrá-la — não fingir que já estava lá.

O resultado "somente semelhança" é, igualmente, uma informação valiosa. Quando se procura uma ligação entre dois trabalhos e se descobre que eles apenas compartilham conceitos, sem dependência demonstrável, a conclusão correta é registrar exatamente isso. Uma ligação inventada contaminaria todas as perspectivas futuras.

#principio(titulo: [Prefira a relação ausente à relação inventada])[
  Quando a evidência não sustenta uma relação, registre a ausência (ou a mera semelhança) em vez de criar a aresta. Uma relação ausente pode ser descoberta depois; uma relação inventada é difícil de remover, porque passa a sustentar raciocínios que parecem independentes.
] <pri-relacao-ausente>

#estudo-de-caso(titulo: [Dois trabalhos que pareciam ligados])[
  Uma equipe suspeitava que uma sequência de trabalhos sobre a estrutura de perspectivas de um sistema estava ligada a um trabalho posterior sobre um fluxo de cliente. Em vez de instruir um agente a "ligar" os trabalhos, o titular pediu que ele tentasse _resolver_ a relação, com quatro respostas possíveis: provada (expor o caminho tipado), implícita não representada, somente semelhança ou somente histórica. O agente encontrou que os trabalhos compartilhavam primitivas, que ambos podiam ser reconstruídos a partir do acervo, mas que não havia aresta explícita nem caminho transitivo completo entre eles. A conclusão registrada foi "relação ausente; primitivas compartilhadas". Em seguida, em vez de criar a aresta, a equipe abriu um experimento que _observava_ ambos os trabalhos como casos de teste — uma relação nova, verdadeira e tipada ("o experimento observa $A$" e "o experimento observa $B$"), que não afirmava dependência entre $A$ e $B$.
] <caso-trabalhos-ligados>

#exercicios[
  + Aplique o @alg-classifica-relacao a três pares de itens de um projeto que você conheça. Algum resultado foi "implícita não representada"? Que aresta deveria ser registrada, e quem deveria registrá-la?
  + Por que o teste de semelhança semântica vem _depois_ do teste de reconstrução? Dê um exemplo em que inverter a ordem levaria a um erro.
  + Mostre que, se toda aresta registrada tem proveniência válida, a composição de tipos é correta, as âncoras são verdadeiras e as janelas de validade são corretas (toda aresta atual é verdadeira no mundo), o @alg-classifica-relacao nunca classifica como #est[provada] e atual uma relação inexistente no mundo. Que hipótese falha para arestas vencidas?
]

== Memória corrente, histórica e arqueológica <sec-epi-memoria>

Acervos envelhecem. Um acervo usado por meses ou anos acumula itens de trabalho encerrados e abandonados, decisões superadas, ponteiros que já não apontam para nada, relações escritas em convenções antigas. Esse material tem valor — é a história do domínio — mas não é verdade corrente.

#definicao(titulo: [Camadas de memória])[
  A memória de um domínio divide-se em três camadas:
  - _Memória corrente_: asserções que participam das perspectivas atuais, com donos semânticos definidos e atualidade controlada.
  - _Memória histórica_: asserções suplantadas, mas preservadas e ligadas às que as suplantaram, de modo que a história possa ser percorrida.
  - _Memória arqueológica_: material antigo cujo estatuto atual não foi estabelecido — pode conter verdades, obsolescências, contradições e convenções esquecidas. É preservado integralmente e consultado apenas por expansão explícita.
] <def-camadas-memoria>

A distinção importa sobretudo quando se reorganiza um domínio. Diante de um acervo antigo e desordenado, há duas tentações opostas: tratar tudo como verdade corrente (e herdar suas contradições) ou "normalizar" tudo (e destruir sua proveniência). A disciplina correta é estabelecer uma _fronteira_.

#algoritmo("Estabelece-Linha-de-Base", params: $Sigma_"antigo"$, legenda: [Separação entre memória arqueológica e linha de base corrente, sem destruir história.])[
  + preserve $Sigma_"antigo"$ integralmente, marcado como #estado[arqueológico]
  + #kw[para cada] ponteiro de aplicabilidade (trabalho ativo, seleção corrente) em $Sigma_"antigo"$ #kw[faça]
    + classifique-o com evidência: corrente, histórico ou desconhecido
    + #kw[se] for histórico #kw[então] registre uma asserção que suplanta sua aplicabilidade corrente, preservando o item
    + #kw[se] for desconhecido #kw[então] mantenha a aplicabilidade como $sans(D)$ e registre um desconhecido explicado (@pri-desconhecido-explicado)
  + construa a linha de base corrente: identidades resolvidas, catálogo de recursos, observações atuais, âncoras de prova, referências de memória, desconhecidos
  + #kw[para cada] item corrente que tenha antecedente arqueológico #kw[faça]
    + registre a ligação "deriva de" ou "suplanta", com proveniência
  + #kw[devolva] a linha de base, com a memória arqueológica acessível apenas por expansão
] <alg-linha-de-base>

As linhas 4 e 5 do algoritmo são as mais sutis. Não se apagam itens antigos: registra-se, por acréscimo, que deixaram de ser aplicáveis — e só quando há evidência de que são históricos. Um ponteiro de estatuto desconhecido mantém aplicabilidade indeterminada, porque retirá-la seria decidir por ausência de evidência (@inv-ausencia-negacao) e reproduziria o erro do caso que abre o livro. Um item de trabalho antigo continua existindo, com toda a sua história; apenas deixa de ser selecionável como trabalho ativo. Isso preserva a distinção entre "item histórico" e "objetivo corrente".

=== Absorção semântica não é conclusão histórica

Um caso especialmente instrutivo ocorre quando o _objetivo_ de um trabalho antigo é atingido por outro caminho. Um item de trabalho foi aberto para implementar uma capacidade; foi interrompido e estacionado; mais tarde, a capacidade foi implementada como parte de outro trabalho. O que dizer do item antigo?

#invariante(titulo: [Absorção semântica não é conclusão histórica])[
  Se o objetivo de um trabalho foi atingido por outro caminho, o sistema pode registrar que o objetivo foi _absorvido_ — indicando onde e como —, mas não pode registrar que o trabalho original foi _concluído_. O ciclo de vida histórico do item (estacionado, abandonado, superado) permanece verdadeiro, e a conclusão não é reivindicada.
] <inv-absorcao>

O invariante evita uma falsificação sutil da história: "fechar" retroativamente um trabalho como concluído porque seu objetivo foi atendido apagaria a informação de que ele foi interrompido, de que outro caminho foi escolhido e de por quê. Esse tipo de informação é precisamente o que a _trajetória_ (@cap-memoria) precisa preservar.

#exercicios[
  + Um acervo antigo contém 300 itens de trabalho, dos quais 40 estão marcados como "abertos". Descreva como aplicar o @alg-linha-de-base sem examinar individualmente os 260 itens fechados.
  + Explique por que o @alg-linha-de-base remove aplicabilidade em vez de remover itens. Que perguntas de auditoria seriam impossíveis de responder se os itens fossem removidos?
  + Dê um exemplo de absorção semântica em um projeto real ou imaginário e escreva as asserções que deveriam ser registradas.
]

== Conhecimento como derivação <sec-epi-conhecimento>

Se prova é ancorada e memória é registrada, conhecimento é _calculado_. Formalmente, ele é a parte da perspectiva que resulta de inferência sobre prova e memória, sob o objetivo da coordenada.

#definicao(titulo: [Derivação de conhecimento])[
  Uma _derivação_ é um procedimento que, dados a prova $Pi_kappa$, a memória $M_kappa$ e as observações correntes $O_kappa$, produz um conjunto de _conclusões_, cada uma acompanhada de (i) seu conjunto $cal(J)(k)$ de _justificações_ — cada justificação $J in cal(J)(k)$ é um conjunto de asserções e conclusões que, em conjunto, sustenta $k$ —, (ii) seu estatuto, (iii) sua atualidade, calculada como $max_(J in cal(J)(k)) min_(x in J) "atual"(x)$ na ordem #estado[atual] > #estado[vencida] > #estado[suplantada], e (iv) as contradições e desconhecidos que a afetam.
] <def-derivacao>

A condição (iii) é uma regra simples e frequentemente esquecida: uma conclusão não é mais atual do que a premissa menos atual de sua melhor justificação. Se uma conclusão depende de uma observação vencida, ela está vencida, ainda que tenha sido calculada há um segundo.

#teorema(titulo: [Retratação por justificação])[
  Suponha que toda conclusão $k$ registre um conjunto finito $cal(J)(k)$ de justificações _monotônicas_ e que o grafo de dependência — que liga cada conclusão aos elementos de suas justificações — seja acíclico. Quando uma asserção $a$ deixa de vigorar: (i) toda conclusão que perde suporte pertence ao conjunto $"Af"(a)$ das conclusões que alcançam $a$ no grafo; (ii) $"Af"(a)$ é obtido em tempo linear no tamanho do subgrafo que ele induz; (iii) uma conclusão $k in "Af"(a)$ perde suporte se e somente se nenhuma $J in cal(J)(k)$ tem todos os elementos ainda vigentes, o que se decide reavaliando $"Af"(a)$ em ordem topológica, com custo $O(sum_(k in "Af"(a)) sum_(J in cal(J)(k)) |J|)$.
] <teo-retratacao>

#prova[
  (i) Se $k$ perde suporte, toda $J in cal(J)(k)$ contém um elemento que deixou de vigorar; por indução na ordem topológica, esse elemento é $a$ ou uma conclusão que perdeu suporte e, portanto, alcança $a$. (ii) $"Af"(a)$ é o conjunto alcançável a partir de $a$ no grafo reverso, obtido por busca em largura ou profundidade. (iii) Pela monotonicidade, a vigência de $k$ depende apenas das vigências dos elementos de suas justificações; processando $"Af"(a)$ em ordem topológica, cada elemento de cada $J$ já tem sua vigência final quando $k$ é avaliada.
]

O conjunto $"Af"(a)$ é, em geral, maior que o das conclusões que de fato caem: uma conclusão com uma justificação alternativa intacta sobrevive à revogação de $a$. Duas hipóteses do teorema merecem nota. A _aciclicidade_ não é automática — ciclos de suporte ("$A$ porque $B$, $B$ porque $A$") são o problema clássico de bem-fundação dos sistemas de manutenção da verdade — e precisa ser garantida pela derivação. E a _monotonicidade_ exclui justificações por omissão ("pronto, se nenhum conflito é conhecido"): com elas, revogar $a$ pode tornar vigentes conclusões novas, e o problema passa a ser o de rotulagem bem-fundada de #ct(<doyle1979>).

O teorema é a versão, para contexto, da ideia dos sistemas de manutenção da verdade @doyle1979 @dekleer1986: guardar justificações torna a retratação barata e localizada. Sem justificações, a única forma segura de lidar com uma revogação é recalcular tudo — ou, como acontece com frequência, não fazer nada e conviver com conclusões órfãs.

#invariante(titulo: [Conhecimento não é autoridade])[
  Uma conclusão derivada, por mais bem justificada que seja, não autoriza ação. Ela pode sustentar a _proposta_ de uma ação, que será submetida aos portões de autorização com a evidência correspondente.
] <inv-conhecimento-autoridade>

#exercicios[
  + Uma conclusão depende de três asserções com atualidades #estado[atual], #estado[atual] e #estado[vencida]. Qual a atualidade da conclusão? Por quê?
  + Mostre um exemplo em que a conclusão "o sistema está pronto para promoção" depende transitivamente de uma observação que acaba de ser revogada. Use o @teo-retratacao para descrever o que precisa ser recalculado.
  + #avancado Compare a retratação por justificação com a contração AGM (@sec-ap-agm). Em que situações a primeira é uma implementação da segunda?
]

== Honestidade epistêmica na prática <sec-epi-honestidade>

Os conceitos deste capítulo resultam num pequeno conjunto de regras de conduta que se aplicam a qualquer agente — humano ou artificial — que relate o estado de um sistema. Elas são simples de enunciar e difíceis de seguir sob pressão.

#principio(titulo: [Regras de honestidade epistêmica])[
  + _Qualifique toda afirmação de estado_: âncora, locus, instante e escopo.
  + _Distinga o observado do lembrado e do inferido_: diga qual é qual.
  + _Prefira #est[desconhecido] a uma conjectura_: quando não puder provar, diga que não pôde, e diga o que seria preciso para provar.
  + _Não reivindique o que não fez_: absorção não é conclusão; preparação não é execução; tentativa não é sucesso.
  + _Reconcilie seus próprios números_: contagens, listas e totais de um relatório devem ser coerentes entre si.
  + _Registre os conflitos_: não os resolva silenciosamente.
  + _Lembre-se de que o observador também envelhece_: o instrumento que mediu tem versão e atualidade próprias (@pri-observador-atualidade).
] <pri-honestidade-pratica>

A quinta regra merece um exemplo, porque mostra como uma inconsistência pequena é um sinal grande.

#estudo-de-caso(titulo: [Oito ou seis?])[
  Um relatório de auditoria afirmava haver "oito itens de trabalho abertos" e, logo abaixo, enumerava seis. O revisor não concluiu que havia erro na contagem nem na lista; concluiu que a primeira evidência do relatório era internamente inconsistente e, portanto, que o próprio procedimento de observação precisava ser examinado. Podia haver dois itens válidos não listados (por exemplo, em outro locus), um critério de contagem diferente do critério de listagem, ou um erro de transcrição. O problema não era haver oito; era a evidência dizer oito e explicar apenas seis. A correção exigiu que o relatório explicitasse o critério de contagem e enumerasse todos os itens contados, com seus loci.
] <caso-oito-seis>

Agentes de linguagem são particularmente vulneráveis a esse tipo de inconsistência, porque produzem texto fluente que _parece_ coerente. Por isso, relatórios de agentes devem ser projetados para serem verificáveis: listas explícitas em vez de totais, identificadores em vez de descrições, e seções separadas para o que foi observado, o que foi inferido e o que permanece desconhecido. O @cap-handoff desenvolve um formato de pacote de retorno com essas propriedades.

#exercicios[
  + Reescreva o parágrafo a seguir aplicando as regras de honestidade epistêmica: "Atualizei a configuração e o serviço voltou a funcionar. Os testes estão passando e o problema de desempenho também parece resolvido. Acho que podemos fechar o item."
  + Proponha três verificações automáticas de coerência interna que poderiam ser aplicadas a relatórios produzidos por agentes.
  + Discuta a tensão entre a regra 3 ("prefira desconhecido") e a utilidade de um agente que precisa agir sob incerteza. Como os portões do @cap-portoes resolvem essa tensão?
]

#quadro[
  - Prova, memória e conhecimento são papéis epistêmicos relativos a uma coordenada, não tipos de objeto.
  - Prova desafia memória; memória guia a busca de prova; conhecimento é recalculado de ambas.
  - Ausência não é negação; estranho não é obsoleto; semelhança não é relação; absorção não é conclusão.
  - Toda afirmação de estado deve ser qualificada por âncora, locus, instante e escopo.
  - A atualidade de uma conclusão é a da sua justificação menos atual; guardar justificações torna a retratação exata.
  - Relatórios honestos são verificáveis: listas em vez de totais, identificadores em vez de descrições, observado separado de inferido.
]

#problemas[
  #problema([Uma lógica para afirmações qualificadas])[
    Defina uma linguagem em que afirmações têm a forma $"prov"(a, ell, t, s) : phi$ — "a âncora $a$ prova $phi$ no locus $ell$, no instante $t$, com escopo $s$".
    + Proponha regras de inferência para combinar afirmações com loci e escopos diferentes (por exemplo, quando uma afirmação sobre a revisão $r$ num locus pode ser usada noutro).
    + Mostre que a regra "uma prova num locus vale em todo locus" leva a conclusões falsas, com um exemplo.
    + #avancado Relacione sua linguagem à lógica epistêmica (@sec-ap-epistemica), interpretando loci como agentes.
  ]
  #problema([Políticas de validade aprendidas])[
    Em vez de fixar janelas de validade, um sistema as estima observando com que frequência cada classe de predicado muda.
    + Modele a mudança de um predicado como um processo de Poisson com taxa $lambda_p$. Qual a probabilidade de uma observação feita há $Delta$ unidades de tempo ainda ser verdadeira?
    + Dada uma tolerância de erro $epsilon$, qual janela de validade $Delta_p$ escolher?
    + Discuta os riscos de estimar $lambda_p$ a partir de observações que só são feitas quando algo dá errado.
  ]
  #problema([Auditoria de um relatório])[
    Escolha um relatório de estado longo produzido por um agente (ou escreva um).
    + Marque cada afirmação como observada, lembrada ou inferida, e qualifique-a.
    + Identifique afirmações cujo estatuto foi promovido indevidamente.
    + Reescreva o relatório no formato de pacote de retorno sugerido neste capítulo e compare os comprimentos.
  ]
]

#notas[
  A distinção entre conhecimento e crença verdadeira justificada é antiga e foi problematizada por #ct(<gettier1963>); para os propósitos deste livro, a distinção relevante é mais operacional: entre o que se pode demonstrar com âncoras e o que apenas se lembra. A hipótese de mundo aberto e a crítica ao uso da ausência como negação vêm da teoria de bancos de dados @reiter1978 @codd1979; a lógica de quatro valores para fontes conflitantes é de #ct(<belnap1977>). Os sistemas de manutenção da verdade de #ct(<doyle1979>) e #ct(<dekleer1986>) introduziram a ideia de registrar justificações para permitir retratação localizada, que o @teo-retratacao reformula. A teoria da revisão de crenças @alchourron1985 @gardenfors1988 fornece o arcabouço normativo para a mudança de crenças diante de informação nova, e a noção de entrincheiramento aproxima-se do que aqui chamamos de força do suporte (sem satisfazer todos os seus postulados). A distinção entre _revisar_ uma crença (o mundo é o mesmo, a crença estava errada) e _atualizá-la_ (o mundo mudou) é de #ct(<katsuno1991>); a revisão de bases finitas, como o acervo, e não de conjuntos fechados sob consequência, é tratada por #ct(<hansson1999>). A ideia de que memória deve guiar a busca de prova, e não substituí-la, tem paralelo na pesquisa sobre _forrageamento de informação_ @pirolli1999, em que pistas ("cheiro de informação") orientam a exploração.

  As distinções "estranho não é obsoleto", "semelhança não é relação" e "absorção não é conclusão" são propostas deste livro, e os estudos de caso deste capítulo generalizam confusões recorrentes entre prova e memória na operação de agentes. A literatura sobre alucinação em modelos de linguagem @ji2023 trata de um fenômeno vizinho — a geração de afirmações sem sustentação —, mas o foco aqui é diferente: mesmo um agente que nunca alucina pode violar a honestidade epistêmica, por exemplo ao apresentar memória como prova.
]
