#import "/modelo/estilo.typ": *

= Unidades de trabalho governadas <cap-trabalho>

#epigrafe[Encerrar não é aprovar, e aprovar não é entregar.]

Agentes não executam apenas ações isoladas; executam _trabalho_ — sequências de ações orientadas por um objetivo, que se estendem por várias sessões, envolvem vários consumidores e produzem evidências, decisões e artefatos. Para que esse trabalho possa ser retomado, auditado, interrompido e encerrado com segurança, ele precisa de uma unidade: um objeto com identidade, ciclo de vida e regras de transição. Chamamos esse objeto de _unidade de trabalho governada_.

Este capítulo trata das unidades de trabalho. A @sec-trab-unidade define a unidade e sua máquina de estados. A @sec-trab-selecao trata da seleção de trabalho e de seus estados — e prova que uma seleção correta nunca "adivinha". A @sec-trab-reservas discute reservas de escrita e concorrência entre agentes. A @sec-trab-encerramento separa selo, aceitação e desfecho terminal e enuncia a regra de conclusão. A @sec-trab-linhas-base trata de linhas de base, candidatos e promoção. A @sec-trab-pendencias trata de pendências e de sua aplicabilidade efetiva. A @sec-trab-sintese discute síntese e fronteiras governadas.

== A unidade de trabalho e seu ciclo de vida <sec-trab-unidade>

#definicao(titulo: [Unidade de trabalho governada])[
  Uma _unidade de trabalho governada_ é um recurso com: identidade; um _objetivo_ (o que se pretende alcançar); uma _definição de concluído_ (DoD — os critérios verificáveis de sucesso); um _escopo_ (os recursos sobre os quais pode haver mutação); um _estado de ciclo de vida_; um conjunto de _reservas_ (quem pode escrever sob ela); e o registro de suas evidências, decisões e transições.
] <def-unidade-trabalho>

O estado de ciclo de vida de uma unidade é uma máquina simples, mas os atributos que costumam ser confundidos com ele são ortogonais.

