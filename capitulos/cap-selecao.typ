#import "/modelo/estilo.typ": *

= Seleção de contexto: suficiência, otimização e complexidade <cap-selecao>

#epigrafe(fonte: [Antoine de Saint-Exupéry])[A perfeição é atingida não quando não há mais nada a acrescentar, mas quando não há mais nada a retirar.]

O @cap-modelo definiu o que significa uma perspectiva ser _suficiente_ para uma coordenada: responder a todas as necessidades de informação com a mesma fidelidade epistêmica do acervo inteiro. Este capítulo pergunta quanto custa encontrá-la. A resposta tem duas metades. A metade negativa é que encontrar a perspectiva suficiente _mínima_ é NP-difícil, e nem sequer se pode aproximá-la eficientemente a menos de um fator logarítmico. A metade positiva é que versões naturais do problema — maximizar cobertura de necessidades sob orçamento de tokens — admitem algoritmos gulosos simples com garantias constantes, e que, quando o acervo é organizado de modo que cada conceito tenha um _dono semântico_ único, a suficiência pode ser obtida _por construção_, sem busca combinatória.

A @sec-selecao-problema formula o problema. A @sec-selecao-dureza prova sua dureza. A @sec-selecao-guloso apresenta algoritmos aproximados para a versão com orçamento. A @sec-selecao-utilidade discute como estimar, na prática, a utilidade de itens, incluindo redundância e dependências. A @sec-selecao-construcao desenvolve a estratégia de suficiência por construção. A @sec-selecao-ordem trata da ordenação dos itens selecionados, a @sec-selecao-adaptativa, da seleção adaptativa com expansão sob demanda, e a @sec-selecao-rag, da recuperação aumentada vista como seleção aproximada.

== O problema da seleção <sec-selecao-problema>

Fixemos uma coordenada $kappa$ e o subacervo aplicável e legível. Os candidatos à inclusão são _itens_ — asserções, grupos de asserções, documentos ou trechos — cada um com um custo.

#definicao(titulo: [Instância de seleção])[
  Uma _instância de seleção_ é uma tupla $(I, c, Q, w, "sup", B)$ em que $I$ é um conjunto finito de itens; $c: I -> bb(N)$ dá o custo de cada item (em tokens, após renderização); $Q$ é o conjunto de necessidades de informação; $w: Q -> bb(R)_(>= 0)$ dá a importância de cada necessidade; $"sup"$ associa a cada necessidade $q$ uma família de _suportes_ — subconjuntos $T subset.eq I$ tais que incluir todos os itens de $T$ basta para responder $q$ —; e $B$ é o orçamento. Um conjunto $S subset.eq I$ _responde_ $q$ se contém algum suporte de $q$. O custo de $S$ é $c(S) = sum_(i in S) c(i)$.
] <def-instancia-selecao>

Dois casos particulares importam:

- No caso _disjuntivo_ (ou de suportes unitários), todo suporte tem um único item: $q$ é respondida se algum item que a "cobre" for incluído. Escrevemos $"cob"(i) = {q : {i} in "sup"(q)}$.
- No caso _conjuntivo_, uma necessidade pode exigir vários itens simultaneamente — por exemplo, a definição de um identificador e a asserção que o usa.

Há duas formulações de otimização naturais:

/ Mínima suficiência: encontrar $S$ de custo mínimo que responda a todo $q in Q$.
/ Máxima cobertura com orçamento: encontrar $S$ com $c(S) lt.eq B$ que maximize $f(S) = sum_(q "respondida por" S) w(q)$.

A primeira corresponde ao ideal de "menor contexto suficiente"; a segunda, à situação prática em que o orçamento é dado e se quer o melhor contexto possível dentro dele.

#exercicios[
  + Modele como instância de seleção a tarefa "explicar por que o teste $T$ falha", com itens: o código do teste, o código da função testada, o registro de execução, a última alteração na função, a documentação da função. Quais necessidades são disjuntivas e quais conjuntivas?
  + Mostre que, no caso disjuntivo, $f$ é uma função de cobertura ponderada e, portanto, normalizada, monótona e submodular (@ex-ap-cobertura).
  + Dê um exemplo de instância de seleção em que o item de maior relevância individual não pertence a nenhuma seleção ótima sob o orçamento dado. Que propriedade da utilidade torna isso possível?
]

== Dureza <sec-selecao-dureza>

#teorema(titulo: [Suficiência limitada é NP-completa])[
  O problema de decisão "dada uma instância de seleção, existe $S$ com $c(S) lt.eq B$ que responde a todas as necessidades?" é NP-completo, mesmo no caso disjuntivo com custos unitários.
] <teo-suficiencia-np>

