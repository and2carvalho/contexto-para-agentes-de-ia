#import "/modelo/estilo.typ": *

= Avaliação e verificação <cap-avaliacao>

#epigrafe(fonte: [Marilyn Strathern, 1997, formulando a lei de Goodhart])[Quando uma medida se torna um alvo, deixa de ser uma boa medida.]

Como saber se um sistema de contexto funciona? A pergunta tem duas metades. A primeira é _empírica_: os consumidores que recebem as perspectivas do sistema decidem melhor, erram menos, gastam menos? A segunda é de _verificação_: o sistema faz o que afirma — preserva estatutos, respeita autoridade, declara omissões — em todas as superfícies e versões? As duas exigem rigor. Sistemas de contexto são avaliados com consumidores estocásticos, cujo desempenho varia com detalhes de formulação; e verificados em ambientes reais, em que falhas de teste têm muitas causas além do código.

A @sec-aval-medir trata do que medir. A @sec-aval-frio trata do consumidor frio e da independência. A @sec-aval-prereg apresenta o protocolo de teste frio pré-registrado. A @sec-aval-desenho trata do desenho experimental e da estatística. A @sec-aval-benchmarks discute modelos como juízes, benchmarks e a lei de Goodhart. A @sec-aval-sistemas trata da verificação de sistemas de contexto.

== O que medir <sec-aval-medir>

A métrica mais óbvia — a qualidade da resposta final do consumidor — é necessária, mas não suficiente. Um sistema de contexto pode produzir respostas corretas por acaso e falhar em dimensões que não aparecem numa amostra pequena; ou pode produzir respostas incorretas por limitações do consumidor, não do contexto.

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Dimensão de avaliação], [Pergunta]),
    [preservação de dimensões], [o consumidor recuperou, da perspectiva, as distinções essenciais (domínio, objetivo, fronteira, estatutos, desconhecidos, autoridade)?],
    [navegabilidade], [o consumidor soube expandir corretamente quando precisou — nem demais, nem de menos?],
    [falhas evitadas], [o consumidor evitou as falhas que o contexto deveria evitar (promoção de desconhecido, ação fora do teto, confusão de identidade)?],
    [custo], [quantos tokens, rodadas e chamadas foram necessários?],
    [violações], [quantas vezes o consumidor violou um invariante?],
    [excesso de autoridade], [o consumidor solicitou ou exerceu mais autoridade que a tarefa exigia?],
    [atualidade], [as decisões se basearam em evidência atual?],
  ),
  caption: [Dimensões de avaliação de um sistema de contexto.],
) <tab-dimensoes-avaliacao>

#definicao(titulo: [Escore por dimensão])[
  Para cada dimensão $d$ e cada execução, o _escore_ $e_d in {#estado[correto], #estado[parcial], #estado[ausente], #estado[injustificado]}$ registra se o consumidor recuperou $d$ corretamente, parcialmente, não a recuperou, ou afirmou sobre ela algo que a perspectiva não sustentava. Os escores são ordenados — $#estado[injustificado] < #estado[ausente] < #estado[parcial] < #estado[correto]$ — e, quando é preciso um valor numérico, usam-se $-1$, $0$, $1\/2$ e $1$: afirmar sem base é pior do que calar. Uma dimensão é _crítica_ se sua falha torna a execução inaceitável qualquer que seja o resto.
] <def-escore-dimensao>

#proposicao(titulo: [Médias escondem falhas críticas])[
  Para todo $epsilon > 0$ existem um protocolo com $n$ dimensões, das quais uma é crítica, e um conjunto de execuções cujo escore médio é pelo menos $1 - epsilon$ e em que a dimensão crítica falha em todas as execuções.
] <prop-medias>

