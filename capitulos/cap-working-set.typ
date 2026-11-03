#import "/modelo/estilo.typ": *

= Conjunto de trabalho, eixos ortogonais e hierarquias de contexto <cap-working-set>

#epigrafe(fonte: [Peter J. Denning, 1968, parafraseado])[Um programa, em qualquer intervalo de tempo, favorece um subconjunto de suas páginas.]

Em 1968, Peter Denning propôs uma ideia que reorganizou o projeto de sistemas operacionais: em vez de perguntar quanta memória um programa _tem_, perguntar de quais páginas ele _precisa agora_. O _conjunto de trabalho_ — as páginas referenciadas recentemente — mostrou-se um preditor excelente das páginas referenciadas em seguida, porque programas exibem _localidade_. Com base nisso, foi possível decidir quantos programas executar simultaneamente, quando trazer páginas do disco e quando descartá-las, e diagnosticar o colapso de desempenho conhecido como _thrashing_.

Este capítulo transporta a ideia para o contexto de agentes. A @sec-ws-denning define o conjunto de trabalho contextual e suas propriedades. A @sec-ws-eixos mostra que o estado de um recurso num conjunto de trabalho não é um rótulo, mas um ponto num espaço de _eixos ortogonais_ — disponibilidade, autoridade, aplicabilidade, seleção, divulgação e expansibilidade — e que colapsar esses eixos em enumerações produz erros. A @sec-ws-derivadas discute por que camadas derivadas, como o próprio conjunto de trabalho, não devem ser transformadas em entidades persistentes. A @sec-ws-hierarquia apresenta a hierarquia de memória de um agente e as políticas de substituição, com seus resultados clássicos de otimalidade e competitividade, e destaca a diferença crucial entre uma falta de página e uma "falta de contexto": esta última costuma ser silenciosa. A @sec-ws-thrashing trata da pressão de contexto e de seu análogo ao thrashing. A @sec-ws-estimativa mostra como estimar o conjunto de trabalho de um agente a partir de seu histórico de ações.

== O conjunto de trabalho contextual <sec-ws-denning>

Na formulação original @denning1968, o conjunto de trabalho de um processo no instante $t$ com janela $Delta$ é o conjunto $"WS"(t, Delta)$ das páginas referenciadas no intervalo $(t - Delta, t]$, medido em tempo virtual do processo. O _princípio da localidade_ @denning2005 afirma que, em intervalos curtos, programas concentram suas referências em subconjuntos pequenos e lentamente variáveis de seu espaço de endereçamento.

Agentes também exibem localidade. Ao depurar uma falha, um agente lê repetidamente os mesmos poucos arquivos, consulta os mesmos registros e volta às mesmas decisões; ao implementar uma funcionalidade, trabalha sobre um pequeno grupo de módulos. Medimos o "tempo" de um agente em passos do laço agêntico (@alg-laco).

#definicao(titulo: [Conjunto de trabalho contextual])[
  Seja $"ref"(s) subset.eq I$ o conjunto de recursos (ou asserções) referenciados pelo agente no passo $s$ — lidos, citados, modificados ou mencionados em sua saída. O _conjunto de trabalho contextual_ no passo $t$, com janela $Delta >= 1$, é
  $ "WS"(t, Delta) = union.big_(s = t - Delta + 1)^t "ref"(s). $
  Seu _tamanho_ é $omega(t, Delta) = c("WS"(t, Delta))$, a soma dos custos em tokens de seus elementos quando renderizados.
] <def-ws-contextual>

#lema(titulo: [Propriedades elementares])[
  Para todo $t$ e $Delta$: (i) $"WS"(t, Delta) subset.eq "WS"(t, Delta + 1)$; (ii) $omega(t, Delta)$ é não decrescente em $Delta$; (iii) $"WS"(t+1, Delta) subset.eq "WS"(t, Delta) union "ref"(t+1)$.
] <lem-ws-propriedades>

#prova[
  (i) A união que define $"WS"(t, Delta + 1)$ inclui todos os termos da que define $"WS"(t, Delta)$. (ii) Segue de (i) e da não negatividade dos custos. (iii) $"WS"(t+1, Delta)$ é a união de $"ref"(s)$ para $s$ de $t - Delta + 2$ a $t + 1$; todos os termos, exceto o último, aparecem em $"WS"(t, Delta)$.
]

