#import "/modelo/estilo.typ": *

= Um modelo formal de contexto <cap-modelo>

#epigrafe(fonte: [John McCarthy, 1993])[Nossa proposta é introduzir contextos como objetos abstratos, sobre os quais se pode raciocinar.]

Para estudar algoritmos com rigor, precisamos de um modelo da máquina que os executa; o modelo RAM cumpre esse papel em textos clássicos, abstraindo detalhes de hardware e preservando o que importa para custo e correção. Este capítulo apresenta o modelo correspondente para este livro: um modelo abstrato de _como o contexto de um agente é produzido, consumido e realimentado_. Ele é deliberadamente simples, mas preciso o bastante para que possamos enunciar invariantes, provar propriedades e reconhecer, em sistemas reais, onde uma propriedade foi violada.

O modelo descreve um ciclo. Existe um _acervo_ de asserções sobre o mundo, cada uma com proveniência e estatuto epistêmico. Um consumidor — um agente ou um humano — trabalha a partir de uma _coordenada_ que diz quem ele é, onde está, o que pretende e sob qual autoridade. Uma _projeção_ calcula, a partir do acervo e da coordenada, uma _perspectiva_: a parte do acervo que se aplica àquela coordenada, acompanhada do que se sabe que não se sabe, do que foi deixado de fora e de como expandir. Uma _renderização_ transforma a perspectiva em contexto — tokens numa janela. O consumidor age; a ação, se autorizada e executada, produz efeitos; os efeitos são observados; as observações tornam-se evidência; e a evidência atualiza o acervo. A @fig-ciclo resume o ciclo, e as seções seguintes o formalizam peça por peça.

#figure(
  diagram(
    spacing: (9mm, 7mm),
    node-stroke: 0.6pt + cor.primaria,
    node-fill: cor.tinta-def,
    node-corner-radius: 2pt,
    node((0, 0), [Acervo $Sigma_t$], name: <s>),
    node((1, 0), [Projeção $pi$], name: <p>),
    node((2, 0), [Perspectiva $P$], name: <P>),
    node((3, 0), [Renderização $rho$], name: <r>),
    node((3, 1), [Contexto $c$], name: <c>),
    node((2, 1), [Consumidor $M$], name: <m>),
    node((1, 1), [Ação governada], name: <a>),
    node((0, 1), [Evidência], name: <e>),
    node((1, -0.85), [Coordenada $kappa$], name: <k>, fill: white),
    edge(<s>, <p>, "-|>"),
    edge(<k>, <p>, "-|>"),
    edge(<p>, <P>, "-|>"),
    edge(<P>, <r>, "-|>"),
    edge(<r>, <c>, "-|>"),
    edge(<c>, <m>, "-|>"),
    edge(<m>, <a>, "-|>"),
    edge(<a>, <e>, "-|>"),
    edge(<e>, <s>, "-|>", label: [atualiza], label-side: left),
  ),
  caption: [O ciclo do contexto. A projeção depende do acervo e da coordenada; a perspectiva é renderizada em contexto; o consumidor propõe ações, que, se autorizadas e executadas, geram evidência que atualiza o acervo. Nenhuma seta vai da perspectiva ao acervo: perspectivas não escrevem.],
) <fig-ciclo>

== Por que um modelo <sec-modelo-porque>

Há três razões para insistir num modelo formal num campo que, à primeira vista, parece dominado por prática e experimentação.

A primeira é _vocabulário_. Termos como "memória", "contexto", "estado" e "conhecimento" são usados de maneira intercambiável na literatura e na prática de agentes de linguagem, e essa intercambialidade esconde distinções que causam falhas reais. Um agente que trata o resumo de uma sessão anterior como estado atual do sistema confundiu memória com prova; um sistema que exibe um grafo de dependências desenhado a partir de nomes de diretórios confundiu renderização com fonte de verdade. O modelo dá nomes distintos a coisas distintas.

A segunda é _invariância_. Boa parte do conhecimento acumulado sobre contexto toma a forma de distinções do tipo "$X$ não é $Y$": ler não é escrever; existir não é ser aplicável; estar resolvido não é estar selecionado; uma perspectiva não é uma autoridade. Num modelo formal, essas distinções tornam-se _invariantes_ — propriedades que um sistema correto preserva em todas as execuções — e podem ser verificadas.

A terceira é _análise_. Com um modelo, podemos perguntar quanto custa produzir um contexto suficiente, se há algoritmos eficientes para isso, e o que se pode garantir quando não há (@cap-selecao). Podemos também perguntar o que acontece quando vários consumidores compartilham um acervo, quando o acervo é distribuído, ou quando observações chegam fora de ordem.

O modelo abstrai deliberadamente quase tudo sobre o funcionamento interno do consumidor. Do modelo de linguagem, retemos apenas o que o @cap-llm estabeleceu: ele é uma função estocástica e sem estado do contexto, com janela limitada e eficácia dependente da composição. Isso é suficiente para tudo o que segue.

#exercicios[
  + Escolha um sistema de agentes que você conheça (um assistente de programação, um agente de pesquisa, um atendente automatizado). Identifique, nele, o que corresponde a cada nó da @fig-ciclo. Algum nó está ausente ou implícito?
  + Dê dois exemplos, de sua experiência, de falhas causadas por usar a mesma palavra para duas coisas distintas num sistema de software.
  + Escolha uma falha de agente que você presenciou e descreva-a usando apenas o vocabulário das seis peças do modelo (acervo, coordenada, projeção, perspectiva, renderização, consumidor). Em qual peça estava a falha?
]

== Recursos, identidades e asserções <sec-modelo-assercoes>

Começamos pelo mundo e pelo que dizemos dele.

#definicao(titulo: [Recursos e domínios de identidade])[
  Um _recurso_ é qualquer entidade sobre a qual se pode fazer afirmações: um repositório, uma revisão de código, um processo em execução, uma decisão, uma pessoa, um documento, um espaço de trabalho. Recursos são designados por _identificadores_, e cada identificador pertence a um _domínio de identidade_ (ou espaço de nomes) $N$; escrevemos $N:x$ para o identificador $x$ no domínio $N$. Dois identificadores de domínios diferentes podem designar o mesmo recurso, mas essa _equivalência_ é ela mesma uma afirmação que precisa de prova.
] <def-recurso>

A insistência em domínios de identidade não é pedantismo. Um mesmo repositório pode ter um identificador no serviço de hospedagem, outro no sistema de integração contínua, um caminho no sistema de arquivos de cada máquina onde está materializado e um nome informal usado pela equipe. O @cap-identidade mostra que tratar qualquer um desses como "a" identidade — em particular, tratar um _localizador_ como o caminho de diretório como identidade — produz uma família inteira de erros.

