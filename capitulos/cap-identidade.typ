#import "/modelo/estilo.typ": *

= Identidade, nomes e materialização <cap-identidade>

#epigrafe[O caminho é apenas onde procurar agora; ao chegar, ainda precisamos provar que encontramos aquilo que procurávamos.]

Antes de dizer qualquer coisa sobre um recurso — que está atualizado, que pertence a um domínio, que pode ser alterado —, é preciso saber _qual_ recurso. Parece trivial, e é a fonte de uma quantidade desproporcional de erros. Um mesmo repositório tem um identificador no serviço de hospedagem, cópias em várias máquinas, um nome informal usado pela equipe e, às vezes, um apelido herdado de uma reorganização antiga. Um espaço de trabalho pode ser conhecido por um identificador opaco, por um caminho de diretório e por um papel ("o espaço de contexto da equipe"). Um processo pode ser identificado pelo nome do executável, por uma versão declarada ou pelo resumo criptográfico do binário. Cada uma dessas designações é útil; nenhuma delas, sozinha, _é_ o recurso.

Este capítulo organiza o problema. A @sec-id-nomes distingue nomes, identificadores, localizadores e identidade. A @sec-id-dominios trata de domínios de identidade e de equivalências provadas, e enuncia o princípio de resolver identidade antes de renderizar. A @sec-id-materializacao distingue um recurso de suas materializações. A @sec-id-temporal mostra que localizadores são temporalmente inseguros e dá um procedimento de resolução com verificação de identidade. A @sec-id-conteudo trata de identidade por conteúdo. A @sec-id-executaveis aplica as ideias a executáveis e processos.

== Nomes, identificadores, localizadores e identidade <sec-id-nomes>

#ct(<saltzer1978>) mostrou que nomes só têm significado em relação a um _contexto de nomeação_ — um mapeamento de nomes para objetos —, e que boa parte das dificuldades de sistemas está em saber qual contexto se aplica a cada nome. Adotamos uma terminologia compatível com essa visão e com a distinção usual entre identificadores e localizadores na arquitetura da web @rfc3986.

#definicao(titulo: [Designações de um recurso])[
  - Um _nome_ é uma designação legível por humanos, sem garantia de unicidade nem de estabilidade ("o serviço de autenticação").
  - Um _identificador_ é uma designação que, num domínio de identidade, é única e estável: designa sempre o mesmo recurso enquanto o domínio existir.
  - Um _localizador_ é uma designação que diz _onde_ encontrar uma materialização do recurso _agora_ (um caminho de diretório, um endereço de rede). Localizadores não são únicos nem estáveis: o mesmo localizador pode, em momentos diferentes, levar a recursos diferentes.
  - A _identidade_ de um recurso é a classe dos _identificadores_ que o designam, com as provas que sustentam cada equivalência. Nomes e localizadores não pertencem à identidade: ligam-se a ela por asserções datadas.
] <def-designacoes>

#invariante(titulo: [Localizador não é identidade])[
  Um caminho de diretório, um endereço de rede ou qualquer outro localizador não identifica um recurso. Em particular: caminho não é espaço de trabalho; caminho não é identidade de repositório; estar contido num diretório não é pertencer a um domínio.
] <inv-localizador-identidade>

O invariante é violado de modo quase reflexo. Um agente que encontra um diretório chamado `projetos/` contendo dezessete repositórios tende a concluir que existe uma entidade "projetos" da qual os repositórios são membros. Pode existir — mas a contenção em diretório não o prova. Pode ser apenas o lugar onde alguém decidiu guardar cópias.

#exemplo(titulo: [Três designações, três perguntas])[
  Considere as designações: (a) o nome "espaço de contexto"; (b) o identificador opaco `id:7f3a…`; (c) o caminho `/dados/meta`. A pergunta "qual é o espaço de trabalho corrente?" deve ser respondida por (b), com prova de que o processo corrente o resolveu. A pergunta "onde estão os arquivos desse espaço de trabalho nesta máquina?" é respondida por (c), com prova de que (c) contém uma materialização de (b). O nome (a) é um _papel_ atribuído pelo titular — útil para humanos, inútil como prova. Renomear, mover ou reatribuir qualquer um dos três não altera os outros dois.
] <ex-tres-designacoes>

=== O recurso lógico e suas manifestações

