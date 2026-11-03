#import "/modelo/estilo.typ": *

= Observabilidade e depuração de contexto <cap-observabilidade>

#epigrafe[Um sistema de contexto que não pode ser inspecionado pede ao usuário que confie nele. Um que pode, permite que o verifique.]

Quando um agente erra, a primeira pergunta é: o que ele estava vendo? Em sistemas convencionais, depurar significa inspecionar estado e fluxo de controle. Em sistemas de contexto, significa inspecionar _perspectivas_ — o que foi selecionado, o que foi omitido e por quê, com que estatuto, de que fonte, sob que autoridade. Sem instrumentos para isso, a depuração se reduz a reler a conversa e adivinhar.

Este capítulo apresenta os instrumentos de observação de um sistema de contexto. A @sec-obs-tres-estados distingue declarado, observado e efetivo. A @sec-obs-inspetor descreve o inspetor de contexto. A @sec-obs-misturador apresenta o painel de contribuição por dimensão. A @sec-obs-tempo trata da linha do tempo e da comparação de perspectivas. A @sec-obs-tracos trata de traços e auditoria. A @sec-obs-saude trata de saúde e diagnóstico estratificado. A @sec-obs-delta apresenta o delta de perspectiva como ferramenta de navegação.

== Declarado, observado, efetivo <sec-obs-tres-estados>

O @cap-modelo introduziu as três colunas de informação sobre um recurso (@pri-tres-colunas). Para a depuração, a distinção se aplica com especial força à própria configuração do sistema de contexto.

#definicao(titulo: [Três estados de uma configuração])[
  Para qualquer aspecto configurável de um sistema de contexto — perfil de projeção, teto de autoridade, política de divulgação, vínculos de ambiente —, distinguem-se:
  - o _declarado_: o que a configuração afirma;
  - o _observado_: o que uma medição, feita agora, encontra;
  - o _efetivo_: o que de fato determinou o comportamento numa execução específica.
] <def-tres-estados>

#invariante(titulo: [Declarado, observado e efetivo podem divergir])[
  Uma configuração declarada pode não ter sido aplicada; uma observação pode ter sido feita num momento diferente da execução; o efetivo pode ter sido influenciado por fatores não declarados (variáveis de ambiente, padrões embutidos, caches). Uma ferramenta de depuração exibe os três e destaca as divergências.
] <inv-tres-estados>

#estudo-de-caso(titulo: [O contrato persistido que não era aplicado])[
  Uma política de seleção foi gravada corretamente na configuração de um domínio, e a ferramenta de inspeção a exibia. Mas o componente de projeção lia a política de um padrão embutido, ignorando a configuração. Durante semanas, o declarado e o observado (a leitura do arquivo) concordavam, e o efetivo era outro. A divergência só foi descoberta quando a inspeção passou a registrar, para cada perspectiva, a política _efetivamente_ usada.
] <caso-contrato-persistido>

#exercicios[
  + Dê um exemplo de divergência entre declarado e efetivo em sistemas que você conhece (por exemplo, configuração de registro, variáveis de ambiente).
  + Proponha como um componente de projeção poderia registrar o efetivo sem custo significativo.
  + Proponha como registrar, para cada perspectiva, a versão efetiva de cada política aplicada, e como comparar automaticamente o efetivo com o declarado.
]

== O inspetor de contexto <sec-obs-inspetor>

#definicao(titulo: [Inspetor de contexto])[
  Um _inspetor de contexto_ é uma ferramenta somente leitura que, dada uma coordenada — inclusive uma coordenada passada —, exibe a perspectiva calculada e, para cada segmento: função, fonte, âncora, estatuto, aplicabilidade, atualidade e regra de seleção que o incluiu; e, para cada omissão: categoria, contagem, motivo e alça de expansão. Cada item é marcado com seu _grau de resolução_: #estado[exato] (conteúdo verificado na âncora), #estado[só metadados] (referência sem conteúdo) ou #estado[não resolvido].
] <def-inspetor>

