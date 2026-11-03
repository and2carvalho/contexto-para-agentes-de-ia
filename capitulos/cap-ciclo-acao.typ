#import "/modelo/estilo.typ": *

= O ciclo de vida da ação governada <cap-ciclo-acao>

#epigrafe[Retornar zero não prova que o efeito aconteceu.]

Até aqui, o livro tratou sobretudo do que um agente _sabe_. Este capítulo trata do que ele _faz_. Entre a intenção de mudar algo e a prova de que a mudança aconteceu há uma sequência de estágios, e cada estágio tem sua própria pergunta, sua própria evidência e seu próprio modo característico de falha. A maior parte dos acidentes com agentes autônomos pode ser descrita como um _salto_ entre estágios: executar o que apenas existia como possibilidade, declarar provado o que apenas foi executado, considerar autorizado o que apenas foi proposto.

A @sec-acao-cadeia apresenta a cadeia de estágios e prova que, numa execução correta, nenhum estágio é pulado. A @sec-acao-qualificacao introduz a qualificação em camadas de uma intenção contra a realidade. A @sec-acao-laco descreve o laço de mutação governada. A @sec-acao-efeitos trata de efeitos idempotentes e de execução exatamente-uma-vez. A @sec-acao-prova distingue recibo, pós-condição e evidência e enuncia a regra contra o excesso de alegação. A @sec-acao-poderes discute a separação de poderes entre quem propõe, quem autoriza, quem executa e quem decide.

== A cadeia de estágios <sec-acao-cadeia>

#definicao(titulo: [Estágios de uma ação])[
  Para uma ação $a$ (uma transição proposta sobre um sujeito) numa coordenada $kappa$, definimos sete predicados:
  + $"Existe"(a)$: a ação está definida — há uma operação com esse nome e assinatura;
  + $"Válida"(a, kappa)$: a ação é estruturalmente válida — sujeito resolvido (identidade e locus), parâmetros bem formados, pré-requisitos de forma satisfeitos;
  + $"Aplicável"(a, kappa)$: a ação se aplica ao objetivo da coordenada e ao sujeito resolvido;
  + $"Pronta"(a, kappa)$: as pré-condições específicas da transição estão satisfeitas no estado atual (por exemplo, a evidência exigida existe);
  + $"Autorizada"(a, kappa)$: a autoridade competente concedeu, para este principal, este sujeito e esta classe de efeito, agora;
  + $"Executada"(a)$: o efeito foi tentado pelo executor responsável e produziu um recibo;
  + $"Provada"(a)$: uma pós-condição observada independentemente confirma o efeito, e a evidência foi registrada.
] <def-estagios-acao>

Os estágios formam uma cadeia: cada um pressupõe os anteriores — não faz sentido perguntar se uma ação se aplica a um sujeito que ainda não foi resolvido. Escrevemos $"est"(a, kappa) in {0, 1, dots, 7}$ para o maior $k$ tal que os $k$ primeiros predicados valem com estatuto #est[provado]. A cadeia de qualificação dos portões (@sec-port-logica) refina os estágios 2 a 5.

#invariante(titulo: [Nenhum estágio implica o seguinte])[
  Existir não implica ser válida; ser válida não implica ser aplicável; ser aplicável não implica estar pronta; estar pronta não implica estar autorizada; estar autorizada não implica ter sido executada; ter sido executada não implica ter o efeito provado.
] <inv-estagios>

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Salto], [Falha característica]),
    [existe → executa], [executar uma operação porque ela está disponível na interface, sem resolver o sujeito nem verificar os parâmetros],
    [válida → executa], [executar uma ação bem formada que não se aplica ao objetivo corrente],
    [aplicável → executa], [executar uma transição cujas pré-condições não estão satisfeitas (por exemplo, promover sem evidência)],
    [pronta → executa], [executar sem autorização, porque "estava tudo pronto"],
    [autorizada → provada], [declarar sucesso porque a ação foi autorizada e disparada, sem observar o efeito],
    [executada → provada], [declarar sucesso porque o comando retornou zero, sem pós-condição independente],
  ),
  caption: [Saltos entre estágios e as falhas que produzem.],
) <tab-saltos>

