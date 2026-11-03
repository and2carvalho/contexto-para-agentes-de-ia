#import "/modelo/estilo.typ": *

= Autoridade, capacidades e soberania <cap-autoridade>

#epigrafe(fonte: [Jerome Saltzer e Michael Schroeder, 1975])[Todo programa e todo usuário privilegiado do sistema deve operar com o menor conjunto de privilégios necessário para completar sua tarefa.]

Um agente que lê pode errar; um agente que escreve pode causar dano. A diferença entre os dois é a _autoridade_ — e a história da segurança computacional é, em boa parte, a história de como sistemas confundiram autoridade com coisas que se parecem com ela: estar logado, estar no diretório certo, ter a ferramenta, ter recebido uma instrução. Agentes de linguagem reabrem todas essas confusões de uma vez, porque operam por meio de texto, e texto pode conter qualquer coisa — inclusive frases que _soam_ como autorização.

Este capítulo trata da autoridade como dimensão própria do contexto, independente de identidade, localização, relevância e visibilidade. A @sec-aut-classicos recapitula os conceitos clássicos de controle de acesso. A @sec-aut-planos separa os planos de dados, identidade e autoridade. A @sec-aut-imitacoes cataloga o que _não_ é autoridade. A @sec-aut-tempo trata da dimensão temporal: autoridade no momento da proposta e no momento da execução. A @sec-aut-humana distingue três formas de autoridade humana. A @sec-aut-soberania define soberania e domínios de autoridade. A @sec-aut-fluxo trata do fluxo de informação e do teto de autoridade de uma perspectiva.

== Conceitos clássicos <sec-aut-classicos>

A formulação clássica de proteção @lampson1974 descreve o sistema como uma _matriz de acesso_: linhas são _sujeitos_ (quem age), colunas são _objetos_ (sobre o que se age), e cada célula contém os _direitos_ do sujeito sobre o objeto. Há duas formas de armazenar a matriz: por coluna, como _listas de controle de acesso_ associadas a objetos, ou por linha, como _capacidades_ — referências não forjáveis que carregam, junto com a designação do objeto, o direito de usá-la @dennis1966.

#definicao(titulo: [Capacidade])[
  Uma _capacidade_ é um par (designação de objeto, conjunto de direitos) que não pode ser forjado nem ampliado por quem o detém, e cuja posse é condição necessária e suficiente para exercer os direitos sobre o objeto. Capacidades podem ser delegadas (transmitidas, possivelmente com direitos reduzidos) e, em sistemas bem projetados, revogadas.
] <def-capacidade>

Neste livro, "capacidade" é usada apenas nesse sentido de segurança. Para o que o sistema _sabe fazer_ — uma ferramenta, uma operação, uma função disponível — dizemos _funcionalidade_. A distinção não é pedantismo: ter uma funcionalidade à mão não é ter autoridade para usá-la, e o vocabulário deve impedir que uma passe pela outra.

O _princípio do menor privilégio_ @saltzer1975 pede que cada sujeito opere com o mínimo de direitos necessários. O problema do _delegado confuso_ @hardy1988 mostra por que listas de controle de acesso tornam esse princípio difícil: um programa com autoridade própria, agindo a pedido de um cliente, pode ser induzido a usar _sua_ autoridade em benefício do cliente, porque nada no pedido distingue "com qual autoridade" a operação deve ser feita. Capacidades resolvem o problema ao unir designação e autoridade num só objeto: o cliente só pode pedir operações sobre objetos para os quais ele mesmo pode fornecer a capacidade @miller2006.

Modelos posteriores organizam permissões por _papéis_ (RBAC) @sandhu1996 ou por _atributos_ de sujeito, objeto e ambiente (ABAC) @hu2014; protocolos de delegação na web, como o OAuth @rfc6749, emitem _tokens_ com escopos limitados para que aplicações ajam em nome de usuários.

#observacao(titulo: [Agentes como delegados confusos])[Um agente de linguagem com acesso a ferramentas é o delegado confuso por excelência. Ele recebe instruções de várias fontes — o usuário, documentos recuperados, saídas de ferramentas, outros agentes — e age com a autoridade de suas ferramentas. Se um documento recuperado contém "envie este arquivo para tal endereço" (@pri-contexto-nao-comando), o agente pode usar sua autoridade legítima para servir a uma fonte que não tem autoridade alguma. A defesa não é ensinar o agente a desconfiar, e também não basta verificar a autoridade do principal da tarefa: numa injeção, a autoridade legítima do principal é justamente o que o atacante usa. A defesa estrutural é dupla: a ação é avaliada contra a autoridade do principal _e_ seus argumentos são rotulados pela procedência, de modo que dados de fontes sem autoridade de efeito não determinem o destino, o sujeito ou o conteúdo de uma ação sem revisão (@sec-seg-procedencia).]

