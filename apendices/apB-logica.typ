#import "/modelo/estilo.typ": *

= Lógica, verdade parcial e conhecimento <ap-logica>

Um tema recorrente deste livro é que um agente raramente sabe tudo o que precisaria saber, e que a forma como representamos essa ignorância determina se ele age com segurança. Este apêndice reúne as ferramentas lógicas para tratar o assunto com precisão: a distinção entre mundo fechado e mundo aberto; as lógicas de três e quatro valores, que dão significado formal a "desconhecido" e a "contraditório"; a lógica epistêmica, que permite falar do que um agente sabe (e do que sabe sobre o que outros sabem); e a teoria da revisão de crenças, que descreve como um conjunto de crenças deve mudar diante de informação nova.

== Lógica clássica e a hipótese de mundo fechado <sec-ap-mundo-fechado>

Na lógica proposicional clássica, uma _valoração_ atribui a cada variável um valor em ${sans(V), sans(F)}$, e os conectivos têm as tabelas-verdade usuais. Um conjunto de fórmulas $Gamma$ _acarreta_ $phi$ ($Gamma models phi$) se toda valoração que satisfaz $Gamma$ satisfaz $phi$. A lógica de primeira ordem estende esse quadro com variáveis de indivíduo, predicados e quantificadores; não precisaremos de seus detalhes.

Quando um banco de dados (ou um acervo de fatos) é consultado, há duas leituras possíveis da ausência de um fato.

#definicao(titulo: [Hipóteses de mundo fechado e de mundo aberto])[
  Sob a _hipótese de mundo fechado_ (CWA, do inglês _closed-world assumption_), todo fato atômico que não consta do acervo é considerado falso. Sob a _hipótese de mundo aberto_ (OWA), um fato que não consta do acervo tem valor _desconhecido_: nem sua verdade nem sua falsidade podem ser inferidas da ausência.
] <def-ap-cwa>

A CWA foi formalizada por #ct(<reiter1978>) e é apropriada quando o acervo é, por construção, completo em relação ao domínio — por exemplo, a tabela de voos de uma companhia aérea, se nenhum voo é operado sem constar dela. Ela é inadequada quando o acervo é uma _observação parcial_ do mundo, como é quase sempre o caso para um agente que trabalha num ambiente de software real: o fato de o agente não ter visto um processo em execução, uma permissão concedida ou uma relação entre dois artefatos não prova que eles não existam. Grande parte dos erros discutidos no @cap-epistemologia são aplicações indevidas da CWA a acervos que só sustentam a OWA. O valor nulo dos bancos de dados relacionais é uma tentativa histórica, e notoriamente problemática, de acomodar informação ausente dentro de um modelo essencialmente fechado @codd1979.

#exercicios[
  + Um agente lista os arquivos de configuração que consegue ler e não encontra nenhum que conceda acesso de escrita a um diretório. Formule as conclusões que ele pode tirar sob CWA e sob OWA. Qual delas é justificável se a listagem pode ter sido truncada?
  + Dê um exemplo de domínio em que a CWA é correta e explique qual propriedade do processo de registro garante essa correção.
]

== A lógica de três valores de Kleene <sec-ap-kleene>

A lógica _forte_ de três valores de Kleene, $K_3$, acrescenta um terceiro valor, que escreveremos $sans(D)$ (desconhecido), aos valores $sans(V)$ e $sans(F)$ @kleene1952. As tabelas são escolhidas de modo que o resultado seja $sans(D)$ exatamente quando substituir $sans(D)$ por $sans(V)$ ou por $sans(F)$ pudesse mudar o resultado.

