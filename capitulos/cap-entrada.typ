#import "/modelo/estilo.typ": *

= Entrada, inicialização e orientação <cap-entrada>

#epigrafe[O contexto inicial não diz ao modelo o que pensar; delimita o que ele pode tomar como dado.]

Um consumidor frio — um agente iniciado sem histórico — precisa, antes de qualquer trabalho, de três coisas: estar ligado a uma coordenada, receber uma perspectiva e orientar-se a partir dela. Cada uma dessas etapas pode falhar sem que ninguém perceba. O domínio pode estar inicializado sem que o cliente esteja ligado a ele; o contexto pode ter sido montado sem ter sido entregue; o contexto entregue pode não ter sido lido; e um modelo que leu pode ter se orientado de forma errada. Instruções do tipo "leia os arquivos A, B e C antes de começar" criam a _aparência_ de uma inicialização — mas não a provam.

Este capítulo trata da entrada de contexto como processo verificável. A @sec-ent-escada apresenta a escada de engajamento. A @sec-ent-boot descreve a inicialização de contexto. A @sec-ent-entrada define a entrada de contexto e sua identidade. A @sec-ent-envelope apresenta o envelope comportamental mínimo. A @sec-ent-conformidade mostra como verificar a orientação por conformidade. A @sec-ent-expansao estende a verificação às expansões.

== A escada de engajamento <sec-ent-escada>

#definicao(titulo: [Escada de engajamento])[
  O engajamento de um consumidor com um domínio passa por cinco degraus, cada um com seu recibo:
  + _domínio inicializado_: o domínio existe e é resolvível (recibo: identidade resolvida);
  + _cliente anexado_: um processo consumidor específico foi ligado à coordenada (recibo: registro de vínculo, feito após o início bem-sucedido do processo);
  + _contexto entregue_: a entrada de contexto foi entregue ao consumidor por um adaptador (recibo: observação de transporte);
  + _modelo orientado_: o consumidor derivou uma interpretação válida da entrada (recibo: conformidade verificada);
  + _efeito autorizado_: alguma ação do consumidor foi autorizada (recibo: decisão de autoridade).
  Nenhum degrau implica o seguinte. Os três primeiros são encadeados — cada um pressupõe o anterior —; os dois últimos são recibos distintos, não degraus de uma cadeia: a autorização de um efeito é decidida por portões, não pela orientação, e pode existir sem ela.
] <def-escada-engajamento>

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Estado de entrega], [Significado]),
    [#estado[não observado]], [não há registro sobre a entrega — nada se pode afirmar],
    [#estado[não tentado]], [observou-se que nenhuma entrega foi tentada],
    [#estado[tentado]], [a entrega foi tentada; resultado desconhecido],
    [#estado[aceito pelo adaptador]], [o adaptador do cliente aceitou o conteúdo],
    [#estado[confirmado pelo consumidor]], [o consumidor confirmou o recebimento por um canal verificável],
    [#estado[falhou]], [a entrega falhou, com o motivo],
  ),
  caption: [Estados de entrega de uma entrada de contexto. "Não observamos uma tentativa" é diferente de "observamos que não houve tentativa".],
) <tab-estados-entrega>

#invariante(titulo: [Prompt injetado não é modelo inicializado])[
  Ter colocado texto no contexto de um modelo não prova que ele foi lido, nem que foi entendido, nem que o modelo está orientado. Cada degrau da escada exige seu próprio recibo.
] <inv-prompt-injetado>

#exercicios[
  + Para um agente de programação iniciado num terminal, identifique o recibo de cada degrau da escada. Quais recibos não existem hoje no sistema que você usa?
  + Por que distinguir #estado[não observado] de #estado[não tentado]? Que erro de interface surge quando os dois são confundidos?
  + Para cada degrau da escada de engajamento, proponha o recibo que comprova sua passagem e indique quem o emite. Que degrau é mais frequentemente suposto sem recibo?
]

== A inicialização de contexto <sec-ent-boot>

#algoritmo("Inicializa-Contexto", params: $kappa_0, o, d$, legenda: [Inicialização de contexto para um consumidor com adaptador $d$, coordenada pedida $kappa_0$ e objetivo opcional $o$.])[
  + resolva o domínio pela origem do vínculo (explícita > ambiente); registre origem e método #h(1fr) ▷ @def-vinculo-consumidor
  + #kw[se] o domínio não é resolvível #kw[então] #kw[falhe] fechado: "domínio não inicializado" e a ação explícita para inicializá-lo
  + resolva o cliente registrado para o adaptador $d$
  + componha a entrada de contexto $E_0$ e calcule sua identidade canônica #h(1fr) ▷ antes de iniciar o consumidor
  + inicie o processo consumidor
  + #kw[se] o processo não iniciou #kw[então] #kw[devolva] #estado[falhou] (sem vínculo)
  + registre o vínculo (unidade, domínio, cliente, adaptador, processo, objetivo) como reserva com validade, renovada por batimento #h(1fr) ▷ só após o início
  + entregue $E_0$ pelo adaptador; registre o estado de entrega (@tab-estados-entrega)
  + ao término do processo, libere o vínculo; se o processo cair, o vínculo expira por falta de batimento
] <alg-inicializa>

Três regras do algoritmo evitam falhas sutis.

/ Vínculo só após o início, e com validade: registrar o vínculo antes de o processo consumidor iniciar com sucesso cria "vínculos fantasmas" — registros de consumidores que nunca existiram, que outros componentes passam a considerar ativos. O mesmo acontece se o vínculo só for liberado "ao término": um processo que cai nunca o libera. Por isso o vínculo é uma reserva com validade, renovada enquanto o processo vive. E a entrada é composta antes de o consumidor iniciar, para que não haja janela em que ele opere sem contexto.

/ Nunca junção retrospectiva: se não há uma coordenada viva e única que correlacione uma entrada a um ciclo de execução (por exemplo, porque há vínculos concorrentes ou expirados), a entrada fica _não correlacionada_. Atribuí-la depois ao ciclo "mais provável" é inventar proveniência.

/ Falhar fechado com ação: um domínio não resolvível não é contornado por um padrão; a inicialização falha e diz o que fazer.

#exercicios[
  + Descreva um cenário de vínculo fantasma e suas consequências para a seleção de trabalho.
  + Por que a junção retrospectiva é tentadora? Mostre um caso em que ela atribui contexto ao ciclo errado.
  + Execute o @alg-inicializa para um agente iniciado sem objetivo declarado num domínio com duas unidades de trabalho abertas. O que a entrada deve conter? O que ela não deve fazer?
]