A propriedade (iii) é uma identidade de conjuntos; o que torna o conjunto de trabalho útil como _preditor_ é a _localidade_ de referência, um fato empírico: se a localidade é forte, $"WS"(t+1, Delta)$ difere pouco de $"WS"(t, Delta)$, e incluir $"WS"(t, Delta)$ na próxima perspectiva antecipa a maior parte do que o agente vai precisar. A janela $Delta$ controla o compromisso: janelas grandes reduzem faltas, mas aumentam o custo; janelas pequenas fazem o oposto.

#exercicios[
  + Mostre que $omega(t, Delta)$ não é necessariamente monótono em $t$ e dê um exemplo em que o conjunto de trabalho encolhe bruscamente. Que mudança no comportamento do agente isso indica?
  + Num registro de 20 passos de um agente, os recursos referenciados foram: $a, b, a, c, a, b, d, d, e, d, f, d, e, g, d, e, f, g, d, e$. Calcule $W(t, 4)$ para $t = 8, 12, 16, 20$ e comente a localidade observada.
  + Proponha uma definição de "referência" que distinga ler um recurso de apenas mencioná-lo. Por que a distinção importa para o custo do conjunto de trabalho?
]

== Eixos ortogonais do estado de um recurso <sec-ws-eixos>

Quando um recurso aparece (ou deixa de aparecer) num conjunto de trabalho, há muitas perguntas diferentes sobre ele. Está disponível? O consumidor tem autoridade sobre ele? Ele se aplica ao objetivo corrente? Foi selecionado? Seu conteúdo foi divulgado ou apenas referenciado? Pode ser expandido? É tentador resumir as respostas num único rótulo — "ativo", "indisponível ou não autorizado", "aplicável e selecionado" —, e essa tentação é a origem de uma família de erros.

#definicao(titulo: [Eixos de estado de um recurso numa perspectiva])[
  O estado de um recurso $r$ numa perspectiva é uma tupla de sete componentes, cada um com sua própria _base_ (a evidência ou regra que o justifica):
  - _disponibilidade_ $in {#estado[disponível], #estado[indisponível], #est[desconhecido]}$: o recurso pode ser alcançado agora?
  - _autoridade de leitura_ e _autoridade de ação_, cada uma $in {#estado[concedida], #estado[negada], #estado[requer autenticação], #est[desconhecido]}$: o consumidor pode ler o recurso? Pode agir sobre ele (e de que modo)? As duas são separadas porque ler sem poder agir é o caso comum e legítimo do uso epistêmico somente leitura;
  - _aplicabilidade_ $in {#estado[aplicável], #estado[não aplicável], #est[desconhecido]}$: ele importa para a coordenada?
  - _seleção_ $in {#estado[selecionado], #estado[não selecionado]}$: ele foi escolhido para o conjunto de trabalho?
  - _divulgação_ $in {#estado[divulgado], #estado[só referência], #estado[retido]}$: seu conteúdo está no contexto, só sua referência, ou nada?
  - _expansibilidade_ $in {#estado[expansível], #estado[não expansível], #est[desconhecido]}$: o consumidor pode obter mais sobre ele?
] <def-eixos>

Os eixos não são todos do mesmo tipo. Alguns descrevem o recurso em si (disponibilidade, expansibilidade); outros, sua relação com o consumidor e a coordenada (autoridade, aplicabilidade, seleção, divulgação); outros, ainda, o _plano_ de verdade em que se encontram — desejado, autoritativo, materializado, ativo. Esse último recorte, os _planos de estado_, é tratado em detalhe no @cap-reconciliacao (@def-planos-estado) e, para a configuração, no @cap-ambiente; o ponto aqui é que um recurso pode estar no conjunto de trabalho por um eixo e fora dele por outro, e a perspectiva precisa dizer por qual.

Os eixos são _independentes como representação_: cada um é guardado separadamente, com sua base. Isso não significa que toda combinação seja válida — os axiomas a restringem: leitura negada implica divulgação #estado[só referência] ou #estado[retido] (P3); selecionado implica aplicabilidade diferente de #estado[não aplicável]. Armazenar os eixos separadamente é justamente o que permite _verificar_ essas restrições. Dentro delas, as combinações são muitas e significativas. Um recurso pode estar disponível e não autorizado (existe, mas o consumidor não pode lê-lo); autorizado e indisponível (o consumidor teria permissão, mas o serviço está fora do ar); aplicável e não selecionado (importa, mas não coube no orçamento — e então deve ser expansível); selecionado e só referenciado (escolhido, mas com conteúdo omitido por custo); e assim por diante. Cada combinação pede uma ação diferente do consumidor.

#definicao(titulo: [Rótulo e colapso])[
  Seja $E = E_1 times dots times E_7$ o espaço de estados dos eixos. Um _rótulo_ é uma função $lambda: E -> L$ para um conjunto finito $L$ de frases. O rótulo _colapsa_ os estados $x != y$ se $lambda(x) = lambda(y)$. Um rótulo é _armazenado_ quando o sistema guarda $lambda(x)$ em vez de $x$.
] <def-rotulo-colapso>

#proposicao(titulo: [Colapso armazenado é irreversível])[
  Se um sistema armazena apenas $lambda(x)$, então nenhuma decisão que dependa de distinguir dois estados colapsados por $lambda$ pode ser tomada corretamente a partir do que foi armazenado, para todas as entradas.
] <prop-colapso>

#prova[
  Sejam $x != y$ com $lambda(x) = lambda(y)$, e seja $d$ uma decisão com $d(x) != d(y)$. Qualquer procedimento que recebe apenas $lambda(dot)$ produz o mesmo resultado para $x$ e $y$, e portanto erra em pelo menos um deles.
]

#antipadrao(titulo: [Enumeração cartesiana])[
  Em vez de manter eixos separados, o sistema define uma enumeração de "estados" que combina vários eixos: #estado[aplicável e selecionado], #estado[aplicável não selecionado expansível], #estado[disponível não aplicável], #estado[indisponível ou não autorizado]. A última categoria funde disponibilidade e autoridade; um consumidor que a recebe não sabe se deve tentar mais tarde, pedir permissão ou autenticar-se — três ações diferentes. Além disso, a enumeração cresce combinatorialmente à medida que novos eixos aparecem, e cada nova combinação exige alterar todos os consumidores.
] <anti-enumeracao-cartesiana>

#principio(titulo: [Armazene eixos; derive frases])[
  Represente e transmita o estado de um recurso como eixos ortogonais, cada um com sua base. Frases convenientes para humanos ou para o modelo — "pronto para uso", "bloqueado" — são _derivadas_ dos eixos no momento da renderização e nunca substituem os eixos no acervo ou na perspectiva.
] <pri-eixos-frases>