#definicao(titulo: [Asserção])[
  Uma _asserção_ é uma tupla
  $ a = (s, p, o, sigma, "prov", t_"obs", t_"reg", "fonte") $
  em que $s$ é o sujeito (um identificador), $p$ um predicado de um vocabulário fixo, $o$ o objeto (um identificador ou um valor), $sigma$ o _estatuto epistêmico_ da asserção, $"prov"$ sua _proveniência_ (de onde ela veio e com base em quê), $t_"obs"$ o instante a que a observação se refere, $t_"reg"$ o instante em que a asserção foi registrada no acervo e $"fonte"$ o agente ou sistema que a registrou. O triplo $"cont"(a) = (s, p, o)$ é o _conteúdo_ da asserção. Quando $o$ é um identificador, a asserção é uma _relação_ (uma aresta tipada de $s$ a $o$ com tipo $p$).
] <def-assercao>

#definicao(titulo: [Estatuto epistêmico])[
  O estatuto epistêmico de uma asserção é um elemento de
  $ cal(S) = {#est[desconhecido], #est[provado], #est[refutado], #est[conflitante]}, $
  ordenado pela _ordem de informação_ $scripts(lt.eq)_i$ em que #est[desconhecido] é o menor elemento, #est[conflitante] o maior, e #est[provado] e #est[refutado] são incomparáveis — o reticulado de informação do bireticulado $sans("FOUR")$ de Belnap (Apêndice B, @fig-ap-belnap). Lemos #est[provado] como "há suporte registrado e nenhum contra-suporte vigente", #est[refutado] como o simétrico, #est[conflitante] como "há suporte e contra-suporte" e #est[desconhecido] como "nenhum dos dois". #est[provado] não afirma que o suporte é forte: a força do suporte é uma dimensão separada (@def-estatuto-composto).
] <def-estatuto>

Duas observações sobre essa definição. Primeiro, #est[desconhecido] é um estatuto que uma asserção _registrada_ pode ter: o acervo pode conter a asserção "não se sabe se o serviço $X$ está em execução", que é diferente de o acervo nada conter sobre $X$. Distinguir o _desconhecido declarado_ da _ausência_ é a primeira de muitas aplicações da hipótese de mundo aberto (@sec-ap-mundo-fechado). Segundo, o estatuto não é a única dimensão epistêmica: uma asserção #est[provado] há três semanas pode ter deixado de ser verdadeira. A _atualidade_ (ou frescor) é tratada separadamente, pela combinação de $t_"obs"$ com uma política de validade (@cap-epistemologia).

#definicao(titulo: [Acervo])[
  Um _acervo_ no instante $t$ é um conjunto finito $Sigma_t = {a : t_"reg"(a) lt.eq t}$ de asserções, munido da estrutura de multigrafo tipado (@def-ap-multigrafo) induzida por suas relações. O acervo evolui apenas por _acréscimo_ de asserções: $Sigma_t subset.eq Sigma_(t')$ para $t lt.eq t'$. Uma asserção que deixa de valer não é apagada; é _suplantada_ por uma asserção posterior que a revoga, corrige ou torna histórica.
] <def-acervo>

Como o acervo pode conter várias asserções sobre o mesmo conteúdo — uma observação antiga e sua correção, duas fontes que discordam —, é preciso dizer qual estatuto o acervo _sustenta_ para um conteúdo. É isso que a definição seguinte faz, e é a ela que o axioma de honestidade (P4) se refere.

#definicao(titulo: [Suplantação e estatuto sustentado])[
  Uma relação de _suplantação_ $prec.curly subset.eq Sigma times Sigma$ (lida "$a'$ suplanta $a$", $a prec.curly a'$) é acíclica e só liga asserções com o mesmo conteúdo ou com conteúdos declarados incompatíveis. Para um conjunto $L subset.eq Sigma_t$ e um conteúdo $phi$, as asserções _vigentes_ sobre $phi$ em $L$ são
  $ "vig"_L (phi) = {a in L : "cont"(a) = phi "e não existe" a' in L "com" a prec.curly a'}, $
  e o _estatuto sustentado_ de $phi$ em $L$ é o supremo, na ordem de informação, dos estatutos vigentes,
  $ sigma_L (phi) = scripts(union.sq)_i {sigma(a) : a in "vig"_L (phi)}, $
  com $sigma_L (phi) = #est[desconhecido]$ quando o conjunto é vazio. Para um teto $alpha$, escrevemos $sigma_(Sigma, alpha) (phi) = sigma_("leg"_alpha (Sigma_t)) (phi)$, em que $"leg"_alpha (Sigma_t)$ é o conjunto das asserções legíveis sob $alpha$.
] <def-estatuto-sustentado>

O estatuto sustentado é calculado sobre o _legível_, e não sobre todo o acervo. A escolha é forçada: se fosse calculado sobre todo o acervo, um consumidor de teto baixo veria um estatuto #est[conflitante] produzido por uma refutação que ele não pode ler — um vazamento de informação acima do teto, que contraria a não interferência (@teo-nao-interferencia). O preço da escolha é que dois consumidores com tetos diferentes podem receber estatutos diferentes para o mesmo conteúdo, sem que nenhum dos dois seja enganado: a honestidade é relativa ao que cada um pode ler. Quando isso importa, a política de divulgação pode declarar, em $X$, que há informação retida que afeta o estatuto — uma desclassificação controlada.

#observacao(titulo: [Acréscimo e apagamento obrigatório])[
  A política de acréscimo convive mal com obrigações de apagamento — o direito de eliminação de dados pessoais previsto em leis de proteção de dados — e com segredos gravados por engano. A solução compatível com o modelo é a _redação_: uma asserção que suplanta a original, torna seu conteúdo ilegível sob qualquer teto (por exemplo, descartando a chave com que foi cifrado) e preserva apenas seu identificador, seu resumo criptográfico e uma proveniência mínima. Com redações, as propriedades de reprodutibilidade deste capítulo continuam valendo _módulo redação_. O @cap-higiene volta ao tema.
]

A política de acréscimo (_append-only_) é uma escolha de modelagem com consequências fortes, e é defensável por três argumentos: permite auditoria (sempre se pode perguntar o que se sabia em $t$); permite reprodutibilidade (uma perspectiva calculada em $t$ pode ser recalculada); e evita a destruição de proveniência (uma asserção revogada continua sendo a razão pela qual algo foi feito no passado). Implementações reais compactam acervos por razões de custo; o modelo exige apenas que a compactação preserve a capacidade de responder às perguntas de auditoria que se pretende responder (@cap-higiene).

#invariante(titulo: [O acervo não é o mundo])[
  O acervo contém _afirmações sobre_ o mundo, com estatuto e proveniência; não contém o mundo. Toda asserção pode estar desatualizada, e toda ausência de asserção é, salvo declaração explícita de completude, ausência de informação — não informação de ausência.
] <inv-acervo-nao-mundo>