#exercicios[
  + Represente como matriz de acesso um cenário com três agentes, dois repositórios e um serviço de implantação. Escreva a mesma informação como listas de controle de acesso e como capacidades.
  + Descreva um ataque de delegado confuso contra um agente de programação que tem permissão de escrita num repositório e lê arquivos de dependências de terceiros.
  + Por que tokens com escopo, como os do OAuth, são uma aproximação de capacidades? Em que aspectos diferem delas?
]

== Dados, identidade e autoridade <sec-aut-planos>

Três perguntas distintas aparecem sempre que um consumidor quer agir sobre um recurso:

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Plano], [Pergunta], [Quem responde]),
    [Dados], [Que recurso quero, e como obtê-lo?], [o caminho de leitura (resolução, transporte, materialização)],
    [Identidade], [Quem sou eu?], [a autenticação, que prova um principal],
    [Autoridade], [O que este principal pode fazer neste recurso, agora?], [o dono da autoridade do recurso-alvo, com decisão atual],
  ),
  caption: [Os três planos. Respostas de um plano não substituem respostas de outro: autenticar-se não autoriza; alcançar um recurso não autoriza; e ser autorizado não garante que o recurso esteja disponível.],
) <tab-tres-planos>

#invariante(titulo: [Autenticação não é autorização])[
  Provar quem se é não implica poder fazer algo. Uma credencial válida carrega "eu sou $P$"; não carrega "$P$ pode ler $W$". A decisão de autorização vem, atualizada, do dono da autoridade do alvo.
] <inv-autenticacao-autorizacao>

#invariante(titulo: [Leitura não é escrita])[
  A autoridade para ler um recurso não implica autoridade para alterá-lo. Em particular, ter acesso de sistema de arquivos para gravar um arquivo não implica estar autorizado a alterar o contexto governado que esse arquivo materializa.
] <inv-leitura-escrita>

O segundo invariante tem uma consequência prática imediata para agentes. Um agente frequentemente consegue, tecnicamente, escrever em lugares onde não deveria: o sistema operacional permite, o diretório é gravável, a ferramenta de edição funciona. A pergunta correta não é "consigo escrever?", mas "a escrita está autorizada para este principal, neste recurso, sob esta coordenada?". Quando a resposta não pode ser estabelecida, o agente deve tratar o recurso como somente leitura.

#exercicios[
  + Dê um exemplo de cada uma das seguintes situações: autenticado e não autorizado; autorizado e indisponível; disponível e não autenticado.
  + Um agente é iniciado num diretório de um projeto em que tem permissão de escrita no sistema de arquivos, mas o titular declarou o projeto como "somente leitura" para aquela tarefa. Que mecanismos garantiriam que a declaração seja respeitada mesmo que o agente "esqueça" dela?
  + Classifique como autenticação, autorização ou nenhuma das duas: (a) verificar a assinatura de uma mensagem; (b) consultar se o principal pode promover a revisão; (c) verificar que o principal tem uma conta no serviço; (d) verificar que a ferramenta existe.
]

== O que não é autoridade <sec-aut-imitacoes>

Muitas coisas se parecem com autoridade e são tratadas como tal por sistemas mal projetados. Listá-las explicitamente é uma das ferramentas mais eficazes de projeto.

