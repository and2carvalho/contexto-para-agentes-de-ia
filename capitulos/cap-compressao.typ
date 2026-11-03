#import "/modelo/estilo.typ": *

= Compressão por coordenadas <cap-compressao>

#epigrafe[Uma coordenada suficientemente rica pode substituir enormes quantidades de narrativa sem perder precisão.]

O contexto é caro (@sec-custo) e a atenção é finita (@pri-recurso-finito); por isso, toda engenharia de contexto é, em parte, engenharia de compressão. Mas há duas maneiras muito diferentes de comprimir. A primeira — a mais óbvia, e a mais usada — é _resumir_: substituir um texto longo por um mais curto que preserve o essencial. A segunda é _endereçar_: substituir conteúdo por coordenadas que permitem recuperá-lo de um acervo compartilhado, e transmitir apenas o que delimita o problema. A primeira perde informação de forma irrecuperável; a segunda, quando suas condições de validade são atendidas, não perde nada.

Este capítulo desenvolve a distinção. A @sec-comp-duas compara as duas compressões. A @sec-comp-coordenadas mostra como coordenadas reduzem o espaço de interpretações. A @sec-comp-validade enuncia as condições de validade do endereçamento. A @sec-comp-governada descreve a compressão governada sensível a coordenadas e o que ela deve preservar. A @sec-comp-densidade trata da densidade informacional por token e de escolhas de serialização. A @sec-comp-aprendida situa as técnicas de compressão aprendida.

== Duas compressões <sec-comp-duas>

#definicao(titulo: [Compressão por resumo e por endereçamento])[
  Seja $M$ um material (histórico, documentos, estado) a ser transmitido a um consumidor.
  - Uma _compressão por resumo_ é uma função $s: M -> M'$ com $|M'| << |M|$ tal que o consumidor recebe apenas $M'$. Em geral, $M$ não pode ser reconstruído a partir de $M'$.
  - Uma _compressão por endereçamento_ supõe um acervo $Sigma$ acessível ao consumidor e transmite um par $(kappa, A)$ em que $kappa$ é uma coordenada e $A$ um conjunto de referências resolúveis em $Sigma$, mais apenas o conteúdo indispensável para orientar. O consumidor recupera qualquer parte de $M$ resolvendo referências.
] <def-duas-compressoes>

A @prop-ap-referencia quantifica a diferença em bits: referenciar $k$ itens de um acervo com $N$ itens custa $O(k log N)$, independentemente do tamanho dos itens, e o consumidor paga o conteúdo apenas do que efetivamente lê. Mas a diferença mais importante não é de custo; é de _natureza_.

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([], [Resumo], [Endereçamento]),
    [Perda], [com perdas; o que foi omitido não é recuperável pelo consumidor], [sem perdas, se as referências resolvem],
    [Estatutos], [tendem a ser achatados ("os testes passaram")], [preservados nas asserções referenciadas],
    [Proveniência], [geralmente perdida], [preservada],
    [Atualidade], [congelada no momento do resumo], [verificável no momento da resolução],
    [Dependência], [nenhuma: o resumo é autossuficiente], [exige acervo acessível e resolução confiável],
    [Custo de leitura], [pago integralmente, mesmo para o irrelevante], [pago sob demanda],
  ),
  caption: [Resumo e endereçamento. O resumo é autossuficiente mas com perdas; o endereçamento é sem perdas mas depende de infraestrutura.],
) <tab-resumo-enderecamento>

#principio(titulo: [Resuma o que é narrativa; enderece o que é estado])[
  Use resumo para material cuja função é orientar e cujo detalhe não será verificado (por exemplo, a história de uma discussão). Use endereçamento para material que sustenta decisões e pode precisar ser verificado (estado de recursos, evidências, decisões registradas). Nunca substitua por resumo uma asserção que um portão precisará verificar.
] <pri-resumo-estado>

#exercicios[
  + Para cada item, indique se deve ser resumido ou endereçado numa transferência de trabalho: a discussão que levou a uma decisão; a decisão; o registro de testes que sustenta a promoção; as hipóteses descartadas; o estado atual dos ramos de código.
  + Mostre um exemplo em que um resumo "achata" um estatuto (#est[desconhecido] vira #est[provado], ou #est[conflitante] vira um dos lados) e descreva a decisão errada que isso causaria.
  + Calcule, para uma transferência de trabalho com 40 decisões, 15 desconhecidos e 3 mil palavras de discussão, o tamanho aproximado de (a) um resumo de 500 palavras e (b) uma coordenada com referências. O que cada forma preserva e o que perde?
]