#prova[
  Tome $n > 1 \/ epsilon$ e execuções em que a dimensão crítica é sempre #estado[ausente] (valor $0$) e as $n - 1$ demais, #estado[correto] (valor $1$). A média é $(n - 1) \/ n = 1 - 1\/n > 1 - epsilon$. Com $k$ dimensões críticas falhando, a média é $1 - k\/n$, e basta tomar $n > k \/ epsilon$.
]

#principio(titulo: [Agregação não compensatória])[
  O resultado de uma avaliação é relatado por dimensão; a agregação é o mínimo sobre as dimensões críticas, não a média. Um sucesso em dez dimensões não compensa uma falha em uma dimensão crítica.
] <pri-nao-compensatoria>

O princípio é a aplicação, à avaliação, da regra não compensatória dos portões (@def-compensatoria): pelo @teo-min-unico, o mínimo é a única agregação monótona e idempotente que nunca aprova um agregado com componente crítico reprovado. É também a versão empírica do @lem-agregado-minimo: o veredito de um agregado não excede o de seu pior componente.

#exercicios[
  + Para um agente de suporte técnico, escolha as dimensões críticas da @tab-dimensoes-avaliacao e justifique.
  + Construa uma tabela de resultados em que a média por execução favorece o sistema A, mas a agregação não compensatória favorece o B.
  + Proponha uma forma de relatar resultados por dimensão que seja legível para gestores sem perder a agregação não compensatória.
]

== O consumidor frio e a independência <sec-aval-frio>

#definicao(titulo: [Consumidor frio])[
  Um _consumidor frio_ é um consumidor sem memória específica do trabalho avaliado: nova sessão, sem histórico, sem acesso ao projeto além do que o teste entrega, idealmente de outro fornecedor de modelos. Frio não é vazio: ele tem o conhecimento geral de seu treinamento.
] <def-consumidor-frio>

O consumidor frio é a ferramenta central de avaliação de sistemas de contexto, porque testa exatamente o que o sistema promete: que a perspectiva, sozinha, basta para orientar. Mas ele é fácil de contaminar.

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Contaminação], [Como ocorre]),
    [memória do fornecedor], [o serviço guarda histórico ou memórias de conversas anteriores],
    [mesma sessão], [o teste é feito na mesma conversa em que o trabalho foi discutido],
    [vazamento pelo enunciado], [a pergunta do teste contém parte da resposta],
    [vazamento pelo gabarito], [o avaliador conhece a resposta enquanto formula perguntas de acompanhamento],
    [ferramentas abertas], [o consumidor tem acesso a fontes além das que o teste declara],
    [treinamento], [o material avaliado é público e pode ter sido visto no treinamento],
  ),
  caption: [Formas de contaminação de um consumidor frio.],
) <tab-contaminacao>

#principio(titulo: [Replicação entre fornecedores])[
  Um resultado obtido com consumidores de um único fornecedor pode refletir peculiaridades daquele modelo. Resultados que se pretendem gerais são replicados com consumidores de pelo menos dois fornecedores; divergências são reportadas, não médias.
] <pri-replicacao>

#exercicios[
  + Para cada contaminação da @tab-contaminacao, proponha uma salvaguarda.
  + Por que "frio não é vazio" importa para interpretar resultados? Dê um exemplo em que o conhecimento geral do consumidor faz um contexto ruim parecer bom.
  + Desenhe um procedimento para verificar que um serviço de modelos não reteve memória entre duas sessões de teste. Que resultado indicaria contaminação?
]

== O teste frio pré-registrado <sec-aval-prereg>

#definicao(titulo: [Níveis de mundo])[
  Um teste frio tem _nível de mundo_:
  - _T1, mundo fechado_: o consumidor recebe apenas o material de teste;
  - _T2, expansão limitada_: recebe o material e um conjunto declarado de referências que pode resolver;
  - _T3, mundo aberto_: recebe o material e acesso aberto a fontes.
] <def-niveis-mundo>

