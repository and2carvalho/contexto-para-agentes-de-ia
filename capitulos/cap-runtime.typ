#import "/modelo/estilo.typ": *

= Execução, artefatos e convergência <cap-runtime>

#epigrafe[Arquivo substituído não é processo atualizado.]

Um sistema de contexto não vive apenas de acervos e perspectivas; vive de código em execução. Os serviços que projetam perspectivas, as ferramentas que agentes chamam, os servidores que respondem a protocolos — tudo isso é software, com versões, construções e processos. E o comportamento que um agente observa depende de _qual_ versão está executando, _onde_, e _desde quando_. Este capítulo trata o código em execução como parte do campo verificável de contexto.

A @sec-run-pernas apresenta as pernas de execução e o autorrelato. A @sec-run-cadeia descreve a cadeia de proveniência material, da fonte ao processo. A @sec-run-realizacao introduz o realização em dois eixos de funcionalidades. A @sec-run-compatibilidade trata de compatibilidade escopada por requisito. A @sec-run-versoes trata da ordem entre versões e da atualização segura. A @sec-run-convergencia descreve a convergência de execução e o pulso de convergência. A @sec-run-reconstituicao trata da reconstituição de um nó a partir de coordenadas duráveis.

== Pernas de execução e autorrelato <sec-run-pernas>

Uma mesma máquina pode executar o "mesmo" sistema de várias formas: uma ferramenta de linha de comando, um serviço residente, um servidor de ferramentas para agentes, um executor embutido numa aplicação. Cada uma é uma _perna de execução_.

#definicao(titulo: [Perna de execução e autorrelato])[
  Uma _perna de execução_ é um processo que desempenha um papel no sistema (linha de comando, serviço residente, servidor de ferramentas). Seu _autorrelato_ é a declaração, emitida pelo próprio processo e obtida por observação, de: seu papel; o resumo criptográfico dos bytes que está executando; a revisão de fonte embutida na construção; se a fonte tinha alterações não registradas; a receita de construção; as funcionalidades que oferece; e o identificador do processo. O resumo é calculado na carga do processo, ou embutido na construção — nunca relido do disco no momento do relato, o que relataria os bytes novos enquanto o processo executa os antigos. O autorrelato tem proveniência própria ("autorrelatado"), distinta de uma inferência a partir do caminho do executável.
] <def-perna>

#invariante(titulo: [Mesmo hospedeiro, execuções diferentes])[
  Estar na mesma máquina não implica executar o mesmo artefato, servir o mesmo domínio, projetar a mesma perspectiva ou ter a mesma autoridade. Cada igualdade é um fato a observar.
] <inv-mesmo-hospedeiro>

#estudo-de-caso(titulo: [Duas pernas, dois artefatos])[
  Superfícies diferentes de um sistema davam respostas divergentes para a mesma coordenada. A investigação pelo caminho dos executáveis não encontrou diferença: ambos os caminhos apontavam para o mesmo binário instalado. O autorrelato de cada perna revelou o que o caminho escondia: um processo havia sido iniciado depois da última instalação; o outro, um serviço de longa duração, executava ainda os bytes anteriores, carregados na memória antes da substituição do arquivo. A lição foi dupla: a identidade do que executa se observa por autorrelato, não pelo caminho; e instalar não é ativar — processos de longa duração precisam ser religados.
] <caso-duas-pernas>

#invariante(titulo: [Arquivo substituído não é processo atualizado])[
  Construir, instalar e executar são estados distintos: um binário construído não está instalado; um binário instalado não está em execução; substituir o arquivo de um executável não atualiza os processos que já o carregaram.
] <inv-arquivo-processo>

#exercicios[
  + Liste as pernas de execução de um sistema que você usa e o que cada uma deveria declarar em seu autorrelato.
  + Proponha um teste que detecte, automaticamente, uma divisão de execução como a do @caso-duas-pernas.
  + Uma ferramenta de linha de comando e um serviço residente da mesma máquina relatam versões diferentes do sistema. Liste as hipóteses que explicam a divergência e a observação que distingue cada uma.
]

== A cadeia de proveniência material <sec-run-cadeia>

#definicao(titulo: [Cadeia de proveniência material])[
  A _cadeia de proveniência material_ de uma perna de execução é a sequência
  $ "fonte" ->^"revisão" "construção" ->^"receita" "artefato" ->^"resumo" "perna" ->^"autorrelato" "topologia" -> "quadro resolvido" $
  em que cada aresta é observada — nenhuma é inferida por proximidade de arquivos. O quadro resolvido de uma perspectiva deve declarar a revisão de implementação, o artefato, o locus, a materialização e sua relação com a linha de base aceita.
] <def-cadeia-material>