#exercicios[
  + Escreva cinco asserções, no formato da @def-assercao, que descrevam o estado de um pequeno projeto de software: um repositório, sua revisão atual, um teste que passou, uma decisão de arquitetura e uma dúvida em aberto. Atribua a cada uma um estatuto e uma proveniência plausíveis.
  + Por que a @def-acervo exige que o acervo cresça por acréscimo? Descreva uma situação em que apagar uma asserção falsa impediria responder a uma pergunta legítima de auditoria.
  + Dê um exemplo de domínio em que a ausência de uma asserção pode legitimamente ser lida como negação. Que propriedade do processo de registro torna isso legítimo?
]

== Observação: declarado, observado e efetivo <sec-modelo-observacao>

O mundo tem, a cada instante, um estado $omega_t$ que nenhum agente observa por completo. O que agentes e sistemas fazem é _observar_ partes dele.

#definicao(titulo: [Observação])[
  Uma _observação_ é um procedimento $"obs"$ que, executado por uma fonte $f$ num locus $ell$ e instante $t$, produz um conjunto finito de asserções sobre $omega_t$, cada uma com proveniência que registra o procedimento, a fonte, o locus e o instante, e com uma _âncora_ — um artefato verificável que sustenta a asserção (a saída de um comando, um resumo criptográfico de um conteúdo, a referência a um registro).
] <def-observacao>

Para qualquer recurso de interesse, convém distinguir três "colunas" de informação, que raramente coincidem em sistemas reais.

- O estado _declarado_: o que configurações, registros e documentos afirmam que deveria ser. Exemplo: "o serviço usa o espaço de trabalho $A$".
- O estado _observado_: o que uma observação ancorada mostra que é. Exemplo: "o processo do serviço resolveu o espaço de trabalho $B$".
- O estado _efetivo_ para um consumidor: o que, de fato, entrou na perspectiva com a qual ele decidiu. Exemplo: "o agente agiu supondo $A$".

#principio(titulo: [Três colunas])[
  Para todo recurso relevante a uma decisão, mantenha distinguíveis o declarado, o observado e o efetivo. Divergências entre as colunas não são ruído a ser suprimido: são o principal sinal de que o contexto precisa de reconciliação.
] <pri-tres-colunas>

A @def-observacao também torna precisa uma noção que reaparecerá muitas vezes: uma asserção é _ancorada_ se sua proveniência termina numa observação com âncora verificável; é _derivada_ se foi inferida de outras asserções; e é _relatada_ se foi registrada por uma fonte que não fornece âncora (por exemplo, um resumo escrito por um agente). As três categorias não diferem em verdade, mas em _como se pode verificá-las_ — e, portanto, em quanto se deve confiar nelas quando entram em conflito (@cap-proveniencia).

#exercicios[
  + Para um serviço web de sua escolha, dê um exemplo de divergência entre declarado e observado, e outro de divergência entre observado e efetivo. Qual das duas é mais difícil de detectar? Por quê?
  + Classifique como ancorada, derivada ou relatada: (a) "os testes passaram", acompanhada do registro completo da execução; (b) "os testes passaram", escrita num resumo de sessão; (c) "a revisão $r$ contém a correção", inferida de "a correção foi integrada no ramo principal" e "$r$ é posterior à integração".
  + Uma ferramenta de monitoramento mostra que um serviço está "saudável". Escreva as três colunas (declarado, observado, efetivo) para o agente que vai decidir se reinicia o serviço, e indique qual coluna sustenta a decisão.
]

== Coordenadas <sec-modelo-coordenadas>

Um consumidor nunca precisa de todo o acervo. Precisa da parte que se aplica a ele, agora, para o que pretende fazer. O objeto que especifica "ele, agora, para isto" é a coordenada.

#definicao(titulo: [Coordenada contextual])[
  Uma _coordenada_ é uma tupla
  $ kappa = (u, ell, o, tau, t, alpha) $
  em que $u$ é o _consumidor_ (quem vai usar o contexto), $ell$ é o _locus_ (o domínio soberano a partir do qual se trabalha — por exemplo, um espaço de trabalho), $o$ é o _objetivo_ (o trabalho pretendido), $tau$ é a _transição_ considerada (a mudança de estado específica que o consumidor avalia, se houver), $t$ é o _instante de referência_ ("conforme o acervo em $t$") e $alpha$ é o _teto de autoridade_ (o conjunto máximo de permissões sob o qual o consumidor opera). Cada componente pode ser _não especificado_, o que denotamos por $bot$.
] <def-coordenada>

As coordenadas são parcialmente ordenadas por _especificidade_: $kappa scripts(lt.eq)_e kappa'$ se $kappa'$ especifica tudo o que $kappa$ especifica, com os mesmos valores, e possivelmente mais. Uma coordenada sem nenhum componente especificado é a mais geral; uma coordenada totalmente especificada descreve uma situação de decisão precisa. O refinamento é _plano_ em cada componente — um valor especificado só é refinado por ele mesmo —, inclusive no teto $alpha$, embora tetos sejam conjuntos: por decisão de projeto, trocar de teto é trocar de coordenada, e não refiná-la. Em consequência, as coordenadas formam um produto de domínios planos: duas coordenadas sempre têm ínfimo, mas só têm supremo quando são _compatíveis_ (não especificam valores diferentes para o mesmo componente).

A coordenada é o mecanismo central de _compressão por endereçamento_ que o @cap-compressao desenvolve. Quando dois participantes compartilham um acervo, transmitir uma coordenada rica — "a revisão $r$ é candidata; a linha de base aceita é $b$; a evidência $e$ sustenta $r$; o alvo remoto é $g$; tudo atual em $t$" — substitui centenas de mensagens de narrativa: o receptor não precisa reconstruir o estado a partir da história, porque a coordenada delimita exatamente o subgrafo relevante e o ponto não resolvido.

#exemplo(titulo: [Coordenada versus narrativa])[
  Um orquestrador precisa que outro agente continue um trabalho interrompido. Uma transferência narrativa diria: "estávamos corrigindo o problema de autenticação; tentamos duas abordagens; a segunda parecia funcionar, mas os testes de integração falharam ontem à noite; acho que é por causa da mudança de configuração". Uma transferência por coordenada diria: objetivo $o$ (corrigir a falha de autenticação descrita na decisão $d$); candidato $r_2$ (revisão); evidência $e_1$ (testes unitários aprovados em $r_2$) e $e_2$ (testes de integração reprovados em $r_2$, registro anexo); hipótese não verificada $h$ (a mudança de configuração $k$ causa a falha); transição considerada: promover $r_2$ — _bloqueada_ por $e_2$. A segunda forma é mais curta, é verificável item por item e torna explícito o que é fato e o que é hipótese.
] <ex-coordenada-narrativa>

Uma consequência importante da possibilidade de componentes não especificados é que coordenadas _parciais_ são legítimas. Um consumidor que acaba de ser iniciado pode conhecer seu locus, mas não seu objetivo; um agente que recebeu uma pergunta pode conhecer o objetivo, mas não o locus em que a resposta deve ser buscada. Em ambos os casos, a projeção continua definida: componentes $bot$ apenas tornam mais asserções indeterminadamente aplicáveis ($sans(D)$), e a perspectiva resultante declara essa indeterminação. O @cap-localizacao formaliza essa propriedade (@inv-coordenada-parcial).

