#import "/modelo/estilo.typ": *

= Orquestração de agentes <cap-orquestracao>

#epigrafe[O executor otimiza a correção local; o supervisor otimiza a coerência do sistema. Nenhum dos dois é o modelo — são posições de onde se observa.]

Um único agente, com uma única janela, enfrenta os limites dos capítulos anteriores: pressão de contexto, perda por compactação, atenção diluída. Vários agentes cooperando podem contorná-los — cada um com sua janela, sua perspectiva e sua tarefa. Mas a cooperação tem custos: o contexto precisa ser transferido entre agentes, as perspectivas precisam permanecer coerentes, e a autoridade precisa continuar sendo de quem deve ser.

Este capítulo trata da orquestração como problema de contexto. A @sec-orq-porque discute quando vários agentes ajudam. A @sec-orq-papeis define papéis como posições observacionais. A @sec-orq-laco descreve o laço de orquestração governada. A @sec-orq-fases apresenta a escada de fases de risco. A @sec-orq-divisao trata da divisão e conquista contextual. A @sec-orq-patologias cataloga patologias típicas. A @sec-orq-classicos relaciona o tema à literatura clássica de sistemas multiagentes.

== Quando vários agentes ajudam <sec-orq-porque>

Há quatro razões principais para dividir trabalho entre agentes.

/ Isolamento de contexto: cada agente tem uma janela limpa, dedicada à sua subtarefa. Se o conjunto de trabalho da tarefa inteira excede a janela efetiva (@def-pressao), dividi-la em subtarefas com conjuntos de trabalho menores evita a pressão de contexto.

/ Paralelismo: subtarefas independentes podem ser executadas ao mesmo tempo — por exemplo, investigar várias fontes de informação numa pesquisa ampla.

/ Especialização: perspectivas diferentes servem a funções diferentes — uma com alta resolução sobre o código, outra com visão ampla da coerência do sistema.

/ Separação de poderes: quem propõe, quem revisa e quem executa podem ser agentes diferentes, o que evita que um único consumidor transforme sua opinião em efeito sem verificação (@tab-papeis-laco).

Os custos são igualmente concretos: um relato de engenharia estima que agentes consomem cerca de quatro vezes mais tokens que uma conversa, e sistemas multiagentes cerca de quinze vezes mais @anthropic2025multiagent; cada transferência entre agentes é uma oportunidade de perda e de distorção (@cap-handoff); e perspectivas de agentes diferentes podem divergir sem que ninguém perceba (@tab-comparacao). A orquestração vale a pena quando o ganho em isolamento, paralelismo, especialização ou separação de poderes supera esses custos — o que é frequente em tarefas amplas e de alto valor, e raro em tarefas pequenas e acopladas.

#exercicios[
  + Para cada uma das quatro razões, dê uma tarefa em que ela justifica vários agentes e outra em que não justifica.
  + Por que tarefas fortemente acopladas — em que cada passo depende do anterior — se beneficiam pouco do paralelismo entre agentes?
  + Estime, para uma tarefa de pesquisa com cinco subtópicos independentes, o custo em tokens de um único agente e de um orquestrador com cinco subagentes, supondo retornos de 800 tokens. Que fatores tornariam o arranjo multiagente mais caro?
]

== Papéis como posições observacionais <sec-orq-papeis>

#definicao(titulo: [Papéis de orquestração])[
  - O _supervisor_ é um consumidor de granularidade grossa e contexto amplo, porém limitado: interpreta o objetivo, recomenda, propõe pacotes de trabalho e revisa resultados estruturados quanto à coerência do sistema.
  - O _titular_ decide: aceita ou não a prévia, escolhe objetivos, concede autoridade.
  - O _orquestrador_ (ou coordenador) decompõe o trabalho aceito, re-resolve atualidade, funcionalidade e autoridade, distribui subtarefas e integra os retornos; tem contexto amplo de _plano_ e estreito de _detalhe_.
  - O _executor_ realiza uma subtarefa delimitada, com contexto fino da subtarefa; otimiza a correção local.
  - O _revisor_ (ou auditor) compara o pedido com o observado.
  A _prévia_ não é um papel, mas um artefato: um turno preparado (@alg-prepara-turno) que torna visíveis, antes da execução, o contexto selecionado, os alvos, as funcionalidades, as lacunas de autoridade, o fluxo previsto, as validações e as evidências esperadas.
] <def-papeis-orquestracao>