#lema(titulo: [Proveniência por cadeia])[
  Suponha pernas não adversariais (processos possivelmente defeituosos, mas não comprometidos). A afirmação "a perna $l$ executa a revisão $r$" é derivável, com estatuto #est[provado], se e somente se existe um caminho de arestas observadas $r ->$ construção $->$ artefato $a ->$ $l$ no grafo de proveniência, com o resumo de $a$ coincidindo com o resumo autorrelatado por $l$.
] <lem-proveniencia-cadeia>

#prova[
  (⇐) Cada aresta observada sustenta seu passo, e a coincidência dos resumos liga o artefato construído ao que executa. (⇒) Se falta alguma aresta observada, há um mundo compatível com as observações em que a perna executa outro artefato (por exemplo, construído de outra revisão e colocado no mesmo caminho); logo a afirmação não é provada. Proximidade no sistema de arquivos — "o executável está ao lado da cópia da revisão $r$" — não é aresta observada.
]

O autorrelato é, na taxonomia do @cap-modelo, uma asserção _relatada_: a fonte não fornece âncora independente. A hipótese de pernas não adversariais é o que permite tratá-lo como evidência. Contra um processo comprometido, o autorrelato é substituído por _atestação_ — medição do artefato na carga, verificada por um componente confiável —, como nos modelos de ameaça de sistemas de atualização @samuel2010 e de cadeia de suprimentos de software @torresarias2019.

#invariante(titulo: [Resumo do artefato não é revisão da fonte])[
  O resumo dos bytes executados identifica o artefato; a revisão da fonte identifica o código de origem. Um não se infere do outro sem a aresta de construção registrada.
] <inv-artefato-fonte>

#exercicios[
  + Construa a cadeia de proveniência material de uma ferramenta instalada na sua máquina. Quais arestas você consegue observar e quais teria de inferir?
  + Por que o quadro resolvido de uma perspectiva deveria declarar a revisão de implementação do próprio sistema que a calculou?
  + Escreva a cadeia de proveniência material de um executável instalado, da revisão da fonte ao processo em execução, e indique em que elo uma substituição silenciosa do arquivo romperia a cadeia.
]

== Realização de funcionalidades <sec-run-realizacao>

Quando se diz que um sistema "tem" uma funcionalidade, de que se está falando? Da existência do código? Da versão instalada? Do processo em execução? Da aceitação pelo titular? Cada um é um degrau diferente.

#definicao(titulo: [Realização de uma funcionalidade])[
  A _realização_ de uma funcionalidade é um elemento do produto de duas cadeias, acompanhado de um atributo:
  - o eixo _material_: $#estado[definida na fonte] < #estado[construída] < #estado[instalada] < #estado[ativa] < #estado[observada viva]$ — o código existe numa revisão; um artefato foi produzido dela; o artefato está no lugar de execução; um processo o executa; a funcionalidade foi exercida com sucesso por um consumidor real através do caminho de produção;
  - o eixo de _durabilidade_: $#estado[efêmera] < #estado[durável]$ — a revisão está ou não publicada e retida;
  - o atributo de _aceitação_, ortogonal a ambos, registrado por decisão do titular (@cap-trabalho).
  O produto das duas cadeias é um reticulado.
] <def-realizacao>

Os eixos são independentes: uma construção local de desenvolvimento pode estar #estado[ativa] sem ser #estado[durável] — é a situação do @anti-rebaixamento. E a aceitação não é um degrau: uma funcionalidade pode ser aceita antes de chegar ao ambiente de produção, ou observada viva sem jamais ter sido aceita.

#fato(titulo: [Degraus exigem evidência própria])[
  Ao longo de cada eixo, a afirmação de que uma funcionalidade está no degrau $k$ exige evidência daquele degrau; evidência do degrau $j < k$ não basta, e evidência do degrau $k$ não dispensa a dos anteriores para fins de proveniência.
] <prop-degraus>

#prova[
  Para cada par de degraus consecutivos há mundos em que o inferior vale e o superior não (código existe e não foi construído; artefato instalado e não executado; processo ativo e caminho de produção não alcançável); logo a evidência do inferior não sustenta o superior. A segunda parte decorre do @lem-proveniencia-cadeia: a cadeia precisa ser completa.
]

