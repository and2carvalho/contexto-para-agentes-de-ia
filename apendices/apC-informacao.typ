#import "/modelo/estilo.typ": *

= Probabilidade, informação e otimização <ap-informacao>

Este apêndice reúne as ferramentas quantitativas do livro. A probabilidade discreta é usada para modelar incerteza sobre o estado do ambiente e o comportamento estocástico de modelos de linguagem; a teoria da informação dá significado preciso a ideias como "compressão por resumo" e "compressão por endereçamento"; as funções submodulares formalizam o fenômeno dos retornos decrescentes que governa a seleção de contexto; e a teoria da complexidade explica por que encontrar o contexto _ótimo_ é, em geral, intratável, e o que podemos garantir com algoritmos aproximados.

== Probabilidade discreta

Um _espaço de probabilidade discreto_ é um conjunto enumerável $Omega$ de resultados com uma função $Pr: Omega -> [0, 1]$ tal que $sum_(omega in Omega) Pr(omega) = 1$. Um _evento_ é um subconjunto $A subset.eq Omega$, com $Pr(A) = sum_(omega in A) Pr(omega)$. A _probabilidade condicional_ de $A$ dado $B$, com $Pr(B) > 0$, é $Pr(A | B) = Pr(A inter B) \/ Pr(B)$, e a _regra de Bayes_ afirma que
#eqn($ Pr(A | B) = (Pr(B | A) Pr(A)) / Pr(B). $) <eq-ap-bayes>
Eventos $A$ e $B$ são _independentes_ se $Pr(A inter B) = Pr(A) Pr(B)$.

Uma _variável aleatória_ é uma função $X: Omega -> bb(R)$ (ou com valores num conjunto finito qualquer). Sua _esperança_ é $E[X] = sum_omega X(omega) Pr(omega)$, e a esperança é linear: $E[a X + b Y] = a E[X] + b E[Y]$, mesmo sem independência. A _desigualdade de Markov_ afirma que, para $X >= 0$ e $t > 0$, $Pr(X >= t) lt.eq E[X] \/ t$.

A desigualdade de Markov é fraca; para médias de variáveis independentes e limitadas, há uma garantia exponencial.

#teorema(titulo: [Desigualdade de Hoeffding])[
  Sejam $X_1, dots, X_n$ variáveis aleatórias independentes com valores em $[0, 1]$ e $overline(X) = (1\/n) sum_i X_i$. Para todo $t > 0$,
  $ Pr(|overline(X) - E[overline(X)]| >= t) lt.eq 2 e^(-2 n t^2). $
] <teo-ap-hoeffding>

A prova @hoeffding1963 aplica a desigualdade de Markov a $e^(lambda (overline(X) - E[overline(X)]))$, limita a função geradora de momentos de cada termo limitado e otimiza em $lambda$.

#corolario(titulo: [Tamanho de amostra])[
  Para estimar uma taxa de acerto com erro máximo $t$ e confiança $1 - delta$, bastam $n >= ln(2 \/ delta) \/ (2 t^2)$ execuções independentes.
] <cor-ap-amostra>

#prova[
  Iguale $2 e^(-2 n t^2)$ a $delta$ e resolva em $n$.
]

O corolário não depende da distribuição e é, por isso, conservador: para $t = 0","05$ e $delta = 0","05$, exige $n >= 738$. Intervalos que exploram a forma binomial, como o de Wilson (@cap-avaliacao), são mais estreitos para o mesmo $n$; o mérito de Hoeffding é valer para qualquer variável limitada — um escore médio por dimensão, por exemplo.

Modelos de linguagem são, formalmente, distribuições condicionais: dado um contexto $c in V^*$, o modelo define $Pr_theta(x | c)$ para o próximo _token_ $x in V$, e, por encadeamento, uma distribuição sobre continuações inteiras. O comportamento de um agente é, portanto, uma variável aleatória cuja distribuição depende do contexto — um fato elementar com uma consequência metodológica importante, explorada no @cap-avaliacao: qualquer afirmação do tipo "o contexto $c_1$ é melhor que $c_2$" é uma afirmação sobre distribuições e precisa ser sustentada por amostragem repetida e estatística adequada, não por uma única execução.