#principio(titulo: [Papéis não são modelos])[
  Um papel é uma posição de observação com função definida — não um modelo, uma personalidade ou uma pessoa. O mesmo modelo pode ocupar qualquer papel, e um humano também; o sistema escolhe quais posições precisam ser ocupadas para um trabalho. Papéis também não são autoridade: supervisor, orquestrador e executor têm a autoridade que a política do hospedeiro lhes concede para cada tarefa, nada mais.
] <pri-papeis-modelos>

#invariante(titulo: [Correção local e coerência sistêmica])[
  O executor responde pela correção na granularidade da subtarefa; o supervisor, pela coerência na granularidade do sistema; o orquestrador, pela integração entre as duas. Um "os testes passaram" do executor não responde à pergunta do supervisor ("isto é coerente com a arquitetura e com os invariantes?"), e uma recomendação do supervisor não responde à do executor ("isto funciona aqui, agora?").
] <inv-correcao-coerencia>

#exercicios[
  + Atribua os papéis da @def-papeis-orquestracao num fluxo de trabalho de correção de uma falha de produção com três agentes e um titular humano.
  + Dê um exemplo em que o mesmo modelo, ocupando papéis diferentes, deve receber perspectivas diferentes.
  + Por que o supervisor, que tem contexto amplo, não deve executar efeitos diretamente? Relacione com a separação de poderes do @cap-ciclo-acao.
]

== O laço de orquestração governada <sec-orq-laco>

#algoritmo("Orquestra", params: $o$, legenda: [Laço de orquestração governada para um objetivo $o$.])[
  + o supervisor resolve $o$, seleciona contexto amplo e limitado, lista desconhecidos e recomenda
  + o supervisor propõe um pacote de trabalho estruturado (@cap-handoff)
  + monta-se a prévia: contexto, alvos, funcionalidades, lacunas de autoridade, fluxo, efeitos bloqueados, validações e evidências esperadas
  + o titular aceita (ou não); a aceitação liga a prévia, o objetivo, os alvos, as restrições, as proibições, as validações e as coordenadas de atualidade
  + #kw[se] o titular não aceita #kw[então] #kw[devolva] #estado[recusado], com a razão registrada
  + o orquestrador re-resolve atualidade, funcionalidade e autoridade
  + calcule a afetação das mudanças ocorridas desde a prévia sobre o que ela leu (@alg-afetacao)
  + #kw[se] a afetação é #estado[refazer], #estado[conflito semântico] ou #est[desconhecido] #kw[então] #kw[devolva] #estado[bloqueado: nova prévia necessária]
  + #kw[se] a afetação é #estado[renovar prova] ou #estado[só reconciliação] #kw[então] revalide as provas afetadas, ou integre as histórias, antes de prosseguir
  + o orquestrador conduz o fluxo, com executores, sob governança (@alg-mutacao-governada)
  + produz-se um resultado estruturado (pacote de retorno)
  + o revisor compara pedido e observado: a prova está completa? é coerente? é proporcional? deve-se continuar?
] <alg-orquestra>

O laço termina em todas as suas saídas: cada linha é executada no máximo uma vez, e a execução (linha 10) herda o término do @alg-mutacao-governada. Nenhum efeito ocorre antes da linha 10, e esta só é alcançada com aceitação do titular e afetação nula ou revalidada desde a prévia — que é o conteúdo do invariante seguinte.

#invariante(titulo: [Aceitação vale para a coordenada aceita])[
  A aceitação do titular liga-se à coordenada da prévia. Se o mundo mudou de modo que afeta o que a prévia leu — um alvo foi alterado, uma autoridade revogada, uma linha de base promovida sobre os mesmos sujeitos —, a aceitação não se transfere silenciosamente: a execução fica bloqueada até uma nova prévia. Mudanças sem efeito sobre a prévia não a invalidam: divergência não é afetação (@inv-historias-divergentes).
] <inv-aceitacao-coordenada>

#principio(titulo: [A prévia é desenhada para ser recusável])[
  Toda a governança termina numa aceitação humana, e humanos aprovam por hábito: o viés de automação e a confiança mal calibrada em sistemas automáticos são bem documentados @parasuraman1997 @lee2004trust. A prévia mostra primeiro o que mudaria e o que é irreversível; limita o número de aprovações por unidade de tempo; inclui, periodicamente, prévias com defeito injetado — a fase 0 aplicada ao titular —; e a taxa de recusas é medida como indicador de saúde da governança.
] <pri-previa-recusavel>