#observacao[O princípio é a versão, para estado de contexto, da regra de normalização de bancos de dados e da recomendação de engenharia de software de não codificar várias dimensões num único campo. O que o torna especialmente importante em contexto é que o consumidor — um modelo de linguagem — é excelente em _interpretar_ frases e péssimo em _recuperar_ distinções que a frase destruiu.]

#exercicios[
  + Para cada uma das combinações a seguir, descreva uma situação concreta e a ação adequada do consumidor: (a) disponível, negada, aplicável, não selecionado, retido, não expansível; (b) indisponível, concedida, aplicável, selecionado, só referência, expansível; (c) disponível, requer autenticação, aplicável, não selecionado, só referência, expansível.
  + Mostre que o produto dos eixos tem $3 dot 4 dot 4 dot 3 dot 2 dot 3 dot 3 = 2592$ combinações e conte quantas delas são válidas sob as restrições do texto (leitura negada implica divulgação #estado[só referência] ou #estado[retido]; selecionado implica aplicabilidade diferente de #estado[não aplicável]). Argumente por que uma enumeração explícita seria inviável e por que, ainda assim, a representação por eixos é compacta.
  + Escolha um rótulo usado num sistema que você conhece ("ativo", "pendente", "erro") e identifique quais eixos ele colapsa.
]

== Camadas derivadas não são entidades <sec-ws-derivadas>

O conjunto de trabalho é uma _camada derivada_: ele é calculado a partir do acervo, da coordenada e do histórico de referências. O mesmo vale para a perspectiva e para o que poderíamos chamar de _ambiente_ do agente (o conjunto de recursos observados, com suas autoridades, a partir dos quais a perspectiva é calculada). Uma organização em camadas útil é:

$ "ambiente" -> "perspectiva" -> "conjunto de trabalho" -> "trajetória" $

em que cada camada é derivada da anterior (e do histórico, no caso da trajetória). Há uma tentação recorrente de "substantivar" uma dessas camadas: dar-lhe identidade, ciclo de vida e armazenamento próprios — um registro durável do "contexto de trabalho" do agente, por exemplo.

