#import "/modelo/estilo.typ": *

= Federação e autoridade distribuída <cap-federacao>

#epigrafe[O servidor pode cadastrar o domínio; não pode tomá-lo.]

Quando o contexto atravessa fronteiras de soberania — um agente de uma equipe consulta o domínio de outra; uma decisão depende de atestações de três domínios; um serviço central avalia autoridade em nome de vários domínios —, surgem problemas que não existem dentro de um único domínio. Quem atesta o quê? Como uma autoridade central pode servir domínios soberanos sem se tornar dona deles? Como um principal se autentica em domínios diferentes? Como compor afirmações cujas partes vêm de fontes que não se coordenam?

Este capítulo trata da federação — composição de significado entre domínios soberanos — e da autoridade distribuída. A @sec-fed-significado distingue federação de significado de sincronização de estado. A @sec-fed-dominios trata de domínios de autoridade, resolvedores e chaves. A @sec-fed-bilateral formaliza a vinculação bilateral como máquina de estados. A @sec-fed-principal trata de principais portáveis e dos tempos de vida das credenciais. A @sec-fed-raiz trata de gênese, rotação e recuperação. A @sec-fed-atestacoes trata da composição de atestações federadas. A @sec-fed-falapor apresenta a lógica de "fala por" como fundamento formal da delegação.

== Federação de significado, não de estado <sec-fed-significado>

#definicao(titulo: [Federação de significado])[
  Uma _federação_ entre domínios soberanos é um arranjo em que conhecimento atravessa fronteiras — referências, atestações, projeções exportadas — sem que a autoridade atravesse. Cada domínio continua sendo a fonte de suas verdades; o que outro domínio recebe é uma observação, com proveniência, do que o primeiro afirma.
] <def-federacao>

#invariante(titulo: [Federação de significado não é sincronização de estado])[
  Importar informações de outro domínio não as torna autoritativas localmente. Importações entram em quarentena — somente leitura, com proveniência, marcadas como externas — e são atualizadas por nova observação, não por escrita local.
] <inv-federacao-estado>

#invariante(titulo: [Ponte interna não é ponte entre soberanias])[
  Dentro de um mesmo domínio, compor informação é uma projeção pura. Entre domínios, há confiança a estabelecer, conflitos a resolver e um escritor canônico a respeitar. Tratar uma importação federada como leitura local esconde esses três problemas.
] <inv-ponte>

Uma _aresta de referência_ é a forma mínima de federação: um domínio sabe, tipadamente, que outro domínio contém algo relevante, sem conteúdo, sem transporte e sem autoridade. A referência pode ser unilateral — o domínio referenciado não precisa saber que é referenciado.

#exercicios[
  + Dê um exemplo em que tratar uma importação federada como estado local produz uma decisão errada depois que a fonte muda.
  + Por que arestas de referência unilaterais são aceitáveis, enquanto delegações de autoridade unilaterais não são?
  + Uma equipe importa, de outro domínio, a lista de serviços que dependem de uma API. Descreva como a importação deve ser representada no acervo local (estatuto, proveniência, atualização) para respeitar o @inv-federacao-estado.
]

== Domínios de autoridade, resolvedores e chaves <sec-fed-dominios>

Para muitos domínios, manter seu próprio serviço de autoridade é inviável; delega-se a avaliação a um serviço compartilhado. Esse arranjo exige separar várias identidades que costumam ser confundidas.

#definicao(titulo: [Domínio de autoridade e resolvedor])[
  Um _domínio de autoridade_ é a identidade lógica durável de um conjunto de principais, concessões e sujeitos governados — separada do hospedeiro, do banco de dados físico, do endereço de rede e de qualquer chave. Um _resolvedor_ é um serviço autorizado a emitir decisões em nome de um domínio, provando posse de uma _chave de atestação_ cuja parte pública está registrada no domínio e cuja parte privada vive no armazenamento de segredos da implantação, não no banco de dados.
] <def-dominio-autoridade>

#invariante(titulo: [Domínio, chave, hospedeiro e endereço são distintos])[
  O identificador do domínio de autoridade não é a chave do resolvedor, nem o hospedeiro, nem o endereço do serviço. Migrar o banco de dados ou o hospedeiro não cria um novo domínio; perder a chave não destrói o domínio.
] <inv-dominio-chave>

