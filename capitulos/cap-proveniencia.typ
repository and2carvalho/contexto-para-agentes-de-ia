#import "/modelo/estilo.typ": *

= Proveniência e evidência <cap-proveniencia>

#epigrafe[A proveniência nos diz como chegamos aqui de forma verdadeira; a trajetória nos diz por que viemos.]

Toda asserção do acervo veio de algum lugar. Foi observada por alguém, num lugar e num momento, com algum procedimento; ou foi derivada de outras asserções, por alguma regra; ou foi relatada por uma fonte que não forneceu âncora. A _proveniência_ é o registro dessa origem. Ela é o que permite verificar uma afirmação, avaliar quanto confiar nela, reproduzir a derivação que a produziu e saber o que mais precisa ser revisto quando ela se revela falsa.

Este capítulo desenvolve a proveniência como objeto de primeira classe do gerenciamento de contexto. A @sec-prov-conceitos apresenta os conceitos fundamentais e o vocabulário padronizado. A @sec-prov-evidencia define evidência e distingue evidência de afirmação e de renderização. A @sec-prov-cadeias trata de cadeias de proveniência fechadas e da reprodutibilidade que elas permitem. A @sec-prov-semianeis mostra como semianéis de proveniência permitem calcular, a partir do mesmo grafo, confiança, custo e número de derivações. A @sec-prov-contexto aplica a proveniência ao próprio contexto renderizado. A @sec-prov-trajetoria distingue proveniência de trajetória. A @sec-prov-correcao trata de revogação e correção.

== Conceitos fundamentais <sec-prov-conceitos>

Na literatura de bancos de dados, distinguem-se três perguntas de proveniência sobre um resultado @buneman2001: _de onde_ veio (quais dados de origem contribuíram), _por que_ está ali (que combinação de dados de origem o justifica) e _como_ foi produzido (que operações transformaram a origem no resultado). Na web semântica, o modelo W3C PROV padronizou um vocabulário com três tipos de nó — _entidades_ (coisas), _atividades_ (processos que usam e geram entidades) e _agentes_ (responsáveis por atividades e entidades) — e relações como "foi gerada por", "usou", "deriva de" e "foi atribuída a" @prov2013.

#definicao(titulo: [Grafo de proveniência])[
  Um _grafo de proveniência_ é um multigrafo tipado (@def-ap-multigrafo) cujos vértices são entidades (asserções, artefatos, observações), atividades (observações, derivações, ações) e agentes (humanos, agentes de linguagem, sistemas), e cujas arestas têm tipos como #raw("gerada-por"), #raw("usou"), #raw("deriva-de"), #raw("atribuída-a") e #raw("associada-a"). Exigimos que o subgrafo das arestas #raw("deriva-de") e #raw("gerada-por") seja acíclico.
] <def-grafo-proveniencia>

A aciclicidade expressa uma exigência simples: nada pode ser, direta ou indiretamente, sua própria origem. Uma asserção que, ao final de uma cadeia de derivações, aparece como justificativa de si mesma não tem proveniência — tem circularidade.

#exercicios[
  + Desenhe o grafo de proveniência da asserção "a revisão $r$ passou nos testes de integração", incluindo a execução dos testes, o executável usado, o agente que disparou a execução e o registro produzido.
  + Mostre um exemplo realista de circularidade de proveniência entre resumos produzidos por dois agentes que se citam mutuamente. Como detectá-la?
  + Mostre que, se o grafo de proveniência é acíclico nas arestas de derivação, toda asserção derivada tem pelo menos uma cadeia de derivação que termina em observações ou declarações primárias.
]

== Evidência <sec-prov-evidencia>

Nem toda asserção com proveniência é evidência. Reservamos o termo para um tipo específico de registro.

