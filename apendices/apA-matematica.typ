#import "/modelo/estilo.typ": *

= Conjuntos, relações, ordens e grafos <ap-matematica>

Este apêndice reúne o vocabulário matemático usado ao longo do livro. Ele não pretende substituir um texto de matemática discreta; seu objetivo é fixar notação e enunciar, com provas curtas, os poucos resultados de que dependemos com frequência: o elo entre relações de equivalência e partições (usado na resolução de identidade), a teoria de ordens parciais e reticulados (usada nos estatutos epistêmicos, nos tetos de autoridade e nos estágios de ciclo de vida das ações), os teoremas de ponto fixo (usados na reconciliação) e os conceitos de grafos dirigidos acíclicos (usados nos grafos de proveniência, de governança e de trajetória). O leitor iniciante pode lê-lo de uma vez antes da Parte II; o leitor experiente pode consultá-lo sob demanda.

== Conjuntos, funções e sequências

Escrevemos $x in A$ quando $x$ é elemento do conjunto $A$, e $A subset.eq B$ quando todo elemento de $A$ pertence a $B$. O conjunto vazio é $emptyset$; a união, a interseção e a diferença são $A union B$, $A inter B$ e $A without B$. O _conjunto potência_ $cal(P)(A)$ é o conjunto de todos os subconjuntos de $A$; se $A$ é finito com $n$ elementos, $|cal(P)(A)| = 2^n$. O _produto cartesiano_ $A times B$ é o conjunto dos pares ordenados $(a, b)$ com $a in A$ e $b in B$.

Uma _função_ $f: A -> B$ associa a cada $a in A$ exatamente um $f(a) in B$. Quando a associação pode não estar definida para alguns elementos, falamos em _função parcial_ e escrevemos $f: A harpoon.rt B$; o conjunto dos elementos em que $f$ está definida é seu _domínio de definição_, $"dom"(f)$. Funções parciais aparecem naturalmente no livro: uma função que resolve um identificador para um recurso é tipicamente parcial — e convém distinguir "não definida" — a função nada diz sobre o elemento — de "definida com o valor #est[desconhecido]" — a função registra explicitamente que o valor não é conhecido. A primeira corresponde a uma asserção _ausente_; a segunda, a um desconhecido _declarado_, distinção que o @cap-epistemologia formaliza. (Evitamos a expressão "valor nulo", que evoca o nulo de SQL, cuja semântica mistura os dois casos.) A _imagem_ de $X subset.eq A$ é $f(X) = {f(x) : x in X}$, e a _pré-imagem_ de $Y subset.eq B$ é $f^(-1)(Y) = {a in A : f(a) in Y}$. A _restrição_ de $f$ a $X subset.eq A$ é denotada $f|_X$.

Uma função é _injetora_ se $f(a) = f(a')$ implica $a = a'$; _sobrejetora_ se $f(A) = B$; _bijetora_ se ambas. Composição: $(g compose f)(a) = g(f(a))$. Uma função $f: A -> A$ é _idempotente_ se $f compose f = f$. Idempotência é uma propriedade que exigiremos de várias operações — projeções de contexto, operações de reconciliação, aplicações de efeitos com chave de idempotência — porque ela torna seguro repetir uma operação cujo resultado não foi observado.

Um _alfabeto_ é um conjunto finito $V$ de símbolos; uma _sequência_ (ou cadeia) sobre $V$ é uma lista finita $s = s_1 s_2 dots s_n$ de símbolos, de comprimento $|s| = n$. O conjunto de todas as sequências finitas é $V^*$. Uma janela de contexto de capacidade $W$ é, nesse vocabulário, um elemento de ${s in V^* : |s| <= W}$, em que $V$ é o vocabulário de _tokens_ do modelo. A concatenação de $s$ e $t$ é escrita $s dot t$ ou simplesmente $s t$.

Um _multiconjunto_ generaliza um conjunto permitindo repetições; formalmente, é uma função $m: A -> bb(N)$ que conta quantas vezes cada elemento ocorre. Multiconjuntos são úteis para raciocinar sobre o _conteúdo_ de uma janela independentemente da _ordem_ de seus segmentos.

#exercicios[
  + Mostre que $|cal(P)(A)| = 2^(|A|)$ para todo conjunto finito $A$, por indução em $|A|$.
  + Seja $f: A -> B$ e $X_1, X_2 subset.eq A$. Prove que $f(X_1 union X_2) = f(X_1) union f(X_2)$, mas que $f(X_1 inter X_2) subset.eq f(X_1) inter f(X_2)$ pode ser estrita. Dê um exemplo em que a inclusão é estrita. Qual hipótese sobre $f$ garante a igualdade?
  + Uma função parcial $r: I harpoon.rt U$ resolve identificadores $I$ em recursos $U$. Explique a diferença entre "$i in.not "dom"(r)$" e "$r(i)$ é um recurso marcado como removido". Por que um sistema que confunde os dois casos pode tomar decisões erradas?
  + Prove que, se $f$ e $g$ são idempotentes e comutam ($f compose g = g compose f$), então $f compose g$ é idempotente. Mostre por contraexemplo que a hipótese de comutação é necessária.
]

