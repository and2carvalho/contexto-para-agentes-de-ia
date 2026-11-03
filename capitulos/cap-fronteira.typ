#import "/modelo/estilo.typ": *

= Fronteira e expansão dirigida <cap-fronteira>

#epigrafe(fonte: [Ben Shneiderman, 1996])[Primeiro a visão geral, depois o zoom e o filtro, e então os detalhes sob demanda.]

Nenhuma perspectiva contém tudo. O axioma de omissão declarada (P5) exige que o que fica de fora seja _contabilizado_ ou _alcançável_; a fronteira é o mecanismo que torna o alcançável concreto. Ela transforma a pergunta "o que mais existe?" em um conjunto de _alças_ — pontos de partida para obter mais informação, cada um com custo, efeito esperado e requisitos de autoridade. Uma boa fronteira permite que perspectivas pequenas sejam suficientes, porque o consumidor sabe exatamente onde buscar o que falta; uma fronteira ruim obriga a escolher entre perspectivas inchadas e consumidores que inventam o que não veem.

A @sec-front-definicao define alças e fronteira. A @sec-front-expansao formaliza a operação de expansão e suas propriedades. A @sec-front-relevancia trata da relevância derivada e do perigo do fecho irrestrito. A @sec-front-valor apresenta o valor da informação como critério de escolha de expansões. A @sec-front-profundidade discute a profundidade justificada e a fronteira condicionada por pergunta. A @sec-front-escopo trata das sentinelas de escopo — os cuidados para que "não observado aqui" não vire "inexistente". A @sec-front-costura distingue expansões puras de expansões que observam o mundo.

== Alças e fronteira <sec-front-definicao>

#definicao(titulo: [Alça de expansão])[
  Uma _alça de expansão_ é uma tupla $h = (r, k, c, alpha_h, j)$ em que $r$ é uma _referência resolúvel_ — uma coordenada mais específica ou um identificador de recurso —; $k$ é o _tipo_ da expansão (abrir o conteúdo de um recurso, seguir uma relação, observar o estado material, consultar a história, expandir a trajetória); $c$ é uma estimativa de custo (tokens, latência, efeitos colaterais); $alpha_h$ é a autoridade exigida; e $j$ é a _justificativa_ — por que essa alça é oferecida nesta perspectiva.
] <def-alca>

#definicao(titulo: [Fronteira])[
  A _fronteira_ $Phi(P)$ de uma perspectiva $P$ é o conjunto finito de alças que ela oferece. Uma fronteira é _honesta_ se (i) toda alça é resolúvel sob o teto de autoridade da coordenada, ou declara explicitamente a autoridade adicional que exigiria; (ii) toda asserção aplicável e legível ausente de $F union R$ e não contabilizada em $X$ é alcançável por alguma alça; (iii) nenhuma alça promete mais do que entrega — o tipo e a justificativa descrevem corretamente o que a expansão retornará.
] <def-fronteira>

A condição (iii) parece trivial e é frequentemente violada. Uma alça genérica como "ver mais" ou "detalhes" não diz ao consumidor o que ele obteria; ele precisa expandir para descobrir — o que anula a vantagem de ter uma fronteira. Alças boas são _específicas_: "abrir o registro da execução de testes de 14h na revisão $r$", "seguir a relação #raw("depende-de") até o serviço $Y$", "observar o estado material atual do repositório $R$".

#principio(titulo: [Âncora, fronteira e próximo objetivo são coisas distintas])[
  A _âncora_ é onde a verdade e a história são recuperáveis — o lugar a partir do qual um consumidor frio reconstrói o estado. A _fronteira_ é o conjunto de arestas de continuação disponíveis. O _próximo objetivo_ é a aresta efetivamente escolhida para trabalho, por quem tem autoridade para escolher. Uma aresta aberta na fronteira não é, por estar aberta, o próximo objetivo.
] <pri-ancora-fronteira>

#exercicios[
  + Reescreva as alças "ver mais", "histórico" e "relacionados" de forma específica, para uma perspectiva sobre uma falha de implantação.
  + Explique por que uma alça que exige autoridade adicional deve aparecer na fronteira (com a exigência declarada) em vez de ser omitida. Em que casos omiti-la é preferível? Relacione com o @pri-conhecer-divulgar.
  + Dê um exemplo em que tratar uma aresta aberta da fronteira como próximo objetivo leva um agente a trabalhar na coisa errada.
]

