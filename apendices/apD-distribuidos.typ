#import "/modelo/estilo.typ": *

= Sistemas distribuídos <ap-distribuidos>

Contexto de agentes é, quase sempre, informação distribuída: o acervo de um domínio, as materializações em vários nós, os serviços que observam ambientes, os agentes que trabalham em paralelo. Este apêndice reúne os conceitos de sistemas distribuídos usados no livro — ordem causal, relógios lógicos, cortes consistentes, modelos de consistência, o teorema CAP, tipos de dados replicados sem conflito, consenso e arrendamentos, e laços de reconciliação. A apresentação é deliberadamente compacta e autocontida — alguns conceitos, como a ordem causal e os cortes consistentes, aparecem também no @cap-tempo, aplicados à atualidade do contexto —; as notas ao final indicam tratamentos completos.

== Modelo de sistema <sec-ap-modelo-sistema>

Um _sistema distribuído_ é modelado como um conjunto finito de processos $p_1, dots, p_n$ que se comunicam apenas por troca de mensagens. Cada processo executa uma sequência de _eventos_: eventos internos, envios e recebimentos. Não há relógio global: cada processo pode ter um relógio físico, mas os relógios de processos diferentes não estão perfeitamente sincronizados, e as mensagens têm atrasos arbitrários (no modelo _assíncrono_) ou limitados por uma constante conhecida (no modelo _síncrono_).

Processos podem falhar. No modelo de _falha por parada_, um processo falho simplesmente para; no modelo _bizantino_, pode se comportar arbitrariamente. Canais podem perder, duplicar ou reordenar mensagens, conforme a hipótese adotada.

Para os fins deste livro, a consequência mais importante do modelo é simples: _nenhum processo observa o estado global instantaneamente_. Todo conhecimento sobre outros processos é conhecimento sobre o passado deles, transmitido por mensagens.

== Ordem causal e relógios lógicos <sec-ap-relogios>

#definicao(titulo: [Aconteceu-antes])[
  A relação _aconteceu-antes_ $->$ entre eventos é a menor relação transitiva tal que: (i) se $a$ e $b$ são eventos do mesmo processo e $a$ ocorre antes de $b$, então $a -> b$; (ii) se $a$ é o envio de uma mensagem e $b$ é o seu recebimento, então $a -> b$. Eventos $a$ e $b$ são _concorrentes_ ($a parallel b$) se nem $a -> b$ nem $b -> a$.
] <def-ap-aconteceu-antes>

A relação é uma ordem parcial estrita sobre os eventos (Apêndice A). Ela captura a _causalidade potencial_: $a -> b$ significa que $a$ pode ter influenciado $b$.

#definicao(titulo: [Relógio de Lamport])[
  Um _relógio de Lamport_ atribui a cada evento $e$ um inteiro $C(e)$ segundo as regras: cada processo incrementa seu contador antes de cada evento; cada mensagem carrega o valor do contador do remetente; ao receber uma mensagem com valor $m$, o receptor ajusta seu contador para $max(c, m) + 1$.
] <def-ap-lamport>

#teorema(titulo: [Condição do relógio])[
  Se $a -> b$, então $C(a) < C(b)$.
] <teo-ap-condicao-relogio>

#prova[
  Por indução na derivação de $a -> b$. No caso (i), o contador do processo é incrementado entre $a$ e $b$. No caso (ii), o receptor ajusta seu contador para um valor maior que o carregado pela mensagem, que é $C(a)$. A transitividade preserva a desigualdade estrita.
]

A recíproca é falsa: $C(a) < C(b)$ não implica $a -> b$. Relógios de Lamport dão uma ordem total compatível com a causalidade (desempatando por identificador de processo), mas não detectam concorrência.

#definicao(titulo: [Relógio vetorial])[
  Um _relógio vetorial_ atribui a cada evento $e$ um vetor $V(e) in bb(N)^n$. O processo $p_i$ incrementa a componente $i$ antes de cada evento; mensagens carregam o vetor do remetente; ao receber, o receptor toma o máximo componente a componente e depois incrementa sua componente. Vetores são comparados componente a componente: $V <= W$ se $V_k <= W_k$ para todo $k$, e $V < W$ se $V <= W$ e $V != W$.
] <def-ap-vetorial>