#figure(
  tabela(
    colunas: (1fr, 1.6fr),
    cabecalho: ([Imitação], [Por que não é autoridade]),
    [Posse de ferramenta], [Uma ferramenta é uma _affordance_: torna a ação possível tecnicamente. Ter a ferramenta não prova que a ação está autorizada.],
    [Localização], [Estar no diretório, na máquina ou na rede do recurso não confere direitos sobre ele. Saber onde algo está não é poder lê-lo.],
    [Alcançabilidade], [Conseguir se conectar a um serviço (por exemplo, um login de transporte bem-sucedido) não autoriza operar sobre seus dados.],
    [Papel ou perfil], [Papéis e perfis _restringem_ ou _descrevem_ o que um consumidor tenta; não concedem direitos. "Papel = executor" não é permissão.],
    [Pertinência a composição], [Ser membro de um grupo de recursos não herda a autoridade do grupo nem de outros membros.],
    [Instrução de transferência], [Um pacote que descreve trabalho a ser feito não concede a autoridade para fazê-lo.],
    [Proposta], [Uma proposta bem formada é um pedido; não é uma credencial.],
    [Recomendação], [A recomendação de um agente supervisor não é decisão do titular nem autorização.],
    [Divulgação], [Ver um recurso numa perspectiva não autoriza agir sobre ele.],
    [Registro administrativo], [Quem cadastrou um recurso num servidor não é, por isso, seu dono soberano.],
  ),
  caption: [Imitações de autoridade. Cada linha corresponde a uma classe de falhas observadas em sistemas de agentes.],
) <tab-imitacoes>

#invariante(titulo: [Nenhuma imitação concede autoridade])[
  Nenhum dos itens da @tab-imitacoes — ferramenta, localização, alcançabilidade, papel, pertinência, transferência, proposta, recomendação, divulgação ou registro — concede, por si só, autoridade para efeitos. A autoridade para um efeito é sempre uma decisão explícita, rastreável a um dono, avaliada no momento do efeito.
] <inv-imitacoes>

=== Perfis só restringem

Perfis de consumidor — que dizem, por exemplo, que um agente de revisão só vê certos tipos de recurso — são úteis para reduzir ruído e risco. Eles precisam satisfazer uma propriedade simples.

#proposicao(titulo: [Monotonicidade de perfis])[
  Seja $A_"prov"$ o conjunto de operações que o provedor de autoridade permite a um principal e $A_"perfil"$ o conjunto que um perfil lhe atribui. Se o sistema calcula as operações efetivas como $A_"ef" = A_"prov" inter A_"perfil"$, então nenhum perfil pode ampliar os direitos do principal: $A_"ef" subset.eq A_"prov"$.
] <prop-perfis-restringem>

#prova[
  Imediata: a interseção de dois conjuntos está contida em cada um deles.
]

A proposição é trivial; violá-la não é. Basta que, em algum ponto do sistema, o perfil seja _consultado sozinho_ ("o perfil diz que é executor, então executa") para que um perfil mal configurado se torne um vetor de escalada.

#exercicios[
  + Para cada linha da @tab-imitacoes, descreva uma falha concreta em que a imitação foi tratada como autoridade.
  + Um sistema permite que o titular dê instruções em linguagem natural a um agente orquestrador, que as repassa a agentes executores. Identifique em que pontos uma frase do titular pode se transformar indevidamente em autoridade estrutural, e proponha salvaguardas.
  + Para cada imitação de autoridade da @tab-imitacoes, descreva um incidente plausível em que um agente a tomou por autoridade, e a salvaguarda que o teria impedido.
]

== Autoridade no tempo <sec-aut-tempo>

Autoridade muda. Concessões são revogadas, recursos mudam de dono, credenciais expiram, o estado do alvo se altera entre o momento em que uma ação é proposta e o momento em que é executada.

#invariante(titulo: [Autoridade na proposta não é autoridade na execução])[
  A autoridade, a aplicabilidade e o estado do alvo devem ser reavaliados no momento da execução. Uma autorização obtida para uma proposta numa coordenada não se transfere silenciosamente para outra coordenada, nem sobrevive a mudanças relevantes do mundo.
] <inv-autoridade-tempo>

O invariante é a versão, para autorização, do problema de verificação e uso (TOCTOU) já encontrado no @cap-identidade: entre verificar e agir, o mundo pode mudar. A defesa é a mesma: reverificar no ponto de uso, com o menor intervalo possível entre verificação e efeito, e tratar como bloqueado qualquer caso em que a reverificação não possa ser feita.

=== Tempos de vida e concessões tipadas

Diferentes credenciais e decisões têm tempos de vida muito diferentes: a identidade de um principal é, por decisão de projeto, imutável (contas são renomeadas e fundidas; o identificador estável não); a posse de um dispositivo confiável dura até a revogação; uma sessão dura minutos ou horas; uma concessão de efeito vive enquanto não for revogada; e a raiz de confiança de um domínio é usada raramente e fora do fluxo normal. O @cap-federacao apresenta a tabela completa (@tab-tempos-vida). Confundir esses tempos de vida produz falhas típicas: tratar uma sessão como identidade, guardar em cache uma concessão que deveria ser reavaliada, usar a raiz de recuperação como credencial cotidiana.