== Coordenadas e o espaço de interpretações <sec-comp-coordenadas>

Por que coordenadas comprimem tanto? Porque eliminam _interpretações_. Um consumidor que recebe a narrativa de um trabalho precisa reconstruir o estado: quais revisões estão envolvidas, qual é a linha de base, que evidência existe, o que está em aberto. Cada frase da narrativa é compatível com muitos estados possíveis, e o consumidor precisa escolher entre eles — tipicamente, pelo mais plausível.

#definicao(titulo: [Espaço de interpretações])[
  Dado um material $m$ recebido por um consumidor, o _espaço de interpretações_ $cal(I)(m)$ é o conjunto de estados do mundo compatíveis com $m$. Sua _entropia residual_ é $H(Omega | M = m)$, a incerteza que resta sobre o estado depois de receber $m$, sob uma distribuição a priori sobre os estados.
] <def-espaco-interpretacoes>

Note-se que a entropia residual _pontual_ $H(Omega | M = m)$ pode ser maior que $H(Omega)$: uma narrativa específica pode aumentar a incerteza (por exemplo, ao mencionar uma hipótese que reabre alternativas). Só a média $H(Omega | M) = sum_m Pr(m) H(Omega | M = m)$ nunca excede $H(Omega)$. É mais um argumento a favor de coordenadas: elas não dependem de que a narrativa, em particular, seja informativa.

#proposicao(titulo: [Coordenada rica elimina a incerteza sobre a resposta do acervo])[
  Seja $A_"rel"$ a variável que descreve as respostas do acervo às necessidades de informação de uma decisão. Se a coordenada $kappa$ especifica as dimensões relevantes e o acervo responde a cada necessidade com estatuto em ${#est[provado], #est[refutado]}$, então $H(A_"rel" | kappa, Sigma) = 0$. A incerteza sobre o _mundo_ não desaparece: $H(Omega_"rel" | kappa, Sigma) = H(Omega_"rel" | A_"rel")$, que é zero apenas se as respostas do acervo forem corretas e atuais.
] <prop-coordenada-entropia>

#prova[
  Por hipótese, cada necessidade é respondida, de modo determinado, por asserções do acervo selecionadas pela coordenada; logo, dado $(kappa, Sigma)$, o valor de $A_"rel"$ é determinado, e a entropia condicional de uma variável determinada é zero. Para a segunda parte, $Omega_"rel"$ depende de $(kappa, Sigma)$ apenas por meio de $A_"rel"$, e o acervo não é o mundo (@inv-acervo-nao-mundo).
]

A proposição tem hipóteses fortes — e é justamente por isso que ela é instrutiva. Ela diz que a eficiência das coordenadas depende de três coisas: de a coordenada ser _rica_ (especificar as dimensões relevantes), de o acervo ser _bem gerenciado_ (conter asserções decisivas sobre essas dimensões) e de essas asserções serem _corretas e atuais_ — o que nenhuma coordenada garante. Quando qualquer das duas falha, a incerteza residual reaparece, e o consumidor volta a interpretar.

#exemplo(titulo: [Compressão por endereçamento em ação])[
  Ao final de uma longa sequência de trabalhos, um agente recebeu de outro apenas: "candidato $= r_2$; linha de base $= r_0$; evidência $= e_7$ (testes de integração em $r_2$, aprovados); alvo remoto $= g$; atual em $t$; aplicabilidade: sim". Com isso, ele não precisou reler centenas de mensagens. Cada valor eliminava uma família de interpretações: não era preciso adivinhar qual revisão estava em jogo, nem se os testes eram os unitários, nem se a linha de base era a ponta do ramo. O espaço de busca foi de "toda a história" para "a aresta exata não resolvida": a promoção de $r_2$ sobre $r_0$ em $g$.
] <ex-enderecamento-acao>

=== Coordenada não substitui trajetória