#figure(
  diagram(
    spacing: (18mm, 10mm),
    node-stroke: 0.6pt + cor.primaria, node-fill: cor.tinta-def, node-corner-radius: 2pt,
    node((0, 0), [#estado[aberta]], name: <a>),
    node((1, 0), [#estado[estacionada]], name: <e>),
    node((2, 0), [#estado[selada]], name: <s>),
    edge(<a>, <e>, "-|>", bend: 20deg, label: text(size: 8pt)[estacionar]),
    edge(<e>, <a>, "-|>", bend: 20deg, label: text(size: 8pt)[retomar]),
    edge(<a>, <s>, "-|>", bend: -35deg, label: text(size: 8pt)[selar (regra de conclusão)], label-side: right),
    edge(<e>, <s>, "-|>", label: text(size: 8pt)[selar]),
    edge(<s>, <a>, "-|>", bend: 55deg, label: text(size: 8pt)[reabrir (decisão do titular, com registro)], label-side: right),
  ),
  caption: [Ciclo de vida de uma unidade de trabalho. A reabertura de uma unidade selada é uma decisão do titular, registrada com a razão. _Aceitação_ e _desfecho terminal_ não são estados desta máquina: são atributos ortogonais, registrados por transições próprias.],
) <fig-ciclo-unidade>

#invariante(titulo: [Estacionar não é abandonar])[
  Uma unidade estacionada continua existindo, com sua história e suas pendências; ela apenas deixa de ser trabalho corrente. Estacionar não encerra, não descarta e não autoriza a remoção de seus artefatos.
] <inv-estacionar>

#exercicios[
  + Escreva a definição de concluído de uma unidade cujo objetivo é "corrigir a falha intermitente nos testes de integração". Que critérios são verificáveis e quais seriam vagos?
  + Por que a aceitação não deve ser um estado da máquina da @fig-ciclo-unidade? Dê um exemplo em que uma unidade selada nunca é aceita, e outro em que o objetivo de uma unidade estacionada é aceito por outro caminho.
  + Desenhe a máquina de estados do ciclo de vida de uma unidade de trabalho e indique, para cada transição, a evidência exigida e quem pode executá-la.
]

== Seleção de trabalho <sec-trab-selecao>

Num domínio com várias unidades abertas, um consumidor precisa saber em qual está trabalhando. A tentação, em implementações simples, é escolher "a primeira aberta", "a mais recente" ou "a que tem tal sufixo no nome". Cada uma dessas regras é uma adivinhação.

#estudo-de-caso(titulo: [O ponteiro escolhido pelo sufixo])[
  Um mecanismo automático que injetava contexto no início de cada sessão precisava indicar ao agente a unidade de trabalho corrente. Ele percorria o inventário de unidades e escolhia a primeira cujo nome de arquivo terminava com uma marca de "aberta". Como uma unidade estacionada ainda conservava a marca no nome, o mecanismo a selecionava — e o agente passava a trabalhar numa unidade que o titular havia deliberadamente parado. A correção não foi renomear o arquivo, mas separar três coisas que o mecanismo misturava: o inventário (todas as unidades), a seleção (qual unidade é corrente, e com que base) e o objetivo corrente do titular.
] <caso-sufixo>

#invariante(titulo: [Inventário não é seleção; seleção não é objetivo])[
  O inventário lista as unidades existentes; a seleção indica qual unidade é corrente para uma coordenada, com uma _base_ explícita (pedido do consumidor, ponteiro padrão aplicável); o objetivo corrente do titular é uma terceira coisa. A multiplicidade de unidades abertas não é ambiguidade a ser resolvida por heurística.
] <inv-inventario-selecao-objetivo>

#definicao(titulo: [Resultado de seleção])[
  O _resultado de uma seleção_ é uma tupla (ponteiro padrão, pedido, selecionada, base, estado), em que o estado pertence a {#estado[selecionada por pedido], #estado[selecionada por padrão], #estado[nenhuma selecionada], #estado[pedido não resolvido], #estado[pedido não aplicável], #estado[padrão não aplicável]}.
] <def-resultado-selecao>

#algoritmo("Seleciona-Trabalho", params: $I, d, q, kappa$, legenda: [Seleção de trabalho sem recurso a heurísticas. $I$ é o inventário, $d$ o ponteiro padrão (opcional), $q$ o pedido explícito (opcional) e $kappa$ a coordenada.])[
  + #kw[se] $q != bot$ #kw[então]
    + $w <- $ #proc("Resolve")$(q, I)$
    + #kw[se] $w = bot$ #kw[então] #kw[devolva] $(d, q, bot, bot, $ #estado[pedido não resolvido]$)$
    + #kw[se] #kw[não] #proc("Aplicável")$(w, kappa)$ #kw[então] #kw[devolva] $(d, q, bot, $ "pedido explícito"$, $ #estado[pedido não aplicável]$)$
    + #kw[devolva] $(d, q, w, $ "pedido explícito"$, $ #estado[selecionada por pedido]$)$
  + #kw[se] $d != bot$ #kw[e] #proc("Aplicável")$(d, kappa)$ #kw[então] #kw[devolva] $(d, bot, d, $ "ponteiro padrão"$, $ #estado[selecionada por padrão]$)$
  + #kw[se] $d != bot$ #kw[então] #kw[devolva] $(d, bot, bot, bot, $ #estado[padrão não aplicável]$)$
  + #kw[devolva] $(bot, bot, bot, bot, $ #estado[nenhuma selecionada]$)$
] <alg-seleciona-trabalho>

#proposicao(titulo: [Seleção sem adivinhação])[
  O @alg-seleciona-trabalho nunca devolve como selecionada uma unidade diferente da pedida quando há pedido, nunca seleciona uma unidade não aplicável, e nunca seleciona uma unidade que não seja o pedido nem o ponteiro padrão.
] <prop-selecao-sem-adivinhacao>

