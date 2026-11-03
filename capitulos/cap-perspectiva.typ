#import "/modelo/estilo.typ": *

= O núcleo de projeção: compondo perspectivas <cap-perspectiva>

#epigrafe[Programe o espaço de estados observável, não a resposta.]

O @cap-modelo definiu a projeção $pi$ por seus axiomas: somente leitura, determinismo, limitação por autoridade, honestidade, omissão declarada e estabilidade. Este capítulo mostra como implementá-la. A ideia central é que a composição de uma perspectiva pode — e deve — ser uma _função pura_: um cálculo sobre fatos já adquiridos, sem acesso a rede, sistema de arquivos ou controle de versão, que pode ser executado, testado e verificado independentemente de onde e por quem é chamado. Toda a complexidade de obter fatos fica num estágio separado; toda a complexidade de apresentá-los, noutro.

A @sec-persp-estagios separa os quatro estágios do cálculo e seus donos. A @sec-persp-regras apresenta fatos tipados e regras. A @sec-persp-ponto-fixo descreve a composição como cálculo de ponto fixo e prova sua unicidade. A @sec-persp-metamorficas enuncia e prova as propriedades metamórficas do núcleo. A @sec-persp-complexidade analisa o custo. A @sec-persp-facetas trata de perfis e do grafo acíclico de facetas. A @sec-persp-turno descreve o turno preparado. A @sec-persp-superficies prova a invariância entre superfícies e discute a evolução segura do núcleo.

== Quatro estágios e seus donos <sec-persp-estagios>

#definicao(titulo: [Estágios da produção de contexto])[
  A produção do contexto de um consumidor tem quatro estágios, com donos distintos:
  + _aquisição_: obter, limitadamente, os fatos necessários — observar o mundo, ler o acervo, consultar serviços (envolve entrada e saída);
  + _composição_: calcular a perspectiva a partir dos fatos adquiridos e da coordenada (função pura);
  + _renderização_: transformar a perspectiva em contexto para um consumidor e um orçamento (@def-renderizacao);
  + _transporte_: entregar o contexto ao consumidor por uma superfície (protocolo de ferramentas, linha de comando, interface).
] <def-quatro-estagios>

#invariante(titulo: [Aquisição, composição, renderização e transporte são distintos])[
  Nenhum estágio faz o trabalho de outro. A composição não lê arquivos nem consulta o controle de versão; a renderização não recalcula relações nem atribui estatutos; o transporte não altera conteúdo. Quando um renderizador consulta o controle de versão "para completar a informação", ele se torna uma segunda composição, que divergirá da primeira.
] <inv-quatro-estagios>

A separação tem uma vantagem imediata para verificação: o estágio de composição, sendo puro, pode ser testado com conjuntos de fatos fabricados, sem ambiente real; e todas as superfícies que o chamam herdam suas garantias.

#exercicios[
  + Classifique nos quatro estágios: listar arquivos de um diretório; decidir que uma unidade de trabalho não se aplica à coordenada; truncar uma lista para caber no orçamento; enviar o contexto por um protocolo de ferramentas.
  + Descreva uma falha produzida quando o renderizador de uma interface gráfica lê diretamente o estado do controle de versão em vez de usar a perspectiva.
  + Mostre que, se a composição não faz entrada e saída, então ela pode ser testada sem nenhum serviço externo. Proponha a estrutura de um teste unitário do estágio de composição.
]

== Fatos tipados e regras <sec-persp-regras>

#definicao(titulo: [Fato tipado])[
  Um _fato tipado_ é uma asserção do acervo (@def-assercao) acrescida da coordenada de sua fonte (de onde o fato vem), da coordenada de sua observação (quem, onde, quando observou) e de seu frescor. Fatos são imutáveis durante uma composição.
] <def-fato-tipado>