#teorema(titulo: [Execuções governadas não pulam estágios])[
  Suponha que um sistema imponha, para cada estágio $k >= 2$, um portão que só permite registrar o estágio $k$ se o estágio $k - 1$ estiver registrado com estatuto #est[provado] e o predicado do estágio $k$ for avaliado como #est[provado] no momento do registro. Então, em toda execução, a sequência de estágios registrados de cada ação é um prefixo de $1, 2, dots, 7$, e nenhuma ação tem registrado o estágio $k$ sem ter registrados todos os anteriores.
] <teo-sem-saltos>

#prova[
  Por indução no número de registros. Inicialmente nenhum estágio está registrado (prefixo vazio). Suponha que, antes de um registro, os estágios registrados de $a$ formem um prefixo $1, dots, j$. O portão só permite registrar o estágio $k$ se $k - 1$ está registrado, isto é, se $k - 1 lt.eq j$; e registrar um estágio já registrado não altera o conjunto. Logo o único estágio novo possível é $j + 1$, e o conjunto continua sendo um prefixo.
]

O teorema garante a forma dos _registros_, não a validade simultânea dos estágios no instante do efeito: a prontidão pode ter sido registrada às 10h00, a autorização às 10h05, e uma delas ter deixado de valer quando o efeito ocorre às 10h10 (@inv-autoridade-tempo). A versão temporal exige invalidação.

#teorema(titulo: [Execuções governadas não pulam estágios nem os deixam expirar])[
  Suponha, além das hipóteses do @teo-sem-saltos, que (i) todo registro de estágio $j$ tenha uma janela de validade e seja _invalidado_ quando um fato posterior refuta seu predicado ou a janela expira, e (ii) invalidar o estágio $j$ invalide todos os estágios $k > j$. Então, em todo instante, os estágios _válidos_ de cada ação formam um prefixo, e o efeito só é registrado se os estágios 1 a 5 estiverem simultaneamente válidos no instante do registro.
] <teo-sem-saltos-temporal>

#prova[
  A invalidação de $j$ remove do conjunto de estágios válidos um sufixo ($j, j + 1, dots$), o que preserva a propriedade de prefixo; o registro de um estágio novo a preserva pelo @teo-sem-saltos, que exige o anterior válido. O registro do efeito (estágio 6) exige o estágio 5 válido e, pela propriedade de prefixo, todos os anteriores.
]

Os dois teoremas são simples porque as hipóteses fazem todo o trabalho: o difícil, em sistemas reais, é garantir que _não existe outro caminho_ para causar o efeito — que um agente não possa, por exemplo, editar um arquivo diretamente em vez de passar pela ação governada. Essa é a razão pela qual o @inv-mudanca-evidencia exige que toda mudança deixe evidência: caminhos não governados aparecem, então, como efeitos sem cadeia.

=== Prontidão é específica da transição

Um mesmo item de trabalho pode estar pronto para uma transição e não para outra. Uma unidade de trabalho existe e está aberta; isso não significa que esteja pronto para _receber uma mutação de código_, nem para _ser encerrado_, nem para _ter seu candidato promovido_. Cada transição tem seu conjunto de pré-condições.

#invariante(titulo: [Existir não é estar pronto para esta transição])[
  A prontidão é avaliada por par (item, transição). Um item que existe e está aberto pode estar pronto para uma transição e bloqueado para outra; a avaliação de prontidão deve declarar qual transição avaliou.
] <inv-prontidao-transicao>

#exercicios[
  + Para a ação "aplicar uma migração de banco de dados", descreva concretamente cada um dos sete predicados da @def-estagios-acao e a evidência que sustenta cada um.
  + Dê um exemplo de caminho não governado que permite causar um efeito sem passar pelos estágios, e explique como o @inv-mudanca-evidencia ajuda a detectá-lo.
  + Um item de trabalho está pronto para "registrar evidência" e não está pronto para "encerrar". Liste pré-condições plausíveis que expliquem a diferença.
]

== Qualificação em camadas <sec-acao-qualificacao>

Muitas ações nascem de uma _intenção declarada_: "o serviço $X$ deve estar na versão 3", "o agente $A$ deve ter leitura no espaço $W$". Antes de propor qualquer ação, é preciso comparar a intenção com a realidade observada. Essa comparação tem três camadas, que não devem ser fundidas.