== Relações

Uma _relação binária_ $R$ entre $A$ e $B$ é um subconjunto $R subset.eq A times B$; escrevemos $a R b$ quando $(a, b) in R$. Quando $A = B$, dizemos que $R$ é uma relação _sobre_ $A$. Uma relação sobre $A$ é:

- _reflexiva_ se $a R a$ para todo $a in A$;
- _simétrica_ se $a R b$ implica $b R a$;
- _antissimétrica_ se $a R b$ e $b R a$ implicam $a = b$;
- _transitiva_ se $a R b$ e $b R c$ implicam $a R c$.

A _composição_ de $R subset.eq A times B$ e $S subset.eq B times C$ é $S compose R = {(a, c) : exists b. thin a R b and b S c}$. A _inversa_ de $R$ é $R^(-1) = {(b, a) : a R b}$.

#definicao(titulo: [Relação de equivalência e partição])[
  Uma relação sobre $A$ reflexiva, simétrica e transitiva é uma _relação de equivalência_. A _classe de equivalência_ de $a$ é $[a]_R = {b in A : a R b}$. Uma _partição_ de $A$ é uma família de subconjuntos não vazios, disjuntos dois a dois, cuja união é $A$.
] <def-ap-equivalencia>

#teorema(titulo: [Equivalências e partições])[
  Se $R$ é uma relação de equivalência sobre $A$, então suas classes de equivalência formam uma partição de $A$. Reciprocamente, toda partição $cal(Q)$ de $A$ define a relação de equivalência "$a$ e $b$ pertencem ao mesmo bloco de $cal(Q)$".
] <teo-ap-particao>

#prova[
  Pela reflexividade, $a in [a]_R$, logo as classes são não vazias e cobrem $A$. Suponha que $c in [a]_R inter [b]_R$. Então $a R c$ e $b R c$; por simetria, $c R b$, e por transitividade $a R b$. Agora, se $x in [b]_R$, temos $b R x$ e, por transitividade, $a R x$, isto é, $x in [a]_R$; logo $[b]_R subset.eq [a]_R$, e simetricamente $[a]_R subset.eq [b]_R$. Assim, duas classes ou são disjuntas ou são iguais. A recíproca é imediata: pertencer ao mesmo bloco é reflexivo, simétrico e transitivo porque os blocos são disjuntos e cobrem $A$.
]

=== Fechos

Dada uma relação $R$ sobre $A$, o _fecho transitivo_ $R^+$ é a menor relação transitiva que contém $R$; explicitamente, $a R^+ b$ se e somente se existe uma cadeia $a = x_0 R x_1 R dots R x_k = b$ com $k >= 1$. O _fecho reflexivo-transitivo_ $R^*$ acrescenta os pares $(a, a)$. O _fecho de equivalência_ de $R$ é a menor relação de equivalência que contém $R$, isto é, $(R union R^(-1))^*$.

