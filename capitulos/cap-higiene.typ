#import "/modelo/estilo.typ": *

= Higiene, convergência e dívida de contexto <cap-higiene>

#epigrafe(fonte: [Meir M. Lehman, 1980])[À medida que um programa em evolução é continuamente modificado, sua complexidade, que reflete uma estrutura em deterioração, aumenta, a menos que se trabalhe para mantê-la ou reduzi-la.]

Sistemas de contexto acumulam resíduos. Ponteiros que já não apontam para nada; cópias de trabalho de tarefas encerradas; identificadores órfãos; registros "abertos" de objetivos atendidos; duas fontes para a mesma informação; convenções antigas que um mecanismo ainda segue. Nenhum desses resíduos é, isoladamente, um erro grave. Juntos, eles constituem o que chamaremos de _dívida de contexto_: o custo crescente de descobrir o que é verdade.

Este capítulo trata da administração dessa dívida. A @sec-hig-divida define dívida de contexto e propõe medi-la pelo custo de descoberta. A @sec-hig-inventario descreve o inventário do acervo como primeira ferramenta de higiene. A @sec-hig-poda trata da classificação antes da remoção e prova que remover em ordem crescente de irreversibilidade minimiza a perda esperada. A @sec-hig-convergencia trata da convergência de linhas de trabalho e do manifesto de convergência. A @sec-hig-paralisia discute os limites da higiene: higiene sem paralisia. A @sec-hig-apagamento trata do apagamento obrigatório num acervo por acréscimo. A @sec-hig-diagnostico apresenta o diagnóstico estratificado.

== Dívida de contexto <sec-hig-divida>

A metáfora da dívida técnica @cunningham1992 descreve o custo futuro de atalhos tomados no presente; em sistemas de aprendizado de máquina, ela foi estendida a dependências ocultas de dados e de configuração @sculley2015. A dívida de contexto é a forma que essa ideia assume em sistemas de agentes.

#definicao(titulo: [Dívida de contexto])[
  A _dívida de contexto_ de um domínio, para uma família de perguntas $Q$, é a diferença entre o custo de responder $Q$ a partir do domínio tal como está e o custo de respondê-las se toda a informação necessária estivesse disponível por projeção direta, com donos semânticos únicos, identificadores resolvidos e estatutos atualizados.
] <def-divida-contexto>

A definição usa um contrafactual que não se observa. A versão operacional é: fixe uma bateria de perguntas $Q$ e um protocolo de consumidor frio (@cap-avaliacao); meça o custo esperado de descoberta — em tokens, rodadas e intervenções humanas — para responder $Q$ hoje; e compare-o com o mesmo custo depois que a projeção direta das respostas for _construída_. A dívida, assim medida, só é conhecida _a posteriori_; antes, estima-se pela proporção de respostas que exigem arqueologia.

O custo de responder é medido pelo _custo de descoberta_ do @cap-proveniencia: quanto da resposta veio de projeção direta, quanto exigiu expansões, quanto exigiu arqueologia em artefatos brutos e quanto exigiu inferência humana. As fontes típicas de dívida de contexto são:

- _ponteiros pendentes_: referências a recursos movidos, renomeados ou removidos;
- _estado registrado divergente_: registros cujo estado nominal não corresponde ao estado vigente (@def-estado-efetivo);
- _donos duplicados_: duas ou mais fontes para a mesma pergunta, sem dono designado;
- _identificadores órfãos_: designações sem definição resolúvel;
- _materializações sem classificação_: cópias de trabalho, ramos e diretórios cuja função ninguém sabe dizer;
- _relações implícitas não representadas_: o acervo sabe o bastante para reconstruí-las, mas não as registra (@def-classificacao-relacoes).

#principio(titulo: [A limpeza é o primeiro uso])[
  Organizar o acervo de um domínio não é um trabalho preparatório anterior à engenharia de contexto; é a primeira aplicação dela. Cada pergunta que hoje exige arqueologia é um caso de teste: depois da limpeza, ela deve ser respondível por projeção.
] <pri-limpeza-uso>