#exercicios[
  + Um agente acerta uma tarefa com probabilidade $p$ em cada tentativa independente. Qual a probabilidade de acertar pelo menos uma vez em $k$ tentativas? Quantas tentativas são necessárias para que essa probabilidade seja ao menos 0,99 quando $p = "0,3"$?
  + Dois contextos $c_1$ e $c_2$ foram comparados em $n = 20$ execuções cada; $c_1$ acertou 14 e $c_2$ acertou 11. Discuta, sem fazer um teste formal, por que essa diferença pode não ser evidência de superioridade de $c_1$. Que fatores aumentariam a confiança na conclusão?
  + Quantas execuções independentes são necessárias, pelo @cor-ap-amostra, para estimar uma taxa de concordância com erro de $0","05$ e confiança de 95%? Compare com a largura do intervalo de Wilson para $n = 20$ e $hat(p) = 0","7$, e use o resultado para responder quantitativamente ao exercício anterior.
]

== Entropia e informação <sec-ap-entropia>

Seja $X$ uma variável aleatória com valores num conjunto finito $cal(X)$ e distribuição $p$. A _entropia_ de $X$, em bits, é
#eqn($ H(X) = - sum_(x in cal(X)) p(x) log_2 p(x), $) <eq-ap-entropia>
com a convenção $0 log 0 = 0$. A entropia mede a incerteza média sobre $X$ e satisfaz $0 lt.eq H(X) lt.eq log_2 |cal(X)|$, com igualdade à direita exatamente quando $X$ é uniforme. Para um par $(X, Y)$, a _entropia condicional_ é $H(X | Y) = sum_y p(y) H(X | Y = y)$, e a _informação mútua_ é
#eqn($ I(X; Y) = H(X) - H(X | Y) = H(Y) - H(Y | X), $) <eq-ap-info-mutua>
a redução média de incerteza sobre $X$ obtida ao observar $Y$. Vale $I(X; Y) >= 0$, isto é, _condicionar não aumenta a entropia em média_. A _divergência de Kullback–Leibler_ entre distribuições $p$ e $q$ é $D(p || q) = sum_x p(x) log_2 (p(x) \/ q(x))$, sempre não negativa e nula se e somente se $p = q$.

=== Codificação de fonte

Um _código de prefixo_ atribui a cada $x in cal(X)$ uma palavra binária $C(x)$ de modo que nenhuma palavra seja prefixo de outra; tais códigos podem ser decodificados sem separadores.

#teorema(titulo: [Desigualdade de Kraft e limite de Shannon])[
  Comprimentos $ell_1, dots, ell_m$ são realizáveis por um código de prefixo binário se e somente se $sum_i 2^(-ell_i) lt.eq 1$. Consequentemente, o comprimento esperado $L$ de qualquer código de prefixo para $X$ satisfaz $L >= H(X)$, e existe um código de prefixo com $L < H(X) + 1$.
] <teo-ap-shannon>

A prova encontra-se em #ct(<cover2006>). O teorema dá o sentido preciso de "compressão": nenhuma codificação sem perdas pode, em média, usar menos bits do que a entropia da fonte.

=== Processamento de dados

A _informação mútua condicional_ é $I(X; Y | Z) = H(X | Z) - H(X | Y, Z) >= 0$, e vale a _regra da cadeia_ $I(X; (Y, Z)) = I(X; Z) + I(X; Y | Z)$. Dizemos que $X -> Y -> Z$ é uma _cadeia de Markov_ se $X$ e $Z$ são condicionalmente independentes dado $Y$, isto é, $I(X; Z | Y) = 0$.

#teorema(titulo: [Desigualdade do processamento de dados])[
  Se $X -> Y -> Z$ é uma cadeia de Markov, então $I(X; Z) lt.eq I(X; Y)$, com igualdade se e somente se $I(X; Y | Z) = 0$.
] <teo-ap-processamento>

