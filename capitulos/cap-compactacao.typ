#import "/modelo/estilo.typ": *

= Compactação, pontos de controle e sementes <cap-compactacao>

#epigrafe[A semente não contém o organismo; contém a informação para reconstruí-lo no ambiente atual.]

Agentes de longa duração enfrentam um limite físico: a janela de contexto enche. O @cap-llm mostrou que o laço agêntico ingênuo tem custo quadrático e atinge a janela após um número finito de passos (@teo-custo-quadratico); o @cap-working-set mostrou que, sob pressão de contexto, compactar com mais frequência pode piorar as coisas. Este capítulo trata do que fazer quando, inevitavelmente, é preciso reduzir o contexto — e de como fazê-lo sem destruir o que importa.

A tese do capítulo é que há duas maneiras de compactar. A primeira, mais comum, _resume o texto_ acumulado na janela. A segunda _reprojeta_: grava no acervo o que precisa sobreviver e recalcula uma perspectiva nova, pequena, a partir dele. A primeira é uma compressão por resumo, com todas as suas perdas (@cap-compressao); a segunda é uma projeção e herda os axiomas.

A @sec-comp-estrategias apresenta as estratégias de redução de contexto. A @sec-comp-perda modela a perda acumulada de compactações sucessivas. A @sec-comp-reprojecao propõe a compactação por reprojeção. A @sec-comp-checkpoint trata de pontos de controle e suficiência. A @sec-comp-semente define a semente de continuação. A @sec-comp-colheita apresenta a colheita semântica — a compressão do que um episódio de trabalho ensinou.

== Estratégias de redução de contexto <sec-comp-estrategias>

Na prática, cinco estratégias são usadas, isoladas ou combinadas @anthropic2025context @packer2023.

/ Truncamento: descartar o material mais antigo. Simples e barato, mas sem critério de importância: decisões antigas e cruciais desaparecem antes de observações recentes e triviais.

/ Resumo do histórico: substituir o histórico por um resumo, frequentemente gerado pelo próprio modelo. Preserva a narrativa, mas é com perdas e tende a achatar estatutos.

/ Limpeza de resultados de ferramentas: substituir resultados volumosos de ferramentas já consumidos por uma referência ("resultado da busca $X$, 2 mil linhas, disponível em $r$"). É uma forma de endereçamento e costuma ser a redução mais segura.

/ Notas estruturadas: o agente mantém, fora da janela, um arquivo de notas — objetivos, decisões, pendências, progresso — que relê quando necessário. É externalização de memória.

/ Reinício com contexto novo e subagentes: encerrar a sessão e iniciar outra com uma perspectiva recalculada, ou delegar subtarefas a agentes com janelas limpas que devolvem apenas resultados condensados.

As três últimas estratégias têm em comum o deslocamento da informação para fora da janela, num lugar de onde ela pode ser recuperada. Esse é o princípio que o restante do capítulo desenvolve.

#principio(titulo: [Escreva antes de esquecer])[
  Antes de qualquer redução de contexto, registre no acervo — como evidência, decisão, pendência ou nota estruturada — tudo o que precisa sobreviver à redução. O que só existia na janela e não foi registrado deve ser considerado perdido após a compactação.
] <pri-escreva-antes>

#exercicios[
  + Classifique as cinco estratégias quanto a: perda de informação, custo, risco de achatar estatutos e possibilidade de recuperação.
  + Por que a limpeza de resultados de ferramentas costuma ser mais segura do que o resumo do histórico? Em que caso ela também perde informação?
  + Proponha uma política combinada de redução de contexto para um agente de programação de longa duração: que estratégia usar primeiro, quando recorrer à próxima e o que registrar antes de cada uma (@pri-escreva-antes).
]

== Perda acumulada <sec-comp-perda>

Quando a compactação é feita por resumo, cada compactação preserva apenas parte do que estava na janela. Um modelo simples mostra por que isso é grave para tarefas longas.

#teorema(titulo: [Sobrevivência geométrica])[
  Suponha que cada compactação preserve cada unidade de informação presente na janela, independentemente, com probabilidade $q in (0, 1)$, e que informação descartada não seja recuperada. Então a probabilidade de uma unidade introduzida antes da primeira compactação sobreviver a $k$ compactações é $q^k$, e o número esperado de compactações a que ela sobrevive é $q \/ (1 - q)$.
] <teo-sobrevivencia>