Uma concessão de efeito, por sua vez, deve ser _tipada_: ela autoriza uma classe de efeito (ler, escrever, promover, implantar) sobre um sujeito (um domínio, um recurso, uma relação), possivelmente com um propósito e uma expiração. Uma concessão de "acesso ao domínio", sem tipo nem sujeito preciso, é um convite à autoridade ambiente. Autoridade concedida para um propósito limitado termina com o propósito: o escritor criado para inicializar um domínio não deve ser reaproveitado para gravar evidências novas.

=== Não concedido não é negado

Uma confusão sutil aparece quando a autoridade é avaliada em três valores. Uma decisão pode ser #estado[concedida], #estado[negada] ou simplesmente não ter sido obtida — porque o serviço de autoridade estava inacessível, porque a pergunta não foi feita, porque a credencial expirou.

#invariante(titulo: [Não concedido não autoriza])[
  O estado "não concedido" (autoridade não estabelecida) é distinto de "negado", mas tem o mesmo efeito sobre a execução: nenhuma ação é executada. Um portão que bloqueia apenas em "negado" e deixa passar "não concedido" falha aberto.
] <inv-nao-concedido>

Na linguagem do Apêndice B, a autorização é uma variável em $K_3$, e o portão deve exigir $sans(V)$ (@sec-ap-kleene). O @cap-portoes generaliza essa regra para conjunções de pré-condições.

=== Credenciais não entram no contexto

Uma consequência menos óbvia: credenciais — tokens, chaves, segredos — nunca devem fazer parte do contexto de um consumidor, nem das registros de continuação que outro consumidor receberá.

#principio(titulo: [Credencial não é contexto])[
  O contexto de um consumidor pode conter o _resultado_ de uma decisão de autoridade, com sua proveniência ("o principal $P$ tem leitura em $W$, decidido por $D$ em $t$"), mas não a credencial que permitiu obtê-la. Continuações e transferências carregam referências a credenciais, nunca o material da credencial.
] <pri-credencial-contexto>

O princípio protege contra vazamento — um contexto é texto, e texto é copiado, resumido, registrado e enviado a provedores de modelos — e contra uma forma de confusão: um agente que encontra uma credencial em seu contexto pode concluir que está autorizado a usá-la para qualquer fim.

#exercicios[
  + Classifique por tempo de vida: um token de sessão de um serviço de modelos; a chave de assinatura de um dispositivo; a regra "o agente $A$ pode abrir solicitações de integração no repositório $R$".
  + Descreva uma sequência de eventos em que um agente executa uma ação com base numa autorização obtida antes de uma revogação. Que ponto do sistema deveria ter impedido a execução?
  + Por que "não concedido" e "negado" devem ser distinguidos no registro, mesmo que tenham o mesmo efeito na execução? Que perguntas cada um sugere ao consumidor?
  + Um agente precisa passar trabalho a outro agente que vai acessar um serviço autenticado. Descreva o que deve e o que não deve constar do pacote de transferência.
]

== Três formas de autoridade humana <sec-aut-humana>

Em sistemas em que humanos e agentes colaboram, a autoridade humana aparece de três formas que convém manter separadas.

#definicao(titulo: [Formas de autoridade humana])[
  - Uma _concessão canônica_ é uma autorização durável, registrada pelo dono da autoridade do alvo, com escopo explícito.
  - Uma _diretiva de sessão_ do titular é uma autorização efêmera, limitada a uma execução ou conversa, que deve ser rotulada como tal e registrada com proveniência.
  - Uma _política do requisitante_ descreve o que uma perspectiva ou um consumidor pode _tentar_; não autoriza nada no alvo.
] <def-autoridade-humana>

#invariante(titulo: [Linguagem natural não vira autoridade estrutural])[
  Uma frase do titular numa conversa ("pode fazer o que for preciso") é, no máximo, uma diretiva de sessão: tem escopo limitado à sessão, é registrada como tal, e não se converte silenciosamente em concessão canônica nem se propaga a outros agentes por transferência.
] <inv-linguagem-autoridade>