== A operação de expansão <sec-front-expansao>

#definicao(titulo: [Expansão])[
  Dada uma perspectiva $P = pi(Sigma, kappa)$ e uma alça $h in Phi(P)$, a _expansão_ produz uma nova perspectiva
  $ "exp"(P, h) = pi(Sigma', kappa union.sq h) $
  em que $kappa union.sq h$ é a coordenada refinada pela alça — o supremo, na ordem de especificidade, de $kappa$ e da coordenada parcial que a alça designa (por exemplo, um foco ou um recurso selecionado), definido apenas quando as duas são compatíveis — e $Sigma'$ é o acervo no instante da expansão — igual a $Sigma$ para expansões puras, ou acrescido das observações feitas pela expansão, quando ela observa o mundo.
] <def-expansao>

Duas restrições acompanham a definição. Uma alça só é oferecida em $Phi(P)$ se a coordenada que designa é compatível com $kappa$ — caso contrário, $kappa union.sq h$ não existe. E o teto de autoridade é preservado: $alpha(kappa union.sq h) = alpha(kappa)$. Uma expansão que exigisse autoridade adicional não é uma expansão, mas um pedido de autoridade, que passa pelo dono da autoridade e produz uma coordenada nova (@cap-autoridade).

Definir a expansão como _nova projeção_ sobre uma coordenada refinada, em vez de como "acréscimo de material" à perspectiva antiga, tem consequências importantes.

#teorema(titulo: [Expansões preservam os axiomas])[
  Se $pi$ satisfaz os axiomas P1–P6 para toda coordenada, então toda perspectiva obtida por uma sequência finita de expansões a partir de $pi(Sigma, kappa)$ também os satisfaz — e, como o teto é preservado, nenhuma delas apresenta material ilegível sob o teto de $kappa$.
] <teo-expansao-axiomas>

#prova[
  Cada expansão é, por definição, um valor de $pi$ sobre algum acervo e alguma coordenada; logo satisfaz P1–P6. Por indução no número de expansões, toda perspectiva da sequência os satisfaz.
]

O teorema impede uma classe inteira de degradações: expansões feitas "à mão", acrescentando texto ao contexto sem passar pela projeção, podem violar limitação por autoridade (P3), honestidade (P4) ou omissão declarada (P5) — por exemplo, ao acrescentar o conteúdo de um documento sem seu estatuto, ou ao abrir um recurso fora do teto de autoridade porque "o consumidor pediu".

#invariante(titulo: [Expansões não mutam perspectivas anteriores])[
  Uma expansão produz uma nova perspectiva, com seu próprio instante; a perspectiva anterior permanece como estava. Em particular, se a perspectiva anterior registrava "não observado nesta expansão", esse registro continua verdadeiro depois que uma expansão posterior observa o objeto.
] <inv-expansao-nao-muta>

O invariante é a forma, para expansões, do @inv-observado-agora. Ele permite responder, depois, à pergunta "o que o consumidor sabia quando decidiu?", que seria impossível se as perspectivas fossem atualizadas no lugar.

#exercicios[
  + Mostre que, se $kappa union.sq h$ é mais específica que $kappa$ e $pi$ é monótona em especificidade (no sentido da @sec-modelo-aplicabilidade), a expansão nunca _remove_ asserções aplicáveis, exceto por exclusões de orçamento declaradas.
  + Descreva uma expansão "à mão" que viola P4 e explique como a definição como nova projeção a evita.
  + Mostre que expandir duas alças em ordens diferentes produz a mesma perspectiva final, supondo que a projeção seja determinística e que as alças refinem componentes independentes da coordenada.
]

== Relevância derivada <sec-front-relevancia>

Que alças oferecer? Uma resposta tentadora é: todas as relações que partem dos recursos da perspectiva. Em grafos reais, isso explode.

#proposicao(titulo: [O fecho irrestrito torna tudo relevante])[
  Seja $G$ um grafo de recursos em que todo vértice é alcançável a partir do foco, com excentricidade $d$ a partir dele. Se a relevância é definida como "alcançável a partir do foco por qualquer caminho de relações", então todos os recursos de $G$ são relevantes. Em grafos de "mundo pequeno", em que $d$ cresce como $O(log n)$, isso acontece com caminhos curtos.
] <prop-fecho-irrestrito>

#prova[
  Por hipótese, todo vértice é alcançável a partir do foco; a excentricidade limita o comprimento dos caminhos necessários.
]