#prova[
  A sobrevivência a $k$ compactações é a interseção de $k$ eventos independentes de probabilidade $q$. O número $N$ de compactações sobrevividas satisfaz $Pr(N >= k) = q^k$, e $E[N] = sum_(k >= 1) Pr(N >= k) = sum_(k >= 1) q^k = q \/ (1 - q)$.
]

Com $q = "0,9"$ — um resumo que preserva 90% do que importa —, uma informação sobrevive em média a nove compactações; com vinte compactações, a probabilidade de ainda estar presente é cerca de 12%. Para uma tarefa que dura centenas de passos, isso significa que restrições estabelecidas no início — "não altere a interface pública", "o titular decidiu não suportar a versão 1" — têm alta probabilidade de desaparecer antes do fim. A independência é uma idealização; na prática, resumos de resumos tendem a perder sistematicamente as mesmas classes de informação (detalhes, ressalvas, desconhecidos), o que torna a situação pior para essas classes.

#corolario(titulo: [Informação de longa duração vive fora da janela])[
  Informação que precisa valer por toda a duração de uma tarefa longa não pode depender da sobrevivência a compactações sucessivas; deve viver no acervo e ser reprojetada na janela a cada recomposição.
] <cor-longa-duracao>

#antipadrao(titulo: [Resumo de resumo])[
  O contexto é compactado resumindo o resumo anterior junto com o material novo. A cada geração, ressalvas viram certezas, desconhecidos desaparecem, decisões condicionais viram regras. Depois de algumas gerações, o resumo descreve com confiança um estado que nunca existiu.
] <anti-resumo-resumo>

#exercicios[
  + Com $q = "0,95"$, quantas compactações são necessárias para que a probabilidade de sobrevivência caia abaixo de 50%?
  + Proponha um experimento para estimar $q$ por classe de informação (decisões, desconhecidos, restrições, observações) para um procedimento de resumo concreto.
  + #avancado Suponha que cada compactação preserve cada item com probabilidade $rho_c$ que depende da classe $c$ do item. Mostre que, após $n$ compactações, a proporção esperada de itens da classe $c$ é $rho_c^n$ e discuta como registrar fora da janela as classes com $rho_c$ baixo.
]

== Compactação por reprojeção <sec-comp-reprojecao>

A alternativa ao resumo é tratar a compactação como uma _nova projeção_: em vez de comprimir o texto da janela, grava-se no acervo o que deve sobreviver (@pri-escreva-antes) e calcula-se uma perspectiva nova, para a coordenada corrente, que substitui a janela.

#definicao(titulo: [Compactação por reprojeção])[
  Uma _compactação por reprojeção_ no passo $t$ consiste em: (i) registrar no acervo, com proveniência, as observações, decisões, pendências e evidências produzidas desde a última recomposição; (ii) atualizar a coordenada $kappa_t$ (objetivo, trabalho selecionado, transição considerada); (iii) calcular $P_t = pi(Sigma_t, kappa_t)$; e (iv) substituir a janela por $rho(P_t, B, u)$ seguida apenas do material volátil indispensável ao passo corrente, marcado com sua função e com estatuto #est[desconhecido] até ser registrado.
] <def-compactacao-reprojecao>

#teorema(titulo: [Reprojeção preserva os axiomas])[
  Se $pi$ satisfaz os axiomas P1–P6 e $rho$ é honesta, a parte renderizada do contexto produzido por uma compactação por reprojeção não promove o estatuto de nenhuma asserção e não omite silenciosamente nenhuma asserção aplicável e legível registrada no acervo; o material volátil, por estar marcado como #est[desconhecido] até ser registrado, também não promove estatuto.
] <teo-reprojecao>

#prova[
  A parte renderizada é $rho(pi(Sigma_t, kappa_t), B, u)$, à qual se aplica diretamente o @lem-composicao-honesta. O material volátil não passou por $pi$; a marcação exigida no item (iv) da definição é o que impede que ele seja lido com estatuto maior que o que tem.
]