#exercicios[
  + Para um projeto que você conhece, liste cinco perguntas cuja resposta exige hoje "arqueologia". Classifique a fonte de dívida de cada uma.
  + Proponha uma medida numérica de dívida de contexto baseada no custo de descoberta e discuta seus limites.
  + Liste cinco sintomas observáveis de dívida de contexto num projeto com agentes e proponha uma métrica simples para cada um.
]

== O inventário do acervo <sec-hig-inventario>

A primeira ferramenta de higiene é um inventário honesto. Ele substitui perguntas que exigem busca manual por uma perspectiva que as responde diretamente.

#figure(
  tabela(
    colunas: (1fr, 1fr),
    cabecalho: ([Antes (arqueologia)], [Depois (projeção)]),
    ["Onde está o repositório $X$?" — procurar no sistema de arquivos], [catálogo de recursos: $X$ conhecido; remoto identificado; materializado em $ell$, ou #estado[não materializado]],
    ["Esta cópia de trabalho ainda é necessária?" — perguntar a pessoas, inspecionar revisões], [disposição classificada com evidência (@tab-disposicoes)],
    ["O ramo principal local está atualizado?" — conferir manualmente], [local, remoto e linha de base aceita como três valores distintos, com instante de observação],
    ["O que esta unidade de trabalho entregou?" — reconstruir pela história], [desfecho terminal com referências de entrega e evidência],
    ["Que executável estou usando?" — localizar, consultar versão, adivinhar a origem], [identidade por conteúdo e proveniência de construção (@pri-executaveis)],
  ),
  caption: [Do inventário arqueológico ao inventário projetado.],
) <tab-antes-depois>

O inventário deve ser construído como uma _linha de base observacional_ (@caso-linha-de-base-observacional): ele registra, com proveniência, o que se sabe e o que não se sabe sobre cada recurso — inclusive seu custo de descoberta. Assim, a melhoria do sistema pode ser medida comparando observações antes e depois, sem recorrer a pontuações subjetivas.

#exercicios[
  + Escreva o registro de inventário de um repositório com: dois ramos de trabalho, uma cópia de trabalho com alterações não registradas, uma referência de retenção e uma linha de base aceita diferente da ponta do ramo principal.
  + Por que o inventário deve registrar o _custo de descoberta_ de cada informação? Que decisão ele informa?
  + Proponha o formato de um inventário de acervo para um domínio com cem unidades de trabalho, dez anos de decisões e vários ramos abandonados. Que campos permitem classificar sem abrir cada item?
]

== Classificar antes de podar <sec-hig-poda>