#estudo-de-caso(titulo: [Correto, testado, instalado — e inalcançável])[
  Uma funcionalidade foi implementada, testada no próprio processo de testes e instalada. O titular a experimentou — e nada aconteceu. O caminho real de invocação em produção passava por outro adaptador, que não chamava a nova funcionalidade. Ela estava, no eixo material, em #estado[ativa], mas não em #estado[observada viva]. A lição levou a uma prática: antes de codificar, verificar o caminho vivo — qual afirmação será provada, quem é dono da semântica, como a funcionalidade é invocada no sistema real e como a consequência será observada (@pri-disciplina-verificacao).
] <caso-caminho-vivo>

#exercicios[
  + Classifique no reticulado: (a) um recurso implementado num ramo não publicado; (b) um recurso instalado mas cujo serviço não foi reiniciado; (c) um recurso usado com sucesso por um agente em produção, mas não aceito pelo titular.
  + Por que testes "no próprio processo" não provam o degrau #estado[observada viva]?
  + Para uma funcionalidade nova de um sistema de contexto, descreva, para cada degrau dos dois eixos da realização (@def-realizacao), a evidência própria que o sustenta e quem a produz.
]

== Compatibilidade escopada por requisito <sec-run-compatibilidade>

Quando há várias pernas ou vários nós, é tentador exigir que todos executem exatamente o mesmo artefato. Essa exigência é ao mesmo tempo forte demais e fraca demais.

#definicao(titulo: [Relação de artefato e compatibilidade])[
  Para duas pernas, distinguem-se duas perguntas: a _relação de artefato_ — #estado[mesmo], #estado[diferente] ou #est[desconhecido] — e a _compatibilidade para um requisito_ — #estado[satisfeito], #estado[não satisfeito] ou #est[desconhecido] —, avaliada para uma operação específica.
] <def-compatibilidade>

#invariante(titulo: [Idêntico não é suficiente; diferente não é incompatível])[
  Artefatos diferentes podem ser compatíveis para um requisito; o mesmo artefato pode ser insuficiente para uma operação (por exemplo, por configuração diferente). Bytes idênticos não implicam compatibilidade; bytes diferentes não implicam incompatibilidade.
] <inv-identico-compativel>

Exigir "todos o mesmo binário" bloqueia sistemas legítimos (plataformas diferentes produzem bytes diferentes da mesma revisão) e, ao mesmo tempo, deixa passar incompatibilidades de configuração. A pergunta correta é sempre escopada: compatível _para quê_?

#exercicios[
  + Dê um exemplo de dois artefatos diferentes compatíveis para um requisito e incompatíveis para outro.
  + Por que a mesma revisão de fonte, construída para duas plataformas, produz artefatos diferentes? Como relacioná-los na cadeia de proveniência?
  + Dê um exemplo em que dois artefatos idênticos byte a byte não satisfazem um requisito (por causa do ambiente) e outro em que dois artefatos diferentes são compatíveis para o mesmo requisito.
]

== Ordem entre versões e atualização segura <sec-run-versoes>

Saber se uma versão é "mais nova" que outra parece simples — basta comparar números. Mas números de versão são rótulos, atribuídos por pessoas ou processos, e podem não refletir a ancestralidade real do código.

#definicao(titulo: [Relação de ancestralidade entre versões])[
  Para duas versões com revisões de fonte $r_1$ e $r_2$, a relação é: #estado[mesma fonte] se $r_1 = r_2$; #estado[à frente] se $r_2$ é ancestral próprio de $r_1$; #estado[atrás] se $r_1$ é ancestral próprio de $r_2$; #estado[divergente] se nenhuma é ancestral da outra; e #est[desconhecido] se alguma revisão é desconhecida.
] <def-ancestralidade>

#proposicao(titulo: [A ancestralidade é uma ordem parcial])[
  A relação "é ancestral de" sobre as revisões de um repositório é uma ordem parcial; em geral, não é total.
] <prop-ancestralidade>

#prova[
  O grafo de revisões é um DAG (cada revisão aponta para seus pais, que lhe são anteriores); a alcançabilidade num DAG é uma ordem parcial (exercício do Apêndice A). Duas revisões em ramos não integrados são incomparáveis.
]