#exercicios[
  + Mostre que a ordem de especificidade $scripts(lt.eq)_e$ é uma ordem parcial e que não é um reticulado: duas coordenadas com o mesmo consumidor e objetivos diferentes não têm supremo. Caracterize os pares que têm supremo.
  + Reescreva, na forma de coordenada, uma mensagem de passagem de turno que você tenha recebido ou escrito. O que se perdeu? O que se ganhou?
  + Por que o teto de autoridade $alpha$ faz parte da coordenada, e não do consumidor? Dê um exemplo em que o mesmo consumidor opera com tetos diferentes.
]

== Aplicabilidade e seleção <sec-modelo-aplicabilidade>

Dada uma coordenada, nem toda asserção do acervo se aplica. A noção de aplicabilidade separa o que existe do que importa aqui.

#definicao(titulo: [Aplicabilidade])[
  Uma _relação de aplicabilidade_ é uma função $"apl": Sigma times K -> {sans(V), sans(F), sans(D)}$ que, para cada asserção e coordenada, diz se a asserção se aplica à coordenada ($sans(V)$), não se aplica ($sans(F)$) ou se isso não pode ser determinado com a informação disponível ($sans(D)$). O _subacervo aplicável_ é $Sigma|_kappa = {a in Sigma : "apl"(a, kappa) = sans(V)}$.
] <def-aplicabilidade>

Exigimos que a aplicabilidade seja _monótona em especificidade_ na ordem de informação de Kleene ($sans(D) scripts(lt.eq)_k sans(V)$ e $sans(D) scripts(lt.eq)_k sans(F)$; Apêndice B): se $kappa scripts(lt.eq)_e kappa'$, então $"apl"(a, kappa) scripts(lt.eq)_k "apl"(a, kappa')$. Especificar mais a coordenada pode resolver um $sans(D)$ em $sans(V)$ ou em $sans(F)$, mas nunca inverte um valor já determinado; em particular, a coordenada inteiramente não especificada é a que tem mais asserções de aplicabilidade $sans(D)$.

#observacao(titulo: [Anotações ortogonais não são valores de verdade])[
  Aplicabilidade, atualidade, autoridade de leitura e divulgação são _anotações_ de uma asserção relativas a uma coordenada; não são valores de verdade. Uma asserção #est[provado] pode ser inaplicável, desatualizada para uma pergunta ou retida para um consumidor — e continua #est[provado]. Codificar essas anotações como valores adicionais do estatuto ("provado-mas-velho", "falso-aqui") mistura eixos independentes e torna impossível raciocinar sobre cada um separadamente. O @cap-working-set desenvolve essa separação como eixos ortogonais de estado.
]

A aplicabilidade é o lugar formal de uma série de distinções que, na prática, são frequentemente confundidas.

#invariante(titulo: [Existir, resolver, aplicar, selecionar])[
  Para um item de trabalho $w$, escreva $"apl"(w, kappa)$ para a aplicabilidade da asserção que declara o escopo de $w$. As propriedades
  + $w$ _existe_ (há asserções sobre $w$ no acervo);
  + $w$ _resolve_ (o identificador de $w$ designa inequivocamente um recurso);
  + $w$ _se aplica_ a $kappa$ ($"apl"(w, kappa) = sans(V)$);
  + $w$ está _selecionado_ em $kappa$ (é o valor do componente de objetivo e transição da coordenada);
  formam uma cadeia de condições necessárias — selecionado ⇒ aplica-se ⇒ resolve ⇒ existe —, e nenhuma das implicações recíprocas vale.
] <inv-existir-selecionar>

#antipadrao(titulo: [Inventário tomado por seleção])[
  Um sistema lista todos os itens de trabalho abertos (inventário) e, ao não encontrar nenhum _selecionado_ para a coordenada corrente, informa ao consumidor que "não há trabalho ativo" — ou, pior, recomenda iniciar trabalho novo. Na realidade, havia trabalho em andamento noutro locus, ou trabalho aberto mas não aplicável àquela coordenada. A informação correta era: "nenhum trabalho selecionado aqui; existe trabalho observável noutro lugar; resolva o locus antes de criar trabalho novo".
] <anti-inventario-selecao>

O antipadrão ilustra um fenômeno sutil e recorrente: o sistema _sabia_ a verdade — a lista de itens existia, a aplicabilidade fora calculada corretamente — mas a _descreveu_ mal. Perspectivas corretas mal renderizadas são uma classe inteira de falhas, tratada nos @cap-perspectiva e @cap-apresentacao.

#exercicios[
  + Construa um exemplo com três itens de trabalho e duas coordenadas em que: um item existe mas não resolve; outro resolve mas não se aplica; o terceiro se aplica mas não está selecionado.
  + Prove que, se $"apl"$ é monótona em especificidade, então $kappa scripts(lt.eq)_e kappa'$ implica $Sigma|_(kappa') without Sigma|_kappa subset.eq {a : "apl"(a, kappa) = sans(D)}$.
  + Mostre que uma condição mais fraca — "se $"apl"(a, kappa') = sans(V)$, então $"apl"(a, kappa) != sans(F)$" — admitiria uma aplicabilidade que declara tudo aplicável na coordenada vazia e inaplicável nas específicas. Por que isso é indesejável?
  + Reescreva a mensagem do @anti-inventario-selecao de forma que ela seja verdadeira e acionável, sem expor ao consumidor mais detalhes do que ele precisa.
]

== Perspectivas e projeção <sec-modelo-perspectiva>

Chegamos ao objeto central do modelo.

#definicao(titulo: [Perspectiva])[
  Uma _perspectiva_ para a coordenada $kappa$ é uma tupla
  $ P = (F, R, U, X, Phi, mu) $
  em que $F$ é um conjunto de asserções sobre recursos (os _fatos_ apresentados), $R$ um conjunto de relações entre eles, $U$ um conjunto de _desconhecidos explícitos_ (perguntas relevantes cuja resposta é #est[desconhecido]), $X$ uma _declaração de exclusões_ (o que existe e se aplica, mas não foi incluído, descrito ao menos por contagem e categoria), $Phi$ a _fronteira_ (um conjunto de _alças de expansão_, cada uma uma coordenada mais específica ou uma referência resolúvel que permite obter mais informação) e $mu$ os _metadados_ (instante de referência, teto de autoridade, cobertura, e a proveniência da própria perspectiva).
] <def-perspectiva>

#definicao(titulo: [Projeção])[
  Uma _projeção_ é uma função $pi$ que, dados um acervo $Sigma$ e uma coordenada $kappa$, produz uma perspectiva $pi(Sigma, kappa)$.
] <def-projecao>

Exigimos que projeções satisfaçam seis propriedades. Elas formam o núcleo axiomático do modelo; os capítulos seguintes as refinam e mostram como implementá-las.