A garantia vale para o que foi _registrado_. A compactação por reprojeção desloca o problema: em vez de "o resumo preservou o que importa?", a pergunta passa a ser "o agente registrou o que importa?". A segunda pergunta é mais tratável: o registro pode ser exigido por portões (nenhuma decisão sem registro; nenhuma observação relevante sem evidência), verificado por sentinelas e auditado depois.

#figure(
  tabela(
    colunas: (1fr, 1fr),
    cabecalho: ([Compactação por resumo], [Compactação por reprojeção]),
    [comprime o texto da janela], [recalcula a perspectiva a partir do acervo],
    [preservação probabilística, perda acumulada], [preservação do que foi registrado, sem acúmulo],
    [estatutos tendem a ser achatados], [estatutos preservados (P4)],
    [desconhecidos tendem a desaparecer], [desconhecidos explícitos (P5)],
    [invalida o cache de prefixo], [prefixo estável recalculável de forma canônica],
    [não exige disciplina de registro], [exige registrar antes de compactar],
  ),
  caption: [Compactação por resumo e por reprojeção.],
) <tab-resumo-reprojecao>

#exercicios[
  + Descreva uma compactação por reprojeção para um agente de depuração depois de 40 passos, listando o que deve ser registrado no passo (i).
  + Mostre um exemplo em que a reprojeção perde informação que o resumo teria preservado. Que falha de registro isso revela?
  + Mostre que, se o acervo contém tudo o que a perspectiva continha antes da compactação, então a reprojeção na mesma coordenada é sem perda em relação ao acervo. Que hipótese de registro garante isso?
]

== Pontos de controle e suficiência <sec-comp-checkpoint>

Um _ponto de controle_ é um registro do estado de um trabalho a partir do qual ele pode ser retomado — pelo mesmo agente após um reinício, ou por outro. A pergunta central é se o ponto de controle é _suficiente_.

#definicao(titulo: [Ponto de controle suficiente])[
  Seja $H_t$ o histórico de um trabalho até o passo $t$ e $Omega_"rel"$ o estado das dimensões relevantes para as decisões futuras. Um ponto de controle $k_t$ é _informacionalmente suficiente_ se $Pr(Omega_"rel" | H_t) = Pr(Omega_"rel" | k_t)$ — tudo o que o histórico diz sobre o que importa, o ponto de controle também diz. A propriedade é do par (histórico, ponto de controle) e não depende do consumidor; com um acervo bem registrado, pode ser verificada no acervo.
] <def-checkpoint-suficiente>

A suficiência informacional não garante que um consumidor real _decida_ da mesma forma com o histórico e com o ponto de controle: modelos de linguagem são sensíveis a diferenças de forma que não carregam informação. A equivalência de comportamento é uma propriedade empírica, que se _testa_.

#definicao(titulo: [Teste de retomada fria])[
  Um _teste de retomada fria_ compara, para um conjunto de pontos de um trabalho, as decisões de um consumidor que continua com o histórico completo e as de um consumidor frio que recebe apenas o ponto de controle. Sejam $a_"hh"$ a taxa de concordância entre duas execuções independentes do consumidor com o histórico completo e $a_"hc"$ a taxa entre uma execução com o histórico e uma com o ponto de controle. A _suficiência empírica normalizada_ é $a_"hc" \/ a_"hh"$, estimada com intervalo de confiança (@cap-avaliacao).
] <def-retomada-fria>

A normalização é necessária porque mesmo um ponto de controle perfeito não produz concordância 1 com um consumidor estocástico: a referência correta é a concordância do consumidor consigo mesmo.

Pontos de controle bem projetados contêm, tipicamente: a coordenada (objetivo, unidade, transição); referências ao estado relevante, não cópias dele; as decisões tomadas e ainda vigentes; os desconhecidos e hipóteses abertas; a fronteira imediata; e a trajetória mínima que explica por que se está ali (@pri-coordenada-trajetoria).

#exercicios[
  + Proponha o conteúdo de um ponto de controle para uma tarefa de migração de banco de dados interrompida no meio.
  + Desenhe um teste de retomada fria para comparar dois formatos de ponto de controle, incluindo o número de repetições.
  + Por que um ponto de controle deve registrar os desconhecidos com o mesmo cuidado que os fatos? Dê um exemplo em que a omissão de um desconhecido leva o consumidor que retoma a agir sobre uma suposição.
]

== A semente de continuação <sec-comp-semente>