#definicao(titulo: [Satisfação, reconciliabilidade e acionabilidade])[
  Dada uma intenção $phi$ sobre um sujeito e a realidade observada:
  - A _satisfação_ diz se a realidade já satisfaz $phi$: #estado[satisfeita], #estado[insatisfeita] ou #est[desconhecida].
  - A _reconciliabilidade_ diz se existe um _satisfator_ — uma ação tipada, com escopo exato, capaz de levar a realidade a satisfazer $phi$.
  - A _acionabilidade_ diz se, dado que existe um satisfator, as condições correntes (autoridade, atualidade, disponibilidade) permitem executá-lo agora.
] <def-qualificacao-camadas>

#invariante(titulo: [Satisfação desconhecida bloqueia a reconciliação])[
  Se a satisfação é #est[desconhecida], nenhuma ação de reconciliação é proposta: não se pode corrigir o que não se sabe estar errado. A primeira ação adequada é observar.
] <inv-satisfacao-desconhecida>

As três camadas têm consequências diferentes para o consumidor: uma intenção insatisfeita sem satisfator exige trabalho de projeto (criar o satisfator); uma intenção com satisfator e sem acionabilidade exige obter autoridade ou esperar disponibilidade; uma intenção com satisfator acionável pode virar proposta. Fundir as camadas — por exemplo, reportar "bloqueado" para todos esses casos — impede o consumidor de saber o que fazer.

#exercicios[
  + Para a intenção "o agente $A$ deve ter leitura no repositório $R$", descreva uma situação em cada uma das combinações: insatisfeita e não reconciliável; insatisfeita, reconciliável e não acionável; insatisfeita, reconciliável e acionável.
  + Explique por que propor uma ação de reconciliação sob satisfação desconhecida pode causar dano, com um exemplo.
  + Dê um exemplo em que uma ação é satisfazível, mas não reconciliável, e outro em que é reconciliável, mas não acionável. O que a perspectiva deve informar ao consumidor em cada caso?
]

== O laço de mutação governada <sec-acao-laco>

Combinando os estágios e a qualificação, obtemos a gramática geral de uma mudança governada.

#algoritmo("Mutação-Governada", params: $phi, kappa$, legenda: [O laço de mutação governada. Cada linha produz um artefato próprio; nenhuma é implícita.])[
  + $O <- $ #proc("Observa")$(kappa)$ #h(1fr) ▷ realidade corrente, com proveniência
  + $Delta <- $ #proc("Diferença")$(phi, O)$ #h(1fr) ▷ satisfação por componente
  + $Q <- $ #proc("Qualifica")$(Delta)$ #h(1fr) ▷ reconciliabilidade e acionabilidade
  + $p <- $ #proc("Propõe")$(Q)$ #h(1fr) ▷ pedido tipado, sem credencial
  + #kw[para cada] pedido de execução que referencia $p$ #kw[faça]
    + $O' <- $ #proc("Observa")$(kappa)$; $p' <- $ #proc("Propõe")$($#proc("Qualifica")$($#proc("Diferença")$(phi, O')))$ #h(1fr) ▷ re-resolução
    + #kw[se] $p'$ é vazio #kw[então] #kw[devolva] #estado[já satisfeito] #h(1fr) ▷ @inv-ja-satisfeito
    + #kw[se] $p' != p$ #kw[então] #kw[devolva] #estado[bloqueado: nova proposta necessária]
    + #kw[se] #proc("Autoriza")$(p', kappa) != $ #estado[concedida] #kw[então] #kw[devolva] #estado[não autorizado]
    + $r <- $ #proc("Executa-Se-Versão")$(p', "versão"(O'))$ #h(1fr) ▷ o dono do efeito recusa se a versão observada mudou
    + $c <- $ #proc("Observa-Pós-Condição")$(p')$ #h(1fr) ▷ canal independente
    + registre evidência $(p', r, c)$; #proc("Recompõe")$(kappa)$
] <alg-mutacao-governada>