#definicao(titulo: [Regra de composição])[
  Uma _regra de composição_ tem a forma
  $ h(arrow(x)) arrow.l b_1 (arrow(x)_1), dots, b_k (arrow(x)_k) $
  em que a _cabeça_ $h$ é uma relação derivada e o _corpo_ é uma conjunção de átomos sobre fatos ou relações derivadas, com variáveis. Cada regra tem um identificador e uma versão.
] <def-regra-composicao>

O estatuto das relações derivadas exige cuidado. Uma regra de Horn deriva uma cabeça _a partir_ de um corpo; o estatuto da cabeça não pode ser maior que o que o corpo sustenta, e uma mesma cabeça pode ter várias derivações. A definição seguinte trata estatutos como anotações num reticulado, à maneira dos semianéis de proveniência do @cap-proveniencia.

#definicao(titulo: [Anotação de estatuto])[
  Para uma derivação $m$ de uma cabeça $h$, com corpo $b_1, dots, b_k$, o estatuto de $m$ é: #est[provado] se todos os $sigma(b_j) = #est[provado]$; #est[conflitante] se algum $sigma(b_j) = #est[conflitante]$ e nenhum é #est[desconhecido] ou #est[refutado]; e #est[desconhecido] nos demais casos. O estatuto de $h$ é o supremo, na ordem de informação, dos estatutos de suas derivações: $sigma(h) = scripts(union.sq)_i {sigma(m) : m "derivação de" h}$. Uma regra de Horn nunca produz #est[refutado]: refutações só entram por fatos ou por regras de negação explícita (@pri-negacao-evidencia).
] <def-anotacao-estatuto>

A definição evita as duas leituras erradas da expressão "ínfimo dos estatutos do corpo". Tomado na ordem de verdade de Belnap, o ínfimo de #est[desconhecido] e #est[conflitante] é #est[refutado] — uma regra fabricaria uma refutação que nenhuma premissa sustenta. Tomado na ordem de informação, o ínfimo de #est[conflitante] e #est[provado] é #est[provado] — uma conclusão tirada de premissa contestada sairia limpa. A anotação acima não promove nem lava estatutos.

Regras desse tipo são cláusulas de Horn, e um conjunto delas é um programa _Datalog_ @abiteboul1995. A escolha é deliberada: Datalog é expressivo o bastante para relações de aplicabilidade, seleção, alcançabilidade restrita e classificação, e suficientemente restrito para ter semântica de ponto fixo única e custo polinomial.

#exemplo(titulo: [Regras de seleção de trabalho])[
  As regras a seguir derivam a unidade de trabalho selecionada a partir de fatos de pedido, ponteiro padrão e aplicabilidade, sem nenhuma regra de "primeira aberta":
  $ "selecionada"(u, "pedido") &arrow.l "pedido"(q), "resolve"(q, u) \
    "selecionada"(u, "padrão") &arrow.l "sem-pedido"(), "padrão"(u), "aplicável"(u) $
  A ausência de qualquer fato que derive "selecionada" é representada por um desconhecido explícito ("nenhuma selecionada"), nunca por uma escolha.
] <ex-regras-selecao>

#exercicios[
  + Escreva regras que derivem "aplicável$(a, kappa)$" a partir de fatos sobre o domínio de $a$, o locus de $kappa$ e uma relação de pertinência.
  + Mostre que a @def-anotacao-estatuto nunca atribui a uma cabeça um estatuto maior, na ordem de informação, que o que suas premissas sustentam, e relacione com o axioma de honestidade (P4).
  + Mostre, com um exemplo, que "ínfimo na ordem de verdade" produz #est[refutado] a partir de premissas #est[desconhecido] e #est[conflitante].
  + Escreva uma regra de composição que derive "bloqueado$(w, kappa)$" para uma unidade de trabalho cuja reserva pertence a outro consumidor, e discuta qual deve ser o estatuto da conclusão quando a reserva é desconhecida.
]

== A composição como ponto fixo <sec-persp-ponto-fixo>

