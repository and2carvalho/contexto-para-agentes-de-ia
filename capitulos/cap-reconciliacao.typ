#import "/modelo/estilo.typ": *

= Reconciliação, deriva e afetação <cap-reconciliacao>

#epigrafe[A divergência entre o que se declarou e o que se observa não é ruído: é a informação mais importante que o sistema tem.]

Todo sistema real diverge de sua descrição. Configurações declaram um estado que os processos não atingiram; registros de autoridade afirmam uma membresia que a materialização não reflete; um serviço continua executando uma versão antiga depois que a nova foi instalada. A _reconciliação_ é a atividade de observar essas divergências, entendê-las e, quando apropriado e autorizado, eliminá-las.

O tema tem uma tradição sólida em sistemas distribuídos e em orquestração de contêineres, onde controladores comparam continuamente o estado desejado com o observado e agem para aproximá-los @burns2016 @verma2015. Este capítulo adapta essa tradição a sistemas de contexto, com uma diferença deliberada: aqui, a reconciliação é _conservadora_ — ela propõe, e a passagem da proposta ao efeito exige autoridade. A @sec-rec-planos apresenta os quatro planos de estado. A @sec-rec-deriva define deriva e achados. A @sec-rec-laco descreve o laço conservador. A @sec-rec-convergencia prova condições de convergência. A @sec-rec-crdt compara reconciliação por autoridade com convergência por junção. A @sec-rec-afetacao trata da afetação de mudanças concorrentes sobre um efeito candidato. A @sec-rec-donos trata de reconciliação com múltiplos donos.

== Quatro planos de estado <sec-rec-planos>

Para cada sujeito relevante — um serviço, uma pertinência, uma permissão, uma revisão em execução —, há quatro perguntas diferentes, cada uma com seu dono e seu relógio.

#definicao(titulo: [Planos de estado])[
  - O plano _desejado_ registra o que o dono de uma intenção declarou que deveria ser (por exemplo, numa configuração versionada).
  - O plano _autoritativo observado_ registra o que a autoridade competente reconhece como estado vigente (por exemplo, o registro de membresia mantido pelo serviço de autoridade).
  - O plano _materializado_ registra o que um locus efetivamente tem, segundo observação limitada (por exemplo, os arquivos presentes numa máquina, o binário instalado).
  - O plano _ativo_ registra o que um consumidor ou processo está efetivamente usando agora (por exemplo, a versão carregada na memória de um processo de longa duração).
] <def-planos-estado>

#observacao(titulo: [Relação com as três colunas do @cap-modelo])[
  O _declarado_ do @pri-tres-colunas corresponde ao plano desejado; o _observado_ desdobra-se em autoritativo observado e materializado, observados por fontes diferentes; o plano ativo é o observado do lado do processo em execução; e o _efetivo_ do @cap-modelo é ortogonal aos quatro planos: é o que, de qualquer deles, entrou na perspectiva com que um consumidor decidiu. Os planos de verdade da configuração (@tab-planos-verdade) são outra classificação: de _artefatos de configuração_ por portabilidade e editor, não de estados de um sujeito.
]

Cada valor em cada plano carrega dono, referência, instante de observação e estatuto. A indisponibilidade de um plano — o serviço de autoridade não responde, a máquina está desligada — não é uma falha da reconciliação: é um valor #est[desconhecido] naquele plano, que a perspectiva deve mostrar como tal.

#exemplo(titulo: [Quatro planos de uma atualização])[
  Um serviço deve estar na versão 3. Desejado: versão 3 (configuração versionada, alterada ontem). Autoritativo observado: versão 3 aprovada para produção (registro de linha de base). Materializado: binário da versão 3 instalado na máquina (resumo criptográfico conferido). Ativo: o processo em execução foi iniciado antes da instalação e ainda executa a versão 2. Nenhum plano está "errado"; o estado é uma combinação perfeitamente explicável — e o achado relevante é a divergência entre materializado e ativo.
] <ex-quatro-planos>