#estudo-de-caso(titulo: [A recomendação que não era decisão])[
  Um agente supervisor revisou o resultado de um trabalho e recomendou ao titular abrir uma nova frente de trabalho. O agente orquestrador, que recebia as mensagens do supervisor, interpretou a recomendação como instrução e iniciou o trabalho. O titular, porém, havia decidido outra coisa. A falha não foi do supervisor (que recomendou), nem do titular (que decidiu), mas da ausência de uma distinção estrutural entre três estados: recomendado pelo supervisor, decidido pelo titular e executado pelo orquestrador. A correção foi tornar explícito, nos pacotes de transferência, quem decide e o que é apenas recomendação — e exigir que o orquestrador trate como #est[desconhecido] a próxima ação até que a decisão do titular esteja registrada.
] <caso-recomendacao-decisao>

#exercicios[
  + Classifique como concessão canônica, diretiva de sessão ou política do requisitante: (a) "este agente só pode ler arquivos de documentação"; (b) "nesta conversa, pode rodar os testes"; (c) uma regra de acesso no repositório que concede escrita a um grupo.
  + Proponha um formato de registro para diretivas de sessão que permita auditá-las depois.
  + Um titular escreve, numa conversa, "pode seguir com a migração". Que forma de autoridade humana isso é, e o que precisa acontecer para que se torne autorização estrutural de um efeito?
]

== Soberania e domínios de autoridade <sec-aut-soberania>

Chamamos de _domínio soberano_ uma fronteira durável de identidade, estado, autoridade e continuidade — por exemplo, um espaço de trabalho com seu próprio acervo e suas próprias regras de autoridade.

#definicao(titulo: [Soberania])[
  Um domínio é _soberano_ sobre um conjunto de recursos se é a fonte última de autoridade sobre eles: concessões sobre esses recursos nascem no domínio, decisões de autoridade sobre eles são tomadas por ele (ou por quem ele delega explicitamente), e nenhum outro domínio pode alterá-los sem sua autorização.
] <def-soberania>

A soberania não se infere de propriedades materiais. Um domínio não é soberano porque ocupa um diretório, porque tem um arquivo de configuração, porque está registrado num servidor ou porque alguém executou um comando de inicialização ali. A soberania é uma asserção que precisa de justificativa — tipicamente, uma decisão registrada do titular.

#invariante(titulo: [Registro não é soberania])[
  Ser registrado num serviço de coordenação não torna o serviço dono do domínio, e quem registrou não é, por isso, titular. Um serviço pode _cadastrar_ um domínio; não pode _tomá-lo_.
] <inv-registro-soberania>

=== Delegação bilateral

Domínios podem delegar a avaliação de autoridade a um serviço especializado — um servidor de autoridade que mantém principais e concessões. Essa delegação é delicada: feita de modo unilateral, ela permite que o serviço "assuma" domínios que apenas cadastrou.

#definicao(titulo: [Vinculação bilateral de autoridade])[
  A delegação da avaliação de autoridade de um domínio $W$ a um serviço $E$ é _legítima_ somente se existem, simultaneamente, (i) uma declaração de $W$ — registrada sob a autoridade de $W$ — de que delega a $E$, e (ii) uma observação, verificável criptograficamente, de que $E$ reconhece $W$ com a mesma identidade. Os estados possíveis formam o produto {declarado por $W$, não declarado} × {reconhecido por $E$, não reconhecido}, mais um estado de _conflito_ (de identidade de $E$ ou de $W$); só "declarado e reconhecido" — o estado _confirmado_ — habilita decisões delegadas, e, como toda observação, a confirmação tem instante: sem reconfirmação dentro de uma janela, ela volta a #est[desconhecido].
] <def-vinculacao-bilateral>

A bilateralidade é a proteção da soberania: sem a declaração de $W$, o registro em $E$ é apenas cadastro; sem a confirmação de $E$, a declaração de $W$ é apenas intenção. O @cap-federacao desenvolve os aspectos criptográficos (chaves de atestação, rotação, raiz de confiança) e as consequências para federação de domínios.

#exercicios[
  + Explique por que a delegação unilateral (apenas o serviço registra o domínio) permite um "sequestro administrativo". Descreva o ataque.
  + Um domínio declara delegar a um serviço que, por estar fora do ar, não pode confirmar. Qual deve ser o estado registrado, e como os consumidores devem se comportar?
  + #avancado Mostre, por redução do problema da parada, a ideia central da indecidibilidade de @teo-hru: como comandos condicionais de uma matriz de acesso podem simular os passos de uma máquina de Turing. Por que restringir os comandos a uma única operação torna o problema decidível?
]