#algoritmo("Teste-Frio", params: $m, g, n$, legenda: [Protocolo de teste frio pré-registrado para um material de contexto $m$, um gabarito $g$ e $n$ execuções.])[
  + congele $g$ — dimensões esperadas, sentinelas, critérios e $n$ — #kw[antes] de qualquer execução #h(1fr) ▷ pré-registro
  + inclua ao menos uma _premissa adversarial_: uma pergunta que induz a violar um invariante
  + #kw[para] $i <- 1$ #kw[até] $n$ #kw[faça] #h(1fr) ▷ execuções independentes (@sec-aval-desenho)
    + instancie um consumidor frio (@def-consumidor-frio), com parâmetros registrados
    + entregue $m$ conforme o nível de mundo, sem truncar nem resumir
    + obtenha a resposta e _sele_ a transcrição (registre seu resumo criptográfico)
  + só então abra $g$
  + #kw[para cada] execução $i$ e dimensão $d$ #kw[faça] atribua $e_(d,i)$ (@def-escore-dimensao)
  + #kw[para cada] dimensão com resultado #estado[parcial] #kw[faça] crie uma nova sentinela para a _próxima_ versão do teste, nunca para esta
  + registre, por dimensão, a taxa observada com intervalo de confiança e a agregação não compensatória
] <alg-teste-frio>

Três elementos do protocolo merecem justificativa.

/ Pré-registro: congelar o gabarito antes da execução impede que o avaliador ajuste, conscientemente ou não, os critérios ao resultado. É a mesma razão pela qual a pesquisa experimental adota o pré-registro @nosek2018.

/ Premissa adversarial: uma pergunta como "a revisão $r$ foi aceita, certo?" — quando a perspectiva diz que o estatuto é desconhecido — testa se o consumidor preserva a distinção sob pressão. Sem premissas adversariais, o teste mede apenas a recuperação passiva.

/ Parciais viram sentinelas: um resultado parcial — por exemplo, o consumidor respondeu "nenhum" quando o correto era "desconhecido" — revela uma fragilidade. A reação correta é acrescentar uma sentinela ao teste, não uma nova capacidade ao sistema às pressas.

#estudo-de-caso(titulo: [Oito dimensões e uma sentinela nova])[
  Um material de continuação foi testado com um modelo frio de outro fornecedor, em sessão isolada, sem ferramentas, com temperatura zero, sob o @alg-teste-frio em nível T1. O consumidor recuperou corretamente sete das oito dimensões do gabarito. Na oitava, respondeu "nenhuma" para uma revisão cuja aceitação era desconhecida — um resultado parcial. Em vez de declarar sucesso, o protocolo gerou uma sentinela: "materiais com estatuto desconhecido devem produzir a palavra 'desconhecido' na resposta". A versão seguinte do material tornou o estatuto explícito, e a sentinela passou a fazer parte de todos os testes posteriores.

  Note-se o que o caso _não_ mostra. Uma execução, com temperatura zero, não estabelece taxa alguma: pela @teo-regra-tres, uma execução sem falha limita a taxa de falha apenas a cerca de 95%. O valor do caso está na sentinela, que é um achado qualitativo; a afirmação de que a nova versão do material funciona exige as repetições e a estatística da @sec-aval-desenho.
] <caso-oito-dimensoes>

#exercicios[
  + Pré-registre um teste frio para um material de transferência entre sessões: escreva o gabarito, as sentinelas e duas premissas adversariais.
  + Por que o protocolo exige não truncar nem resumir o material? Que viés um resumo introduz?
  + Escreva três premissas adversariais para um teste frio de um material de orientação de agentes, cada uma visando um invariante diferente.
]

== Desenho experimental e estatística <sec-aval-desenho>

=== Fatorização

Afirmações como "perspectivas estruturadas melhoram o desempenho do agente" envolvem vários fatores — formato do contexto, conteúdo, modelo, tarefa — que precisam ser variados de forma controlada @shadish2002 @wohlin2012. Uma comparação justa entre uma perspectiva estruturada e o mesmo conteúdo em prosa livre isola o _formato_; uma comparação entre perspectivas com e sem desconhecidos declarados isola um _componente_ (ablação).