#teorema(titulo: [Reprodutibilidade de perspectivas passadas])[
  Suponha que (i) o acervo seja por acréscimo (@def-acervo) e $t$ designe um corte consistente dele (@sec-tempo-cortes); (ii) toda entrada da projeção — inclusive decisões de autoridade e o relógio usado para atualidade — esteja registrada no acervo ou na coordenada; (iii) nenhuma compactação tenha removido asserções registradas até $t$ (e as redações sejam tratadas como na @prop-reproducao-apagamento); e (iv) a versão da projeção $pi$ em uso em $t$ esteja preservada. Então a _perspectiva_ calculada em $t$ pode ser recalculada exatamente em qualquer instante posterior. O _contexto entregue_ é recalculável se, além disso, a versão de $rho$, o orçamento e o perfil foram registrados; o _consumido_ não é recalculável.
] <teo-reproducao-passada>

#prova[
  Por (i) e (iii), o acervo restrito às asserções com instante de registro até $t$ é recuperável e bem definido; por (ii), nenhuma entrada da projeção vem de fora dele ou da coordenada; pelo determinismo (P2) e por (iv), aplicar a mesma versão de $pi$ à mesma coordenada sobre o mesmo acervo produz a mesma perspectiva. A segunda parte aplica o mesmo argumento a $rho$. O consumido depende do que o modelo efetivamente usou, que não é registrado.
]

O teorema torna possível a pergunta mais útil da depuração — "o que o agente via _quando_ tomou a decisão?" — e mostra quanto é preciso registrar para que a resposta seja um cálculo, e não uma reconstrução aproximada. As hipóteses não são triviais: decisões de autoridade são, em geral, obtidas do dono no momento da decisão, e só entram na reprodução se forem registradas.

#invariante(titulo: [Inspecionar exige teto suficiente])[
  Inspecionar a perspectiva de uma coordenada $kappa$ exige um teto de autoridade que contenha o de $kappa$. Traços e registros de contexto herdam o rótulo máximo dos segmentos que contêm e têm políticas de retenção e de acesso próprias: concentram tudo o que os agentes viram, inclusive o que foi retido para outros, e são, por isso, o maior canal potencial de exfiltração do sistema (@sec-seg-fluxo).
] <inv-inspecao-teto>

#principio(titulo: [Inspecionar não altera])[
  O inspetor é uma leitura exploratória: prova a não mutação (@pri-nao-mutacao). Uma ferramenta de depuração que aquece caches, recalcula índices ou grava registros de acesso altera o sistema que pretende observar.
] <pri-inspetor-leitura>

#exercicios[
  + Especifique a saída do inspetor para uma perspectiva com dez segmentos e três categorias omitidas.
  + Que informação adicional é necessária para reproduzir uma perspectiva passada quando a projeção é estocástica (por exemplo, usa amostragem)? Relacione com o @teo-reproducao-passada.
  + Use o @teo-reproducao-passada para descrever o que deve ser retido para responder "o que o agente via" sobre uma decisão de seis meses atrás, e estime o custo de armazenamento.
]

== Contribuição por dimensão <sec-obs-misturador>

Além de mostrar _o que_ entrou numa perspectiva, um sistema de contexto precisa mostrar _por que_ o resto ficou de fora.

#definicao(titulo: [Painel de contribuição por dimensão])[
  O _painel de contribuição_ de uma perspectiva percorre as dimensões na ordem da cadeia de restrição (@def-cadeia-restricao) — autoridade, aplicabilidade, atualidade, orçamento — e mostra, para cada uma, quantos itens ela excluiu e por quê. Cada exclusão é atribuída à _primeira_ dimensão da cadeia que exclui o item, de modo que os números são aditivos. O painel permite ainda, de forma somente leitura, simular a variação de um parâmetro e ver o efeito na perspectiva.
] <def-misturador>