#invariante(titulo: [Endereço não é identidade do resolvedor])[
  O serviço que responde num endereço configurado não é, por isso, o resolvedor legítimo. A identidade do resolvedor é verificada por desafio criptográfico contra a chave registrada; divergência de impressão digital produz #estado[conflito de identidade do resolvedor], nunca aceitação.
] <inv-endereco-resolvedor>

#invariante(titulo: [A chave privada não vive nos dados de autoridade])[
  Se a parte privada da chave do resolvedor estivesse no banco de dados de autoridade, clonar o banco clonaria a identidade, e dois resolvedores indistinguíveis passariam a emitir decisões. O banco guarda apenas a parte pública autorizada. Se a chave privada está ausente na inicialização, o resolvedor falha fechado — nunca gera uma chave nova automaticamente nem reaproveita uma chave antiga de outro hospedeiro.
] <inv-chave-privada>

#exercicios[
  + Explique como a clonagem de um banco de dados com chaves privadas produz uma situação de "cérebro dividido" indistinguível.
  + Descreva o comportamento correto de um resolvedor que inicia sem encontrar sua chave privada.
  + Faça uma tabela com as cinco identidades distintas desta seção (domínio, resolvedor, chave, hospedeiro, endereço) e, para cada uma, o que acontece quando ela muda e quais das outras permanecem.
]

== A vinculação bilateral como máquina de estados <sec-fed-bilateral>

O @cap-autoridade introduziu a vinculação bilateral (@def-vinculacao-bilateral): a delegação da avaliação de autoridade de um domínio $W$ a um serviço $E$ exige declaração de $W$ e reconhecimento de $E$. Aqui damos sua forma de máquina de estados.

#figure(
  diagram(
    spacing: (14mm, 10mm),
    node-stroke: 0.6pt + cor.primaria, node-fill: cor.tinta-def, node-corner-radius: 2pt,
    node((0, 0), text(size: 8pt)[não registrado], name: <nr>),
    node((2, 0), text(size: 8pt)[registrado,\ não delegado], name: <rn>, fill: cor.tinta-anti),
    node((2, 1.3), text(size: 8pt)[confirmado], name: <c>),
    node((0, 1.3), text(size: 8pt)[delegado,\ não registrado], name: <dn>, fill: cor.tinta-anti),
    node((1, 2.5), text(size: 8pt)[conflito (de domínio\ ou de resolvedor)], name: <cf>, fill: cor.tinta-anti),
    edge(<nr>, <rn>, "-|>", label: text(size: 7.5pt)[registro em $E$]),
    edge(<rn>, <c>, "-|>", label: text(size: 7.5pt)[declaração em $W$], label-side: left),
    edge(<nr>, <dn>, "-|>", label: text(size: 7.5pt)[declaração sem registro], label-side: right),
    edge(<dn>, <c>, "-|>", label: text(size: 7.5pt)[registro], label-side: left),
    edge(<c>, <cf>, "-|>", label: text(size: 7.5pt)[divergência], label-side: left),
    edge(<rn>, <cf>, "-|>"),
    edge(<c>, <rn>, "-|>", bend: 30deg, label: text(size: 7.5pt)[$W$ retira], label-side: right),
    edge(<cf>, <c>, "-|>", bend: -40deg, label: text(size: 7.5pt)[resolução pelo titular], label-side: right),
  ),
  caption: [Estados da vinculação bilateral entre um domínio $W$ e um serviço de autoridade $E$. Apenas #estado[confirmado] habilita avaliação de autoridade delegada; os estados em vermelho são inválidos para ação. Os estados são o produto "declarado por $W$" × "reconhecido por $E$", mais o conflito; a confirmação, como toda observação, tem instante e precisa ser renovada.],
) <fig-vinculacao>

#fato(titulo: [Só o estado confirmado autoriza leitura delegada])[
  Se toda leitura que atravessa loci exige uma decisão emitida por um resolvedor vinculado a $W$ em estado #estado[confirmado], então nenhuma leitura delegada de $W$ é autorizada em qualquer outro estado da máquina da @fig-vinculacao.
] <prop-confirmado>

#prova[
  Por hipótese, a autorização exige o estado #estado[confirmado]; nos demais estados, a condição falha e o portão (que falha fechado, @teo-falha-fechado) não abre.
]