== A entrada de contexto <sec-ent-entrada>

#definicao(titulo: [Entrada de contexto])[
  Uma _entrada de contexto_ é um pacote limitado, derivado e não persistido como autoridade, que materializa a coordenada e a perspectiva para um consumidor. Tem duas partes: o _conteúdo_ — ambiente, perspectiva, funcionalidades, política de divulgação, fronteira de expansão, teto de autoridade, desconhecidos e o resultado somente leitura da reconciliação — e o _envelope_, que identifica o destinatário e a entrega. É uma primitiva de máquina, não um ritual humano.
] <def-entrada-contexto>

#definicao(titulo: [Identidade canônica da entrada])[
  A _identidade_ de uma entrada de contexto é o resumo criptográfico da serialização canônica de seu _conteúdo_, excluídos o envelope (destinatário) e os metadados de ciclo de vida (instante de entrega, identificador de sessão, processo). A serialização canônica é, por hipótese, injetiva nas classes de equivalência semântica: $"can"(x) = "can"(y)$ se e somente se $x$ e $y$ têm o mesmo conteúdo semântico.
] <def-identidade-entrada>

#proposicao(titulo: [Identidade semântica ortogonal à sessão])[
  Com a @def-identidade-entrada: (i) duas entregas, em sessões diferentes ou a destinatários diferentes, de entradas com o mesmo conteúdo semântico têm a mesma identidade; (ii) qualquer mudança semântica — na perspectiva, nas funcionalidades, nos desconhecidos — produz identidade diferente, exceto com probabilidade desprezível, se o resumo é resistente a colisões.
] <prop-identidade-entrada>

