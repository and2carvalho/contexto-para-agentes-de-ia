#import "/modelo/estilo.typ": *

= O ambiente de contexto e a configuração <cap-ambiente>

#epigrafe[A verdade canônica não é um único tipo de verdade.]

Agentes reais trabalham sobre ambientes compostos: vários domínios, cada um com seu acervo e sua autoridade; várias máquinas, cada uma com suas materializações; vários serviços, cada um com sua versão em execução; e uma configuração que tenta descrever tudo isso. O _ambiente de contexto_ é o nome que damos à composição, para uma situação e um consumidor, de todas essas partes — e este capítulo trata de como compô-la sem que a composição se torne, ela própria, uma autoridade ou uma fonte de verdade concorrente.

A @sec-amb-cadeia apresenta a cadeia de restrição do universo ao contexto consumido. A @sec-amb-composicao define o ambiente como composição derivada. A @sec-amb-vetor trata da visão de ambiente como vetor de coordenadas. A @sec-amb-configuracao apresenta a configuração em camadas. A @sec-amb-planos estabelece a tabela de planos de verdade da configuração. A @sec-amb-roteamento trata do roteamento de mudanças ao dono certo. A @sec-amb-degradacao discute a degradação honesta quando partes do ambiente estão indisponíveis.

== A cadeia de restrição <sec-amb-cadeia>

Entre "tudo o que existe" e "o que o modelo efetivamente usou" há uma sequência de reduções, cada uma imposta por um operador diferente.

#definicao(titulo: [Cadeia de restrição])[
  Para uma coordenada $kappa$ com teto $alpha$, a _cadeia de restrição_ é a sequência de conjuntos de asserções
  $ cal(U) supset.eq A(cal(E)(kappa)) supset.eq "leg"_alpha (cal(E)(kappa)) supset.eq A_kappa supset.eq S supset.eq T supset.eq C $
  em que $cal(U)$ é o conjunto das asserções potencialmente resolvíveis; $A(cal(E)(kappa))$ é o conteúdo assertivo do _ambiente_ — as observações adquiridas e compostas para a situação; $"leg"_alpha$ o legível sob o teto; $A_kappa = {a : "apl"(a, kappa) in {sans(V), sans(D)}}$ o aplicável (ou possivelmente aplicável) legível; $S = F union R$ o selecionado sob orçamento, isto é, o conteúdo da perspectiva; $T$ o efetivamente transportado à janela do consumidor; e $C$ o consumido — aquilo a que o consumidor de fato atendeu. Cada inclusão é imposta, respectivamente, por: aquisição e composição; filtro de autoridade; aplicabilidade; seleção; renderização e transporte; atenção do consumidor. O que fica de fora de cada elo é contabilizado — em $X$, em $Phi$ ou em marcas de omissão — conforme P5 e a política de divulgação (@def-politica-divulgacao), que decide o que se declara sobre o que não é legível.
] <def-cadeia-restricao>

#figure(
  {
    let nivel(rotulo, cor-borda, corpo) = block(
      width: 100%, stroke: 0.7pt + cor-borda, radius: 3pt, inset: (x: 7pt, top: 5pt, bottom: 7pt),
      [#text(size: 8pt, fill: cor-borda, weight: "bold")[#rotulo] #v(2pt) #corpo],
    )
    set align(left)
    block(width: 88%, nivel([universo resolvível $cal(U)$ — _aquisição e composição_], cor.primaria,
      nivel([ambiente $cal(E)(kappa)$ — _filtro de autoridade_], cor.secundaria,
        nivel([legível $"leg"_alpha$ — _aplicabilidade_], cor.inv,
          nivel([aplicável $A_kappa$ — _seleção sob orçamento_], cor.princ,
            nivel([selecionado $S$ — _renderização e transporte_], cor.anti,
              nivel([transportado $T$ — _atenção do consumidor_], cor.caso,
                text(size: 8pt)[consumido $C$])))))))
  },
  caption: [A cadeia de restrição. Cada nível indica, em itálico, o operador que impõe a passagem ao nível seguinte. Ao procurar onde uma informação "sumiu", pergunte em qual fronteira ela foi barrada — e por qual operador.],
) <fig-cadeia-restricao>

#invariante(titulo: [O ambiente sabe mais do que o consumidor vê])[
  Que uma informação esteja no ambiente não significa que seja legível pelo consumidor; que seja legível e aplicável não significa que tenha sido selecionada; que tenha sido selecionada não significa que tenha sido entregue; que tenha sido entregue não significa que tenha sido consumida. Cada fronteira é um lugar diferente onde informação pode ser retida — legitimamente ou por erro.
] <inv-ambiente-consumidor>