O fecho de equivalência tem papel central no @cap-identidade: se um sistema registra apenas um conjunto $E$ de equivalências _provadas_ entre identificadores ("o identificador $x$ no domínio de nomes $N_1$ denota o mesmo recurso que $y$ em $N_2$"), então as identidades que ele tem o direito de fundir são exatamente as classes do fecho de equivalência de $E$ — nem mais (o que seria fusão sem prova), nem menos (o que deixaria de usar transitividade legítima). Esse fecho pode ser mantido incrementalmente pela estrutura de dados de conjuntos disjuntos (_union-find_), com custo amortizado quase constante por operação @cormen2022.

#lema(titulo: [Monotonicidade do fecho])[
  Se $R subset.eq S$, então o fecho de equivalência de $R$ está contido no fecho de equivalência de $S$.
] <lem-ap-fecho-monotono>

#prova[
  O fecho de equivalência de $S$ é uma relação de equivalência que contém $S$ e, portanto, contém $R$. Como o fecho de $R$ é a _menor_ relação de equivalência que contém $R$, ele está contido no fecho de $S$.
]

#exercicios[
  + Mostre que a interseção de duas relações de equivalência sobre $A$ é uma relação de equivalência, mas que a união pode não ser.
  + Prove que $(R union R^(-1))^*$ é de fato uma relação de equivalência e que é a menor que contém $R$.
  + Considere identificadores ${a, b, c, d, e}$ e equivalências provadas $E = {(a, b), (c, d), (b, c)}$. Calcule as classes do fecho de equivalência. Se, em seguida, descobrirmos que a prova de $(b, c)$ era inválida e a retirarmos, quais classes mudam? Discuta por que union-find não suporta remoção eficientemente e que alternativa um sistema que precisa _revogar_ equivalências deveria adotar.
  + #avancado Seja $R$ uma relação sobre um conjunto finito com $n$ elementos. Mostre que $R^+ = R union R^2 union dots union R^n$, em que $R^k$ é a composição de $R$ consigo mesma $k$ vezes.
]

== Ordens parciais e reticulados <sec-ap-ordens>

Uma _pré-ordem_ é uma relação reflexiva e transitiva. Uma _ordem parcial_ é uma pré-ordem antissimétrica; o par $(A, lt.eq)$ é então um _conjunto parcialmente ordenado_ (abreviado _poset_). Se, adicionalmente, quaisquer dois elementos são comparáveis, a ordem é _total_ (ou linear), e o poset é uma _cadeia_. Elementos incomparáveis são escritos $a parallel b$.

Posets finitos são desenhados como _diagramas de Hasse_: um ponto por elemento, e um segmento ascendente de $a$ para $b$ quando $a < b$ e não existe $c$ com $a < c < b$ (dizemos que $b$ _cobre_ $a$).

Seja $X subset.eq A$. Um _majorante_ de $X$ é um $u$ com $x lt.eq u$ para todo $x in X$; o _supremo_ (ou _junção_) de $X$, se existir, é o menor majorante, denotado $or.big X$; para dois elementos, $a or b$. Dualmente, o _ínfimo_ (ou _encontro_) é $and.big X$, e $a and b$ para dois elementos. Quando há risco de confusão com conectivos lógicos, usamos $a union.sq b$ e $a inter.sq b$.

#definicao(titulo: [Reticulado])[
  Um poset $(L, lt.eq)$ é um _reticulado_ se todo par de elementos tem supremo e ínfimo. É um _reticulado completo_ se todo subconjunto (inclusive $emptyset$ e $L$) tem supremo e ínfimo. Um reticulado completo tem um menor elemento $bot = and.big L$ e um maior elemento $top = or.big L$.
] <def-ap-reticulado>

Todo reticulado finito e não vazio é completo. Exemplos que reaparecem no livro:

+ $(cal(P)(A), subset.eq)$, com $union$ e $inter$ como supremo e ínfimo — o reticulado dos _conjuntos de permissões_ e dos _conjuntos de fatos visíveis_.
+ Uma cadeia finita $c_0 < c_1 < dots < c_k$ — por exemplo, os estágios do ciclo de vida de uma ação (@cap-ciclo-acao) ou os níveis de classificação de confidencialidade.
+ O produto de reticulados $L_1 times L_2$ com a ordem componente a componente — por exemplo, um _rótulo de segurança_ formado por um nível e um conjunto de categorias @denning1976.
+ O reticulado de quatro valores de Belnap (Apêndice B), que ordena estados de informação: $bot$ (nenhuma informação), $sans(V)$ (verdadeiro), $sans(F)$ (falso) e $top$ (informação contraditória).

=== Funções monótonas e pontos fixos

Uma função $f: L -> M$ entre posets é _monótona_ se $a lt.eq b$ implica $f(a) lt.eq f(b)$. Um _ponto fixo_ de $f: L -> L$ é um $x$ com $f(x) = x$; um _pré-ponto fixo_ satisfaz $f(x) lt.eq x$.

#teorema(titulo: [Knaster–Tarski])[
  Se $L$ é um reticulado completo e $f: L -> L$ é monótona, então o conjunto de pontos fixos de $f$ é não vazio e forma, ele próprio, um reticulado completo. Em particular, $f$ tem um menor ponto fixo, dado por $"lfp"(f) = and.big {x in L : f(x) lt.eq x}$.
] <teo-ap-tarski>

#prova[
  Provamos a afirmação sobre o menor ponto fixo, que é a que usaremos. Seja $D = {x : f(x) lt.eq x}$ e $m = and.big D$ (existe porque $L$ é completo; $D$ é não vazio porque contém $top$). Para todo $x in D$, $m lt.eq x$, logo $f(m) lt.eq f(x) lt.eq x$ por monotonicidade. Portanto $f(m)$ é minorante de $D$, e $f(m) lt.eq m$. Por monotonicidade, $f(f(m)) lt.eq f(m)$, ou seja, $f(m) in D$, e então $m lt.eq f(m)$. Logo $f(m) = m$. Qualquer ponto fixo $y$ pertence a $D$, de modo que $m lt.eq y$: $m$ é o menor ponto fixo. A prova de que os pontos fixos formam um reticulado completo segue o mesmo padrão e é deixada como exercício.
]

Em reticulados finitos há um método construtivo para calcular o menor ponto fixo, que é o modelo abstrato de todo laço de "observar, comparar, corrigir" estudado no @cap-reconciliacao.

#teorema(titulo: [Iteração de Kleene em reticulados finitos])[
  Seja $L$ um reticulado finito com menor elemento $bot$, e $f: L -> L$ monótona. A sequência $bot lt.eq f(bot) lt.eq f^2(bot) lt.eq dots$ é crescente e se estabiliza após no máximo $h$ passos, em que $h$ é o comprimento da maior cadeia de $L$; o valor em que se estabiliza é $"lfp"(f)$.
] <teo-ap-kleene>

#prova[
  Por indução: $bot lt.eq f(bot)$ trivialmente; se $f^k(bot) lt.eq f^(k+1)(bot)$, a monotonicidade dá $f^(k+1)(bot) lt.eq f^(k+2)(bot)$. Uma cadeia estritamente crescente em $L$ tem no máximo $h$ passos, logo existe $k lt.eq h$ com $f^k(bot) = f^(k+1)(bot)$, um ponto fixo. Se $y$ é um ponto fixo qualquer, $bot lt.eq y$ implica, por indução, $f^j(bot) lt.eq f^j(y) = y$ para todo $j$; logo o ponto fixo atingido é o menor.
]

=== Conexões de Galois

Sejam $(C, lt.eq)$ e $(A, subset.eq.sq)$ posets — pense em $C$ como um domínio "concreto" (por exemplo, todos os fatos de um acervo) e $A$ como um domínio "abstrato" (por exemplo, resumos ou perspectivas). Um par de funções monótonas $alpha: C -> A$ e $gamma: A -> C$ é uma _conexão de Galois_ se, para todos $c in C$ e $a in A$,
$ alpha(c) subset.eq.sq a quad <==> quad c lt.eq gamma(a). $
Intuitivamente, $alpha$ abstrai (perde informação de modo controlado) e $gamma$ concretiza (devolve o conjunto de situações concretas compatíveis com a abstração). Conexões de Galois são a base da interpretação abstrata @cousot1977 e oferecem um vocabulário preciso para dizer quando um resumo de contexto é _correto_ — isto é, quando ele nunca afirma mais do que aquilo que os dados concretos garantem.