#invariante(titulo: [Os quatro planos são distintos])[
  Desejado, autoritativo observado, materializado e ativo são planos com donos e relógios diferentes. Nenhum é inferido de outro: estar declarado não é estar aprovado; estar aprovado não é estar instalado; estar instalado não é estar em uso.
] <inv-quatro-planos>

#exercicios[
  + Descreva os quatro planos para a pertinência de um agente a uma composição de domínios.
  + Um arquivo de configuração foi substituído, mas o processo de longa duração não foi reiniciado. Em que planos o estado mudou?
  + Por que a indisponibilidade do plano autoritativo deve aparecer como #est[desconhecido] e não como falha da reconciliação inteira?
]

== Deriva e achados <sec-rec-deriva>

#definicao(titulo: [Deriva])[
  Há _deriva_ num sujeito quando dois de seus planos de estado discordam. A deriva é descrita por um _achado_: a tupla (sujeito, transição quebrada, referência desejada e seu dono, referência observada e sua proveniência, estatuto, aplicabilidade, classe de efeito proposta, dono de autoridade requerido, executável?).
] <def-deriva>

Com quatro planos, uma mesma causa pode produzir até seis pares discordantes numa dimensão. Por isso os achados são agregados _por dimensão_: o achado de uma dimensão traz o vetor dos quatro valores, e não um par; o @teo-convergencia conta dimensões discordantes, não pares.

#invariante(titulo: [Deriva não é erro])[
  Uma divergência entre planos pode ter muitas causas legítimas: governança pendente, desconexão temporária, modo local deliberado, autoridade retida, reinício programado. A deriva é informação a ser explicada, não alarme a ser silenciado. Detectar deriva não autoriza corrigi-la.
] <inv-deriva-erro>

#antipadrao(titulo: [O reconciliador cego])[
  Um mecanismo declarativo compara o desejado com o observado e "aplica" a diferença a qualquer custo: reinicia serviços, sobrescreve permissões, reinstala binários. Ele trata o plano desejado como autoridade e a deriva como erro, e confunde planejar com aplicar. Quando a deriva tinha uma causa legítima — uma correção manual de emergência, uma decisão pendente —, o reconciliador a desfaz silenciosamente.
] <anti-reconciliador-cego>

#exercicios[
  + Para o @ex-quatro-planos, escreva o achado completo.
  + Dê três causas legítimas para deriva entre desejado e autoritativo observado.
  + Classifique como deriva esperada, deriva a corrigir ou erro: (a) a configuração desejada pede três réplicas e há duas, por uma falha de máquina; (b) a versão materializada é posterior à aceita, num ambiente de testes; (c) um serviço está ativo sem nenhuma declaração desejada correspondente.
]

== O laço de reconciliação conservador <sec-rec-laco>

#algoritmo("Reconcilia", params: $S$, legenda: [Uma volta do laço de reconciliação conservador sobre o conjunto de sujeitos $S$.])[
  + #kw[para cada] sujeito $s in S$ #kw[faça]
    + #kw[para cada] plano $p in {"desejado", "autoritativo", "materializado", "ativo"}$ #kw[faça]
      + $v_p (s) <- $ #proc("Observa")$(s, p)$ #h(1fr) ▷ valor, dono, instante, estatuto
  + $A <- {$achado$(s) : $ dois planos de $s$ discordam$}$
  + #kw[para cada] achado $a in A$ #kw[faça]
    + $a."proposta" <- $ #proc("Qualifica")$(a)$ #h(1fr) ▷ satisfação, reconciliabilidade, acionabilidade
  + #kw[devolva] $A$ agrupado por dono de autoridade requerido
] <alg-reconcilia>

Uma volta custa $4|S|$ observações e uma qualificação por achado — $O(|S| T_"obs" + |A| T_"qual")$ —, e é somente leitura: nenhuma linha muda o acervo ou o ambiente, de modo que repeti-la é seguro. A saída do laço não é uma lista de ações executadas: é uma lista de _achados qualificados_, agrupados pelo dono que poderia autorizar sua resolução. A passagem de um achado para um efeito segue o laço de mutação governada do @cap-ciclo-acao — com observação fresca, autorização e pós-condição.