A tentação mais perigosa da higiene é a remoção apressada: o ramo antigo "parece abandonado", a cópia de trabalho "ninguém usa", o diretório "é lixo". O @inv-estranho-obsoleto já advertiu que aparência não é evidência. Aqui, a advertência se torna procedimento.

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Disposição], [Significado e ação]),
    [#estado[trabalho governado ativo]], [pertence a uma unidade aberta; não tocar],
    [#estado[candidato provado não promovido]], [contém trabalho com evidência aguardando decisão; preservar e escalar],
    [#estado[aguardando promoção]], [decisão de promoção pendente; preservar],
    [#estado[raiz de retenção]], [mantém bytes que precisam sobreviver (por exemplo, de uma revisão aceita); não remover sem substituto],
    [#estado[bytes de recuperação]], [alterações não registradas noutra parte; registrar antes de qualquer remoção],
    [#estado[superado]], [trabalho substituído por outro; pode ser removido após registrar a suplantação],
    [#estado[já integrado]], [conteúdo presente na linha canônica; pode ser removido após prova de integração],
    [#est[desconhecido]], [não classificado; não remover],
  ),
  caption: [Disposições de materializações de trabalho (ramos, cópias de trabalho, diretórios).],
) <tab-disposicoes>

#algoritmo("Classifica-e-Poda", params: $M$, legenda: [Classificação de materializações antes de qualquer remoção.])[
  + #kw[para cada] materialização $m in M$ #kw[faça]
    + reúna: unidade associada, revisões, ancestralidade em relação à linha canônica, raízes de retenção, alterações não registradas, propósito corrente
    + #kw[se] contém material único relevante #kw[então] integre à linha canônica (ação governada) e reclassifique
    + #kw[senão se] é historicamente necessária #kw[então] registre referência de recuperação; remova apenas a materialização ativa
    + #kw[senão se] contém alterações não registradas #kw[então] reconcilie antes de qualquer remoção
    + #kw[senão se] está limpa, sem material único, e integrada ou superada com prova #kw[então] marque como candidata segura à remoção
    + #kw[senão] marque #est[desconhecido]
  + remova as candidatas seguras em ordem crescente de irreversibilidade (@prop-ordem-irreversibilidade)
] <alg-classifica-poda>

/ Correção e custo: o algoritmo só remove o que a linha 6 marcou como candidata segura, e a linha 6 exige conjuntamente quatro condições — limpa, sem material único, integrada ou superada, com prova —; qualquer dúvida cai na linha 7 (#est[desconhecido]), que não remove. Logo nenhuma materialização com material único é removida, desde que as observações da linha 2 sejam corretas. As linhas 3 e 5 são ações governadas que mudam a classificação; como cada uma retira uma razão de bloqueio e nenhuma a acrescenta, cada materialização é reclassificada no máximo duas vezes, e o laço termina. O custo é dominado pela linha 2: com $|M|$ materializações e a ancestralidade calculada por alcançabilidade no grafo de revisões $(V, E)$, $O(|M| (|V| + |E|))$, ou $O(|V| + |E| + |M|)$ com uma única travessia que marque as revisões alcançáveis da linha canônica; a ordenação final custa $O(|M| log |M|)$.

=== Ordem de remoção

Mesmo após classificação cuidadosa, erros são possíveis. A ordem das remoções afeta o custo esperado desses erros.

#proposicao(titulo: [Remover em ordem crescente de irreversibilidade])[
  Considere $n$ remoções, cada uma com custo de irreversibilidade $c_i >= 0$ (o dano se a remoção estiver errada) e a mesma probabilidade $p$, independente, de estar errada. Suponha que um erro é detectado imediatamente após a remoção errada e interrompe o processo. Então o custo esperado de erro é minimizado executando as remoções em ordem crescente de $c_i$.
] <prop-ordem-irreversibilidade>

#prova[
  Numa ordem $sigma$, a $k$-ésima remoção só é executada se as $k - 1$ anteriores estiverem corretas, e então está errada com probabilidade $p$. O custo esperado é
  $ E[C_sigma] = sum_(k=1)^n c_(sigma(k)) (1 - p)^(k-1) p. $
  Os pesos $w_k = (1 - p)^(k-1) p$ são decrescentes em $k$. Pela desigualdade do rearranjo (@prop-rearranjo, aplicada para minimizar), a soma dos produtos é mínima quando a sequência de custos é ordenada no sentido oposto ao dos pesos, isto é, em ordem crescente de $c_i$.
]

A proposição formaliza uma prudência intuitiva: comece pelo que pode ser desfeito. Se a classificação estiver sistematicamente errada, o erro aparece cedo, num item barato.

#exercicios[
  + Aplique o @alg-classifica-poda a cinco materializações fictícias de sua escolha, uma de cada disposição relevante.
  + Na @prop-ordem-irreversibilidade, mostre, por argumento de troca, que a ordem ótima continua crescente em $c_i$ mesmo com probabilidades de erro $p_i$ diferentes por item. Em seguida, considere o modelo em que cada remoção tem também um custo de execução $k_i$, pago sempre que é executada; mostre que a ordem ótima passa a ser crescente em $(k_i + p_i c_i) \/ p_i$.
  + Por que #est[desconhecido] nunca é candidata à remoção, mesmo que pareça antiga?
]

== Convergência de linhas de trabalho <sec-hig-convergencia>

Com o tempo, o trabalho de vários agentes e humanos se espalha por ramos, cópias de trabalho, referências de retenção e versões em execução. Em algum momento, é preciso recuperar uma única realidade operacional.

#estudo-de-caso(titulo: [Uma única realidade primeiro])[
  Depois de semanas de trabalho paralelo, o estado de um conjunto de repositórios incluía a linha principal, vários ramos locais, referências de preservação e cópias de trabalho com alterações. A primeira estratégia foi preservar cada trajetória separadamente, porque a governança histórica não conseguia provar a aceitação de todas as mudanças. O titular tomou então uma decisão que mudou o objetivo: _primeiro recuperar uma única realidade operacional na linha principal; a governança reconcilia a história depois_. O procedimento passou de "preservar trajetórias separadamente" para "integrar as histórias, preservar a proveniência e reconciliar a árvore final pela semântica corrente". As histórias foram incorporadas, mas nem todas as implementações antigas foram mantidas: conflitos foram resolvidos pela semântica atual, e cada conceito passou a ter um único dono na linha principal.
] <caso-realidade-unica>

#invariante(titulo: [Preservar história não é preservar implementações antigas])[
  A convergência preserva a proveniência — de onde veio cada mudança e por quê — mas não obriga a manter implementações concorrentes do mesmo conceito. Na linha principal, cada conceito tem um único dono semântico; as implementações substituídas permanecem acessíveis pela história, não pelo código corrente.
] <inv-historia-implementacoes>

#invariante(titulo: [Toda funcionalidade válida, não todo código histórico])[
  O critério de convergência é que toda funcionalidade válida esteja na linha principal — não que todo código histórico tenha sido integrado. Material único é classificado (@alg-classifica-poda): integrado se válido, retido se historicamente necessário, descartado com registro se superado.
] <inv-funcionalidade-valida>