#prova[
  Por inspeção dos casos. Com pedido, a única unidade que pode ser devolvida como selecionada é a resolução do pedido, e só se aplicável (linhas 3 a 5); se a resolução falha ou a unidade não se aplica, nenhuma é selecionada, em vez de se recorrer ao padrão ou à primeira aberta. Sem pedido, a única candidata é o padrão, e só se aplicável (linha 6). Em todos os demais casos, a seleção é vazia.
]

O algoritmo faz no máximo uma resolução de pedido e duas verificações de aplicabilidade: com o inventário indexado por identificador, custa $O(T_"res" + 2 T_"apl")$, independente do tamanho do inventário — uma consequência direta de não procurar candidatas.

A proposição tem uma consequência para a renderização: "nenhuma selecionada" é uma resposta válida e deve aparecer literalmente na perspectiva, acompanhada — conforme o @anti-inventario-selecao — da indicação de onde há trabalho observável. A pior resposta possível é a que substitui "nenhuma selecionada" por "não há trabalho; abra uma nova unidade".

=== Pedido, resolução e aplicabilidade

Os quatro casos de pedido — sem pedido; resolvido e aplicável; não resolvido; resolvido e não aplicável — são distinguidos no resultado porque pedem respostas diferentes do consumidor: corrigir o identificador, mudar de coordenada ou, se a unidade está selada, pedir ao titular que a reabra (@fig-ciclo-unidade) ou abrir uma unidade nova que a referencie.

#exercicios[
  + Execute o @alg-seleciona-trabalho nos casos: (a) pedido válido de uma unidade estacionada; (b) sem pedido, padrão apontando para unidade selada; (c) sem pedido, sem padrão, três unidades abertas.
  + Por que o algoritmo não recorre ao padrão quando o pedido não resolve? Dê um exemplo em que esse recurso levaria a um erro grave.
  + Mostre que, sem a linha 4, o algoritmo selecionaria uma unidade selada pedida explicitamente, violando a @prop-selecao-sem-adivinhacao.
]

== Reservas de escrita e concorrência <sec-trab-reservas>

Quando vários agentes trabalham ao mesmo tempo, é preciso controlar quem pode alterar o quê. O mecanismo usual é a _reserva_ (às vezes chamada de _claim_ ou _lease_): o direito temporário e exclusivo de escrever sob uma unidade, num escopo.

#definicao(titulo: [Reserva de escrita])[
  Uma _reserva de escrita_ é um registro (unidade, escopo, titular da reserva, instante de início, validade, época) que concede ao titular da reserva o papel de _escritor_ da unidade naquele escopo. Reservas expiram, podem ser liberadas e são verificadas no momento de cada mutação.
] <def-reserva>

Expiração por relógio não basta para garantir exclusividade. Um titular cujo processo é suspenso — por uma pausa longa, por uma partição de rede — pode continuar escrevendo depois de sua reserva expirar, quando outro já obteve uma nova. Os _arrendamentos_ (leases) clássicos @gray1989 supõem limite de deriva entre relógios; a prática exige, além disso, _fichas de cerca_: cada concessão recebe um número de época crescente, e o armazenamento recusa escritas de épocas antigas @kleppmann2017.

#proposicao(titulo: [Exclusividade com fichas de cerca])[
  Suponha que cada concessão de reserva sobre um escopo receba um número de época estritamente crescente, que toda escrita leve a época de sua reserva, e que o armazenamento recuse toda escrita cuja época seja menor que a maior época já vista nesse escopo. Então, mesmo que dois titulares acreditem simultaneamente ter a reserva, depois de aceita a primeira escrita de época $e$ nenhuma escrita de época menor que $e$ é aceita.
] <prop-fichas-cerca>