#principio(titulo: [Não substantive camadas derivadas])[
  Uma camada derivada não ganha identidade nem armazenamento durável próprios enquanto não houver evidência de que isso é necessário — isto é, de que há perguntas que só podem ser respondidas guardando-a. Quando guardada, ela é registrada como _resultado de uma derivação_, com a proveniência dos insumos, e não como fonte de verdade.
] <pri-nao-substantivar>

O princípio decorre do @pri-dono-semantico: guardar uma camada derivada cria uma segunda fonte para as informações que ela contém, que pode divergir da primeira assim que o acervo mudar. O problema é o mesmo das visões materializadas em bancos de dados @gupta1995: elas são úteis por desempenho, mas exigem manutenção, e uma visão materializada desatualizada é pior que nenhuma, porque parece verdade.

Um caso relacionado, igualmente importante, envolve autoridade.

#invariante(titulo: [Ambiente não é autoridade])[
  Um ambiente composto de recursos de vários domínios contém _observações de autoridade por recurso_, cada uma com sua base; ele não tem uma autoridade própria. Expressões como "ambiente autorizado" convidam a tratar a composição como um envelope de autorização global, e devem ser evitadas: a autoridade qualifica recursos, não composições.
] <inv-ambiente-autoridade>

#exercicios[
  + Dê um exemplo de pergunta que só pode ser respondida guardando o conjunto de trabalho de um agente num instante passado. Proponha como guardá-lo respeitando o @pri-nao-substantivar.
  + Explique como o rótulo "ambiente autorizado" pode levar a um vazamento de permissão quando o ambiente combina recursos de dois domínios com políticas diferentes.
  + Classifique como entidade ou camada derivada: o conjunto de trabalho de um agente; uma decisão registrada; o "ambiente efetivo" de uma sessão; um ponto de controle. Justifique com o @pri-nao-substantivar.
]

== A hierarquia de memória de um agente <sec-ws-hierarquia>

Sistemas computacionais organizam a memória em níveis: registradores, caches, memória principal, disco. Cada nível é maior, mais lento e mais barato por byte que o anterior, e o desempenho depende de manter nos níveis rápidos aquilo que será usado em breve. Agentes têm uma hierarquia análoga:

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr, 1fr),
    cabecalho: ([Nível], [Conteúdo típico], [Acesso], [Custo]),
    [Janela de contexto], [perspectiva corrente, conjunto de trabalho], [imediato, pela atenção], [alto por token, a cada chamada],
    [Acervo indexado], [asserções, documentos, registros], [por ferramenta de consulta ou expansão], [latência de uma chamada; tokens do resultado],
    [Memória arqueológica], [material antigo, sem estatuto estabelecido], [por expansão explícita e investigação], [alto: exige interpretação],
    [Mundo], [estado real dos recursos], [por observação], [variável; pode ter efeitos colaterais],
  ),
  caption: [Hierarquia de memória de um agente. Diferentemente das hierarquias de hardware, os níveis inferiores não são cópias dos superiores: o mundo é a referência, e os demais são observações dele com idades diferentes.],
) <tab-hierarquia>

A analogia com sistemas operacionais foi explorada explicitamente por propostas que tratam o modelo de linguagem como um processador cuja janela é memória principal e cujas ferramentas de busca e escrita implementam paginação @packer2023. No nível do servidor de inferência, a mesma analogia orienta o gerenciamento do cache KV em páginas @kwon2023. Nesta seção, aplicamos à janela de contexto os resultados clássicos sobre políticas de substituição, e mostramos onde a analogia falha.

=== Políticas de substituição

Considere o modelo de _paginação_: uma memória rápida com capacidade para $k$ itens de mesmo tamanho; uma sequência de requisições $sigma = sigma_1 sigma_2 dots sigma_n$; uma requisição a um item ausente causa uma _falta_ e obriga a trazê-lo, removendo outro se a memória estiver cheia. Uma política de substituição decide qual remover. O objetivo é minimizar o número de faltas.

#teorema(titulo: [Otimalidade de Belady])[
  A política #proc("Min"), que remove o item cuja próxima requisição está mais distante no futuro (ou que nunca mais será requisitado), minimiza o número de faltas para toda sequência de requisições.
] <teo-belady>

A prova, por argumento de troca, é clássica @belady1966 @mattson1970 e é pedida nos exercícios desta seção. #proc("Min") exige conhecer o futuro, o que nenhum agente conhece; serve como referência para avaliar políticas _online_, que decidem sem conhecer as requisições futuras. A medida usual de qualidade é a _razão competitiva_ @sleator1985 @borodin1998.