A pergunta mais básica de qualquer sistema de contexto é: _sobre qual coisa durável estamos falando?_ Muitos sistemas não têm resposta explícita para ela. Têm arquivos, revisões, artefatos, registros de evidência, apelidos — cada um com seu identificador —, mas nenhum objeto que diga "estes são aspectos do _mesmo_ recurso".

#definicao(titulo: [Recurso lógico])[
  Um _recurso lógico_ é uma coisa durável, pertencente ao espaço semântico de um domínio, que pode ter manifestações, artefatos, evidências e relações sem que nenhuma dessas manifestações seja sua identidade. Seu identificador é distinto de todas as designações das manifestações.
] <def-recurso-logico>

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Designação], [O que identifica]),
    [identificador do recurso lógico], [a coisa durável, enquanto o domínio existir],
    [apelido], [um rótulo de conveniência, atribuído e reatribuível],
    [localizador], [onde há uma materialização agora],
    [revisão do registro do recurso], [uma versão dos metadados do recurso no acervo],
    [revisão da fonte], [uma versão do conteúdo-fonte no controle de versão],
    [resumo de conteúdo], [uma sequência exata de bytes],
    [artefato renderizado], [um produto derivado (um documento, um executável)],
    [identificador de evidência], [um registro que prova algo _sobre_ o recurso],
  ),
  caption: [Manifestações de um recurso lógico. Nenhuma delas é a identidade do recurso; cada uma tem seu próprio relógio de versão.],
) <tab-manifestacoes>

Com o recurso lógico explícito, as demais peças se organizam: uma memória é memória _sobre_ o recurso; uma evidência prova algo _sobre_ ele; o controle de versão o _materializa_; um armazém por conteúdo _retém_ uma manifestação dele; um objetivo diz que ele _importa_; uma interface o _apresenta_. Sem ele, cada mecanismo orbita arquivos e diretórios, e a junção entre os mecanismos é feita, implicitamente, por caminhos — exatamente o que o @inv-localizador-identidade proíbe.

Uma consequência prática: num locus onde o recurso não está materializado, o recurso continua existindo. O outro locus sabe que ele existe, a que domínio pertence e que, ali, sua materialização não está disponível; a perspectiva o apresenta como "identidade conhecida, materialização remota", e não como ausente.

#exercicios[
  + Para um repositório de código, liste todas as designações que você consegue identificar (em serviços, máquinas, ferramentas, conversas). Classifique-as como nome, identificador ou localizador.
  + Por que um identificador opaco (por exemplo, um UUID) é, em geral, melhor identificador do que um nome descritivo, mesmo que único? Em que situação um nome descritivo único pode servir como identificador?
  + Dê um exemplo em que a contenção em diretório coincide com pertinência semântica, e outro em que não coincide.
]

== Domínios de identidade e equivalência provada <sec-id-dominios>

Recursos raramente têm um único identificador global. Um repositório tem um identificador no serviço de hospedagem, outro no sistema de integração contínua, outro no registro de implantação. Um espaço de trabalho pode ter um identificador no sistema de arquivos local, outro num serviço remoto de coordenação e outro numa composição que o referencia. Cada identificador pertence a um _domínio de identidade_ (@def-recurso), e afirmar que dois identificadores de domínios diferentes designam o mesmo recurso é uma _asserção de equivalência_ que precisa de prova.

#definicao(titulo: [Equivalência, apelido e coincidência])[
  Sejam $N_1:x$ e $N_2:y$ identificadores.
  - Uma _equivalência provada_ é uma asserção $N_1:x equiv N_2:y$ com proveniência que demonstra que ambos designam o mesmo recurso (por exemplo, um registro mantido pela autoridade que emitiu ambos, ou um marcador de identidade lido nas duas extremidades).
  - Um _apelido_ é uma asserção de que um nome ou identificador é uma designação alternativa, mantida por conveniência, de outro; apelidos podem ser históricos e não implicam equivalência atual.
  - Uma _coincidência_ é qualquer semelhança entre designações — mesmo nome, mesmo sufixo, mesmo caminho — sem prova de equivalência.
] <def-equivalencia>

#invariante(titulo: [Mesmo nome não é mesma identidade])[
  Coincidência de nome, de caminho ou de qualquer outra designação não implica equivalência. Registrar um identificador não resolve um conflito de identidade, e um apelido não é uma equivalência.
] <inv-mesmo-nome>