A cadeia é uma ferramenta de diagnóstico. Quando um agente "não sabia" de algo, a pergunta útil não é "por que ele não sabia?", mas "em que fronteira a informação parou?". Não adquirida, não legível, não aplicável, não selecionada, não entregue (truncada no transporte) ou não atendida (perdida no meio de um contexto longo): cada resposta aponta para um operador e uma correção diferentes.

#exercicios[
  + Para um caso em que um agente ignorou uma restrição importante, determine em que fronteira da cadeia ela foi perdida.
  + Por que a distinção entre $T$ (transportado) e $C$ (consumido) é relevante, dados os efeitos de posição do @cap-llm? Como medir $C$?
  + Mostre que, se a seleção sob orçamento fosse feita antes do filtro de autoridade, a escolha dos itens legíveis que sobrevivem poderia depender de itens ilegíveis, violando a não interferência (@teo-nao-interferencia).
  + Para cada inclusão da cadeia de restrição (@def-cadeia-restricao), dê o operador responsável, um exemplo de perda legítima e um exemplo de perda defeituosa num agente de suporte ao cliente.
]

== O ambiente como composição derivada <sec-amb-composicao>

#definicao(titulo: [Ambiente de contexto])[
  O _ambiente de contexto_ de uma situação é uma composição limitada e com proveniência do universo operacional corrente, formada por componentes de donos distintos — identidades de domínios, composição desejada, pertinências autoritativas, materializações em nós, coordenadas de execução, vínculos de consumidores, governança e objetivos, perspectivas, referências de fonte, evidência e linhas de base. O ambiente compõe autoridades sem absorvê-las: é um modelo de leitura derivado, não um acervo, não uma composição de domínios e não uma autoridade.
] <def-ambiente>

O @inv-ambiente-autoridade já estabeleceu que o ambiente não tem autoridade própria. A fórmula que resume a definição é a epígrafe do @cap-espacos: gestão central sem posse semântica central. O ambiente permite ver, num só lugar, o que está espalhado; ele não decide nada sobre o que mostra.

#antipadrao(titulo: [O ambiente que absorve])[
  Um componente central compõe o ambiente e, por conveniência, passa a guardar cópias das informações dos domínios, a responder perguntas de autoridade com base nelas e a aceitar escritas que "propaga" depois. Ele se tornou um acervo global concorrente, com a pior combinação de propriedades: é o lugar mais consultado e o menos autoritativo.
] <anti-ambiente-absorve>

#exercicios[
  + Liste os componentes do ambiente de um agente que trabalha em dois domínios em duas máquinas, indicando o dono de cada um.
  + Explique por que um ambiente que guarda cópias dos acervos dos domínios viola o @pri-dono-semantico.
  + Explique por que um ambiente que "absorve" as fontes que compõe (copiando-as para um armazenamento próprio) passa a competir com elas como fonte de verdade. Que regra de projeto evita o problema?
]

== A visão de ambiente como vetor de coordenadas <sec-amb-vetor>

Como os componentes do ambiente são observados por fontes diferentes, em momentos diferentes, a forma correta de representar o ambiente não é um "estado em $t$", mas um vetor.

#definicao(titulo: [Visão de ambiente])[
  Uma _visão de ambiente_ é um vetor $V = (v_1, dots, v_n)$ em que cada componente $v_i$ — identidade de domínio, composição desejada, pertinência observada, registro de nó, coordenada de artefato em execução, linha de base, vínculo de consumidor, revisão de perspectiva — carrega (fonte, revisão, instante de observação, frescor, estatuto). Não há uma revisão global única do ambiente.
] <def-visao-ambiente>

#proposicao(titulo: [Visões úteis sem consistência global])[
  Uma visão de ambiente responde corretamente a uma pergunta $q$ se (i) $q$ declara de quais componentes depende, (ii) esses componentes estão presentes na visão com frescor suficiente para $q$ (@def-frescor-condicionado) e (iii) $q$ não exige que componentes de fontes diferentes tenham sido observados simultaneamente. Quando (iii) é exigido, a visão deve ser um corte consistente demonstrado (@teo-corte-vetorial).
] <prop-visao-util>

#prova[
  Sob (i) e (ii), a resposta é função dos componentes declarados, cada um suficientemente fresco; a falta de simultaneidade entre componentes não declarados não afeta a resposta. A condição (iii) captura exatamente as perguntas cujo valor depende da simultaneidade; para elas, só um corte consistente garante que a combinação observada poderia ter ocorrido.
]