#definicao(titulo: [Relevância derivada restrita])[
  Seja $N subset.eq T$ o subconjunto dos tipos de relação com _semântica de necessidade_ — por exemplo, #raw("escopo-direto"), #raw("dependência-requerida"), #raw("requisito-de-composição"), #raw("bloqueador-de-recurso-requerido"). A _relevância derivada_ de um recurso $x$ para um objetivo com âncoras de escopo $A$ é verdadeira se $x$ é alcançável a partir de $A$ por um caminho que usa apenas arestas de tipos em $N$.
] <def-relevancia-derivada>

#invariante(titulo: [Relacionado não é relevante])[
  Arestas de tipos sem semântica de necessidade — #raw("par-de"), #raw("relacionado-a"), "mesmo domínio", "mesmo locus", "mesmo autor" — não propagam relevância. Elas podem aparecer como _sinais de orientação_ na fronteira, com justificativa explícita, mas não tornam um recurso relevante.
] <inv-relacionado-relevante>

#definicao(titulo: [Sinal de orientação])[
  Um _sinal de orientação_ é uma alça cuja justificativa é uma razão observada pela qual um alvo _pode_ valer a pena expandir (por exemplo, uma ancestralidade comum), com efeito de autoridade nulo, sem ser relação de composição nem afirmação de relevância. Na metáfora visual: uma linha pontilhada entre duas estrelas, não uma constelação.
] <def-sinal-orientacao>

A distinção formaliza a divisão de trabalho entre componentes do sistema: um registro de descoberta _sinaliza_; a projeção _seleciona_; a engenharia de contexto _expande_.

=== Grau de interesse

Para ordenar as alças oferecidas, uma formulação clássica de visualização de informação é útil. #ct(<furnas1986>) propôs, para "visões olho-de-peixe" de estruturas grandes, o _grau de interesse_ de um item $x$ dado um foco $f$:
#eqn($ "GI"(x | f) = "IAP"(x) - D(x, f), $) <eq-grau-interesse>
em que $"IAP"(x)$ é a importância _a priori_ do item e $D(x, f)$ sua distância ao foco. Itens com grau de interesse acima de um limiar são mostrados; os demais, resumidos ou omitidos. Na fronteira, a importância a priori pode refletir o tipo do recurso e o gabarito de necessidades; a distância deve ser medida apenas sobre arestas de necessidade, pelo @inv-relacionado-relevante.

#exercicios[
  + Num grafo de dependências de software com 500 componentes e diâmetro 6, calcule quantos componentes seriam "relevantes" pelo fecho irrestrito a partir de um foco qualquer. Compare com uma estimativa do fecho restrito a dependências requeridas.
  + Classifique as arestas a seguir quanto à semântica de necessidade: "o serviço $A$ chama a API de $B$"; "$A$ e $B$ foram escritos pela mesma equipe"; "$A$ requer a credencial $C$"; "$A$ está no mesmo repositório que $B$".
  + Proponha uma função de importância a priori para recursos de um projeto de software e discuta seus vieses.
]

== Valor da informação <sec-front-valor>

Entre as alças disponíveis, qual expandir? A teoria da decisão oferece um critério: o _valor da informação_ — quanto a expansão melhora, em expectativa, a decisão que o consumidor vai tomar.

#definicao(titulo: [Valor da informação de uma expansão])[
  Seja $D$ o conjunto de decisões possíveis, $U(d, omega)$ a utilidade da decisão $d$ no estado $omega$ do mundo, e $Pr(omega | P)$ a crença do consumidor dada a perspectiva $P$. O _valor da informação_ da alça $h$, cuja expansão revela uma observação $o$ com distribuição $Pr(o | P)$, é
  $ "VI"(h | P) = E_o [max_d E[U(d, omega) | P, o]] - max_d E[U(d, omega) | P]. $
] <def-valor-informacao>

#proposicao(titulo: [O valor da informação é não negativo])[
  Para toda alça, $"VI"(h | P) >= 0$.
] <prop-vi-nao-negativo>

#prova[
  Para cada $o$, $max_d E[U | P, o] >= E[U(d^*, omega) | P, o]$, em que $d^*$ é a decisão ótima sem a observação. Tomando a esperança em $o$ e usando $E_o [E[U(d^*, omega) | P, o]] = E[U(d^*, omega) | P]$ (lei da esperança total), obtém-se o resultado.
]

