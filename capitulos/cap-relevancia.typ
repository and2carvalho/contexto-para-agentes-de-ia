#import "/modelo/estilo.typ": *

= Objetivos, requisitos, relevância e divulgação <cap-relevancia>

#epigrafe[O design pode decidir que algo é relevante; não pode torná-lo autorizado.]

A Parte III tratou de _como_ calcular uma perspectiva. A Parte IV trata de _que_ perspectiva calcular e de como apresentá-la — o domínio do design de contexto. Este primeiro capítulo da parte trata das decisões que determinam o conteúdo: qual é o objetivo, o que ele exige, o que é relevante para ele, e o que pode ser mostrado a quem.

Essas quatro decisões são frequentemente fundidas. "O agente pode ver isso?" é tratado como "isso é relevante?"; "isso é relevante?" é respondido por semelhança de palavras com o enunciado do objetivo; "o objetivo é este" é inferido da última mensagem do usuário. A @sec-rel-objetivo trata do objetivo, de seu escopo e do foco. A @sec-rel-relevancia trata da relevância derivada. A @sec-rel-requisitos formaliza requisitos e sua resolução. A @sec-rel-quatro separa as quatro perguntas — pode, importa, pode ver, viu. A @sec-rel-divulgacao define a política de divulgação. A @sec-rel-perfis trata de perfis, modos e escopos temporários.

== Objetivo, escopo e foco <sec-rel-objetivo>

#definicao(titulo: [Escopo e foco de um objetivo])[
  O _escopo_ de um objetivo responde "sobre o que é este objetivo?" e é expresso por _âncoras tipadas_: referências a recursos e a requisitos. O _foco_ responde "a que quero dar atenção agora?" e é um subconjunto efêmero do escopo. O escopo é a fronteira de atenção do objetivo — pode atravessar domínios —, enquanto o domínio é a fronteira de soberania. A durabilidade do escopo acompanha a do objetivo; o foco muda a cada passo.
] <def-escopo-foco>

#invariante(titulo: [O texto do objetivo não é um classificador])[
  O escopo de um objetivo não é expresso por caminhos, nomes de repositórios, palavras-chave, semelhança vetorial ou rótulos livres. Palavras no enunciado podem ajudar a _propor_ âncoras; não as substituem. Um objetivo que "menciona produção" não torna relevante, por isso, uma máquina chamada "produção".
] <inv-texto-objetivo>

O objetivo é uma componente da coordenada (@def-coordenada) e, como tal, pode estar ausente. Há três casos, que devem ser distinguidos.

#definicao(titulo: [Estados do objetivo])[
  - #estado[sem objetivo]: a perspectiva é de orientação — mostra onde se está e o que existe, sem selecionar trabalho nem recursos por relevância;
  - #estado[objetivo resolvido]: as âncoras do objetivo resolvem; a perspectiva seleciona trabalho e recursos aplicáveis;
  - #estado[objetivo não resolvido]: o objetivo foi declarado mas suas âncoras não resolvem; ele é preservado como declarado, sem substituição por um objetivo "parecido", e a perspectiva devolve a lacuna.
] <def-estados-objetivo>

#invariante(titulo: [O objetivo não é adivinhado])[
  O objetivo corrente não é inferido da unidade aberta mais recente, da primeira da lista, nem do teor das últimas mensagens. Mudanças de intenção do titular são explícitas; um agente que persegue uma intenção já abandonada — ou que adivinha uma nova — está operando com coordenada inventada.
] <inv-objetivo-adivinhado>

Uma confusão vizinha é a de categoria: tratar a _composição desejada_ de domínios como objetivo, ou derivar a composição a partir de listas de trabalhos. A composição diz que domínios se relacionam e como; o objetivo diz o que se pretende fazer. Um tem dono na topologia, o outro na governança do trabalho.

#exercicios[
  + Escreva o escopo, por âncoras tipadas, do objetivo "corrigir a falha de autenticação no serviço de pagamentos". Que âncoras você não consegue escrever sem consultar o acervo?
  + Dê um exemplo para cada um dos três estados do objetivo e a perspectiva correspondente.
  + Um titular escreve "melhore o desempenho do serviço de busca". Escreva o escopo e o foco do objetivo com âncoras tipadas, e liste as perguntas que o sistema deve fazer antes de considerar o objetivo resolvido.
]

== Relevância derivada <sec-rel-relevancia>

O @cap-fronteira introduziu a relevância derivada como alcançabilidade restrita a arestas com semântica de necessidade (@def-relevancia-derivada) e mostrou que o fecho irrestrito torna tudo relevante (@prop-fecho-irrestrito). Aqui tratamos do cálculo.