No encerramento de uma unidade de trabalho, ou numa transferência, é preciso deixar algo que permita a continuidade. O objeto mínimo com essa função é a semente.

#definicao(titulo: [Semente de continuação])[
  Uma _semente de continuação_ é um registro, ciente de proveniência e emitido numa fronteira governada, que permite ao próximo consumidor reconstruir contexto suficiente e expandir de forma determinística, e que é mínimo, em número de referências, entre os registros que passam no teste de retomada fria (@def-retomada-fria). Ela contém referências à intenção — objetivo, foco, escopo — e à origem; não contém o estado que essas referências designam. Uma semente pode declarar que _nenhuma_ continuação é necessária (semente terminal), apontando o arco encerrado como âncora.
] <def-semente-continuacao>

#invariante(titulo: [A semente transporta intenção, não realidade])[
  A semente carrega a intenção — o que se pretendia, com que foco e escopo — e deixa que a realidade seja recomputada no destino: observações, materializações, autoridade, atualidade, aplicabilidade e seleção são recalculadas por quem retoma. Continuidade de contexto não é cópia de contexto. Uma semente não é autoridade, nem verdade corrente, nem sessão.
] <inv-semente-intencao>

A metáfora da epígrafe é precisa: a semente não contém o organismo, mas a informação para reconstruí-lo _no ambiente onde vai germinar_. Se ela carregasse a topologia, os localizadores e o estado da origem, o destino operaria sobre uma realidade obsoleta — candidatos que já foram promovidos, máquinas que já foram substituídas, autorizações que já foram revogadas.

#invariante(titulo: [Semente não é trajetória])[
  A semente carrega apenas a intenção suficiente para continuar; não o registro de tudo o que foi visto. Uma semente que cresce até conter a trajetória inteira perdeu sua função: deixou de ser um portal e passou a ser um depósito. Sementes bem projetadas são pequenas.
] <inv-semente-trajetoria>

#invariante(titulo: [Reconstruível não é atual])[
  Poder reconstruir a jornada a partir de sementes antigas não garante que a semente usada seja a corrente. Mecanismos de retomada devem verificar que a semente escolhida é a mais recente aplicável — e não uma anterior, ainda presente no acervo.
] <inv-semente-atual>

#exercicios[
  + Escreva a semente de continuação para uma unidade de trabalho interrompida (a) a meio caminho e (b) concluída sem continuação necessária.
  + Por que a semente deve conter o foco intencional, mas não a seleção corrente? Relacione com a recomputação da seleção no destino.
  + Uma semente terminal declara que nenhuma continuação é necessária. Que âncora ela deve conter, e por que essa declaração não é equivalente a "não há trabalho pendente no domínio"?
]

== Colheita semântica <sec-comp-colheita>

Ao fim de um episódio de trabalho, um agente ou equipe acumulou lições: o que funcionou, o que falhou, que distinção faltava, que hipótese caiu. Guardar tudo como memória cria um acervo que cresce sem limite e repete a mesma lição em muitas formas. A _colheita semântica_ é a compressão desse aprendizado.

#definicao(titulo: [Colheita semântica])[
  A _colheita semântica_ de um conjunto de lições $L$ contra a semântica estabelecida $S$ (invariantes, princípios, definições já registrados) aplica a cada lição $ell in L$ um desafio (é generalizável? tem consumidor? contradiz $S$?), encontra o melhor mapeamento de $ell$ em $S$ e escolhe uma operação:
  - #estado[acrescentar]: $ell$ é nova e merece registro;
  - #estado[subsumir]: $ell$ é caso particular de algo em $S$; registrar só a ligação;
  - #estado[suplantar]: $ell$ corrige algo em $S$, que vira histórico;
  - #estado[retirar]: $ell$ mostra que algo em $S$ deixou de valer;
  - #estado[adiar]: $ell$ é promissora, mas carece de evidência; vira pendência;
  - #estado[nada fazer]: $ell$ não acrescenta.
  Persiste-se apenas o resíduo das operações #estado[acrescentar] e #estado[adiar]; o resíduo adiado é acompanhado periodicamente e, quando ganha evidência, volta a ser colhido.
] <def-colheita>

#principio(titulo: [Absorver o valor, não a estrutura histórica])[
  Da experiência passada, preserve o que ela ensinou, mapeado na semântica corrente — não a forma em que o ensinamento apareceu pela primeira vez.
] <pri-absorver-valor>