#exercicios[
  + Dê um exemplo de pergunta que exige simultaneidade entre componentes e outra que não exige.
  + Proponha uma representação compacta da visão de ambiente para renderização ao consumidor.
  + Dê um exemplo de pergunta que uma visão de ambiente sem consistência global responde corretamente e de outra que ela não pode responder sem um corte consistente (Apêndice D).
]

== Configuração em camadas <sec-amb-configuracao>

Humanos querem descrever um ambiente num único arquivo legível. Sistemas precisam de partes com donos e ciclos de vida diferentes. A solução não é escolher entre os dois, mas _compilar_ o primeiro no segundo.

#definicao(titulo: [Três camadas de configuração])[
  - A _composição portátil_ declara o ambiente desejado em termos de domínios, relações e requisitos (por exemplo, "o domínio $A$ precisa de leitura em $B$"). É versionável e não contém nada específico de uma máquina — nem caminhos, nem endereços, nem segredos.
  - A _sobreposição do hospedeiro_ diz _como_ esta máquina resolve e materializa o ambiente: localizadores candidatos para cada domínio, endereços de serviços, preferências de execução, _referências_ a credenciais, apelidos. Nunca diz o que os domínios autorizam.
  - A _entrada de perspectiva_ diz o que o consumidor quer agora: objetivo, perfil, foco. É efêmera.
] <def-tres-camadas-config>

#definicao(titulo: [Compilador de intenção])[
  Um _compilador de intenção_ transforma um arquivo de configuração escrito por um humano nas três camadas: normaliza (forma canônica, resumo), decompõe (o que é portátil, o que é do hospedeiro, o que é da perspectiva), resolve, observa e _planeja_ — sem aplicar. Para cada item, produz: estado desejado, relação, acesso requerido, autoridade (e sua fonte), locus, materializado, ativo, bloqueio, dono e próxima aresta.
] <def-compilador-intencao>

#invariante(titulo: [Um arquivo para escrever não é um arquivo de verdade])[
  A conveniência de escrever a configuração num só arquivo não faz desse arquivo a fonte canônica de todas as verdades que ele menciona. Um arquivo central que reúne todas as variáveis de um processo não é, por isso, um dono semântico; uma composição que declara "precisa de leitura" não concede leitura; uma seção de perspectiva que declara um objetivo não concede autoridade.
] <inv-arquivo-verdade>

A resolução de um valor de configuração percorre seis níveis de precedência — valor padrão de referência, hospedeiro, domínio, aplicação, sessão e objetivo —, que se distribuem pelas três camadas: o padrão, o domínio e a aplicação pertencem à composição portátil; o hospedeiro, à sobreposição do hospedeiro; a sessão e o objetivo, à entrada de perspectiva. A ordem intercala as camadas — a sobreposição do hospedeiro prevalece sobre os padrões, mas não sobre o que o domínio e a aplicação declaram —, e um nível mais específico prevalece sobre um mais geral, com uma restrição: nenhum nível fabrica autoridade (@prop-camadas-restricao).

#exercicios[
  + Separe nas três camadas um arquivo de configuração de um projeto seu que mistura dependências, caminhos locais e preferências pessoais.
  + Escreva um verificador ("lint semântico") que detecte vazamento de hospedeiro — caminhos, endereços, identificadores de máquina ou segredos — na composição portátil.
  + Escreva, para um projeto com dois serviços e um banco de dados, as três camadas de configuração (portátil, local, segredos) e indique qual delas cada pessoa ou agente pode editar.
]

== A tabela de planos de verdade <sec-amb-planos>

#figure(
  tabela(
    colunas: (1.1fr, 1fr, 1.2fr, 1.3fr),
    cabecalho: ([Plano], [Portabilidade], [Quem edita], [Exemplos]),
    [Configuração desejada], [versionada, portátil], [humano (dono da composição)], [domínios, relações, requisitos],
    [Identidade], [portátil com cuidado], [ninguém (marcador estável)], [identificador soberano do domínio],
    [Estado soberano], [federável, não copiável], [transições governadas], [decisões, evidências, unidades de trabalho],
    [Vínculo de nó e segredos], [local], [o sistema, por operação], [localizadores, referências a credenciais],
    [Topologia corrente], [recalculável], [ninguém (modelo de leitura)], [o que está materializado e ativo agora],
  ),
  caption: [Planos de verdade da configuração. "A verdade canônica não é um único tipo de verdade": cada plano tem portabilidade, editor e semântica próprios.],
) <tab-planos-verdade>