A @prop-coordenada-entropia fala de _estado_. Ela não diz nada sobre _por que_ o estado é o que é. O @cap-memoria mostrou que a trajetória de intenção é uma segunda forma de compressão, complementar: uma coordenada responde "onde estamos e o que está em jogo"; uma trajetória mínima responde "por que estamos aqui". Para decisões que dependem de intenção — escolher entre alternativas, avaliar se uma decisão anterior ainda vale —, a coordenada sozinha é insuficiente.

#principio(titulo: [Comprima estado por coordenada e intenção por trajetória])[
  Uma transferência eficiente combina uma coordenada rica (o estado relevante, por referência) com uma trajetória mínima (as poucas arestas de intenção que explicam o estado). Nenhuma das duas substitui a outra.
] <pri-coordenada-trajetoria>

#exercicios[
  + Estime, para uma transferência de trabalho que você conhece, a fração do texto que descrevia estado e a fração que descrevia intenção. Como cada fração poderia ser comprimida?
  + Dê um exemplo em que uma coordenada completa é insuficiente para decidir, porque falta a intenção.
  + #avancado Usando a teoria da informação do Apêndice C, explique por que, quando emissor e receptor compartilham um acervo, a informação necessária para designar um estado é o logaritmo do número de estados _compatíveis com a coordenada_, e não o tamanho da descrição do estado.
]

== Condições de validade do endereçamento <sec-comp-validade>

O endereçamento é sem perdas apenas sob condições. Elas devem ser verificadas, não presumidas.

#definicao(titulo: [Condições de validade])[
  Uma compressão por endereçamento é _válida_ para um consumidor se:
  + _Resolubilidade_: toda referência pode ser resolvida pelo consumidor, no momento em que ele precisar, para o conteúdo pretendido;
  + _Estabilidade_: as referências designam identidades imutáveis, ou a mutabilidade é declarada (o consumidor sabe que "a ponta do ramo" pode mudar);
  + _Legibilidade_: o consumidor tem autoridade para ler o que as referências designam, ou sabe que não tem;
  + _Interpretabilidade_: todo identificador usado é definido ou resolúvel (nenhum identificador órfão, @pri-identificador-orfao);
  + _Consciência de necessidade_: o consumidor sabe _quando_ precisa resolver uma referência — isto é, a perspectiva indica que informação está por trás de cada referência.
] <def-validade-enderecamento>

A última condição é a mais sutil, e ecoa o problema das faltas silenciosas do @cap-working-set. Uma referência opaca — um identificador hexadecimal sem descrição — é perfeitamente resolúvel, mas o consumidor não sabe se precisa resolvê-la. Na prática, ou ele resolve tudo (anulando a compressão), ou não resolve nada (e decide sem a informação). A solução é acompanhar cada referência de uma _etiqueta semântica_ curta: "evidência $e_7$ (testes de integração em $r_2$: aprovados)". A etiqueta custa poucos tokens e permite ao consumidor decidir se precisa do conteúdo completo.

#antipadrao(titulo: [Referências mudas])[
  Uma transferência contém dezenas de identificadores — de revisões, evidências, itens de trabalho — sem nenhuma indicação do que cada um é. O consumidor, para entender o estado, resolve todos, gastando mais do que se tivesse recebido o conteúdo; ou ignora todos, e decide às cegas.
] <anti-referencias-mudas>

#exercicios[
  + Reescreva o @ex-enderecamento-acao acrescentando etiquetas semânticas a cada referência, e estime o custo adicional em tokens.
  + Para cada condição da @def-validade-enderecamento, descreva uma falha concreta quando ela é violada.
  + Um consumidor externo não tem acesso ao acervo. A compressão por endereçamento ainda é útil? Como adaptar?
]

== Compressão governada sensível a coordenadas <sec-comp-governada>

Juntando as peças, chegamos a uma noção de compressão que não é nem resumo puro nem endereçamento puro, mas uma composição governada.

#definicao(titulo: [Compressão governada])[
  Uma _compressão governada_ de um estado para uma coordenada $kappa$ é uma perspectiva renderizada que preserva, para tudo o que inclui ou referencia: identidade, proveniência, estatuto epistêmico, atualidade, desconhecidos, relações, alças de expansão e fronteiras de autoridade. O que for omitido é declarado (P5).
] <def-compressao-governada>

A definição explica por que a passagem de sistemas que comprimiam _conteúdo_ para sistemas que comprimem _por coordenada_ é uma mudança de categoria, e não de grau. Comprimir conteúdo perde exatamente as dimensões que a definição exige preservar; comprimir por coordenada as mantém, porque não toca nas asserções — apenas escolhe quais trazer e como referenciar as demais.