#proposicao(titulo: [Propriedades de uma conexão de Galois])[
  Se $(alpha, gamma)$ é uma conexão de Galois, então $c lt.eq gamma(alpha(c))$ e $alpha(gamma(a)) subset.eq.sq a$ para todos $c$ e $a$; além disso, $alpha compose gamma compose alpha = alpha$ e $gamma compose alpha compose gamma = gamma$. Em particular, $gamma compose alpha$ é um operador de fecho: monótono, extensivo e idempotente.
] <prop-ap-galois>

#prova[
  De $alpha(c) subset.eq.sq alpha(c)$ obtemos $c lt.eq gamma(alpha(c))$ pela equivalência; de $gamma(a) lt.eq gamma(a)$ obtemos $alpha(gamma(a)) subset.eq.sq a$. Aplicando $alpha$ (monótona) à primeira desigualdade, $alpha(c) subset.eq.sq alpha(gamma(alpha(c)))$; aplicando a segunda com $a = alpha(c)$, $alpha(gamma(alpha(c))) subset.eq.sq alpha(c)$; por antissimetria, $alpha compose gamma compose alpha = alpha$. O caso de $gamma$ é dual. Idempotência de $gamma compose alpha$ segue de $gamma compose alpha compose gamma compose alpha = gamma compose alpha$.
]

#exercicios[
  + Desenhe o diagrama de Hasse de $(cal(P)({r, w, x}), subset.eq)$. Interprete cada elemento como um conjunto de permissões (ler, escrever, executar) e identifique o supremo e o ínfimo de ${r, w}$ e ${w, x}$.
  + Mostre que todo reticulado finito não vazio é completo.
  + Complete a prova do @teo-ap-tarski: mostre que o conjunto de pontos fixos de uma função monótona sobre um reticulado completo é um reticulado completo (não necessariamente um sub-reticulado).
  + Dê um exemplo de função _não_ monótona sobre um reticulado finito cuja iteração a partir de $bot$ oscila para sempre. Relacione o exemplo a um laço de reconciliação em que dois controladores desfazem mutuamente suas correções.
  + #avancado Seja $C = cal(P)(F)$ o conjunto de subconjuntos de um conjunto de fatos $F$, e $A = cal(P)(T)$, em que $T$ é um conjunto de "tópicos", com uma função $t: F -> T$ que atribui um tópico a cada fato. Defina $alpha(X) = t(X)$ e $gamma(Y) = t^(-1)(Y)$. Prove que $(alpha, gamma)$ é uma conexão de Galois e interprete $gamma(alpha(X))$ em termos de "tudo o que um resumo por tópicos não consegue distinguir de $X$".
]

== Grafos <sec-ap-grafos>

Um _grafo dirigido_ é um par $G = (V, E)$, com $E subset.eq V times V$; os elementos de $V$ são _vértices_ e os de $E$, _arestas_. Um _caminho_ de $u$ a $v$ é uma sequência de vértices $u = x_0, x_1, dots, x_k = v$ com $(x_(i-1), x_i) in E$; seu comprimento é $k$. Dizemos que $v$ é _alcançável_ a partir de $u$ ($u ~> v$) se existe tal caminho; a relação de alcançabilidade é exatamente o fecho reflexivo-transitivo $E^*$. Um _ciclo_ é um caminho de comprimento positivo com $x_0 = x_k$. Um grafo dirigido sem ciclos é um _grafo dirigido acíclico_ (DAG, do inglês _directed acyclic graph_).

#teorema(titulo: [Caracterização de DAGs])[
  Um grafo dirigido finito é acíclico se e somente se admite uma _ordenação topológica_, isto é, uma ordem total $v_1, v_2, dots, v_n$ de seus vértices tal que toda aresta $(v_i, v_j)$ satisfaz $i < j$.
] <teo-ap-topologica>