Três decisões de projeto merecem justificativa — e uma quarta, sobre a janela entre observar e executar. A re-resolução da linha 6 reduz, mas não elimina, a condição de corrida entre verificação e uso: o mundo pode mudar entre as linhas 6 e 10. A solução clássica é a _escrita condicional_: o dono do efeito executa apenas se a versão do sujeito ainda é a observada (comparar-e-trocar sobre a versão), recusando caso contrário. É o que a linha 10 exige.

/ Propostas não são credenciais: a proposta $p$ é um pedido bem formado, com coordenada determinística derivada de (intenção, dono, sujeito, candidato, base de observação). Ela pode ser serializada e enviada, mas, quando chega o pedido de execução, o sistema _reconstrói_ a proposta a partir da realidade atual (linha 6) e compara. Uma proposta fornecida pelo cliente nunca é tratada como fato confiável: poderia estar obsoleta ou adulterada, e confiar nela reabre o problema do delegado confuso.

/ O executor é parametrizado pelo sujeito: o "dono do efeito" é um componente ligado a um sujeito exato no momento da composição — não um executor genérico que recebe "execute a operação $X$ sobre o identificador $Y$". O sujeito vem da realidade autoritativa, não do chamador.

/ A recomposição fecha o ciclo: depois do efeito, a perspectiva é recalculada; a proposta original, agora satisfeita, torna-se #estado[não aplicável]. Se o efeito falhou, a nova perspectiva mostra a intenção ainda insatisfeita, com a evidência da falha.

/ Correção e custo: o laço mantém o invariante de que nenhum efeito é executado sem que, na mesma iteração, (a) a proposta tenha sido reconstruída da realidade corrente (linha 6), (b) coincida com a que foi proposta (linha 8) e (c) tenha autorização concedida para ela (linha 9); o dono do efeito acrescenta (d) que a versão observada não mudou até a aplicação (linha 10). Logo todo efeito executado passou, na versão em que é aplicado, pelos estágios de existência a autorização do @teo-sem-saltos. Cada iteração termina se as chamadas a observação, autorização e efeito terminam — e elas têm prazo, cuja expiração devolve #est[desconhecido], que não executa nada. O custo por pedido é o de duas observações, duas diferenças e uma autorização, mais o próprio efeito; com intenção de $|phi|$ componentes e observação em tempo $T_"obs"$, é $O(T_"obs" + |phi| + T_"aut" + T_"ef")$. O laço é idempotente: repetido depois de um sucesso, a linha 7 devolve #estado[já satisfeito].

#principio(titulo: [Texto vira intenção, intenção vira plano, plano vira execução])[
  A saída de um modelo de linguagem nunca é executada diretamente. Ela é interpretada como intenção estruturada, que é qualificada e transformada num plano resolvido contra a realidade, que é executado por donos de efeito sob autorização. Nunca: texto → comando de shell.
] <pri-texto-plano>

#exercicios[
  + Por que a linha 8 do @alg-mutacao-governada compara a nova proposta com a antiga em vez de simplesmente executar a nova? Que informação seria perdida?
  + Descreva um ataque possível se o executor aceitasse o sujeito fornecido pelo chamador. Relacione com o problema do delegado confuso (@cap-autoridade).
  + Mostre que, se a observação da linha 6 falha (estado #est[desconhecido]), o algoritmo não executa nada. Que linha garante isso?
]

== Efeitos idempotentes e exatamente-uma-vez <sec-acao-efeitos>

Agentes repetem coisas: perdem a confirmação de uma chamada e tentam de novo; são reiniciados no meio de uma tarefa; recebem a mesma instrução por dois caminhos. Efeitos que não toleram repetição são uma fonte constante de dano.

#definicao(titulo: [Efeito de garantia])[
  Um _efeito de garantia_ $"garante"(s)$ leva o sujeito ao estado $s$: se o sujeito já está em $s$, não faz nada; caso contrário, aplica uma mudança que o leva a $s$ (a menor, segundo uma métrica de mudança declarada), sem alterar dimensões não relacionadas.
] <def-efeito-garantia>

#proposicao(titulo: [Efeitos de garantia são idempotentes])[
  Para todo estado inicial $x$, $"garante"(s)("garante"(s)(x)) = "garante"(s)(x) = s$ (restrito às dimensões de $s$).
] <prop-garantia-idempotente>

#prova[
  Após a primeira aplicação, o sujeito está em $s$; a segunda encontra o sujeito já em $s$ e, por definição, não faz nada.
]