=== Os limites da análise de segurança ★

Uma pergunta natural sobre qualquer sistema de autoridade é: partindo de uma configuração inicial de direitos, é possível que um principal venha a obter um direito que não deveria ter? #ct(<harrison1976>) formalizaram sistemas de proteção como matrizes de acesso modificadas por comandos condicionais e mostraram que, no caso geral, essa pergunta — a _segurança_ do sistema — é indecidível; ela se torna decidível sob restrições fortes, como comandos de uma única operação, e continua indecidível mesmo para sistemas monotônicos, sem remoção de direitos @harrison1978. Em contraste, o modelo de concessão e tomada (_take-grant_) @jones1976 admite decisão em tempo linear @lipton1977.

#teorema(titulo: [Indecidibilidade da segurança de sistemas de proteção])[
  No modelo de Harrison, Ruzzo e Ullman, não existe algoritmo que decida, para todo sistema de proteção e toda configuração inicial, se um dado direito pode vir a ser concedido a um principal que não o possuía @harrison1976.
] <teo-hru>

A ideia da prova é codificar uma máquina de Turing na matriz de acesso: cada célula da fita é um sujeito, os direitos de cada célula codificam o símbolo e, na posição do cabeçote, o estado; comandos condicionais simulam as transições, e um direito especial é concedido exatamente quando a máquina atinge o estado final. Decidir se esse direito pode vazar é, então, decidir se a máquina para.

O resultado tem uma lição direta para sistemas de contexto: modelos de autoridade precisam ser _deliberadamente restritos_ para que suas propriedades possam ser verificadas. A proposição seguinte mostra uma restrição suficiente.

#proposicao(titulo: [Segurança decidível com delegação atenuante])[
  Considere um sistema em que (i) direitos só nascem como concessões canônicas registradas por donos; (ii) todo outro direito é obtido por uma cadeia finita de delegações, cada uma concedendo um subconjunto dos direitos de quem delega; e (iii) nenhum comando cria sujeitos ou objetos. Então "o principal $p$ pode vir a obter o direito $r$ sobre $o$?" é decidível em tempo $O(|V| + |E|)$ no grafo de delegação potencial.
] <prop-seguranca-atenuante>

#prova[
  Por (ii), todo direito obtido por $p$ é um direito de alguma concessão canônica que alcança $p$ por um caminho no grafo de delegação potencial cujas arestas podem transmitir $r$; por (iii), o grafo é finito e fixo. A pergunta reduz-se, então, a alcançabilidade no subgrafo das arestas que podem transmitir $r$, decidível por busca em largura.
]

Concessões tipadas, tetos que só restringem (@prop-perfis-restringem), delegação que nunca amplia o escopo e ausência de autoridade ambiente são restrições desse tipo.

== Fluxo de informação e teto de autoridade <sec-aut-fluxo>

Até aqui tratamos de autoridade para _agir_. Há uma dimensão igualmente importante: autoridade para _saber_. O modelo de reticulado de fluxo de informação de #ct(<denning1976>) associa a cada objeto um _rótulo de segurança_ num reticulado e exige que informação só flua de rótulos menores para maiores — nunca de um objeto confidencial para um público. A propriedade correspondente, para sistemas inteiros, é a _não interferência_ de #ct(<goguen1982>): as saídas observáveis por um usuário de nível baixo não dependem das entradas de nível alto.

No modelo deste livro, o teto de autoridade $alpha$ da coordenada (@def-coordenada) desempenha o papel do rótulo do consumidor, e o @teo-nao-interferencia garante que a projeção não vaza o que está acima do teto — desde que a hipótese do teorema valha. Três canais típicos violam essa hipótese:

/ Índices calculados com autoridade maior: um índice de busca construído sobre todo o acervo pode revelar, pela simples presença de um resultado, a existência de um documento que o consumidor não poderia ler.

/ Resumos e caches compartilhados: um resumo calculado para um consumidor privilegiado e reaproveitado para outro carrega informação do nível alto.

/ Contagens e metadados: declarar em $X$ (exclusões) que "há 3 documentos que você não pode ver sobre este tema" é, ela mesma, uma divulgação — às vezes desejável, às vezes não. A política de divulgação deve decidir.