#prova[
  _Pertinência a NP_: um conjunto $S$ é um certificado; verificar $c(S) lt.eq B$ e que cada $q$ tem um suporte contido em $S$ leva tempo polinomial.

  _Dureza_: reduzimos #proc("Set-Cover") (@def-ap-set-cover). Dada uma instância $(Q, cal(F) = {F_1, dots, F_m}, k)$, construa a instância de seleção com itens $I = {1, dots, m}$, custos $c(j) = 1$, necessidades $Q$ e suportes unitários $"sup"(q) = {{j} : q in F_j}$, e orçamento $B = k$. Um conjunto $S subset.eq I$ responde a todas as necessidades se e somente se ${F_j : j in S}$ cobre $Q$, e $c(S) = |S|$. Logo existe cobertura com $k$ conjuntos se e somente se existe seleção suficiente com custo $lt.eq k$. A construção é claramente polinomial.
]

#corolario(titulo: [Inaproximabilidade])[
  A menos que P = NP, nenhum algoritmo de tempo polinomial encontra, para toda instância disjuntiva com custos unitários, uma seleção suficiente de custo inferior a $(1 - epsilon) ln |Q|$ vezes o mínimo, para nenhum $epsilon > 0$.
] <cor-inaproximabilidade>

#prova[
  A redução do @teo-suficiencia-np preserva exatamente o valor das soluções (custo da seleção = número de conjuntos da cobertura). Um algoritmo com fator melhor que $(1 - epsilon) ln |Q|$ para a seleção daria o mesmo fator para #proc("Set-Cover"), contrariando o @teo-ap-set-cover na forma de #ct(<dinur2014>). (A versão original do limiar, de #ct(<feige1998>), supunha a hipótese mais forte de que NP não está contido em tempo quase polinomial.)
]

O caso conjuntivo é ainda pior, de uma maneira instrutiva: a função de cobertura deixa de ser submodular.

#proposicao(titulo: [Complementaridade destrói a submodularidade])[
  No caso conjuntivo, a função $f(S) = sum_(q "respondida por" S) w(q)$ pode não ser submodular.
] <prop-conjuntivo>

#prova[
  Considere itens $a, b$ e uma única necessidade $q$ com suporte ${a, b}$ e peso $1$. Então $Delta(a | emptyset) = 0$ e $Delta(a | {b}) = 1$, violando $Delta(a | emptyset) >= Delta(a | {b})$.
]

Os conflitos produzem o mesmo fenômeno, e isso liga a honestidade (P4) à complexidade da seleção.

#proposicao(titulo: [Conflitos tornam a seleção conjuntiva])[
  Se o acervo sustenta uma necessidade $q$ com estatuto #est[conflitante], então todo suporte honesto de $q$ — que a responda com o estatuto do acervo (@def-suficiencia) — contém ao menos uma asserção de suporte e uma de contra-suporte. Em particular, a função de cobertura honesta pode deixar de ser submodular mesmo quando todos os itens são asserções unitárias.
] <prop-conflito-conjuntivo>

#prova[
  Um subconjunto com apenas asserções de suporte responde #est[provado]; com apenas contra-suporte, #est[refutado]; nenhum dos dois é o estatuto do acervo. Logo todo suporte honesto contém as duas espécies, e a @prop-conjuntivo se aplica tomando $a$ de suporte e $b$ de contra-suporte.
]

A prova revela a origem do problema: itens _complementares_ — que só têm valor juntos — produzem retornos crescentes, e algoritmos gulosos, que olham um item de cada vez, não os enxergam. O exemplo não é artificial. Uma asserção que menciona o identificador opaco de um recurso só é útil se a definição desse identificador também estiver presente; um trecho de registro de execução só é interpretável junto com a versão do código que o produziu. Voltaremos a essas _dependências_ na @sec-selecao-utilidade.

#exercicios[
  + Mostre que o problema de mínima suficiência no caso disjuntivo, com custos arbitrários, é o problema de cobertura de conjuntos ponderada, e que o guloso por razão custo/novas-necessidades atinge fator $H(|Q|)$ @johnson1974 @chvatal1979.
  + Construa uma família de instâncias conjuntivas em que o guloso por ganho marginal devolve um conjunto de valor $0$, enquanto o ótimo tem valor arbitrariamente grande.
  + #avancado Mostre que a versão de _máxima cobertura com orçamento_ — escolher no máximo $B$ itens que respondam a pelo menos $k$ necessidades — continua NP-difícil mesmo quando cada necessidade tem um único suporte de tamanho 2. (Dica: redução de #proc("Clique") com $B = k$ e meta $binom(k, 2)$.) Por que a versão de suficiência total é trivial nesse caso?
]