#teorema(titulo: [Caracterização da causalidade])[
  Para eventos $a$ e $b$, $a -> b$ se e somente se $V(a) < V(b)$. Em consequência, $a parallel b$ se e somente se $V(a)$ e $V(b)$ são incomparáveis.
] <teo-ap-vetorial>

#prova[
  ($=>$) Como no @teo-ap-condicao-relogio, cada passo da derivação de $a -> b$ preserva $<=$ componente a componente e incrementa ao menos uma componente. ($<==$) Seja $a$ um evento de $p_i$. A componente $V(b)_i$ só pode ser maior ou igual a $V(a)_i$ se a informação do evento $a$ (ou de um evento posterior de $p_i$) chegou a $b$ por uma cadeia de mensagens e eventos locais — isto é, se $a -> b$ ou $a = b$. Como $V(a) < V(b)$ implica $V(a)_i <= V(b)_i$ e $V(a) != V(b)$, temos $a -> b$.
]

Relógios vetoriais são a base de mecanismos de detecção de conflito em sistemas replicados: duas atualizações com vetores incomparáveis são concorrentes, e nenhuma pode ser escolhida como "a mais recente" sem uma regra adicional — exatamente a situação que o livro trata como conflito a expor (@cap-reconciliacao).

#exercicios[
  + Construa uma execução com três processos em que $C(a) < C(b)$ mas $a parallel b$.
  + Por que o tamanho de um relógio vetorial é proporcional ao número de processos? Que alternativas existem quando o número de processos é grande ou dinâmico?
]

== Cortes consistentes e instantâneos <sec-ap-cortes>

#definicao(titulo: [Corte consistente])[
  Um _corte_ é um conjunto de eventos que contém, para cada processo, um prefixo de sua sequência de eventos. O corte $K$ é _consistente_ se, para todo evento $b in K$ e todo evento $a$ com $a -> b$, vale $a in K$ — isto é, o corte é fechado para baixo na ordem causal.
] <def-ap-corte>

Um corte consistente corresponde a um estado global que _poderia_ ter sido observado instantaneamente por um observador ideal: nenhuma mensagem aparece recebida sem ter sido enviada.

#teorema(titulo: [Cortes consistentes formam um reticulado])[
  O conjunto dos cortes consistentes de uma execução, ordenado por inclusão, é um reticulado em que o ínfimo é a interseção e o supremo é a união.
] <teo-ap-reticulado-cortes>

#prova[
  A interseção e a união de prefixos por processo são prefixos por processo. Se $K_1$ e $K_2$ são fechados para baixo, a interseção e a união também são: se $b in K_1 union K_2$, então $b in K_j$ para algum $j$, e todo $a -> b$ está em $K_j$.
]

O algoritmo de #ct(<chandy1985>) obtém um instantâneo consistente sem parar o sistema: um processo iniciador registra seu estado e envia marcadores por todos os canais; cada processo, ao receber o primeiro marcador, registra seu estado e propaga marcadores; o estado de cada canal é o conjunto de mensagens recebidas depois do registro do estado local e antes do marcador daquele canal. Supondo canais FIFO, o estado registrado corresponde a um corte consistente.

No livro, cortes consistentes sustentam a discussão de _visões não atômicas_ (@cap-tempo): uma perspectiva composta de observações feitas em momentos diferentes, em processos diferentes, é coerente se as observações formam um corte consistente — ou se a pergunta que ela responde é insensível às diferenças.

#exercicios[
  + Dê um exemplo de corte inconsistente e explique por que nenhum observador poderia vê-lo.
  + Por que o algoritmo de Chandy–Lamport supõe canais FIFO? O que pode dar errado sem essa hipótese?
]

== Modelos de consistência <sec-ap-consistencia>