#figure(
  tabela(
    colunas: (auto, auto, auto, auto, 1fr),
    alinhamento: (left, right, right, right, left),
    cabecalho: ([Dimensão], [Antes], [Excluídos], [Depois], [Motivo dominante]),
    [autoridade], [200], [7], [193], [fora do teto de leitura (existência declarada)],
    [aplicabilidade], [193], [118], [75], [ramo diferente do foco],
    [atualidade], [75], [4], [71], [suplantadas por versão atual],
    [orçamento], [71], [29], [42], [prioridade baixa; declarados em $X$],
    [relevância], [42], [—], [42], [ordenação, não exclusão],
  ),
  caption: [Exemplo de painel de contribuição para uma perspectiva com 200 itens candidatos. A maior parte das exclusões se deve à aplicabilidade e ao orçamento, não à autoridade.],
) <tab-misturador>

#exercicios[
  + Interprete a @tab-misturador: que mudança na coordenada aumentaria o número de itens incluídos? Que mudança seria perigosa?
  + Por que o painel deve simular variações apenas de forma somente leitura?
  + Mostre que, sem a regra de atribuição à primeira dimensão que exclui, os números de exclusão por dimensão dependem da ordem dos filtros e deixam de somar o total.
  + Proponha uma visualização do painel de contribuição para uma perspectiva com nove dimensões e discuta como evitar que ela sugira relações causais entre dimensões (@inv-renderizacao-verdade).
]

== Linha do tempo e comparação de perspectivas <sec-obs-tempo>

A _linha do tempo_ — o histórico causal — mostra a evolução de um domínio: asserções, transições, efeitos, pontos de controle e registros de continuação, ordenados causalmente. Ela permite responder perguntas como "quando esta asserção mudou de estatuto?" e "que efeito precedeu a falha?".

A _comparação de perspectivas_ responde a outra classe de perguntas: por que dois agentes chegaram a conclusões diferentes? Por que o mesmo agente agiu diferente ontem e hoje?

#algoritmo("Compara-Perspectivas", params: $P_1, P_2$, legenda: [Comparação estruturada de duas perspectivas.])[
  + compare as coordenadas: o que difere em domínio, foco, objetivo, instante, autoridade?
  + #kw[para cada] afirmação presente em ambas #kw[faça]
    + compare estatutos, âncoras e atualidade
  + liste as afirmações presentes só em $P_1$ e só em $P_2$, com o motivo (seleção, aplicabilidade, autoridade, atualidade)
  + compare os desconhecidos declarados e as omissões
  + #kw[devolva] o relatório de diferenças, classificado por causa
] <alg-compara>

#proposicao(titulo: [Diferenças de perspectiva têm causa localizável])[
  Seja $pi$ determinística, de mesma versão e uniforme no consumidor (@teo-transferencia-minima). Se duas perspectivas diferem, então diferem as intenções de suas coordenadas, os tetos, os perfis ou os acervos sobre os quais foram calculadas.
] <prop-causa-diferenca>

#prova[
  Pela uniformidade, a perspectiva depende do consumidor apenas por meio do teto e do perfil; o restante da coordenada é a intenção. A contrapositiva de P2 dá o resultado: mesma intenção, mesmo teto, mesmo perfil, mesmo acervo e mesma versão implicam mesma perspectiva.
]

A proposição transforma "por que os agentes discordam?" em uma pergunta respondível — dois agentes sempre têm coordenadas diferentes, porque são consumidores diferentes, mas a diferença relevante está num destes cinco lugares —, e o @alg-compara diz qual.

#exercicios[
  + Dois agentes recebem a mesma tarefa e chegam a conclusões diferentes. Use o @alg-compara para descrever o diagnóstico.
  + E se as perspectivas forem iguais e as conclusões diferentes? O que isso revela?
  + Aplique o @alg-compara a duas perspectivas do mesmo agente, calculadas antes e depois de uma promoção de linha de base. Que diferenças são esperadas e quais indicariam um defeito?
]

== Traços e auditoria <sec-obs-tracos>