== Seleção gulosa com garantias <sec-selecao-guloso>

Voltamos ao caso disjuntivo, em que $f$ é submodular monótona, e à formulação com orçamento. Se todos os itens tivessem o mesmo custo, o @teo-ap-nemhauser garantiria que o guloso atinge $1 - 1\/e$ do ótimo. Com custos diferentes, a regra natural é escolher pela _razão_ entre ganho marginal e custo — mas, sozinha, ela pode falhar.

#exemplo(titulo: [O guloso por razão pode falhar])[
  Orçamento $B = 100$. O item $a$ custa $1$ e cobre uma necessidade de peso $2$; o item $b$ custa $100$ e cobre uma necessidade de peso $100$. A razão de $a$ é $2$; a de $b$, $1$. O guloso escolhe $a$ e não cabe mais nada: valor $2$. O ótimo escolhe $b$: valor $100$.
] <ex-guloso-falha>

A correção, devida a #ct(<khuller1999>), é comparar o resultado do guloso com o melhor item isolado.

#algoritmo("Seleciona-com-Orçamento", params: $I, c, f, B$, legenda: [Guloso por razão ganho/custo combinado com o melhor item isolado.])[
  + $S <- emptyset$; $R <- {x in I : c(x) lt.eq B}$ #h(1fr) ▷ itens que cabem sozinhos
  + #kw[enquanto] $R != emptyset$ #kw[faça]
    + $x <- arg max_(x in R) Delta(x | S) \/ c(x)$
    + #kw[se] $c(S) + c(x) lt.eq B$ #kw[então] $S <- S union {x}$
    + $R <- R without {x}$
  + $x^* <- arg max_(x in I, c(x) lt.eq B) f({x})$
  + #kw[se] $f({x^*}) > f(S)$ #kw[então] #kw[devolva] ${x^*}$ #kw[senão] #kw[devolva] $S$
] <alg-orcamento>

#teorema(titulo: [Garantia do guloso com orçamento])[
  Se $f$ é normalizada, monótona e submodular, o @alg-orcamento devolve um conjunto de valor ao menos $(1 - 1\/e) \/ 2$ do ótimo. Uma variante que enumera todos os conjuntos iniciais de até três itens e completa cada um com o guloso atinge $1 - 1\/e$, com custo polinomial de grau maior.
] <teo-orcamento>

A garantia de $(1 - 1\/e) \/ 2$ para o guloso com o melhor item isolado é de #ct(<khuller1999>) para cobertura e se estende a funções submodulares monótonas gerais; a variante com enumeração parcial, de fator $1 - 1\/e$, é de #ct(<sviridenko2004>). A prova segue a mesma estrutura da do @teo-ap-nemhauser, aplicada ao primeiro item que o guloso _não_ consegue incluir, e é pedida no primeiro problema ao final deste capítulo; o descarte inicial dos itens que não cabem sozinhos no orçamento é necessário para ela.

#observacao(titulo: [Custo computacional])[A implementação direta do @alg-orcamento avalia ganhos marginais de todos os itens restantes a cada passo, com $O(|I|^2)$ avaliações de $f$. Como os ganhos marginais só diminuem (submodularidade), a avaliação _preguiçosa_ — manter os itens numa fila de prioridade com ganhos possivelmente desatualizados e reavaliar apenas o topo — produz o mesmo resultado com, tipicamente, muito menos avaliações. A técnica é de #ct(<minoux1978>).]

#exercicios[
  + Execute o @alg-orcamento no @ex-guloso-falha e verifique que ele devolve o ótimo.
  + Prove que a avaliação preguiçosa produz exatamente a mesma sequência de escolhas que a avaliação completa.
  + Discuta por que a garantia de $(1 - 1\/e)\/2$, embora modesta, é valiosa na prática, e por que o desempenho observado costuma ser muito melhor.
]

== Estimando utilidade: relevância, redundância e dependências <sec-selecao-utilidade>

Os algoritmos da seção anterior supõem conhecidas as necessidades $Q$, os pesos $w$ e a relação de cobertura. Na prática, nenhum desses é dado; precisam ser estimados. Esta seção organiza as estimativas mais comuns e mostra onde cada uma se encaixa no modelo.

=== Relevância