Várias distinções práticas seguem da tabela.

#invariante(titulo: [Replicar configuração não é clonar identidade])[
  Criar um domínio a partir da configuração de outro produz um domínio _novo_, com identidade própria. Retomar um domínio existente noutra máquina é outra operação, que preserva a identidade. Copiar a configuração e o acervo de um domínio não cria "o mesmo domínio" noutro lugar — cria, no máximo, uma cópia não autorizada.
] <inv-replicar-clonar>

#invariante(titulo: [Selecionar não é editar])[
  Mudar o domínio corrente de uma sessão é um vínculo local (coordenada); não exige — e não deve ser feito por — edição da configuração.
] <inv-selecionar-editar>

#invariante(titulo: [Documentação não é configuração corrente])[
  Textos em prosa que descrevem a topologia não competem com a configuração nem com a topologia projetada. Quando um agente precisa ler documentação para descobrir a topologia, há uma lacuna de projeção; a documentação passa a ser histórico assim que a topologia é projetada.
] <inv-documentacao-config>

#exercicios[
  + Classifique nas linhas da @tab-planos-verdade: o identificador de um domínio; o caminho de sua cópia numa máquina; a decisão de que ele depende de outro; a versão do serviço em execução.
  + Uma configuração antiga estava correta quando foi escrita e hoje não está. Ela deve ser apagada, corrigida ou rebaixada a histórico? Justifique.
  + Classifique, na @tab-planos-verdade, cada um dos itens: a lista de domínios de uma composição; o caminho de uma materialização local; a chave de acesso a um serviço; a decisão que aceitou uma versão; o conjunto de serviços em execução agora.
]

== Roteamento de mudanças ao dono certo <sec-amb-roteamento>

Quando um humano ou agente quer mudar algo no ambiente, a mudança precisa chegar ao dono certo — e cada tipo de mudança tem um dono diferente.

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Mudança], [Dono]),
    [nova fonte de um recurso], [o domínio que governa o recurso],
    [domínio entra numa composição], [o dono da composição],
    [novo caminho de materialização], [a sobreposição do hospedeiro],
    [nova concessão de leitura], [o dono da autoridade do alvo],
    [nova versão em execução], [o dono do efeito de implantação, sob governança],
    [novo conhecimento ou decisão], [o acervo do domínio, por transição governada],
    [novo objetivo], [o titular, por declaração explícita],
    [nova política de verificação], [o dono da política],
  ),
  caption: [Roteamento de mudanças. Sem roteamento por dono, mudanças de hospedeiro vazam para a composição portátil e mudanças de objetivo são inferidas de mensagens.],
) <tab-roteamento-mudancas>

#estudo-de-caso(titulo: [Oito mudanças, oito donos])[
  Uma auditoria examinou oito mudanças recentes num ambiente — de fonte, composição, sobreposição, autoridade, execução, conhecimento, objetivo e política. Sem roteamento explícito, duas tinham ido parar no lugar errado: uma mudança de caminho local fora gravada na composição portátil (que passou a quebrar em outras máquinas), e uma mudança de objetivo fora inferida pelo agente a partir de uma conversa, sem declaração do titular. A correção introduziu a pergunta "quem é o dono desta mudança?" como primeiro passo de toda edição.
] <caso-oito-mudancas>

#exercicios[
  + Para cada linha da @tab-roteamento-mudancas, descreva o efeito de rotear a mudança para o dono errado.
  + Proponha uma interface de edição que pergunte ao usuário o dono antes de aceitar uma mudança.
  + Para cinco pedidos de mudança expressos em linguagem natural ("troque a porta do serviço", "adicione o repositório $R$ ao projeto", "use a versão 2 da biblioteca"…), indique o dono que deve recebê-los e o plano de verdade afetado.
]

== Degradação honesta <sec-amb-degradacao>

Partes do ambiente ficam indisponíveis: o serviço de autoridade não responde, uma máquina está desligada, o remoto não pode ser consultado. A tentação é preencher o buraco — com o último valor conhecido, com um valor padrão, com uma inferência. A alternativa honesta é mostrá-lo.

#principio(titulo: [Mostrar o buraco sem preenchê-lo])[
  Quando um plano do ambiente está indisponível, a visão mostra o componente como #est[desconhecido], com o motivo, e calcula tudo o que é possível calcular sem ele. A indisponibilidade não é uma falha do sistema de contexto; inventar uma fonte substituta de autoridade, sim.
] <pri-buraco>