Nem todo efeito pode ser expresso como garantia: enviar uma mensagem, cobrar um pagamento e criar um registro novo são efeitos cuja repetição é, ela própria, uma mudança. Para esses, usa-se uma _chave de idempotência_: antes de executar, o executor obtém um identificador de uso único associado à intenção; a execução consome a chave; uma segunda tentativa com a mesma chave é recusada. (Não confundir com a reserva de escrita do @cap-trabalho, que dá exclusividade sobre um escopo.)

#teorema(titulo: [Efeito único sobre o estado])[
  Suponha que: (i) pedidos de execução sejam entregues _pelo menos uma vez_ (podem ser repetidos, nunca perdidos indefinidamente); (ii) todo efeito seja de garantia ou protegido por uma chave de idempotência cujo consumo e o próprio efeito são confirmados _atomicamente_ pelo dono do efeito, na mesma transação do sistema que o sofre; e (iii) nenhuma outra intenção altere as mesmas dimensões do sujeito entre a primeira e a última entrega de um pedido — ou toda execução seja condicionada à versão observada na proposta. Então, para cada intenção, o estado final do sujeito é o mesmo que seria obtido com uma única execução.
] <teo-exatamente-uma-vez>

#prova[
  Para efeitos de garantia, repetições não alteram o estado (@prop-garantia-idempotente), e, por (iii), nenhuma intenção concorrente faz uma repetição tardia sobrescrever um estado posterior. Para efeitos com chave, a atomicidade de (ii) garante que no máximo uma execução consome a chave _e_ produz o efeito — não há execução que consuma sem produzir, nem que produza sem consumir —; as demais são recusadas sem efeito. Como a entrega é pelo menos uma vez, ao menos uma execução ocorre. Logo há exatamente um efeito por intenção.
]

As três hipóteses são necessárias. Sem (iii), intenções $"garante"(s_1)$ e $"garante"(s_2)$ entregues como $s_1, s_2, s_1$ terminam em $s_1$, embora a execução única de cada uma terminasse em $s_2$: idempotência não é comutatividade. Sem a atomicidade de (ii), uma execução que consome a chave e cai antes do efeito produz zero efeitos, e uma que produz o efeito e cai antes de registrar o consumo produz dois. É por isso que "exatamente uma vez" de ponta a ponta, entre sistemas independentes, exige a cooperação de quem recebe o efeito @helland2012.

#invariante(titulo: [Já satisfeito não é executar de novo])[
  Se a observação mostra que a intenção já está satisfeita, o resultado correto é "já satisfeito, nenhuma mudança", registrado como evidência — não uma nova execução.
] <inv-ja-satisfeito>

#exercicios[
  + Reescreva como efeitos de garantia: "adicionar o usuário $u$ ao grupo $g$"; "atualizar o serviço para a versão 3"; "criar o diretório $d$". Qual dos três tem uma armadilha (dimensões não relacionadas que podem ser alteradas)?
  + Proponha um esquema de reserva para "enviar um relatório semanal" que resista a reinícios do agente.
  + Mostre que o @teo-exatamente-uma-vez falha se a verificação da reserva não for atômica, construindo uma intercalação problemática de duas execuções.
]

== Prova de efeito <sec-acao-prova>

Três registros diferentes costumam ser confundidos depois de uma execução.

#definicao(titulo: [Recibo, pós-condição e evidência])[
  - O _recibo_ é o registro do que o executor _diz_ ter feito (o comando, os parâmetros, o código de retorno, a saída).
  - A _pós-condição_ é o estado do sujeito _observado independentemente_ depois do efeito, por um canal que não depende do relato do executor.
  - A _evidência_ é o registro governado, com proveniência, que associa a proposta, o recibo e a pós-condição.
] <def-recibo-poscondicao>

#invariante(titulo: [Sucesso do comando não é prova de efeito])[
  Um código de retorno de sucesso, uma mensagem "concluído" ou um relato do executor são recibos. A prova de efeito exige pós-condição observada por canal independente.
] <inv-sucesso-comando>