#axioma(titulo: [P1 — Somente leitura])[
  Calcular $pi(Sigma, kappa)$ não altera $Sigma$. Uma perspectiva é uma _composição de leitura_: não é autoridade, não é evidência e não é registro de estado.
] <ax-somente-leitura>

#axioma(titulo: [P2 — Determinismo])[
  $pi$ é uma função: o mesmo acervo e a mesma coordenada produzem a mesma perspectiva. Em particular, uma perspectiva é reprodutível a partir de $(Sigma_t, kappa)$.
] <ax-determinismo>

#axioma(titulo: [P3 — Limitação por autoridade])[
  Toda asserção em $F union R union U$ e toda alça em $Phi$ é legível sob o teto de autoridade $alpha$ de $kappa$. Asserções ilegíveis sob $alpha$ não aparecem, nem direta nem indiretamente — mas sua _existência_ pode ser declarada em $X$ quando a política de divulgação o permitir.
] <ax-autoridade>

#axioma(titulo: [P4 — Honestidade epistêmica])[
  Para todo conteúdo $phi$ apresentado em $P$ com estatuto $sigma_P (phi)$, vale $sigma_P (phi) in {sigma_(Sigma, alpha) (phi), #est[desconhecido]}$, em que $sigma_(Sigma, alpha)$ é o estatuto sustentado sobre o legível (@def-estatuto-sustentado); e, quando o estatuto é composto (@def-estatuto-composto), a força e a base apresentadas não excedem as que o acervo registra. Uma perspectiva pode _omitir_ informação — apresentando-a como desconhecida, com a omissão declarada —, mas nunca _altera_ estatuto: não apresenta como #est[provado] o que o acervo só sustenta como #est[desconhecido], não apresenta ausência como refutação, e não apresenta um conflito (#est[conflitante]) mostrando apenas um de seus lados.
] <ax-honestidade>

#axioma(titulo: [P5 — Omissão declarada])[
  Toda asserção legível sob $alpha$ com $"apl"(a, kappa) in {sans(V), sans(D)}$ está em $F union R$, ou está contabilizada em $X$, ou é alcançável a partir de alguma alça de $Phi$; as de aplicabilidade $sans(D)$ são marcadas como tais. Nada aplicável — nem possivelmente aplicável — desaparece silenciosamente.
] <ax-omissao>

#axioma(titulo: [P6 — Estabilidade sob reprojeção])[
  Seja $Sigma_P = F union R union hat(X) union hat(Phi)$, em que $hat(X)$ e $hat(Phi)$ são asserções-registro que descrevem as exclusões e as alças de $P$. Então $pi(Sigma_P, kappa)$ coincide com $P$ em $(F, R, U, X, Phi)$ e nos campos de $mu$ que não identificam o acervo de origem.
] <ax-estabilidade>

Esses axiomas capturam, de forma compacta, várias das distinções mais importantes do livro. P1 diz que uma perspectiva não é autoridade. P3 diz que ver não é poder ler tudo. P4 diz que resumir não é mentir. P5 diz que omitir não é esconder. P2 e P6 dizem que uma perspectiva é um objeto estável, que se pode comparar, armazenar e transferir.

#invariante(titulo: [Perspectiva não é autoridade])[
  Nenhuma ação é autorizada _por estar presente_ numa perspectiva. A autorização de uma ação é decidida contra o acervo e as regras de autoridade, no momento da ação; a perspectiva informa a proposta da ação, nunca a legitima.
] <inv-perspectiva-autoridade>

Provamos agora algumas consequências simples, mas úteis.

#proposicao(titulo: [Idempotência])[
  Se $pi$ satisfaz P6, então a operação $Sigma mapsto Sigma_(pi(Sigma, kappa))$ é idempotente: aplicá-la duas vezes produz o mesmo acervo restrito que aplicá-la uma vez.
] <prop-idempotencia>

#prova[
  Seja $P = pi(Sigma, kappa)$. Por P6, $pi(Sigma_P, kappa)$ coincide com $P$ nos componentes que determinam $Sigma_P$; logo $Sigma_(pi(Sigma_P, kappa)) = Sigma_P$.
]

Em linguagem de teoria das ordens, P6 diz que a operação $Sigma mapsto Sigma_(pi(Sigma, kappa))$ é uma _retração_ sobre sua imagem; a @prop-idempotencia é a expressão desse fato.

#proposicao(titulo: [Monotonicidade em autoridade])[
  Seja $pi$ uma projeção sem orçamento (todo o aplicável legível vai para $F union R$) que calcula estatutos sobre o legível (@def-estatuto-sustentado). Se $kappa$ e $kappa'$ diferem apenas no teto, com $alpha subset.eq alpha'$, então (i) todo conteúdo apresentado em $pi(Sigma, kappa)$ também é apresentado em $pi(Sigma, kappa')$; e (ii) seu estatuto em $pi(Sigma, kappa')$ é maior ou igual, na ordem de informação, ao estatuto em $pi(Sigma, kappa)$ — _desde que_ nenhuma asserção legível só sob $alpha'$ suplante uma asserção legível sob $alpha$. O conjunto de desconhecidos não é monótono: o esperado é que ele diminua quando o teto cresce.
] <prop-monotonia-autoridade>

#prova[
  A legibilidade é definida por inclusão em $alpha$, logo $"leg"_alpha (Sigma) subset.eq "leg"_(alpha') (Sigma)$, e, como a aplicabilidade não depende do teto, (i) segue. Para (ii), sem suplantação nova, $"vig"_L (phi)$ só cresce com $L$, e o supremo de um conjunto maior é maior ou igual (@prop-ap-belnap-semirreticulado). Com suplantação nova, $"vig"$ pode perder elementos, e o estatuto pode mudar em qualquer direção.
]

A proposição tem duas ressalvas que a prática encontra. Uma projeção que preenche um orçamento fixo de tokens pode, ao ganhar acesso a asserções mais relevantes, deixar de fora asserções que antes incluía — por isso o enunciado supõe ausência de orçamento; com orçamento, as omissões devem aparecer em $X$ ou em $Phi$ (P5). E a suplantação, que torna a vigência uma negação sobre o próprio acervo, quebra a monotonicidade dos estatutos — a mesma não monotonicidade que o @cap-perspectiva discute.

O resultado mais importante desta seção é uma propriedade de _não interferência_ no sentido de @goguen1982: o que está fora da autoridade do consumidor não pode influenciar o que ele vê — exceto pelo que a política de divulgação decide revelar, como contagens de itens retidos. Esse "exceto" tem nome na literatura de fluxo de informação: _desclassificação_ @sabelfeld2009.

#definicao(titulo: [Não interferência com desclassificação])[
  Uma projeção $pi$ é _não interferente sob $alpha$ módulo $delta$_ se, para todos os acervos $Sigma, Sigma'$ com $"leg"_alpha (Sigma) = "leg"_alpha (Sigma')$ e $delta(Sigma) = delta(Sigma')$, vale $pi(Sigma, kappa) = pi(Sigma', kappa)$, em que $delta$ é a função de desclassificação autorizada pela política de divulgação (por exemplo, contagens de retidos por categoria).
] <def-nao-interferencia>