#definicao(titulo: [Evidência])[
  Uma _evidência_ é um registro imutável que contém: (i) o _objeto_ da observação (o que foi observado, identificado por designações estáveis); (ii) o _procedimento_ (como foi observado, incluindo a identidade do executável ou ferramenta); (iii) o _observador_ (quem executou); (iv) o _locus_ e o _instante_; (v) a _âncora_ — o artefato bruto produzido pela observação (saída, registro, resumo de conteúdo) ou uma referência verificável a ele; e (vi) o _escopo_ das afirmações que a evidência sustenta.
] <def-evidencia>

A definição exclui, deliberadamente, três coisas que costumam ser chamadas de evidência.

A primeira é a _afirmação sem âncora_: "verifiquei e está tudo certo". Pode ser verdadeira, mas não é verificável; é um relato. A segunda é a _renderização_: um gráfico, uma tabela, uma imagem de um grafo de dependências. Uma renderização é derivada de evidências (ou de suposições); não é ela mesma evidência, porque não registra o procedimento de observação. A terceira é o _resumo_: um texto que descreve evidências sem reter suas âncoras. Resumos são memória.

#invariante(titulo: [Evidência precede a renderização])[
  O fluxo legítimo é: observação ancorada → evidência → projeção determinística → renderização. Nunca: varredura → desenho → "portanto esta é a arquitetura". Uma renderização pode ajudar a _encontrar_ o que observar, mas não substitui a observação.
] <inv-evidencia-renderizacao>

#estudo-de-caso(titulo: [A primeira evidência é a própria estrutura])[
  Uma equipe queria construir uma ferramenta de visualização do ambiente de desenvolvimento — repositórios, espaços de trabalho, serviços e suas relações. A tentação era começar pelo desenho: varrer o sistema de arquivos e produzir um grafo. A proposta adotada foi outra: a primeira evidência a ser produzida seria uma _linha de base observacional_ — identidades medidas, relações observadas, loci de autoridade, revisões, frescor, relações ausentes ou não provadas e, notavelmente, o _custo de descoberta_ de cada informação (quanto veio de projeção direta do sistema, quanto exigiu expansões, quanto exigiu "arqueologia" no sistema de arquivos e quanto exigiu inferência humana). O desenho viria depois, como renderização dessa evidência. Mais tarde, o mesmo experimento poderia ser repetido para medir quanto da reconstrução passou a ser obtido por projeção em vez de arqueologia — sem inventar uma "pontuação de contexto", apenas comparando observações.
] <caso-linha-de-base-observacional>

=== Traço de derivação não é evidência

Uma quarta exclusão merece destaque, porque é cometida pelos próprios sistemas de contexto. A perspectiva carrega um _traço_ $mu$ — a regra de composição que incluiu cada item, a ordem dos estágios, as decisões de seleção (@def-perspectiva). O traço explica _como se concluiu_; não prova nada sobre o mundo. Citar "a regra $r_7$ selecionou este item como dependência" como prova de que existe uma dependência confunde a explicação de um cálculo com a evidência de um fato. O traço e as âncoras de prova vivem em campos separados, e só as âncoras sustentam estatutos.

=== Recibo e pós-condição

Do mesmo modo, o _recibo_ de uma operação — o código de retorno de um comando, a resposta "aceito" de um serviço — é evidência de que a operação foi _recebida_, não de que seu efeito ocorreu. O @cap-ciclo-acao desenvolve a distinção (@def-recibo-poscondicao): a evidência do efeito é uma observação da pós-condição, feita depois e independentemente.

=== Evidência negativa

Afirmações negativas ("não há processos usando a porta 8080", "nenhum teste falhou") são especialmente delicadas, porque sua prova exige _completude_ da observação.

#principio(titulo: [Evidência negativa declara sua completude])[
  Uma evidência que sustenta uma afirmação negativa registra o universo examinado e o argumento de completude: o que foi verificado, como se sabe que nada ficou de fora, e sob quais limites (truncamento, permissões, tempo). Sem isso, a afirmação negativa tem estatuto #est[desconhecido].
] <pri-evidencia-negativa>