A estimativa mais simples substitui necessidades por uma única consulta e atribui a cada item uma _pontuação de relevância_ $r(i)$ — por correspondência lexical, como no BM25 @robertson2009, por similaridade de representações vetoriais densas @karpukhin2020, ou por um modelo de reordenação. A seleção passa a maximizar $sum_(i in S) r(i)$ sob orçamento: um problema de mochila, com função _modular_ (aditiva). Essa é a base de grande parte da geração aumentada por recuperação @lewis2020, e tem duas fraquezas conhecidas: ignora redundância (dois itens quase idênticos somam relevância) e ignora complementaridade (um item pouco relevante isoladamente pode ser indispensável junto com outro).

=== Redundância

Redundância é capturada naturalmente por modelos de cobertura: se dois itens cobrem as mesmas unidades de informação, o segundo tem ganho marginal nulo. Modelos de cobertura "suaves", em que a utilidade de um conjunto cresce de forma côncava com a soma das similaridades, mantêm a submodularidade e foram usados com sucesso em sumarização @lin2011. A heurística MMR @carbonell1998 é um guloso sobre uma função que combina relevância e dissimilaridade; nem sempre submodular, mas eficaz.

=== Dependências

A complementaridade mais comum em contexto tem uma estrutura especial: itens _dependem_ de outros para serem interpretáveis. Uma asserção sobre $N:x$ depende da asserção que diz o que é $N:x$; um trecho de código depende das definições dos tipos que usa; uma decisão depende do problema que a motivou.

#definicao(titulo: [Fecho de dependências])[
  Um _grafo de dependências_ sobre $I$ é um DAG $D$ em que uma aresta $(i, j)$ significa "$i$ só é interpretável se $j$ estiver presente". Um conjunto $S$ é _fechado_ se, para todo $i in S$ e toda aresta $(i, j)$, temos $j in S$. O _fecho_ de $S$, $overline(S)$, é o menor conjunto fechado que contém $S$.
] <def-fecho-dependencias>

Restringir a seleção a conjuntos fechados transforma o problema numa _mochila com precedência_, que continua NP-difícil, mas admite uma heurística natural: aplicar o guloso não a itens isolados, mas a _fechos_, com ganho $Delta(overline({i}) | S)$ e custo $c(overline({i}) without S)$. A heurística captura a complementaridade mais frequente — definição mais uso — e mantém a simplicidade do guloso.

#principio(titulo: [Nenhum identificador órfão])[
  Todo identificador que aparece num contexto renderizado deve estar definido no próprio contexto ou ser resolúvel por uma alça de expansão explícita. Um identificador órfão consome tokens, não transmite informação e convida o consumidor a inventar seu significado.
] <pri-identificador-orfao>

#exercicios[
  + Dê um exemplo de dois itens com alta relevância individual e ganho conjunto quase igual ao de um só. Mostre como um modelo de cobertura evita selecionar ambos.
  + Mostre que o problema de mochila com precedência admite algoritmo pseudopolinomial quando o grafo de dependências é uma floresta (programação dinâmica em árvore) e discuta por que ele é fortemente NP-difícil em grafos acíclicos gerais @johnson1983.
  + Proponha um procedimento que, dado um contexto renderizado, detecte identificadores órfãos. Que informações do acervo ele precisa consultar?
]

== Suficiência por construção <sec-selecao-construcao>

Os resultados negativos da @sec-selecao-dureza dizem respeito a instâncias _arbitrárias_. Mas o acervo e as necessidades não são arbitrários: são projetados. Esta seção mostra que, com duas disciplinas de organização, a suficiência deixa de ser um problema de busca.

A primeira disciplina é tipificar as transições. Toda coordenada tem uma transição $tau$ — promover uma revisão, retomar um trabalho interrompido, autorizar uma ação, responder a uma pergunta de auditoria — e transições do mesmo _tipo_ têm, em geral, as mesmas necessidades de informação. Para promover uma revisão, por exemplo, é preciso saber qual é o candidato, qual a linha de base aceita, que evidência sustenta o candidato, quem tem autoridade para promover, se há conflitos com o alvo e que desconhecidos permanecem.

#definicao(titulo: [Gabarito de necessidades])[
  Um _gabarito de necessidades_ associa a cada tipo de transição $theta$ um conjunto finito de _perguntas parametrizadas_ $Q_theta$, tal que, para toda coordenada $kappa$ cuja transição tem tipo $theta$, $Q(kappa)$ é obtido instanciando $Q_theta$ com os parâmetros de $kappa$.
] <def-gabarito>

A segunda disciplina é a _soberania semântica_: para cada tipo de pergunta, existe no acervo uma _fonte canônica_ — um único dono responsável por respondê-la. "Qual é a linha de base aceita?" tem como dono o registro de linhas de base, não os comentários espalhados em mensagens; "quem pode promover?" tem como dono o registro de autoridade, não a memória do agente.