#figure(
  grid(
    columns: 2,
    column-gutter: 2.2em,
    tabela(
      colunas: 4,
      alinhamento: center,
      cabecalho: ([$and$], [$sans(V)$], [$sans(D)$], [$sans(F)$]),
      [$sans(V)$], [$sans(V)$], [$sans(D)$], [$sans(F)$],
      [$sans(D)$], [$sans(D)$], [$sans(D)$], [$sans(F)$],
      [$sans(F)$], [$sans(F)$], [$sans(F)$], [$sans(F)$],
    ),
    tabela(
      colunas: 4,
      alinhamento: center,
      cabecalho: ([$or$], [$sans(V)$], [$sans(D)$], [$sans(F)$]),
      [$sans(V)$], [$sans(V)$], [$sans(V)$], [$sans(V)$],
      [$sans(D)$], [$sans(V)$], [$sans(D)$], [$sans(D)$],
      [$sans(F)$], [$sans(V)$], [$sans(D)$], [$sans(F)$],
    ),
  ),
  caption: [Conjunção e disjunção na lógica forte de Kleene. A negação troca $sans(V)$ e $sans(F)$ e fixa $sans(D)$.],
) <tab-ap-kleene>

Uma forma conveniente de ver $K_3$ é ordenar os valores por _quantidade de informação_: $sans(D) scripts(lt.eq)_i sans(V)$ e $sans(D) scripts(lt.eq)_i sans(F)$, com $sans(V)$ e $sans(F)$ incomparáveis. Essa _ordem de informação_ é diferente da _ordem de verdade_ $sans(F) scripts(lt.eq)_t sans(D) scripts(lt.eq)_t sans(V)$.

#teorema(titulo: [Monotonicidade informacional de $K_3$])[
  Os conectivos $not$, $and$ e $or$ de $K_3$ são monótonos na ordem de informação: se $x scripts(lt.eq)_i x'$ e $y scripts(lt.eq)_i y'$, então $not x scripts(lt.eq)_i not x'$, $x and y scripts(lt.eq)_i x' and y'$ e $x or y scripts(lt.eq)_i x' or y'$.
] <teo-ap-k3-monotono>

#prova[
  Para a negação, a verificação é imediata. Para a conjunção, basta considerar o caso em que só um argumento muda, digamos $x scripts(lt.eq)_i x'$ com $x != x'$; então $x = sans(D)$ e $x' in {sans(V), sans(F)}$. Se $sans(D) and y = sans(D)$, não há o que provar, pois $sans(D)$ é o menor elemento de $scripts(lt.eq)_i$. Caso contrário, pela tabela, $sans(D) and y = sans(F)$, o que só ocorre com $y = sans(F)$; nesse caso também $x' and y = sans(F)$. O argumento para a disjunção é dual.
]

O teorema tem uma consequência prática importante. Considere um _portão_ (_gate_) que autoriza uma ação somente se uma fórmula $phi$ de pré-condições é avaliada como $sans(V)$. Se algumas pré-condições ainda são desconhecidas, $phi$ pode valer $sans(D)$; pela monotonicidade, obter mais informação nunca transforma um $sans(V)$ já obtido em $sans(F)$ — mas pode transformar um $sans(D)$ em $sans(F)$. Logo, entre as políticas que dependem apenas do valor de $phi$, autorizar exatamente sob $sans(V)$ é a mais permissiva que nunca precisará ser "desfeita" por informação adicional consistente. (Nunca autorizar também nunca é desfeita, mas não serve para nada.) Essa é a semântica precisa da expressão _falhar fechado_ (_fail-closed_), estudada no @cap-portoes.

A ressalva "consistente" é essencial. Os estatutos do livro vivem em $sans("FOUR")$ (@sec-ap-belnap), não em $K_3$: lá, informação nova pode levar $sans(V)$ a $top$ — uma segunda fonte contradiz a primeira. Em $sans("FOUR")$, nem $sans(V)$ é estável; por isso os portões do livro reavaliam suas condições no momento da execução, em vez de confiar numa avaliação anterior.