#algoritmo("Vincula-Bilateralmente", params: $W, E$, legenda: [Vinculação bilateral de um domínio soberano existente $W$ a um serviço de autoridade $E$.])[
  + observe o estado anterior de $W$ e de $E$
  + registre em $E$ o domínio _existente_ $W$, conferindo o identificador soberano #h(1fr) ▷ registrar, nunca "criar"
  + verifique independentemente o registro: estado #estado[registrado, não delegado]
  + declare a delegação no acervo de $W$, sob a autoridade de $W$, no locus que o materializa
  + componha o declarado com o observado: estado #estado[confirmado]
  + reexecute uma leitura entre loci e verifique a transição esperada: de "autoridade não resolvida" para "autenticação requerida"
  + só então abra a fronteira de principais
] <alg-vincula>

O passo 6 é um exemplo de _assinatura experimental_: a mudança de estado esperada de uma operação é verificada como evidência de que a vinculação funcionou, e não apenas o retorno de sucesso dos passos anteriores.

/ Correção: a fronteira de principais só é aberta (passo 7) se o estado for #estado[confirmado] e a assinatura experimental do passo 6 tiver sido observada; nenhum passo cria o domínio, de modo que a identidade soberana de $W$ não muda. O algoritmo é retomável: cada passo verifica o estado anterior, e repeti-lo depois de uma interrupção não duplica registros, porque o registro do passo 2 é indexado pelo identificador soberano. São $O(1)$ interações com $E$ e com o acervo de $W$; o custo é o das verificações independentes.

#exercicios[
  + Por que o passo 2 do @alg-vincula diz "registrar o domínio existente" e não "criar o domínio"? Que falha a criação produziria?
  + Descreva o que acontece na máquina da @fig-vinculacao se o serviço $E$ for substituído por outro com a mesma configuração de endereço e uma chave diferente.
  + Prove que, na máquina da @fig-vinculacao, o estado #estado[confirmado] só é alcançável se houve tanto registro em $E$ quanto declaração em $W$, independentemente da ordem.
]

== Principais portáveis e tempos de vida <sec-fed-principal>

Um mesmo humano ou agente atua em vários domínios. Para que a autenticação funcione entre eles sem que cada domínio crie sua própria identidade desconexa, é preciso um principal portável.

#definicao(titulo: [Principal portável])[
  Um _principal portável_ é identificado por um par (emissor, sujeito) imutável — a identidade externa —, ligado em cada domínio a um identificador local. A autenticação prova "sou $P$"; a autorização vem, a cada decisão, do dono da autoridade do alvo.
] <def-principal-portavel>

#figure(
  tabela(
    colunas: (1.1fr, 1fr, 1.5fr),
    cabecalho: ([Credencial], [Tempo de vida], [Papel]),
    [identidade externa], [imutável], [designa o principal],
    [chave de dispositivo confiável], [durável até revogação], [prova posse em dispositivo registrado],
    [sessão (token)], [curta, renovável], [prova recente de autenticação],
    [concessão de efeito], [governada, revogável], [autoriza uma classe de efeito sobre um sujeito],
    [raiz de gênese e recuperação], [muito durável, fora do fluxo normal], [recupera o domínio em emergências],
  ),
  caption: [Tempos de vida de credenciais. Confundi-los produz classes inteiras de falhas: tokens no contexto, concessões em cache, sessões tratadas como identidade, dispositivos confiáveis tratados como autoridade.],
) <tab-tempos-vida>

#algoritmo("Autentica-e-Autoriza", params: $p, W, r$, legenda: [Autenticação de um principal portável e autorização de uma operação $r$ sobre o domínio $W$.])[
  + parta da identidade externa imutável de $p$ (emissor, sujeito) #h(1fr) ▷ não do token
  + resolva o vínculo local de $p$ no domínio de autoridade de $W$
  + verifique a prova de autenticação (desafio assinado pela chave de dispositivo; sessão curta)
  + transmita ao serviço remoto uma asserção de autenticação assinada, restrita ao destinatário e de vida curta, pelo canal de serviço — nunca pelo contexto do modelo (@pri-credencial-contexto)
  + o domínio de $W$ resolve o principal local e decide #proc("Acesso")$(p, W, r)$, fresco
  + aplique a política de divulgação ao resultado
  + verifique os controles negativos: prova inválida ⇒ falha de autenticação; sem concessão ⇒ negado; revogada ⇒ negado
] <alg-autentica>