#antipadrao(titulo: [Rebaixamento pelo atualizador])[
  Um mecanismo de atualização compara o número de versão instalado com o publicado e "atualiza" — instalando, na verdade, uma versão mais antiga, porque a instalada era uma construção local de desenvolvimento com número menor, mas código à frente. A ordem de versões foi inferida do rótulo, não da ancestralidade.
] <anti-rebaixamento>

#algoritmo("Atualiza-com-Segurança", params: $i, m$, legenda: [Atualização segura de uma instalação $i$ a partir de um manifesto publicado $m$.])[
  + #kw[se] $i$ é uma construção local sem rótulo publicado #kw[então] #kw[devolva] #estado[construção local] (nenhuma atualização)
  + #kw[se] a assinatura de $m$ não é válida para os papéis autorizados, ou $m$ expirou #kw[então] #kw[devolva] #estado[não confiável] #h(1fr) ▷ retrocesso e congelamento
  + #kw[se] $m$ não declara a revisão de fonte #kw[então] #kw[devolva] #est[desconhecido]
  + $c <- $ #proc("Ancestralidade")$("rev"(i), "rev"(m))$
  + #kw[se] $c != $ #estado[atrás] #kw[então] #kw[devolva] $c$ #h(1fr) ▷ nunca oferecer "atualização" sem relação defensável
  + instale atomicamente o artefato de $m$, preservando a coordenada de reversão
  + religue os processos de longa duração
  + verifique que o resumo instalado coincide com o do manifesto e que os autorrelatos o confirmam
  + #kw[se] a verificação falha #kw[então] reverta, religue e #kw[devolva] #estado[falhou] com a evidência
] <alg-atualiza>

#exercicios[
  + Mostre um exemplo em que comparar números de versão inverte a ordem de ancestralidade.
  + Por que a linha 7 do @alg-atualiza é necessária? Relacione com o @inv-arquivo-processo.
  + Mostre que o @alg-atualiza nunca rebaixa uma instalação (pela linha 5) e que é idempotente: repeti-lo com o mesmo manifesto, depois de um sucesso, não instala nada.
  + Mostre que o @alg-atualiza nunca rebaixa uma instalação quando a versão instalada é descendente da proposta, e discuta o que ele deve fazer quando as versões são incomparáveis (ramos divergentes).
]

== Convergência de execução <sec-run-convergencia>

Em ambientes onde muitos agentes constroem e instalam versões, as pernas de execução se dispersam. A convergência as traz de volta a uma coordenada aceita.

#algoritmo("Converge-Execução", params: $L$, legenda: [Convergência das pernas de execução $L$ para uma coordenada aceita.])[
  + obtenha o autorrelato de cada perna em $L$ (papel, resumo, revisão, alterações, receita, funcionalidades)
  + detecte divisões (pernas do mesmo papel com resumos diferentes) e _explique_ cada uma
  + verifique as pré-condições de instalação: um único resumo exato; bytes recuperáveis; vínculo fonte–árvore; proveniência de construção; coordenada de reversão; linha de base de referência
  + instale atomicamente
  + religue os processos de longa duração
  + prove a identidade viva por autorrelato
  + elimine localizadores alternativos ativos (caminhos que ainda apontam para versões antigas)
  + registre a aceitação da linha de base
] <alg-converge-execucao>

#definicao(titulo: [Pulso de convergência])[
  Um _pulso de convergência_ é um padrão de desenvolvimento em que linhas de trabalho divergem livremente entre pontos limitados de convergência. Em cada ponto, três portões se sucedem: (i) _fonte_ — todo trabalho aplicável retorna à linha canônica e as linhas principais candidatas estão limpas; (ii) _coorte_ — em cada repositório envolvido, a linha local, a remota e um marcador imutável coincidem, e o conjunto é registrado como uma coorte; (iii) _execução_ — o artefato é construído do marcador, retido, instalado, religado, provado vivo e aceito. A direção é sempre a mesma: a aceitação governa, e marcadores e execução são igualados à coordenada aceita.
] <def-pulso>

#exercicios[
  + Por que o @alg-converge-execucao exige _explicar_ cada divisão antes de convergir, em vez de simplesmente instalar a versão desejada?
  + Descreva um pulso de convergência para três repositórios interdependentes.
  + Proponha a frequência e o conteúdo de um pulso de convergência para uma frota de vinte máquinas de desenvolvimento, e o que deve ser registrado quando uma máquina não responde.
]

== Reconstituição <sec-run-reconstituicao>

Um teste poderoso da qualidade do gerenciamento de contexto é reconstruir um nó operacional do zero, usando apenas as coordenadas duráveis aceitas.

