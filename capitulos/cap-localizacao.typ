#import "/modelo/estilo.typ": *

= Localização e resolução: "onde estou?" <cap-localizacao>

#epigrafe[O problema não era o caminho. Era o processo achar que o lugar onde nasceu era o mundo inteiro.]

Antes de qualquer outra pergunta, um agente precisa saber onde está: em que domínio, em que máquina, sob que unidade de trabalho, com que autoridade, a partir de que ponto no tempo. Parece uma pergunta trivial — o agente "está" onde foi iniciado —, e é exatamente essa resposta trivial que produz uma família inteira de erros. Um processo nasce num diretório arbitrário; um serviço de contexto é iniciado num lugar e atende pedidos sobre outros; um agente é retomado noutra máquina. Em todos esses casos, o lugar físico do processo não é a coordenada semântica do trabalho.

Este capítulo trata a localização como um problema computável, com entradas, saídas e provas. A @sec-loc-processo distingue processo, nó, sessão e perspectiva. A @sec-loc-vetor formaliza a coordenada como vetor de escopos, possivelmente parcial. A @sec-loc-autolocalizacao apresenta a autolocalização com proveniência por campo. A @sec-loc-vinculo trata do vínculo de um consumidor a uma coordenada. A @sec-loc-duas-fases descreve a resolução em duas fases, da referência à perspectiva aplicável. A @sec-loc-negacao prova o lema do escopo da negação. A @sec-loc-orientacao reúne tudo num procedimento de orientação de sessão.

== Processo, nó, sessão e perspectiva <sec-loc-processo>

#estudo-de-caso(titulo: [O serviço que não enxergava o domínio vizinho])[
  Um serviço que fornecia contexto a agentes por um protocolo de ferramentas tinha sido iniciado num domínio público, criado apenas para hospedá-lo. Quando um agente pedia informações sobre outro domínio, materializado na mesma máquina, o serviço respondia que não o conhecia — e o agente precisava passar o caminho do diretório como parâmetro, contornando o modelo. O diagnóstico inicial foi um problema de caminhos. O diagnóstico correto foi outro: faltava um circuito anterior à perspectiva. O serviço tratava o domínio onde nascera como o universo, quando deveria perguntar ao nó quais domínios existiam e eram alcançáveis, e só então abrir a perspectiva do domínio pedido.
] <caso-servico-vizinho>

#definicao(titulo: [Quatro noções de lugar])[
  - O _processo_ tem um diretório de trabalho: um localizador, sem significado semântico.
  - O _nó_ tem um locus de resolução: o universo do que pode ser resolvido e materializado ali (@def-no).
  - A _sessão_ de um consumidor tem uma _coordenada de contexto_: a posição semântica que ela ocupa, independentemente de onde o processo nasceu.
  - A _perspectiva_ projeta a partir da coordenada da sessão.
] <def-quatro-lugares>

#invariante(titulo: [Diretório do processo não é coordenada da sessão])[
  O diretório em que um processo foi iniciado não determina a coordenada de contexto da sessão que ele serve. O mesmo consumidor, lançado de dois diretórios diferentes, deve chegar à mesma coordenada se a sessão for a mesma; e um serviço iniciado num domínio pode servir sessões em outros.
] <inv-diretorio-sessao>

#exercicios[
  + Descreva o teste que verifica o @inv-diretorio-sessao para uma ferramenta de linha de comando que lê o domínio corrente.
  + No @caso-servico-vizinho, que informação o agente estava fornecendo ao passar o caminho, e por que essa informação deveria vir do nó e não do agente?
  + Para um agente de programação típico, identifique as quatro noções de lugar da @def-quatro-lugares e descreva uma situação em que cada par delas diverge.
]

== A coordenada como vetor de escopos <sec-loc-vetor>

O @cap-modelo introduziu a coordenada como uma tupla de seis componentes. Na prática, a coordenada de uma sessão tem mais dimensões, e cada uma pode ser independente das outras.

#definicao(titulo: [Espaço de coordenadas])[
  O _espaço de coordenadas_ é um produto $K = K_"exec" times K_"id" times K_"dom" times K_"trab" times K_"temp" times K_"entrega" times K_"aut" times K_"perfil"$, em que cada fator — execução (nó e processo), identidade do ator, domínio, trabalho (unidade e objetivo), tempo (instante ou ponto de controle), entrega (superfície), autoridade (delegação e teto) e perfil (papel, modo) — é um poset com um elemento mínimo $bot$ ("não especificado") e a ordem de refinamento "mais específico que". A ordem de $K$ é componente a componente.
] <def-espaco-coordenadas>

