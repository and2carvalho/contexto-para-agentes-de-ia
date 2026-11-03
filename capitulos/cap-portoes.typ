#import "/modelo/estilo.typ": *

= Portões, prontidão e verificação <cap-portoes>

#epigrafe(fonte: [Jerome Saltzer e Michael Schroeder, 1975])[Baseie as decisões de acesso na permissão, e não na exclusão.]

Um _portão_ é um ponto de decisão: antes de avançar um estágio de uma ação, aceitar um resultado ou prosseguir para a próxima etapa de um trabalho, avalia-se um conjunto de condições. Portões são o mecanismo pelo qual a administração de contexto transforma invariantes em comportamento — e, mal projetados, são também o lugar onde invariantes morrem silenciosamente, diluídas numa nota média ou contornadas por um "verde" que não mediu nada.

Este capítulo trata de portões com rigor. A @sec-port-logica dá a semântica lógica de um portão sobre informação incompleta e prova a propriedade de falhar fechado. A @sec-port-compensacao mostra por que portões devem ser não compensatórios. A @sec-port-saidas reformula a saída de um portão como uma transformação de contexto. A @sec-port-escalonamento trata de escalonamento e do conjunto decisivo mínimo. A @sec-port-sentinelas introduz atenção focal com sentinelas. A @sec-port-roteamento usa portões para rotear computação. A @sec-port-verificacao reúne a disciplina de estados de verificação honestos.

== A lógica de um portão <sec-port-logica>

#definicao(titulo: [Portão])[
  Um _portão_ é uma fórmula proposicional $g$ sobre variáveis de pré-condição $v_1, dots, v_n$, cada uma avaliada, no momento do portão, num estatuto de $K_3$ — $sans(V)$ (provada), $sans(F)$ (refutada) ou $sans(D)$ (desconhecida). O portão _abre_ se e somente se $g$ é avaliada como $sans(V)$ na lógica forte de Kleene (@sec-ap-kleene).
] <def-portao>

#teorema(titulo: [Portões de Kleene falham fechado])[
  Seja $g$ um portão construído com $not$, $and$ e $or$; seja $v$ a valoração das pré-condições no instante da avaliação e $w$ a valoração clássica verdadeira no instante do efeito. Se $v$ é _correta em relação a $w$_ — isto é, $v scripts(lt.eq)_i w$: toda variável que $v$ dá como $sans(V)$ ou $sans(F)$ tem esse mesmo valor em $w$ —, então $g(v) = sans(V)$ implica $g(w) = sans(V)$. Equivalentemente: com informação correta, ainda que incompleta, nenhum portão abre numa situação em que, com informação completa, permaneceria fechado.
] <teo-falha-fechado>

#prova[
  Pela monotonicidade informacional de $K_3$ (@teo-ap-k3-monotono), se $v scripts(lt.eq)_i w$ (componente a componente), então $g(v) scripts(lt.eq)_i g(w)$. Se $g(v) = sans(V)$, o único valor $x$ com $sans(V) scripts(lt.eq)_i x$ é o próprio $sans(V)$; logo $g(w) = sans(V)$.
]

O teorema dá sentido preciso à expressão _falhar fechado_ — o princípio de _padrões à prova de falha_ de #ct(<saltzer1975>): a política "abrir apenas sob $sans(V)$" nunca precisa ser desfeita por informação adicional consistente. A política complementar — "fechar apenas sob $sans(F)$" — falha aberto: abre sob desconhecimento e pode ter de ser revertida.

#observacao(titulo: [O que o portão não garante])[
  A hipótese de correção — $v scripts(lt.eq)_i w$ — não é garantida pelo portão. Ela depende da atualidade das observações (@cap-tempo), da proveniência e da força de cada #est[provado] (@cap-proveniencia) e do intervalo entre a avaliação e o efeito (@inv-autoridade-tempo). Um portão correto sobre evidência envelhecida falha _aberto_. Quanto aos estatutos de Belnap do acervo, um estatuto #est[conflitante] entra no portão como $sans(D)$; o mapeamento $top |-> sans(D)$ não é monótono na ordem de informação, e por isso o conflito precisa ser exposto (e resolvido por ação explícita), não absorvido.
]