#prova[
  (i) Pela injetividade nas classes de equivalência, conteúdos semanticamente iguais têm a mesma serialização canônica; o envelope e os metadados de ciclo de vida, que diferem, foram excluídos. (ii) Conteúdos semânticos diferentes têm serializações canônicas diferentes, e encontrar duas com o mesmo resumo é computacionalmente inviável para uma função resistente a colisões.
]

A proposição tem uma aplicação imediata: permite perguntar "este consumidor recebeu o mesmo contexto que aquele?" comparando identidades, e permite reutilizar resultados de experimentos de orientação para entradas idênticas.

#exercicios[
  + Por que a identidade não deve incluir o instante de entrega? Que pergunta ficaria impossível de responder se incluísse?
  + Proponha regras de canonicalização (ordem de campos, normalização de texto, representação de conjuntos) para uma entrada de contexto em JSON.
  + Por que a identidade canônica da entrada deve ser independente da sessão? Dê um exemplo de falha de auditoria quando a entrada é identificada pela sessão em que foi entregue.
]

== O envelope comportamental mínimo <sec-ent-envelope>

O que, no mínimo, todo consumidor frio deve receber?

#definicao(titulo: [Envelope comportamental mínimo])[
  O _envelope comportamental mínimo_ de uma entrada contém: _onde_ (o domínio e o locus); _quem_ (o consumidor e seu papel); _o quê_ (o objetivo, ou a declaração de que não há); _o contexto_ (afirmações com referências de evidência, desconhecidos explícitos, fronteira de expansão); a _disciplina epistêmica_ (observado não é inferido; desconhecido permanece desconhecido); e a _fronteira de autoridade_ (o que o consumidor pode observar e propor, e o que exige efeito governado).
] <def-envelope-minimo>

#principio(titulo: [O consumidor precisa de semântica, não de infraestrutura])[
  A entrada transmite o que o consumidor precisa para raciocinar e agir — estado, estatutos, autoridade, fronteira —, não os detalhes de como o sistema obteve essas informações. Detalhes de infraestrutura que o consumidor não precisa para decidir são ruído; os que precisa são expostos como funcionalidades.
] <pri-semantica-infra>

O envelope é o complemento, do lado da entrega, do quadro de orientação inicial do @cap-memoria (@def-quadro-orientacao): o quadro diz _o que_ uma perspectiva de chegada deve conter; o envelope diz _o que não pode faltar_ na entrada que a transporta.

#exercicios[
  + Escreva o envelope comportamental mínimo para um agente que vai responder a uma pergunta de auditoria sobre uma decisão passada.
  + Dê um exemplo de detalhe de infraestrutura que é ruído e outro que deveria ser exposto como funcionalidade.
  + Escreva um envelope comportamental mínimo para um agente de pesquisa que só pode ler fontes públicas e deve registrar todas as afirmações com âncoras. Quantas linhas ele tem? O que você deixou de fora, e por quê?
]

== Orientação verificada por conformidade <sec-ent-conformidade>

A orientação é um estado interno do consumidor; não pode ser inspecionada diretamente. Mas pode ser _avaliada por seus efeitos_: pede-se ao consumidor que produza, em formato estruturado, o contexto de trabalho que derivou da entrada, e verifica-se mecanicamente se essa derivação respeita a entrada.

#definicao(titulo: [Contexto de trabalho derivado])[
  O _contexto de trabalho derivado_ é uma saída estruturada do consumidor contendo: domínio, perspectiva, objetivo; afirmações, cada uma com as referências que a sustentam; desconhecidos, cada um com dimensão, razão e dono; referências selecionadas e não selecionadas; candidatos a expansão; suposições de autoridade; classes de operação que considera permitidas e as que considera não provadas ou proibidas.
] <def-contexto-derivado>

#definicao(titulo: [Conformidade de orientação])[
  A orientação de um consumidor é _conforme_ à entrada $e$ se seu contexto derivado $w$ satisfaz:
  + identifica o domínio e a perspectiva de $e$;
  + preserva a ausência de objetivo, se for o caso;
  + toda afirmação de $w$ tem referências encontradas em $e$ (afirmações $subset.eq$ conteúdo entregue);
  + todo desconhecido de $e$ permanece desconhecido em $w$ (nenhum é promovido);
  + referências selecionadas e não selecionadas de $w$ são referências válidas de $e$;
  + candidatos a expansão de $w$ $subset.eq$ alças de $e$;
  + autoridade suposta em $w$ $subset.eq$ teto de autoridade de $e$;
  + observações alegadas em $w$ $subset.eq$ material entregue ou expandido;
  + operações consideradas permitidas em $w$ = funcionalidades declaradas em $e$.
] <def-conformidade-orientacao>