=== Resolver antes de renderizar

Quando um sistema encontra várias designações que _parecem_ referir-se ao mesmo recurso, ele enfrenta uma escolha que tem consequências para todas as perspectivas futuras.

#estudo-de-caso(titulo: [Três identidades para "o mesmo" espaço de trabalho])[
  Uma auditoria encontrou, para o que a equipe chamava informalmente de "o espaço do laboratório", três identificadores: um no sistema de arquivos local, um no serviço de execução que o processo efetivamente usava, e um terceiro declarado por uma composição de serviços como "espaço de controle". Um renderizador ingênuo teria fundido os três num único nó, pois todos apareciam associados ao mesmo nome. O revisor recusou a fusão: os três poderiam ser (a) três identidades da mesma entidade em domínios diferentes; (b) um espaço local, seu correspondente no serviço e um espaço de controle distinto; (c) um apelido histórico; (d) configuração obsoleta; (e) composição incorreta; ou (f) alguma combinação. Apenas evidência poderia decidir — e, até lá, a perspectiva deveria mostrar três identificadores com as relações _provadas_ entre eles e as relações _não provadas_ explicitamente marcadas. A resolução posterior mostrou que a resposta era uma combinação de (b) e (d), e que fundir os nós teria escondido exatamente a configuração obsoleta que causava o problema investigado.
] <caso-tres-identidades>

#principio(titulo: [Resolva a identidade antes de renderizar])[
  Nenhuma renderização funde, agrupa ou conecta designações cuja equivalência não esteja provada. A verdade sobre identidade tem precedência sobre a conveniência da apresentação: na dúvida, mostre os nós separados e as relações não provadas como tais.
] <pri-resolver-antes>

O princípio admite uma formulação precisa em termos do fecho de equivalência (Apêndice A).

#teorema(titulo: [Fusões seguras])[
  Seja $E$ um conjunto de equivalências provadas entre _identificadores_ (designações únicas e estáveis), todas válidas no mesmo intervalo de tempo, e $overline(E)$ seu fecho de equivalência. Se uma renderização funde duas designações somente quando estão na mesma classe de $overline(E)$, então ela nunca funde designações de recursos distintos, desde que as provas de $E$ sejam corretas. Além disso, toda fusão justificada por $E$ é realizada se a renderização funde exatamente as classes de $overline(E)$.
] <teo-fusoes-seguras>

#prova[
  Se as provas são corretas, cada par em $E$ designa o mesmo recurso. Como identificadores designam um único recurso, e as equivalências valem no mesmo intervalo, a relação "designa o mesmo recurso" é, sobre eles, de equivalência e contém $E$, logo contém $overline(E)$ (a menor equivalência que contém $E$). Portanto, designações na mesma classe de $overline(E)$ designam o mesmo recurso. A segunda afirmação é imediata.
]

O teorema torna explícito o caráter _conservador_ da política: designações equivalentes cuja equivalência ainda não foi provada aparecem separadas. Isso é um custo — a perspectiva fica mais poluída —, mas é um custo seguro e visível, enquanto uma fusão errada é um erro invisível que contamina tudo o que se deriva dela. A estrutura de conjuntos disjuntos mantém $overline(E)$ incrementalmente; revogar equivalências exige estruturas de conectividade dinâmica, com custo polilogarítmico amortizado por operação @holm2001. As hipóteses do teorema não são decorativas: nomes não são únicos, e um localizador reaproveitado designa recursos diferentes em instantes diferentes — "$x$ equivale a $ell$ em $t_1$" e "$ell$ equivale a $y$ em $t_2$" não permitem concluir que $x$ equivale a $y$.

#exercicios[
  + No @caso-tres-identidades, escreva as asserções de equivalência que seriam necessárias para justificar cada uma das hipóteses (a)–(c).
  + Mostre que fundir designações com base em "mesmo nome" pode violar a transitividade esperada: dê três designações em que a e b têm o mesmo nome, b e c também, mas a e c designam recursos distintos.
  + Proponha uma renderização para uma perspectiva com cinco designações, duas equivalências provadas e uma equivalência suspeita, que torne visível a diferença entre as três situações.
]

== Recurso e materialização <sec-id-materializacao>