#principio(titulo: [Integridade da entrada])[
  O material entregue ao consumidor num experimento é exatamente o especificado: sem truncamento silencioso por limite de janela, sem resumo intermediário, sem reformatação pela ferramenta de teste. A entrada é identificada por seu resumo criptográfico, e a mesma entrada é usada em todas as condições que deveriam compartilhá-la.
] <pri-integridade-entrada>

#principio(titulo: [O experimento precisa poder falhar])[
  Antes de usar um protocolo para avaliar um sistema, verifica-se que ele detecta uma falha conhecida: entrega-se um material deliberadamente defeituoso (por exemplo, com um desconhecido promovido a provado) e confirma-se que o protocolo o reprova. Um protocolo que aprova tudo não mede nada — a _falsificação bem-sucedida_ é condição de validade @popper1959.
] <pri-experimento-falhar>

Uma variante útil é o _consumidor congelado_: fixa-se o consumidor — mesmo modelo, mesma versão, mesmos parâmetros — e variam-se apenas as perspectivas. Assim, diferenças de resultado são atribuíveis ao contexto, não a mudanças no modelo.

=== Proporções, intervalos e a regra de três

Muitos resultados de avaliação são proporções: em quantas de $n$ execuções o consumidor preservou a dimensão $d$? Para $n$ pequeno, o intervalo de confiança usual (normal) é inadequado; o intervalo de #ct(<wilson1927>) é preferível, e o de #ct(<agresti1998>) é uma aproximação simples e robusta.

#teorema(titulo: [Regra de três])[
  Se nenhuma falha é observada em $n$ execuções independentes, um limite superior de confiança aproximado de 95% para a probabilidade de falha é $3 \/ n$.
] <teo-regra-tres>

#prova[
  Se a probabilidade de falha é $p$, a probabilidade de zero falhas em $n$ execuções é $(1 - p)^n$. O limite superior de 95% é o $p$ tal que $(1 - p)^n = 0","05$, isto é, $n ln(1 - p) = ln 0","05 approx -3$. Para $p$ pequeno, $ln(1 - p) approx -p$, logo $p approx 3 \/ n$ @hanley1983.
]

O teorema dá a medida exata da modéstia necessária: dez execuções sem falha autorizam apenas a afirmação "a taxa de falha é provavelmente menor que 30%". Para afirmar menos de 1%, são necessárias cerca de trezentas execuções sem falha.

/ Independência: o teorema, como os intervalos de Wilson e de Agresti–Coull, supõe execuções independentes. Duas execuções do mesmo consumidor, com temperatura zero, sobre a mesma entrada, são a mesma execução: contam como uma. Execuções sobre a mesma tarefa ou a mesma perspectiva são correlacionadas, e a unidade de análise deve ser o _agrupamento_ (tarefa, perspectiva) e não a execução; o tamanho efetivo da amostra é menor que o número de execuções, na razão do efeito de desenho @kish1965.

/ Confiabilidade: para um agente que será usado muitas vezes, a pergunta relevante não é "acerta em média?", mas "acerta sempre?". A métrica $"pass"^k$ — a probabilidade de que $k$ tentativas independentes na mesma tarefa sejam todas bem-sucedidas @yao2024taubench — mede isso; com taxa de acerto $p$ por tentativa, vale $p^k$, que cai rapidamente: $p = 0","9$ dá $"pass"^8 approx 0","43$.

/ Comparações pareadas: para comparar duas perspectivas (ou dois sistemas) _nas mesmas tarefas_, o teste adequado é o de #ct(<mcnemar1947>), que usa apenas as tarefas discordantes — as que um acerta e o outro erra — e respeita o pareamento; comparar duas proporções como se fossem amostras independentes desperdiça informação e pode inverter conclusões.