#algoritmo("Compõe", params: $F, kappa, cal(R)$, legenda: [O núcleo puro de composição. $F$ são os fatos adquiridos, $kappa$ a coordenada e $cal(R)$ o conjunto versionado de regras, particionado em estratos. Devolve a perspectiva e o traço de composição.])[
  + $F' <- {f in F : f$ legível sob o teto de $kappa}$ #h(1fr) ▷ P3
  + $D <- emptyset$; $theta <- emptyset$ #h(1fr) ▷ relações derivadas anotadas e traço
  + #kw[para cada] estrato $cal(R)_i$, em ordem #kw[faça]
    + #kw[repita]
      + $"mudou" <- "falso"$
      + #kw[para cada] regra $r in cal(R)_i$ e casamento $m$ do corpo de $r$ em $F' union D$ #kw[faça]
        + $h <- $ cabeça de $r$ instanciada por $m$; $sigma_"novo" <- sigma(h) union.sq_i sigma(m)$ #h(1fr) ▷ @def-anotacao-estatuto
        + #kw[se] $h in.not D$ #kw[ou] $sigma_"novo" != sigma(h)$ #kw[então] registre $(h, sigma_"novo")$ em $D$; $theta <- theta union {(h, r, m)}$; $"mudou" <- "verdadeiro"$
    + #kw[até] $not "mudou"$
  + $U <- $ perguntas de $Q(kappa)$ sem fato ou relação que as decida #h(1fr) ▷ mundo aberto
  + $X, Phi <- $ exclusões declaradas e alças de expansão #h(1fr) ▷ P5
  + #kw[devolva] $((F' "aplicáveis", D, U, X, Phi, mu), theta)$
] <alg-compoe>

Cada estrato chega ao seu ponto fixo antes de o seguinte começar — condição necessária para a semântica de programas estratificados @apt1988. Para regras _positivas_ (sem negação no corpo), a semântica do laço interno é bem conhecida. Seja $I$ o conjunto de interpretações (conjuntos de átomos derivados) ordenado por inclusão, e $T: I -> I$ o _operador de consequência imediata_: $T(D)$ é o conjunto de cabeças de todas as regras cujos corpos são satisfeitos em $F' union D$.

#teorema(titulo: [Ponto fixo mínimo e independência de ordem])[
  Para um programa positivo finito sobre fatos finitos: (i) $T$ é monótono e tem um menor ponto fixo $"lfp"(T)$, obtido pela iteração $emptyset subset.eq T(emptyset) subset.eq T^2(emptyset) subset.eq dots$; (ii) qualquer estratégia de aplicação de regras que seja _justa_ — que aplique, até a estabilização, toda regra a todo casamento disponível — termina exatamente em $"lfp"(T)$, independentemente da ordem de aplicação das regras e da ordem dos fatos.
] <teo-ponto-fixo>

#prova[
  (i) Se $D subset.eq D'$, todo corpo satisfeito em $F' union D$ é satisfeito em $F' union D'$; logo $T(D) subset.eq T(D')$. O reticulado das interpretações sobre o universo finito de átomos é finito, e o @teo-ap-kleene garante que a iteração a partir de $emptyset$ atinge o menor ponto fixo.

  (ii) _Correção_: toda aplicação de regra acrescenta a $D$ uma cabeça cujo corpo está satisfeito em $F' union D$; por indução no número de aplicações, $D subset.eq "lfp"(T)$ em todo momento (pois $D subset.eq "lfp"(T)$ implica $T(D) subset.eq T("lfp"(T)) = "lfp"(T)$). _Completude_: na estabilização, nenhuma regra justa produz cabeça nova, ou seja, $T(D) subset.eq D$; $D$ é um pré-ponto fixo, e pelo @teo-ap-tarski o menor ponto fixo está contido em todo pré-ponto fixo, logo $"lfp"(T) subset.eq D$. Portanto $D = "lfp"(T)$, qualquer que tenha sido a ordem.
]