#corolario(titulo: [Pré-condição desconhecida, nenhuma execução])[
  Se um portão é uma conjunção $g = v_1 and dots and v_n$ e alguma pré-condição $v_i$ é $sans(D)$, o portão não abre.
] <cor-precondicao-desconhecida>

#prova[
  Na lógica forte de Kleene, $x and sans(D) in {sans(D), sans(F)}$ para todo $x$; logo a conjunção não vale $sans(V)$.
]

=== Kleene e supervaloração #avancado <sec-portoes-supervaloracao>

A avaliação forte de Kleene é conservadora: para $g = x or not x$ com $x = sans(D)$, ela devolve $sans(D)$, embora toda completação clássica dê $sans(V)$. Existe uma regra mais permissiva que ainda falha fechado.

#definicao(titulo: [Portão supervaloracional])[
  O portão $g$ _abre por supervaloração_ sob $v$ se $g(w) = sans(V)$ para toda valoração clássica $w$ que estende $v$.
] <def-supervaloracao>

#teorema(titulo: [Kleene é correta, mas incompleta, para a supervaloração])[
  (i) Se $g(v) = sans(V)$ na lógica forte de Kleene, então $g$ abre por supervaloração sob $v$. (ii) A recíproca é falsa. (iii) A abertura por supervaloração é a regra mais permissiva que falha fechado: toda regra que abra sob uma valoração $v$ que tem uma extensão clássica com $g = sans(F)$ não falha fechado. (iv) Decidir a abertura por supervaloração é coNP-completo.
] <teo-supervaloracao>

#prova[
  (i) É o @teo-falha-fechado aplicado a cada extensão clássica. (ii) $g = x or not x$ com $v(x) = sans(D)$. (iii) Imediato da definição de falhar fechado: a extensão em que $g = sans(F)$ pode ser a verdadeira. (iv) Um certificado de _não_ abertura é uma extensão $w$ com $g(w) != sans(V)$, verificável em tempo polinomial; logo o problema está em coNP. Com $v$ inteiramente indefinida, abrir por supervaloração equivale a decidir se $g$ é tautologia, problema coNP-completo @garey1979.
]

Na prática, a avaliação de Kleene é a aproximação polinomial adotada; para portões que são conjunções de pré-condições — a grande maioria —, as duas regras coincidem.

=== A cadeia de qualificação

Os portões que antecedem uma ação sobre um alvo costumam verificar, implícita ou explicitamente, uma sequência ordenada de condições: a _relação_ que liga o consumidor ao alvo existe; a _identidade_ do alvo está resolvida; o _locus_ em que ele está materializado é conhecido; a ação é _aplicável_ à coordenada; o consumidor tem _autoridade_; existe a _função_ necessária para executá-la ali; ela é _acionável_ (visível, elegível, executável); e ela foi _selecionada_ pelo consumidor ou pelo titular. Cada elo pressupõe os anteriores: não faz sentido avaliar autoridade sobre um alvo cuja identidade não foi resolvida. A cadeia de qualificação é um refinamento dos estágios "válida", "aplicável", "pronta" e "autorizada" do ciclo da ação (@def-estagios-acao), e segue a mesma ordem: relação, identidade e locus refinam a validade; a função disponível e a acionabilidade refinam a prontidão.

#proposicao(titulo: [Pular um elo só aumenta falsos positivos])[
  Seja $g = q_1 and dots and q_n$ o portão formado pela cadeia de qualificação e $g'$ o portão obtido omitindo um elo $q_k$.
  + Se os elos são logicamente independentes, todo caso em que $g$ abre também abre $g'$, e há casos em que $g'$ abre e $g$ não.
  + Se o elo $q_(k+1)$ pressupõe $q_k$ — só tem semântica definida quando $q_k = sans(V)$ e é avaliado sobre o alvo que $q_k$ estabeleceu —, omitir $q_k$ não altera a forma da fórmula, mas torna _não confiável_ a avaliação de $q_(k+1)$: ela pode valer $sans(V)$ sobre um alvo diferente do pretendido.
  Em ambos os casos, omitir um elo nunca evita uma execução indevida e pode causar uma.
] <prop-pular-elo>