#algoritmo("Deriva-Relevância", params: $A, G, T_N, alpha$, legenda: [Relevância derivada por busca em largura restrita às arestas de necessidade (tipos em $T_N$), a partir das âncoras de escopo $A$ no grafo de recursos $G$, sob o teto $alpha$.])[
  + $"Rel" <- A$; $Q <- $ fila com os elementos de $A$
  + #kw[enquanto] $Q$ não vazia #kw[faça]
    + $x <- $ #proc("Retira")$(Q)$
    + #kw[para cada] aresta $(x, t, y)$ de $G$ com $t in T_N$ #kw[faça]
      + #kw[se] $y in.not "Rel"$ #kw[então] $"Rel" <- "Rel" union {y}$; registre a justificativa $(x, t, y)$; #proc("Insere")$(Q, y)$
  + #kw[para cada] justificativa que atravessa um recurso ilegível sob $alpha$ #kw[faça] substitua-o por "intermediário retido" #h(1fr) ▷ P3
  + #kw[devolva] $"Rel"$ com as justificativas
] <alg-deriva-relevancia>

O algoritmo é uma busca em largura, com custo $O(|V| + |E|)$; sua importância está nas restrições: só arestas de necessidade propagam, e cada recurso relevante carrega a _justificativa_ — o caminho de necessidade que o liga ao escopo. Essa justificativa é o que a perspectiva mostra quando o consumidor pergunta "por que isto está aqui?". Como o caminho pode passar por recursos que o consumidor não pode ler, a linha 6 filtra a justificativa pela autoridade; a alternativa — buscar apenas por recursos legíveis — dá a relevância _sob_ o teto, que pode perder recursos legíveis alcançáveis só através de ilegíveis.

#lema(titulo: [Correção de Deriva-Relevância])[
  Ao término, $y in "Rel"$ se e somente se existe em $G$ um caminho de algum $a in A$ a $y$ cujas arestas têm todas tipo em $T_N$; e a justificativa registrada para $y$ é o último passo de um caminho de comprimento mínimo.
] <lem-deriva-relevancia>

#prova[
  Invariante de laço: todo vértice em $"Rel"$ é alcançável de $A$ por arestas com tipo em $T_N$, e os vértices entram em $"Rel"$ em ordem não decrescente de distância — a propriedade da busca em largura @cormen2022. Término: cada vértice entra na fila no máximo uma vez. Completude: se $y$ é alcançável e não está em $"Rel"$, seja $z$ o primeiro vértice de um caminho até $y$ que não está em $"Rel"$; seu predecessor no caminho está em $"Rel"$, logo foi inserido e retirado da fila, e ao examinar a aresta até $z$ o teria inserido — contradição.
]

#invariante(titulo: [A unidade de relevância é o recurso])[
  Um domínio relevante não torna relevantes todos os seus recursos; o domínio de origem do consumidor não está, por isso, inteiramente divulgado. A granularidade da relevância é o recurso lógico, não o domínio, o repositório ou a máquina.
] <inv-unidade-relevancia>

#exercicios[
  + Num grafo com as arestas "$A$ depende de $B$", "$B$ é par de $C$", "$C$ depende de $D$", e âncora $A$, quais recursos são relevantes se $N = {#raw("depende-de")}$? E se a aresta "par de" fosse incluída em $N$?
  + Por que a justificativa deve ser registrada junto com cada recurso relevante?
  + Por que a unidade de relevância é o recurso, e não o trecho de texto? Dê um exemplo em que derivar relevância por trechos leva a incluir no contexto um fragmento sem o recurso que lhe dá sentido.
]

== Requisitos e sua resolução <sec-rel-requisitos>

Objetivos frequentemente apontam não só para _coisas_, mas para _condições_: "o agente precisa de leitura no repositório $R$", "o serviço $S$ precisa estar materializado em algum nó". Essas condições são requisitos.

#definicao(titulo: [Requisito])[
  Um _requisito_ é identificado pelo seu _lugar semântico_ — a tripla (contexto de composição, dono, dimensão), em que a dimensão pertence a um conjunto fechado (por exemplo, acesso requerido, materialização requerida) — e tem um _valor desejado_ (por exemplo, "leitura"). Sua _resolução corrente_ é recalculada contra a realidade observada (@def-resolucao-candidatos).
] <def-requisito>

#invariante(titulo: [A identidade do requisito é seu lugar, não seu valor])[
  Mudar o valor desejado de um requisito (de leitura para escrita) não cria um requisito novo: altera o valor do mesmo requisito. Identificar requisitos por valor, posição numa lista ou identificador aleatório quebra referências a eles quando são editados.
] <inv-identidade-requisito>