Muitos recursos existem _independentemente_ de qualquer cópia local: um repositório existe no serviço de hospedagem; uma imagem de contêiner existe no registro; um documento existe no sistema de gestão documental. Uma _materialização_ é uma cópia concreta, num local, de um recurso (ou de uma revisão dele).

#definicao(titulo: [Materialização])[
  Uma _materialização_ de um recurso $r$ é um par $(ell, v)$ em que $ell$ é um localizador e $v$ uma revisão de $r$, acompanhado da asserção — com prova — de que o conteúdo em $ell$ corresponde a $v$ (possivelmente com alterações locais declaradas). Um recurso pode ter zero, uma ou muitas materializações.
] <def-materializacao>

A distinção gera um conjunto de estados que precisam ser mantidos separados:

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Estado], [Significado]),
    [#estado[conhecido]], [O acervo tem um identificador provado para o recurso.],
    [#estado[resolvido]], [O identificador pode ser resolvido agora para uma revisão exata.],
    [#estado[materializado]], [Existe ao menos uma materialização provada acessível ao consumidor.],
    [#estado[não materializado]], [O recurso é conhecido e resolvido, mas não há materialização acessível — um estado legítimo, não uma falha.],
    [#est[desconhecido]], [Não há identificador provado; o recurso pode ou não existir.],
  ),
  caption: [Estados de um recurso quanto a conhecimento e materialização. Confundir #estado[não materializado] com #est[desconhecido] faz o sistema "esquecer" recursos que simplesmente não estão copiados localmente.],
) <tab-estados-materializacao>

#invariante(titulo: [Existir não é estar materializado])[
  Um recurso pode ser conhecido, resolvido e relevante sem ter materialização local. A ausência de cópia local é um estado (#estado[não materializado]), nunca evidência de inexistência.
] <inv-existir-materializado>

#invariante(titulo: [Materialização não é domínio])[
  Uma materialização não é um espaço de trabalho, nem um membro de composição, nem uma autoridade. Converter cada repositório materializado num espaço de trabalho, ou criar uma composição apenas para agrupar materializações que estão num mesmo diretório, reintroduz o acoplamento entre localização e semântica que o @inv-localizador-identidade proíbe.
] <inv-materializacao-dominio>

#exemplo(titulo: [Catálogo de recursos com materialização ausente])[
  Um domínio de contexto mantém um catálogo de dezoito repositórios de que depende. Dezessete estão materializados numa máquina de desenvolvimento; o décimo oitavo está temporariamente sem cópia local, por causa de uma migração. O catálogo correto lista os dezoito com seus identificadores e revisões resolvidas, e marca o décimo oitavo como #estado[não materializado], com uma alça de expansão "materializar na revisão $v$". Um catálogo construído por varredura do diretório listaria dezessete — e qualquer perspectiva derivada dele ignoraria a existência do décimo oitavo.
] <ex-catalogo>

#exercicios[
  + Explique por que um catálogo de recursos construído por varredura de diretórios viola o @inv-existir-materializado. Proponha uma forma de construir o catálogo que não dependa de materializações.
  + Dê um exemplo de recurso que nunca deveria ser materializado localmente por um agente, e explique como o agente pode trabalhar com ele.
  + Um recurso tem duas materializações em revisões diferentes na mesma máquina. Que asserções devem existir para que um agente saiba qual usar?
]

== Localizadores são temporalmente inseguros <sec-id-temporal>

O @inv-localizador-identidade tem uma consequência temporal que merece destaque. Mesmo quando um localizador _já designou_ corretamente um recurso, isso não garante que continue designando.

#estudo-de-caso(titulo: [O localizador reaproveitado])[
  Um registro associava o espaço de trabalho $A$ ao caminho `/dados/X`. Numa migração de armazenamento, $A$ foi movido para outro disco, e o caminho `/dados/X` foi reaproveitado para guardar material sem relação com $A$. Semanas depois, um processo consultou o registro, verificou que `/dados/X` existia e concluiu que $A$ estava disponível. Na verdade, estava operando sobre material completamente diferente. A falha não estava no registro (que era histórico), nem na existência do caminho (que era real), mas na inferência "o localizador existe, logo o recurso está disponível".
] <caso-localizador-reaproveitado>