#prova[
  (a) Se $g = sans(V)$, todos os $q_i$ valem $sans(V)$, e $g'$, conjunção de um subconjunto deles, também vale $sans(V)$. Uma valoração com $q_k = sans(F)$ e os demais $sans(V)$ é admissível por independência, e nela $g' = sans(V) != g$. (b) Exemplo: sem o elo de identidade, um nome resolve para um homônimo noutro domínio; a verificação de autoridade, feita sobre o homônimo, vale $sans(V)$, e o portão abre para um efeito sobre o recurso errado. Em ambos os casos, $g'$ abre sempre que $g$ abre, logo a omissão nunca impede uma execução.
]

#exercicios[
  + Para a ação "aplicar uma correção ao serviço $S$ em produção", instancie cada elo da cadeia de qualificação e indique a evidência que o sustenta.
  + Construa um portão com disjunção, $g = (v_1 and v_2) or v_3$, e uma valoração parcial sob a qual ele abre mesmo com uma variável desconhecida. Isso viola o @cor-precondicao-desconhecida? Por quê?
  + Prove que um portão avaliado com a lógica _fraca_ de Kleene (em que qualquer $sans(D)$ contamina o resultado) também falha fechado, e dê um exemplo em que ele abre menos vezes que o forte. Discuta o compromisso.
  + Um sistema registra a autorização como booleano, com "falso" quando o serviço de autoridade não responde. Mostre como isso pode levar a um portão que, ao ser reescrito, passa a falhar aberto.
]

== Portões não compensatórios <sec-port-compensacao>

Uma tentação recorrente é transformar portões em _notas_: cada dimensão de qualidade recebe um valor entre $0$ e $1$, combina-se por média ponderada, e o portão abre se a nota exceder um limiar. O resultado é simples, contínuo — e perigoso.

#definicao(titulo: [Regra de abertura não compensatória])[
  Uma _regra de abertura_ é um par $(A, tau)$ com $A: [0, 1]^n -> [0, 1]$ e limiar $tau in (0, 1]$; o portão abre em $x$ se $A(x) >= tau$. A regra é _não compensatória na dimensão $i$_ se $A(x) >= tau$ implica $x_i >= tau$, e _não compensatória_ se o for em todas as dimensões. Uma agregação $A$ é _não compensatória_ se $(A, tau)$ o é para todo $tau$; caso contrário, é _compensatória_: uma perda numa dimensão pode ser compensada por ganhos noutras.
] <def-compensatoria>

#proposicao(titulo: [Compensação admite violação crítica])[
  Seja $A$ uma agregação monótona (não decrescente em cada argumento) e $tau$ um limiar. Para cada dimensão $i$, existe um vetor $x$ com $x_i = 0$ e $A(x) >= tau$ se, e somente se, $A(1, dots, 1, 0, 1, dots, 1) >= tau$ (com o $0$ na posição $i$). Em particular, para a média aritmética de $n$ dimensões, qualquer limiar $tau lt.eq (n - 1)\/n$ deixa passar uma violação total de uma dimensão.
] <prop-compensacao>

#prova[
  Pela monotonicidade, o maior valor de $A$ com $x_i = 0$ é atingido com todas as demais dimensões em $1$. Para a média, esse valor é $(n - 1)\/n$.
]

#teorema(titulo: [Caracterização das agregações não compensatórias])[
  (i) $A$ é não compensatória se, e somente se, $A(x) lt.eq min_i x_i$ para todo $x$. (ii) Se, além disso, $A$ é monótona e idempotente ($A(t, dots, t) = t$), então $A = min$.
] <teo-min-unico>

#prova[
  (i) Se $A lt.eq min$ e $A(x) >= tau$, então, para todo $i$, $x_i >= min_j x_j >= A(x) >= tau$. Reciprocamente, se $A$ é não compensatória e $A(x) > 0$, tome $tau = A(x)$: a abertura em $x$ implica $x_i >= A(x)$ para todo $i$, isto é, $min_i x_i >= A(x)$; se $A(x) = 0$, a desigualdade é trivial. (ii) Por monotonicidade e idempotência, $A(x) >= A(min_i x_i, dots, min_i x_i) = min_i x_i$; com (i), $A(x) = min_i x_i$.
]