A razão é que executores — humanos, scripts ou agentes — otimizam localmente e relatam o que acreditam ter feito. Um agente que reporta "atualizei a configuração e o serviço voltou a funcionar" pode ter atualizado o arquivo errado, numa máquina errada, enquanto o serviço voltou por outra razão. Só a observação independente distingue.

=== Contra o excesso de alegação

Relatórios agregam: "a implantação está operacionalmente provada" resume dezenas de verificações. A regra para agregar é a mesma que vale para conjunções em lógica de informação parcial.

#definicao(titulo: [Sustentação de uma alegação conjuntiva])[
  Uma alegação agregada $A$ que depende conjuntivamente de $A_1, dots, A_n$ é _sustentada num nível $s$_ de uma escala ordenada se toda componente $A_i$ é sustentada no nível $s$ ou acima.
] <def-sustentacao-conjuntiva>

#proposicao(titulo: [O agregado não excede o mínimo])[
  (i) Numa escala de força totalmente ordenada — por exemplo, $"não testado" < "parcial" < "demonstrado"$ —, o maior nível em que $A$ é sustentada é o mínimo dos níveis das componentes. (ii) Com resultados de verificação mapeados em $K_3$ (aprovado ↦ $sans(V)$, reprovado ↦ $sans(F)$, os demais ↦ $sans(D)$, @tab-estados-verificacao), o estatuto de $A$ é a conjunção forte de Kleene das componentes — o ínfimo na ordem de _verdade_: $sans(F)$ se alguma componente é $sans(F)$, $sans(D)$ se nenhuma é $sans(F)$ e alguma é $sans(D)$, e $sans(V)$ só se todas são $sans(V)$.
] <lem-agregado-minimo>

#prova[
  (i) Pela @def-sustentacao-conjuntiva, $A$ é sustentada em $s$ se e somente se $s$ não excede o nível de nenhuma componente, isto é, $s lt.eq min_i "nível"(A_i)$. (ii) É a tabela da conjunção forte de Kleene (@sec-ap-kleene), que coincide com o ínfimo de $sans(F) < sans(D) < sans(V)$.
]

A parte (ii) liga esta proposição ao @teo-falha-fechado: um relatório agregado é um portão sobre suas componentes, e o ínfimo deve ser tomado na ordem de verdade — não na ordem de informação de Belnap, que é a ordem "padrão" do @cap-modelo e que, aqui, daria o resultado errado.

#antipadrao(titulo: [Veredito acima das partes])[
  Um relatório conclui "operacionalmente provado" enquanto, na sua própria tabela, dois subitens aparecem como "não testados" e um como "testado em ambiente diferente". O veredito foi calculado como impressão geral, não como ínfimo das partes.
] <anti-veredito-partes>

#exercicios[
  + Um agente relata: "migração aplicada (código 0), serviço reiniciado (código 0), testes de fumaça passaram". Quais desses itens são recibos e quais poderiam ser pós-condições? Que observação independente faltaria para provar o efeito?
  + Aplique a @lem-agregado-minimo a um relatório com cinco subitens de níveis demonstrado, demonstrado, parcial, demonstrado e não testado. Qual o estatuto do agregado?
  + Um comando de implantação retorna código 0, mas a versão em execução não mudou. Liste as observações que comprovariam o efeito e explique por que o recibo não basta.
]

== Separação de poderes <sec-acao-poderes>

O laço de mutação governada distribui funções entre papéis diferentes. Mantê-los separados é o que impede que um único componente — em particular, um único agente — transforme sua própria opinião em efeito sem verificação.

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Papel], [Função], [Não pode, por ser este papel]),
    [Titular], [decide objetivos e aceita resultados; concede autoridade], [ser substituído por recomendação de agente],
    [Supervisor], [revisa coerência, recomenda, propõe pacotes de trabalho], [autorizar ou executar],
    [Proponente], [qualifica intenções e produz propostas], [autorizar a própria proposta],
    [Autorizador], [avalia a proposta contra as regras do dono da autoridade], [executar],
    [Dono do efeito], [executa a transição exata sobre o sujeito exato], [escolher o sujeito por conta do chamador],
    [Observador], [verifica a pós-condição por canal independente], [ser o próprio executor, quando a independência importa],
  ),
  caption: [Papéis do laço governado. Um mesmo agente pode exercer papéis diferentes em momentos diferentes, mas nunca dois papéis em conflito sobre a mesma ação.],
) <tab-papeis-laco>