Duas regras de ordem completam o laço.

#principio(titulo: [Plano não é aplicação])[
  Calcular o que seria necessário para eliminar uma deriva não é executá-lo. A aplicação é a passagem, aresta por aresta, de cada achado ao seu dono, à autorização, ao efeito e à evidência.
] <pri-plano-aplicacao>

#principio(titulo: [Observável antes de declarável])[
  Só declare um novo estado desejado depois de conseguir observar e explicar o estado atual. Uma configuração desejada elegante, escrita sem que se saiba por que o estado atual é o que é, transforma derivas não explicadas em ordens de correção cegas.
] <pri-observavel-declaravel>

#exercicios[
  + Por que o @alg-reconcilia agrupa achados por dono de autoridade? Que problema essa organização resolve?
  + Descreva uma situação em que aplicar o princípio "observável antes de declarável" teria evitado um incidente.
  + Por que o laço de reconciliação conservador produz um plano antes de aplicar qualquer efeito? Dê um exemplo em que aplicar diretamente teria causado dano que o plano revelaria.
]

== Convergência <sec-rec-convergencia>

Quando os achados são resolvidos — com autorização — por efeitos de garantia (@def-efeito-garantia), o laço converge.

#teorema(titulo: [Convergência da reconciliação com efeitos de garantia])[
  Suponha que: (i) cada sujeito tenha um único dono por dimensão; (ii) cada achado resolvível seja resolvido por um efeito de garantia que leva a dimensão ao valor desejado sem alterar outras dimensões; (iii) não haja perturbação externa nem mudança do estado desejado durante o processo. Seja $N_0$ o número inicial de dimensões discordantes — resolvíveis ou bloqueadas. Então o número de dimensões discordantes diminui estritamente a cada volta em que algum achado é resolvido, e o laço atinge, em no máximo $N_0$ voltas com resolução, um estado sem achados resolvíveis.
] <teo-convergencia>

#prova[
  Use como função potencial o número $N$ de dimensões discordantes. Por (ii), resolver um achado zera a discordância naquela dimensão e não cria discordância em outras; por (iii), nenhuma discordância nova surge do exterior; por (i), não há dois donos levando a mesma dimensão a valores diferentes. Logo cada volta com pelo menos uma resolução reduz $N$ em pelo menos 1. Como $N >= 0$, há no máximo $N_0$ tais voltas. Note que o número de achados _resolvíveis_ não serve como potencial: resolver um achado pode desbloquear outro, mantendo-o constante.
]

As hipóteses do teorema são exatamente as que, quando violadas, produzem as patologias conhecidas de sistemas de reconciliação.

#exemplo(titulo: [Dois donos, oscilação])[
  Dois controladores gerenciam o mesmo parâmetro: um quer o valor $a$, outro o valor $b$. Cada volta de um desfaz a do outro. O sistema composto não tem ponto fixo — nenhum estado satisfaz os dois controladores —, embora cada controlador, isoladamente, convirja. A correção não é um controlador mais rápido, mas a hipótese (i): um único dono por dimensão.
] <ex-oscilacao>

#exercicios[
  + Construa um exemplo em que a violação da hipótese (ii) — um efeito que corrige uma dimensão e altera outra — faz o laço não convergir.
  + Relacione o @teo-convergencia com o @teo-ap-kleene, identificando o reticulado e a função monótona.
  + No exemplo de dois donos com oscilação, proponha uma regra de autoridade que elimine a oscilação e prove que, sob ela, o laço converge.
]

== Reconciliação por autoridade e convergência por junção <sec-rec-crdt>