A proposição justifica a intuição de que "saber mais nunca atrapalha" — _em expectativa, para um decisor que usa a informação corretamente_. O @cap-llm mostrou por que essa hipótese falha para modelos de linguagem: informação irrelevante dilui a atenção, e o consumidor não é um decisor bayesiano ideal. Por isso, na prática, a escolha de expansões pondera valor da informação e _custo de atenção_:

#eqn($ h^* = arg max_(h in Phi(P)) ("VI"(h | P) - lambda dot c(h)), $) <eq-escolha-expansao>

em que $lambda$ converte custo em unidades de utilidade e $c(h)$ inclui tokens, latência e o efeito de diluição. Como $"VI"$ raramente é calculável exatamente, usa-se uma aproximação operacional: o número esperado de _desconhecidos relevantes resolvidos_ por unidade de custo.

#principio(titulo: [Conformidade não é utilidade])[
  Uma expansão pode ser perfeitamente conforme — respeitar autoridade, preservar estatutos, declarar omissões — e ainda assim ter ganho zero: não resolver nenhum desconhecido relevante nem alterar nenhuma decisão. Avalie expansões pelos dois critérios separadamente.
] <pri-conformidade-utilidade>

#exercicios[
  + Um agente decide entre promover ou não uma revisão. Com a perspectiva atual, a probabilidade de os testes de integração passarem é $"0,7"$. A alça "abrir registro dos testes de integração" revela o resultado. Com utilidades $U("promover", "passou") = 10$, $U("promover", "falhou") = -50$, $U("não promover", dot) = 0$, calcule o valor da informação da alça.
  + Explique por que a @prop-vi-nao-negativo não contradiz a observação empírica de que contexto adicional pode piorar o desempenho de modelos.
  + Construa um exemplo numérico em que o valor da informação de uma expansão é positivo, mas menor que o custo da expansão, e outro em que é zero porque nenhum resultado possível da expansão mudaria a decisão.
]

== Profundidade justificada <sec-front-profundidade>

Expansões encadeiam-se: da perspectiva para uma aresta selecionada, da aresta para a fonte, da fonte para o estado material da fonte. Cada nível de profundidade custa mais e, frequentemente, cruza fronteiras de sistema. A pergunta "até onde expandir?" tem uma resposta disciplinada.

#principio(titulo: [Cada profundidade é justificada por uma necessidade real])[
  Uma nova profundidade de expansão — e, em projeto de sistemas, uma nova _capacidade_ de expansão — só se justifica quando um consumidor real fez uma pergunta que as profundidades existentes não respondem. "Poderia ser útil" não justifica; "o consumidor perguntou qual é o estado material atual, e nenhuma alça responde" justifica.
] <pri-profundidade-justificada>

Uma consequência é que a fronteira pode ser _condicionada pela pergunta_: em vez de uma lista fixa de alças, a perspectiva oferece um caminho que vai da pergunta do consumidor à aresta epistêmica relevante não resolvida e, daí, à necessidade limitada de evidência.

#algoritmo("Expande-por-Pergunta", params: $P, q, b$, legenda: [Expansão condicionada por pergunta: da pergunta à menor necessidade de evidência que a responde, sob um orçamento $b$ de expansões.])[
  + $E <- $ arestas epistêmicas não resolvidas de $P$ relevantes para $q$ #h(1fr) ▷ desconhecidos, conflitos, vencidos
  + #kw[se] $E = emptyset$ #kw[então] #kw[devolva] resposta a partir de $P$
  + $H <- {(e, h) : e in E, h in Phi(P) "ainda não expandida e capaz de resolver" e}$
  + #kw[se] $H = emptyset$ #kw[então] #kw[devolva] #est[desconhecido] com a lista de arestas e o que seria necessário
  + escolha $(e, h) in H$ que maximiza o valor líquido $"VI"(h) - lambda c(h)$ (@eq-escolha-expansao)
  + #kw[se] $b = 0$ #kw[ou] $"VI"(h) - lambda c(h) lt.eq 0$ #kw[então] #kw[devolva] resposta parcial a partir de $P$, com as arestas abertas declaradas
  + $P' <- "exp"(P, h)$; #kw[devolva] #proc("Expande-por-Pergunta")$(P', q, b - 1)$
] <alg-expande-pergunta>