#exercicios[
  + Construa a tabela da implicação material $x -> y := not x or y$ em $K_3$. Mostre que $x -> x$ não é uma tautologia (isto é, não vale $sans(V)$ para todo $x$). Que consequência isso tem para regras do tipo "se a pré-condição vale, então…" avaliadas sobre informação incompleta?
  + Prove que, se uma fórmula construída com $not, and, or$ vale $sans(V)$ em $K_3$ sob uma valoração parcial $v$, então vale $sans(V)$ em toda valoração clássica que estende $v$. Mostre, com $p or not p$ e $v(p) = sans(D)$, que a recíproca é falsa, e relacione com a avaliação por supervalorações (@sec-portoes-supervaloracao).
  + Um portão exige $p and (q or r)$. Os valores atuais são $p = sans(V)$, $q = sans(D)$, $r = sans(F)$. Qual é o valor do portão? Qual informação mínima precisa ser obtida para decidi-lo? Generalize: descreva um procedimento que, dado $phi$ e uma valoração parcial, identifique um conjunto mínimo de variáveis cuja observação decide $phi$. ★ Mostre que encontrar o menor tal conjunto é, em geral, um problema difícil.
]

== A lógica de quatro valores de Belnap <sec-ap-belnap>

Num sistema que recebe informação de várias fontes, há um quarto estado possível: duas fontes podem afirmar coisas opostas sobre o mesmo fato. #ct(<belnap1977>) propôs tratar esse estado como um valor de primeira classe, $top$ (contraditório, ou "ambos"), ao lado de $bot$ (nenhuma informação, ou "nenhum"), $sans(V)$ e $sans(F)$. O valor de um fato passa a ser lido como _o que nos foi dito_ sobre ele: nada ($bot$), apenas que é verdadeiro ($sans(V)$), apenas que é falso ($sans(F)$), ou ambas as coisas ($top$).

#figure(
  diagram(
    spacing: (14mm, 9mm),
    node((0, 0), $top$),
    node((-1, 1), $sans(V)$),
    node((1, 1), $sans(F)$),
    node((0, 2), $bot$),
    edge((0, 2), (-1, 1), "-"),
    edge((0, 2), (1, 1), "-"),
    edge((-1, 1), (0, 0), "-"),
    edge((1, 1), (0, 0), "-"),
  ),
  caption: [O reticulado de informação de Belnap ($scripts(lt.eq)_i$). Subir no diagrama significa ter recebido mais informação; $top$ representa informação contraditória. Na ordem de verdade $scripts(lt.eq)_t$, por outro lado, $sans(F)$ é o menor elemento, $sans(V)$ o maior, e $bot$, $top$ são incomparáveis.],
) <fig-ap-belnap>

As duas ordens fazem do conjunto $sans("FOUR") = {bot, sans(V), sans(F), top}$ um _bireticulado_. A junção na ordem de informação, que escrevemos $plus.o$, combina relatos: $sans(V) plus.o sans(F) = top$, $bot plus.o x = x$, $x plus.o x = x$.

#figure(
  tabela(
    colunas: (auto, auto, 1fr),
    cabecalho: ([$sans("FOUR")$], [Estatuto no livro], [Leitura]),
    [$bot$], [#est[desconhecido]], [nada foi dito],
    [$sans(V)$], [#est[provado]], [só suporte],
    [$sans(F)$], [#est[refutado]], [só contra-suporte],
    [$top$], [#est[conflitante]], [suporte e contra-suporte],
  ),
  caption: [Correspondência entre os valores de Belnap e os estatutos epistêmicos do livro (@def-estatuto-sustentado).],
) <tab-ap-four-estatutos>

#proposicao(titulo: [Combinação de relatos independe da ordem])[
  A operação $plus.o$ é comutativa, associativa e idempotente. Consequentemente, o valor obtido ao combinar os relatos de qualquer conjunto finito de fontes não depende da ordem nem do número de vezes em que cada relato é recebido.
] <prop-ap-belnap-semirreticulado>

#prova[
  $plus.o$ é o supremo num reticulado finito, e o supremo é sempre comutativo, associativo e idempotente. O valor combinado de um conjunto de relatos é, portanto, o supremo do conjunto, que não depende de ordem ou multiplicidade.
]

Essa proposição é a mesma propriedade algébrica que garante a convergência dos tipos de dados replicados livres de conflito @shapiro2011 (@cap-reconciliacao, Apêndice D): um semirreticulado de junção é a estrutura natural para acumular observações vindas de fontes que não se coordenam. Num acervo de contexto, ela justifica a regra de _não sobrescrever_ um relato com outro de sinal oposto, mas registrar o conflito ($top$) e tratá-lo como um fato a ser resolvido por quem tem autoridade.

#exercicios[
  + Escreva as tabelas de $and$ e $or$ em $sans("FOUR")$, definidas como ínfimo e supremo na ordem de verdade. Verifique que elas estendem as de $K_3$ quando $sans(D)$ é identificado com $bot$.
  + Três fontes relatam o estado de um serviço: a primeira diz "ativo", a segunda nada diz, a terceira diz "inativo". Qual o valor combinado? Por que um sistema que adota "o relato mais recente vence" pode exibir comportamento dependente da ordem de chegada das mensagens?
  + #avancado Mostre que $not$ definida por $not sans(V) = sans(F)$, $not sans(F) = sans(V)$, $not bot = bot$, $not top = top$ é monótona em $scripts(lt.eq)_i$ e antimonótona em $scripts(lt.eq)_t$.
]