Há uma segunda tradição de convergência em sistemas distribuídos: os _tipos de dados replicados livres de conflito_ (CRDTs) @shapiro2011. Neles, réplicas recebem atualizações em qualquer ordem e convergem para o mesmo estado sem coordenação, porque o estado pertence a um semirreticulado de junção e a fusão de duas réplicas é a junção.

#teorema(titulo: [Convergência forte por junção])[
  Seja $(L, union.sq)$ um semirreticulado de junção. (a) _Por estado_: se cada atualização é aplicada apenas na réplica de origem, é inflacionária ($x lt.eq u(x)$), e as réplicas trocam estados fundindo-os por $union.sq$, então duas réplicas que fundiram os mesmos estados de origem, em qualquer ordem e com qualquer repetição, estão no mesmo estado. (b) _Por junção de deltas_: se toda atualização tem a forma $x |-> x union.sq d$, então duas réplicas que aplicaram o mesmo multiconjunto de deltas, em qualquer ordem e com qualquer repetição, estão no estado $x_0 union.sq union.sq.big_i d_i$.
] <teo-crdt>

#prova[
  (b) A junção é comutativa, associativa e idempotente; logo o resultado de aplicar os deltas é a junção de todos eles com o estado inicial, independentemente de ordem e multiplicidade. (a) Por indução no número de fusões: o estado de cada réplica é sempre a junção dos estados de origem que ela já incorporou, e a junção de um mesmo conjunto não depende da ordem nem das repetições.
]

A hipótese não pode ser enfraquecida para "atualizações apenas inflacionárias, aplicadas em todas as réplicas": atualizações inflacionárias não comutam em geral. Com $u_1 (x) = x union.sq a$ e $u_2(x) =$ "se $a lt.eq x$ então $x union.sq b$ senão $x union.sq c$", tem-se $u_2(u_1(bot)) = a union.sq b != a union.sq c = u_1(u_2(bot))$. É por isso que, nos CRDTs por estado @shapiro2011, o que se propaga é o estado, não a operação.

Quando usar cada abordagem? A resposta depende da natureza do que está sendo reconciliado.

#figure(
  tabela(
    colunas: (1fr, 1fr),
    cabecalho: ([Convergência por junção (CRDT)], [Reconciliação por autoridade]),
    [acumular observações e evidências (conjuntos que só crescem)], [decidir qual revisão é a linha de base],
    [registrar conflitos (Belnap: verdadeiro e falso relatados viram contraditório)], [resolver conflitos (quem decide entre os relatos)],
    [contadores, conjuntos de marcas, históricos append-only], [permissões, membresias, configurações efetivas],
    [nenhuma decisão é tomada; apenas se acumula], [cada resolução é um ato de um dono],
  ),
  caption: [Quando convergir por junção e quando reconciliar por autoridade. Regras do tipo "o último que escreve vence" são convergentes, mas não são autoridade: decidem pelo relógio, não pelo dono.],
) <tab-crdt-autoridade>

#principio(titulo: [Acumule por junção; decida por autoridade])[
  O que é observação pode convergir por junção; o que é decisão converge apenas por ato de quem tem autoridade. Misturar os dois — por exemplo, decidir uma linha de base por "último escritor vence" — dá convergência sem legitimidade.
] <pri-juncao-autoridade>

#exercicios[
  + Mostre que o acervo do @cap-modelo, crescendo por acréscimo, é um CRDT trivial (conjunto que só cresce). Que parte do sistema, então, não pode ser CRDT?
  + Dê um exemplo em que "último escritor vence" produz uma linha de base que nenhum dono aprovou.
  + Classifique como acumulável por junção ou decidível só por autoridade: o conjunto de evidências de um recurso; a linha de base aceita; o conjunto de etiquetas de um documento; o dono de um domínio.
]

== Afetação de mudanças concorrentes <sec-rec-afetacao>

Em trabalho multiagente, é comum que um agente prepare um efeito candidato — uma mudança de código com sua evidência — enquanto outro agente promove uma mudança diferente na linha de base. A pergunta é: a mudança alheia afeta o candidato? Exige refazer o trabalho, reexecutar as provas, ou nada?