Quando dados são replicados, leitores diferentes podem ver versões diferentes. Um _modelo de consistência_ especifica que resultados de leitura são admissíveis.

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Modelo], [Garantia informal]),
    [linearizabilidade @herlihy1990], [cada operação parece ocorrer instantaneamente em algum ponto entre sua invocação e sua resposta; a ordem respeita o tempo real],
    [consistência sequencial @lamport1979], [existe uma ordem total das operações, compatível com a ordem de cada processo, que explica todas as leituras],
    [consistência causal @ahamad1995], [operações causalmente relacionadas são vistas na mesma ordem por todos; operações concorrentes podem ser vistas em ordens diferentes],
    [causal com convergência @lloyd2011], [consistência causal e, além disso, réplicas que viram as mesmas escritas estão no mesmo estado],
    [consistência eventual @vogels2009], [na ausência de novas escritas, todas as réplicas acabam convergindo para o mesmo valor],
    [garantias de sessão @terry1994], [ler as próprias escritas; leituras monotônicas; escritas monotônicas; escritas seguem leituras],
  ),
  caption: [Modelos de consistência. As cinco primeiras linhas vão do mais forte ao mais fraco, exceto que a consistência causal e a eventual são incomparáveis: a causal não exige convergência, e a eventual não exige ordem; a causal com convergência implica ambas. As garantias de sessão são propriedades por cliente, ortogonais à escala; juntas, as quatro implicam a consistência causal vista por aquele cliente.],
) <tab-ap-consistencia>

As garantias de sessão são particularmente relevantes para agentes: um agente que gravou uma decisão e, na leitura seguinte, não a vê (violação de "ler as próprias escritas") pode refazer o trabalho ou tomar decisões contraditórias.

=== O teorema CAP

#teorema(titulo: [CAP])[
  Num sistema replicado sujeito a partições de rede, não é possível garantir simultaneamente consistência linearizável e disponibilidade (toda requisição a uma réplica não falha recebe resposta).
] <teo-ap-cap>

#prova[
  Esboço @gilbert2002: suponha uma partição que separa as réplicas em dois grupos sem comunicação. Uma escrita é feita num grupo; em seguida, uma leitura é feita no outro. Se o sistema é disponível, a leitura recebe resposta; como não houve comunicação, a resposta não pode refletir a escrita, violando a linearizabilidade.
]

O teorema não diz que se deve escolher "dois de três" de uma vez por todas: diz que, _durante uma partição_, é preciso escolher entre responder (possivelmente com dados antigos) e não responder; fora dela, ambas as propriedades são alcançáveis, e a escolha pode ser feita por operação @brewer2012. Para sistemas de contexto, a escolha tem uma tradução direta: responder com dados possivelmente antigos é aceitável _se o estatuto e a atualidade forem declarados_ (@cap-tempo); responder com dados antigos apresentados como atuais não é.

#exercicios[
  + Classifique, na @tab-ap-consistencia, o comportamento de um cache de projeções com invalidação por tempo.
  + Mostre um cenário em que a violação de "leituras monotônicas" leva um agente a uma decisão errada.
]

== Tipos de dados replicados sem conflito <sec-ap-crdt>

#definicao(titulo: [CRDT baseado em estado])[
  Um _tipo de dados replicado sem conflito_ (CRDT) baseado em estado é um tipo cujos estados formam um semirreticulado de supremo $(S, ⊔)$, cujas atualizações são infladoras ($s <= u(s)$) e cuja fusão de réplicas é o supremo.
] <def-ap-crdt>

#teorema(titulo: [Convergência forte])[
  Num CRDT baseado em estado, suponha que cada atualização seja aplicada apenas na réplica de origem e que as réplicas troquem _estados_, fundindo-os pelo supremo. Chame de _estado de origem_ o estado produzido na réplica de origem imediatamente após uma atualização. Então o estado de cada réplica é o supremo de um conjunto de estados de origem, e duas réplicas que incorporaram — diretamente ou por fusões transitivas — os mesmos estados de origem estão no mesmo estado, quaisquer que sejam a ordem e as repetições das fusões.
] <teo-ap-crdt>

#prova[
  Por indução no número de passos de uma réplica. Inicialmente, seu estado é $bot$, o supremo do conjunto vazio. Se o estado é $s = ⊔ S$ e ocorre uma atualização local, o novo estado de origem é $s' = u(s) >= s$, e $s' = s ⊔ s' = ⊔ (S union {s'})$. Se ocorre a fusão com um estado recebido $t = ⊔ T$, o novo estado é $s ⊔ t = ⊔ (S union T)$. Logo o estado é sempre o supremo de um conjunto de estados de origem. Como o supremo é comutativo, associativo e idempotente, o resultado depende apenas do conjunto @shapiro2011.
]