A proposição formaliza um exemplo que, na prática, é bem conhecido: "qualidade = 0,83, aprovado", quando uma das seis dimensões avaliadas — por exemplo, "a autoridade foi preservada" — vale zero. O teorema diz o que fazer: para dimensões críticas, só agregações limitadas superiormente pelo mínimo evitam a compensação (o produto, por exemplo, também a evita), e, entre as monótonas e idempotentes — as que preservam a escala dos estatutos —, o mínimo é a única. É o que o @lem-agregado-minimo recomenda para alegações compostas e o que a avaliação empírica exige no @cap-avaliacao (@prop-medias).

#principio(titulo: [Invariantes críticas não se diluem na média])[
  Portões sobre invariantes críticas são conjunções de verificações independentes, avaliadas em $K_3$; nunca médias ponderadas. Notas podem existir para fins de _diagnóstico_ ou _priorização_, mas não decidem a abertura de portões sobre invariantes.
] <pri-nao-compensatorio>

#exercicios[
  + Com seis dimensões e limiar 0,8 sobre a média, construa um vetor que passe no portão com "autoridade preservada" $= 0$.
  + Proponha uma forma de combinar dimensões críticas (por mínimo) e não críticas (por média) num único procedimento, e discuta sua interpretabilidade.
  + Um processo de aprovação usa a média de cinco notas (0 a 10) com limiar 7. Mostre um caso em que uma nota 0 numa dimensão crítica é compensada, e reescreva o processo como portão não compensatório.
]

== A saída de um portão como transformação de contexto <sec-port-saidas>

Um portão binário diz "passa" ou "não passa". Mas, num sistema de contexto, a pergunta mais útil depois de avaliar o resultado de um consumidor raramente é "foi bom?"; é "o que muda na próxima interação?". Isso sugere que a saída de um portão seja uma _operação sobre a perspectiva_.

#definicao(titulo: [Saídas de uma política de revisão])[
  Uma _política de revisão_ (ou portão de contexto) recebe o resultado de um consumidor e um conjunto de observações independentes de qualidade, e devolve uma das operações sobre a perspectiva:
  - #estado[suficiente]: prosseguir com a perspectiva atual;
  - #estado[expandir]: acrescentar à perspectiva material alcançável pela fronteira;
  - #estado[estreitar]: remover material que diluiu a atenção ou desviou o escopo;
  - #estado[recompor]: recalcular a perspectiva — na mesma coordenada, com o acervo atualizado, ou com outra coordenada ou gabarito;
  - #estado[pedir evidência]: obter uma observação específica antes de prosseguir;
  - #estado[mudar de perspectiva]: transferir o trabalho para outro ponto de vista (outro locus, outro papel, outro perfil ou outra granularidade);
  - #estado[escalar]: pedir decisão a quem tem a autoridade que falta (tipicamente o titular) — escalar transfere a decisão, não amplia a autoridade de quem escala;
  - #estado[adiar]: registrar como pendente, com condição de retomada;
  - #estado[bloquear aresta exata]: impedir uma transição específica, nomeando-a.
] <def-saidas-portao>

As observações de qualidade que alimentam a decisão são, por sua vez, perguntas independentes sobre o resultado do consumidor, por exemplo:

#figure(
  tabela(
    colunas: (1fr, 1fr),
    cabecalho: ([Observação], [Saída típica se falhar]),
    [A proveniência citada é suficiente?], [#estado[pedir evidência]],
    [O objetivo foi entendido?], [#estado[recompor] (coordenada mais explícita)],
    [A autoridade foi preservada?], [#estado[bloquear aresta exata]; #estado[escalar]],
    [A fronteira exata foi recuperada?], [#estado[expandir]],
    [Os desconhecidos foram localizados?], [#estado[pedir evidência]; #estado[expandir]],
    [A evidência está ligada ao sujeito certo?], [#estado[pedir evidência]],
    [Escopo e granularidade são adequados?], [#estado[estreitar] ou #estado[mudar de perspectiva]],
  ),
  caption: [Observações de qualidade e as transformações de perspectiva que tipicamente seguem de sua falha.],
) <tab-observacoes-qualidade>

A política de revisão e o portão lógico da @def-portao se ligam pelo conjunto decisivo (@sec-port-escalonamento). Quando o portão é uma conjunção de pré-condições e não abre, a saída é determinada pela natureza das pré-condições não satisfeitas: alguma em $sans(F)$ ⇒ #estado[bloquear aresta exata]; alguma de autoridade em $sans(D)$ ⇒ #estado[escalar]; desconhecidos alcançáveis por uma alça da fronteira ⇒ #estado[expandir]; desconhecidos sem alça ⇒ #estado[pedir evidência]. Só quando todas as pré-condições valem $sans(V)$ e a falha está numa observação de qualidade do resultado (escopo, granularidade, atenção) entram #estado[estreitar], #estado[recompor] e #estado[mudar de perspectiva].

#principio(titulo: [Portões transformam contexto, não atribuem notas])[
  O resultado de um portão de contexto é a menor transformação da perspectiva que torna a próxima interação suficiente — ou a declaração de que nenhuma transformação ao alcance do sistema basta, com escalonamento.
] <pri-portao-transforma>

#exercicios[
  + Um agente executor devolve um relatório correto, mas que cita como evidência um registro de outro ambiente. Que observação de qualidade falha e que saída o portão deve produzir?
  + Descreva uma situação em que a saída correta é #estado[estreitar] e explique por que acrescentar mais contexto pioraria o resultado.
  + Por que #estado[bloquear aresta exata] é preferível a um bloqueio genérico do trabalho? Que informação ele preserva?
]

== Escalonamento e o conjunto decisivo mínimo <sec-port-escalonamento>

Quando um portão não abre por desconhecimento, ele pode simplesmente fechar — ou pode dizer _o que falta saber_. A segunda opção é muito mais útil, e tem uma formulação precisa.

#definicao(titulo: [Conjunto decisivo])[
  Dados um portão $g$ e uma valoração parcial $v$ com $g(v) = sans(D)$, um conjunto $S$ de variáveis desconhecidas é _decisivo_ se, para toda atribuição clássica às variáveis de $S$, o valor de $g$ fica determinado ($sans(V)$ ou $sans(F)$), independentemente das demais variáveis desconhecidas.
] <def-conjunto-decisivo>

Um portão que devolve um conjunto decisivo mínimo transforma o "não" num _plano de observação_: estas são as poucas coisas que, uma vez observadas, decidirão a questão.

#proposicao(titulo: [Conjunções têm conjunto decisivo trivial])[
  Se $g = v_1 and dots and v_n$ e o conjunto $D$ das variáveis desconhecidas é não vazio (e nenhuma conhecida é $sans(F)$), então $D$ é o único conjunto decisivo mínimo.
] <prop-decisivo-conjuncao>

#prova[
  Se alguma variável de $D$ ficar fora de $S$, atribuir $sans(V)$ a todas as de $S$ deixa $g$ dependente da variável omitida; logo $S$ não é decisivo. E $D$ é decisivo: qualquer atribuição clássica a $D$ determina a conjunção.
]

Para portões gerais, encontrar o conjunto decisivo mínimo é difícil (o problema contém a verificação de tautologia como caso particular), mas portões de pré-condições são, na prática, majoritariamente conjunções — e então a resposta é simples: liste os desconhecidos. A dificuldade prática não é computacional, é de projeto: o portão precisa _ter acesso_ à estrutura das pré-condições, em vez de receber apenas um booleano final.

#exercicios[
  + Encontre um conjunto decisivo mínimo para $g = (v_1 and v_2) or (v_3 and v_4)$ quando todas as variáveis são desconhecidas.
  + #avancado Mostre que decidir se um portão arbitrário tem conjunto decisivo vazio (isto é, se ele já está decidido apesar dos desconhecidos) é coNP-completo.
  + Para o portão $g = (v_1 and v_2) or (v_3 and v_4)$, encontre os conjuntos decisivos mínimos sob a valoração em que todas as variáveis são desconhecidas. Qual pré-condição convém verificar primeiro se as verificações têm custos diferentes?
]

== Atenção focal e sentinelas <sec-port-sentinelas>