#figure(
  tabela(
    colunas: (1fr, auto),
    cabecalho: ([Dimensão a preservar], [Preservada por resumo?]),
    [identidade (quais recursos exatamente)], [frequentemente não],
    [proveniência (de onde veio)], [quase nunca],
    [estatuto (provado, desconhecido, conflitante)], [frequentemente achatado],
    [atualidade (quando foi verdade)], [congelada],
    [desconhecidos (o que não se sabe)], [frequentemente omitidos],
    [relações tipadas], [convertidas em prosa],
    [alças de expansão], [ausentes],
    [fronteiras de autoridade], [ausentes],
  ),
  caption: [Lista de verificação da compressão governada. Cada linha é uma pergunta que se deve fazer a qualquer mecanismo de compressão de contexto.],
) <tab-checklist-compressao>

=== Compressão relativa à decisão #avancado

A lista da @tab-checklist-compressao diz _o que_ preservar. A teoria da decisão diz _quanto custa_ não preservar. Seja $Omega$ o estado do mundo relevante, $m$ o material a comprimir (uma variável aleatória correlacionada com $Omega$) e $s$ uma função de resumo.

#definicao(titulo: [Distorção de decisão])[
  Dado um conjunto finito de decisões $D$ e uma utilidade limitada $U(d, omega)$, a _distorção de decisão_ do resumo $s$ é a perda esperada de utilidade de decidir com $s(m)$ em vez de $m$:
  $ Delta_U (s) = E[max_(d in D) E[U(d, Omega) | m]] - E[max_(d in D) E[U(d, Omega) | s(m)]]. $
] <def-distorcao-decisao>

#proposicao(titulo: [Distorção nula e suficiência])[
  (i) $Delta_U (s) >= 0$ para toda utilidade $U$. (ii) Se $s(m)$ é suficiente para $Omega$ — isto é, $Pr(Omega | m) = Pr(Omega | s(m))$ —, então $Delta_U (s) = 0$ para toda $U$. (iii) Se $Omega$ é finito e $Delta_U (s) = 0$ para toda $U$, então $s(m)$ é suficiente para $Omega$.
] <prop-distorcao-suficiencia>

#prova[
  (i) Como $s(m)$ é função de $m$, $E[U(d, Omega) | s(m)] = E[E[U(d, Omega) | m] | s(m)]$. Para cada $d$, $E[U(d, Omega) | m] <= max_(d') E[U(d', Omega) | m]$; tomando a esperança condicional a $s(m)$ e o máximo em $d$, $max_d E[U(d, Omega) | s(m)] <= E[max_d E[U(d, Omega) | m] | s(m)]$; tomando a esperança, obtém-se (i). (ii) Com a suficiência, $E[U(d, Omega) | m] = E[U(d, Omega) | s(m)]$ para todo $d$, e os dois termos coincidem. (iii) Fixe $omega_0$ e $c in bb(R)$, e tome $D = {0, 1}$, $U(0, omega) = 0$ e $U(1, omega) = [omega = omega_0] - c$. Com $p(m) = Pr(Omega = omega_0 | m)$, os termos da definição são $E[max(0, p(m) - c)]$ e $E[max(0, E[p(m) | s(m)] - c)]$. A função $x |-> max(0, x - c)$ é convexa; pela desigualdade de Jensen condicional, o primeiro termo domina o segundo, com igualdade para todo $c$ somente se, para quase todo valor de $s(m)$, a distribuição condicional de $p(m)$ não tiver pontos de seu suporte dos dois lados de nenhum $c$ — isto é, se $p(m)$ for constante dado $s(m)$. Então $p(m) = E[p(m) | s(m)] = Pr(Omega = omega_0 | s(m))$, e, como $omega_0$ é arbitrário, $s(m)$ é suficiente.
]

A proposição é a versão decisória do @cor-ap-resumo: um resumo nunca melhora decisões; não as piora, para _nenhuma_ decisão, exatamente quando é suficiente; e quando é suficiente só para _algumas_ decisões, a distorção para as demais pode ser grande. É por isso que a regra prática "resuma o que é narrativa; enderece o que é estado" funciona: a narrativa — como se chegou até aqui — raramente muda a decisão seguinte, e sua distorção é pequena; o estado — o que está provado, o que é desconhecido, quem tem autoridade — entra em quase toda decisão, e resumi-lo tem distorção alta para alguma delas. O _gargalo de informação_ @tishby1999 relaxa a exigência de suficiência: procura o resumo mais curto que preserve uma fração dada da informação mútua com a variável relevante.