#definicao(titulo: [Dono semântico])[
  Um acervo tem _donos semânticos_ para um gabarito se, para cada pergunta parametrizada $q in Q_theta$, existe uma função de resolução $"dono"_q$ que, dados os parâmetros, devolve um conjunto de asserções $A_q$ do acervo que responde $q$ com o estatuto que o acervo sustenta — inclusive #est[desconhecido], quando for o caso.
] <def-dono-semantico>

#teorema(titulo: [Suficiência por construção])[
  Seja $kappa$ uma coordenada cuja transição tem tipo $theta$, e suponha que o acervo tenha donos semânticos para $Q_theta$ e que as respostas sejam _locais_: a resposta a $q$ a partir de qualquer superconjunto de $A_q$ contido no acervo é a mesma que a partir de $A_q$. Então a perspectiva cujos fatos são $union.big_(q in Q(kappa)) A_q$ é suficiente para $kappa$, pode ser calculada com $|Q_theta|$ chamadas de resolução, sem busca combinatória, e tem custo no máximo $sum_(q in Q(kappa)) c(A_q)$.
] <teo-suficiencia-construcao>

#prova[
  Por definição de dono semântico, cada $A_q$ responde $q$ com o estatuto sustentado pelo acervo; pela localidade, acrescentar os demais $A_(q')$ não altera essa resposta, e a união responde todas as perguntas de $Q(kappa)$, o que é a definição de suficiência. O cálculo consiste em instanciar o gabarito e chamar cada função de resolução uma vez. O custo é subaditivo na união.
]

A hipótese de localidade não é decorativa: com suplantação ou com conflitos, uma asserção trazida para responder a $q'$ pode alterar a resposta a $q$. E o teorema promete suficiência, não minimalidade: a perspectiva construída pode ser muito maior que a mínima, e a razão entre seu custo e o ótimo não é limitada em geral.

O teorema não contradiz o @teo-suficiencia-np: ele transfere a dificuldade do _momento da consulta_ para o _momento do projeto_ do acervo. A combinatória desaparece porque cada pergunta tem um lugar canônico para ser respondida — exatamente o que falta quando a mesma informação está espalhada, duplicada e parcialmente contraditória em muitas fontes, situação em que voltamos a ter de escolher, entre várias coberturas possíveis, a mais barata e confiável.

#principio(titulo: [Um dono semântico por conceito])[
  Para cada conceito que participa de decisões — linha de base, autoridade, estado de um trabalho, identidade de um recurso — mantenha exatamente uma fonte canônica no estado corrente do sistema. Fontes históricas, cópias e resumos podem existir, mas apontam para o dono; não competem com ele.
] <pri-dono-semantico>

=== Contexto requerido e contexto declarado

Quando o gabarito exige uma informação que nenhum dono consegue fornecer — o registro não existe, a fonte está indisponível, o consumidor não tem autoridade para lê-la —, a seleção não pode simplesmente prosseguir com o que há. O resultado correto é explícito: _contexto requerido ausente_, com a lista do que falta, e o plano de ação correspondente fica bloqueado nessa aresta. Seguir adiante com uma perspectiva incompleta, sem declarar a falta, é a forma mais comum de transformar uma lacuna de contexto numa decisão errada.

#invariante(titulo: [Contexto requerido ausente é um resultado])[
  Se uma pergunta exigida pelo gabarito da transição não pode ser respondida, a seleção devolve #estado[requerido ausente], com a pergunta, a razão e o dono; o planejamento da transição fica bloqueado nessa aresta. Disponível, materializado, selecionado e renderizado são estados distintos, e "requerido ausente" só se conclui depois de verificar que o requerido não está disponível — não apenas que ainda não foi materializado.
] <inv-requerido-ausente>

Uma fonte especial de necessidades é o _contexto declarado_: a declaração explícita, pelo titular de um recurso ou de uma aplicação, do contexto pretendido — propósito, audiência, contexto operacional, o que deve e o que não deve ser incluído, resultados desejados. O contexto declarado alimenta os gabaritos e a relevância (@cap-relevancia), mas não é o contexto corrente (que é calculado), nem a projeção, nem autoridade: declarar que um documento deve ser incluído não dá a ninguém o direito de lê-lo.

Por fim, a seleção opera sobre asserções _com estatuto_. Um marcador de desconhecido — "a aprovação do titular é desconhecida; dono: titular; caminho: pedir confirmação" — consome orçamento como qualquer outro item e tem valor próprio: ele evita que o consumidor suponha. Em perspectivas sob orçamento apertado, os marcadores de desconhecido das perguntas do gabarito têm prioridade sobre fatos de baixa relevância, porque sua omissão é exatamente o tipo de omissão silenciosa que P5 proíbe.