#definicao(titulo: [Reconstituição de nó])[
  A _reconstituição_ parte de um nó limpo e descartável e retém apenas coordenadas explicitamente duráveis — fonte aceita, conjunto de compatibilidade, acervo, serviços, declaração de ambiente. A partir delas, reconstrói o sistema, conecta os serviços, autentica, seleciona o domínio, recupera o contexto, inspeciona, recupera a linhagem de execução e de evidência, e executa uma funcionalidade governada descartável. A pergunta de saída é: _o que precisamos que não estava duravelmente declarado?_
] <def-reconstituicao>

#principio(titulo: [O estado de execução pode desaparecer; o semântico não])[
  Um sistema de contexto bem gerenciado tolera a perda total de um nó: tudo o que é semanticamente relevante pode ser reconstruído a partir de coordenadas duráveis. O que a reconstituição revela como faltante era "estado acidental da máquina" — e é dívida de contexto.
] <pri-estado-execucao>

#exercicios[
  + Planeje uma reconstituição de um ambiente de desenvolvimento seu. Que itens você suspeita que não estão duravelmente declarados?
  + Por que a reconstituição deve terminar executando uma funcionalidade governada, e não apenas verificando que os serviços iniciaram?
  + Planeje um experimento de reconstituição de nó para uma máquina de desenvolvimento e liste três coisas que você suspeita que não estão duravelmente declaradas.
]

#quadro[
  - Pernas de execução declaram identidade por autorrelato; o caminho do executável não basta; instalar não é ativar.
  - A cadeia material fonte → construção → artefato → perna só prova com arestas observadas (@lem-proveniencia-cadeia).
  - Realização de funcionalidade: eixo material (definida, construída, instalada, ativa, observada viva) e eixo de durabilidade, com a aceitação ortogonal — cada degrau com evidência própria.
  - Compatibilidade é escopada por requisito: idêntico não basta; diferente não é incompatível.
  - Ordem de versões é ancestralidade (ordem parcial), não rótulo; atualize só com relação defensável.
  - Convergência explica divisões, instala atomicamente, religa e prova viva; pulsos de convergência têm três portões.
  - Reconstituição revela estado acidental; o semântico deve sobreviver à perda do nó.
]

#problemas[
  #problema([Manifesto mínimo comparável])[
    Projete um manifesto de publicação que torne qualquer atualização comparável com a instalação local.
    + Especifique os campos (versão, revisão, árvore, resumos por plataforma, proveniência).
    + Mostre que, com o manifesto, o @alg-atualiza nunca oferece rebaixamento.
    + Discuta como lidar com construções locais de desenvolvimento.
  ]
  #problema([Observador desatualizado])[
    O instrumento que observa as pernas — ele próprio uma perna — pode estar desatualizado e não reconhecer funcionalidades novas.
    + Mostre um cenário em que um alvo saudável é relatado como #est[desconhecido] por causa do observador.
    + Proponha uma regra de ordem: convergir o observador antes de medir.
    + Formalize a regra como precondição de portão (@cap-portoes).
  ]
  #problema([Divisões de execução em escala])[
    Num ambiente com centenas de nós e várias pernas por nó:
    + Proponha uma estrutura para agregar autorrelatos e detectar divisões eficientemente.
    + Discuta a frequência de coleta e o custo.
    + Relacione com a visão de ambiente como vetor (@def-visao-ambiente).
  ]
]

#notas[
  A verificação de que um artefato em execução corresponde à fonte aceita é o objeto de mecanismos de cadeia de suprimentos de software @torresarias2019 e de sistemas de atualização resistentes a comprometimento @samuel2010; construções reprodutíveis e herméticas @dolstra2004 tornam a aresta fonte–artefato verificável por reconstrução. A engenharia de confiabilidade @beyer2016 e a entrega contínua @humble2010 tratam extensamente de implantação, reversão e verificação em produção; a distinção entre instalar e ativar é familiar a quem já operou serviços de longa duração. A ancestralidade de revisões como ordem parcial é a do grafo de histórico de controle de versão @chacon2014.

  As pernas de execução com autorrelato, a realização de funcionalidades em degraus, a compatibilidade escopada por requisito, a atualização segura baseada em ancestralidade, o pulso de convergência e a reconstituição de nó são propostas deste livro para sistemas desenvolvidos e executados em várias máquinas ao mesmo tempo, em que "qual versão está executando?" se torna uma das perguntas mais difíceis.
]
