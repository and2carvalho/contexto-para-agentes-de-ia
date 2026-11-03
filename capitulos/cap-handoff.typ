#import "/modelo/estilo.typ": *

= Transferência, relato e relocação <cap-handoff>

#epigrafe[A transferência atravessa referências e dados limitados, não a transcrição.]

Toda orquestração, toda retomada e toda colaboração entre humanos e agentes depende de transferências: um consumidor passa a outro — ou ao seu próprio eu futuro — o que é preciso para continuar. As transferências são o ponto mais frágil de sistemas de agentes. Contexto se perde, estatutos são achatados, autoridade é transmitida sem querer, relatos de sucesso viram fatos. Este capítulo trata das transferências como objetos de engenharia: com formato, contrato e verificação.

A @sec-hand-relocacao define a transferência como relocação de coordenada. A @sec-hand-pacote descreve o pacote de investigação, que leva o trabalho. A @sec-hand-retorno descreve o pacote de retorno, que traz o resultado. A @sec-hand-verificacao trata da verificação do retorno. A @sec-hand-continuidade trata da continuidade sem continuidade do observador. A @sec-hand-fundamentacao relaciona o tema à fundamentação comum na comunicação humana.

== A transferência como relocação <sec-hand-relocacao>

#definicao(titulo: [Transferência])[
  Uma _transferência_ (handoff) é a relocação de trabalho de um consumidor de origem para um consumidor de destino, que transporta a _coordenada mínima de recomposição_ — domínio, objetivo, fronteira, sujeitos, teto de autoridade e política de divulgação, referências, sentinelas e contrato de retorno — e não a conversa que a produziu.
] <def-transferencia>

A coordenada da origem, $kappa = (u, ell, o, tau, t, alpha)$, contém o próprio consumidor $u$ e seu teto $alpha$. O destino é outro consumidor, com outro teto — e o @inv-heranca-autoridade proíbe que ele use os da origem. O que se transfere, portanto, não é $kappa$ inteira, mas sua _intenção_ $iota(kappa) = (ell, o, tau, t)$: locus, objetivo, transição e instante de referência. Dizemos que uma projeção é _uniforme no consumidor_ se depende de $u$ apenas por meio do teto e do perfil.

#teorema(titulo: [Transferência por intenção])[
  Sejam origem e destino com acesso de leitura a acervos dos quais se reconstrói o mesmo $Sigma_t$ (acervo por acréscimo, com instante de registro), a mesma versão de uma projeção $pi$ uniforme no consumidor, e tetos $alpha$ e $alpha'$. Se a origem transfere $iota(kappa)$, o destino obtém $pi(Sigma_t, (u', iota(kappa), alpha'))$, que coincide com a perspectiva da origem quando $alpha' = alpha$ e os perfis são iguais; e, em geral, sob as hipóteses da @prop-monotonia-autoridade, ambas contêm o conteúdo da perspectiva calculada sob $alpha inter alpha'$. Transferir apenas a perspectiva _renderizada_, por outro lado, não basta para que o destino expanda como a origem expandiria.
] <teo-transferencia-minima>

#prova[
  Como $Sigma_t$ é reconstruído pelo instante de registro, ambos projetam sobre o mesmo acervo. Pela uniformidade e pelo determinismo (P2), com tetos e perfis iguais as perspectivas coincidem. Com tetos diferentes, $alpha inter alpha' subset.eq alpha$ e $alpha inter alpha' subset.eq alpha'$, e a @prop-monotonia-autoridade dá as inclusões. Para a última parte, basta um contraexemplo: se a renderização omitiu, por orçamento, as alças de uma categoria (declarando apenas sua contagem), o destino que recebe só o texto sabe que elas existem, mas não pode resolvê-las sem a intenção e o acervo; a origem pode.
]

A transferência por intenção é, além disso, _mínima_ num sentido preciso: se a classe de transferências possíveis induz $N$ perspectivas distintas para o destino, nenhuma codificação com menos de $log_2 N$ bits no pior caso permite ao destino distingui-las — um argumento de contagem. Endereçar uma intenção custa o logaritmo do número de intenções, não o tamanho da perspectiva.