#prova[
  Depois de aceita uma escrita de época $e$, a maior época vista no escopo é pelo menos $e$, e só cresce; pela regra do armazenamento, toda escrita posterior de época menor é recusada.
]

Reservas não são autoridade em si: um agente com reserva ainda precisa de autorização para cada efeito (@cap-autoridade). Elas resolvem outro problema — o de duas escritas concorrentes sobre o mesmo escopo, com bases diferentes, produzirem um estado que nenhuma das duas pretendia.

#invariante(titulo: [Trabalho concorrente não é bloqueio, nem posse])[
  A presença de trabalho de outro agente no mesmo repositório não bloqueia, por si só, o trabalho corrente — e o trabalho corrente não se apropria do trabalho alheio. Alterações locais de outro escritor conhecido não são "estado desconhecido da fonte": são trabalho de outro dono, a ser preservado e integrado por quem tem a reserva correspondente. A convergência é um portão de encerramento, não de início.
] <inv-trabalho-concorrente>

Uma consequência prática: ao encerrar, a unidade registra o _conjunto exato de mutações que ela causou_, separado da revisão final da fonte, que pode conter também trabalho concorrente integrado. Sem essa separação, a história causal se fragmenta — fica impossível dizer o que cada unidade fez.

#exercicios[
  + Dois agentes trabalham em unidades diferentes que tocam o mesmo arquivo. Descreva como reservas por escopo evitariam a interferência, e o que acontece se os escopos forem definidos de modo grosseiro demais.
  + Por que a revisão final da fonte não é suficiente para registrar o que uma unidade fez? Proponha o registro adicional necessário.
  + Dois agentes querem alterar o mesmo arquivo em unidades de trabalho diferentes. Descreva como reservas de escrita e análise de afetação decidem se eles podem prosseguir em paralelo.
]

== Selo, aceitação e desfecho terminal <sec-trab-encerramento>

Três transições diferentes costumam ser chamadas, indistintamente, de "fechar" uma unidade.

#definicao(titulo: [Selo, aceitação e desfecho])[
  - O _selo_ registra que o arco de trabalho de uma unidade foi encerrado: nada mais será feito sob ela.
  - A _aceitação_ é a decisão, por quem tem autoridade, de que o resultado é aceito — por exemplo, que um candidato passa a ser a linha de base.
  - O _desfecho terminal_ é o vínculo do resultado selado às suas referências de entrega e de evidência: o que foi efetivamente entregue, onde, e com que prova.
] <def-selo-aceitacao>

#invariante(titulo: [Selado não é aceito; selado não é entregue])[
  Uma unidade pode estar selada sem que seu resultado tenha sido aceito, e sem desfecho terminal (por exemplo, quando o trabalho foi interrompido ou superado). Selar não implica aprovar, e aprovar não implica que a entrega foi materializada.
] <inv-selado-aceito>

#antipadrao(titulo: [Selar antes do candidato final])[
  Uma unidade é selada referenciando um candidato que, logo depois, é alterado para corrigir um detalhe. O selo passa a registrar uma implementação; a entrega contém outra. A regra correta é congelar o candidato final, provar o caminho vivo com ele, e só então selar.
] <anti-selar-antes>

=== A regra de conclusão

Uma unidade não deve ser selada "quando parece pronta", nem mantida aberta "até estar perfeita". O critério é explícito.

#definicao(titulo: [Regra de conclusão])[
  Uma unidade pode ser selada como concluída quando: (i) cada item da definição de concluído está satisfeito com evidência; (ii) se houve entrega, o desfecho terminal está registrado; (iii) todas as pendências surgidas foram classificadas (resolvidas, adiadas com condição, transferidas ou descartadas com razão); (iv) a preservação está garantida nas três camadas — governança (registros), controle de versão (fonte) e retenção (bytes que precisam sobreviver); e (v) uma semente de continuação foi emitida, possivelmente declarando que nenhuma continuação é necessária.
] <def-regra-conclusao>