#proposicao(titulo: [A conformidade é verificável em tempo linear])[
  Com índices (tabelas de dispersão) sobre as referências, alças, funcionalidades e desconhecidos de $e$, a conformidade de $w$ é decidível em tempo $O(|e| + |w|)$ esperado.
] <prop-conformidade-linear>

#prova[
  Cada condição é uma inclusão ou igualdade entre conjuntos extraídos de $e$ e de $w$. Construir os índices de $e$ custa $O(|e|)$; verificar cada elemento de $w$ contra o índice correspondente custa $O(1)$ esperado; logo o total é $O(|e| + |w|)$.
]

A conformidade transforma a pergunta vaga "o modelo entendeu?" em perguntas mecânicas: ele afirmou algo sem apontar para o que recebeu? Promoveu algum desconhecido? Supôs autoridade que não tinha? Considerou permitida uma operação não declarada? Cada "sim" é uma falha específica e localizável. Mas a conformidade é uma condição _sintática_, necessária e não suficiente: verifica que toda afirmação aponta para material entregue, não que esse material a _sustente_. Um consumidor pode citar uma referência válida e afirmar algo falso sobre ela. A sustentação é uma relação semântica, que exige verificação por conteúdo — comparação com a asserção referida, por regra ou por outro consumidor — e herda os problemas de avaliação do @cap-avaliacao.

=== O experimento de conformidade

Para que a verificação seja válida como experimento, algumas condições precisam ser respeitadas.

#principio(titulo: [Integridade do experimento de orientação])[
  + Use uma entrada congelada (identificada por seu resumo), sem regeneração nem acréscimos entre execuções.
  + Isole o consumidor: sem ferramentas, busca, sistema de arquivos, memória ou contexto prévio.
  + Verifique, antes, que a janela _efetiva_ do modelo comporta a entrada; se não comporta, aborte com o estado #estado[janela insuficiente] — nunca trunque, pois truncar invalida o experimento.
  + Registre os resumos da entrada, da instrução, do pedido, da resposta e da saída estruturada.
  + Classifique cada ensaio com o vocabulário de verificação do livro (@tab-estados-verificacao): #estado[aprovado], #estado[reprovado], #estado[não medido] (sem saída) ou #estado[bloqueado] (não executado). Como o consumidor é estocástico, um ensaio não estabelece nada: relate a taxa de conformidade em $n$ ensaios, com intervalo de confiança (@cap-avaliacao).
  + Não substitua saída ausente por resposta de um consumidor já orientado.
] <pri-integridade-experimento>

#estudo-de-caso(titulo: [A janela que não comportava a entrada])[
  Num experimento de conformidade, a janela efetiva do modelo testado era menor que a declarada, e a entrada não cabia. A tentação foi truncar a entrada "só um pouco" para poder rodar. A decisão correta foi abortar com estado explícito: com a entrada truncada, o experimento mediria outra coisa, e um resultado positivo seria uma prova de algo que não foi testado.
] <caso-janela-insuficiente>

#exercicios[
  + Projete o esquema JSON do contexto de trabalho derivado e um verificador das condições da @def-conformidade-orientacao.
  + Por que o consumidor deve estar isolado de ferramentas no experimento? Que confusão seria introduzida se ele pudesse ler arquivos?
  + #avancado Mostre que a conformidade de orientação, definida como um conjunto de inclusões verificáveis entre o contexto entregue e a perspectiva, pode ser verificada em tempo linear no tamanho de ambos, supondo identificadores canônicos.
]

== Conformidade de expansões <sec-ent-expansao>

A mesma ideia se aplica às expansões. Depois de orientado, o consumidor escolhe uma expansão, recebe o resultado e atualiza seu contexto de trabalho. Cada passo pode ser verificado.