#invariante(titulo: [Recomendar, autorizar, executar])[
  Uma recomendação não é uma decisão; uma decisão não é uma execução. O titular pode autorizar algo diferente do recomendado, e o orquestrador não executa o que foi apenas recomendado.
] <inv-recomendar-executar>

A separação de poderes é a versão, para sistemas de agentes, da _separação de deveres_ das políticas de integridade comerciais @clark1987: nenhuma pessoa — ou agente — deve poder, sozinha, propor, aprovar e executar uma mudança que afete o que lhe interessa.

#exercicios[
  + Descreva um sistema de agentes em que o mesmo agente propõe, autoriza e executa. Que tipo de erro esse arranjo não consegue detectar?
  + Por que o observador da pós-condição não deve, em geral, ser o executor? Dê uma situação em que a coincidência é aceitável e justifique.
  + Proponha uma atribuição de papéis (recomendar, autorizar, executar) para um fluxo de atualização de dependências com dois agentes e um titular humano, e identifique o que acontece se o mesmo agente acumular dois papéis.
]

#quadro[
  - Sete estágios: existe, aplicável, válida, pronta, autorizada, executada, provada. Nenhum implica o seguinte; portões garantem que nenhum seja pulado (@teo-sem-saltos).
  - Prontidão é por par (item, transição).
  - Qualificação em camadas: satisfação, reconciliabilidade, acionabilidade; satisfação desconhecida bloqueia reconciliação.
  - Laço governado: observar, diferenciar, qualificar, propor, re-resolver, autorizar, executar, observar pós-condição, registrar evidência, recompor.
  - Propostas não são credenciais; executores são parametrizados pelo sujeito; texto nunca vira comando diretamente.
  - Efeitos de garantia e reservas de uso único dão exatamente-uma-vez sobre o estado.
  - Recibo não é pós-condição; sucesso do comando não é prova; o agregado não excede o mínimo das partes.
]

#problemas[
  #problema([Ações compostas])[
    Uma ação composta (por exemplo, "implantar a versão 3") consiste em subações (construir, publicar artefato, atualizar configuração, reiniciar, verificar).
    + Defina os estágios da ação composta em função dos estágios das subações.
    + Mostre que o estágio "provada" da composta exige o estágio "provada" de todas as subações necessárias.
    + Discuta como lidar com falhas parciais: que evidência registrar e qual deve ser o estado recomposto.
  ]
  #problema([Re-resolução e vivacidade])[
    No @alg-mutacao-governada, se o mundo muda frequentemente, a proposta reconstruída pode diferir da original a cada tentativa.
    + Mostre um cenário em que nenhuma execução jamais ocorre.
    + Proponha uma regra que garanta progresso sem abrir mão da re-resolução (por exemplo, propostas com tolerância declarada a certas mudanças).
    + Discuta os riscos de sua regra.
  ]
  #problema([Relatórios verificáveis])[
    Projete um formato de relatório de execução de agente que torne mecanicamente verificável o @lem-agregado-minimo.
    + Especifique os campos por subitem.
    + Escreva o procedimento que calcula o veredito permitido a partir dos subitens.
    + Mostre como o formato detecta o @anti-veredito-partes.
  ]
]

#notas[
  A separação entre plano, autorização e execução tem raízes na engenharia de sistemas críticos e no princípio de separação de privilégios de #ct(<saltzer1975>). A noção de pós-condição observada remete à lógica de Hoare @hoare1969 e ao projeto por contrato @meyer1992; a diferença aqui é que a pós-condição não é provada sobre o código, mas observada no mundo, por um canal independente. Efeitos idempotentes e reservas de uso único são técnicas clássicas de sistemas distribuídos para tolerar entregas repetidas @helland2007; o laço "observar, comparar, agir" sobre estado desejado é o mesmo dos controladores de reconciliação @burns2016, tratado no @cap-reconciliacao.

  A cadeia de sete estágios, a qualificação em camadas e o laço de mutação governada são propostas deste livro, que sistematizam práticas dispersas de engenharia de implantação e de controle de mudanças; a epígrafe resume a lição mais repetida dessas práticas.
]