#invariante(titulo: [Higiene não é condição infinita de fechamento])[
  Fecha-se contra a definição de concluído, não contra a perfeição. Melhorias desejáveis que não fazem parte da definição viram pendências, não impedimentos. Preservar não é promover; adiar não é descartar.
] <inv-higiene-fechamento>

#exercicios[
  + Classifique os seguintes estados: (a) selada, aceita, com desfecho; (b) selada, não aceita, sem desfecho; (c) selada, aceita, sem desfecho. Dê uma situação plausível para cada um.
  + Aplique a @def-regra-conclusao a uma unidade de trabalho de sua experiência. Qual dos cinco critérios costuma ser esquecido?
  + Uma unidade foi selada, mas a revisão final ainda não passou pelo portão de aceitação. Que campos do registro distinguem essa situação de uma unidade aceita? Que erro um consumidor frio cometeria sem eles?
]

== Linhas de base, candidatos e promoção <sec-trab-linhas-base>

Em trabalho de software, o objeto que interessa é frequentemente uma _revisão_. Três noções precisam ser mantidas separadas.

#definicao(titulo: [Linha de base, candidato e promoção])[
  A _linha de base aceita_ para um alvo é um fato governado: "a revisão $r$ é a implementação aceita corrente para o alvo $g$", registrado por quem tem autoridade, com histórico. Um _candidato_ é uma revisão proposta para substituir a linha de base. A _promoção_ é a transição governada que torna um candidato a nova linha de base.
] <def-linha-base>

#invariante(titulo: [A linha de base não é a ponta do ramo])[
  A linha de base aceita não é a revisão mais recente, nem a ponta do ramo principal, nem a revisão marcada por um rótulo, nem a revisão em execução. Controle de versão prova ancestralidade; governança determina aceitação. A direção correta é: o titular aceita, e então ramo, rótulo e execução são igualados à decisão — nunca o inverso.
] <inv-linha-base>

#invariante(titulo: [Mais novo não é aceito])[
  Nenhum candidato é aceito por ser o mais recente. A aceitação é relativa à linha de base governada: o candidato descende dela, ou há uma convergência governada que explica a divergência.
] <inv-mais-novo>

Duas decisões que frequentemente são tomadas "automaticamente" pertencem, na verdade, ao titular: a _versão_ de uma entrega (que comunica compatibilidade a terceiros e não é consequência do número de mudanças) e a _prioridade_ das próximas frentes (que tem validade temporal: uma classificação de "não bloqueante" feita antes de um incidente deve ser revista depois dele).

#estudo-de-caso(titulo: [A versão escolhida pela máquina])[
  Ao preparar uma publicação, um agente consultou uma memória antiga sobre a convenção de versões, observou o número de mudanças acumuladas e escolheu um novo número de versão, que registrou num rótulo. A escolha era plausível, mas não era sua: a versão comunicava aos consumidores uma promessa de compatibilidade que só o titular podia fazer. Além disso, a memória consultada estava desatualizada. A correção estabeleceu que a versão de uma entrega é #est[desconhecida] até decisão do titular, e que memórias sobre convenções são orientação, não prova.
] <caso-versao>

#exercicios[
  + Um ramo principal tem três revisões após a última linha de base aceita; a revisão em execução é a segunda. Qual é a linha de base? O que é cada uma das revisões?
  + Proponha o registro mínimo de uma promoção, com proveniência suficiente para auditá-la.
  + Por que "o mais recente é o aceito" falha quando há várias linhas de trabalho paralelas? Dê um exemplo com fusões.
]

== Pendências e aplicabilidade efetiva <sec-trab-pendencias>

O @cap-memoria definiu pendências como possibilidades de trabalho sem compromisso. Num acervo que cresce por acréscimo, pendências antigas permanecem registradas como "abertas" muito depois de terem sido atendidas, superadas ou tornadas irrelevantes — porque o registro original nunca é editado.