A colheita tem um paralelo no princípio do comprimento mínimo de descrição @rissanen1978: a melhor teoria é a que, somada aos dados que ela não explica, tem a descrição mais curta. Acrescentar uma lição só se justifica se ela reduz o que precisa ser lembrado de outra forma.

#exercicios[
  + Aplique a colheita semântica a cinco lições de um projeto seu, usando como $S$ os princípios deste livro.
  + Qual a diferença entre #estado[subsumir] e #estado[nada fazer]? Por que registrar a ligação na subsunção é útil?
  + Mostre, com um exemplo, como a colheita semântica impede o crescimento indefinido de um corpo de lições. Que critério decide entre #estado[substituir] e #estado[aposentar] uma lição antiga?
]

#quadro[
  - Reduzir contexto: truncar, resumir, limpar resultados de ferramentas, notas estruturadas, reiniciar ou delegar; escreva antes de esquecer.
  - Compactações por resumo acumulam perda geometricamente (@teo-sobrevivencia); informação de longa duração vive no acervo.
  - Compactação por reprojeção herda os axiomas (@teo-reprojecao); desloca o problema para a disciplina de registro.
  - Pontos de controle devem ser suficientes; suficiência se testa por retomada fria.
  - A semente de continuação transporta intenção, não realidade; é pequena, não é trajetória, e precisa ser a corrente.
  - A colheita semântica comprime o aprendizado: acrescentar, subsumir, suplantar, retirar, adiar ou nada fazer.
]

#problemas[
  #problema([Política ótima de compactação])[
    Combine o modelo de custo do @cor-compactacao com o @teo-sobrevivencia.
    + Escreva o custo esperado por passo de uma política que compacta por resumo ao atingir $W$, incluindo o custo esperado de erros causados por informação perdida (suponha custo $C_e$ por informação crítica perdida).
    + Compare com uma política de reprojeção com custo fixo de registro por passo.
    + Encontre as condições em que cada política domina.
  ]
  #problema([Sementes e atualidade])[
    Num acervo com muitas sementes de uma mesma linha de trabalho, um mecanismo de retomada precisa escolher a semente corrente.
    + Formule a escolha como consulta ao acervo, usando relações de suplantação.
    + Mostre que a escolha pela data de gravação pode falhar (@inv-tres-relogios).
    + Proponha uma regra baseada em relações explícitas e prove que ela escolhe uma única semente quando a cadeia de suplantação é linear.
  ]
  #problema([Colheita como compressão])[
    Formalize a colheita semântica como problema de comprimento mínimo de descrição.
    + Defina o custo de descrever um conjunto de lições dado um conjunto de princípios.
    + Mostre que acrescentar um princípio que subsume $k$ lições reduz o custo se e somente se a descrição do princípio, somada às descrições das $k$ ligações de subsunção, é menor que a soma das descrições das lições que ele substitui: $L("princípio") + sum_(i=1)^k L("ligação"_i) < sum_(i=1)^k L("lição"_i)$.
    + Discuta o risco de "sobreajuste": princípios que subsumem lições por coincidência.
  ]
]

#notas[
  Estratégias de compactação, notas estruturadas e arquiteturas com subagentes são discutidas, para agentes de longa duração, em guias de prática @anthropic2025context e no levantamento de #ct(<mei2025>); a paginação entre janela e armazenamento externo é a proposta de #ct(<packer2023>), e agentes com memória de reflexões aparecem em #ct(<park2023>) e #ct(<shinn2023>). A suficiência de uma estatística é um conceito clássico de estatística; aqui ela é usada de forma operacional, testada por retomada fria. O princípio do comprimento mínimo de descrição é de #ct(<rissanen1978>), e o gargalo de informação de #ct(<tishby1999>) oferece outra formulação do compromisso entre compressão e preservação do que é relevante para uma tarefa.

  A distinção entre compactar por resumo e por reprojeção, a semente de continuação como portal e não como resumo, a regra "transportar intenção, recomputar realidade" e a colheita semântica com suas operações são propostas deste livro para colaborações longas, em que sessões são encerradas e retomadas muitas vezes e a qualidade da retomada depende do que foi registrado.
]