#prova[
  Pela regra da cadeia, aplicada de duas formas, $I(X; (Y, Z)) = I(X; Z) + I(X; Y | Z) = I(X; Y) + I(X; Z | Y)$. Pela hipótese, $I(X; Z | Y) = 0$; logo $I(X; Z) = I(X; Y) - I(X; Y | Z) lt.eq I(X; Y)$, com igualdade se e somente se $I(X; Y | Z) = 0$.
]

#corolario(titulo: [Nenhum resumo aumenta a informação sobre a decisão])[
  Sejam $H_t$ o histórico de um trabalho, $D$ uma variável de decisão futura e $s$ uma função de resumo — determinística, ou aleatória com aleatoriedade independente de $D$ dado $H_t$. Então $I(D; s(H_t)) lt.eq I(D; H_t)$, com igualdade se e somente se $s(H_t)$ é _suficiente_ para $D$: $D$ e $H_t$ são condicionalmente independentes dado $s(H_t)$.
] <cor-ap-resumo>

#prova[
  Pelas hipóteses sobre $s$, $D -> H_t -> s(H_t)$ é uma cadeia de Markov; aplique o @teo-ap-processamento.
]

O corolário é a base formal da frase "o resumo perde; o endereçamento não", que atravessa o @cap-compressao e o @cap-compactacao, e da noção de ponto de controle suficiente (@def-checkpoint-suficiente): um resumo pode, no máximo, preservar a informação sobre a decisão; nunca a aumenta.

=== Informação compartilhada e endereçamento

O caso que mais nos interessa é aquele em que emissor e receptor compartilham informação prévia. Se ambos têm acesso a um acervo $Sigma$ com $N$ itens enumerados, então, para comunicar _qual_ item é relevante, basta transmitir seu índice, ao custo de $ceil(log_2 N)$ bits — independentemente do tamanho do item. Em termos de entropia condicional, se $Y$ é o conteúdo do item e $Z$ é o índice, $H(Y | Z, Sigma) = 0$: dado o acervo, o índice determina o conteúdo.

#proposicao(titulo: [Custo de referência versus custo de inclusão])[
  Sejam $Sigma$ um acervo compartilhado com $N$ itens e $S subset.eq Sigma$ um subconjunto de $k$ itens com comprimentos $ell(s)$ (em bits). Transmitir $S$ por inclusão custa $sum_(s in S) ell(s)$ bits; transmitir $S$ por referência custa no máximo $k ceil(log_2 N)$ bits. Se o receptor precisa ler efetivamente apenas um subconjunto $S' subset.eq S$, o custo total por referência com leitura sob demanda é $k ceil(log_2 N) + sum_(s in S') ell(s)$.
] <prop-ap-referencia>

#prova[
  Imediata a partir das definições: cada referência é um índice em ${1, dots, N}$, codificável com $ceil(log_2 N)$ bits, e o conteúdo só é transmitido para os itens efetivamente lidos.
]

A proposição é trivial como matemática, mas fundamenta uma distinção conceitual que atravessa o livro: a _compressão por resumo_ reduz o custo descartando informação (é, em geral, com perdas, e o que se perde não pode ser recuperado pelo receptor), enquanto a _compressão por endereçamento_ reduz o custo deslocando a informação para um acervo compartilhado e transmitindo apenas coordenadas (é sem perdas, desde que o receptor possa resolver as coordenadas). O @cap-compressao desenvolve essa distinção e suas condições de validade — em particular, a de que endereçar só funciona quando a resolução da coordenada é confiável e quando o receptor sabe _quando_ precisa resolvê-la.

#exercicios[
  + Calcule a entropia de uma variável que assume quatro valores com probabilidades $1\/2, 1\/4, 1\/8, 1\/8$, e construa um código de prefixo cujo comprimento esperado seja igual à entropia.
  + Prove que $H(X, Y) = H(X) + H(Y | X)$ (regra da cadeia).
  + Um acervo tem $N = 10^6$ itens, cada um com cerca de $2000$ bits. Um consumidor recebe referências a $k = 50$ itens e lê, em média, $5$ deles. Compare o custo esperado com o de incluir os 50 itens. Em que situação a estratégia por referência é pior que a inclusão?
  + Mostre que a compressão por endereçamento, vista como o par (referências $A$, acervo $Sigma$), não está sujeita à perda do @cor-ap-resumo quando o receptor tem acesso a $Sigma$: se $A$ endereça tudo o que $H_t$ registrou, então $I(D; (A, Sigma)) = I(D; (H_t, Sigma))$.
]