#prova[
  Se existe ordenação topológica, todo caminho visita vértices com índices estritamente crescentes, e portanto não pode voltar ao vértice inicial: não há ciclos. Reciprocamente, todo DAG finito não vazio tem um vértice sem arestas de entrada (caso contrário, caminhando para trás a partir de qualquer vértice encontraríamos, após no máximo $n$ passos, um vértice repetido — um ciclo). Coloque esse vértice em primeiro lugar, remova-o e repita: o grafo restante continua acíclico, e o processo produz uma ordenação topológica.
]

A prova é construtiva e corresponde ao algoritmo de Kahn; o algoritmo baseado em busca em profundidade, com tempo $O(|V| + |E|)$, é apresentado em #ct(<cormen2022>). A aciclicidade importa para grafos de proveniência (nenhum fato pode ser, direta ou indiretamente, evidência de si mesmo) e para grafos de dependência de trabalho (nenhum ciclo de trabalho pode depender, transitivamente, de sua própria conclusão).

=== Grafos rotulados e multigrafos tipados

Os grafos deste livro raramente são "simples". Uma aresta carrega um _tipo_ (por exemplo, `deriva-de`, `observa`, `governa`, `é-membro-de`), uma proveniência e um estatuto epistêmico; pode haver várias arestas de tipos diferentes entre os mesmos dois vértices. Formalizamos isso assim.

#definicao(titulo: [Multigrafo tipado com atributos])[
  Um _multigrafo tipado_ é uma tupla $G = (V, E, "src", "dst", tau, "attr")$, em que $V$ e $E$ são conjuntos finitos (vértices e arestas), $"src", "dst": E -> V$ dão a origem e o destino de cada aresta, $tau: V union E -> T$ atribui um tipo de um conjunto finito $T$, e $"attr"$ associa a cada vértice ou aresta um registro de atributos (pares chave–valor).
] <def-ap-multigrafo>

Nessa formulação, duas arestas distintas $e != e'$ podem ter a mesma origem, o mesmo destino e até o mesmo tipo — o que permite registrar, por exemplo, duas observações independentes da mesma relação, cada uma com sua proveniência. Para cada tipo $t in T$, o _subgrafo de tipo_ $G_t$ mantém apenas as arestas de tipo $t$. Muitos erros de raciocínio sobre contexto consistem em tratar $G_t$ e $G_(t')$ como se fossem o mesmo grafo — por exemplo, inferir autoridade a partir de pertinência —; o @cap-espacos dedica-se a esse tema.

=== Vizinhanças e distância

A _vizinhança de saída_ de $v$ é $N^+(v) = {w : (v, w) in E}$; a de entrada, $N^-(v)$. A _distância_ $d(u, v)$ é o comprimento do menor caminho de $u$ a $v$ (ou $infinity$ se não houver). A _bola_ de raio $k$ em torno de $v$ é $B_k(v) = {w : d(v, w) lt.eq k}$; ela é calculada por busca em largura em tempo proporcional ao número de vértices e arestas visitados. Bolas e suas generalizações ponderadas são o modelo mais simples de "contexto local" de um vértice e reaparecem na discussão de fronteiras e expansão dirigida (@cap-fronteira).

#exercicios[
  + Prove que a alcançabilidade em um DAG é uma ordem parcial sobre seus vértices. O que falha se o grafo tiver ciclos?
  + Escreva o algoritmo de Kahn em pseudocódigo e prove que ele detecta a presença de ciclos.
  + Mostre que, em um multigrafo tipado, a projeção $G mapsto G_t$ comuta com a remoção de vértices: remover $v$ e depois projetar no tipo $t$ dá o mesmo resultado que projetar e depois remover.
  + #avancado A _redução transitiva_ de um DAG $G$ é o menor grafo com o mesmo fecho transitivo de $G$. Prove que ela é única e dê um algoritmo para calculá-la. Por que um grafo de proveniência _não_ deve ser substituído por sua redução transitiva, mesmo que ela preserve a alcançabilidade?
]

== Notação assintótica