A hipótese de que se transmitem _estados_ é essencial. Aplicar as mesmas _operações_ em ordens diferentes não converge em geral, porque atualizações infladoras não precisam comutar: sobre $(bb(N), max)$, as atualizações $s |-> max(s, 5)$ e $s |-> s + 1$, a partir de $0$, dão $6$ numa ordem e $5$ na outra. CRDTs baseados em operações exigem, por isso, que operações concorrentes comutem e que a entrega seja causal — a mesma distinção, no @cap-reconciliacao, entre convergência por estado e por deltas (@teo-crdt).

Exemplos: o conjunto que só cresce (fusão por união), o contador que só cresce (vetor de contadores por réplica, fusão por máximo componente a componente), registros com "última escrita vence" (que, note-se, descartam silenciosamente escritas concorrentes — o oposto do que se deseja para asserções com estatuto). O acervo por acréscimo do livro é um conjunto que só cresce e, portanto, um CRDT. Um registro de estatuto com fusão pelo supremo na ordem de informação de Belnap também é: o supremo de evidências contraditórias é #est[conflitante], não uma escolha (@prop-ap-belnap-semirreticulado). O que _não_ é um CRDT é o estatuto _vigente_ sob suplantação: uma asserção nova pode retirar outra do conjunto vigente, e o estatuto sustentado pode então descer na ordem de informação — de #est[provado] para #est[desconhecido], quando a evidência é suplantada sem substituta. A suplantação é infladora no acervo, mas não no estatuto; por isso o livro replica o acervo e recalcula o estatuto, em vez de replicar o estatuto.

#exercicios[
  + Mostre que o registro "última escrita vence" é um CRDT e explique por que ele é inadequado para asserções com estatuto epistêmico.
  + Projete um CRDT para um conjunto que admite remoções (dica: guarde marcas de remoção).
  + Dê uma sequência de asserções acrescentadas a um acervo em que o estatuto vigente de uma afirmação passa de #est[provado] a #est[desconhecido]. Por que isso não contradiz a convergência do acervo?
]

== Consenso, impossibilidade e arrendamentos <sec-ap-consenso>

Várias construções do livro supõem uma operação atômica de "comparar e trocar" sobre um registro compartilhado — a gênese federada (@teo-genese), as fichas de cerca (@prop-fichas-cerca), a reivindicação de trabalho. Implementar tal registro de forma replicada e tolerante a falhas é resolver o _consenso_: fazer processos concordarem sobre um valor proposto por algum deles.

#teorema(titulo: [Impossibilidade de Fischer, Lynch e Paterson])[
  No modelo assíncrono, se ao menos um processo pode falhar por parada, nenhum protocolo determinístico de consenso garante, em todas as execuções, acordo, validade e terminação.
] <teo-ap-flp>

A prova @fischer1985 mostra que todo protocolo tem uma configuração inicial _bivalente_ — da qual ambas as decisões ainda são alcançáveis — e que, a partir de uma configuração bivalente, o escalonador adversário pode sempre atrasar uma mensagem de modo a permanecer bivalente. A saída prática é enfraquecer o modelo: sob _sincronia parcial_ — existe um instante, desconhecido, a partir do qual os atrasos são limitados @dwork1988 —, protocolos como Paxos @lamport1998 e Raft @ongaro2014 garantem acordo e validade sempre, e terminação depois que o sistema se estabiliza. Para o livro, a lição é que a _segurança_ de uma decisão pode ser garantida incondicionalmente, e o _progresso_, não; um sistema de contexto que não consegue decidir deve declarar #est[desconhecido], não escolher.

Uma alternativa mais barata ao consenso, para exclusão mútua, é o _arrendamento_ @gray1989: o concedente dá a um titular o direito exclusivo sobre um recurso por um prazo $L$, sem precisar revogá-lo explicitamente.

#teorema(titulo: [Exclusão por arrendamento sob deriva limitada])[
  Suponha que os relógios do concedente e do titular tenham taxa de deriva limitada por $rho < 1$: um intervalo real $Delta$ é medido entre $(1 - rho) Delta$ e $(1 + rho) Delta$. O titular começa a contar ao _enviar_ o pedido e considera o arrendamento válido enquanto seu tempo local decorrido for menor que $L' = L (1 - rho) \/ (1 + rho)$; o concedente começa a contar ao conceder e não concede o recurso a outro antes de seu tempo local decorrido atingir $L$. Então nunca há dois titulares válidos simultâneos.
] <teo-ap-arrendamento>