#exercicios[
  + Classifique como evidência, relato, renderização ou resumo: (a) a captura de tela de um painel de monitoramento; (b) o arquivo de registro completo de uma execução, com o resumo criptográfico do binário; (c) "rodei os testes e passou"; (d) um diagrama de arquitetura; (e) a saída de um comando de listagem, com o comando exato e o instante.
  + Escreva uma evidência negativa completa para "não há outro processo escrevendo neste banco de dados", incluindo o argumento de completude.
  + No @caso-linha-de-base-observacional, por que medir o _custo de descoberta_ é útil? Que decisões ele informa?
]

== Cadeias fechadas e reprodutibilidade <sec-prov-cadeias>

#definicao(titulo: [Cadeia de proveniência fechada])[
  A proveniência de uma asserção $a$ é _fechada_ se todo caminho no grafo de proveniência que parte de $a$ seguindo arestas #raw("deriva-de"), #raw("gerada-por") e #raw("usou") termina em evidências (@def-evidencia) cujas âncoras são acessíveis. Um conjunto de asserções tem proveniência fechada se cada uma tem.
] <def-cadeia-fechada>

#teorema(titulo: [Reprodutibilidade por cadeia fechada])[
  Se uma asserção $a$ tem proveniência fechada, se as atividades de derivação no grafo são determinísticas e _herméticas_ — não têm entradas não declaradas, como o relógio, variáveis de ambiente ou a ordem de listagem do sistema de arquivos — e se suas especificações estão registradas, então $a$ pode ser reproduzida por qualquer consumidor com acesso às âncoras e às especificações, sem acesso à história narrativa que levou a $a$.
] <teo-reprodutibilidade>

#prova[
  Por indução na profundidade do subgrafo acíclico que termina em $a$. As folhas são evidências com âncoras acessíveis, que podem ser verificadas diretamente. Se todas as entradas declaradas de uma atividade determinística e hermética foram reproduzidas, sua saída também pode ser, executando a especificação registrada: pela hermeticidade, não há outras entradas. Como o subgrafo é finito e acíclico, a indução alcança $a$.
]

O teorema formaliza uma observação feita repetidamente na prática de agentes: quando a cadeia de proveniência de um estado se fecha, um agente "frio" — sem nenhuma conversa anterior — consegue reconstruir o mesmo estado, de forma comprovável, a partir das coordenadas e das âncoras. O contraste é com a reconstrução a partir de narrativa, que é probabilística: o agente frio pode chegar à mesma conclusão, mas não pode prová-la.

#principio(titulo: [Feche a cadeia antes de transferir])[
  Antes de transferir um trabalho a outro consumidor, ou de encerrá-lo, verifique que as asserções em que o estado depende têm proveniência fechada. Cadeias abertas são dívida: alguém, depois, terá de reconstruí-las por arqueologia.
] <pri-fechar-cadeia>

#exercicios[
  + Dê um exemplo de asserção com proveniência aberta e descreva o que um agente frio precisaria fazer para reconstruí-la.
  + O @teo-reprodutibilidade exige atividades determinísticas. Como lidar com atividades não determinísticas, como chamadas a modelos de linguagem? (Dica: registre a saída como entidade gerada, e trate a chamada como observação.)
  + Classifique como fechada ou aberta a cadeia de proveniência de: (a) um binário construído a partir de uma revisão e de dependências fixadas por resumo; (b) o mesmo binário, com uma dependência resolvida pela "versão mais recente"; (c) um relatório produzido por um agente a partir de uma busca na web.
]

== Semianéis de proveniência <sec-prov-semianeis>

Um mesmo grafo de proveniência pode responder a perguntas quantitativas diferentes: quão confiável é esta conclusão? Quantas derivações independentes a sustentam? Qual é o custo mínimo para reverificá-la? #ct(<green2007>) mostraram que essas perguntas são instâncias de um único cálculo, parametrizado por um _semianel_.

#definicao(titulo: [Semianel comutativo])[
  Um _semianel comutativo_ é uma estrutura $(K, plus.o, times.o, 0, 1)$ em que $(K, plus.o, 0)$ e $(K, times.o, 1)$ são monoides comutativos, $times.o$ distribui sobre $plus.o$ e $0 times.o k = 0$ para todo $k$.
] <def-semianel>