#definicao(titulo: [Razão competitiva])[
  Uma política online $A$ é _$r$-competitiva_ se existe uma constante $b$ tal que, para toda sequência $sigma$, $"faltas"_A(sigma) lt.eq r dot "faltas"_"Min"(sigma) + b$.
] <def-competitiva>

#teorema(titulo: [Limite inferior para políticas determinísticas])[
  Nenhuma política online determinística de paginação com memória de capacidade $k$ é $r$-competitiva para $r < k$.
] <teo-limite-inferior-paginacao>

#prova[
  Considere $k + 1$ itens. Um adversário que conhece a política determinística $A$ requisita, a cada passo, o único item que não está na memória de $A$. Assim $A$ falta em todas as $n$ requisições. Divida a sequência em blocos de $k$ requisições consecutivas. Em cada bloco, #proc("Min") falta no máximo uma vez: ao faltar, remove o item cuja próxima requisição está mais longe; como o bloco tem $k$ requisições a no máximo $k$ itens distintos, e há $k + 1$ itens no total, existe um item que não será requisitado nas próximas $k - 1$ requisições, e #proc("Min") remove um item com essa propriedade (ou mais distante ainda). Logo $"faltas"_A >= k dot "faltas"_"Min" - O(k)$. Como $"faltas"_"Min" -> infinity$ quando $n -> infinity$ (há ao menos uma falta a cada $k$ requisições), nenhuma constante aditiva $b$ fixa permite uma razão menor que $k$.
]

#teorema(titulo: [LRU é $k$-competitiva])[
  A política #proc("LRU"), que remove o item usado há mais tempo, é $k$-competitiva.
] <teo-lru>

#prova[
  Divida $sigma$ em _fases_: cada fase é a maior subsequência, começando onde a anterior terminou, que contém requisições a no máximo $k$ itens distintos. Em cada fase, #proc("LRU") falta no máximo $k$ vezes: um item requisitado na fase, uma vez trazido, só seria removido se $k$ outros itens distintos fossem requisitados depois dele na mesma fase, o que não acontece. Por outro lado, considere uma fase e o primeiro item da fase seguinte: juntos, eles somam $k + 1$ itens distintos; como #proc("Min") tem capacidade $k$, ele falta pelo menos uma vez no intervalo que vai da segunda requisição de uma fase até a primeira da seguinte. Logo #proc("Min") falta ao menos uma vez por fase (exceto possivelmente na última), e $"faltas"_"LRU" lt.eq k dot "faltas"_"Min" + k$.
]

Políticas randomizadas podem fazer muito melhor: o algoritmo de marcação randomizado é $O(log k)$-competitivo contra um adversário que não conhece suas escolhas aleatórias @fiat1991.

=== Onde a analogia falha

Os resultados acima pressupõem três coisas que, em contexto, não valem.

/ Itens de tamanhos diferentes: Asserções e documentos têm custos em tokens muito diferentes. O problema correspondente é o de _cache com pesos e tamanhos_: a política de Belady deixa de ser ótima, e o problema _offline_ torna-se NP-difícil @chrobak2012; no caso _online_, há algoritmos $k$-competitivos que generalizam LRU @young2002.

/ Faltas com custos diferentes: Trazer de volta um fato do acervo indexado custa uma chamada de ferramenta; reconstruir um fato da memória arqueológica pode custar uma investigação inteira; reobservar o mundo pode ter efeitos colaterais.

/ Faltas silenciosas: Esta é a diferença decisiva. Em hardware, uma falta de página é _detectada_: o processador tenta acessar um endereço, descobre que a página não está presente e invoca o sistema operacional. Num agente, a "falta" de um fato fora da janela frequentemente _não é percebida_: o modelo não tenta acessar um endereço; simplesmente raciocina com o que tem, e pode preencher a lacuna com uma suposição plausível. A falta silenciosa não custa uma recuperação — custa um erro.

#teorema(titulo: [Omissão declarada torna as faltas detectáveis])[
  Se a perspectiva satisfaz o axioma de omissão declarada (P5) e a renderização é honesta, então, para toda asserção aplicável e legível que não está na janela, o contexto contém uma declaração de exclusão ou uma alça de expansão que a cobre. Em particular, um consumidor que verifica as exclusões e alças antes de concluir que um fato não existe nunca confunde "fora da janela" com "inexistente".
] <teo-faltas-detectaveis>