== Funções submodulares <sec-ap-submodular>

Seja $U$ um conjunto finito e $f: cal(P)(U) -> bb(R)$. Para $S subset.eq U$ e $x in U$, o _ganho marginal_ de $x$ em relação a $S$ é $Delta(x | S) = f(S union {x}) - f(S)$.

#definicao(titulo: [Função submodular])[
  A função $f$ é _submodular_ se, para todos $A subset.eq B subset.eq U$ e todo $x in U without B$,
  $ Delta(x | A) >= Delta(x | B). $
  Ela é _monótona_ se $A subset.eq B$ implica $f(A) lt.eq f(B)$, e _normalizada_ se $f(emptyset) = 0$.
] <def-ap-submodular>

A desigualdade expressa _retornos decrescentes_: acrescentar um item a um conjunto maior rende no máximo o que renderia acrescentá-lo a um conjunto menor. Uma definição equivalente é $f(A) + f(B) >= f(A union B) + f(A inter B)$ para todos $A, B$.

#exemplo(titulo: [Cobertura])[
  Seja $Q$ um conjunto de "necessidades de informação" (perguntas que um agente precisa conseguir responder) e, para cada item de contexto $x in U$, seja $"cob"(x) subset.eq Q$ o conjunto das necessidades que $x$ satisfaz. A função de _cobertura ponderada_ $f(S) = sum_(q in union.big_(x in S) "cob"(x)) w(q)$, com pesos $w(q) >= 0$, é normalizada, monótona e submodular: o ganho marginal de $x$ é o peso das necessidades que $x$ cobre e que _ainda não_ foram cobertas, e esse conjunto só diminui quando $S$ cresce.
] <ex-ap-cobertura>

Outros exemplos importantes: a entropia conjunta $f(S) = H(X_S)$ de um conjunto de variáveis aleatórias é submodular (consequência de "condicionar não aumenta a entropia"), assim como a informação mútua com uma variável-alvo sob hipóteses de independência condicional @krause2014.

=== O algoritmo guloso

Considere o problema de maximizar uma função submodular monótona e normalizada sujeita a uma restrição de cardinalidade: $max {f(S) : |S| lt.eq k}$. O algoritmo guloso escolhe, a cada passo, o item de maior ganho marginal.

#algoritmo("Guloso-Submodular", params: $f, U, k$, legenda: [Maximização gulosa de função submodular sob restrição de cardinalidade.])[
  + $S <- emptyset$
  + #kw[para] $i <- 1$ #kw[até] $k$ #kw[faça]
    + $x^* <- arg max_(x in U without S) Delta(x | S)$
    + $S <- S union {x^*}$
  + #kw[devolva] $S$
] <alg-ap-guloso>

#teorema(titulo: [Nemhauser, Wolsey e Fisher])[
  Se $f$ é normalizada, monótona e submodular, o conjunto $S$ devolvido pelo @alg-ap-guloso satisfaz
  $ f(S) >= (1 - (1 - 1/k)^k) f(S^*) >= (1 - 1/e) f(S^*) approx "0,632" thin f(S^*), $
  em que $S^*$ é um conjunto ótimo com $|S^*| lt.eq k$.
] <teo-ap-nemhauser>