Quando um requisito pode ser satisfeito por vários _candidatos_ — por exemplo, o serviço $S$ pode ser obtido em qualquer de três nós —, a resolução é um problema de alcançabilidade.

#definicao(titulo: [Resolução com candidatos])[
  A resolução de um requisito com candidatos declarados $L_1, dots, L_n$ é, por casos exaustivos:
  - #estado[lacuna], se não existe relação tipada entre o requisito e candidatos — o sistema não inventa candidatos;
  - #estado[satisfeito], se algum candidato é observado satisfazendo o requisito;
  - #estado[não resolvido], se nenhum candidato é observado satisfazendo, mas algum tem observação #est[desconhecido];
  - #estado[bloqueado], se todos os candidatos foram observados e nenhum satisfaz.
] <def-resolucao-candidatos>

#fato(titulo: [A resolução é monótona em disponibilidade])[
  Se o conjunto de candidatos disponíveis cresce (mantidos os demais fatos), um requisito #estado[satisfeito] permanece #estado[satisfeito]; um requisito #estado[bloqueado], porém, pode tornar-se #estado[satisfeito] ou #estado[não resolvido].
] <prop-resolucao-monotona>

#prova[
  Satisfeito significa que existe um candidato observado que o satisfaz; aumentar o conjunto de disponíveis preserva a existência desse candidato. Para a segunda parte, um candidato novo pode satisfazer o requisito ou ter observação ainda #est[desconhecido].
]

#exercicios[
  + Escreva os requisitos de um objetivo "executar a suíte de integração do serviço $S$" e sua resolução numa situação em que um dos dois nós candidatos está fora do ar.
  + Por que, sem relação tipada requisito → candidato, o resultado correto é uma lacuna e não "bloqueado"?
  + Mostre, com um exemplo, a monotonicidade da resolução em disponibilidade: tornar disponível um novo candidato nunca transforma um requisito #estado[satisfeito] em #estado[não resolvido]. Dê um exemplo em que um novo candidato transforma um requisito #estado[bloqueado] em #estado[não resolvido], e explique por que isso não é um retrocesso epistêmico.
]

== Quatro perguntas distintas <sec-rel-quatro>

Para cada recurso que poderia entrar numa perspectiva, quatro perguntas distintas precisam de resposta.

#figure(
  tabela(
    colunas: (auto, 1fr, 1fr),
    cabecalho: ([Pergunta], [Nome], [Quem responde]),
    [Pode?], [autorização], [o dono da autoridade do recurso (@cap-autoridade)],
    [Importa?], [relevância e aplicabilidade], [a derivação a partir do escopo e da coordenada],
    [Pode ver?], [divulgação], [a política de divulgação, sob o teto de autoridade],
    [Viu?], [observação efetiva], [a trajetória: o que de fato entrou no contexto do consumidor],
  ),
  caption: [Quatro perguntas distintas sobre um recurso. Nenhuma resposta pode ser _substituída_ por outra; num sistema correto valem apenas as implicações "viu ⇒ pode ver" e "pode ver ⇒ pode ler".],
) <tab-quatro-perguntas>

#invariante(titulo: [Autorização, relevância, divulgação e observação são distintas])[
  Estar autorizado não torna um recurso relevante; ser relevante não o torna expandido; poder vê-lo não significa tê-lo visto. Uma perspectiva que precisa de qualquer dessas informações mantém um campo para cada uma. As únicas implicações que um sistema correto garante são as que decorrem de P3: o que foi visto podia ser visto, e o que pode ser visto é legível sob o teto.
] <inv-quatro-perguntas>

#exercicios[
  + Para cada uma das 16 combinações das quatro perguntas, decida se é possível num sistema que satisfaz P3 e dê um exemplo das que forem.
  + Relacione a @tab-quatro-perguntas com os eixos de estado do @cap-working-set.
  + Construa uma tabela com as 16 combinações das quatro perguntas (pode, importa, pode ver, viu) e, para cinco delas, descreva uma situação concreta e o que a perspectiva deve dizer ao consumidor.
]

== A política de divulgação <sec-rel-divulgacao>

#definicao(titulo: [Política de divulgação])[
  Uma _política de divulgação_ para uma coordenada $kappa$ é uma função $delta_kappa$ que associa a cada asserção do acervo um de quatro modos — #estado[divulgado] (conteúdo no contexto), #estado[só referência] (referência resolúvel, sem conteúdo), #estado[só existência] (o consumidor sabe que algo existe, sem referência) ou #estado[retido] (nada) —, acompanhado de uma razão, sujeita a: (i) se a asserção é ilegível sob o teto, o modo é #estado[só existência] ou #estado[retido] (P3); (ii) se é aplicável e legível, o modo não é #estado[retido], salvo exclusão declarada em $X$ (P5). A política é determinística e explicável.
] <def-politica-divulgacao>