O teorema separa dois tipos de transferência. Entre consumidores que compartilham acervo, a transferência ideal é _por coordenada_: pequena, exata e verificável. Para consumidores externos, sem acesso ao acervo, é preciso transferir conteúdo — e então todas as regras de compressão governada (@def-compressao-governada) se aplicam.

#invariante(titulo: [Transportar intenção, recomputar realidade])[
  Numa relocação, transportam-se a intenção (objetivo, foco, escopo, referências, restrições) e a proveniência; recomputam-se no destino as observações, a materialização, a execução, o transporte, a autoridade, a acionabilidade, a atualidade, a aplicabilidade e a seleção. Nunca se copiam: histórico de conversa, contexto anterior do modelo, instantâneos do ambiente, conclusões de autoridade, observações de locus ou provas de autenticação.
] <inv-transportar-recomputar>

#exercicios[
  + Liste o que deveria e o que não deveria constar de uma transferência entre um agente que investigou uma falha e outro que vai corrigi-la.
  + Por que conclusões de autoridade da origem não devem ser copiadas para o destino? Dê um cenário em que isso causa um efeito não autorizado.
  + Construa um exemplo em que transferir apenas a perspectiva renderizada leva o destino a uma conclusão errada que a transferência da coordenada teria evitado (@teo-transferencia-minima).
]

== O pacote de investigação <sec-hand-pacote>

O pacote que leva trabalho de um consumidor a outro é um contrato. Sua estrutura evita que o destino reinterprete o pedido.

#definicao(titulo: [Pacote de investigação])[
  Um _pacote de investigação_ contém:
  - _propósito_: o objetivo, enumerado em itens verificáveis;
  - _autoridade_: o teto do destino para esta tarefa e o que exige autorização adicional;
  - _coordenada corrente_: domínio, unidade de trabalho, instante, linha de base;
  - _fundação_: o que já está fechado e não deve ser reaberto;
  - _invariantes_: as distinções que o destino não pode supor (por exemplo, "caminho não é identidade", "leitor não é escritor");
  - _fatos conhecidos_, com âncoras, e _desconhecidos_;
  - _mutações permitidas_ e _proibidas_ (uma lista explícita do que _não_ fazer);
  - _fases_, _critérios de aceitação_ e _condições de parada_;
  - _contrato de retorno_: as seções nomeadas e o vocabulário fechado de vereditos;
  - a _próxima aresta exata_ esperada.
] <def-pacote-investigacao>

Dois elementos merecem destaque, porque são os que mais frequentemente faltam. O primeiro é a _lista de mutações proibidas_: um destino capaz tende a "aproveitar" para corrigir o que encontra pelo caminho; sem proibições explícitas, a investigação vira uma reforma não autorizada. O segundo é a _regra de superfície_: "se uma superfície de leitura não responder, classifique como lacuna antes de recorrer a arquivos ou comandos de sistema" (@pri-superficie-lacuna).

#exemplo(titulo: [Invariantes inegociáveis num pacote])[
  Um pacote para auditar o estado de um ambiente de desenvolvimento listava, como invariantes que o destino não poderia violar: caminho não é domínio; caminho não é repositório; repositório não é domínio; materialização não é domínio; composição não é coleção de repositórios; leitor não é escritor; projeção derivada não é autoridade; memória não é prova; revisão de controle de versão não é, por si só, autoridade. E acrescentava: "não infira identidade de domínio ou de composição a partir de contenção em diretórios". O destino, um agente frio, produziu um relatório que respeitava todas essas distinções — e que, por isso, foi útil.
] <ex-invariantes-pacote>

#exercicios[
  + Escreva um pacote de investigação completo para "determinar por que os testes de integração falham intermitentemente", seguindo a @def-pacote-investigacao.
  + Por que o pacote deve pedir _exatamente uma_ próxima aresta, e não uma lista de sugestões?
  + Avalie um pedido de tarefa típico que você já enviou a um agente segundo a @def-pacote-investigacao. Quais campos estavam implícitos? Qual ausência teve consequências?
]