#teorema(titulo: [Projeções fatoradas são não interferentes])[
  $pi$ é não interferente sob $alpha$ módulo $delta$ se, e somente se, existe uma função $g$ tal que $pi(Sigma, kappa) = g("leg"_alpha (Sigma), delta(Sigma), kappa)$ para todo $Sigma$. Em particular, se todo índice, cache ou resumo consultado por $pi$ é calculado a partir de $"leg"_alpha (Sigma)$ e de $delta(Sigma)$, então $pi$ é não interferente.
] <teo-nao-interferencia>

#prova[
  Se $pi$ se fatora por $g$, acervos com o mesmo legível e a mesma desclassificação produzem a mesma perspectiva, que é a definição. Reciprocamente, se $pi$ é não interferente, defina $g(L, d, kappa) = pi(Sigma, kappa)$ para qualquer $Sigma$ com $"leg"_alpha (Sigma) = L$ e $delta(Sigma) = d$; a não interferência garante que $g$ está bem definida, e a fatoração vale por construção. A segunda parte decorre da primeira: uma composição de funções do legível e de $delta$ é função do legível e de $delta$.
]

O teorema transforma uma propriedade semântica em uma propriedade estrutural verificável: basta examinar de que dados cada componente da projeção depende. O difícil, na prática, é garantir a fatoração: projeções reais consultam índices, caches e resumos que podem ter sido calculados com autoridade maior que a do consumidor, e assim vazar, por exemplo, a _forma_ de um conteúdo que ele não poderia ler. O @cap-autoridade trata desses canais.

#exercicios[
  + A ordem de informação de Belnap coloca #est[provado] abaixo de #est[conflitante]. Mostre que uma versão de P4 que exigisse apenas $sigma_P (a) scripts(lt.eq)_i sigma_Sigma (a)$ permitiria apresentar um conflito como #est[provado], e explique por que isso seria desonesto. Com a versão adotada, uma projeção pode apresentar o conflito como #est[desconhecido]? Discuta se isso é desejável.
  + Construa uma projeção que satisfaça P1–P4 mas viole P5. Descreva uma falha que ela causaria.
  + Dê um exemplo concreto em que uma projeção com orçamento fixo viola a monotonicidade em autoridade, e mostre como P5 mitiga o problema.
  + #avancado Formule e prove uma versão da @prop-monotonia-autoridade para a ordem de especificidade de coordenadas.
]

== Renderização e contexto <sec-modelo-renderizacao>

Uma perspectiva é um objeto estruturado; o modelo de linguagem consome uma sequência de tokens. A renderização faz a ponte.

#definicao(titulo: [Renderização])[
  Uma _renderização_ é uma função $rho$ que, dados uma perspectiva $P$, um orçamento $B lt.eq W$ de tokens e um perfil de consumidor $u$, produz um contexto $c = rho(P, B, u)$ com $|c| lt.eq B$. A renderização é _honesta_ se: (i) todo conteúdo apresentado em $c$ o é com seu estatuto em $P$ ou com #est[desconhecido] e a omissão declarada; (ii) toda asserção de $F union R$ não apresentada em $c$ é contabilizada numa declaração de exclusão presente em $c$; (iii) toda exclusão de $X$ e toda alça de $Phi$ não apresentadas são contabilizadas numa declaração resumida presente em $c$; e (iv) nenhum segmento é apresentado com função diferente da que tem em $P$ (por exemplo, um dado apresentado como instrução).
] <def-renderizacao>

#lema(titulo: [Composição de honestidades])[
  Se a projeção $pi$ satisfaz P4 e P5 e a renderização $rho$ é honesta, então o contexto $rho(pi(Sigma, kappa), B, u)$ não promove o estatuto de nenhuma asserção em relação ao acervo e não omite silenciosamente nenhuma asserção aplicável e legível.
] <lem-composicao-honesta>

#prova[
  Para o estatuto: pela cláusula (i) da honestidade de $rho$, $sigma_c (phi) in {sigma_P (phi), #est[desconhecido]}$; por P4, $sigma_P (phi) in {sigma_(Sigma, alpha) (phi), #est[desconhecido]}$; logo $sigma_c (phi) in {sigma_(Sigma, alpha) (phi), #est[desconhecido]}$ — em particular, $sigma_c (phi) scripts(lt.eq)_i sigma_(Sigma, alpha) (phi)$, e nenhum estatuto é alterado além da omissão. Para a omissão: por P5, toda asserção aplicável e legível está em $F union R$, em $X$ ou alcançável por $Phi$; pela cláusula (ii), o que de $F union R$ não couber no orçamento é declarado como exclusão, e, pela (iii), o que de $X$ ou $Phi$ não couber é declarado de forma resumida. Logo nada desaparece sem declaração.
]

A renderização é apenas um dos pontos em que o contexto se reduz. Entre o universo de informação potencialmente disponível e aquilo que o modelo efetivamente usa ao decidir, há uma _cadeia de restrição_ sobre conjuntos de asserções: o ambiente observado; o legível sob o teto de autoridade; o aplicável à coordenada; o selecionado sob orçamento; o efetivamente entregue; e, por fim, o consumido. Cada redução é imposta por um operador distinto — aquisição, filtro de autoridade, aplicabilidade, seleção, transporte e atenção do consumidor — e cada uma tem suas falhas próprias. A ordem importa: filtrar por autoridade _antes_ de selecionar é condição para a não interferência, porque a seleção sob orçamento compara itens entre si, e um item ilegível que consumisse orçamento influenciaria quais itens legíveis sobrevivem. A divulgação não é um elo da cadeia, mas a decisão sobre o que se _declara_ a respeito do que ficou fora do legível. O @cap-ambiente formaliza a cadeia (@def-cadeia-restricao); por ora, basta notar que a honestidade exigida de $pi$ e de $rho$ precisa valer em _cada_ elo: um elo que omite sem declarar anula a honestidade dos demais.

#invariante(titulo: [A renderização não é fonte de verdade])[
  Um contexto renderizado — um texto, uma tabela, um grafo desenhado — é uma _apresentação_ de relações evidenciadas, nunca um registro delas. Nenhuma asserção nova é criada pelo ato de renderizar; se a renderização sugere uma relação que a perspectiva não contém (por exemplo, por proximidade visual ou por agrupamento), a sugestão é um defeito da renderização.
] <inv-renderizacao-verdade>

O invariante merece um exemplo. Uma ferramenta que desenha a arquitetura de um sistema agrupando, numa mesma caixa, todos os repositórios que estão num mesmo diretório, _afirma visualmente_ uma relação de pertinência que pode não existir. Se um agente, depois, raciocina a partir do desenho ("esses serviços pertencem ao mesmo domínio, logo compartilham credenciais"), a renderização tornou-se fonte de verdade sem que ninguém tenha decidido isso. A regra correta é _aresta antes de linha_: primeiro existe a relação tipada, com proveniência, no acervo; só depois existe a linha no desenho.