=== O manifesto de convergência

#definicao(titulo: [Manifesto de convergência])[
  O _manifesto de convergência_ de um conjunto de recursos é uma visão derivada que, para cada recurso, registra: a revisão de trabalho corrente, a referência local, a referência remota, a revisão integrada proposta, a linha de base aceita, as operações explicitamente não realizadas e os termos usados com significado técnico preciso. O manifesto é calculado, não editado; ele não decide nada.
] <def-manifesto>

#proposicao(titulo: [A linha de base não é função das referências])[
  Se a aceitação não é registrada como referência de controle de versão, não existe função $f$ que, para todo recurso, calcule a linha de base aceita apenas a partir das referências de controle de versão (local, remota, rótulos).
] <prop-linha-base-referencias>

#prova[
  Considere dois mundos com exatamente as mesmas referências de controle de versão, num dos quais o titular aceitou a revisão $r_1$ e no outro a revisão $r_2$ (ambas presentes na história). Qualquer $f$ das referências dá o mesmo resultado nos dois mundos e, portanto, erra em pelo menos um deles. A aceitação é um ato governado registrado fora das referências.
]

#exercicios[
  + Escreva o manifesto de convergência de três repositórios em estados diferentes (um alinhado, um com candidato à frente, um divergente).
  + No @caso-realidade-unica, que registros garantem que, depois da convergência, ainda se possa responder "de onde veio esta linha de código?"?
  + Calcule o manifesto de convergência para três repositórios com situações diferentes (sincronizado; adiantado em relação ao remoto; com revisão aceita ainda não integrada) e indique a próxima ação para cada um.
]

== Higiene sem paralisia <sec-hig-paralisia>

A higiene tem um modo de falha oposto ao da remoção apressada: a paralisia. "Não posso provar que este item não importa, logo não posso removê-lo; não posso removê-lo, logo não posso declarar o acervo limpo; não posso declará-lo limpo, logo não posso avançar."

#invariante(titulo: [Paralisia epistêmica é falha])[
  A pertinência ao grafo corrente exige prova positiva; o que não tem prova positiva de pertinência é tratado como histórico — preservado, contabilizado em $X$ na categoria "histórico" ou alcançável por uma alça de $Phi$, conforme P5 —, não como bloqueio. "Não posso provar que não importa" não impede o avanço.
] <inv-paralisia>

O invariante não contradiz a prudência da @sec-hig-poda: tratar como histórico não é remover. A memória arqueológica (@def-camadas-memoria) existe precisamente para acomodar o que não se sabe classificar — preservado integralmente e acessível por expansão, mas fora do caminho.

#principio(titulo: [Contenção não é correção sistêmica])[
  Esconder um sintoma — remover uma recomendação errada, silenciar um alerta, renomear um arquivo que confundia um mecanismo — é contenção. A correção sistêmica corrige o mecanismo que produziu o sintoma. As duas podem ser necessárias, mas só a segunda encerra a classe de falhas.
] <pri-contencao>

=== Encerrar por esgotamento