#definicao(titulo: [Estado registrado e estado vigente])[
  O _estado registrado_ de uma pendência é o que seu registro original afirma (por exemplo, "aberta"). O _estado vigente_ é derivado por junção com os fatos posteriores relevantes e ainda vigentes (@def-estatuto-sustentado): unidades que a atenderam, decisões que a superaram, evidências que a satisfizeram, linhas de base que a tornaram obsoleta.
] <def-estado-efetivo>

#lema(titulo: [O estado vigente é monótono nos fatos de conclusão vigentes])[
  Seja $"vig"(Sigma)$ o conjunto das asserções de $Sigma$ não suplantadas, e suponha que o estado vigente seja #estado[satisfeita] quando existe fato de conclusão aplicável em $"vig"(Sigma)$, e o estado registrado caso contrário. Então: (i) acrescentar asserções que não suplantam fatos de conclusão preserva #estado[satisfeita]; (ii) acrescentar uma suplantação de um fato de conclusão pode fazer a pendência voltar a #estado[aberta] — e esse retorno deve ser registrado como evento.
] <lem-estado-efetivo>

#prova[
  (i) Um fato de conclusão vigente continua vigente enquanto nenhuma asserção o suplanta; acrescentar outras asserções não altera sua vigência, e a condição existencial continua satisfeita. (ii) Basta um exemplo: com um único fato de conclusão, sua suplantação o retira de $"vig"(Sigma)$ e o estado volta ao registrado. Como a suplantação é, ela mesma, um acréscimo, a vigência — e com ela o estado vigente — é não monótona em $Sigma$; é a não monotonicidade discutida no @cap-perspectiva.
]

#estudo-de-caso(titulo: [A pendência recomendada como prioridade])[
  Um mecanismo de orientação recomendou a um agente, como próximo passo, uma pendência cujo estado registrado era "aberta". O objetivo dessa pendência já havia sido satisfeito, aceito e superado por trabalhos posteriores. A correção imediata foi conter a recomendação; a correção sistêmica foi calcular o estado vigente por junção — e registrar que conter um sintoma não corrige a causa.
] <caso-pendencia-prioridade>

#exercicios[
  + Proponha a consulta (em linguagem de sua preferência) que calcula o estado vigente de pendências a partir de registros de unidades, decisões e linhas de base.
  + Por que o estado vigente deve ser _derivado_ e não obtido editando o registro original? Relacione com o @inv-erro-historia.
  + Use o lema da monotonicidade do estado vigente para argumentar que acrescentar fatos de conclusão nunca reabre uma pendência. Que tipo de fato _poderia_ reabri-la, e como deveria ser registrado?
]

== Síntese e fronteiras governadas <sec-trab-sintese>

Ao fim de uma etapa, é útil parar e classificar: o que a unidade aprendeu, o que resta, o que deveria virar pendência, o que deveria ser descartado. Esse momento de _síntese_ é valioso, mas tem uma regra.

#invariante(titulo: [Síntese não é mutação de governança])[
  A síntese produz apenas _propostas_ — de novas pendências, de encerramento, de promoção, de mudanças de prioridade. Ela não encerra unidades, não promove candidatos e não altera prioridades por conta própria. Da mesma forma, uma transferência não é aceitação.
] <inv-sintese>

#definicao(titulo: [Fronteira governada])[
  Uma _fronteira governada_ é um ponto natural de reconciliação do estado de uma unidade: início, transição de estado, liberação de reserva, transferência, desmontagem, prova, publicação. Em cada fronteira, verifica-se a coerência entre o registro da unidade, a fonte, a evidência e as reservas.
] <def-fronteira-governada>

As fronteiras governadas são os momentos em que vale a pena gastar contexto com verificações: entre elas, o trabalho segue com sentinelas leves (@def-sentinelas); nelas, faz-se a reconciliação completa.