#exemplo(titulo: [Explicações de divulgação])[
  "$X$ divulgado: aplicável ao objetivo e relação de dependência requerida com o escopo." "$Y$ só referência: aplicável, mas excede o orçamento; expansível." "$Z$ só existência: conhecido mas não aplicável ao objetivo; mencionado para evitar falsa ausência." "$W$ retido: fora do teto de autoridade do consumidor."
] <ex-explicacoes-divulgacao>

#invariante(titulo: [A existência também é divulgação])[
  Dizer que algo existe — seu nome, sua contagem, sua categoria — já revela informação. A política de divulgação se aplica a metadados, inclusive às declarações de exclusão (P5) e aos rótulos das alças de expansão.
] <inv-existencia-divulgacao>

#invariante(titulo: [Divulgação não resolve requisitos nem concede autoridade])[
  A política de divulgação decide o que é mostrado; ela não altera a resolução de requisitos, não concede autoridade e não seleciona trabalho. Cada uma dessas decisões tem seu próprio dono.
] <inv-divulgacao-limites>

Uma observação frequentemente esquecida: entregar contexto a um modelo de linguagem não exige autoridade de _efeito_, mas não está livre de fronteiras. Enviar material a um provedor de modelos é um fluxo de informação sujeito à política de divulgação, ao consentimento dos donos e às regras do provedor. A noção de _integridade contextual_ @nissenbaum2004 — fluxos de informação são apropriados ou não conforme as normas do contexto em que a informação foi produzida — é uma boa lente para essas decisões.

#exercicios[
  + Proponha uma política de divulgação para três consumidores (titular, agente interno, agente de um parceiro externo) sobre o mesmo acervo.
  + Explique como a declaração de exclusões pode violar a política de divulgação e como a renderização honesta deve lidar com isso.
  + Mostre como a contagem de itens retidos ("3 documentos retidos por autoridade") pode, por si só, vazar informação sensível. Proponha uma política de divulgação que preserve a honestidade (P5) sem esse vazamento.
]

== Perfis, modos e escopos temporários <sec-rel-perfis>

#definicao(titulo: [Perfil, papel e modo])[
  Um _perfil_ descreve o tipo de consumidor e suas restrições estruturais (o que ele pode tentar e ver); um _papel_ é uma lente de responsabilidade (revisor, executor, auditor); um _modo_ é um regime de processo (explorar, investigar, implementar, revisar, auditar, publicar, responder a incidente, comparar, recuperar). Todos _restringem_ ou _orientam_ a perspectiva; nenhum concede autoridade.
] <def-perfil-papel-modo>

#fato(titulo: [Camadas de restrição ficam abaixo da base])[
  Se cada camada de configuração (perfil, papel, modo, sessão) é aplicada como um encontro (ínfimo) com o conjunto de operações permitido pela camada anterior, então o resultado de qualquer sequência de camadas está contido no conjunto permitido pela base.
] <prop-camadas-restricao>

#prova[
  O encontro de dois conjuntos está contido em cada um; por indução no número de camadas, o resultado está contido na base. (É a generalização da @prop-perfis-restringem a várias camadas.)
]

=== Escopos temporários

Às vezes um consumidor precisa inspecionar algo fora de sua composição — um domínio vizinho, um repositório de outra equipe — sem que isso altere relações persistentes. A tentação de "acrescentar à composição para poder olhar" é um erro de categoria.

#definicao(titulo: [Escopo temporário])[
  Um _escopo temporário_ (ou sobreposição) é uma concessão de leitura tipada, limitada no tempo e no escopo, emitida pelo dono da autoridade do alvo, que permite atravessar uma aresta e expandir material sem alterar pertinência nem posse. Ele altera apenas a coordenada do consumidor — inclusive seu teto de leitura, de forma temporária —, nunca o acervo.
] <def-escopo-temporario>

#fato(titulo: [Remover o escopo restaura a perspectiva])[
  Se a projeção depende apenas do acervo e da coordenada (P2), o escopo temporário altera apenas a coordenada, e o acervo e os demais componentes da coordenada — inclusive o instante — são os mesmos antes e depois do escopo, então remover o escopo restaura exatamente a perspectiva anterior a ele.
] <prop-remover-escopo>