/ Comparações múltiplas: um protocolo com vinte dimensões, testadas cada uma a 5%, encontra em média uma "diferença significativa" por acaso. O procedimento sequencial de #ct(<holm1979>) controla a taxa de erro da família: ordenam-se os valores-$p$ crescentemente e rejeita-se a $i$-ésima hipótese enquanto $p_((i)) <= alpha \/ (m - i + 1)$.

Para estimativas de médias de grandezas limitadas, a desigualdade de #ct(<hoeffding1963>) dá um tamanho de amostra que não depende da distribuição: com $n >= ln(2\/delta) \/ (2 epsilon^2)$ execuções independentes, a média amostral de uma variável em $[0, 1]$ difere da esperança por menos de $epsilon$ com probabilidade ao menos $1 - delta$.

Quando o escore é atribuído por avaliadores — humanos ou modelos —, a concordância entre avaliadores deve ser medida, por exemplo pelo coeficiente kappa @cohen1960, e reportada junto com o resultado.

#exercicios[
  + Um sistema passou em 20 de 20 testes frios. Que afirmação sobre sua taxa de falha é justificável?
  + Calcule o intervalo de Wilson de 95% para 17 sucessos em 20 execuções e compare com o intervalo normal.
  + Desenhe um experimento fatorial $2 times 2$ para separar o efeito do formato (estruturado ou prosa) e da declaração de desconhecidos.
  + Duas perspectivas foram comparadas nas mesmas 50 tarefas: a primeira acertou 40 e a segunda, 44; houve 3 tarefas em que só a primeira acertou e 7 em que só a segunda acertou. Aplique o teste de McNemar e compare com um teste de duas proporções independentes.
  + Um agente tem taxa de acerto de 95% por tentativa. Calcule $"pass"^k$ para $k = 1, 5, 20$ e discuta o que isso significa para um agente executado vinte vezes por dia.
]

== Modelos como juízes, benchmarks e Goodhart <sec-aval-benchmarks>

=== Modelos como juízes

Avaliar milhares de respostas manualmente é inviável; usar um modelo de linguagem como juiz é comum @zheng2023judge. Os vieses conhecidos — preferência pela posição (a primeira ou a segunda resposta), pela extensão e pelas próprias respostas do modelo juiz — exigem salvaguardas: alternar posições, normalizar extensão, usar juízes de outro fornecedor, calibrar com uma amostra avaliada por humanos e medir a concordância. Para sistemas de contexto, há um viés adicional: o juiz pode ser mais convencido por respostas confiantes do que por respostas que preservam corretamente a incerteza. Por isso, as sentinelas de estatuto (por exemplo, "a resposta contém 'desconhecido'") são avaliadas por regra determinística, não pelo juiz.

=== Benchmarks

Benchmarks de contexto longo medem a capacidade de modelos de usar janelas grandes: a recuperação de uma "agulha" num "palheiro" @kamradt2023, tarefas sintéticas de complexidade controlada @hsieh2024, tarefas realistas de compreensão @bai2024longbench, e a degradação com o tamanho da entrada @hong2025. Benchmarks de agentes medem a resolução de tarefas de programação reais @jimenez2024 e o desempenho em ambientes variados @liu2024agentbench. Todos são valiosos, e todos medem o _consumidor_ — o modelo —, não o _sistema de contexto_. Avaliar um sistema de contexto exige variar o contexto e fixar o consumidor (@sec-aval-desenho).

=== Goodhart

#principio(titulo: [Não construir maquinaria para zerar uma métrica])[
  Quando uma métrica de qualidade de contexto se torna alvo — "zero junções improvisadas", "100% de dimensões recuperadas" —, sistemas passam a otimizá-la diretamente, às vezes com mecanismos genéricos sem consumidor real. Cada componente introduzido para melhorar uma métrica deve ser justificado por um consumidor que dele precisa, e as métricas devem ser rotacionadas e complementadas por avaliações qualitativas. A observação é a lei de Goodhart @goodhart1975, na formulação popularizada por #ct(<strathern1997>): quando uma medida se torna alvo, deixa de ser uma boa medida.
] <pri-goodhart>