Agentes que executam trabalho detalhado tendem a perder de vista a vizinhança sistêmica: concentrados em corrigir uma função, deixam de notar que um invariante global foi violado. A resposta não é pedir ao executor que "preste atenção a tudo", mas compor sua perspectiva em duas partes.

#definicao(titulo: [Perspectiva focal com sentinelas])[
  Uma _perspectiva com sentinelas_ é uma perspectiva composta de uma _projeção focal_, com alta resolução sobre o trabalho em curso, e de um pequeno conjunto de _projeções sentinela_, cada uma uma verificação barata de um invariante sistêmico que deve permanecer verdadeiro durante o trabalho (por exemplo: "a linha principal local coincide com a remota", "a autoridade não mudou", "o escopo continua limitado", "nenhum domínio foi inicializado por acidente").
] <def-sentinelas>

A ideia tem uma interpretação de divisão de trabalho entre consumidores. Num trabalho real, um agente executor, com alta resolução sobre o código, encontrou um defeito numa função; um agente supervisor, com resolução menor sobre os bytes mas maior sobre a vizinhança semântica, encontrou que o resultado declarava "navegável" um alvo que não era um domínio válido. Nenhum dos dois precisava observar o universo inteiro: ocupavam perspectivas diferentes sobre o mesmo trabalho.

#principio(titulo: [Papéis são posições observacionais])[
  "Supervisor" e "executor" não são modelos nem personalidades: são posições de observação — uma ampla e grossa, outra estreita e fina. Qualquer modelo, humano ou processo determinístico pode ocupar qualquer uma delas; o sistema escolhe quais posições precisam ser ocupadas para um trabalho.
] <pri-papeis-posicoes>

#exercicios[
  + Proponha cinco sentinelas para um agente que vai refatorar um módulo de autenticação.
  + Por que as sentinelas devem ser verificações baratas e, de preferência, determinísticas? O que acontece se cada sentinela exigir uma chamada a um modelo?
  + Proponha três sentinelas para um portão de revisão de código feito por um agente revisor, de modo que a ausência de qualquer uma torne o resultado do revisor inválido.
]

== Portões como roteadores de computação <sec-port-roteamento>

Se o portão decide _que transformação de contexto_ aplicar, pode também decidir _que tipo de processador_ deve tratar a próxima etapa. A observação central é que modelos grandes gastam boa parte de sua funcionalidade reconstruindo contexto mal estruturado: inferindo onde estão, o que aconteceu, qual o objetivo, quem tem autoridade, quais arquivos importam. Com uma perspectiva bem projetada — coordenada tipada, fatos exatos, desconhecidos, autoridade, fronteira e funcionalidades —, o problema que resta para o modelo é muito menor.

#hipotese(titulo: [Projeção melhor, modelo menor])[
  Para tarefas de rotina num domínio bem gerenciado, um modelo pequeno ou médio, consumindo perspectivas projetadas com rigor, atinge desempenho comparável ao de um modelo maior consumindo contexto não estruturado; o modelo maior é necessário principalmente quando a incerteza, a novidade semântica, o risco, a ambiguidade de trajetória ou a síntese entre domínios são altos.
] <hip-modelo-menor>

#figure(
  tabela(
    colunas: (1fr, 1fr),
    cabecalho: ([Resultado das observações], [Roteamento]),
    [evento rotineiro com condição observável], [funcionalidade determinística (callback, regra); nenhum modelo],
    [proveniência suficiente, escopo claro, baixa ambiguidade, autoridade clara], [modelo local ou pequeno],
    [escopo incerto ou intenção entre domínios ambígua], [expandir a perspectiva de coordenação; modelo maior se persistir],
    [risco alto ou novidade semântica alta], [modelo de fronteira e/ou escalonamento ao titular],
  ),
  caption: [Roteamento de computação a partir das observações do portão. Eventos rotineiros devem ser tratados por funcionalidades determinísticas, não por modelos "observando" continuamente.],
) <tab-roteamento>

#antipadrao(titulo: [Modelo como vigia])[
  Para saber quando um pedido muda de estado, um sistema mantém um modelo de linguagem consultando o estado periodicamente e "decidindo" se deve notificar o usuário. A tarefa é um evento com condição observável; deveria ser uma funcionalidade determinística (assinatura de evento, regra de notificação), configurada uma vez a partir da intenção do usuário.
] <anti-modelo-vigia>