O espaço de coordenadas do @cap-modelo é uma projeção deste: o consumidor $u$ corresponde a $K_"id"$; o locus $ell$, a $K_"dom"$ (com $K_"exec"$ como seu suporte material); o objetivo e a transição $(o, tau)$, a $K_"trab"$; o instante $t$, a $K_"temp"$; e o teto $alpha$, a $K_"aut"$. Os fatores $K_"entrega"$ e $K_"perfil"$ não são parâmetros da projeção $pi$, mas da renderização $rho$ (o perfil $u$ de $rho(P, B, u)$): dois consumidores que diferem só na superfície ou no perfil recebem a mesma perspectiva, renderizada de modos diferentes.

#proposicao(titulo: [Coordenadas parciais formam um poset com ínfimos])[
  Se cada fator $K_i$ é um semirreticulado de encontro com mínimo $bot$, então $K$ também o é, com $kappa and kappa' $ calculado componente a componente. Em particular, quaisquer duas coordenadas têm uma coordenada comum menos específica, e a coordenada vazia $(bot, dots, bot)$ é o mínimo.
] <prop-coordenadas-parciais>

#prova[
  O encontro componente a componente é um minorante de $kappa$ e $kappa'$ no produto; qualquer outro minorante é, em cada componente, menor ou igual ao encontro naquele componente; logo o encontro componente a componente é o maior minorante.
]

Duas consequências práticas seguem da estrutura de produto.

#invariante(titulo: [Coordenada parcial não é contexto inválido])[
  Uma sessão com algumas dimensões não especificadas (sem unidade de trabalho selecionada, sem objetivo declarado) tem uma coordenada válida e uma perspectiva calculável. A projeção deve estar definida quando componentes são $bot$, e a perspectiva deve declarar o que não foi especificado.
] <inv-coordenada-parcial>

#invariante(titulo: [Mudar uma dimensão não destrói as outras])[
  Alterar um componente da coordenada — mudar de unidade de trabalho, de perfil ou de instante — não invalida os demais componentes. Uma implementação que "reinicia" a coordenada inteira a cada mudança perde contexto legítimo.
] <inv-dimensao-independente>

#exercicios[
  + Escreva as coordenadas de: (a) um agente recém-iniciado, sem objetivo; (b) o mesmo agente após o titular declarar o objetivo; (c) o mesmo agente após selecionar uma unidade de trabalho. Mostre que formam uma cadeia no refinamento.
  + Dê um exemplo em que duas coordenadas não são comparáveis e calcule seu encontro.
  + #avancado Mostre que o espaço de coordenadas com componentes $bot$ não é, em geral, um reticulado (falta supremo), e caracterize quando duas coordenadas têm supremo.
]

== Autolocalização com proveniência por campo <sec-loc-autolocalizacao>

Um agente que precisa saber onde está deveria _medir_ cada componente de sua coordenada, registrando como mediu — e não presumir.

#definicao(titulo: [Autolocalização])[
  A _autolocalização_ de uma sessão devolve, para cada observação que determina um componente da coordenada — por exemplo, o domínio, o local de materialização, o nó, a unidade de trabalho ativa —, uma tupla (valor, medido-de, confiança, classe de autoridade): o valor observado, a fonte da medição, o grau de confiança e o tipo de autoridade que a fonte tem sobre o valor. A coordenada é obtida da tabela descartando as proveniências e marcando $bot$ onde a confiança é insuficiente.
] <def-autolocalizacao>

#algoritmo("Autolocaliza", params: $s$, legenda: [Autolocalização de uma sessão $s$, com proveniência por componente.])[
  + #kw[para cada] componente $k$ da coordenada #kw[faça]
    + $(v, f, c, a) <- $ #proc("Mede")$(k, s)$ #h(1fr) ▷ valor, fonte, confiança, classe de autoridade
    + #kw[se] o nome esperado para $k$ diverge da identidade medida #kw[então]
      + registre a divergência; #kw[não] repare #h(1fr) ▷ relatar, não corrigir
  + #kw[se] uma escrita é pretendida #kw[então]
    + prove a autoridade de escrita pela semântica de governança (não por permissões do sistema operacional)
    + #kw[se] não provada #kw[então] permaneça somente leitura e devolva o bloqueio
  + #kw[devolva] a tabela de componentes
] <alg-autolocaliza>