#exercicios[
  + Proponha um protocolo para usar um modelo como juiz numa avaliação de preservação de estatutos, com salvaguardas para cada viés.
  + Por que um modelo que melhora num benchmark de contexto longo não necessariamente se beneficia mais de um bom sistema de contexto?
  + Proponha um protocolo de calibração de um modelo-juiz com uma amostra avaliada por humanos, incluindo o tamanho da amostra e a medida de concordância.
]

== Verificação de sistemas de contexto <sec-aval-sistemas>

A segunda metade da avaliação é verificar o sistema — o código que projeta, renderiza e governa.

/ Testes metamórficos: verificam as propriedades da projeção (renomeação, permutação, irrelevância, monotonicidade epistêmica, localidade) sem saídas esperadas escritas à mão (@sec-persp-metamorficas) @chen2018.

/ Conformidade entre superfícies: para a mesma coordenada, extrai-se de cada superfície o vetor de valores semânticos; separa-se o que é só de entrega; e verifica-se que as sentinelas (desconhecido, autoridade, aplicabilidade, proveniência, omissão não é negação) são preservadas por todas (@teo-superficie).

/ Caminho vivo: testa-se o artefato que os consumidores realmente executam, não o código-fonte (@caso-caminho-vivo).

/ Contrato aplicado: verifica-se o efetivo, não apenas o declarado (@caso-contrato-persistido).

=== Taxonomia de falhas de teste

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Classe], [Definição], [Ação]),
    [regressão causal], [falha introduzida pela mudança em avaliação], [corrigir antes de aceitar],
    [dívida herdada], [falha que já existia antes da mudança], [registrar e medir; não bloquear a mudança],
    [não hermética], [falha que depende de rede, serviço ou estado externo], [classificar; isolar o teste],
    [intermitente], [falha que não se reproduz de forma determinística], [registrar frequência; investigar],
    [pré-requisito ausente], [o ambiente de teste não tem o necessário], [materializar o pré-requisito; nunca concluir "rejeitado"],
  ),
  caption: [Taxonomia de falhas de teste. Tratar todas as falhas como regressões bloqueia trabalho legítimo; tratar todas como herdadas aceita regressões.],
) <tab-falhas-teste>

#algoritmo("Teste-Diferencial", params: $A, B$, legenda: [Separação entre dívida herdada e regressão por teste diferencial: $A$ é a linha de base anterior à mudança e $B$ o estado atual.])[
  + prepare a mesma infraestrutura para $A$ e $B$, com a migração neutra mínima necessária para coletar os testes em $A$
  + execute os mesmos casos em $A$ e $B$
  + #kw[para cada] falha $f$ #kw[faça]
    + #kw[se] $f$ ocorre em $A$ e $B$ com a mesma causa #kw[então] classifique como dívida herdada
    + #kw[senão se] $f$ ocorre só em $B$ #kw[então] classifique como regressão
    + #kw[senão se] $f$ depende de rede ou serviço #kw[então] classifique como não hermética
  + aceite a mudança se não há regressões novas, os contratos afetados passam e a dívida herdada está medida e explícita
] <alg-teste-diferencial>

Uma última regra, homônima da estatística mas distinta dela: a _regra de três para abstrações_ @fowler1999 recomenda extrair uma abstração genérica apenas quando o padrão aparece pela terceira vez. Em sistemas de contexto, ela é a contraparte do @pri-goodhart e do princípio "nenhuma fundação sem consumidor" (@cap-metodo): mecanismos genéricos nascem de usos repetidos, não de antecipação.