#corolario(titulo: [Determinismo da composição])[
  Para regras positivas, o @alg-compoe satisfaz o axioma de determinismo (P2): o mesmo conjunto de fatos, a mesma coordenada e as mesmas regras produzem o mesmo conjunto de relações derivadas _e as mesmas anotações de estatuto_, para qualquer ordem de leitura dos fatos e de aplicação das regras.
] <cor-determinismo>

#prova[
  Para o conjunto de relações, é o @teo-ponto-fixo. Para as anotações, considere o operador que leva uma atribuição de anotações aos átomos à atribuição das cabeças pela @def-anotacao-estatuto: ele é monótono na ordem de informação componente a componente (o estatuto de uma derivação é monótono nos estatutos do corpo, e o supremo é monótono), e o reticulado das atribuições é finito. Pelo @teo-ap-kleene, a iteração a partir da atribuição vazia converge para um único menor ponto fixo; e, como no @teo-ponto-fixo, qualquer estratégia justa de aplicação termina nele.
]

#exercicios[
  + Execute o @alg-compoe à mão com as regras do @ex-regras-selecao e três conjuntos de fatos diferentes.
  + Mostre que o traço $theta$ pode depender da ordem de aplicação (duas derivações diferentes da mesma cabeça), mas que o conjunto $D$ e suas anotações não. Proponha como tornar também o traço determinístico.
  + #avancado Mostre que o operador de consequência imediata de um programa Datalog positivo é monótono e contínuo no reticulado dos conjuntos de fatos, e conclua, pelo teorema de Kleene, que o ponto fixo mínimo é atingido em, no máximo, tantas iterações quantos forem os fatos deriváveis.
]

== Propriedades metamórficas <sec-persp-metamorficas>

Uma _propriedade metamórfica_ relaciona as saídas de um programa para entradas transformadas de maneira conhecida — por exemplo, "permutar a entrada não muda a saída". Elas são valiosas para testar programas cuja saída correta é difícil de calcular diretamente @chen1998 @chen2018. O núcleo de composição tem várias, todas consequências da estrutura de Datalog.

#proposicao(titulo: [Monotonicidade])[
  Para regras positivas, se $F subset.eq G$ então $"lfp"(T_F) subset.eq "lfp"(T_G)$. Em palavras: acrescentar fatos nunca remove relações derivadas; e, equivalentemente, remover fatos nunca cria uma relação derivada. (Para _estatutos_ a afirmação é mais fraca: remover uma refutação pode levar #est[conflitante] a #est[provado].)
] <prop-monotonicidade>

#prova[
  Todo corpo satisfeito com os fatos de $F$ é satisfeito com os de $G$; por indução na iteração de Kleene, cada $T_F^k (emptyset) subset.eq T_G^k (emptyset)$.
]

#proposicao(titulo: [Localidade])[
  Para regras positivas, as relações em $"lfp"(T_(F union {f})) without "lfp"(T_F)$ são exatamente aquelas que são deriváveis de $F union {f}$ e cujas derivações _todas_ usam o fato $f$.
] <prop-localidade>

#prova[
  Se uma relação nova tivesse todas as suas derivações sem $f$, ela já seria derivável de $F$ e estaria em $"lfp"(T_F)$. Reciprocamente, uma relação com alguma derivação que usa $f$ e nenhuma sem $f$ não está em $"lfp"(T_F)$. (É a caracterização da proveniência "por quê" de #ct(<buneman2001>).)
]

#proposicao(titulo: [Genericidade])[
  Se nenhuma regra menciona constantes de identidade (identificadores específicos de recursos), então a composição comuta com renomeações: para toda bijeção $beta$ dos identificadores, $"lfp"(T_(beta(F))) = beta("lfp"(T_F))$.
] <prop-genericidade>

#prova[
  Uma regra sem constantes casa com $beta(F)$ exatamente nos pontos em que casa com $F$, transportados por $beta$; por indução na iteração, as interpretações correspondem por $beta$. (É a noção de consulta genérica de #ct(<chandra1980>).)
]