#exercicios[
  + Classifique, segundo a @tab-roteamento, cinco tarefas de um assistente pessoal.
  + Proponha um experimento para testar a @hip-modelo-menor, controlando a qualidade da projeção e o tamanho do modelo como fatores independentes.
  + Descreva um fluxo em que portões determinísticos decidem quando consultar um modelo de linguagem, em vez de o modelo decidir quando consultar os portões. Que garantias o primeiro arranjo oferece que o segundo não oferece?
]

== Estados de verificação honestos <sec-port-verificacao>

Portões dependem de verificações — testes, observações, auditorias. A honestidade dos portões depende, portanto, da honestidade dos _estados_ que as verificações reportam.

#figure(
  tabela(
    colunas: (auto, 1fr, auto),
    cabecalho: ([Estado], [Significado], [Em $K_3$]),
    [#estado[aprovado]], [a verificação foi executada no alvo e no ambiente declarados e o resultado satisfaz o critério], [$sans(V)$],
    [#estado[reprovado]], [a verificação foi executada e o resultado não satisfaz o critério], [$sans(F)$],
    [#estado[bloqueado]], [a verificação não pôde ser executada (pré-requisito ausente, ambiente indisponível)], [$sans(D)$],
    [#estado[não alcançado]], [a verificação não foi executada porque um portão anterior parou o fluxo], [$sans(D)$],
    [#estado[não medido]], [ninguém tentou verificar], [$sans(D)$],
  ),
  caption: [Estados de verificação — o vocabulário canônico do livro para resultados de verificação. Apenas #estado[aprovado] sustenta a abertura de um portão; os três últimos são variedades de desconhecido e não devem ser confundidos com #estado[reprovado].],
) <tab-estados-verificacao>

A distinção entre os três últimos estados importa para o diagnóstico: #estado[não alcançado] aponta para o portão anterior; #estado[bloqueado], para o ambiente; #estado[não medido], para o processo. Reportar qualquer um deles como #estado[reprovado] produz diagnósticos errados ("o teste falhou" quando nunca rodou); reportá-los como #estado[aprovado] é simplesmente falso.

Reunimos a seguir as regras de verificação que a prática mostrou indispensáveis.

#principio(titulo: [Disciplina de verificação])[
  + _Declare o que foi executado_: comando, diretório, revisão, ambiente. Um "aprovado" sem esses metadados não identifica o que foi aprovado.
  + _Teste aprovado não é evidência por si_: torna-se evidência quando registrado com proveniência e ligado ao sujeito.
  + _Prove propriedades negativas explicitamente_: "não aconteceu" não prova "é rejeitado"; tente o caso proibido e registre a rejeição.
  + _Distinga dívida herdada de regressão_: uma falha presente na linha principal não foi necessariamente causada pelo trabalho corrente; compare antes e depois (teste diferencial).
  + _Leituras exploratórias provam não mutação_: uma operação declarada como somente leitura registra o estado antes e depois (por exemplo, resumos de conteúdo) e prova que nada mudou.
  + _Observável antes de declarável_: só declare um estado desejado depois de conseguir explicar o estado atual.
  + _Nomeie o grau de verificação_: inspeção independente, reexecução, ou aceitação da evidência de outro.
  + _Verifique o caminho vivo_: antes de construir, pergunte qual afirmação será provada, quem é dono da semântica, como a funcionalidade é invocada no sistema real e como a consequência será observada.
] <pri-disciplina-verificacao>

#estudo-de-caso(titulo: [O teste que nunca rodou])[
  Um agente relatou "todos os testes aprovados (42 pacotes)". A revisão do pacote de retorno mostrou que a contagem correspondia à suíte de outro repositório, executada num diretório diferente, porque o agente havia mudado de diretório durante a sessão. Os testes do repositório alvo estavam, na verdade, #estado[não medidos]. A partir desse caso, os pacotes de retorno passaram a exigir, para toda afirmação de verificação, o comando, o diretório, o repositório e a revisão — e o portão de aceitação passou a rejeitar afirmações de verificação sem esses metadados.
] <caso-teste-nunca-rodou>

#exercicios[
  + Um portão de integração contínua reporta "falhou" quando o serviço de banco de dados de teste não sobe. Reclassifique o estado corretamente e explique o efeito da correção no diagnóstico.
  + Descreva como provar que um comando de "inspeção" não altera o estado de um repositório.
  + Escreva o procedimento de um teste diferencial que distinga, para uma falha observada, dívida herdada de regressão introduzida.
]

#quadro[
  - Portões são fórmulas sobre pré-condições em $K_3$; abrir apenas sob $sans(V)$ é falhar fechado (@teo-falha-fechado).
  - Invariantes críticas não se diluem em médias: agregação compensatória admite violações totais (@prop-compensacao).
  - A saída de um portão de contexto é uma transformação da perspectiva: suficiente, expandir, estreitar, recompor, pedir evidência, mudar de perspectiva, escalar, adiar, bloquear aresta exata.
  - Portões úteis devolvem o conjunto decisivo de desconhecidos — para conjunções, a lista dos desconhecidos.
  - Perspectivas focais com sentinelas dividem atenção sem exigir que alguém observe tudo; papéis são posições de observação.
  - Portões podem rotear computação: funcionalidades determinísticas para rotina; modelos maiores para incerteza e risco.
  - Estados de verificação honestos distinguem aprovado, reprovado, bloqueado, não alcançado e não medido.
]

#problemas[
  #problema([Portões com estatutos de Belnap])[
    Estenda a @def-portao para variáveis em $sans("FOUR")$, incluindo o estatuto contraditório $top$.
    + Proponha a regra de abertura e mostre que ela falha fechado também diante de conflitos.
    + Discuta se um conflito deve produzir a saída #estado[escalar] ou #estado[pedir evidência], e em que circunstâncias.
  ]
  #problema([Aprendendo saídas de portão])[
    Suponha que se tenha um registro histórico de resultados de consumidores, observações de qualidade e a transformação de perspectiva que um revisor humano escolheu.
    + Formule o problema de aprender a política do portão como classificação.
    + Quais transformações nunca deveriam ser decididas automaticamente? Justifique com base no @inv-linguagem-autoridade.
    + Proponha uma métrica de avaliação que penalize mais fortemente escolher #estado[suficiente] quando a correta era #estado[escalar] do que o inverso.
  ]
  #problema([Sentinelas e custo])[
    Um agente trabalha por $T$ passos; cada sentinela custa $c_s$ por verificação e detecta uma violação com probabilidade $p$ se ela ocorreu desde a última verificação.
    + Modele o custo esperado de uma violação não detectada como função do intervalo entre verificações.
    + Encontre o intervalo ótimo.
    + Discuta como sentinelas orientadas a eventos (verificar quando algo relevante muda) alteram a análise.
  ]
]