A regra "relatar, não reparar" merece ênfase. Quando um agente percebe que o domínio em que está tem um identificador diferente do que esperava — porque o nome humano não corresponde ao registro —, a tentação é "consertar": renomear, rebindar, reinicializar. Mas a divergência é um _fato_ a ser explicado, e a correção, se houver, é uma ação governada de quem tem autoridade sobre a identidade. A mesma regra vale para a escrita: permissão de sistema de arquivos não é autoridade (@inv-leitura-escrita), e um agente que não consegue provar autoridade de escrita pela governança do domínio permanece somente leitura.

#exercicios[
  + Construa a tabela de autolocalização de uma sessão de agente que você conhece. Quantos componentes foram medidos e quantos presumidos?
  + Por que a autolocalização deve registrar a _classe de autoridade_ da fonte de cada medição? Dê um exemplo em que duas fontes informam valores diferentes para o mesmo componente.
  + Aplique o @alg-autolocaliza a um processo iniciado por um gancho de ciclo de vida de um cliente de agentes. Quais componentes são medidos, quais são declarados e quais ficam desconhecidos?
]

== O vínculo do consumidor <sec-loc-vinculo>

Como uma sessão chega à sua coordenada? Há vários caminhos, e o caminho importa para a confiança no resultado.

#definicao(titulo: [Vínculo de contexto do consumidor])[
  O _vínculo_ de um consumidor é o estado derivado que responde "para este consumidor, qual coordenada estamos resolvendo?". Ele registra duas coisas: _de onde veio_ a coordenada — por exemplo, um parâmetro explícito, um marcador encontrado no sistema de arquivos, uma composição de que o domínio faz parte, um pacote de transferência — e _como_ o localizador foi resolvido — diretamente, por consulta a um registro, por busca nos diretórios ancestrais. As duas dimensões não são independentes (um vínculo não resolvido não tem método de resolução), mas são registradas separadamente. Vínculos explícitos têm precedência sobre a descoberta pelo ambiente.
] <def-vinculo-consumidor>

#invariante(titulo: [Como se chegou não faz parte do destino])[
  A base e o método do vínculo descrevem como a sessão chegou à coordenada; não fazem parte do domínio nem da perspectiva. O mesmo domínio pode ser alcançado de modos diferentes, e deve ser o mesmo domínio em todos eles.
] <inv-vinculo-destino>

#invariante(titulo: [O alvo efetivo não é o declarado])[
  Quando a coordenada vem de um valor padrão (e não de uma declaração explícita), isso deve ser registrado. Um alvo usado por padrão não é um alvo configurado, e tratá-lo como tal esconde que ninguém o escolheu.
] <inv-alvo-efetivo>

#exercicios[
  + Classifique a base e o método do vínculo em: (a) um agente iniciado com um parâmetro que nomeia o domínio; (b) um agente iniciado num diretório, que encontra um marcador de domínio subindo pelos diretórios ancestrais; (c) um agente que recebe a coordenada num pacote de transferência.
  + Por que a busca nos diretórios ancestrais é um método frágil? Relacione com o @caso-localizador-reaproveitado.
  + Dê um exemplo em que o alvo efetivo de um vínculo difere do declarado e descreva como a perspectiva deve apresentar a divergência ao consumidor.
]

== Resolução em duas fases <sec-loc-duas-fases>

Quando um consumidor pede algo por referência — "a fonte corrente do recurso $X$" —, a resolução atravessa várias etapas, cada uma com seu modo de falha. Separá-las é a chave para respostas honestas.

#figure(
  diagram(
    spacing: (6mm, 8mm),
    node-stroke: 0.5pt + cor.primaria, node-fill: cor.tinta-def, node-corner-radius: 2pt,
    node((0, 0), text(size: 8pt)[referência\ conhecida]),
    node((1, 0), text(size: 8pt)[identidade\ resolvida]),
    node((2, 0), text(size: 8pt)[locus\ resolvido]),
    node((3, 0), text(size: 8pt)[transporte\ disponível]),
    node((4, 0), text(size: 8pt)[leitura\ autorizada]),
    node((5, 0), text(size: 8pt)[perspectiva\ aplicável]),
    edge((0, 0), (1, 0), "-|>"), edge((1, 0), (2, 0), "-|>"), edge((2, 0), (3, 0), "-|>"),
    edge((3, 0), (4, 0), "-|>"), edge((4, 0), (5, 0), "-|>"),
  ),
  caption: [A cadeia de resolução. Cada etapa pode parar com um motivo explícito. As duas primeiras etapas são _semânticas_ (o que é); locus e transporte são _materiais_ (onde está e se pode ser alcançado); leitura e aplicabilidade são de _autoridade_ e de _relevância_.],
) <fig-cadeia-resolucao>