A ideia é anotar cada evidência $e$ com um valor $v(e) in K$ e propagar: uma derivação que _combina_ entradas (conjunção: precisa de todas) multiplica seus valores com $times.o$; alternativas que _sustentam_ a mesma conclusão (disjunção: basta uma) somam com $plus.o$. O valor de uma conclusão é a soma, sobre suas derivações alternativas, do produto dos valores das evidências de cada derivação — um polinômio de proveniência avaliado em $K$.

#figure(
  tabela(
    colunas: (auto, auto, auto, 1fr),
    cabecalho: ([Semianel], [$plus.o$], [$times.o$], [Pergunta respondida]),
    [Booleano ${0, 1}$], [$or$], [$and$], [A conclusão é derivável a partir de evidências confiáveis?],
    [Contagem $bb(N)$], [$+$], [$times$], [Quantas derivações distintas a sustentam?],
    [Tropical $bb(R)_(>= 0) union {infinity}$], [$min$], [$+$], [Qual o custo mínimo de reverificação?],
    [Viterbi $[0, 1]$], [$max$], [$times$], [Qual a confiança da melhor derivação, se confianças são independentes?],
  ),
  caption: [Semianéis de proveniência e as perguntas que respondem sobre o mesmo grafo.],
) <tab-semianeis>

#exemplo(titulo: [Confiança de uma conclusão])[
  A conclusão "a revisão $r$ pode ser promovida" deriva de duas formas alternativas: (i) testes de integração no servidor ($e_1$, confiança $"0,95"$) _e_ aprovação de revisão humana ($e_2$, $"0,9"$); ou (ii) testes de integração reexecutados localmente ($e_3$, $"0,7"$) _e_ $e_2$. No semianel Viterbi, a confiança _da melhor derivação_ é $max("0,95" dot "0,9"; "0,7" dot "0,9") = "0,855"$. No semianel de contagem, há $2$ derivações. No semianel booleano, se $e_1$ for revogada, a conclusão continua derivável por (ii).
] <ex-semianel>

A confiança da melhor derivação não é a probabilidade de a conclusão valer. Supondo as evidências independentes, a probabilidade de _alguma_ derivação valer é $Pr(e_2 and (e_1 or e_3)) = "0,9" dot (1 - "0,05" dot "0,3") = "0,8865"$ — e calculá-la exige a fórmula inteira de linhagem, não apenas um semianel; em geral, avaliar probabilidades de linhagem é difícil (\#P-difícil) @dalvi2007.

O resultado principal de #ct(<green2007>) garante que essa propagação é bem definida e compatível com as operações da álgebra relacional positiva e de Datalog, e que o polinômio de proveniência é a anotação mais geral — qualquer outro semianel pode ser obtido avaliando-o. Para a engenharia de contexto, isso significa que vale a pena guardar a _estrutura_ da proveniência (quais evidências, combinadas como) em vez de apenas um número de confiança: o número responde a uma pergunta; a estrutura responde a todas.

#exercicios[
  + No @ex-semianel, calcule o custo mínimo de reverificação no semianel tropical, supondo custos $e_1 = 10$, $e_2 = 30$, $e_3 = 5$.
  + Mostre que o semianel booleano é suficiente para implementar a retratação do @teo-retratacao.
  + #avancado Explique por que a hipótese de independência das confianças, implícita no semianel Viterbi, pode ser violada quando duas evidências usam o mesmo executável defeituoso. Como o grafo de proveniência permite detectar essa dependência?
]

== Proveniência do próprio contexto <sec-prov-contexto>

O @teo-continuidade-externa mostrou que a decisão de um agente depende apenas do contexto da chamada. Logo, para auditar uma decisão, é preciso saber _exatamente_ qual foi o contexto — e de onde veio cada parte dele.