#prova[
  Seja $S_i$ o conjunto após $i$ iterações, e $"OPT" = f(S^*)$. Pela monotonicidade, $"OPT" lt.eq f(S_i union S^*)$. Escrevendo $S^* without S_i = {y_1, dots, y_r}$ com $r lt.eq k$ e somando ganhos marginais sucessivos,
  $ f(S_i union S^*) = f(S_i) + sum_(j=1)^r Delta(y_j | S_i union {y_1, dots, y_(j-1)}) lt.eq f(S_i) + sum_(j=1)^r Delta(y_j | S_i), $
  em que a desigualdade usa submodularidade. Cada termo da soma é no máximo o ganho do item escolhido pelo guloso, $Delta(x^*_(i+1) | S_i) = f(S_(i+1)) - f(S_i)$. Logo $"OPT" - f(S_i) lt.eq k (f(S_(i+1)) - f(S_i))$, ou seja,
  $ "OPT" - f(S_(i+1)) lt.eq (1 - 1/k) ("OPT" - f(S_i)). $
  Aplicando a desigualdade $k$ vezes a partir de $f(S_0) = 0$, obtemos $"OPT" - f(S_k) lt.eq (1 - 1\/k)^k "OPT" lt.eq e^(-1) "OPT"$, como queríamos.
]

Quando os itens têm custos diferentes — o caso típico em contexto, em que cada item consome um número diferente de _tokens_ — a restrição natural é de _mochila_: $sum_(x in S) c(x) lt.eq W$. O guloso que escolhe pela razão $Delta(x | S) \/ c(x)$ pode ser arbitrariamente ruim sozinho, mas a melhor entre sua solução e o melhor item isolado garante uma fração constante do ótimo, e uma variante com enumeração parcial de conjuntos iniciais de três itens recupera a garantia $1 - 1\/e$ @khuller1999 @sviridenko2004. O @cap-selecao aplica esses resultados à seleção de contexto sob orçamento de _tokens_.

#exercicios[
  + Prove a equivalência entre a definição de submodularidade por ganhos marginais e a desigualdade $f(A) + f(B) >= f(A union B) + f(A inter B)$.
  + Mostre que a função de cobertura do @ex-ap-cobertura é submodular.
  + Construa uma instância com restrição de mochila em que o guloso por razão ganho/custo devolve uma solução de valor arbitrariamente pequeno em relação ao ótimo. (Dica: um item minúsculo com ótima razão e um item grande que ocupa quase todo o orçamento.)
  + #avancado Mostre que, se $f$ é submodular mas não monótona, o guloso pode não ter garantia constante.
]

== Complexidade computacional <sec-ap-complexidade>

Recordamos as noções básicas; o tratamento completo está em #ct(<garey1979>) e no capítulo correspondente de #ct(<cormen2022>). Um _problema de decisão_ pertence à classe P se pode ser resolvido em tempo polinomial no tamanho da entrada, e à classe NP se toda instância positiva admite um _certificado_ verificável em tempo polinomial. Um problema $Pi$ é _NP-difícil_ se todo problema em NP se reduz a ele por uma redução de tempo polinomial; se, além disso, $Pi in "NP"$, ele é _NP-completo_. A menos que P = NP, nenhum problema NP-difícil admite algoritmo de tempo polinomial.

Usaremos repetidamente o seguinte problema clássico, um dos 21 problemas NP-completos de #ct(<karp1972>).

#definicao(titulo: [Cobertura de conjuntos])[
  Uma instância de #proc("Set-Cover") consiste num universo finito $Q$, numa família $cal(F) = {F_1, dots, F_m}$ de subconjuntos de $Q$ cuja união é $Q$, e num inteiro $k$. A pergunta é: existem $k$ conjuntos de $cal(F)$ cuja união é $Q$?
] <def-ap-set-cover>

#teorema(titulo: [Dificuldade de aproximação da cobertura])[
  #proc("Set-Cover") é NP-completo @karp1972. Além disso, para todo $epsilon > 0$, não existe algoritmo de tempo polinomial que aproxime o tamanho da menor cobertura a um fator $(1 - epsilon) ln |Q|$, a menos que $"NP" subset.eq "DTIME"(n^(O(log log n)))$ @feige1998; a mesma conclusão vale sob a hipótese mais fraca $"P" != "NP"$ @dinur2014. O algoritmo guloso atinge fator $H(|Q|) lt.eq ln |Q| + 1$, em que $H(n)$ é o $n$-ésimo número harmônico @johnson1974 @lovasz1975 @chvatal1979.
] <teo-ap-set-cover>