Para analisar o custo de algoritmos usamos a notação assintótica habitual. Para funções $f, g: bb(N) -> bb(R)_(>= 0)$:

- $f(n) = O(g(n))$ se existem constantes $c > 0$ e $n_0$ tais que $f(n) lt.eq c dot g(n)$ para todo $n >= n_0$;
- $f(n) = Omega(g(n))$ se $g(n) = O(f(n))$;
- $f(n) = Theta(g(n))$ se $f(n) = O(g(n))$ e $f(n) = Omega(g(n))$;
- $f(n) = o(g(n))$ se $lim_(n -> infinity) f(n) \/ g(n) = 0$.

No contexto deste livro, os "tamanhos" relevantes raramente são apenas o número de itens de entrada. Distinguimos com cuidado: $n$, o número de asserções no acervo; $m$, o número de relações; $W$, a capacidade da janela em _tokens_; $k$, o número de itens efetivamente selecionados; e $|c|$, o comprimento em _tokens_ do contexto renderizado. Uma operação de seleção pode ser barata em $n$ e cara em $W$, ou vice-versa, e o custo dominante de um sistema de agentes costuma estar no número de _tokens_ processados pelo modelo — uma grandeza que a análise clássica de algoritmos não captura sozinha. A @sec-custo trata desse modelo de custo com mais detalhe.

#exercicios[
  + Mostre que $log_2(n!) = Theta(n log n)$.
  + Um procedimento de seleção custa $O(n log n)$ operações de CPU e produz um contexto de $|c| lt.eq W$ _tokens_; o modelo de linguagem processa o contexto em tempo $Theta(|c|^2)$ no pior caso. Para quais valores relativos de $n$ e $W$ o custo da seleção domina o custo de processamento? Discuta por que, na prática, é comum que o oposto ocorra.
]

#problemas[
  #problema([Fusões de identidade com revogação])[
    Um sistema mantém um conjunto $E$ de equivalências provadas entre identificadores, e cada equivalência tem uma evidência que pode ser revogada.
    + Mostre que o fecho de equivalência não é "monótono sob revogação": remover uma aresta pode separar uma classe em várias.
    + Proponha uma estrutura de dados que suporte inserção e revogação de equivalências e consulta "$x$ e $y$ estão na mesma classe?". Analise seus custos. (Dica: pense em conectividade dinâmica em grafos, ou em recomputação preguiçosa por componente.)
    + Argumente por que, para fins de _auditoria_, o sistema deve guardar o conjunto $E$ com proveniência, e não apenas a partição resultante.
  ]
  #problema([Reticulados de permissões])[
    Considere permissões ${"ler", "escrever", "executar", "delegar"}$ e a ordem de inclusão de conjuntos.
    + Mostre que o conjunto de permissões efetivas de um agente que recebe permissões de duas fontes independentes, sob a regra "tem a permissão se ambas concedem", é o ínfimo dos dois conjuntos.
    + Mostre que, sob a regra "tem a permissão se alguma concede", é o supremo. Discuta qual das regras é compatível com o princípio do menor privilégio @saltzer1975.
    + #avancado Suponha que "delegar" só faça sentido acompanhado de alguma outra permissão. Mostre que os conjuntos válidos não formam um sub-reticulado de $cal(P)(P)$ e proponha uma ordem alternativa que forme um reticulado.
  ]
]

#notas[
  O material deste apêndice é clássico. Para conjuntos, relações e grafos, ver os apêndices de #ct(<cormen2022>), que adotamos também como referência para algoritmos em grafos e para a estrutura de conjuntos disjuntos. Para ordens e reticulados, o texto de referência é #ct(<davey2002>), que trata em detalhe de reticulados completos, conexões de Galois e teoremas de ponto fixo. A interpretação abstrata de #ct(<cousot1977>) mostrou como conexões de Galois tornam precisa a ideia de uma abstração _correta_ — a mesma ideia que, no @cap-perspectiva, usamos para caracterizar perspectivas que resumem sem mentir. O modelo de reticulado para fluxo de informação segura é de #ct(<denning1976>) e será retomado no @cap-autoridade.
]