Uma unidade de higiene pode ser encerrada de duas formas legítimas: quando a definição de concluído é satisfeita, ou quando as lacunas restantes se esgotaram — todas foram classificadas como resolvidas, adiadas com condição, transferidas ou explicitamente aceitas como históricas. Uma higiene que exige perfeição nunca termina; uma que termina por cansaço deixa dívida não registrada.

#exercicios[
  + Dê um exemplo de contenção que, sem correção sistêmica, leva à reincidência da falha.
  + Escreva o critério de encerramento por esgotamento para uma unidade de limpeza de ramos antigos.
  + Um agente se recusa a remover um diretório porque "não pode provar que ninguém o usa". Explique por que isso é paralisia epistêmica e proponha um procedimento que permita decidir com evidência limitada.
]

== Apagamento e o acervo por acréscimo <sec-hig-apagamento>

O modelo exige que o acervo só cresça (@def-acervo), e a reprodutibilidade das perspectivas depende disso. Obrigações legais de apagamento — o direito de eliminação de dados pessoais previsto em leis de proteção de dados — e de minimização exigem o contrário; e segredos gravados por engano precisam desaparecer. O conflito é real, mas tem solução compatível com o modelo.

#definicao(titulo: [Apagamento compatível com acréscimo])[
  Um _apagamento_ de uma asserção $a$ é o acréscimo de uma _lápide_ — o registro $(a, "motivo", "autoridade", t)$ — e a destruição do _conteúdo_ de $a$ (por exemplo, descartando a chave com que foi cifrado), preservando seu identificador, seu resumo criptográfico e uma proveniência mínima. Uma projeção _respeita apagamentos_ se nunca apresenta conteúdo apagado e declara em $X$ a existência da lápide quando a política de divulgação o permite.
] <def-apagamento>

#proposicao(titulo: [Reprodutibilidade módulo apagamentos])[
  Se o acervo cresce por acréscimo de asserções e de lápides, e a projeção respeita apagamentos, então a perspectiva recalculada em $t' > t$ para o instante $t$ coincide com a calculada em $t$, exceto pela substituição do conteúdo das asserções apagadas em $(t, t']$ pelas declarações de suas lápides.
] <prop-reproducao-apagamento>

#prova[
  As lápides são acréscimos; as asserções apagadas conservam identificador e estatuto, e só seu conteúdo é indisponível. Pelo determinismo (P2), o recálculo coincide com o original em tudo o que não depende do conteúdo apagado; onde depende, a projeção, por respeitar apagamentos, apresenta a lápide no lugar do conteúdo.
]

O apagamento toca outros temas do livro: a integridade contextual @nissenbaum2004, que pede que a informação flua apenas em contextos compatíveis com aquele em que foi obtida; os traços de execução (@cap-observabilidade), que concentram tudo o que os agentes viram e precisam de política de retenção própria; e a memória que se autoriza (@anti-memoria-autoriza), cujo remédio às vezes é, precisamente, apagar.

#exercicios[
  + Descreva o apagamento de um dado pessoal mencionado em dez asserções e em três registros de proveniência de contexto. O que permanece e o que desaparece?
  + Por que apagar o conteúdo, preservando o resumo criptográfico, ainda permite verificar que uma perspectiva antiga não foi adulterada?
  + #avancado Discuta se o resumo criptográfico de um dado pessoal de baixa entropia (por exemplo, um número de documento) deve ser preservado, considerando ataques de dicionário.
]

== Diagnóstico estratificado <sec-hig-diagnostico>

Ferramentas de diagnóstico ("o sistema está saudável?") frequentemente misturam dimensões e produzem alarmes falsos. Uma forma melhor é estratificar.

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Estrato], [Pergunta]),
    [Saúde semântica], [O domínio tem identidade resolvida, acervo íntegro e projeções calculáveis?],
    [Execução], [Os executáveis e serviços em uso têm identidade conhecida e oferecem as funções exigidas?],
    [Compatibilidade de clientes], [Cada cliente em uso está pronto, compatível apenas por adaptação, ou ausente?],
    [Compatibilidade legada], [Artefatos de convenções antigas estão presentes? Há migração disponível?],
  ),
  caption: [Diagnóstico estratificado. A ausência de um artefato legado não degrada a saúde semântica se nenhum consumidor atual o exige.],
) <tab-diagnostico>