O princípio do dono semântico tem um custo: alguém precisa manter os donos atualizados e coerentes, o que é trabalho de gerenciamento e administração de contexto (Partes II e V). E tem um limite: perguntas novas, fora dos gabaritos, ainda exigem seleção heurística. A estratégia do livro combina as duas coisas — um _núcleo_ suficiente por construção, para as necessidades previsíveis do tipo de transição, e uma _fronteira_ expansível, para o imprevisto (@cap-fronteira).

#exercicios[
  + Escreva um gabarito de necessidades para a transição "retomar um trabalho interrompido por outro agente". Para cada pergunta, indique qual seria seu dono semântico num sistema que você conheça — ou registre que ele não existe.
  + Dê um exemplo em que um item "não materializado" foi tratado como "requerido ausente", levando a um bloqueio desnecessário. Que verificação teria evitado o erro?
  + Mostre que, se duas fontes respondem à mesma pergunta com estatutos incompatíveis e nenhuma é designada como dona, a suficiência por construção falha. Como a perspectiva deveria representar essa situação?
  + #avancado Formule o problema de projetar donos semânticos para um conjunto de gabaritos de forma a minimizar o custo total esperado das perspectivas, dado um modelo de frequência das transições. Esse problema é mais fácil ou mais difícil que a seleção?
]

== Ordenação dos itens selecionados <sec-selecao-ordem>

Escolhido o conjunto, resta decidir a ordem. O @cap-llm mostrou duas forças: o cache de prefixos favorece colocar o estável antes do volátil (@pri-estavel-volatil), e efeitos de posição podem favorecer colocar o importante perto do início ou do fim. Quando os efeitos de posição são conhecidos, a ordenação ótima decorre de uma desigualdade clássica.

#proposicao(titulo: [Ordenação por rearranjo])[
  Suponha que a contribuição de um item de importância $v_i$ colocado na posição $p$ seja $v_i lambda_p$, em que $lambda_1, dots, lambda_n >= 0$ são pesos de posição conhecidos. A soma $sum_i v_i lambda_(p(i))$ é maximizada pela permutação que associa os itens mais importantes às posições de maior peso.
] <prop-rearranjo>

#prova[
  É a desigualdade do rearranjo @hardy1934: para sequências $v$ e $lambda$, a soma dos produtos é máxima quando ambas estão ordenadas no mesmo sentido. Diretamente: se $v_i > v_j$ e $lambda_(p(i)) < lambda_(p(j))$, trocar as posições de $i$ e $j$ altera a soma em $(v_i - v_j)(lambda_(p(j)) - lambda_(p(i))) > 0$; logo, numa permutação ótima, não há tal par.
]

Com pesos em forma de "U" (@sec-llm-desempenho), a proposição recomenda os itens mais importantes nas extremidades e os menos importantes no meio. Combinada com o custo de cache, ela produz um problema de compromisso cuja solução prática mais comum é a já mencionada: prefixo estável com as definições e regras, miolo com material de apoio, e um segmento final curto e volátil com o objetivo corrente, as restrições críticas e os desconhecidos que bloqueiam a decisão.

#exercicios[
  + Com $lambda = (3, 1, 1, 1, 2)$ e importâncias $v = (5, 4, 3, 2, 1)$, encontre a ordenação ótima e seu valor.
  + Por que a hipótese de contribuições _separáveis_ ($v_i lambda_p$) é irrealista quando há dependências entre itens? Dê um exemplo em que colocar uma definição longe de seu uso prejudica o consumidor.
  + #avancado Generalize a @prop-rearranjo para o caso em que cada item ocupa várias posições consecutivas (itens de tamanhos diferentes). A ordenação por importância decrescente continua ótima? Dê um contraexemplo ou uma prova.
]

== Seleção adaptativa e expansão sob demanda <sec-selecao-adaptativa>

Até aqui, a seleção foi feita de uma vez, antes de o consumidor ver qualquer coisa. Mas agentes podem _pedir mais_: uma perspectiva com fronteira permite que o consumidor solicite expansões à medida que descobre o que precisa. Isso muda a natureza do problema: em vez de escolher um conjunto, escolhe-se uma _política_ — uma regra que, a cada passo, decide o que incluir com base no que já foi observado.