== Lógica epistêmica <sec-ap-epistemica>

A lógica epistêmica estuda enunciados da forma "o agente $a$ sabe que $phi$", escritos $K_a phi$ @hintikka1962 @fagin1995. Sua semântica usual é dada por _estruturas de Kripke_.

#definicao(titulo: [Estrutura de Kripke epistêmica])[
  Uma _estrutura de Kripke_ para agentes $1, dots, n$ é uma tupla $M = (S, pi, cal(K)_1, dots, cal(K)_n)$, em que $S$ é um conjunto de _mundos_ (ou estados possíveis), $pi$ atribui a cada mundo uma valoração das proposições atômicas, e cada $cal(K)_a subset.eq S times S$ é uma relação de _acessibilidade_: $(s, t) in cal(K)_a$ significa que, no mundo $s$, o agente $a$ não consegue distinguir $s$ de $t$. Define-se $M, s models K_a phi$ se e somente se $M, t models phi$ para todo $t$ com $(s, t) in cal(K)_a$.
] <def-ap-kripke>

Intuitivamente, um agente sabe $phi$ quando $phi$ vale em todos os mundos compatíveis com o que ele observou. Quanto menos o agente observa, maior o conjunto de mundos que ele não consegue distinguir — e menos ele sabe. Propriedades da relação $cal(K)_a$ correspondem a axiomas:

#figure(
  tabela(
    colunas: (auto, 1fr, auto),
    cabecalho: ([Axioma], [Enunciado], [Propriedade de $cal(K)_a$]),
    [K], [$K_a phi and K_a (phi -> psi) -> K_a psi$], [(vale sempre)],
    [T], [$K_a phi -> phi$ (só se sabe o que é verdade)], [reflexiva],
    [4], [$K_a phi -> K_a K_a phi$ (introspecção positiva)], [transitiva],
    [5], [$not K_a phi -> K_a not K_a phi$ (introspecção negativa)], [euclidiana],
    [D], [$not K_a sans(F)$ (crenças consistentes)], [serial],
  ),
  caption: [Axiomas da lógica epistêmica e as propriedades correspondentes da relação de acessibilidade. O sistema S5 (T, 4, 5) modela conhecimento; KD45 modela crença.],
) <tab-ap-axiomas>

A distinção entre conhecimento (S5) e crença (KD45) está no axioma T: crenças podem ser falsas. Um agente de linguagem que "lembra" de um fato a partir de um resumo antigo tem, no máximo, uma crença; só uma observação ancorada e atual o autoriza a tratá-la como conhecimento. O @cap-epistemologia usa essa distinção para separar _memória_ de _prova_.

=== Conhecimento distribuído e conhecimento comum

Para um grupo $G$ de agentes, dois operadores são especialmente úteis.