#principio(titulo: [Pacote não é plano])[
  O pacote proposto pelo supervisor é um contrato entre consumidores — objetivo, restrições, proibições, evidência esperada, formato de retorno —; não é o plano resolvido. O plano é calculado pelo orquestrador a partir do pacote e da realidade atual. Duplicar a função de planejamento no supervisor e no orquestrador produz dois planos divergentes.
] <pri-pacote-plano>

#exercicios[
  + No @alg-orquestra, por que o orquestrador re-resolve autoridade mesmo depois da aceitação do titular? Relacione com o @inv-autoridade-tempo.
  + Descreva o conteúdo mínimo de uma prévia para uma mudança de configuração em produção.
  + Escreva a prévia (@sec-ap-previa) de uma tarefa de atualização de dependências e indique quais campos a aceitação do titular liga à coordenada.
]

== A escada de fases <sec-orq-fases>

Introduzir agentes autônomos num processo real é arriscado. Uma progressão por fases, cada uma com sua evidência, reduz o risco.

#definicao(titulo: [Escada de fases])[
  - _Fase 0 — semântica sem efeito_: o fluxo é executado sem nenhum efeito real, com um _defeito injetado_ deliberadamente (por exemplo, um resultado que alega sucesso sem a validação exigida), para testar se o revisor o rejeita.
  - _Fase 1 — mediação por modelo sem efeito_: os agentes de linguagem participam, mas nenhuma ação é executada.
  - _Fase 2 — investigação real somente leitura_: os agentes observam o ambiente real, com prova de não mutação.
  - _Fase 3 — fechamento epistêmico_: as conclusões da investigação são estabelecidas na coordenada corrente, com evidência.
  - _Fase 4 — um efeito limitado e reversível_: um único efeito, num ambiente descartável.
  - _Fase 5 — efeitos reais_: cada efeito real com autorização própria, ligada à linha de base, com atualidade antes e depois, correlação efeito–evidência, validação independente e política de reversão.
] <def-escada-fases>

#fato(titulo: [Fases não se implicam])[
  O sucesso numa fase não constitui evidência suficiente para a fase seguinte.
] <prop-fases>

#prova[
  Cada fase introduz um fator ausente da anterior — modelos reais, dados reais, conclusões na coordenada corrente, efeitos, efeitos reais. Para cada par consecutivo, há sistemas que passam na fase anterior e falham na seguinte por causa exatamente do fator introduzido; logo a evidência da anterior não cobre a seguinte.
]

A fase 0 com defeito injetado merece destaque: ela testa o _revisor_, não os executores — a mesma ideia do teste de mutação em engenharia de software @demillo1978, que avalia uma bateria de testes pela sua capacidade de detectar defeitos semeados. Um sistema em que o revisor aprova um resultado sem a validação exigida não está pronto para nenhuma fase posterior, por mais que os executores pareçam competentes.

#exercicios[
  + Proponha o defeito injetado da fase 0 para um fluxo de atualização de dependências.
  + Que evidência você exigiria para passar da fase 4 à fase 5?
  + Para um sistema de agentes que vai operar um banco de dados de produção, descreva o que seria demonstrado em cada fase da escada e o defeito injetado na fase 0.
]

== Divisão e conquista contextual <sec-orq-divisao>

O padrão mais comum de orquestração com agentes de linguagem é o de _orquestrador e trabalhadores_: um agente principal decompõe a tarefa, delega subtarefas a subagentes com janelas limpas e recebe deles resultados condensados @anthropic2025multiagent @anthropic2024agents. Do ponto de vista de contexto, o padrão é uma aplicação do conjunto de trabalho: a janela do orquestrador contém apenas o plano, as coordenadas e os resultados condensados; o detalhe de cada subtarefa vive na janela do subagente correspondente e morre com ela — salvo o que for registrado.

#principio(titulo: [O orquestrador vê retornos, não transcrições])[
  O contexto do orquestrador recebe dos subagentes pacotes de retorno estruturados (@cap-handoff), não suas transcrições. A transcrição completa de um subagente na janela do orquestrador anula o isolamento de contexto que justificou a delegação.
] <pri-retornos>

Para trabalho que atravessa domínios soberanos, a mesma lógica se aplica em escala maior: um objetivo de coordenação (@def-objetivo-coordenacao) relaciona unidades de trabalho em cada domínio, e a perspectiva de coordenação contém interfaces, dependências, contribuições, provas e a trajetória crítica — não os detalhes de cada domínio.