O algoritmo termina: cada chamada recursiva consome uma unidade do orçamento $b$ e nunca reexpande a mesma alça. Sem o orçamento, a terminação não estaria garantida, porque expansões observacionais podem revelar desconhecidos novos. As linhas 4 e 6 são a contrapartida, na fronteira, do conjunto decisivo dos portões (@def-conjunto-decisivo): quando o sistema não consegue resolver, ele diz exatamente o que falta.

#observacao(titulo: [Várias dimensões não resolvidas não são uma funcionalidade])[Ao observar o estado material de uma fonte, um consumidor descobriu que várias dimensões permaneciam abertas — autoridade, revisão aceita, atualidade remota, aplicabilidade ao domínio, elegibilidade de navegação, identidade material. A tentação era transformar a lista numa "próxima funcionalidade". A leitura correta era outra: múltiplas dimensões não resolvidas não são uma funcionalidade; são um conjunto de perguntas, cada uma com seu dono, e a próxima profundidade deveria ser escolhida pela pergunta real do consumidor.]

#exercicios[
  + Execute o @alg-expande-pergunta mentalmente para a pergunta "posso promover a revisão $r$?" numa perspectiva que tem: candidato identificado, testes unitários aprovados, testes de integração não medidos, autoridade não estabelecida.
  + Por que o algoritmo é recursivo e não iterativo com uma lista fixa de alças? O que muda entre uma iteração e outra?
  + Proponha um critério de parada para o @alg-expande-pergunta baseado no valor da informação e no orçamento restante, e discuta o que deve ser registrado quando a expansão para por falta de orçamento.
]

== Sentinelas de escopo <sec-front-escopo>

Toda observação feita numa expansão tem escopo: foi feita _aqui_, _nesta perspectiva_, _com esta autoridade_. Consumidores tendem a esquecer o escopo e generalizar. Experimentos de transferência a consumidores frios revelaram três generalizações típicas, que convém prevenir explicitamente.

#invariante(titulo: [Sentinelas de escopo])[
  + _Não observado aqui não é não observado em lugar algum_: uma expansão que não observou um objeto não prova sua inexistência global.
  + _Desconhecido nesta perspectiva não é globalmente desconhecido_: outra perspectiva, com outra coordenada, pode conhecer.
  + _Autoridade não concedida não proíbe uso epistêmico somente leitura_: não ter autoridade para agir sobre um recurso não impede usar, como informação, o que dele foi legitimamente divulgado.
] <inv-sentinelas-escopo>

A terceira sentinela é a mais contraintuitiva e a mais importante para a utilidade do sistema. Um consumidor que interpreta "autoridade não concedida" como "não posso nem considerar esta informação" descarta conhecimento legítimo e toma decisões piores. A autoridade restringe _efeitos_; a divulgação (@pri-conhecer-divulgar) restringe _conhecimento_; são duas coisas.

#exercicios[
  + Para cada sentinela, escreva um exemplo de raciocínio errado de um consumidor e a correção.
  + Proponha uma forma de renderizar o escopo de cada observação que reduza a chance de generalização indevida.
  + Um agente expandiu a alça "dependências diretas" e concluiu que "o componente $C$ não é usado por ninguém". Identifique a sentinela de escopo violada e reescreva a conclusão corretamente.
]

== Expansões puras e expansões que observam o mundo <sec-front-costura>

Algumas expansões apenas recompõem o que já está no acervo — abrir um registro, seguir uma relação registrada, mostrar a história de uma decisão. Outras exigem _observar o mundo_: consultar o estado material de um repositório, verificar se um processo está em execução, ler a configuração efetiva de um serviço. As segundas cruzam uma costura importante.

#definicao(titulo: [Costura entre coordenação semântica e observação do mundo])[
  Uma expansão _pura_ é calculada apenas a partir do acervo e da coordenada. Uma expansão _observacional_ envolve um procedimento de observação (@def-observacao) executado por um componente com acesso ao mundo. A _costura_ é a fronteira entre a parte da expansão que decide _o que_ observar e _em qual perspectiva_ (coordenação semântica) e a parte que responde _o que existe materialmente_ naquele local (observação).
] <def-costura>

#principio(titulo: [Coordenação semântica não é observação do mundo])[
  O componente que coordena decide o que está sendo observado, dentro de qual perspectiva e a partir de qual candidato exato; o componente que observa responde o que existe materialmente naquele localizador. Nenhum dos dois ganha autoridade por isso, e nenhum faz o trabalho do outro: o coordenador não "adivinha" o estado material; o observador não decide aplicabilidade.
] <pri-costura>