#exercicios[
  + Aplique a lista da @tab-checklist-compressao a um resumo automático de uma conversa longa com um assistente. Quais dimensões foram preservadas?
  + Proponha um formato de "resumo governado" que preserve as oito dimensões, e estime seu tamanho em relação a um resumo livre.
  + No exemplo do último exercício da @sec-front-valor, suponha que o material $m$ é o registro dos testes de integração e que o resumo diz "os testes passaram" sempre que passaram e, quando falharam, diz "os testes passaram" com probabilidade $1\/2$ (arredondando "quase todos passaram") e "os testes falharam" caso contrário. Calcule $Delta_U$ e compare com o valor da informação da alça. Por que um resumo que erra em apenas 15% dos casos destrói todo o valor da informação?
  + Escreva um teste automático que verifique se um resumo preserva os desconhecidos da perspectiva original. Que limitações um teste puramente textual tem?
]

== Densidade informacional e serialização <sec-comp-densidade>

Dentro de uma perspectiva renderizada, a forma importa tanto quanto o conteúdo. Três escolhas de serialização afetam fortemente a densidade informacional por token.

/ Estrutura versus prosa: tabelas e listas de pares chave–valor tendem a transmitir estado com menos tokens e menos ambiguidade do que prosa; prosa transmite melhor intenção e nuance. Use cada uma para sua função — e meça: o desempenho de modelos é sensível a variações de formato aparentemente irrelevantes @sclar2024.

/ Identificadores: identificadores longos e opacos (resumos criptográficos completos) custam muitos tokens e pouco significam para o consumidor. Prefixos curtos, únicos no contexto, com uma tabela de resolução, reduzem o custo sem perder a capacidade de verificação. Uma ressalva de segurança: prefixos curtos de resumos criptográficos perdem a resistência a colisões _adversariais_ — é barato fabricar objetos com o mesmo prefixo —, e por isso servem para endereçar dentro do contexto, nunca para verificar identidade.

/ Canonicidade: uma serialização _canônica_ — mesma ordem de campos, mesmo formato para o mesmo conteúdo — torna o contexto determinístico, o que favorece o cache de prefixos (@prop-prefixo), facilita comparações entre perspectivas e permite identificar uma perspectiva por um resumo de sua forma canônica.

#principio(titulo: [Renderização canônica])[
  Para a mesma perspectiva, a renderização produz o mesmo texto. Variações (de ordem, formatação ou redação) que não carregam informação devem ser eliminadas, porque custam cache, dificultam auditoria e introduzem diferenças espúrias de comportamento do consumidor.
] <pri-renderizacao-canonica>

#exercicios[
  + Compare o número de tokens de três representações do mesmo estado de cinco recursos: prosa, tabela e pares chave–valor. Qual é mais fácil de verificar?
  + Proponha um esquema de prefixos curtos para identificadores que garanta unicidade no contexto e resolução sem ambiguidade.
  + Por que a renderização canônica (sempre a mesma ordem e formato para o mesmo conteúdo) favorece o cache de prefixos? Relacione com o @pri-estavel-volatil.
]

== Compressão aprendida <sec-comp-aprendida>

Uma linha de pesquisa ativa treina modelos ou procedimentos para comprimir contexto automaticamente: removendo tokens de baixa informação do prompt @jiang2023llmlingua, aprendendo "tokens-resumo" que condensam instruções @mu2023, encadeando segmentos comprimidos para lidar com documentos longos @chevalier2023, ou comprimindo documentos recuperados de forma seletiva antes de usá-los @xu2024recomp. Essas técnicas obtêm reduções significativas de custo com perdas modestas de desempenho em tarefas de referência.