#exercicios[
  + Dê um exemplo de renderização desonesta que não altera nenhum estatuto, mas sugere uma relação inexistente pela forma de apresentação.
  + Uma perspectiva contém 40 fatos, mas o orçamento comporta apenas 15. Escreva o trecho de contexto que uma renderização honesta deveria incluir sobre os 25 restantes.
  + Explique por que a função de cada segmento (instrução, evidência, memória, sugestão) é parte do que uma renderização honesta deve preservar, relacionando com o @pri-contexto-nao-comando.
]

== O consumidor, a ação e o fechamento do ciclo <sec-modelo-acao>

O consumidor recebe o contexto e produz uma saída. No caso de um agente, a saída pode conter _propostas de ação_: modificar um arquivo, executar uma implantação, abrir um item de trabalho, enviar uma mensagem. O modelo distingue rigorosamente a _proposta_ de uma ação de sua _execução_.

#definicao(titulo: [Ação governada])[
  Uma _ação governada_ é uma transição proposta $tau$ sobre o mundo ou sobre o acervo que só é executada se um conjunto de _portões_ — predicados avaliados contra o acervo, a coordenada e as regras de autoridade, no momento da execução — for satisfeito com estatuto #est[provado]. Toda execução produz _evidência_: asserções ancoradas sobre o que foi feito e sobre seus efeitos observados.
] <def-acao-governada>

O @cap-ciclo-acao decompõe o caminho entre proposta e efeito numa cadeia de estágios — a ação existe, é aplicável, é estruturalmente válida, está pronta, está autorizada, foi executada, teve seu efeito provado — e mostra que confundir quaisquer dois estágios adjacentes produz uma classe característica de falha. Por ora, basta notar como o ciclo da @fig-ciclo se fecha: a evidência produzida pela execução é acrescentada ao acervo, $Sigma_(t+1) = Sigma_t union E_t$, e o próximo cálculo de perspectiva a incorpora. Um sistema em que ações não geram evidência é um sistema cujo acervo diverge silenciosamente do mundo.

#invariante(titulo: [Toda mudança deixa evidência])[
  Nenhuma transição executada sob governança deixa de produzir evidência ancorada no acervo. A ausência de evidência sobre uma ação executada é, ela própria, uma anomalia a ser registrada.
] <inv-mudanca-evidencia>

#exercicios[
  + Descreva uma ação comum de um agente de programação (por exemplo, "corrigir um teste") como uma ação governada: qual é a transição, quais portões seriam razoáveis, e que evidência a execução deveria produzir?
  + O que acontece com as perspectivas futuras se um agente executa ações fora da governança (por exemplo, editando arquivos diretamente, sem registro)? Relacione com o @pri-tres-colunas.
  + Mostre que, se toda execução produz evidência (@inv-mudanca-evidencia) e o acervo cresce por acréscimo, então é sempre possível responder, depois, "que ações alteraram o recurso $x$ entre $t_1$ e $t_2$". Que hipótese adicional sobre a identidade de $x$ é necessária?
]

== Suficiência, minimalidade e honestidade <sec-modelo-suficiencia>

Podemos agora dar significado preciso à frase que resume a engenharia de contexto: _compor o menor contexto verdadeiro suficiente_.

#definicao(titulo: [Necessidades de informação e respondibilidade])[
  As _necessidades de informação_ de uma coordenada $kappa$ são um conjunto finito $Q(kappa)$ de perguntas cuja resposta o consumidor precisa conhecer (ou saber que não conhece) para decidir bem. Uma perspectiva $P$ _responde_ a pergunta $q$ se a resposta de $q$, com seu estatuto, é derivável de $F union R union U$ por regras de inferência fixadas.
] <def-necessidades>

#definicao(titulo: [Suficiência e minimalidade])[
  Uma perspectiva $P$ é _suficiente_ para $kappa$ se responde toda pergunta de $Q(kappa)$ com o mesmo estatuto com que o acervo inteiro (restrito ao legível sob $alpha$) a responderia. É _minimal_ se nenhuma perspectiva obtida removendo-se uma asserção de $F union R$ continua suficiente (minimalidade por remoção unitária; com respostas não monótonas — remover uma refutação pode levar #est[conflitante] a #est[provado] — ela não implica minimalidade por inclusão). É _mínima_, em relação a uma função de tamanho (por exemplo, tokens após renderização), se nenhuma perspectiva suficiente é menor.
] <def-suficiencia>

A definição de suficiência é estrita num ponto importante: uma perspectiva que responde #est[provado] a uma pergunta que o acervo só sustenta como #est[desconhecido] não é suficiente — é desonesta. E uma perspectiva que responde #est[desconhecido] a uma pergunta que o acervo sustenta como #est[provado] também não é suficiente — é incompleta. Suficiência é _fidelidade epistêmica_ restrita às necessidades.

Há uma tensão inevitável entre suficiência e tamanho. O @cap-selecao prova que encontrar uma perspectiva suficiente de tamanho mínimo é NP-difícil, mesmo em versões muito simplificadas do problema, e que nem sequer é possível aproximar o mínimo eficientemente a menos de um fator $(1 - epsilon) ln n$, salvo P = NP @dinur2014. Esse resultado negativo orienta toda a estratégia do livro: em vez de procurar o contexto ótimo, construímos perspectivas _suficientes por construção_ — por meio de coordenadas que delimitam o aplicável, fronteiras que tornam o resto alcançável, e desconhecidos explícitos que tornam honesta a incompletude — e medimos empiricamente sua adequação.

#exercicios[
  + Para a coordenada "decidir se a revisão $r$ pode ser promovida", proponha um conjunto $Q(kappa)$ de cinco a oito perguntas. Quais delas costumam ser esquecidas na prática?
  + Mostre que a interseção de duas perspectivas suficientes não é necessariamente suficiente.
  + Mostre que toda perspectiva suficiente contém uma perspectiva minimal suficiente, e que perspectivas minimais podem ter tamanhos muito diferentes.
]

== As quatro disciplinas <sec-modelo-disciplinas>

O modelo permite delimitar com precisão as quatro disciplinas que dão subtítulo a este livro. Elas não são fases sequenciais, mas responsabilidades distintas sobre partes diferentes do ciclo.

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Disciplina], [Objeto no modelo], [Pergunta central]),
    [Gerenciamento], [O acervo $Sigma$: identidade, proveniência, evidência, estatuto, atualidade, autoridade, ciclo de vida], [O que é verdade, de onde veio, ainda vale, e quem responde por ela?],
    [Engenharia], [A projeção $pi$: seleção e composição dado consumidor, objetivo e transição], [Qual é o menor conjunto verdadeiro suficiente para esta coordenada?],
    [Design], [A estrutura de $P$ e a renderização $rho$: o que aparece, o que fica expansível, como desconhecidos e exclusões são mostrados, que affordances o consumidor recebe], [Como esta perspectiva deve ser apresentada para ser usada corretamente?],
    [Administração], [O ciclo de ações e a evolução de $Sigma$: portões, unidades de trabalho, reconciliação, higiene, ambientes], [Como o sistema muda sem perder a verdade, e quem autoriza cada mudança?],
  ),
  caption: [As quatro disciplinas do contexto e seus objetos no modelo formal.],
) <tab-disciplinas>