#exercicios[
  + Liste as verificações que devem ocorrer na fronteira "liberação de reserva".
  + Explique por que uma síntese que encerra unidades automaticamente viola a separação de poderes do @cap-ciclo-acao.
  + Uma sessão de reflexão de um agente produz cinco propostas de mudança na governança. Descreva o caminho de cada proposta até se tornar (ou não) uma mudança efetiva, respeitando o invariante de que síntese não é mutação.
]

#quadro[
  - Unidades de trabalho têm identidade, objetivo, definição de concluído, escopo, estado e reservas; estacionar não é abandonar.
  - Inventário ≠ seleção ≠ objetivo; a seleção tem base explícita e nunca adivinha (@prop-selecao-sem-adivinhacao).
  - Reservas de escrita controlam concorrência, mas não são autoridade; trabalho concorrente não é posse nem bloqueio.
  - Selo ≠ aceitação ≠ desfecho terminal; feche contra a definição de concluído, com a regra de conclusão.
  - Linha de base é decisão governada, não a ponta do ramo; o mais novo não é aceito por ser novo; versão é decisão do titular.
  - Estado efetivo de pendências é derivado por junção e é monótono nos fatos de conclusão.
  - Síntese só propõe; fronteiras governadas concentram as verificações.
]

#problemas[
  #problema([Seleção com múltiplos loci])[
    O trabalho de um titular está distribuído em três domínios, cada um com seu inventário e seu ponteiro padrão.
    + Generalize o @alg-seleciona-trabalho para receber uma coordenada com locus e devolver, além da seleção local, a lista de domínios onde há trabalho observável.
    + Prove que a generalização preserva a @prop-selecao-sem-adivinhacao.
    + Discuta como renderizar o resultado para que o consumidor não confunda "nenhuma selecionada aqui" com "nenhum trabalho".
  ]
  #problema([Unidades como redes de fluxo de trabalho])[
    Modele uma unidade de trabalho, com suas transições guardadas por contratos, como uma rede de Petri.
    + Defina os lugares e as transições para os estados da @fig-ciclo-unidade e para os atributos de aceitação e desfecho.
    + Formule a propriedade "toda unidade selada como concluída satisfaz a regra de conclusão" como propriedade de alcançabilidade.
    + Discuta como verificar a propriedade automaticamente.
  ]
  #problema([Integração de histórias divergentes])[
    Três linhas de trabalho divergiram de uma linha de base comum e precisam convergir.
    + Descreva um procedimento que integre as histórias preservando a proveniência de cada uma e resolvendo conflitos pela semântica corrente.
    + Mostre que, ao final, cada conceito deve ter um único dono semântico na linha principal (@pri-dono-semantico), e explique o que acontece com as implementações antigas.
    + Proponha os registros que permitem, depois, dizer qual unidade causou cada mudança da árvore final.
  ]
]

#notas[
  O controle de concorrência por reservas com validade é uma forma de _lease_, técnica clássica de sistemas distribuídos para exclusão mútua tolerante a falhas; a separação entre proponente, autorizador e executor e a regra de que ninguém aprova o próprio trabalho têm paralelo no princípio de separação de deveres de políticas de integridade comercial. A modelagem de fluxos de trabalho por redes de Petri é tradicional na literatura de gestão de processos. A distinção entre linha de base aceita e estado do controle de versão reflete a diferença entre proveniência (que o controle de versão registra muito bem, @chacon2014) e decisão governada (que ele não registra).

  A seleção de trabalho sem adivinhação, a distinção entre selo, aceitação e desfecho terminal, a regra de conclusão e o cálculo do estado vigente de pendências são propostas deste livro, motivadas por falhas recorrentes de sistemas de orientação de agentes: escolher unidades pelo nome de arquivo, recomendar pendências já superadas, selar trabalhos antes de congelar o candidato final. A observação de que conter um sintoma não corrige a causa sistêmica é um tema recorrente da engenharia de confiabilidade.
]