#definicao(titulo: [Traço de execução])[
  O _traço_ de uma execução é a sequência de pares (perspectiva consumida, ação produzida) de um agente, com coordenadas, correlações de efeito e evidências. Um traço permite reconstruir, para cada ação, o que o agente via ao produzi-la.
] <def-traco>

Traços servem a três propósitos: depuração (por que esta ação?), auditoria (esta ação estava autorizada? era sustentada por evidência?) e avaliação (com que frequência o agente age sobre perspectivas incompletas?). Para auditoria, um tipo de verificação é especialmente valioso:

#definicao(titulo: [Auditoria de junção])[
  Uma _auditoria de junção_ verifica, para cada valor apresentado numa perspectiva, de que fonte ele veio e se a junção que o produziu respeitou identidade (@inv-mesmo-nome), atualidade e autoridade. Detecta, por exemplo, uma descrição exibida para um recurso vinda, na verdade, de outro recurso com o mesmo nome.
] <def-auditoria-juncao>

#principio(titulo: [Exploração arqueológica por família])[
  Para entender um sistema herdado, explora-se por famílias de conceito — identidade, autoridade, execução, contexto —, registrando a cada passo o que foi observado e com que estatuto, num registro de continuação. O resultado é um grafo explorador derivado: útil para navegar, mas nunca autoridade sobre o sistema que descreve.
] <pri-arqueologia>

#exercicios[
  + Especifique o formato mínimo de um traço que permita reproduzir a perspectiva de cada ação.
  + Proponha uma auditoria de junção para uma interface que exibe nomes, descrições e estados de recursos.
  + Projete uma consulta sobre traços que responda: "em quantas ações com efeito o agente agiu sobre uma perspectiva que continha desconhecidos não resolvidos?". Que campos do traço ela exige?
]

== Saúde como dimensão observável <sec-obs-saude>

O @cap-higiene apresentou o diagnóstico estratificado (@tab-diagnostico) e o princípio da saúde dimensional (@pri-saude-dimensional): a saúde de um sistema de contexto é um vetor de estatutos por estrato — semântico, execução, clientes, legado —, não um semáforo. Do ponto de vista da observabilidade, duas consequências se acrescentam.

A primeira é que cada estrato é medido por um instrumento próprio, e o instrumento tem sua própria atualidade (@pri-observador-atualidade). Um verificador de saúde desatualizado, que ainda exige um artefato de uma convenção antiga, reporta degradação onde não há; um verificador que não conhece um estrato novo reporta saúde onde não se mediu nada. A ferramenta de observação exibe, junto de cada estatuto de saúde, a versão e o instante do instrumento que o produziu.

A segunda é que mudanças de saúde são eventos da linha do tempo (@sec-obs-tempo), com estatuto e proveniência como qualquer outra asserção. "O serviço de projeção ficou indisponível entre $t_1$ e $t_2$" é uma asserção que explica, depois, por que perspectivas calculadas nesse intervalo declararam desconhecidos — e evita que esses desconhecidos sejam lidos como falhas da projeção.

#invariante(titulo: [Serviço indisponível não é contexto perdido])[
  A indisponibilidade de um serviço que transporta ou calcula contexto torna o contexto temporariamente inacessível por aquele caminho; não o destrói nem o altera. O acervo e a coordenada permanecem; a perspectiva pode ser recalculada por outro caminho ou mais tarde (@teo-reproducao-passada).
] <inv-servico-indisponivel>

#exercicios[
  + Para cada estrato da @tab-diagnostico, indique o instrumento que o mede e um modo pelo qual o instrumento pode estar desatualizado.
  + Por que um serviço residente parado não implica contexto perdido? O serviço é transporte, não dono do contexto.
  + Escreva a asserção de saúde, com estatuto e proveniência, para um intervalo em que o serviço de projeção ficou indisponível, e mostre como ela explica desconhecidos em perspectivas calculadas nesse intervalo.
]

== O delta de perspectiva <sec-obs-delta>

A observação não serve só para depurar depois; serve para navegar durante. Depois de cada interação, o consumidor — ou o sistema por ele — escolhe o próximo movimento sobre a perspectiva.