A teoria da _submodularidade adaptativa_ de #ct(<golovin2011>) estende o @teo-ap-nemhauser a esse cenário: se o ganho esperado de incluir um item, condicionado ao que já foi observado, é não negativo (_monotonicidade adaptativa_) e satisfaz uma versão adaptativa da propriedade de retornos decrescentes, então a política gulosa adaptativa — incluir, a cada passo, o item de maior ganho esperado condicional — atinge a fração $1 - 1\/e$ do valor da melhor política adaptativa com o mesmo _número_ de passos. A garantia vale para restrição de cardinalidade; com custos diferentes, valem resultados análogos aos do caso não adaptativo, com fatores mais fracos.

Para a engenharia de contexto, o resultado sugere uma decomposição do custo de uma interação:

#eqn($ "custo total" = c(P_0) + E[sum_(j=1)^J c("exp"_j)] + J dot c_"ida-e-volta", $) <eq-custo-adaptativo>

em que $P_0$ é a perspectiva inicial, $"exp"_j$ são as expansões solicitadas, $J$ é o número (aleatório) de expansões e $c_"ida-e-volta"$ é o custo fixo de cada rodada adicional (latência, reprocessamento de contexto). A @eq-custo-adaptativo explicita o compromisso: uma perspectiva inicial pequena reduz o primeiro termo, mas aumenta o número esperado de expansões; uma perspectiva inicial grande faz o oposto. O ponto ótimo depende de quão previsíveis são as necessidades — e é aqui que gabaritos de necessidades (@def-gabarito) se pagam: eles tornam previsível a maior parte do que será pedido, deixando para a expansão apenas o genuinamente imprevisto.

#exercicios[
  + Suponha que cada necessidade não prevista pelo gabarito ocorra, independentemente, com probabilidade $p$, e que incluí-la antecipadamente custe $c$ tokens, enquanto expandi-la sob demanda custe $c + c_"ida-e-volta"$. Para que valores de $p$ vale a pena incluí-la antecipadamente?
  + Explique por que uma fronteira mal projetada — com alças vagas como "ver mais" — anula as vantagens da seleção adaptativa.
  + Compare, num exemplo numérico, o custo esperado de (a) incluir antecipadamente um item com probabilidade $p$ de ser necessário e custo $c$, e (b) expandi-lo sob demanda com custo $c + r$, em que $r$ é o custo de uma rodada adicional. Para que valores de $p$ cada estratégia é melhor?
]


== Recuperação aumentada como seleção aproximada <sec-selecao-rag>

Na geração aumentada por recuperação, a seleção é feita por um índice que devolve os $k$ trechos mais semelhantes a uma consulta @lewis2020 @gao2023rag. No vocabulário deste capítulo, o índice estima a cobertura de cada item por uma pontuação de similaridade e seleciona por ordenação, sem considerar suportes conjuntivos, redundância ou estatuto.

#proposicao(titulo: [Revocação limita a suficiência])[
  Seja $R_k$ o conjunto recuperado e $"rec"_k = |{q in Q : R_k "contém um suporte de" q}| \/ |Q|$. Então a fração de necessidades respondidas por qualquer perspectiva formada a partir de $R_k$ é no máximo $"rec"_k$, qualquer que seja a qualidade da renderização.
] <prop-revocacao>

#prova[
  Uma necessidade só é respondida por uma perspectiva que contenha um de seus suportes; se nenhum suporte está em $R_k$, nenhuma perspectiva formada a partir de $R_k$ a responde.
]

Duas consequências merecem nota. Primeiro, segmentar documentos em trechos de tamanho fixo pode separar os dois itens de um suporte conjuntivo — a definição de um identificador e o trecho que o usa —, tornando a necessidade irrespondível para todo $k$: o fecho de dependências (@def-fecho-dependencias) é o critério que a segmentação deveria respeitar. Segundo, aumentar $k$ aumenta $"rec"_k$, mas também o número de distratores, que reduz o uso efetivo do contexto (@sec-llm-desempenho). O compromisso não é resolvido pela teoria da seleção, que supõe a cobertura conhecida; ele é medido empiricamente (@cap-avaliacao). E similaridade não é relação governada (@cap-epistemologia): o trecho mais parecido com a pergunta pode ser de uma versão antiga ou de outro domínio, e só a projeção, com estatuto e aplicabilidade, distingue os dois casos.

#exercicios[
  + Construa um documento e uma segmentação em trechos de 200 tokens em que uma necessidade conjuntiva fica irrespondível para todo $k$.
  + Proponha uma segmentação que respeite o fecho de dependências e estime seu custo em tokens.
  + #avancado Modele a escolha de $k$ como a maximização de $"rec"_k dot u(k)$, em que $u(k)$ é a fração de uso efetivo do contexto com $k$ trechos. Que hipóteses de forma sobre $u$ garantem um único ótimo?
]