#definicao(titulo: [Registro de proveniência de contexto])[
  Um _registro de proveniência de contexto_ para uma chamada contém: o resumo criptográfico do contexto renderizado; a coordenada $kappa$; a identificação da projeção e da renderização usadas (versões), o orçamento e o perfil de renderização; o instante de referência do acervo; para cada segmento do contexto, as asserções do acervo de que foi derivado; e a identificação do modelo e dos parâmetros de amostragem.
] <def-registro-contexto>

Com esse registro, três perguntas de auditoria se tornam respondíveis: _o que o agente viu?_ (o contexto, reconstruível reexecutando projeção e renderização sobre o acervo retido, e verificável pelo resumo criptográfico); _por que viu isso?_ (a coordenada e a projeção); e _o que mudou desde então?_ (comparando o acervo em $t$ com o atual). Sem ele, a auditoria de decisões de agentes se reduz a adivinhar o que estava na janela.

#principio(titulo: [Toda decisão relevante tem contexto auditável])[
  Para toda decisão de agente que produza efeito governado, mantenha um registro de proveniência de contexto suficiente para reconstruir o que o agente viu e por quê.
] <pri-contexto-auditavel>

=== Atribuição das saídas

A proveniência do contexto diz de onde veio o que o agente viu. Resta a direção oposta: de onde vem o que o agente _diz_. Um consumidor que relata o estado de um sistema produz afirmações, e cada uma deveria ser atribuível a segmentos do contexto.

#definicao(titulo: [Afirmação atribuível])[
  Uma afirmação $s$ de uma saída é _atribuível_ a um conjunto de segmentos $G$ do contexto se um leitor cuidadoso, lendo apenas $G$, concluiria $s$. Uma saída é _atribuível_ se cada uma de suas afirmações factuais o é a algum conjunto de segmentos citado.
] <def-atribuivel>

A noção é a de _atribuição a fontes identificadas_ de #ct(<rashkin2023>), e sistemas que geram texto com citações podem ser avaliados por ela — com que frequência a citação sustenta a afirmação, e com que frequência afirmações sustentáveis deixam de citar @gao2023cite. Relatórios com afirmações não atribuíveis violam a regra de distinguir o observado do inferido (@pri-honestidade-pratica), mesmo quando verdadeiros. A atribuibilidade é mais forte que a conformidade sintática de uma orientação (@def-conformidade-orientacao), que só exige que as referências citadas existam no material entregue; aqui se exige que elas _sustentem_ a afirmação.

#exercicios[
  + Estime o custo de armazenamento de registros de proveniência de contexto para um agente que faz 1000 chamadas por dia, supondo que o acervo é preservado por acréscimo. Por que guardar apenas resumos e referências, em vez do texto completo, é suficiente?
  + Que informação adicional seria necessária para reproduzir não apenas o contexto, mas a distribuição da saída?
  + Proponha um procedimento automático que verifique a atribuição (@def-atribuivel) de cada afirmação de um pacote de retorno às asserções referenciadas. Que parte pode ser decidida por regra e que parte exige um juiz?
  + Dê um exemplo de afirmação verdadeira e não atribuível, e explique por que ela deve ser tratada como inferência.
  + Escreva o registro de proveniência de contexto (@def-registro-contexto) para uma decisão de um agente de suporte que reembolsou um cliente. Que campos são indispensáveis para uma auditoria posterior?
]

== Proveniência e trajetória <sec-prov-trajetoria>

Num episódio ilustrativo — sem pretensão de experimento controlado —, um titular humano e um agente tentaram, cada um, reconstruir de memória a história de um longo projeto que haviam conduzido juntos. O agente produziu uma reconstrução técnica precisa: qual estado levou a qual, sob qual evidência, em qual coordenada, o que estava provado ou desconhecido, que implementação substituiu qual. O titular, por sua vez, seria muito menos preciso sobre os estados — mas contaria com facilidade _por que_ cada coisa aconteceu: que dor motivou cada objetivo, que observação mudou a hipótese, por que uma solução foi abandonada, que intenção maior tornava coerentes vários trabalhos técnicos.

As duas reconstruções são projeções diferentes do mesmo grafo de acontecimentos.