#prova[
  A coordenada após a remoção é igual à anterior ao escopo, e o acervo é o mesmo por hipótese; pela determinação da projeção, a perspectiva é a mesma.
]

O fato restaura a _perspectiva_, não o _consumidor_: o que foi lido durante o escopo permanece na trajetória e em qualquer memória derivada, e leitura não se revoga. Por isso, escopos temporários sobre material sensível exigem consumidores sem memória persistente, ou o descarte controlado da trajetória do período.

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Situação], [Resultado na perspectiva]),
    [referência sem autoridade], [alvo conhecido; expansão bloqueada, com o motivo],
    [referência com autoridade limitada], [expansão limitada ao permitido],
    [referência com autoridade; objetivo exclui], [endereçável, não selecionado],
    [referência com autoridade; objetivo inclui], [aplicável e expansível],
    [escopo ou objetivo removido], [referência permanece; relações inalteradas; não selecionado],
  ),
  caption: [Matriz de escopo temporário. Em nenhum caso o escopo exige mutação de relação persistente.],
) <tab-matriz-escopo>

#exercicios[
  + Um agente precisa ler a documentação de um domínio vizinho para responder a uma pergunta. Descreva o escopo temporário adequado e o que deve aparecer na perspectiva antes, durante e depois dele.
  + Mostre que um perfil "liberador" — que concede uma operação ausente da base — viola o @prop-camadas-restricao, e descreva como detectá-lo automaticamente.
  + Prove a proposição de que remover um escopo temporário restaura a perspectiva anterior, supondo que o escopo atue apenas como restrição adicional sobre a coordenada. Que tipo de escopo violaria a propriedade?
]

#quadro[
  - Escopo é expresso por âncoras tipadas; foco é atenção efêmera; o texto do objetivo não é classificador.
  - O objetivo tem três estados (ausente, resolvido, não resolvido) e não é adivinhado.
  - Relevância derivada por arestas de necessidade, com justificativa; a unidade de relevância é o recurso.
  - Requisitos se identificam pelo lugar semântico; resolução com candidatos é alcançabilidade e não inventa candidatos.
  - Pode, importa, pode ver e viu são quatro perguntas independentes.
  - Política de divulgação: divulgado, só referência, só existência, retido — determinística e explicável; a existência também é divulgação.
  - Perfis, papéis e modos só restringem; escopos temporários alteram a coordenada, não o acervo.
]

#problemas[
  #problema([Escopo a partir de linguagem natural])[
    Um titular descreve um objetivo em linguagem natural.
    + Proponha um procedimento que _proponha_ âncoras tipadas a partir do texto, com o titular confirmando-as.
    + Mostre como o procedimento respeita o @inv-texto-objetivo.
    + Discuta como medir a qualidade das âncoras propostas.
  ]
  #problema([Divulgação ótima sob orçamento])[
    Dado um orçamento de tokens, a política de divulgação precisa escolher entre #estado[divulgado] e #estado[só referência] para as asserções aplicáveis.
    + Formule a escolha como problema de seleção (@cap-selecao), em que #estado[só referência] tem custo baixo e valor reduzido.
    + Mostre que, se o valor de uma referência é uma fração fixa do valor do conteúdo, o problema tem a mesma estrutura de mochila.
    + Discuta como as explicações de divulgação ajudam o consumidor a decidir o que expandir.
  ]
  #problema([Integridade contextual para agentes])[
    Aplique a noção de integridade contextual a um agente que lê e-mails corporativos para redigir relatórios.
    + Identifique os contextos de origem e as normas de fluxo de cada tipo de informação.
    + Proponha uma política de divulgação que as respeite.
    + Discuta conflitos entre utilidade do relatório e integridade contextual.
  ]
]

#notas[
  A distinção entre relevância e permissão tem longa história em recuperação de informação e em segurança; a teoria da relevância de #ct(<sperber1986>) e a máxima de relação de #ct(<grice1975>) tratam da relevância na comunicação humana — o ouvinte presume que o que lhe é dito é relevante, presunção que um contexto mal projetado explora contra o consumidor. A integridade contextual é de #ct(<nissenbaum2004>); o modelo de reticulado de fluxo de informação, de #ct(<denning1976>). A separação entre o que um agente deseja e aquilo com que se comprometeu — próxima da distinção entre objetivo declarado e foco — remete à arquitetura de crenças, desejos e intenções @rao1995.

  A separação entre escopo e foco, a relevância restrita a arestas de necessidade, os requisitos identificados pelo lugar semântico, as quatro perguntas distintas e a matriz de escopo temporário são propostas deste livro, motivadas pela confusão recorrente entre "relacionado" e "relevante", e entre "relevante" e "autorizado".
]