#definicao(titulo: [Conformidade de expansão])[
  Uma expansão é _conforme_ se: (i) a referência escolhida pertence às alças expansíveis e é única; (ii) a escolha é motivada por um desconhecido ou por material não materializado, e não supõe autoridade adicional; (iii) o retorno contém apenas o material da referência pedida (nenhum vizinho ou transitivo não solicitado); e (iv) a atualização do contexto de trabalho só acrescenta afirmações com base no material recebido, não promove desconhecidos, não altera a autoridade, preserva o que não foi tocado e não produz contradições não declaradas.
] <def-conformidade-expansao>

A conformidade garante que a expansão não _degradou_ o contexto; não garante que ela _ajudou_. O ganho é medido separadamente: número de desconhecidos relevantes resolvidos e de afirmações novas com base (@pri-conformidade-utilidade). "Nenhum ganho de informação" é um resultado válido — e informativo sobre a fronteira.

#exercicios[
  + Escreva três violações de conformidade de expansão e o sintoma que cada uma produziria nas decisões do consumidor.
  + Proponha uma métrica de ganho de informação por expansão e discuta como agregá-la ao longo de uma sessão.
  + Proponha três casos de teste de conformidade de expansão para a alça "dependências diretas", incluindo um caso em que a expansão deve devolver #est[desconhecido].
]

#quadro[
  - Escada de engajamento: inicializado, anexado, entregue, orientado, autorizado — cada degrau com seu recibo; prompt injetado não é modelo inicializado.
  - Inicialize registrando o vínculo só após o início do processo; nunca faça junção retrospectiva; falhe fechado com ação.
  - A entrada de contexto é uma primitiva de máquina; sua identidade é o resumo canônico sem metadados de ciclo de vida.
  - Envelope mínimo: onde, quem, o quê, contexto, disciplina epistêmica, fronteira de autoridade.
  - Orientação se verifica por conformidade: inclusões de conjuntos, decidíveis em tempo linear.
  - Experimentos de conformidade: entrada congelada, consumidor isolado, janela verificada, abortar em vez de truncar.
  - Conformidade de expansão não é utilidade; meça o ganho separadamente.
]

#problemas[
  #problema([Confirmação de consumo sem confiar no modelo])[
    Projete um protocolo que distinga #estado[aceito pelo adaptador] de #estado[confirmado pelo consumidor] sem depender apenas do relato do modelo.
    + Proponha um desafio derivado do conteúdo da entrada, cuja resposta correta só é possível se a entrada foi lida.
    + Analise falsos positivos e falsos negativos do protocolo.
    + Discuta o custo em tokens e latência.
  ]
  #problema([Conformidade como prova de segurança])[
    Mostre que, se toda ação proposta por um consumidor é derivada de seu contexto de trabalho, e o contexto de trabalho é conforme à entrada, então nenhuma proposta supõe autoridade acima do teto da entrada.
    + Formalize "derivada de".
    + Prove a afirmação.
    + Discuta por que a hipótese "toda ação é derivada do contexto de trabalho" é difícil de garantir com modelos de linguagem, e como portões compensam.
  ]
  #problema([Bateria de orientação])[
    Construa uma bateria de entradas para avaliar a orientação de consumidores frios.
    + Inclua casos sem objetivo, com objetivo não resolvido, com desconhecidos sutis e com premissas adversariais embutidas.
    + Defina os resultados esperados em termos das condições da @def-conformidade-orientacao.
    + Discuta como evitar que a bateria seja memorizada por modelos futuros.
  ]
]

#notas[
  A distinção entre entrega e compreensão tem paralelo nos estudos de fundamentação comum na comunicação humana @clark1991, em que o interlocutor busca evidência de que foi entendido antes de prosseguir. A orientação como etapa distinta da observação e da decisão é central no ciclo atribuído a Boyd @osinga2007 e na teoria de consciência situacional de #ct(<endsley1995>). Protocolos abertos para conectar aplicações a modelos @anthropic2024mcp @mcp2025spec padronizam a entrega de contexto e ferramentas, mas não a verificação de orientação — que fica a cargo do sistema de contexto.

  A escada de engajamento, a identidade canônica da entrada, o envelope comportamental mínimo e a conformidade de orientação por inclusões são propostas deste livro. Motivam-nas uma observação simples e recorrente: instruções de "leitura prévia" produzem a aparência de orientação sem garanti-la.
]