#definicao(titulo: [Delta de perspectiva])[
  Dada uma perspectiva $P$ e o resultado de uma interação, o _delta_ é a saída da política de revisão (@def-saidas-portao) aplicada ao próprio consumidor durante a navegação: um dos movimentos #estado[suficiente], #estado[expandir], #estado[estreitar], #estado[recompor], #estado[pedir evidência], #estado[mudar de perspectiva], #estado[escalar], #estado[adiar] e #estado[bloquear aresta exata], com os significados definidos no @cap-portoes.
] <def-delta>

#invariante(titulo: [O delta não muda verdade, autoridade nem identidade])[
  Um movimento de delta pode mudar granularidade, observador, superfície ou modelo; nunca muda o estatuto de uma asserção, a autoridade do principal ou a identidade de um recurso. Esses mudam por transições governadas, não por navegação.
] <inv-delta>

#exercicios[
  + Para cada movimento da @def-delta, descreva uma situação em que ele é o correto.
  + Por que #estado[escalar] não é o mesmo que obter mais autoridade? Quem ganha o quê?
  + Construa uma sequência de cinco interações de um agente com os movimentos de delta correspondentes, terminando num bloqueio em aresta exata, e justifique cada movimento.
]

#quadro[
  - Declarado, observado e efetivo podem divergir; ferramentas de depuração mostram os três.
  - O inspetor exibe função, fonte, âncora, estatuto, aplicabilidade, atualidade, regra e grau de resolução; perspectivas passadas são reprodutíveis (@teo-reproducao-passada); inspecionar não altera.
  - O painel de contribuição mostra quanto cada dimensão excluiu; a linha do tempo, a evolução; a comparação, a causa das diferenças.
  - Traços ligam perspectivas a ações; a auditoria de junção verifica a origem de cada valor.
  - Saúde é dimensional; o instrumento tem atualidade própria; serviço indisponível não é contexto perdido.
  - O delta de perspectiva navega sem mudar verdade, autoridade ou identidade.
]

#problemas[
  #problema([Ferramenta integrada de depuração de contexto])[
    Projete uma ferramenta que integre o inspetor, o painel de contribuição e a linha do tempo.
    + Especifique as consultas de cada vista sobre o acervo e a projeção.
    + Garanta que todas sejam somente leitura e explique como prová-lo.
    + Proponha uma interação para "explicar por que este segmento foi omitido".
  ]
  #problema([Custo de observabilidade])[
    Registrar o efetivo e os traços tem custo de armazenamento.
    + Estime o tamanho de um traço completo por ação.
    + Proponha uma política de retenção que preserve a reprodutibilidade de perspectivas de decisões com efeito.
    + Relacione com o @teo-reproducao-passada: o que basta guardar?
  ]
  #problema([Explicações contrafactuais de seleção])[
    Uma explicação contrafactual responde: "que mudança mínima na coordenada faria o segmento $s$ entrar na perspectiva?".
    + Formalize o problema.
    + Mostre que, para seleção por limiar de relevância, a resposta pode ser calculada diretamente.
    + Discuta a dificuldade para seleção gulosa sob orçamento.
  ]
]

#notas[
  A observabilidade de sistemas distribuídos por traços foi popularizada por sistemas de rastreamento distribuído @sigelman2010; a ideia de reconstituir estados passados a partir de um registro de eventos é a do registro de eventos como fonte de verdade @kleppmann2017. Explicações de seleção relacionam-se à literatura de explicabilidade em sistemas de recuperação e recomendação. Para agentes de linguagem, a avaliação de trajetórias completas, e não só de respostas finais, é tema de levantamentos recentes @yehudai2025.

  O inspetor com graus de resolução, o painel de contribuição por dimensão, a comparação estruturada de perspectivas, a auditoria de junção e o delta de perspectiva são propostas deste livro para responder, de forma sistemática, à pergunta que domina a depuração de agentes: "o que o agente estava vendo?".
]