#definicao(titulo: [Efeito candidato])[
  Um _efeito candidato_ é uma tupla $E = (b, Delta, W, R, D, pi_E)$: a base $b$ sobre a qual foi preparado; a mudança $Delta$; o conjunto de escrita $W$ (o que $Delta$ altera); o conjunto de leitura $R$ (o que $Delta$ e suas provas leem); as dependências $D$ (interfaces, contratos, artefatos gerados de que depende); e o ambiente de prova $pi_E$.
] <def-efeito-candidato>

#definicao(titulo: [Classes de afetação])[
  A _afetação_ de uma mudança alheia $Delta'$ sobre um efeito candidato $E$ é um elemento da cadeia
  $ #estado[sem efeito] < #estado[só reconciliação] < #estado[renovar prova] < #estado[refazer] < #estado[conflito semântico] $
  ou o valor #est[desconhecido], que está fora da cadeia e pede expansão.
] <def-afetacao>

A primeira pergunta é: quando se pode afirmar, com segurança, que não há efeito? Um resultado clássico sobre programas paralelos responde.

#teorema(titulo: [Condições de Bernstein])[
  Sejam $Delta$ e $Delta'$ duas mudanças com conjuntos de leitura $R, R'$ e de escrita $W, W'$. Se $R inter W' = W inter R' = W inter W' = emptyset$, então executar $Delta$ e $Delta'$ em qualquer ordem produz o mesmo estado final, e o resultado observado por cada uma é independente da outra.
] <teo-bernstein>

#prova[
  Se nenhuma das mudanças escreve o que a outra lê, os valores lidos por cada uma são os mesmos em qualquer ordem; se, além disso, não escrevem nas mesmas posições, as escritas não se sobrepõem. Logo o estado final é a união das escritas, independentemente da ordem.
]

O teorema dá uma condição _suficiente_ para #estado[sem efeito]. Mas a pergunta geral — "a mudança $Delta'$ altera o comportamento relevante de $E$?" — é uma pergunta sobre a semântica de programas, e o teorema de Rice diz que propriedades semânticas não triviais de programas são indecidíveis @rice1953. A consequência para projeto é direta.

#corolario(titulo: [Afetação é aproximação conservadora])[
  Se as mudanças são escritas numa linguagem Turing-completa, nenhum procedimento automático decide corretamente a afetação semântica em todos os casos. Todo procedimento útil é uma aproximação conservadora, que deve devolver #est[desconhecido] — ou uma classe maior — quando suas condições suficientes não se aplicam.
] <cor-afetacao-conservadora>

#prova[
  Fixe um programa $P_0$ e considere a mudança que substitui $P_0$ por $P$. Decidir se ela "não altera o comportamento relevante" é decidir se $P$ é equivalente a $P_0$ — uma propriedade semântica não trivial dos programas, indecidível pelo teorema de Rice @rice1953 quando a linguagem é Turing-completa. Em linguagens restritas (por exemplo, configurações sem recursão), a afetação pode ser decidível.
]

#algoritmo("Afetação", params: $E, Delta'$, legenda: [Classificação conservadora da afetação de uma mudança alheia sobre um efeito candidato.])[
  + #kw[se] $W$, $R$, $D$, $pi_E$, $W'$ ou $R'$ não são conhecidos #kw[então] #kw[devolva] #est[desconhecido]
  + #kw[se] $W inter W' != emptyset$ #kw[e] há incompatibilidade _detectada_ (conflito de fusão, contrato violado, teste reprovado) #kw[então] #kw[devolva] #estado[conflito semântico]
  + #kw[se] $W inter W' != emptyset$ #kw[então] #kw[devolva] #estado[refazer]
  + #kw[se] $W' inter (R union D) != emptyset$ #kw[ou] $Delta'$ toca $pi_E$ #kw[então] #kw[devolva] #estado[renovar prova]
  + #kw[se] $W inter R' != emptyset$ #kw[então] #kw[devolva] #estado[só reconciliação] #h(1fr) ▷ o candidato afeta a mudança alheia
  + #kw[devolva] #estado[sem efeito] #h(1fr) ▷ condições de Bernstein (@teo-bernstein)
] <alg-afetacao>