#exercicios[
  + Um orquestrador delega cinco subtarefas de pesquisa. Estime o tamanho do seu contexto com retornos estruturados e com transcrições completas.
  + Quando a divisão em subagentes _piora_ o resultado? Dê um exemplo em que o contexto necessário para cada subtarefa é quase o contexto inteiro.
  + #avancado Modele a divisão de uma tarefa em subagentes como um problema de partição do conjunto de trabalho com custo de comunicação. Mostre que, se o grafo de dependências entre itens é completo, nenhuma partição reduz o contexto de cada subagente abaixo de $omega$.
]

== Patologias de orquestração <sec-orq-patologias>

#antipadrao(titulo: [Orquestração por instrução])[
  O orquestrador apenas repassa ao executor, em prosa, a instrução que recebeu, sem coordenadas, sem restrições explícitas e sem formato de retorno. O executor reinterpreta; o resultado volta em prosa; ninguém consegue verificar se o que foi feito corresponde ao pedido.
] <anti-orquestracao-instrucao>

#antipadrao(titulo: [Redução da definição de concluído por parecer grande])[
  Um executor, diante de uma tarefa que "parece grande", reduz por conta própria os critérios de concluído e relata sucesso sobre a versão reduzida. A hesitação do executor não é uma decisão de arquitetura: o correto é tentar, e, diante de uma falha concreta, devolver uma lacuna tipada e deixar a decisão a quem tem autoridade.
] <anti-reducao-dod>

#antipadrao(titulo: [O objeto do trabalho tratado como pré-requisito])[
  Um executor interrompe o trabalho alegando que falta uma funcionalidade — quando construir essa funcionalidade é exatamente o objeto do trabalho. Antes de declarar um bloqueio, compara-se a lacuna com a razão de existir da unidade de trabalho.
] <anti-objeto-prerequisito>

#antipadrao(titulo: [Modelo revisando modelo sem portões])[
  A revisão de um resultado consiste em pedir a outro modelo que leia o relatório e opine. Sem portões determinísticos sobre o resultado estruturado — validações exigidas, evidências ancoradas, estatutos —, a revisão é apenas uma segunda opinião sobre um texto.
] <anti-modelo-revisa>

#exercicios[
  + Para cada antipadrão, descreva o mecanismo estrutural que o previne.
  + Por que relatos de sucesso de executores precisam ser verificados mesmo quando o executor é um modelo muito capaz? Relacione com o @inv-sucesso-comando.
  + Descreva um teste que detecte automaticamente a patologia "redução da definição de concluído", comparando os critérios do pacote com os itens do retorno.
]

== Relação com sistemas multiagentes clássicos <sec-orq-classicos>

A orquestração de agentes de linguagem reencontra problemas estudados há décadas na pesquisa em sistemas multiagentes @wooldridge2009. O _protocolo de rede de contratos_ @smith1980 propõe que um gerente anuncie tarefas e agentes ofertem para executá-las — uma forma de alocação de trabalho com contrato explícito, próxima da ideia de pacote. Os _sistemas de quadro-negro_ @nii1986 coordenam especialistas por meio de uma estrutura de dados compartilhada que todos leem e onde todos escrevem — antecessor direto do acervo compartilhado, com o problema de controle de escrita que aqui resolvemos por reservas e governança. O _modelo de atores_ @hewitt1973 trata a computação como troca de mensagens entre entidades isoladas — o isolamento de contexto entre subagentes é uma forma desse isolamento. Linguagens de comunicação entre agentes @finin1994, baseadas na teoria dos atos de fala @searle1969, distinguiram tipos de mensagem (informar, pedir, propor), antecipando a distinção entre funções de segmentos. E a arquitetura de crenças, desejos e intenções @rao1995 separou o que o agente acredita do que deseja e do que se comprometeu a fazer.

Uma contribuição clássica é especialmente pertinente: a teoria do _trabalho em equipe_ como compromisso conjunto @cohen1991teamwork. Membros de uma equipe se comprometem com um objetivo comum _e_ com uma obrigação adicional: quando um membro descobre que o objetivo foi atingido, tornou-se impossível ou deixou de ser relevante, deve tornar isso mutuamente conhecido, em vez de simplesmente parar. É a fundamentação formal do pacote de retorno com veredito explícito e da preservação do desconhecido diante de hipóteses contraditas (@cap-handoff). Taxonomias empíricas recentes de falhas de sistemas multiagentes de linguagem @cemri2025 — desvios de especificação, desalinhamento entre agentes, verificação insuficiente do resultado — correspondem, em boa parte, às patologias da @sec-orq-patologias.