- _Conhecimento distribuído_: $D_G phi$ vale se $phi$ é consequência do que os membros de $G$ sabem _em conjunto_ — semanticamente, se $phi$ vale em todos os mundos que _nenhum_ membro consegue distinguir do atual (interseção das relações $cal(K)_a$). É o conhecimento que estaria disponível se todos compartilhassem tudo.
- _Conhecimento comum_: $C_G phi$ vale se todos sabem $phi$, todos sabem que todos sabem $phi$, e assim por diante, indefinidamente.

#teorema(titulo: [Ataque coordenado, versão informal])[
  Se mensagens entre dois agentes podem ser perdidas sem que o remetente saiba, nenhum protocolo finito de troca de mensagens torna um fato não trivial conhecimento comum entre eles.
] <teo-ap-ataque-coordenado>

O problema, conhecido como o dos _dois generais_, foi formulado por #ct(<gray1978>); a análise em termos de conhecimento comum é de #ct(<halpern1990>), e a prova clássica, por indução no número de mensagens, está em #ct(<fagin1995>). A lição para sistemas de agentes é direta: quando um orquestrador transfere trabalho a outro agente por um canal falível, ele _não_ pode presumir que ambos compartilham o mesmo entendimento do estado; o que pode fazer é exigir confirmações explícitas e projetar o protocolo para que a ausência de confirmação seja tratada como estado desconhecido (@cap-handoff).

#exercicios[
  + Construa uma estrutura de Kripke com dois mundos em que o agente $a$ sabe $p$ e o agente $b$ não sabe $p$. Verifique que $D_({a, b}) p$ vale.
  + Explique por que o axioma 5 (introspecção negativa) é implausível para agentes com memória limitada: um agente que não sabe $phi$ nem sempre sabe que não sabe. Relacione com a necessidade de representar desconhecidos _explicitamente_ no contexto.
  + #avancado Prove, por indução no número de mensagens entregues, a versão do @teo-ap-ataque-coordenado para o caso em que os agentes só agem se tiverem conhecimento comum de que ambos agirão.
]

== Revisão de crenças <sec-ap-agm>

A teoria AGM @alchourron1985 @gardenfors1988 descreve como um conjunto de crenças $B$ (fechado sob consequência lógica) deve mudar diante de uma nova informação $phi$. Há três operações:

- _Expansão_ $B + phi$: acrescentar $phi$ e fechar sob consequência, sem remover nada (apropriada quando $phi$ é consistente com $B$);
- _Contração_ $B - phi$: remover $phi$ de modo que $phi$ deixe de ser consequência, abrindo mão do mínimo possível;
- _Revisão_ $B * phi$: incorporar $phi$ mesmo que contradiga $B$, removendo o mínimo necessário para restaurar a consistência.

A _identidade de Levi_ relaciona as três: $B * phi = (B - not phi) + phi$. Os postulados AGM exigem, entre outras coisas, _sucesso_ ($phi in B * phi$), _consistência_ (se $phi$ é consistente, $B * phi$ é consistente) e _mudança mínima_ (a revisão preserva tanto quanto possível de $B$).

Os postulados não determinam uma única operação: a escolha do que abandonar depende de uma ordem de _entrincheiramento_ entre crenças. Em acervos de contexto, essa ordem tem uma interpretação concreta: crenças sustentadas por evidência ancorada e recente são mais entrincheiradas do que crenças derivadas de memória ou de inferência. Os _sistemas de manutenção da verdade_ @doyle1979 @dekleer1986 tornam essa ideia operacional ao registrar, para cada crença, suas _justificativas_; quando uma justificativa cai, todas as crenças que dependiam exclusivamente dela são retiradas. Essa é exatamente a função de um grafo de proveniência quando uma evidência é revogada (@cap-proveniencia).

Duas ressalvas aproximam a teoria da prática. Primeiro, AGM opera sobre conjuntos fechados sob consequência — em geral infinitos —, enquanto um acervo é uma _base_ finita de asserções; a revisão de bases @hansson1999 trata desse caso, em que duas bases logicamente equivalentes podem ser revisadas de formas diferentes, porque o que se registrou importa, não apenas o que se segue.