A genericidade tem uma consequência de projeto que vale a pena destacar: regras que mencionam identificadores específicos — `se pedido = X então ...` — são exemplos disfarçados de regras. Elas quebram a genericidade, não se aplicam a casos não previstos e costumam nascer de testes: alguém transformou um caso de teste em regra.

#principio(titulo: [Exemplo não é regra])[
  Casos de teste ilustram o comportamento; não o legislam. Uma regra que só existe para fazer um caso específico passar deve ser substituída por uma regra genérica que explique o caso — ou o caso é um sinal de que falta um fato.
] <pri-exemplo-regra>

=== Negação e mundo aberto

Regras com negação no corpo ("aplicável se _não_ há fato de exclusão") quebram a monotonicidade: acrescentar um fato pode remover conclusões. A semântica _estratificada_ dá significado preciso a programas com negação em camadas @abiteboul1995, mas a pergunta epistemológica permanece: o que significa "não há fato"?

#principio(titulo: [Negação só de evidência negativa])[
  Uma regra que conclui uma negação (#est[refutado]) só pode usar no corpo evidência negativa explícita — fatos com estatuto #est[refutado], ou fatos de completude declarada (@pri-evidencia-negativa). A mera ausência de fatos _sobre o mundo_ produz #est[desconhecido], nunca #est[refutado].
] <pri-negacao-evidencia>

Há, porém, uma forma de negação por ausência que o modelo precisa e que é legítima: a ausência de registros _no próprio acervo_. "Esta asserção está vigente" significa "não há, no acervo, asserção que a suplante" — e o acervo é, por construção, completo sobre o que ele mesmo registrou. A negação por ausência é legítima quando se refere a registros do acervo (mundo fechado sobre o acervo) e ilegítima quando se refere ao mundo (não há processo em execução), que exige evidência negativa. A consequência é que a composição é monótona na ordem de informação apenas para acervos sem suplantação; com suplantação, acrescentar uma asserção pode levar #est[provado] a #est[refutado], e a reprodutibilidade (P2) depende de fixar $Sigma_t$.

#exercicios[
  + Construa um programa com negação estratificada em que acrescentar um fato remove uma conclusão. Reescreva-o usando a disciplina do @pri-negacao-evidencia.
  + Escreva três testes metamórficos para o núcleo de composição de um sistema que você conhece (permutação, renomeação, acréscimo de fato irrelevante).
  + Para a @prop-localidade, construa um teste que altere um fato fora do fecho de dependências de uma conclusão e verifique que ela não muda. Que falha de implementação esse teste detectaria?
]

== Complexidade <sec-persp-complexidade>

#teorema(titulo: [Complexidade de Datalog])[
  Para um programa Datalog fixo, avaliar o menor ponto fixo é PTIME-completo no tamanho dos fatos (_complexidade de dados_). Quando o programa também faz parte da entrada (_complexidade combinada_), o problema é EXPTIME-completo.
] <teo-complexidade-datalog>

O resultado é de #ct(<vardi1982>); a prova está em @abiteboul1995. Para engenharia de contexto, sua leitura é tranquilizadora: com regras fixas e versionadas, compor perspectivas é polinomial nos fatos, e técnicas como a avaliação _semi-ingênua_ — que, a cada iteração, só considera casamentos que usam pelo menos uma relação derivada na iteração anterior — evitam rederivar o que já foi derivado, embora o custo continue limitado pelo número de instanciações de regras, e não pelo tamanho da saída (o fecho transitivo, por exemplo, pode exigir $O(n^3)$ passos para uma saída $O(n^2)$). O recurso escasso não é a computação da composição; é a _aquisição_ de fatos (entrada e saída, latência, autoridade) e os _tokens_ da renderização. Por isso o núcleo pode ser executado a cada pedido, sem caches que arrisquem violar P2.

#exercicios[
  + Explique a avaliação semi-ingênua e por que ela produz o mesmo resultado que a ingênua.
  + Estime o custo da composição para um acervo com $10^5$ fatos e regras de alcançabilidade restrita de profundidade limitada.
  + Explique a diferença entre complexidade de dados e complexidade combinada de Datalog e por que, para sistemas de contexto com regras fixas e acervos grandes, a primeira é a medida relevante.
]