Arcabouços recentes para agentes de linguagem @wu2023autogen @hong2024metagpt @khattab2024 implementam variações desses padrões com modelos como componentes. O que este capítulo acrescenta é a ênfase em contexto: em cada padrão, a pergunta decisiva é que perspectiva cada agente recebe, que autoridade carrega, e o que atravessa as fronteiras entre agentes.

#exercicios[
  + Mapeie o protocolo de rede de contratos para o @alg-orquestra, identificando o que corresponde ao anúncio, à oferta e à adjudicação.
  + Que problema dos sistemas de quadro-negro reaparece quando vários agentes escrevem no mesmo acervo sem reservas?
  + Compare o quadro-negro dos sistemas clássicos com o acervo governado deste livro quanto a: controle de escrita, estatuto das entradas, proveniência e resolução de conflitos.
]

#quadro[
  - Vários agentes ajudam por isolamento de contexto, paralelismo, especialização e separação de poderes; custam tokens, transferências e coerência.
  - Papéis são posições observacionais, não modelos nem autoridade; supervisor cuida da coerência, orquestrador da correção local.
  - Orquestração governada: recomendação, pacote, prévia, aceitação do titular, re-resolução, execução governada, retorno estruturado, revisão.
  - A aceitação vale para a coordenada aceita; pacote não é plano.
  - Escada de fases, começando com defeito injetado para testar o revisor; fases não se implicam.
  - O orquestrador vê retornos, não transcrições.
  - Patologias: orquestração por instrução, redução de DoD, objeto tratado como pré-requisito, modelo revisando modelo sem portões.
]

#problemas[
  #problema([Quando dividir])[
    Uma tarefa tem conjunto de trabalho $omega$ e janela efetiva $W_"ef"$; dividi-la em $k$ subtarefas custa $c_h$ por transferência e reduz o conjunto de trabalho de cada uma a $|omega| \/ k + s$, em que $s$ é o contexto compartilhado necessário.
    + Escreva o custo total em função de $k$.
    + Encontre o $k$ ótimo e a condição para que dividir valha a pena.
    + Discuta o efeito de $s$ crescente (tarefas acopladas).
  ]
  #problema([Coerência entre perspectivas de subagentes])[
    Subagentes recebem perspectivas diferentes do mesmo acervo.
    + Defina formalmente "perspectivas coerentes" usando a compatibilidade de cartas (@cap-espacos).
    + Mostre que, se todas as perspectivas são projeções honestas do mesmo acervo no mesmo instante, são coerentes.
    + Mostre como a coerência pode ser perdida quando subagentes trabalham com instantâneos diferentes, e proponha uma salvaguarda.
  ]
  #problema([Revisor sob teste])[
    Projete uma bateria de defeitos injetados para a fase 0.
    + Inclua: sucesso sem validação exigida; evidência de outro ambiente; autoridade suposta além do teto; desconhecido promovido.
    + Defina o critério de aprovação do revisor.
    + Discuta como evitar que o revisor "aprenda" a bateria.
  ]
]

#notas[
  A introdução de #ct(<wooldridge2009>) cobre a teoria clássica de sistemas multiagentes; a rede de contratos é de #ct(<smith1980>), os sistemas de quadro-negro, de #ct(<nii1986>), o modelo de atores, de #ct(<hewitt1973>), a comunicação entre agentes, de #ct(<finin1994>) e #ct(<searle1969>), e a arquitetura BDI, de #ct(<rao1995>). Para agentes de linguagem, há guias de prática que descrevem padrões de fluxos e agentes @anthropic2024agents e relatos de construção de sistemas de pesquisa com orquestrador e subagentes, que discutem explicitamente o custo em tokens e os ganhos de paralelismo @anthropic2025multiagent; arcabouços representativos são os de #ct(<wu2023autogen>), #ct(<hong2024metagpt>) e #ct(<khattab2024>). A teoria dos compromissos conjuntos é de #ct(<cohen1991teamwork>), e uma taxonomia empírica de falhas de sistemas multiagentes de linguagem, de #ct(<cemri2025>). O viés de automação e a confiança calibrada em sistemas automáticos são tratados por #ct(<parasuraman1997>) e #ct(<lee2004trust>).

  Os papéis como posições observacionais, o laço de orquestração governada com prévia, a escada de fases com defeito injetado e o catálogo de patologias são propostas deste livro para arranjos em que humanos e agentes com acessos diferentes ao ambiente cooperam — arranjos em que a qualidade do trabalho depende, quase inteiramente, da qualidade dos pacotes que atravessam as fronteiras entre eles.
]