#prova[
  Sejam $T_r$ o instante real do pedido e $T_g >= T_r$ o da concessão. O titular usa o arrendamento no máximo até o instante real $T_r + L' \/ (1 - rho)$, pois seu relógio mede ao menos $(1 - rho)$ do tempo real. O concedente não concede a outro antes do instante real $T_g + L \/ (1 + rho)$, pois seu relógio mede no máximo $(1 + rho)$ do tempo real. Com $L' = L(1 - rho)\/(1 + rho)$, temos $T_r + L'\/(1 - rho) = T_r + L\/(1 + rho) <= T_g + L\/(1 + rho)$.
]

O teorema tem duas hipóteses que costumam falhar. A deriva limitada é razoável para relógios de hardware, mas não para relógios ajustados por sincronização, que podem saltar. E o teorema não cobre _pausas_ do processo titular entre verificar o arrendamento e agir — uma coleta de lixo, uma suspensão da máquina virtual —, que são atrasos sem limite. Por isso, o arrendamento garante exclusão no tempo, mas o efeito sobre o recurso precisa ser protegido por fichas de cerca (@prop-fichas-cerca): o recurso rejeita operações com ficha menor que a maior já vista.

#exercicios[
  + Explique por que o teorema FLP não contradiz a existência de protocolos de consenso usados em produção.
  + No @teo-ap-arrendamento, por que o titular começa a contar ao enviar o pedido, e não ao receber a concessão?
  + Com $rho = 10^(-4)$ e $L = 10$ s, calcule $L'$. Que margem adicional você daria para pausas do processo, e por que nenhuma margem é suficiente sem fichas de cerca?
]

== Laços de reconciliação <sec-ap-reconciliacao>

Sistemas de orquestração de contêineres popularizaram um padrão de controle em que o sistema não executa comandos imperativos, mas reconcilia continuamente um _estado desejado_ declarado com o _estado observado_ @burns2016.

#algoritmo("Laço-de-Controle", params: $d$, legenda: [Laço de controle por reconciliação para um estado desejado $d$.])[
  + #kw[repita]
    + observe o estado $o$ do recurso
    + #kw[se] $o$ satisfaz $d$ #kw[então] registre convergência e aguarde mudança
    + #kw[senão] calcule uma ação $a$ que aproxima $o$ de $d$ e execute-a
] <alg-ap-reconcilia>

O padrão tem três propriedades úteis: é _idempotente_ (repetir o laço com o estado já convergido não faz nada); é _robusto a falhas_ (se uma ação falha, a próxima iteração observa o estado real e tenta de novo); e _separa declaração de execução_. O livro o adota para a convergência de ambientes e execuções (@cap-runtime, @cap-reconciliacao), acrescentando o que o padrão básico não tem: estatuto epistêmico para a observação (a observação pode ser desconhecida), autoridade para a ação e evidência para a convergência.

#exercicios[
  + Por que o @alg-ap-reconcilia é preferível a "executar a sequência de comandos que leva ao estado desejado"?
  + O que o laço deve fazer quando a observação retorna #est[desconhecido]? Justifique.
]

#notas[
  A relação aconteceu-antes e os relógios lógicos são de #ct(<lamport1978>); os relógios vetoriais, de #ct(<fidge1988>) e #ct(<mattern1989>); os instantâneos consistentes, de #ct(<chandy1985>). A linearizabilidade é de #ct(<herlihy1990>); a consistência eventual é discutida por #ct(<vogels2009>), e as garantias de sessão, por #ct(<terry1994>). O teorema CAP, conjecturado por Brewer, foi provado por #ct(<gilbert2002>), e reexaminado pelo próprio Brewer em #ct(<brewer2012>). A consistência sequencial é de #ct(<lamport1979>); a memória causal, de #ct(<ahamad1995>); a consistência causal com convergência, de #ct(<lloyd2011>). A impossibilidade do consenso assíncrono é de #ct(<fischer1985>); a sincronia parcial, de #ct(<dwork1988>); Paxos e Raft, de #ct(<lamport1998>) e #ct(<ongaro2014>); os arrendamentos, de #ct(<gray1989>). Os CRDTs são de #ct(<shapiro2011>). Os laços de reconciliação de orquestradores são descritos por #ct(<burns2016>). #ct(<kleppmann2017>) é um tratamento acessível e abrangente desses temas na perspectiva de sistemas de dados.
]