== Perfis e o grafo de facetas <sec-persp-facetas>

Na prática, a perspectiva para uma coordenada é organizada em _facetas_: partes com significado próprio (a identidade do domínio, o trabalho selecionado, a autoridade, os desconhecidos, a fronteira), cada uma calculada por um _resolvedor_ a partir dos fatos e de outras facetas.

#definicao(titulo: [Perfil e grafo de facetas])[
  Um _perfil_ é um grafo dirigido acíclico de facetas, em que uma aresta $(f, g)$ indica que o resolvedor de $g$ usa o resultado de $f$. Um _resolvedor_ é uma função pura de um instantâneo fixo de fatos e dos resultados de suas facetas predecessoras. Calcular o perfil é avaliar os resolvedores numa ordem topológica.
] <def-grafo-facetas>

#teorema(titulo: [Determinismo do grafo de facetas])[
  Se os resolvedores são puros, definidos sobre _conjuntos_ (e não sobre listas) de fatos e de resultados, e o instantâneo de fatos é fixo, o resultado do perfil é o mesmo para qualquer ordem topológica do grafo de facetas e para qualquer permutação das entradas.
] <teo-facetas>

#prova[
  Por indução na posição numa ordem topológica: o resultado de cada faceta é uma função pura do instantâneo e dos resultados de seus predecessores, que, por hipótese de indução, são os mesmos em qualquer ordem topológica (todo predecessor aparece antes, em qualquer delas). Logo o resultado de cada faceta independe da ordem escolhida. A invariância a permutações segue de os resolvedores serem funções de conjuntos: uma função pura de uma _lista_ pode depender da ordem, e por isso a hipótese é necessária.
]

#exercicios[
  + Projete o grafo de facetas para o perfil "revisar uma mudança": identidade do domínio, candidato, linha de base, evidências, autoridade, desconhecidos, fronteira.
  + Dê um exemplo de resolvedor impuro (que lê o relógio, o sistema de arquivos ou um cache mutável) e mostre como ele quebra o @teo-facetas.
  + Mostre que, se o grafo de facetas tiver um ciclo, não há ordem topológica de resolução, e proponha como detectar e relatar o ciclo ao autor do perfil.
]

== O turno preparado <sec-persp-turno>

Num sistema que serve agentes interativos, a unidade de trabalho do núcleo é o _turno_: o que a aplicação tenta fazer agora. O pipeline completo de um turno junta os quatro estágios com a seleção do @cap-selecao.

#definicao(titulo: [Ciclo de vida de um componente de contexto])[
  Um componente de contexto passa pelos estados: #estado[disponível] (o hospedeiro pode legitimamente fornecê-lo) → #estado[selecionado] (escolhido para o turno, com classe de participação: em linha, sob demanda ou omitido) → #estado[materializado] (efetivamente obtido) → #estado[projetado] → #estado[renderizado] → #estado[consumido]. Cada estado pressupõe o anterior, mas nenhum implica o seguinte. Esta é a mesma ordem da cadeia de restrição (@def-cadeia-restricao), vista do ponto de vista de um componente: a disponibilidade já incorpora o filtro de autoridade ("legitimamente").
] <def-ciclo-componente>

#algoritmo("Prepara-Turno", params: $e, kappa$, legenda: [Preparação de um turno: resolver, selecionar, adquirir, projetar, renderizar e planejar.])[
  + $t <- $ #proc("Resolve-Turno")$(e, kappa)$ #h(1fr) ▷ o que se pretende; não executa
  + $A <- $ componentes que o hospedeiro pode legitimamente fornecer
  + $S <- $ #proc("Seleciona")$(t, A)$ #h(1fr) ▷ em linha / sob demanda / omitido, com razões
  + $M <- $ requeridos $without A$
  + #kw[se] $M != emptyset$ #kw[então] plano $<- $ #estado[bloqueado] (contexto requerido ausente: $M$)
  + $F <- $ fatos já carregados $union$ #proc("Adquire")$(S_"em linha" without$ materializados$)$ #h(1fr) ▷ sob demanda não vira leitura antecipada
  + $P <- $ #proc("Perfil")$(F, kappa)$ #h(1fr) ▷ grafo de facetas
  + $c <- rho(P, B, u)$
  + #kw[devolva] turno preparado $(A, S, F, P, c, $ plano: executável ou bloqueado$)$
] <alg-prepara-turno>