#principio(titulo: [Saúde dimensional, não semáforo])[
  Relate a saúde como um vetor de estatutos por estrato e funcionalidade, não como uma única cor. Um semáforo vermelho que significa "falta um arquivo de compatibilidade antigo" esconde o que importa e treina os usuários a ignorar alarmes.
] <pri-saude-dimensional>

#exercicios[
  + Classifique nos estratos da @tab-diagnostico: (a) um arquivo de instruções num formato antigo ausente; (b) o serviço de projeção não responde; (c) um cliente exige uma versão de protocolo mais nova; (d) o identificador do domínio diverge do registrado.
  + Converta um relatório de saúde do tipo semáforo, de algum sistema que você conhece, num vetor dimensional.
  + Projete o formato de saída de um diagnóstico estratificado que possa ser lido tanto por humanos quanto por agentes, e indique como cada estrato referencia a evidência que o sustenta.
]

#quadro[
  - Dívida de contexto é o custo excedente de descobrir a verdade; meça-a pelo custo de descoberta.
  - O inventário projetado substitui arqueologia; a limpeza é o primeiro uso do sistema.
  - Classifique antes de podar (@tab-disposicoes); remova em ordem crescente de irreversibilidade (@prop-ordem-irreversibilidade).
  - Converja para uma única realidade preservando proveniência; preservar história não é preservar implementações antigas.
  - A linha de base não é função das referências de controle de versão (@prop-linha-base-referencias).
  - Higiene sem paralisia: pertinência exige prova positiva; o resto é histórico. Contenção não é correção sistêmica.
  - Diagnóstico estratificado e saúde dimensional, não semáforos.
]

#problemas[
  #problema([Ordem ótima com dependências])[
    Na @prop-ordem-irreversibilidade, suponha que algumas remoções dependam de outras (uma referência de retenção só pode ser removida depois da materialização que ela protege).
    + Formule o problema como ordenação com restrições de precedência.
    + Mostre que, quando as precedências formam uma floresta, há um algoritmo guloso ótimo baseado em combinar subárvores (pense em problemas de escalonamento com pesos).
    + Discuta o caso geral.
  ]
  #problema([Medindo a dívida])[
    Proponha um experimento para medir a redução de dívida de contexto após uma operação de higiene.
    + Defina um conjunto de perguntas-padrão e o protocolo para medir o custo de descoberta de cada uma.
    + Use consumidores frios para evitar que o conhecimento do experimentador contamine a medição.
    + Discuta como evitar que a higiene seja "otimizada para o teste".
  ]
  #problema([Convergência sob concorrência])[
    Enquanto uma unidade de convergência trabalha, outros agentes continuam promovendo mudanças.
    + Descreva um procedimento que observe a linha principal antes de mudar, antes de registrar, antes de instalar e antes de selar, e registre separadamente a fonte final e o conjunto de mutações causadas pela unidade.
    + Mostre que, sem essa separação, a história causal se torna ambígua.
    + Relacione com o @inv-trabalho-concorrente.
  ]
]

#notas[
  A metáfora da dívida técnica é de #ct(<cunningham1992>), e sua extensão a sistemas de aprendizado de máquina, de #ct(<sculley2015>); as leis de evolução de software de #ct(<lehman1980>) descrevem o crescimento inexorável da complexidade em sistemas que não recebem trabalho de manutenção. A gestão de configuração e a entrega contínua @humble2010 tratam de muitos dos problemas de convergência deste capítulo do ponto de vista de pipelines de software, e a engenharia de confiabilidade @beyer2016 enfatiza a diferença entre mitigação e correção de causas. A desigualdade do rearranjo usada na @prop-ordem-irreversibilidade está em #ct(<hardy1934>).

  A noção de dívida de contexto, o inventário projetado como "primeiro uso", a tipologia de disposições de materializações e o caso de recuperação de uma única realidade operacional são propostas deste livro. A observação de fundo é que a limpeza de um ambiente é o melhor teste do próprio sistema de contexto: cada pergunta que exige arqueologia aponta uma lacuna de gerenciamento.
]