O @cap-selecao mostra, por redução a partir de #proc("Set-Cover"), que decidir se existe um contexto _suficiente_ de tamanho limitado para um conjunto de necessidades de informação é NP-completo, e usa o @teo-ap-set-cover para concluir que nenhum procedimento eficiente pode, em geral, garantir contexto suficiente de tamanho próximo ao mínimo. Essa é a justificativa formal para uma prática que o livro defende em vários capítulos: em vez de buscar o contexto ótimo, projetar contextos _suficientes por construção_ (por meio de coordenadas e fronteiras de expansão) e medir empiricamente sua adequação.

#exercicios[
  + Mostre que #proc("Set-Cover") está em NP, descrevendo o certificado e o verificador.
  + O problema da mochila 0-1 é NP-completo, mas admite algoritmo pseudopolinomial por programação dinâmica. Explique a diferença e discuta se o orçamento de _tokens_ de um contexto (tipicamente da ordem de $10^5$ a $10^6$) torna essa programação dinâmica praticável.
  + #avancado Mostre que o guloso para #proc("Set-Cover") atinge o fator $H(|Q|)$. (Dica: distribua o custo de cada conjunto escolhido igualmente entre os elementos que ele cobre pela primeira vez.)
]

#problemas[
  #problema([Seleção com redundância])[
    Itens de contexto frequentemente se sobrepõem: dois documentos podem repetir a mesma informação.
    + Modele a utilidade de um conjunto de itens como cobertura ponderada de "unidades de informação" e mostre que a redundância é capturada automaticamente pela submodularidade.
    + A heurística de _relevância marginal máxima_ (MMR) de #ct(<carbonell1998>) escolhe itens que maximizam uma combinação linear de relevância e dissimilaridade em relação aos já escolhidos. Mostre que ela é um caso particular de guloso sobre uma função (não necessariamente submodular) e discuta quando a garantia do @teo-ap-nemhauser se aplica.
    + Proponha um experimento para estimar empiricamente a função de utilidade de itens de contexto para uma tarefa concreta.
  ]
  #problema([Endereçamento com falhas de resolução])[
    Na @prop-ap-referencia supusemos que toda referência pode ser resolvida. Suponha agora que cada referência falha independentemente com probabilidade $q$, e que uma falha obriga o receptor a recorrer a um procedimento de reconstrução de custo $R$ bits.
    + Calcule o custo esperado da estratégia por referência.
    + Determine o valor de $q$ a partir do qual incluir os itens diretamente é mais barato.
    + Discuta por que falhas de resolução _silenciosas_ (a referência resolve para o item errado) são muito mais graves do que falhas _detectáveis_, e relacione com a distinção entre identidade e localizador estudada no @cap-identidade.
  ]
]

#notas[
  #ct(<cover2006>) é a referência padrão para teoria da informação; o artigo fundador é #ct(<shannon1948>). A teoria da maximização de funções submodulares começa com #ct(<nemhauser1978>); o caso com restrição de mochila foi resolvido por #ct(<khuller1999>) e #ct(<sviridenko2004>), e #ct(<krause2014>) é uma excelente introdução com aplicações em aprendizado de máquina e seleção de informação. A NP-completude de #proc("Set-Cover") é de #ct(<karp1972>); a análise do guloso, de #ct(<johnson1974>), #ct(<lovasz1975>) e #ct(<chvatal1979>); o limite de aproximação $ln n$, de #ct(<feige1998>), sob hipótese de tempo quase polinomial, e de #ct(<dinur2014>), sob $"P" != "NP"$. A desigualdade de concentração é de #ct(<hoeffding1963>), e a desigualdade do processamento de dados, com o conceito de estatística suficiente em forma informacional, está em #ct(<cover2006>); #ct(<garey1979>) permanece a referência clássica para NP-completude. A heurística MMR de #ct(<carbonell1998>) é um dos primeiros tratamentos explícitos de redundância na seleção de documentos para leitura humana — preocupação que, trinta anos depois, reaparece na seleção de contexto para leitura por máquinas.
]