Duas decisões do algoritmo merecem nota. A falta de contexto requerido (linha 5) é um _resultado_ — um plano bloqueado com a lista do que falta —, não uma exceção; isso permite ao consumidor saber o que pedir. E a aquisição só materializa o que foi selecionado _em linha_: componentes sob demanda permanecem como alças de expansão, sem custo de entrada e saída antecipado.

#exercicios[
  + Por que a seleção (linha 3) deve ser feita uma única vez, antes da aquisição? Que problema surgiria se a aquisição pudesse "re-selecionar"?
  + Mostre como o turno preparado expõe, para auditoria, cada etapa do ciclo de vida de um componente.
  + Descreva o turno preparado para a pergunta "por que o serviço $S$ está lento?", indicando, para cada componente de contexto, os estados disponível, selecionado, materializado, projetado e renderizado.
]

== Montagem compartilhada e invariância de superfície <sec-persp-superficies>

Um mesmo sistema de contexto costuma ter várias superfícies: uma ferramenta de linha de comando, um servidor de ferramentas para agentes, uma interface gráfica. Se cada uma calcular sua própria versão da perspectiva, elas vão divergir — "terceira superfície, terceiro comportamento".

#teorema(titulo: [Invariância de superfície])[
  Suponha que a composição seja uma função pura da coordenada (@def-coordenada) e de um estado observado, e que todas as superfícies obtenham a perspectiva chamando a mesma função de montagem compartilhada. Então duas superfícies que recebem a mesma coordenada e o _mesmo_ estado observado produzem perspectivas com o mesmo núcleo semântico, independentemente do diretório de trabalho do processo e do formato de apresentação.
] <teo-superficie>

#prova[
  O núcleo semântico é o valor da mesma função aplicada aos mesmos argumentos; as superfícies diferem apenas na renderização e no transporte, que, pelo @inv-quatro-estagios, não alteram o conteúdo semântico. O diretório de trabalho não é argumento da função (@inv-diretorio-sessao).
]

#exemplo(titulo: [Contraexemplo: junção na superfície])[
  Uma superfície de linha de comando calcula a seleção de trabalho com a função compartilhada; o servidor de ferramentas, para responder mais rápido, implementa sua própria junção entre o inventário e o ponteiro padrão — e esquece a verificação de aplicabilidade. Para uma coordenada em que o ponteiro padrão aponta para uma unidade selada, as duas superfícies dão respostas diferentes. A hipótese violada é "todas chamam a mesma função".
] <ex-juncao-superficie>

#principio(titulo: [Um contrato semântico, muitas implementações conformes])[
  A semântica da perspectiva é definida uma vez — pelas regras e pelos axiomas — e verificada por uma suíte de conformidade. Se for necessário ter várias implementações (por exemplo, em linguagens diferentes), todas passam pela mesma suíte; nenhuma superfície recalcula semântica.
] <pri-contrato-conformes>

=== Evolução segura: modo sombra

Mudar o núcleo de composição é arriscado: uma regra nova pode alterar perspectivas de muitos consumidores. Uma técnica eficaz é o _modo sombra_: executar o núcleo novo sobre os fatos reais, em paralelo ao vigente, registrando as diferenças sem entregá-las a nenhum consumidor. As diferenças são classificadas — esperadas (a mudança pretendida), regressões, ou correções de erros antigos — antes de a nova versão substituir a anterior.