#prova[
  Imediata do @lem-composicao-honesta: nada aplicável e legível desaparece sem declaração; logo, para cada asserção ausente da janela, há uma exclusão ou alça que a cobre, e o consumidor pode consultar essa cobertura antes de concluir.
]

O teorema identifica o papel das exclusões declaradas e das fronteiras de expansão na hierarquia de memória: elas são a _tabela de páginas_ do agente. Sem elas, a hierarquia não tem como sinalizar que algo existe num nível inferior; com elas, a falta passa a ser um evento detectável, que o consumidor pode tratar com uma expansão.

#exercicios[
  + Simule #proc("LRU") e #proc("Min") com $k = 3$ na sequência de 20 passos usada nos exercícios da primeira seção deste capítulo e compare o número de faltas.
  + Prove o @teo-belady por um argumento de troca: mostre que qualquer política ótima pode ser transformada, sem aumentar faltas, numa que concorda com #proc("Min") na primeira decisão.
  + Explique por que a hipótese de faltas detectáveis é essencial para a análise competitiva. O que significaria "razão competitiva" se algumas faltas fossem silenciosas e causassem erros em vez de recuperações?
  + #avancado Considere uma variante em que cada item tem um tamanho $s_i$ e a capacidade é $W$ (em tokens). Mostre que a regra "remover o item menos recentemente usado" pode ser arbitrariamente ruim em relação a uma regra que pondera recência e tamanho, construindo uma sequência adequada.
]

=== A relação de Denning e Schwartz #avancado

Um resultado clássico liga o tamanho médio do conjunto de trabalho à taxa de faltas, e explica por que o tamanho cresce cada vez mais devagar com a janela.

#proposicao(titulo: [Relação de Denning e Schwartz])[
  Suponha um único item referenciado por passo, custos unitários e um processo de referências estacionário. Seja $s(Delta) = E[|"WS"(t, Delta)|]$ o tamanho médio do conjunto de trabalho e $m(Delta)$ a probabilidade de a referência do passo $t + 1$ não estar em $"WS"(t, Delta)$ (a taxa de faltas). Então $s(Delta + 1) - s(Delta) = m(Delta)$; em consequência, $s$ é não decrescente e côncava em $Delta$.
] <prop-denning-schwartz>

#prova[
  Como $"WS"(t, Delta + 1) = "WS"(t, Delta) union {r_(t - Delta)}$, o tamanho cresce de 1 exatamente quando $r_(t - Delta)$ não é referenciado nos $Delta$ passos seguintes; logo $s(Delta + 1) - s(Delta) = a(Delta)$, a probabilidade de uma referência não se repetir nos $Delta$ passos seguintes. Seja $b(Delta) = m(Delta)$ a probabilidade de uma referência não ter ocorrido nos $Delta$ passos anteriores. Numa janela de $k + 1$ passos, cada item distinto tem exatamente uma primeira e uma última ocorrência; tomando esperanças e usando a estacionariedade, $sum_(j = 0)^k a(j) = sum_(j = 0)^k b(j)$ para todo $k$, e, por diferenças sucessivas, $a = b$. Finalmente, $m$ é não crescente (uma janela maior contém a anterior), e uma função cujas diferenças são não crescentes é côncava.
]

O resultado é de #ct(<denning1972>). Para o projeto de contexto, sua leitura é dupla: aumentar a janela de recência $Delta$ traz cada vez menos itens novos, e a taxa de faltas pode ser estimada observando apenas o crescimento do tamanho médio do conjunto de trabalho.

== Pressão de contexto e thrashing <sec-ws-thrashing>

Denning também explicou o _thrashing_ @denning1968thrashing: quando a soma dos conjuntos de trabalho dos processos em execução excede a memória disponível, cada processo passa a maior parte do tempo esperando páginas, o sistema faz pouco progresso útil e o desempenho colapsa. O remédio clássico não é uma política de substituição melhor, mas _controle de carga_: executar menos processos simultaneamente, de modo que cada um tenha espaço para seu conjunto de trabalho.

Agentes exibem um fenômeno análogo, que chamaremos de _pressão de contexto_.

#definicao(titulo: [Pressão de contexto])[
  Um agente está sob _pressão de contexto_ quando o tamanho de seu conjunto de trabalho, $omega(t, Delta)$, para uma janela $Delta$ adequada à tarefa, excede sua janela efetiva $W_"ef"$ (@def-janela-efetiva).
] <def-pressao>