#invariante(titulo: [Token prova quem, não o quê])[
  Uma credencial carrega "eu sou $P$", não "$P$ pode ler $W$". Concessões são avaliadas no dono do alvo a cada decisão, o que permite revogação imediata. Um identificador fornecido pelo chamador, sem prova, é entrada não confiável.
] <inv-token>

#exercicios[
  + Classifique na @tab-tempos-vida: um cookie de sessão de navegador; uma chave de assinatura num dispositivo; uma regra de acesso a um repositório.
  + Por que começar pela identidade externa, e não pelo token, evita a criação de principais desconexos em domínios diferentes?
  + No @alg-autentica, explique o papel de cada controle negativo do passo 7 e por que eles devem ser testados explicitamente, e não apenas supostos.
]

== Gênese, rotação e recuperação <sec-fed-raiz>

#definicao(titulo: [Gênese])[
  A _gênese_ de um domínio de autoridade é a criação de seu primeiro administrador por uma operação de provisionamento autorizada fora do domínio — por uma raiz de confiança de gênese —, permitida exatamente uma vez.
] <def-genese>

#teorema(titulo: [Gênese única])[
  Suponha que (i) a gênese seja executada como uma operação atômica de comparar-e-trocar sobre um registro linearizável @herlihy1990 que contém o sinal "inicializado"; (ii) o sinal nunca volte a falso — nem quando todos os administradores são removidos, nem por restauração de cópia de segurança ou clonagem do armazenamento (o registro vive fora do banco de autoridade, ou toda restauração preserva o maior valor já confirmado); e (iii) só a raiz de gênese invoque a operação. Então, em toda execução, ocorre no máximo uma gênese bem-sucedida.
] <teo-genese>

#prova[
  Por (i), as invocações são linearizáveis: existe uma ordem total delas, compatível com o tempo real, em que cada uma parece ocorrer instantaneamente. Só a primeira nessa ordem encontra o sinal falso e o troca para verdadeiro. Por (ii), nenhuma invocação posterior encontra o sinal falso. Logo há no máximo um sucesso.
]

Sem a hipótese (i), a prova ingênua — "a gênese só ocorre se o sinal é falso, e o torna verdadeiro" — falha: duas tentativas concorrentes podem ler "falso" antes que qualquer uma escreva "verdadeiro", e ambas criam um primeiro administrador. É a condição de corrida entre verificação e uso que o livro denuncia em outros lugares (@inv-autoridade-tempo). Garantir (i) num armazenamento replicado exige consenso (Apêndice D).

A propriedade precisa ser _testada negativamente_: tentar uma segunda gênese e registrar a rejeição (@pri-disciplina-verificacao). Remover todos os administradores não deve reabrir a porta — caso contrário, um atacante que consiga remover administradores obtém um caminho para tomar o domínio.

#principio(titulo: [Rotação após perda não exige a chave perdida])[
  Se a chave privada de um resolvedor é perdida, a rotação para uma chave nova segue um caminho de recuperação que não exige assinatura com a chave antiga — caso contrário, a recuperação seria circular. A rotação é governada e registrada, a chave antiga é declarada perdida e provadamente rejeitada, e a nova é registrada sob o _mesmo_ domínio.
] <pri-rotacao>

Antes de declarar uma chave perdida, distingue-se: a chave não está no processo; a chave não é referenciada pela implantação; a chave não existe mais. Só o terceiro caso exige rotação; os dois primeiros exigem, respectivamente, carregar e corrigir a referência. A busca por candidatos ocorre em superfícies legítimas, sem exibir conteúdo de segredos, derivando localmente a parte pública e comparando impressões digitais.

#exercicios[
  + Descreva um ataque que explore uma gênese não única.
  + Escreva o registro de decisão de perda operacional de uma chave, incluindo o escopo da busca e a classificação triádica.
  + #avancado Mostre que a monotonicidade do sinal "inicializado" é essencial no @teo-genese: construa uma execução com duas gêneses quando o sinal pode voltar a falso após a remoção de todos os administradores.
]

== Composição de atestações federadas <sec-fed-atestacoes>

Uma afirmação que atravessa domínios — "a versão $v$ do produto foi aprovada pela revisão de segurança, pela equipe de plataforma e pelo titular" — é composta de afirmações parciais, cada uma atestada por uma autoridade diferente.