#exercicios[
  + Projete uma suíte de conformidade mínima entre duas superfícies, especificando quais campos comparar e quais diferenças são aceitáveis (por exemplo, formatação).
  + Descreva o processo de migração de uma regra por modo sombra, incluindo o critério de promoção.
  + Construa um exemplo em que duas superfícies que chamam o mesmo núcleo de composição ainda assim divergem, por causa de uma diferença no estágio de renderização. Que parte da @teo-superficie isso viola, se alguma?
]

#quadro[
  - Quatro estágios com donos distintos: aquisição, composição (pura), renderização, transporte.
  - Fatos tipados e regras de Horn; o estatuto derivado é o ínfimo do corpo — regras nunca promovem.
  - A composição é o menor ponto fixo do operador de consequência: única e independente de ordem (@teo-ponto-fixo).
  - Propriedades metamórficas: monotonicidade, localidade, genericidade; exemplo não é regra; negação só de evidência negativa.
  - Compor é polinomial nos fatos; o recurso escasso é aquisição e tokens.
  - Perfis como grafos de facetas puros são determinísticos (@teo-facetas); o turno preparado expõe cada etapa do ciclo de vida.
  - Montagem compartilhada garante invariância de superfície (@teo-superficie); evolua o núcleo em modo sombra.
]

#problemas[
  #problema([Implementação semi-ingênua com traço])[
    Implemente o @alg-compoe com avaliação semi-ingênua e traço de composição.
    + Prove que a implementação produz o mesmo $D$ que a ingênua.
    + Prove a @prop-localidade usando o traço: mostre como calcular, a partir dele, as relações afetadas pela remoção de um fato.
    + Analise o custo em função do número de fatos e do tamanho da saída.
  ]
  #problema([Conformidade entre implementações])[
    Duas equipes implementam o núcleo de composição em linguagens diferentes.
    + Especifique uma suíte de conformidade baseada em propriedades metamórficas, sem precisar de saídas esperadas escritas à mão.
    + Mostre que a suíte detecta a violação do @ex-juncao-superficie.
    + Discuta o que a suíte não consegue detectar e como complementá-la.
  ]
  #problema([Manutenção incremental])[
    Fatos mudam continuamente; recalcular toda a perspectiva a cada mudança pode ser caro em acervos grandes.
    + Relacione o problema à manutenção incremental de visões materializadas @gupta1995.
    + Explique por que a remoção de fatos é mais difícil que o acréscimo em Datalog, e como o traço ajuda.
    + Discuta o risco de violar o determinismo (P2) com caches incrementais e como mitigá-lo.
  ]
]

#notas[
  A semântica de ponto fixo de programas lógicos é de #ct(<vanemden1976>); #ct(<abiteboul1995>) é a referência para Datalog, negação estratificada e avaliação semi-ingênua, e a complexidade de linguagens de consulta relacionais foi estabelecida por #ct(<vardi1982>). A noção de consulta genérica é de #ct(<chandra1980>); a caracterização da proveniência "por quê" que sustenta a @prop-localidade é de #ct(<buneman2001>), e os semianéis de proveniência @green2007 generalizam o traço de composição. Testes metamórficos foram propostos por #ct(<chen1998>) e revisados por #ct(<chen2018>). A manutenção incremental de visões @gupta1995 é o análogo direto da recomposição de perspectivas quando o acervo muda. A separação entre função pura e efeitos é um princípio antigo de projeto de software @parnas1972, aqui aplicada com consequências epistemológicas: só uma composição pura pode prometer que "o mesmo acervo e a mesma coordenada dão a mesma perspectiva".

  A formulação do núcleo como cálculo puro sobre fatos já adquiridos, a separação em quatro estágios, as propriedades metamórficas, o modo sombra e a exigência de montagem compartilhada entre superfícies resultaram de um esforço de reconstrução de um sistema cujas superfícies haviam divergido — cada uma com sua própria versão de junções e padrões —, e no qual regras específicas para casos de teste haviam se acumulado no código.
]