Cada disciplina tem uma tentação característica, que convém nomear desde já:

- o gerenciamento de contexto não é um _navegador de acervo_: guardar tudo e permitir busca não garante que se saiba o que é verdade;
- a engenharia de contexto não é um _montador de prompts_: concatenar trechos relevantes não garante suficiência nem honestidade;
- o design de contexto não é um _grafo bonito_: uma apresentação agradável que sugere relações inexistentes é pior do que nenhuma;
- a administração de contexto não é _burocracia_: portões e ciclos existem porque tornam o contexto mais preciso e mais barato, ao delimitar o que cada consumidor precisa considerar.

A última afirmação é uma tese do livro, e os capítulos da Parte V a sustentam com argumentos e casos: governança bem desenhada é um mecanismo de _compressão contextual_, porque coordenadas governadas eliminam enormes porções do espaço de interpretações possíveis.

#exercicios[
  + Para cada linha da @tab-disciplinas, dê um exemplo de decisão de projeto num sistema de agentes que pertence àquela disciplina e um exemplo de decisão que parece pertencer a ela mas pertence a outra.
  + Explique a tese de que "governança bem desenhada é compressão contextual" com um exemplo em que uma regra de governança reduz o número de interpretações possíveis de uma situação.
  + #avancado Proponha um critério para decidir se uma nova técnica de contexto (por exemplo, um novo método de compressão de prompts) pertence a uma das quatro disciplinas ou atravessa várias. Aplique-o a três técnicas da literatura.
]

#quadro[
  - O modelo tem seis peças: acervo, coordenada, projeção, perspectiva, renderização e consumidor, ligadas num ciclo fechado pela evidência (@fig-ciclo).
  - Asserções têm estatuto epistêmico no reticulado de informação de Belnap; o estatuto que o acervo sustenta é calculado sobre as asserções vigentes e legíveis (@def-estatuto-sustentado); o desconhecido declarado é diferente da ausência.
  - Coordenadas delimitam o aplicável; aplicabilidade é distinta de existência, resolução e seleção (@inv-existir-selecionar).
  - Projeções satisfazem seis axiomas: somente leitura, determinismo, limitação por autoridade, honestidade, omissão declarada e estabilidade.
  - Perspectivas não são autoridade; renderizações não são fonte de verdade; toda mudança deixa evidência.
  - Suficiência é fidelidade epistêmica restrita às necessidades; encontrar a perspectiva mínima é intratável, por isso construímos suficiência por estrutura.
]

#problemas[
  #problema([Perspectivas para consumidores diferentes])[
    O mesmo acervo é consumido por um humano titular, por um agente orquestrador e por um agente executor com teto de autoridade restrito.
    + Escreva as coordenadas dos três consumidores para um mesmo objetivo.
    + Descreva como as perspectivas devem diferir, e em que devem coincidir, para que uma decisão tomada a partir de uma possa ser verificada a partir de outra.
    + Mostre que, se as três projeções satisfazem P4 _e têm o mesmo teto de autoridade_, nenhuma delas pode apresentar como #est[provado] algo que outra apresente como #est[refutado]. Construa um contraexemplo com tetos diferentes e discuta o que a política de divulgação deve declarar nesse caso.
  ]
  #problema([Acervo com compactação])[
    Implementações reais não guardam todas as asserções para sempre.
    + Proponha uma operação de compactação $"comp": Sigma -> Sigma'$ que remova asserções suplantadas há mais de $Delta$ unidades de tempo.
    + Defina formalmente o conjunto de perguntas de auditoria que $"comp"$ preserva e o que ela destrói.
    + Mostre que uma projeção que satisfaz P2 sobre $Sigma$ pode deixar de satisfazê-lo "ao longo do tempo" se o acervo for compactado entre dois cálculos com o mesmo $(t, kappa)$, e proponha uma correção.
  ]
  #problema([Honestidade sob orçamento extremo])[
    Suponha um orçamento $B$ tão pequeno que nem as declarações resumidas de exclusão cabem.
    + Mostre que, nesse caso, nenhuma renderização pode ser honesta no sentido da @def-renderizacao.
    + Proponha uma versão degradada de honestidade que ainda seja útil (por exemplo, um único marcador de "contexto truncado" com uma alça de expansão).
    + #avancado Formalize o menor orçamento $B_"min"(P)$ para o qual existe renderização honesta de $P$ e dê limites superior e inferior em função de $|X|$ e $|Phi|$.
  ]
]

#notas[
  A ideia de tratar contextos como objetos formais remonta a #ct(<mccarthy1993>), que propôs a fórmula $"ist"(c, p)$ — "a proposição $p$ é verdadeira no contexto $c$" — e a uma tese de #ct(<guha1991>); a computação ubíqua, por sua vez, popularizou uma noção de contexto como informação sobre a situação de uma entidade @dey2001. O modelo deste capítulo é mais próximo, em espírito, da teoria de bancos de dados: perspectivas são _visões_ calculadas, e a exigência de que sejam somente leitura reflete décadas de dificuldade com o problema de atualização por visões @bancilhon1981 @foster2007; a manutenção incremental de visões materializadas @gupta1995 é o análogo técnico do recálculo de perspectivas quando o acervo muda. A exigência de honestidade epistêmica é uma forma de correção de abstração no sentido da interpretação abstrata @cousot1977, aplicada à ordem de informação de #ct(<belnap1977>). A propriedade de não interferência é de #ct(<goguen1982>); sua versão com desclassificação e a segurança de fluxo de informação baseada em linguagens são revisadas em #ct(<sabelfeld2003>) e #ct(<sabelfeld2009>); a limitação por autoridade segue a tradição de controle de acesso de #ct(<lampson1974>) e #ct(<saltzer1975>). A distinção entre o instante a que um fato se refere e o instante em que foi registrado é a dos bancos de dados bitemporais @snodgrass1999.

  A distinção entre declarado, observado e efetivo tem paralelo nos controladores de reconciliação de orquestradores de contêineres @burns2016, em que o estado desejado é declarado e um laço observa o estado real e age para aproximá-los. A separação entre perceber, compreender e projetar, central para a teoria de consciência situacional de #ct(<endsley1995>), oferece outra leitura do ciclo da @fig-ciclo do ponto de vista de um operador humano. Os modelos de proveniência W3C PROV @prov2013 fornecem um vocabulário padronizado compatível com as asserções da @def-assercao.
]