=== Revisão e atualização

Segundo, há duas situações que a mesma operação não deve tratar @katsuno1991. Na _revisão_, o mundo é o mesmo e a crença estava errada: uma observação melhor corrige uma pior sobre o mesmo instante. Na _atualização_, a crença estava certa, mas o mundo mudou: a observação nova descreve um instante posterior. Os postulados são diferentes — a atualização, por exemplo, é aplicada a cada mundo possível separadamente, e não exige abandonar o que era verdade antes. Em acervos de contexto, a distinção é a dos relógios do @cap-tempo: se a observação nova e a antiga têm o mesmo instante de observação, trata-se de revisão, e a antiga é refutada; se a nova é posterior, trata-se de atualização, e a antiga é _suplantada_ — continua verdadeira sobre o seu instante. Confundir as duas é o erro de tratar o antigo como falso.

#exercicios[
  + Seja $B$ gerado por ${p, p -> q}$. Calcule $B + r$ e descreva duas contrações possíveis $B - q$. Qual delas preserva mais crenças?
  + Um agente acredita que "o serviço X está na versão 2" com base num resumo de uma sessão anterior e recebe agora uma observação ancorada de que está na versão 3. Decida se se trata de revisão ou de atualização e justifique com os relógios do @cap-tempo. Em que circunstância seria a outra?
  + Dê duas bases finitas logicamente equivalentes cuja contração pela mesma fórmula, retirando o mínimo de asserções registradas, produz resultados diferentes.
]

#problemas[
  #problema([Portões sobre informação incompleta])[
    Um portão de autorização é uma fórmula $phi$ sobre variáveis booleanas cujos valores são obtidos por observações que podem falhar.
    + Mostre que avaliar $phi$ em $K_3$ e autorizar somente sob $sans(V)$ nunca autoriza uma ação que seria negada se todas as variáveis fossem conhecidas.
    + Mostre que a política recíproca ("negar somente sob $sans(F)$") pode autorizar ações que seriam negadas com informação completa.
    + Proponha uma política de _escalonamento_: quando $phi$ vale $sans(D)$, o portão devolve a lista das variáveis desconhecidas relevantes, em vez de simplesmente negar. Discuta os custos e benefícios em termos de autonomia do agente e de carga sobre o titular.
  ]
  #problema([Fontes em conflito])[
    Considere $n$ fontes que relatam valores em $sans("FOUR")$ para os mesmos $m$ fatos.
    + Mostre que manter, por fato, o supremo dos relatos exige espaço $O(m)$ e processa cada relato em $O(1)$.
    + Mostre que isso perde a informação de _quais_ fontes discordam. Proponha uma representação que preserve proveniência sem perder a propriedade de independência da ordem.
    + #avancado Relacione sua representação aos semianéis de proveniência de #ct(<green2007>).
  ]
]

#notas[
  A hipótese de mundo fechado foi formalizada por #ct(<reiter1978>); o tratamento de valores ausentes em bancos relacionais é discutido por #ct(<codd1979>). A lógica trivalente forte é de #ct(<kleene1952>), e a lógica de quatro valores, motivada explicitamente pelo problema de um computador que recebe informação de várias fontes, é de #ct(<belnap1977>). A lógica epistêmica moderna começa com #ct(<hintikka1962>); #ct(<fagin1995>) é a referência abrangente para conhecimento em sistemas multiagentes, incluindo conhecimento comum, conhecimento distribuído e o problema do ataque coordenado. A teoria da revisão de crenças foi estabelecida por #ct(<alchourron1985>) e desenvolvida em #ct(<gardenfors1988>). Os sistemas de manutenção da verdade de #ct(<doyle1979>) e #ct(<dekleer1986>) anteciparam, no contexto de sistemas especialistas, muitas das preocupações com justificativa e retratação que reaparecem na gestão de proveniência para agentes de linguagem.
]