Três regras decorrem da costura. Se o candidato a observar é _ambíguo_, a expansão exige seleção explícita ou permanece bloqueada — não escolhe por conta própria. Se a referência é _não resolvida_, a expansão não inventa um localizador. E a observação material permanece separada da referência, da aplicabilidade e da autoridade: observar que um repositório está presente numa máquina não estabelece que ele se aplica ao objetivo, nem que o consumidor pode alterá-lo.

#exercicios[
  + Classifique como puras ou observacionais: abrir o texto de uma decisão registrada; verificar a revisão atual de um repositório remoto; mostrar as dependências registradas de um serviço; listar os processos em execução numa máquina.
  + Por que expansões observacionais devem registrar suas observações no acervo como evidência? Relacione com o @inv-mudanca-evidencia e com a reprodutibilidade (P2).
  + Por que expansões puras podem ser repetidas livremente, enquanto expansões observacionais precisam registrar o instante? Dê um exemplo em que repetir uma expansão observacional produz um resultado diferente.
]

#quadro[
  - A fronteira é um conjunto de alças específicas, com tipo, custo, autoridade e justificativa; alças vagas anulam seu valor.
  - Âncora, fronteira e próximo objetivo são distintos; aresta aberta não é próximo objetivo.
  - Expansão é nova projeção sobre coordenada refinada: preserva os axiomas e não muta perspectivas anteriores.
  - Relevância só se propaga por arestas de necessidade; relacionado não é relevante; sinais de orientação são pontilhados.
  - Escolha expansões por valor da informação menos custo de atenção; conformidade não é utilidade.
  - Cada nova profundidade de expansão é justificada por uma pergunta real; a fronteira pode ser condicionada pela pergunta.
  - Sentinelas de escopo: não observado aqui não é inexistente; desconhecido aqui não é desconhecido globalmente; sem autoridade não é sem uso epistêmico.
  - Coordenação semântica e observação do mundo são separadas por uma costura explícita.
]

#problemas[
  #problema([Fronteira ótima sob orçamento])[
    Uma perspectiva pode oferecer no máximo $m$ alças (por limitação de orçamento de renderização).
    + Formule a escolha das $m$ alças como problema de cobertura das necessidades não atendidas pela perspectiva.
    + Mostre que, se cada alça cobre um conjunto de necessidades, o problema é submodular e o guloso tem garantia $(1 - 1\/e)$.
    + Discuta como incorporar a probabilidade de cada necessidade efetivamente surgir.
  ]
  #problema([Expansão adversarial])[
    Um consumidor (possivelmente comprometido por injeção de instruções) pede expansões sucessivas para extrair informação acima de seu teto de autoridade.
    + Mostre que, se toda expansão é uma projeção que satisfaz P3, nenhuma sequência de expansões ultrapassa o teto.
    + Identifique canais laterais (contagens, tempos de resposta, mensagens de erro) pelos quais a sequência ainda pode vazar informação.
    + Proponha mitigação para cada canal.
  ]
  #problema([Medindo fronteiras])[
    Proponha um experimento para comparar duas políticas de fronteira (alças genéricas versus alças específicas) com consumidores frios.
    + Defina as métricas: acurácia das respostas, número de expansões, tokens totais, generalizações indevidas de escopo.
    + Descreva como pré-registrar as distinções que o consumidor deve recuperar.
    + Discuta as ameaças à validade.
  ]
]

#notas[
  O mantra "visão geral primeiro, zoom e filtro, depois detalhes sob demanda" é de #ct(<shneiderman1996>); as visões olho-de-peixe e o grau de interesse são de #ct(<furnas1986>). A teoria do forrageamento de informação @pirolli1999 modela a navegação humana em espaços de informação como busca guiada por "cheiro de informação", em analogia com o forrageamento animal — uma moldura útil para pensar sobre a justificativa das alças. O valor da informação é um conceito clássico da teoria da decisão; para seleção adaptativa com garantias, ver #ct(<golovin2011>). A observação de que informação adicional pode prejudicar modelos de linguagem é discutida no @cap-llm @shi2023 @levy2024.

  As distinções entre âncora, fronteira e próximo objetivo, a relevância derivada restrita a arestas de necessidade, os sinais de orientação, as sentinelas de escopo e a costura entre coordenação semântica e observação do mundo são propostas deste livro; as três sentinelas de escopo correspondem a generalizações indevidas típicas de consumidores frios avaliados com premissas adversariais (@cap-avaliacao).
]