O caso é aparentado ao problema conhecido em programação concorrente como _ABA_ e ao da referência pendente — a reutilização de um endereço é a causa típica de ambos —, e de sua forma mais geral, a condição de corrida entre verificação e uso (TOCTOU): entre o momento em que se estabeleceu que o localizador levava ao recurso e o momento do uso, o localizador passou a levar a outra coisa.

#invariante(titulo: [Endereçável exige verificação de identidade])[
  Um recurso só é considerado _endereçável_ por um localizador quando (i) o localizador está presente e (ii) o que se encontra nele _prova ser_ o recurso esperado. Localizador presente, sozinho, não implica disponibilidade.
] <inv-enderecavel>

#algoritmo("Resolve-Localizador", params: $r, ell$, legenda: [Resolução de um localizador com verificação de identidade.])[
  + #kw[se] $ell$ não existe #kw[então] #kw[devolva] (#estado[indisponível], "localizador ausente")
  + $m <- $ marcador de identidade encontrado em $ell$ #h(1fr) ▷ p. ex., identificador gravado, resumo de conteúdo
  + #kw[se] $m$ não existe #kw[então] #kw[devolva] (#est[desconhecido], "sem marcador: não é possível provar a identidade")
  + #kw[se] $m$ não designa $r$ #kw[então] #kw[devolva] (#estado[indisponível], "localizador ocupado por outro recurso: $m$")
  + #kw[se] há uma segunda fonte para a identidade de $r$ (p. ex., o registro remoto) #kw[então]
    + $m' <- $ marcador segundo essa fonte
    + #kw[se] $m'$ não designa o mesmo recurso que $m$ #kw[então] #kw[devolva] (#est[conflitante], "fontes discordam: $m$ e $m'$")
    + #kw[devolva] (#estado[disponível], prova $= (ell, m, m')$, corroborada)
  + #kw[devolva] (#estado[disponível], prova $= (ell, m)$, não corroborada)
] <alg-resolve-localizador>

As linhas 5 a 9 introduzem uma prática valiosa: _corroboração independente_. Se o marcador de identidade lido localmente pode ser confirmado por uma fonte independente — por exemplo, o identificador de um repositório remoto, lido tanto da cópia local quanto do serviço de hospedagem —, a prova não depende apenas da observação local, que pode estar corrompida ou desatualizada.

#exercicios[
  + No @caso-localizador-reaproveitado, que marcador de identidade teria evitado o erro? Onde ele deveria estar gravado?
  + O @alg-resolve-localizador devolve #est[desconhecido] quando não há marcador. Por que não #estado[indisponível]? Que ação o consumidor deve tomar em cada caso?
  + Descreva uma situação em que mesmo a verificação de identidade é insuficiente porque o recurso pode mudar entre a verificação e o uso. Como mitigar?
]

== Identidade por conteúdo <sec-id-conteudo>

Uma forma particularmente robusta de identidade é a _identidade por conteúdo_: o identificador de um objeto é um resumo criptográfico de seu conteúdo. Se o conteúdo muda, o identificador muda; se dois objetos têm o mesmo identificador, têm, com probabilidade esmagadora, o mesmo conteúdo — _se a função de resumo for resistente a colisões_. Funções antes consideradas seguras deixaram de sê-lo (a primeira colisão prática do SHA-1 foi exibida em 2017 @stevens2017), e sistemas de versão migraram ou endureceram suas implementações; uma âncora por conteúdo é tão forte quanto sua função de resumo, e a escolha da função faz parte da proveniência. Árvores de Merkle @merkle1987 estendem a ideia a estruturas: o identificador de um diretório é o resumo dos identificadores de seus componentes, de modo que um único resumo identifica toda uma árvore de arquivos. Sistemas de controle de versão distribuídos baseiam-se exatamente nisso @chacon2014.

Identificadores por conteúdo têm duas propriedades que os tornam âncoras ideais (@pri-imutavel): são _autoverificáveis_ — qualquer um pode recalcular o resumo e conferir — e _imutáveis_ — uma afirmação sobre o objeto de resumo $h$ vale para sempre.

=== Conteúdo e história

Em sistemas de controle de versão, é útil distinguir dois identificadores por conteúdo de uma revisão: o da _árvore_ (o conteúdo dos arquivos) e o do _registro de revisão_ (que inclui a árvore, os pais e metadados). Duas revisões podem ter a mesma árvore e registros diferentes — o mesmo conteúdo alcançado por histórias diferentes.