#principio(titulo: [Descoberta propõe; aquisição verifica])[
  Um índice — de busca, de similaridade, de nomes — _propõe_ candidatos; não estabelece fatos. A aquisição — obter, limitadamente, uma observação do candidato e verificar sua identidade — é que estabelece. Resolução semântica não é resolução material.
] <pri-descoberta-aquisicao>

#algoritmo("Resolve-em-Duas-Fases", params: $q, kappa$, legenda: [Resolução de uma referência $q$ a partir da coordenada $kappa$, devolvendo, para cada candidato, a etapa alcançada e o motivo de parada.])[
  + $C <- $ #proc("Índice")$(q)$ #h(1fr) ▷ descoberta: propõe
  + $R <- emptyset$
  + #kw[para cada] $c in C$ #kw[faça]
    + $i <- $ #proc("Resolve-Identidade")$(c)$
    + #kw[se] $i = bot$ #kw[então] $R <- R union {(c, $ #estado[identidade não resolvida]$)}$; #kw[continue]
    + $L <- $ loci registrados de $i$ $union$ loci descobríveis a partir do nó de $kappa$
    + #kw[para cada] $ell in L$ #kw[faça]
      + #kw[se] não há transporte para $ell$ #kw[então] $R <- R union {(i, ell, $ #estado[transporte indisponível]$)}$; #kw[continue]
      + #kw[se] $kappa$ não pode ler metadados de identidade em $ell$ #kw[então] $R <- R union {(i, ell, $ #estado[leitura bloqueada]$)}$; #kw[continue]
      + $(e, "motivo") <- $ #proc("Resolve-Localizador")$(i, ell)$ #h(1fr) ▷ @alg-resolve-localizador
      + #kw[se] $e != $ #estado[disponível] #kw[então] $R <- R union {(i, ell, e, "motivo")}$; #kw[continue] #h(1fr) ▷ preserva ausente, sem marcador, ocupado
      + #kw[se] $kappa$ não tem leitura sobre o conteúdo de $i$ #kw[então] $R <- R union {(i, ell, $ #estado[conteúdo bloqueado]$)}$; #kw[continue]
      + $R <- R union {(i, ell, $ #proc("Aplicabilidade")$(i, kappa))}$
  + #kw[devolva] $R$
] <alg-duas-fases>

A ordem das verificações segue a cadeia: transporte antes de qualquer leitura no locus; leitura de metadados de identidade antes de examinar o localizador; leitura do conteúdo só depois de provada a identidade. Cada motivo de parada — inclusive os três de @alg-resolve-localizador (localizador ausente, sem marcador, ocupado por outro recurso) — é preservado no resultado, sem colapsar em "obsoleto". O custo do algoritmo é linear no número de pares (candidato, locus) examinados, mais o custo das observações. Mais importante que o custo é a forma do resultado: em vez de "encontrado" ou "não encontrado", ele devolve, para cada candidato, _até onde a resolução chegou_ e _por que parou_. É essa forma que permite ao consumidor decidir o próximo passo — autenticar-se, pedir autoridade, escolher outro locus — em vez de concluir que o recurso não existe.

=== Superfície, locus e nó

Três coisas costumam ser confundidas na resolução material. A _superfície_ é como se alcança uma execução (um endereço de serviço, uma ferramenta de linha de comando, um protocolo); o _locus_ é onde a resposta é observada; o _nó_ é o universo de resolução onde o locus vive. Um resultado de aquisição deve registrar os três separadamente.

#invariante(titulo: [Alcançável não é autorizado])[
  Conseguir estabelecer transporte até um locus (por exemplo, um acesso remoto bem-sucedido) não autoriza a leitura do domínio ali materializado. Transporte, locus e autoridade são etapas distintas da @fig-cadeia-resolucao.
] <inv-alcancavel>