Os sintomas são característicos: o agente relê os mesmos recursos repetidamente; esquece decisões tomadas poucos passos antes; alterna entre hipóteses sem convergir; compacta o contexto com frequência crescente e perde, a cada compactação, detalhes de que precisará em seguida. Os remédios também são análogos aos de sistemas operacionais:

- _reduzir a carga_: decompor a tarefa em subtarefas com conjuntos de trabalho menores, atribuídas a agentes distintos ou executadas em sequência, cada uma com sua perspectiva (@cap-orquestracao);
- _aumentar a densidade_: substituir conteúdo por referências e coordenadas, mantendo na janela apenas o que precisa ser lido (@cap-compressao);
- _aumentar a localidade_: reorganizar o trabalho para que referências consecutivas se concentrem em menos recursos — por exemplo, terminar um módulo antes de passar a outro.

#antipadrao(titulo: [Combater thrashing com compactação])[
  Diante de um agente sob pressão de contexto, o sistema compacta o contexto com mais frequência. Cada compactação libera espaço, mas descarta parte do conjunto de trabalho, que precisa ser recuperado em seguida, gerando nova pressão. Como no thrashing de memória, a política de substituição não é o problema; o problema é que a carga não cabe.
] <anti-compactar-thrashing>

#exercicios[
  + Proponha três métricas observáveis, a partir do registro de ações de um agente, que indiquem pressão de contexto.
  + Um agente precisa modificar 30 arquivos interdependentes e sua janela efetiva comporta cerca de 8. Proponha uma decomposição que reduza o conjunto de trabalho de cada subtarefa e discuta o custo de coordenação introduzido.
  + #avancado Modele o thrashing de contexto como no modelo clássico de memória virtual: se o conjunto de trabalho tem tamanho $omega$ e a janela efetiva comporta $k < omega$ itens, estime a taxa de faltas sob referências uniformes ao conjunto de trabalho e discuta por que compactar mais vezes não resolve.
]

== Estimando o conjunto de trabalho <sec-ws-estimativa>

Na prática, o conjunto de trabalho pode ser estimado a partir do registro de ações do agente — as chamadas de ferramentas e os identificadores mencionados em suas saídas. Isso permite duas aplicações.

A primeira é _antecipação_: ao calcular a perspectiva do próximo passo, incluir no núcleo os recursos do conjunto de trabalho recente, renderizados ao menos como referências resolúveis. Isso reduz faltas, e em particular faltas silenciosas.

A segunda é _diagnóstico_: o tamanho do conjunto de trabalho ao longo do tempo é um indicador da complexidade efetiva da tarefa e da adequação da decomposição. Uma tarefa cujo conjunto de trabalho não para de crescer é uma tarefa mal delimitada ou mal decomposta.

#algoritmo("Perspectiva-com-Conjunto-de-Trabalho", params: $Sigma, kappa, H, t, Delta, B$, legenda: [Perspectiva que combina núcleo suficiente por construção, conjunto de trabalho recente e fronteira.])[
  + $N <- $ #proc("Núcleo-por-Gabarito")$(Sigma, kappa)$ #h(1fr) ▷ @teo-suficiencia-construcao
  + #kw[se] $c(N) > B$ #kw[então] #kw[devolva] #estado[requerido ausente] (o núcleo não cabe no orçamento) #h(1fr) ▷ @inv-requerido-ausente
  + $"WS" <- union.big_(s = t - Delta + 1)^t "ref"_H (s)$ #h(1fr) ▷ conjunto de trabalho a partir do histórico $H$
  + $C <- N union ("WS" inter Sigma|_kappa)$
  + #kw[enquanto] $c(C) > B$ #kw[e] há itens de $"WS" without N$ não rebaixados #kw[faça]
    + rebaixe para #estado[só referência] o item de $"WS" without N$ menos recentemente usado
  + #kw[enquanto] $c(C) > B$ #kw[faça] retire de $C$ a referência rebaixada menos recentemente usada e registre-a em $X$
  + $X <- X union $ itens aplicáveis e legíveis fora de $C$, por categoria e contagem
  + $Phi <- $ alças de expansão para $X$ e para os itens rebaixados
  + #kw[devolva] a perspectiva $(C, R_C, U, X, Phi, mu)$ #h(1fr) ▷ relações entre itens de $C$, desconhecidos e metadados como em @def-perspectiva
] <alg-ws-perspectiva>