#definicao(titulo: [Identidade de conteúdo e identidade de história])[
  A _identidade de conteúdo_ de uma revisão é o resumo de sua árvore. A _identidade de história_ é o resumo de seu registro, que inclui a cadeia de antecessores. Duas revisões com a mesma identidade de conteúdo e identidades de história diferentes têm o mesmo estado e histórias distintas.
] <def-conteudo-trajetoria>

A distinção resolve uma situação comum na reconciliação de trabalhos paralelos: várias linhas de desenvolvimento são integradas, os conflitos são resolvidos pela semântica corrente e o resultado é uma árvore que não corresponde a nenhuma das linhas originais. A história de cada linha é preservada (identidades de história), mas o que vale como estado corrente é a árvore resultante (identidade de conteúdo). Preservar história não significa preservar implementações antigas; significa poder percorrer o caminho até o estado atual.

#exercicios[
  + Explique por que uma afirmação sobre "o ramo principal" é uma afirmação sobre um localizador, enquanto uma afirmação sobre a revisão de resumo $h$ é uma afirmação sobre identidade.
  + Dê um exemplo em que duas revisões têm a mesma árvore e histórias diferentes, e explique por que um sistema de proveniência deveria registrar ambas.
  + Por que identificadores por conteúdo são inadequados para recursos cujo conteúdo muda continuamente, como um processo em execução? Que tipo de identidade usar nesse caso?
]

== Identidade de executáveis e processos <sec-id-executaveis>

Agentes executam ferramentas, e o comportamento de uma ferramenta depende de _qual_ executável roda. A pergunta "que versão estou usando?" admite respostas de qualidade muito diferente:

- o _caminho_ do executável (um localizador; vários caminhos podem levar ao mesmo binário, e o mesmo caminho pode levar a binários diferentes ao longo do tempo);
- a _versão declarada_ (uma afirmação do próprio binário sobre si, útil mas não verificável por si só);
- o _resumo do binário_ (identidade por conteúdo, verificável);
- a _proveniência de construção_ (de qual revisão de código e por qual processo o binário foi construído — verificável quando registrada por mecanismos de cadeia de suprimentos @torresarias2019).

#principio(titulo: [Identifique executáveis por conteúdo e proveniência])[
  Quando o comportamento de uma ferramenta importa para uma decisão, registre o resumo do executável e, se disponível, sua proveniência de construção — não apenas o caminho ou a versão declarada.
] <pri-executaveis>

O mesmo vale para _processos_ de longa duração, como servidores e serviços de contexto. Um processo nasce num diretório, com um ambiente e uma configuração, e é tentador tomar esse local de nascimento como o mundo inteiro. Um serviço que resolve recursos "a partir do diretório em que foi iniciado" comete o erro do @inv-localizador-identidade em escala: confunde o locus de seu próprio processo com o domínio soberano dos recursos que lhe pedem para resolver. O @cap-ambiente trata desse problema em detalhe.

=== Identidade de instalação

Entre a identidade do executável e a identidade do domínio há uma terceira: a da _instalação_ — o locus em que um sistema de contexto está instalado e de onde partem suas observações.

#invariante(titulo: [Instalação não é máquina, nem domínio, nem autoridade])[
  A identidade de uma instalação permite afirmar que observações feitas por processos e executáveis diferentes vieram do mesmo locus. Ela não é a identidade eterna da máquina física (uma reinstalação produz uma instalação nova, e a continuidade não deve ser fingida), não é a identidade de nenhum domínio materializado ali e não confere autoridade.
] <inv-instalacao>

Apelidos de máquinas ("o servidor de testes") são ergonomia, não identidade: um apelido é uma dica declarada que, resolvida com evidência (a impressão digital da instalação que responde), se vincula a um locus. Se o apelido passar a apontar para outra instalação, a divergência entre a impressão declarada e a observada é um conflito a expor, não uma continuidade a supor.

=== Três escalas de identidade