Quando o locus é remoto, a identificação dele próprio segue uma _cadeia de vinculação_: uma dica declarada (um apelido configurado) leva a uma observação de transporte, que leva a um autorrelato do serviço remoto, que estabelece a identidade de instalação do nó remoto, que permite um vínculo tipado "este apelido designa este locus", que finalmente permite observar as materializações de domínios ali. Nenhum elo da cadeia significa autoridade; um elo que diverge (o autorrelato não confere com a identidade esperada) produz um conflito explícito.

#exercicios[
  + Execute mentalmente o @alg-duas-fases para uma referência com dois candidatos: um cuja identidade não resolve e outro materializado em dois loci, um deles com localizador obsoleto.
  + Por que o algoritmo continua examinando os demais loci depois de encontrar um com leitura bloqueada?
  + Descreva a cadeia de vinculação de um locus remoto acessado por um apelido de configuração, e o que acontece se a máquina por trás do apelido for substituída.
]

== O escopo da negação <sec-loc-negacao>

Quando a resolução falha, que conclusão é legítima?

#lema(titulo: [Escopo da negação])[
  Seja $"res"(i, kappa)$ a resolução do identificador $i$ a partir da coordenada $kappa$, e suponha que ela falhe depois de examinar exatamente o conjunto de loci $L$. A única conclusão logicamente válida, sem hipóteses adicionais de completude, é "$i$ não foi resolvido em $L$". Em particular, não se segue que $i$ não exista, nem que não seja resolvível noutro locus.
] <lem-escopo-negacao>

#prova[
  Basta exibir, para cada conclusão mais forte, um modelo compatível com as observações em que ela é falsa. Tome um mundo idêntico ao observado em todos os loci de $L$, mas em que $i$ está materializado num locus $ell' in.not L$. As observações feitas são as mesmas nos dois mundos; logo nenhuma conclusão que valha em um e não no outro pode ser derivada delas. "$i$ não existe" e "$i$ não é resolvível em lugar algum" são falsas no segundo mundo.
]

O lema é a contraparte, para localização, do @inv-ausencia-negacao e da sentinela "não observado aqui não é não observado em lugar algum" (@inv-sentinelas-escopo). Ele tem uma consequência operacional importante.

#invariante(titulo: [Falha de descoberta não é ausência])[
  Não encontrar o localizador de um recurso não prova que o recurso foi perdido. Antes de concluir perda — e, sobretudo, antes de reimplementar algo "perdido" —, faz-se uma busca forense limitada nos loci legítimos; e a conclusão de perda, se vier, é uma decisão governada ("operacionalmente perdido: nenhum caminho autorizado de recuperação após busca limitada"), não uma inferência.
] <inv-descoberta-ausencia>

Uma variante sutil: um recurso pode estar _retido_ — seus bytes preservados num armazenamento por conteúdo — e, ainda assim, ser _indescobrível_, porque nenhum índice aponta para ele. Retenção não é descoberta.

#exercicios[
  + Um agente procura a fonte de uma biblioteca em três diretórios e não encontra. Reescreva sua conclusão respeitando o @lem-escopo-negacao.
  + Proponha um procedimento de busca forense limitada e o registro de decisão que encerra a busca.
  + Reformule o lema do escopo da negação como uma regra de renderização: o que deve acompanhar toda frase negativa ("não há", "não existe", "não encontrado") num contexto entregue a um agente?
]

== Orientação de sessão <sec-loc-orientacao>

Reunindo as peças, o primeiro procedimento que um consumidor deveria executar ao chegar é a orientação: um comando somente leitura que responde onde ele está, a partir de qual perspectiva soberana, com que objetivo, e o que pode e deve fazer.

#algoritmo("Orienta-Sessão", params: $s$, legenda: [Orientação de sessão, somente leitura.])[
  + $kappa <- $ #proc("Coordenada")$($#proc("Autolocaliza")$(s))$ #h(1fr) ▷ descarta proveniências; $bot$ onde a confiança é insuficiente
  + $P <- pi(Sigma, kappa)$
  + #kw[se] nenhuma unidade de trabalho está selecionada #kw[então]
    + #kw[se] há trabalho soberano observável noutro domínio ou locus #kw[então]
      + recomende "abrir a perspectiva / resolver o locus", com as referências #h(1fr) ▷ nunca "criar trabalho novo"
  + #kw[se] o objetivo é $bot$ #kw[então] pergunte o objetivo
  + próxima aresta $<- $ #estado[não resolvida] até seleção do titular, salvo prioridade ou aplicabilidade positivas
  + #kw[devolva] (coordenada, perspectiva, recomendações, desconhecidos)
] <alg-orienta-sessao>