#exercicios[
  + Classifique, na @tab-falhas-teste: um teste que falha porque um serviço de nomes estava fora do ar; um teste que falha porque uma dependência não está instalada no ambiente de integração; um teste que falha só depois da mudança.
  + Por que "a importação falhou, logo a mudança foi rejeitada" é uma conclusão errada? O que deve ser feito?
  + Aplique o @alg-teste-diferencial a um cenário com 12 falhas antes da mudança e 14 depois, das quais 11 coincidem em causa. Classifique as falhas e decida se a mudança pode ser aceita.
]

#quadro[
  - Meça por dimensão: preservação, navegabilidade, falhas evitadas, custo, violações, excesso de autoridade, atualidade.
  - Médias escondem falhas críticas (@prop-medias); agregue sem compensação.
  - Consumidores frios testam o que o sistema promete; proteja-os de contaminação; replique entre fornecedores.
  - Teste frio pré-registrado, com premissas adversariais, transcrição selada e parciais que viram sentinelas.
  - Fatore, faça ablações, preserve a integridade da entrada; o experimento precisa poder falhar.
  - Regra de três: zero falhas em $n$ execuções limita a taxa a cerca de $3 \/ n$.
  - Juízes têm vieses; benchmarks medem o modelo, não o sistema de contexto; cuidado com Goodhart.
  - Verifique o sistema com testes metamórficos, conformidade entre superfícies, caminho vivo, contrato aplicado e teste diferencial.
]

#problemas[
  #problema([Uma métrica de navegabilidade])[
    Defina formalmente a navegabilidade de uma perspectiva para um consumidor.
    + Proponha uma medida baseada na distância entre as expansões feitas e as expansões necessárias.
    + Mostre como estimá-la experimentalmente com consumidores frios.
    + Discuta se ela é manipulável (Goodhart) e como protegê-la.
  ]
  #problema([Degradação com o tamanho sob perspectivas estruturadas])[
    A degradação do desempenho de modelos com o tamanho da entrada foi medida para entradas não estruturadas @hong2025.
    + Proponha um experimento que compare a degradação para o mesmo conteúdo em prosa e em perspectiva estruturada, com o mesmo número de tokens.
    + Especifique fatores, níveis, número de repetições e análise.
    + Que resultado refutaria a hipótese de que a estrutura atenua a degradação?
  ]
  #problema([Tamanho de amostra para dimensões críticas])[
    Um protocolo tem três dimensões críticas, e o sistema deve ter taxa de falha abaixo de 2% em cada uma, com 95% de confiança.
    + Quantas execuções sem falha são necessárias?
    + Como o número muda se uma falha for observada?
    + Discuta o custo e proponha uma estratégia sequencial.
  ]
]

#notas[
  O desenho de experimentos e a validade de inferências causais são tratados em #ct(<shadish2002>); para engenharia de software, em #ct(<wohlin2012>); para experimentos controlados em produção, em #ct(<kohavi2020>); para métodos empíricos em inteligência artificial, em #ct(<cohen1995>). O pré-registro é discutido por #ct(<nosek2018>), a falsificabilidade, por #ct(<popper1959>). Os intervalos para proporções são de #ct(<wilson1927>) e #ct(<agresti1998>); a regra de três, de #ct(<hanley1983>); o kappa, de #ct(<cohen1960>). Testes metamórficos são revisados por #ct(<chen2018>). A avaliação com modelos como juízes e seus vieses é estudada por #ct(<zheng2023judge>); a lei de Goodhart, na formulação usada na epígrafe, é de #ct(<strathern1997>). Levantamentos sobre a avaliação de agentes de linguagem @yehudai2025 discutem benchmarks e métricas de trajetória.

  O protocolo de teste frio pré-registrado, com transcrição selada, níveis de mundo, premissas adversariais e parciais que viram sentinelas, adapta à avaliação de contexto as práticas de pré-registro e de testes cegos da pesquisa experimental; a taxonomia de falhas de teste e o teste diferencial respondem à necessidade de distinguir regressões reais de dívida herdada em sistemas com muitos testes não herméticos.
]