== O pacote de retorno <sec-hand-retorno>

#definicao(titulo: [Pacote de retorno])[
  Um _pacote de retorno_ contém, em seções separadas:
  - a _coordenada de execução_ (onde, quando, com que identidade, que executáveis);
  - _itens chave–valor_ enumerados, cada um com estatuto epistêmico e _base_ (como foi observado: fonte, método, confiança, classe de autoridade);
  - as _mutações realizadas_ — e a declaração de que nenhuma outra foi feita, com prova de não mutação quando aplicável;
  - o que _não foi realizado_ e o que foi _adiado_;
  - desvios em relação ao pedido;
  - desconhecidos e bloqueios;
  - a _próxima aresta exata_;
  - um _veredito_ de um vocabulário fechado (por exemplo: #estado[aprovado], #estado[aprovado com emendas], #estado[requer correção], #estado[ainda não executável], #estado[bloqueado] em aresta nomeada).
] <def-pacote-retorno>

#invariante(titulo: [Narrativa, observação, validação, efeito e evidência são separados])[
  O pacote de retorno não mistura o que o executor _pensa_ (narrativa), o que _observou_, o que _validou_, o que _alterou_ e o que _prova_. Um revisor deve poder conferir cada seção sem ler as outras.
] <inv-secoes-retorno>

#invariante(titulo: [Hipótese contradita preserva o desconhecido])[
  Quando a evidência contradiz a hipótese de partida, o retorno registra "hipótese contradita; causa desconhecida", em vez de oferecer uma explicação alternativa não provada. A pressão para fechar a narrativa é a origem da confabulação.
] <inv-hipotese-contradita>

#estudo-de-caso(titulo: [A explicação que não foi dada])[
  Uma investigação somente leitura partiu da hipótese de que uma falha se devia a uma incompatibilidade de versão entre dois componentes. A evidência a contradisse: as versões eram compatíveis. O executor tinha à mão uma explicação alternativa plausível — uma diferença de configuração —, mas não a havia verificado. O retorno registrou: "hipótese H: contradita; causa: desconhecida; próxima aresta: observar a configuração efetiva de ambos". A explicação alternativa, verificada depois, revelou-se errada; tê-la registrado como causa teria levado a uma correção inútil.
] <caso-explicacao-nao-dada>

#exercicios[
  + Converta um relatório em prosa de um agente num pacote de retorno conforme a @def-pacote-retorno. Que informações faltavam?
  + Por que o vocabulário de vereditos deve ser fechado? Que problema surge com vereditos livres ("parece ok, com ressalvas")?
  + Escreva o vocabulário fechado de vereditos para um pacote de retorno de revisão de segurança e defina o critério de cada veredito.
]

== Verificação do retorno <sec-hand-verificacao>

#invariante(titulo: [Pacote não é verdade])[
  Um pacote de retorno é uma observação datada, feita por um executor que otimiza localmente. Ele pode estar errado — inclusive sobre o que o próprio executor fez. O destinatário não o aceita como verdade: reobserva as afirmações críticas e separa o que foi _feito_ do que foi _provado_. Um relato de sucesso não é sucesso provado.
] <inv-pacote-verdade>

#algoritmo("Verifica-Retorno", params: $q, r$, legenda: [Verificação de um pacote de retorno $r$ contra o pacote de investigação $q$.])[
  + confira a coordenada de execução de $r$ contra a esperada por $q$
  + #kw[para cada] critério de aceitação de $q$ #kw[faça]
    + localize em $r$ o item correspondente; #kw[se] ausente #kw[então] marque #estado[não medido]
    + #kw[se] o item é crítico #kw[então] reobserve-o agora e compare
  + verifique que as mutações realizadas $subset.eq$ mutações permitidas, e que nenhuma proibida ocorreu
  + verifique a coerência interna (contagens versus listas, @caso-oito-seis)
  + calcule o veredito admissível pelos estatutos dos itens críticos: algum #est[refutado] ⇒ no máximo #estado[requer correção]; algum #est[conflitante] ⇒ no máximo #estado[bloqueado]; algum #est[desconhecido] ⇒ no máximo #estado[ainda não executável]; todos #est[provado] ⇒ #estado[aprovado] admissível (@lem-agregado-minimo)
  + #kw[se] o veredito de $r$ excede o admissível #kw[então] registre #estado[relato divergente]
] <alg-verifica-retorno>