#definicao(titulo: [Afirmação federada])[
  Seja $c = c_1 and dots and c_n$. Para cada componente $c_i$, seja $A_i$ o conjunto das atestações _vigentes_ — não suplantadas pelo próprio atestador — emitidas por coordenadas de autoridade competentes para $c_i$, sobre o pacote corrente e com escopo declarado. O estatuto da componente é o supremo, na ordem de informação, dos estatutos de $A_i$ (e #est[desconhecido] se $A_i$ é vazio). O estatuto de $c$ é dado pela _conjunção prudente_: #est[refutado] se alguma componente é #est[refutado]; senão #est[conflitante] se alguma é #est[conflitante]; senão #est[desconhecido] se alguma é #est[desconhecido]; senão #est[provado]. A proveniência de $c$ é o conjunto dos pares (componente, atestação).
] <def-afirmacao-federada>

A definição separa dois níveis que não devem ser misturados. Atestações sobre a _mesma_ componente combinam-se na ordem de informação: um #est[provado] e um #est[refutado] de atestadores competentes produzem #est[conflitante], como pede o @inv-contradicao-federada. Componentes _diferentes_ combinam-se conjuntivamente. A conjunção prudente coincide com o ínfimo da ordem de verdade em $K_3$, mas não no bireticulado $sans("FOUR")$: ali, o ínfimo de #est[desconhecido] e #est[conflitante] é #est[refutado], e tomá-lo seria apresentar ausência como refutação — exatamente o que P4 proíbe.

#proposicao(titulo: [Independência da ordem de chegada])[
  O estatuto de uma afirmação federada não depende da ordem em que as atestações vigentes chegam nem de repetições; a suplantação de uma atestação pelo próprio atestador é a única operação que pode diminuir a informação de uma componente.
] <prop-federada-ordem>

#prova[
  O supremo, numa componente, e a conjunção prudente, entre componentes, são comutativos, associativos e idempotentes; logo o resultado depende apenas do conjunto de atestações vigentes. Acrescentar uma atestação vigente só pode aumentar o supremo de sua componente; para diminuí-lo, é preciso retirar uma atestação do conjunto vigente, o que só a suplantação faz.
]

#invariante(titulo: [Atestação vale para o que foi avaliado])[
  Uma atestação vale para o pacote que o atestador efetivamente avaliou. Estendê-la a afirmações que não estavam nesse pacote — ou a uma versão posterior do pacote — é _sobrevinculação_. Cada atestação registra o resumo do pacote avaliado, e a composição verifica que ele coincide com o pacote corrente.
] <inv-sobrevinculacao>

#invariante(titulo: [Contradição é fato a expor])[
  Quando atestadores competentes discordam, o estatuto é #est[conflitante] e permanece assim até uma ação explícita de quem tem autoridade para resolver. Escolher a atestação mais recente ou mais conveniente é resolver em silêncio.
] <inv-contradicao-federada>

Uma última consequência, já antecipada no Apêndice B: uma negação local só se torna global sob hipótese explícita de cobertura. Se nenhum dos domínios consultados atesta $c$, isso prova apenas que _esses_ domínios não atestam — não que $c$ seja falso (@lem-escopo-negacao). O conhecimento distribuído de um grupo de domínios (@sec-ap-epistemica) é o que o grupo saberia se reunisse suas informações; ele decide uma negação global apenas se a cobertura conjunta dos domínios for declarada.

#exercicios[
  + Componha a afirmação federada "a versão $v$ pode ser publicada" a partir de três atestações, uma delas sobre uma versão anterior. Qual é o estatuto?
  + Proponha um formato de atestação que torne a sobrevinculação detectável mecanicamente.
  + Componha a afirmação federada "a versão $v$ pode ser publicada" a partir de atestações com estatutos #est[provado], #est[provado] e #est[desconhecido]. Qual é o estatuto composto? E se uma das atestações for #est[conflitante]?
]

== "Fala por": um fundamento formal para delegação ★ <sec-fed-falapor>

A teoria de autenticação em sistemas distribuídos de #ct(<lampson1992>) e o cálculo de #ct(<abadi1993>) introduziram uma relação entre principais que dá forma precisa à delegação: $A$ _fala por_ $B$ ($A => B$) se tudo o que $A$ diz pode ser tomado como dito por $B$.

#definicao(titulo: [Fala por])[
  Num cálculo de principais com o operador "diz" ($A "diz" phi$), a relação $A => B$ satisfaz: se $A => B$ e $A "diz" phi$, então $B "diz" phi$. A relação é reflexiva e transitiva.
] <def-fala-por>