O algoritmo é correto em relação ao @teo-bernstein: só devolve #estado[sem efeito] (linha 6) quando $W inter W'$, $W' inter R$ e $W inter R'$ são vazios. Sua correção depende de que os conjuntos sejam conhecidos _exatamente_ ou aproximados _por excesso_: se $R$ for subestimado, a linha 6 pode afirmar independência que não existe. Com conjuntos aproximados por excesso, ele é conservador — pode devolver uma classe maior que a necessária, nunca menor. A "incompatibilidade detectada" da linha 2 não é um oráculo semântico, que seria indecidível (@cor-afetacao-conservadora), mas a evidência de uma verificação concreta. Com conjuntos em tabelas de dispersão, o custo esperado é $O(|W| + |W'| + |R| + |R'| + |D|)$.

#invariante(titulo: [Histórias divergentes não são afetação])[
  O fato de duas linhas de desenvolvimento terem divergido no controle de versão não implica que uma afete a outra. Divergência é uma propriedade da história; afetação é uma propriedade das mudanças. Rebasear compulsivamente toda divergência produz laços de realinhamento sem valor.
] <inv-historias-divergentes>

=== Geometria da promoção

Na promoção de um candidato $c$ sobre uma linha de base remota $r$, três geometrias são possíveis: $r$ é ancestral de $c$ (avanço direto: o candidato contém tudo); $c$ e $r$ divergiram sem sobreposição _textual_; ou divergiram com sobreposição textual. A geometria é observável no controle de versão, mas não decide a afetação: ausência de sobreposição textual não implica as condições de Bernstein, que exigem também que nenhuma das mudanças escreva o que a outra lê. A afetação exige o @alg-afetacao.

#exercicios[
  + Classifique a afetação nos casos: (a) a mudança alheia altera um arquivo de documentação não lido pelo candidato; (b) altera a assinatura de uma função que o candidato chama; (c) altera a versão do compilador usada nos testes; (d) altera o mesmo trecho de código que o candidato.
  + Mostre que o @alg-afetacao devolve #estado[sem efeito] apenas sob as condições de Bernstein e explique por que, se os conjuntos de leitura forem estimados por falta, essa saída deixa de ser segura.
  + Aplique as condições de Bernstein a duas mudanças: uma altera a função $f$ e a outra altera um teste que chama $f$. Elas são independentes? O que a análise de afetação conservadora conclui?
]

== Reconciliação com múltiplos donos <sec-rec-donos>

Em ambientes reais, os achados de uma reconciliação pertencem a donos diferentes: a membresia de um domínio a uma composição pertence a um dono; a revisão aceita de um serviço, a outro; a configuração de uma máquina, a um terceiro. Um único executor que resolvesse todos os achados violaria a separação de poderes e o princípio do menor privilégio.

#definicao(titulo: [Reconciliação multi-dono])[
  Uma _reconciliação multi-dono_ particiona os achados por dono de autoridade e entrega a cada dono apenas os seus, com as propostas qualificadas correspondentes. Cada dono executa seus efeitos tipados, sob sua autoridade, e produz evidência. O estado global é recomposto a partir das evidências, e achados que dependem de outros donos permanecem como #estado[bloqueados] com a dependência explícita.
] <def-multidono>

#principio(titulo: [Um grafo de leitura, muitos modelos de escrita])[
  A leitura de um ambiente pode ser unificada numa única projeção — um grafo que mostra todos os planos e achados. A escrita não pode: cada relação editável tem seu dono, seu domínio de autoridade e seu efeito tipado. Um botão "corrigir tudo" é um executor genérico disfarçado.
] <pri-leitura-escrita>