#exercicios[
  + No @alg-ws-perspectiva, por que os itens rebaixados passam a #estado[só referência] em vez de serem removidos? Relacione com o @teo-faltas-detectaveis.
  + Proponha uma forma de escolher $Delta$ automaticamente, com base na taxa de faltas observada.
  + Aplique o @alg-ws-perspectiva ao registro de 20 passos dos exercícios da primeira seção, com $tau = 5$, e liste os itens incluídos integralmente e os rebaixados a referência no passo 20.
]

#quadro[
  - O conjunto de trabalho contextual é o conjunto de recursos referenciados recentemente; localidade o torna bom preditor das próximas referências.
  - O estado de um recurso tem sete eixos independentes como representação, sujeitos a restrições verificáveis; armazene eixos e derive frases (@pri-eixos-frases). Colapsos armazenados são irreversíveis.
  - Camadas derivadas (perspectiva, conjunto de trabalho) não devem ser substantivadas sem necessidade comprovada; ambiente não é autoridade.
  - A teoria clássica de substituição (Belady, LRU, razão competitiva) se aplica com ressalvas: tamanhos e custos variam, e faltas de contexto podem ser silenciosas.
  - Exclusões declaradas e fronteiras são a "tabela de páginas" do agente: tornam as faltas detectáveis (@teo-faltas-detectaveis).
  - Pressão de contexto é o thrashing dos agentes: remédio é reduzir a carga, não compactar mais.
]

#problemas[
  #problema([Conjunto de trabalho e orçamento ótimo])[
    Suponha que a probabilidade de o agente precisar, no próximo passo, de um recurso fora de $"WS"(t, Delta)$ seja $phi(Delta)$, decrescente em $Delta$, e que o custo de uma falta detectável seja $C_f$ tokens.
    + Escreva o custo esperado por passo em função de $Delta$, incluindo o custo de manter $"WS"(t, Delta)$ na janela.
    + Mostre que, se $omega(t, Delta)$ é afim em $Delta$ e $phi(Delta)$ é convexa, o custo esperado é convexo e tem um único minimizador. Dê um contraexemplo com $omega$ côncava — que é o caso realista, pela relação de Denning e Schwartz (@prop-denning-schwartz) — em que o custo tem dois mínimos locais.
    + Como o resultado muda se uma fração $q$ das faltas for silenciosa, com custo de erro $C_e >> C_f$?
  ]
  #problema([Eixos e consumidores diferentes])[
    Um mesmo recurso tem estado (disponível, requer autenticação, aplicável, não selecionado, só referência, expansível).
    + Escreva a frase que um renderizador deveria derivar para um consumidor humano e a que deveria derivar para um agente.
    + Mostre que ambas as frases podem ser derivadas da tupla, mas que nenhuma das duas permite reconstruir a tupla.
    + Proponha um formato de renderização que preserve a tupla e ainda seja legível.
  ]
  #problema([Controle de carga entre agentes])[
    Vários agentes compartilham um orçamento total de tokens por unidade de tempo.
    + Formule, à maneira do controle de carga de sistemas operacionais, uma política de admissão de tarefas baseada no tamanho estimado dos conjuntos de trabalho.
    + Mostre que admitir uma tarefa adicional quando a soma dos conjuntos de trabalho já excede o orçamento pode reduzir o progresso total.
    + #avancado Relacione sua política à teoria de filas e discuta métricas de justiça entre tarefas.
  ]
]

#notas[
  O conjunto de trabalho foi introduzido por #ct(<denning1968>) e o thrashing analisado em #ct(<denning1968thrashing>); #ct(<denning1970>) é um panorama clássico de memória virtual, e #ct(<denning2005>) revisita o princípio da localidade décadas depois. A política ótima de substituição é de #ct(<belady1966>); #ct(<mattson1970>) desenvolveram a teoria de algoritmos de pilha que permite calcular faltas para todas as capacidades de uma vez. A análise competitiva de paginação é de #ct(<sleator1985>), o algoritmo de marcação randomizado é de #ct(<fiat1991>), e #ct(<borodin1998>) é a referência abrangente sobre computação online. A analogia entre modelos de linguagem e sistemas operacionais foi proposta explicitamente por #ct(<packer2023>), e o gerenciamento paginado do cache KV é de #ct(<kwon2023>).

  A decomposição do estado de um recurso em eixos, a crítica às enumerações cartesianas e o princípio de não substantivar camadas derivadas são propostas deste livro. A recomendação de derivar frases a partir de dados estruturados, e não o contrário, é um caso particular da separação entre modelo e apresentação, antiga em engenharia de software.
]