#quadro[
  - Seleção suficiente mínima é NP-completa e inaproximável a menos de $ln |Q|$ (@teo-suficiencia-np, @cor-inaproximabilidade).
  - No caso disjuntivo, a cobertura sob orçamento é submodular; o guloso por razão combinado com o melhor item isolado garante fração constante do ótimo (@teo-orcamento).
  - Complementaridade (itens que só valem juntos) destrói a submodularidade; dependências de interpretação são o caso mais comum e podem ser tratadas com fechos.
  - Gabaritos de necessidades por tipo de transição e donos semânticos únicos tornam a suficiência uma questão de construção, não de busca (@teo-suficiencia-construcao).
  - Ordenação e expansão adaptativa completam a seleção: o núcleo previsível vai na perspectiva; o imprevisto, na fronteira.
  - Conflitos tornam a seleção honesta conjuntiva; na recuperação aumentada, a revocação limita a suficiência.
]

#problemas[
  #problema([Prova da garantia com orçamento])[
    Prove a primeira parte do @teo-orcamento seguindo os passos.
    + Seja $S_j$ o conjunto do guloso após incluir $j$ itens e seja $x_(j+1)$ o primeiro item que o guloso considerou e não pôde incluir por falta de orçamento. Mostre que, para todo $j$, $f(S_j union {x_(j+1)}) - f(S_j) >= (c(x_(j+1)) \/ B)("OPT" - f(S_j))$.
    + Conclua que $f(S_j union {x_(j+1)}) >= (1 - 1\/e) "OPT"$.
    + Use $f(S_j union {x_(j+1)}) lt.eq f(S_j) + f({x_(j+1)})$ para concluir que $max(f(S), f({x^*})) >= (1 - 1\/e)\/2 dot "OPT"$.
  ]
  #problema([Necessidades estimadas por amostragem])[
    Em vez de um gabarito explícito, um sistema estima as necessidades de informação observando quais itens os consumidores efetivamente expandem em tarefas semelhantes.
    + Formule a estimativa como um problema de aprendizado: que dados coletar, e que variável prever?
    + Discuta o viés introduzido pelo fato de que consumidores só podem expandir o que a fronteira oferece.
    + Proponha um procedimento de exploração que mitigue esse viés sem degradar muito as perspectivas oferecidas.
  ]
  #problema([Dono semântico ausente])[
    Num sistema real, a pergunta "qual é a versão correta do componente $X$?" é respondida de formas diferentes pelo registro de implantação, pelo arquivo de dependências do projeto e pelas notas de uma reunião.
    + Modele a situação como instância de seleção com três suportes alternativos e estatutos possivelmente conflitantes.
    + Mostre que nenhuma seleção pode ser ao mesmo tempo suficiente e honesta enquanto o conflito não for resolvido, a menos que a perspectiva declare o conflito.
    + Proponha um procedimento de administração que estabeleça um dono semântico e descreva o que acontece com as outras duas fontes.
  ]
]

#notas[
  A NP-completude da cobertura de conjuntos é de #ct(<karp1972>); o fator logarítmico do guloso, de #ct(<johnson1974>) e #ct(<chvatal1979>); o limite de aproximação, de #ct(<feige1998>) e, sob a hipótese P ≠ NP, de #ct(<dinur2014>). A maximização de funções submodulares monótonas sob cardinalidade foi analisada por #ct(<nemhauser1978>); o problema de cobertura máxima com orçamento e o guloso combinado com o melhor item isolado são de #ct(<khuller1999>), e a extensão a funções submodulares gerais com restrição de mochila, de #ct(<sviridenko2004>). #ct(<krause2014>) é uma introdução acessível, e #ct(<golovin2011>) desenvolveram a submodularidade adaptativa. Em recuperação de informação, o BM25 @robertson2009 e a recuperação densa @karpukhin2020 são as bases das estimativas de relevância usadas na geração aumentada por recuperação @lewis2020 @gao2023rag; a preocupação com redundância remonta à MMR de #ct(<carbonell1998>), e o uso de funções submodulares para sumarização foi sistematizado por #ct(<lin2011>). A desigualdade do rearranjo está em #ct(<hardy1934>).

  A ideia de suficiência por construção, a partir de gabaritos por tipo de transição e de donos semânticos únicos, é uma contribuição deste livro, mas tem raízes conhecidas: é a mesma lógica da normalização de bancos de dados (cada fato num só lugar), do princípio de ocultação de informação de #ct(<parnas1972>) (cada decisão de projeto com um único módulo responsável) e da observação de que a dificuldade de manutenção de sistemas cresce com a duplicação de responsabilidades @lehman1980.
]