#definicao(titulo: [Proveniência e trajetória])[
  - A _proveniência_ responde a "como chegamos aqui de forma verdadeira?": que estado levou a que estado, sob que evidência, em que coordenada.
  - A _trajetória_ responde a "por que viemos para cá?": que problema motivou o objetivo, que observação mudou a hipótese, que escolha suplantou uma alternativa, por que a fronteira seguinte se tornou a próxima, que intenção de ordem superior torna coerentes vários trabalhos.
] <def-proveniencia-trajetoria>

Nenhuma das duas substitui a outra. A proveniência é indispensável para verificar; a trajetória é extraordinariamente _compressiva_ para entender. Uma única aresta de trajetória ("abandonamos a abordagem $A$ porque ela exigia explicar detalhes de controle de versão ao titular a cada tarefa") pode tornar inteligíveis dezenas de decisões técnicas que, vistas só pela proveniência, parecem arbitrárias.

O experimento sugere uma hipótese de projeto: uma boa perspectiva para colaborações longas pode precisar preservar, quando aplicável, algumas relações de trajetória — problema motivador, observação que mudou a hipótese, escolha que suplantou alternativa, razão da próxima fronteira. Isso não exige uma nova entidade: pode ser uma projeção sobre recursos que já existem (decisões, itens de trabalho, evidências), com arestas tipadas de intenção. O @cap-memoria desenvolve a ideia, junto com uma terceira dimensão — a _espacial_, que diz onde o trabalho vive.

#exercicios[
  + Escolha um projeto que você acompanhou e escreva cinco arestas de trajetória e cinco de proveniência sobre ele. Qual conjunto um recém-chegado acharia mais útil para entender o estado atual? E para verificá-lo?
  + Por que a trajetória é mais vulnerável a distorção que a proveniência? Que salvaguardas a tornam confiável?
  + Dê um exemplo em que a trajetória de uma decisão (como se chegou a ela) é útil para um novo consumidor, mas a proveniência dela (o que a sustenta) está incompleta. Que risco isso cria?
]

== Revogação e correção de proveniência <sec-prov-correcao>

Evidências podem se revelar defeituosas: o executável que produziu um registro tinha um erro; o locus observado não era o que se pensava; a âncora foi corrompida. A proveniência também pode estar errada — atribuída ao agente errado, ligada à atividade errada.

#definicao(titulo: [Revogação e correção])[
  A _revogação_ de uma evidência é uma asserção, com proveniência própria, que declara a evidência inválida para um escopo, com o motivo. A _correção_ de proveniência é uma asserção que suplanta uma aresta de proveniência por outra, preservando a original como histórica.
] <def-revogacao>

Como o acervo cresce por acréscimo (@def-acervo), nem revogação nem correção apagam o que existia; ambas acrescentam. O efeito sobre as conclusões derivadas é calculado pela retratação por justificação (@teo-retratacao): todas as conclusões cuja única sustentação passava pela evidência revogada perdem o estatuto #est[provado]; as que tinham derivações alternativas (semianel booleano) mantêm-no.

#invariante(titulo: [Não fabricar proveniência retroativa])[
  Quando se descobre que registros antigos não guardaram resumos de conteúdo, identidades de executáveis ou outras âncoras, não se preenchem esses campos agora "para completar". A proveniência histórica ausente é declarada como _desconhecida dentro de limites_ (o que se sabe e o que não se sabe sobre ela); a proveniência prospectiva é obtida por uma nova atestação, datada do momento em que é feita. Re-atestar não é recuperar.
] <inv-proveniencia-retroativa>

Uma forma particular de proveniência defeituosa é a _sobrevinculação_ de atestações: um validador avaliou um pacote, e seu "aprovado" é estendido a afirmações que não estavam no pacote ou a uma versão posterior dele. A defesa é registrar, em cada atestação, o resumo do pacote avaliado e o escopo das afirmações atestadas (@inv-sobrevinculacao).