#notas[
  A semântica de portões em lógica de três valores apoia-se em #ct(<kleene1952>) e, para fontes conflitantes, em #ct(<belnap1977>); a expressão "falhar fechado" corresponde aos _padrões à prova de falha_ de #ct(<saltzer1975>). A supervaloração vem da filosofia da vagueza e da semântica de lacunas de valor de verdade; sua relação com a lógica de Kleene é a de uma regra correta, porém não polinomial, contra uma aproximação polinomial. A crítica às agregações compensatórias é antiga na teoria da decisão multicritério e em avaliação de riscos; o @teo-min-unico dá a ela uma forma elementar. A formulação da saída de um portão como transformação da perspectiva, a atenção focal com sentinelas e o roteamento de computação por qualidade são propostas deste livro; não conhecemos tratamento anterior com essa forma.

  A disciplina de verificação reúne lições de engenharia de software sobre testes, integração contínua e verificação de propriedades de segurança; a exigência de provar propriedades negativas explicitamente é central em engenharia de segurança, e a distinção entre regressão e dívida herdada corresponde a práticas de teste diferencial. Modelos de linguagem melhoram resultados quando recebem retroalimentação externa @shinn2023 @madaan2023, mas a autocorreção sem verificação externa não é confiável e pode piorar o resultado @huang2024selfcorrect @kamoi2024 — razão pela qual relatos de sucesso de executores precisam ser verificados por portões, não por releitura do próprio texto.
]