Com essa linguagem, a vinculação bilateral tem uma leitura limpa: o resolvedor $E$ só fala pelo domínio $W$ se $W$ disse que $E$ fala por ele (declaração de delegação) e se é verificável que quem fala é de fato $E$ (desafio criptográfico contra a chave registrada). A delegação pode também ser _restrita_: $E$ fala por $W$ apenas sobre certas afirmações. Mecanismos práticos de delegação atenuada — credenciais que carregam restrições acumuláveis, como os "macaroons" @birgisson2014 — e sistemas de autorização globalmente consistentes @pang2019 exploram o espaço de projeto entre _atenuar_ credenciais em trânsito e _re-resolver_ a autoridade no dono a cada decisão.

#exercicios[
  + Formalize, no cálculo "fala por", a regra "um token prova quem, não o quê".
  + Compare atenuação de credenciais e re-resolução no dono quanto a revogação, desempenho e disponibilidade.
  + Mostre, a partir da definição, que a relação "fala por" é transitiva, e explique por que a transitividade torna perigosas cadeias longas de delegação sem restrição de escopo.
]

#quadro[
  - Federação compõe significado, não estado; importações ficam em quarentena, com proveniência.
  - Domínio de autoridade, resolvedor, chave, hospedeiro e endereço são distintos; a chave privada não vive nos dados de autoridade.
  - A vinculação bilateral é uma máquina de estados; só #estado[confirmado] habilita decisões delegadas.
  - Principais portáveis partem da identidade externa; tokens provam quem, não o quê; cinco tempos de vida de credenciais.
  - Gênese é única (@teo-genese); rotação após perda não exige a chave perdida.
  - Afirmações federadas combinam atestações de uma componente pelo supremo de informação e componentes pela conjunção prudente; atestação vale para o pacote avaliado; contradições são expostas.
  - "Fala por" formaliza delegação e sua restrição.
]

#problemas[
  #problema([Recuperação por limiar])[
    A raiz de gênese e recuperação de um domínio é um ponto único de falha.
    + Proponha um esquema de recuperação que exija a concordância de $k$ de $n$ guardiões.
    + Mostre que o esquema preserva a @teo-genese e o @pri-rotacao.
    + Discuta o compromisso entre segurança e disponibilidade na escolha de $k$.
  ]
  #problema([Lógica de autoridade para atestações parciais])[
    Estenda o cálculo "fala por" com escopos de afirmação.
    + Defina $A =>_S B$: $A$ fala por $B$ sobre as afirmações do conjunto $S$.
    + Prove que a relação é transitiva com interseção de escopos: $A =>_S B$ e $B =>_T C$ implicam $A =>_(S inter T) C$.
    + Use o resultado para mostrar que a delegação em cadeia nunca amplia o escopo.
  ]
  #problema([Federação e consistência])[
    Um domínio exporta projeções para outros dez.
    + Descreva o que significa, para os importadores, ver projeções "atuais".
    + Compare uma estratégia de assinatura de mudanças com uma de nova observação sob demanda.
    + Relacione com consistência eventual e garantias de sessão @terry1994.
  ]
]

#notas[
  A matriz de acesso e as capacidades @lampson1974 @dennis1966 dão a base de controle de acesso; a lógica de autenticação em sistemas distribuídos é de #ct(<lampson1992>) e #ct(<abadi1993>), que introduziram a relação "fala por". A decidibilidade de segurança em modelos de proteção é limitada: no modelo geral de #ct(<harrison1976>) a pergunta "algum direito pode vazar?" é indecidível, enquanto no modelo restrito de concessão e tomada de #ct(<lipton1977>) ela é decidível em tempo linear — um lembrete de que modelos de autoridade precisam ser deliberadamente restritos para serem verificáveis. Credenciais atenuáveis são de #ct(<birgisson2014>), autorização global consistente em escala é descrita por #ct(<pang2019>), sistemas de atualização resistentes a comprometimento de chaves por #ct(<samuel2010>), e o padrão de delegação de autorização na web por @rfc6749.

  A vinculação bilateral, a separação entre domínio, chave, hospedeiro e endereço, a gênese única, a rotação após perda sem a chave antiga, os tempos de vida de credenciais e a sobrevinculação de atestações são propostas deste livro, que aplicam a serviços de autoridade compartilhados por domínios soberanos princípios clássicos de gestão de chaves e de autenticação distribuída.
]