#principio(titulo: [Conhecer não é divulgar])[
  Um componente pode saber mais do que deve pôr no contexto de um consumidor. A divulgação é uma decisão explícita, determinística e explicável — "$X$ divulgado porque aplicável ao objetivo; $Z$ só existência porque conhecido mas não aplicável; $Y$ retido por autoridade" —, separada da decisão de autoridade e da decisão de relevância.
] <pri-conhecer-divulgar>

#exercicios[
  + Construa um exemplo em que a resposta "nenhum resultado" de uma busca vaza informação sobre documentos confidenciais.
  + Proponha uma política de divulgação de exclusões para três classes de consumidor (titular, agente interno, agente externo) e justifique.
  + #avancado Formalize a política de divulgação de contagens como uma função do rótulo do consumidor e mostre que, se ela for monótona no reticulado de rótulos, a projeção resultante continua satisfazendo uma forma fraca de não interferência.
]

#quadro[
  - Autoridade é dimensão própria: distinta de identidade, localização, relevância, visibilidade e funcionalidade disponível.
  - Dados, identidade e autoridade são três planos com donos diferentes; autenticação não é autorização; leitura não é escrita.
  - Ferramenta, localização, alcançabilidade, papel, pertinência, transferência, proposta, recomendação, divulgação e registro não são autoridade.
  - Perfis só restringem; "não concedido" não autoriza; autoridade é reavaliada na execução.
  - Credenciais não entram no contexto; linguagem natural não vira autoridade estrutural.
  - Soberania exige justificativa; delegação de autoridade é bilateral.
  - Conhecer não é divulgar: a divulgação é uma decisão explícita, sujeita ao teto de autoridade.
]

#problemas[
  #problema([Capacidades para agentes])[
    Projete um mecanismo em que cada ferramenta de um agente recebe, a cada chamada, uma capacidade derivada da autoridade do principal que originou a tarefa.
    + Descreva como a capacidade é obtida, transmitida e verificada.
    + Mostre que o mecanismo impede o ataque de delegado confuso do exercício da @sec-aut-classicos.
    + Discuta o custo em latência e a experiência do usuário.
  ]
  #problema([Matriz de ortogonalidade])[
    Para os pares (autenticação, autorização), (papel, autorização), (divulgação, autorização), (pertinência, autorização), construa uma matriz de testes que verifique, nas duas direções, que um não implica o outro.
    + Para cada par, descreva o teste "A sem B" e o teste "B sem A".
    + Explique por que testes positivos ("autorizado executa") são insuficientes e por que os negativos ("autenticado sem concessão é negado") são essenciais.
  ]
  #problema([Divulgação e utilidade])[
    Um agente de suporte precisa responder a clientes usando documentação interna, parte da qual é confidencial.
    + Modele o problema com rótulos de segurança e um teto de autoridade por cliente.
    + Mostre como um índice compartilhado pode vazar informação e proponha uma arquitetura que evite o vazamento.
    + Discuta o compromisso entre utilidade das respostas e risco de vazamento, e como medir ambos.
  ]
]

#notas[
  A matriz de acesso é de #ct(<lampson1974>); capacidades foram introduzidas por #ct(<dennis1966>), e #ct(<miller2006>) desenvolveu uma teoria abrangente de composição robusta baseada em capacidades. Os princípios de projeto de proteção, inclusive o menor privilégio, são de #ct(<saltzer1975>), e o problema do delegado confuso, de #ct(<hardy1988>). Modelos de controle de acesso por papéis e por atributos são descritos em #ct(<sandhu1996>) e #ct(<hu2014>); o OAuth 2.0 é especificado em @rfc6749. O modelo de reticulado de fluxo de informação é de #ct(<denning1976>), os modelos de confidencialidade e integridade clássicos são de #ct(<bell1976>) e #ct(<biba1977>), e a não interferência, de #ct(<goguen1982>).

  Para agentes de linguagem, os riscos de injeção de instruções @greshake2023 @perez2022 tornam o problema do delegado confuso central, e o treinamento de hierarquias de instrução @wallace2024 é uma mitigação no nível do modelo — complementar, e não substituta, das garantias estruturais discutidas aqui. A distinção entre concessão canônica, diretiva de sessão e política do requisitante, a vinculação bilateral de autoridade e o catálogo de imitações de autoridade são propostas deste livro, formuladas a partir de confusões recorrentes em sistemas multiagentes.
]