Do ponto de vista deste capítulo, todas são compressões _por resumo_ — sofisticadas, mas com perdas — e herdam suas limitações: não há garantia de que estatutos, proveniência ou desconhecidos sejam preservados, e o que foi removido não é recuperável pelo consumidor. Elas são apropriadas para material de baixo risco e alta redundância (documentos de apoio, histórico de conversa), e inadequadas para material que sustenta decisões governadas. Compressões _latentes_ — que substituem texto por vetores contínuos @mu2023 @chevalier2023 — são ainda mais restritivas: o resultado não pode ser lido, auditado, identificado por resumo criptográfico nem renderizado honestamente, e só é admissível para material que não precisa de proveniência.

#principio(titulo: [Compressão aprendida fora do caminho crítico])[
  Use compressão aprendida para reduzir o custo de material de orientação e de apoio. Mantenha fora dela — por endereçamento e renderização canônica — as asserções que portões, autorizações e decisões precisarão verificar.
] <pri-compressao-aprendida>

#exercicios[
  + Proponha um experimento para medir se uma técnica de compressão aprendida preserva estatutos epistêmicos: que entradas usar, que perguntas fazer ao consumidor, como pontuar.
  + Discuta se a compressão aprendida poderia ser tornada "governada" acrescentando restrições (por exemplo, nunca remover tokens que pertençam a identificadores ou marcadores de estatuto).
  + Classifique quanto ao risco para estatutos epistêmicos: remoção de tokens de baixa informação; resumo abstrativo por um modelo; compressão em vetores latentes; seleção extrativa de sentenças. Justifique.
]

#quadro[
  - Resumo comprime com perdas e achata estatutos; endereçamento comprime sem perdas, se as referências resolvem.
  - Coordenadas comprimem eliminando interpretações; com coordenada rica e acervo bem gerenciado, a incerteza relevante desaparece (@prop-coordenada-entropia).
  - Coordenada comprime estado; trajetória comprime intenção — as duas juntas.
  - Endereçar exige resolubilidade, estabilidade, legibilidade, interpretabilidade e consciência de necessidade; etiquete referências.
  - Compressão governada preserva identidade, proveniência, estatuto, atualidade, desconhecidos, relações, alças e fronteiras de autoridade.
  - Serialize de forma canônica e densa; use compressão aprendida fora do caminho crítico.
]

#problemas[
  #problema([Custo esperado do endereçamento com etiquetas])[
    Um contexto referencia $k$ itens com etiquetas de $t$ tokens; cada item tem $ell$ tokens e é necessário com probabilidade $p$; o consumidor resolve corretamente uma referência necessária com probabilidade $q$ se ela tiver etiqueta e $q_0 < q$ se não tiver.
    + Escreva o custo esperado (tokens) e a probabilidade de decisão correta para as estratégias: incluir tudo; referenciar sem etiqueta; referenciar com etiqueta.
    + Encontre as condições em que referenciar com etiqueta domina as outras duas.
  ]
  #problema([Entropia residual de uma narrativa])[
    Uma narrativa de transferência menciona "o candidato" sem dizer qual, e há três candidatos possíveis, igualmente prováveis a priori.
    + Calcule a entropia residual sobre o candidato.
    + Mostre como a menção "o candidato que passou nos testes de integração" reduz a entropia, e sob que condições a reduz a zero.
    + Generalize: proponha uma medida de "precisão" de uma transferência como redução de entropia sobre as dimensões relevantes, e discuta como estimá-la na prática.
  ]
  #problema([Resumos governados])[
    Projete um procedimento de resumo de sessões longas que produza um resumo governado.
    + Especifique o formato de saída, com seções para estado (por referência), decisões, desconhecidos, trajetória mínima e alças.
    + Mostre como verificar automaticamente que nenhum estatuto foi promovido em relação ao acervo.
    + Discuta o custo de produzir e de manter esses resumos.
  ]
]

#notas[
  A distinção entre compressão com e sem perdas, e o custo de referências num dicionário compartilhado, são temas clássicos da teoria da informação @cover2006 @shannon1948. A observação de que coordenadas governadas substituem narrativa — compressão por endereçamento, não por resumo —, e de que a trajetória de intenção continua necessária para explicar o porquê das decisões, é uma proposta deste livro. As técnicas de compressão aprendida citadas são @jiang2023llmlingua, @mu2023, @chevalier2023 e @xu2024recomp; a geração aumentada por recuperação @lewis2020 pode ser vista como uma forma de endereçamento em que as referências são resolvidas por similaridade, e não por identidade — com as vantagens de flexibilidade e as desvantagens de resolução incerta que isso implica.
]