#invariante(titulo: [Não inventar autoridade fora do ar])[
  Se o serviço de autoridade está indisponível, a pertinência e as concessões que dependem dele são #estado[desconhecidas] — não "assumidas como antes" nem "inferidas do que está localmente materializado". Ações que dependem delas não são autorizadas até que a autoridade volte a responder.
] <inv-autoridade-fora>

#estudo-de-caso(titulo: [Leitura remota com execução antiga])[
  Um agente precisava ler um domínio materializado noutra máquina. O transporte funcionava, mas o serviço remoto executava uma versão antiga, que não expunha a operação de leitura necessária. Duas soluções erradas estavam ao alcance: traduzir a operação nova para algo que a versão antiga entendesse, ou abrir um executor genérico remoto. A resposta correta foi registrar a capacidade remota como #estado[desatualizada] e convergir a execução remota (@cap-runtime) — e, até lá, mostrar o domínio remoto como conhecido, mas não legível.
] <caso-remoto-antigo>

#exercicios[
  + Descreva a visão de ambiente de um agente quando o serviço de autoridade está fora do ar. Que perguntas ela ainda responde?
  + Por que "traduzir para a versão antiga" é uma solução ruim no @caso-remoto-antigo? Relacione com o @inv-sucesso-comando e com a dívida de contexto.
  + Um serviço de autoridade está fora do ar. Escreva a perspectiva honesta de um agente que precisa decidir se pode implantar uma correção, mostrando "o buraco" sem preenchê-lo.
]

#quadro[
  - A cadeia de restrição — universo, ambiente, legível, aplicável, selecionado, transportado, consumido — localiza onde a informação parou.
  - O ambiente é composição derivada, com proveniência; compõe autoridades sem absorvê-las.
  - A visão de ambiente é um vetor de componentes com fonte, revisão, instante e estatuto; não há revisão global.
  - Configuração em três camadas: composição portátil, sobreposição do hospedeiro, entrada de perspectiva; compile a intenção humana nas camadas.
  - A tabela de planos de verdade dá a cada plano sua portabilidade e seu editor; replicar configuração não é clonar identidade.
  - Toda mudança é roteada ao seu dono.
  - Degrade honestamente: mostre o buraco, não invente autoridade.
]

#problemas[
  #problema([Composição de ambientes e teto de autoridade])[
    Dois ambientes são compostos num ambiente maior para um objetivo de coordenação.
    + Defina a composição de visões de ambiente.
    + Prove que, se a autoridade efetiva de um consumidor sobre cada recurso é a interseção das autoridades dos domínios relevantes, a composição não eleva o teto de nenhum consumidor.
    + Dê um exemplo de implementação ingênua de composição que viola a propriedade.
  ]
  #problema([Compilador de intenção])[
    Especifique o compilador de intenção da @def-compilador-intencao.
    + Defina a gramática de entrada e a forma canônica.
    + Defina a decomposição em camadas e as regras de detecção de vazamento.
    + Mostre que o compilador nunca produz efeitos (ele planeja, não aplica) e discuta como testar essa propriedade.
  ]
  #problema([Diagnóstico pela cadeia de restrição])[
    Proponha uma ferramenta que, dado um item de informação e uma sessão de agente, determine automaticamente em que fronteira da cadeia de restrição o item parou.
    + Que registros de cada operador seriam necessários?
    + Como lidar com a fronteira "consumido", que não é diretamente observável?
    + Discuta o custo de manter esses registros.
  ]
]

#notas[
  A separação entre estado desejado declarado, estado observado e laços que os reconciliam é central nos orquestradores de contêineres @burns2016 @verma2015; a gestão de configuração por promessas @bergstra2014 enfatiza que cada agente só promete sobre si mesmo, de modo compatível com o roteamento de mudanças ao dono. A impossibilidade de um instantâneo global gratuito em sistemas distribuídos @chandy1985 e o teorema CAP @gilbert2002 fundamentam a visão de ambiente como vetor e a degradação honesta. #ct(<kleppmann2017>) discute em profundidade a diferença entre sistemas de registro e dados derivados, base do ambiente como modelo de leitura.

  A cadeia de restrição, a configuração em três camadas, o compilador de intenção, a tabela de planos de verdade e o roteamento de mudanças por dono são propostas deste livro; não conhecemos tratamento anterior com essa forma. O problema que motivam — um único arquivo de configuração tornar-se, inadvertidamente, fonte de verdade para coisas que não lhe pertencem — é recorrente em ambientes com vários domínios e máquinas.
]