/ Correção e custo: fixada uma ordem total entre os vereditos em que #estado[aprovado] é o máximo, o veredito admissível da linha 7 é o mínimo dos tetos impostos pelos itens críticos. Logo é monótono: tornar #est[provado] um item que não era nunca piora o veredito, e acrescentar um item crítico não provado nunca o melhora. E todo item crítico é reobservado (linha 4), de modo que o veredito não depende só do relato. Com $k$ critérios, dos quais $k_c$ críticos, e as mutações em tabelas de dispersão, o custo é $O(k + |"mut"|) + k_c T_"obs"$: a verificação custa tanto quanto reobservar o que importa, e nada além disso.

O desfecho "o relato anterior estava errado" é um resultado legítimo e importante da verificação: ele é registrado como correção ligada (@inv-erro-historia), não escondido.

#exercicios[
  + Aplique o @alg-verifica-retorno ao pacote do exercício anterior. Quais itens você reobservaria?
  + Por que verificar a coerência interna do pacote é útil mesmo quando todas as afirmações individuais parecem plausíveis?
  + No @alg-verifica-retorno, por que o veredito admissível é limitado pelo pior item crítico? Dê um exemplo em que o executor declara #estado[aprovado] e o veredito admissível é #estado[requer correção].
]

== Continuidade sem continuidade do observador <sec-hand-continuidade>

#definicao(titulo: [Continuidade de contexto])[
  Há _continuidade de contexto_ quando outro observador — outro processo, outro modelo, outro humano — consegue ocupar a mesma perspectiva, ou uma derivada dela, depois que o observador original desapareceu.
] <def-continuidade-contexto>

#invariante(titulo: [Continuidade de contexto não exige continuidade do observador])[
  Sessões morrem, processos são reiniciados, modelos são trocados. Um sistema de contexto bem projetado recompõe a perspectiva a partir do domínio, do objetivo e dos mecanismos de resolução; não depende de que o mesmo observador continue vivo. O tempo de vida do processo não é o tempo de vida do contexto.
] <inv-continuidade-observador>

Um corolário metodológico: testar a continuidade exige consumidores _frios_ de verdade. Um sucessor que, por acaso, compartilha memória com o original — mesmo provedor com histórico, mesma sessão — não testa nada. Frio, porém, não é vazio: um sucessor frio tem o conhecimento geral de seu treinamento e o arcabouço comum do sistema; o que ele não tem é a memória específica do trabalho.

#exercicios[
  + Proponha um teste de continuidade com consumidor frio para uma transferência entre sessões.
  + Que tipo de "contaminação" pode fazer um consumidor parecer frio sem ser?
  + Descreva um experimento que distinga continuidade de contexto de continuidade do observador, usando dois consumidores frios de fornecedores diferentes.
]

== Fundamentação comum <sec-hand-fundamentacao>

As transferências entre agentes reencontram um problema estudado na comunicação humana: como dois participantes estabelecem que compartilham o entendimento necessário para prosseguir. #ct(<clark1991>) chamaram esse processo de _fundamentação_ (grounding): os participantes buscam evidência positiva de entendimento — confirmações, reformulações, ações coerentes — antes de considerar algo como parte do terreno comum. As máximas conversacionais de #ct(<grice1975>) — quantidade (nem mais nem menos do que o necessário), qualidade (não afirmar o que se crê falso ou sem evidência), relação (ser relevante) e modo (ser claro) — descrevem, em linguagem humana, boa parte das regras deste capítulo: o pacote deve ser suficiente e mínimo; o retorno não deve afirmar sem base; ambos devem ser relevantes ao objetivo e inequívocos. O critério de Clark e Brennan — compreensão _suficiente para os propósitos correntes_ — é, na linguagem deste livro, a suficiência de uma perspectiva para a coordenada (@def-suficiencia).