As linhas 3 a 5 são a correção do @anti-inventario-selecao, e a linha 7 aplica o @pri-ancora-fronteira: a orientação não inventa o próximo trabalho. O @cap-entrada retoma a orientação do ponto de vista da entrega de contexto ao modelo e da verificação de que o consumidor efetivamente se orientou.

#exercicios[
  + Execute o @alg-orienta-sessao para um agente iniciado num domínio sem trabalho aberto, numa máquina em que outro domínio tem duas unidades abertas.
  + Por que a orientação deve ser somente leitura? Que riscos uma orientação que "conserta" coisas introduziria?
  + Escreva a saída do @alg-orienta-sessao para um agente iniciado fora de qualquer domínio, numa máquina com três domínios materializados. Que informação ela deve conter para que o agente não escolha um domínio por conta própria?
]

#quadro[
  - Processo tem diretório; nó tem locus de resolução; sessão tem coordenada; a perspectiva projeta da coordenada.
  - A coordenada é um vetor de escopos com $bot$; coordenadas parciais são válidas e mudar uma dimensão não destrói as outras.
  - Autolocalize com proveniência por campo; relate divergências, não as repare; escreva só com autoridade de governança.
  - O vínculo registra base e método; o alvo efetivo por padrão não é o declarado.
  - Resolução em duas fases: descoberta propõe, aquisição verifica; devolva até onde se chegou e por que parou.
  - Alcançável não é autorizado; a cadeia de vinculação de loci remotos não concede autoridade.
  - Escopo da negação: falhar em $L$ só prova "não resolvido em $L$" (@lem-escopo-negacao); falha de descoberta não é ausência.
]

#problemas[
  #problema([Resolvedor provadamente correto])[
    Especifique um resolvedor de identidade para materialização local.
    + Defina formalmente a correção: o resolvedor só devolve uma materialização se ela prova ser a identidade pedida; e devolve #estado[não resolvido] com o conjunto de loci examinados caso contrário.
    + Prove que sua especificação impede o erro do @caso-localizador-reaproveitado.
    + Analise o custo em função do número de loci e do custo de verificação de identidade.
  ]
  #problema([Coordenadas e monotonicidade da perspectiva])[
    Considere a ordem de refinamento sobre $K$ (@def-espaco-coordenadas).
    + Dê condições suficientes sobre $pi$ para que refinar a coordenada nunca acrescente asserções aplicáveis que a coordenada menos específica considerava não aplicáveis.
    + Mostre um exemplo natural em que refinar o _perfil_ reduz a perspectiva e refinar o _trabalho_ a altera de forma não monótona.
    + Discuta se a não monotonicidade é um defeito ou uma propriedade desejável.
  ]
  #problema([Orientação em ambientes multinó])[
    Um titular trabalha com agentes em três máquinas, cada uma com materializações de domínios diferentes.
    + Projete o registro de nós e a cadeia de vinculação que permitem a um agente, em qualquer máquina, descobrir onde está o trabalho observável.
    + Mostre como o @alg-orienta-sessao precisa ser estendido.
    + Identifique os riscos de divulgação: o que um agente numa máquina pode saber sobre domínios materializados em outra?
  ]
]

#notas[
  A distinção entre nomes, endereços e rotas remonta à teoria de nomeação de #ct(<saltzer1978>); a resolução hierárquica de nomes e a separação entre identificadores e localizadores na web @rfc3986 são antecedentes diretos da cadeia de resolução deste capítulo. A ideia de consciência situacional — perceber os elementos do ambiente, compreender seu significado e projetar seu estado futuro — de #ct(<endsley1995>) oferece uma moldura cognitiva para a orientação de sessão; o ciclo observar–orientar–decidir–agir associado a Boyd @osinga2007 enfatiza, como aqui, que a orientação precede a decisão. A crítica à suposição de que o agente "sabe onde está" ecoa a análise de ação situada de #ct(<suchman1987>).

  A autolocalização com proveniência por campo, a regra "relatar, não reparar" e o lema do escopo da negação são propostas deste livro; o estudo de caso do serviço que não enxergava o domínio vizinho generaliza uma falha recorrente de processos que tomam o lugar onde nasceram pelo mundo inteiro.
]