#antipadrao(titulo: [Corrigir apagando])[
  Ao descobrir que um registro de teste foi produzido por um executável defeituoso, o operador apaga o registro. As conclusões que dependiam dele continuam no acervo, agora sem justificação visível — e ninguém consegue mais descobrir por que foram tiradas, nem que precisam ser revistas.
] <anti-corrigir-apagando>

#exercicios[
  + Descreva os passos para revogar uma evidência produzida por um executável defeituoso, incluindo a identificação de todas as outras evidências produzidas pelo mesmo executável.
  + Um agente atribuiu a si mesmo uma ação que foi, na verdade, executada por outro agente. Escreva a correção de proveniência correspondente.
  + Mostre, com o semianel booleano, quais conclusões perdem o estatuto #est[provado] quando uma evidência é revogada num grafo com duas derivações alternativas, uma das quais passa pela evidência revogada.
]

#quadro[
  - Proveniência responde de onde, por que e como; o grafo de proveniência é acíclico nas arestas de derivação.
  - Evidência é um registro imutável com objeto, procedimento, observador, locus, instante, âncora e escopo; relatos, renderizações e resumos não são evidência.
  - Evidência negativa precisa declarar sua completude.
  - Cadeias fechadas permitem reprodução por consumidores frios (@teo-reprodutibilidade); feche a cadeia antes de transferir.
  - Semianéis de proveniência respondem confiança, contagem e custo a partir da mesma estrutura.
  - O contexto renderizado também precisa de proveniência para que decisões de agentes sejam auditáveis.
  - Proveniência (como) e trajetória (por quê) são projeções complementares; revogar e corrigir acrescentam, nunca apagam.
]

#problemas[
  #problema([Proveniência de resumos])[
    Um agente produz um resumo de uma sessão longa.
    + Proponha um formato de resumo em que cada afirmação carrega uma referência às asserções do acervo que a sustentam.
    + Mostre que, com esse formato, a afirmação do resumo pode ser revalidada sem reler a sessão.
    + Discuta o custo em tokens do formato e proponha uma forma compacta de referência.
  ]
  #problema([Ciclos de citação entre agentes])[
    Em sistemas multiagentes, agentes citam relatórios uns dos outros.
    + Mostre como surgem ciclos de proveniência quando relatórios citam relatórios sem âncoras.
    + Proponha uma regra que impeça ciclos sem proibir citações.
    + #avancado Modele a confiança de afirmações num grafo de citações com ciclos. Mostre que, com ciclos, o semianel de contagem deixa de ser bem definido em $bb(N)$ (há infinitas derivações), enquanto o de Viterbi continua bem definido. O que o valor Viterbi atribui a um ciclo de citações sem âncora?
  ]
  #problema([Custo de descoberta como métrica])[
    Retome o @caso-linha-de-base-observacional.
    + Defina formalmente o custo de descoberta de uma asserção como uma função da forma como ela foi obtida (projeção direta, expansão, arqueologia, inferência humana).
    + Proponha um experimento que compare o custo de descoberta antes e depois de uma melhoria no gerenciamento de contexto.
    + Discuta por que essa métrica é preferível a uma "pontuação de qualidade de contexto" atribuída por julgamento.
  ]
]

#notas[
  A caracterização de proveniência em termos de "por que" e "onde" é de #ct(<buneman2001>); o rastreamento de linhagem em armazéns de dados foi estudado por #ct(<cui2000>), e os semianéis de proveniência, que unificam vários tipos de anotação, são de #ct(<green2007>). O modelo W3C PROV @prov2013 é o vocabulário padronizado mais difundido. Mecanismos de verificação da cadeia de suprimentos de software, como in-toto @torresarias2019, aplicam ideias de proveniência a artefatos de construção. A ideia de manter justificações para permitir retratação vem dos sistemas de manutenção da verdade @doyle1979 @dekleer1986.

  A distinção entre proveniência e trajetória é uma proposta deste livro. A observação de que coordenadas governadas permitem a um agente reconstruir estados sem reler a história — e de que uma narrativa de intenção, embora imprecisa, preserva por que algo existiu e por que a próxima ideia ficou óbvia — é desenvolvida no @cap-memoria.
]