O resultado do ataque coordenado (@teo-ap-ataque-coordenado) dá o limite formal: por um canal falível, conhecimento comum não se estabelece com um número finito de mensagens. A resposta de engenharia é projetar transferências em que a ausência de confirmação seja um estado explícito (#est[desconhecido]), e em que nenhum efeito dependa de supor que o outro lado entendeu.

#exercicios[
  + Mapeie as quatro máximas de Grice para campos da @def-pacote-investigacao e da @def-pacote-retorno.
  + Por que um pacote de transferência longo demais viola a máxima de quantidade, e com que consequência para o consumidor?
  + Explique, com o resultado do ataque coordenado, por que uma transferência não pode supor que o destino entendeu o pacote. Que mecanismo de confirmação limitado é aceitável na prática?
]

#quadro[
  - Transferência é relocação de coordenada, não de conversa; com acervo compartilhado, a coordenada basta (@teo-transferencia-minima).
  - Transporte intenção, recompute realidade; nunca copie autoridade, histórico de conversa ou credenciais.
  - O pacote de investigação é um contrato: propósito, autoridade, coordenada, fundação, invariantes, fatos, desconhecidos, mutações permitidas e proibidas, fases, aceitação, parada, retorno, próxima aresta.
  - O pacote de retorno separa narrativa, observação, validação, efeito e evidência; hipótese contradita preserva o desconhecido.
  - Pacote não é verdade: reobserve o crítico; o veredito não excede o ínfimo dos itens.
  - Continuidade de contexto não exige continuidade do observador; teste com consumidores frios de verdade.
  - Fundamentação comum e máximas de Grice; ausência de confirmação é estado explícito.
]

#problemas[
  #problema([Teto de autoridade em cadeias de transferência])[
    Um trabalho passa por uma cadeia de transferências $A_1 -> A_2 -> dots -> A_n$.
    + Mostre que, se o teto de cada destino é a interseção do teto declarado no pacote com a política do hospedeiro para o destino, então o teto de $A_n$ nunca excede o de $A_1$.
    + Construa um contraexemplo quando o destino herda o teto do emissor sem interseção.
    + Relacione com a delegação restrita do @cap-federacao.
  ]
  #problema([Formato verificável de retorno])[
    Projete um esquema estruturado para o pacote de retorno.
    + Especifique tipos e restrições de cada seção.
    + Escreva verificações automáticas que detectem: afirmação sem base; mutação fora da lista permitida; veredito acima do ínfimo; contagem incoerente com lista.
    + Discuta o custo em tokens do formato e como mantê-lo legível para humanos.
  ]
  #problema([Transferência a consumidor externo])[
    Um agente precisa transferir trabalho a um parceiro externo sem acesso ao acervo.
    + Que partes da coordenada podem ser transmitidas como referências, e quais precisam virar conteúdo?
    + Aplique a lista da compressão governada (@tab-checklist-compressao).
    + Proponha como o parceiro devolveria um retorno verificável.
  ]
]

#notas[
  A fundamentação comum é de #ct(<clark1991>), as máximas conversacionais, de #ct(<grice1975>), e o problema do ataque coordenado, em sua formulação epistêmica, está em #ct(<fagin1995>). A autoavaliação e a reflexão de agentes de linguagem @shinn2023 @madaan2023 mostram que modelos podem melhorar seus resultados com retroalimentação; mas a autocorreção sem verificação externa não é confiável @huang2024selfcorrect @kamoi2024, o que justifica a verificação de retornos por quem os recebe. Arquiteturas cognitivas para agentes de linguagem @sumers2024 e levantamentos de agentes autônomos @wang2024survey discutem memória, comunicação e coordenação entre agentes.

  O pacote de investigação com invariantes inegociáveis e lista de mutações proibidas, o pacote de retorno com seções separadas e vocabulário fechado de vereditos, a regra "pacote não é verdade" e a preservação do desconhecido diante de hipóteses contraditas são propostas deste livro para tornar verificáveis as transferências entre agentes.
]