#exercicios[
  + Particione os achados de uma reconciliação de exemplo (com cinco achados de três donos) e descreva a ordem em que podem ser resolvidos quando um depende de outro.
  + Por que "mover um ambiente" não deve ser implementado como um único efeito de "implantar"? Decomponha a transição em efeitos com donos distintos.
  + Descreva um cenário de reconciliação com dois donos de escrita para planos diferentes do mesmo recurso e mostre como um único grafo de leitura expõe o conflito sem resolvê-lo.
]

#quadro[
  - Quatro planos de estado — desejado, autoritativo observado, materializado, ativo — com donos e relógios distintos.
  - Deriva é informação, não erro; detectar não autoriza corrigir; achados são tuplas qualificadas.
  - O laço conservador observa, compara e propõe; aplicação é governada; plano não é aplicação; observável antes de declarável.
  - Com um dono por dimensão e efeitos de garantia, a reconciliação converge (@teo-convergencia); dois donos oscilam.
  - Acumule observações por junção (CRDT); decida por autoridade.
  - Afetação: as condições de Bernstein, com conjuntos conhecidos ou estimados por excesso, dão #estado[sem efeito] seguro; Rice impõe aproximação conservadora com #est[desconhecido]; divergência não é afetação.
  - Reconciliação multi-dono: um grafo de leitura, muitos modelos de escrita.
]

#problemas[
  #problema([Reconciliação com perturbações])[
    Relaxe a hipótese (iii) do @teo-convergencia: perturbações externas criam novos achados a uma taxa $lambda$ por unidade de tempo, e cada volta resolve até $k$ achados.
    + Modele o número de achados como uma fila e encontre a condição de estabilidade.
    + Discuta o que acontece com a perspectiva dos consumidores quando a condição é violada.
  ]
  #problema([Afetação decidível em linguagens restritas])[
    Para uma linguagem de configuração sem laços nem recursão, em que cada chave é atribuída no máximo uma vez:
    + Mostre que os conjuntos de leitura e escrita de uma mudança são calculáveis exatamente.
    + Mostre que, nessa linguagem, as condições de Bernstein são também necessárias para que duas mudanças comutem.
    + Discuta por que linguagens de configuração restritas facilitam a reconciliação.
  ]
  #problema([Controladores de reconciliação automáticos])[
    Compare o laço conservador deste capítulo com controladores que agem automaticamente sobre o estado desejado.
    + Identifique situações em que a ação automática é segura (por exemplo, reiniciar um processo morto) e situações em que não é.
    + Proponha um critério, baseado na classe de efeito e na reversibilidade, para decidir quais achados podem ser resolvidos sem autorização humana.
    + Relacione seu critério com o roteamento por portões (@sec-port-roteamento).
  ]
]

#notas[
  Controladores que reconciliam estado desejado e observado são centrais na orquestração de contêineres @burns2016 @verma2015; a gestão de configuração por promessas de agentes autônomos @bergstra2014 oferece outra tradição, que enfatiza que cada agente só pode prometer sobre si mesmo — ideia próxima à de um dono por dimensão. Os tipos de dados replicados livres de conflito são de #ct(<shapiro2011>); a teoria de consistência eventual e de garantias de sessão está em #ct(<vogels2009>) e #ct(<terry1994>), e #ct(<kleppmann2017>) oferece uma síntese acessível. As condições de independência para execução paralela são de #ct(<bernstein1966>), e a indecidibilidade de propriedades semânticas, de #ct(<rice1953>). A distinção entre convergência e legitimidade — que "último escritor vence" converge mas não decide — é um tema recorrente no projeto de sistemas distribuídos que mantêm dados com dono.

  O laço de reconciliação conservador, a tipologia de afetação e a distinção entre histórias divergentes e afetação são propostas deste livro para o trabalho de vários agentes sobre o mesmo conjunto de repositórios, que tende a dois erros opostos: rebasear compulsivamente a cada promoção alheia, ou ignorar mudanças de interface que invalidam provas.
]