Por fim, é útil distinguir três escalas em que a identidade opera num sistema de contexto: a do _domínio_ (projeto ou espaço de trabalho: continuidade, governança, proveniência); a da _aplicação_ que usa o sistema de contexto (seus próprios recursos e operações); e a do _assunto_ de que a aplicação trata (conceitos, módulos, documentos do domínio de aplicação). Achatar as três numa só — tratar cada conceito do assunto como recurso do domínio, ou cada aplicação como domínio — produz grafos enormes e sem significado. O correto é que cada escala tenha sua identidade, e que as escalas se liguem por referências tipadas com proveniência (@cap-arquitetura).

#exercicios[
  + Um agente executa um comando de linha e obtém comportamento inesperado. Liste, em ordem de força probatória, as informações que ele deveria coletar para identificar o executável usado.
  + Por que dois binários com a mesma versão declarada podem se comportar de forma diferente? Dê dois exemplos.
  + Uma máquina foi reformatada e o sistema de contexto reinstalado com a mesma configuração. Que asserções sobre identidade de instalação devem ser registradas? Por que não se deve reutilizar a identidade anterior?
]

#quadro[
  - Nome, identificador, localizador e identidade são coisas diferentes; localizador não é identidade (@inv-localizador-identidade).
  - Equivalência entre identificadores de domínios diferentes é uma asserção que exige prova; mesmo nome não é mesma identidade.
  - Resolva identidade antes de renderizar: funda apenas o que está no fecho das equivalências provadas (@teo-fusoes-seguras).
  - Recurso e materialização são distintos: #estado[não materializado] é um estado legítimo, não #est[desconhecido].
  - Localizadores são temporalmente inseguros: endereçável exige verificar a identidade do que se encontra no local.
  - Identidade por conteúdo (resumos, árvores de Merkle) fornece âncoras autoverificáveis e imutáveis; distinga identidade de conteúdo e de trajetória.
]

#problemas[
  #problema([Registro de identidades com revogação])[
    Projete um registro de equivalências entre identificadores de vários domínios.
    + Especifique as operações (registrar equivalência com prova, revogar, consultar classe) e suas pré-condições.
    + Mostre como a revogação de uma equivalência afeta as perspectivas que dependiam da fusão correspondente, usando o @teo-retratacao.
    + Discuta a política de divulgação: um consumidor sem autoridade sobre um domínio pode saber que um identificador desse domínio é equivalente a um que ele conhece?
  ]
  #problema([Catálogo a partir de múltiplas fontes])[
    Um catálogo de recursos é construído combinando o serviço de hospedagem, varreduras de máquinas e um registro manual mantido pela equipe.
    + Modele cada fonte como um conjunto de asserções com estatuto e proveniência.
    + Proponha regras de combinação que respeitem os invariantes deste capítulo e o @pri-dono-semantico.
    + Identifique três tipos de inconsistência que o procedimento deve detectar e relatar, em vez de resolver silenciosamente.
  ]
  #problema([Identidade de serviços de contexto])[
    Um serviço que fornece contexto a agentes é iniciado em diferentes máquinas e diretórios.
    + Liste as designações relevantes para identificar uma instância do serviço e o espaço de trabalho que ela serve.
    + Mostre como um serviço que infere o espaço de trabalho a partir do diretório de trabalho do processo pode servir o espaço errado.
    + Proponha um protocolo de inicialização que estabeleça, com prova, qual espaço de trabalho a instância serve.
  ]
]

#notas[
  A teoria de nomeação e vinculação de #ct(<saltzer1978>) continua a referência fundamental para o tema; a distinção entre identificadores e localizadores na web é formalizada na especificação de URIs @rfc3986. Árvores de Merkle foram introduzidas por #ct(<merkle1987>) e são a base do modelo de objetos de sistemas de controle de versão distribuídos @chacon2014. A preocupação com proveniência de executáveis ganhou força com o estudo de ataques à cadeia de suprimentos de software, e o arcabouço in-toto @torresarias2019 é um exemplo de mecanismo para registrar e verificar essa proveniência. A estrutura de conjuntos disjuntos para manutenção do fecho de equivalência está em #ct(<cormen2022>).

  Os estudos de caso deste capítulo — três identidades para "o mesmo" espaço, o catálogo com materialização ausente e o localizador reaproveitado — generalizam falhas recorrentes de reorganização de ambientes de desenvolvimento, em que a confusão entre localizador e identidade é causa direta de erros de difícil diagnóstico. A formulação "o caminho é apenas onde procurar agora" resume a lição: localizadores orientam a busca; identidade se prova ao chegar.
]
