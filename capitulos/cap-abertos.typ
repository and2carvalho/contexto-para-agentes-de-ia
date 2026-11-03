#import "/modelo/estilo.typ": *

#let _cont-aberto = counter("aberto")
#let aberto(titulo, enunciado, importa, sabemos, direcoes) = {
  _cont-aberto.step()
  block(above: 1.5em, below: 1.2em, breakable: true, width: 100%, inset: (left: 10pt, y: 2pt), stroke: (left: 1.5pt + cor.secundaria), {
    block(below: 0.6em, sticky: true, text(font: semserifa, weight: "bold", size: 10.5pt)[
      #text(fill: cor.primaria)[Problema em aberto #context _cont-aberto.display()]#h(0.6em)#titulo
    ])
    set par(first-line-indent: 0pt)
    [*Enunciado.* #enunciado]
    parbreak()
    [*Por que importa.* #importa]
    parbreak()
    [*O que o livro estabelece.* #sabemos]
    parbreak()
    [*Direções.* #direcoes]
  })
}

= Problemas em aberto <cap-abertos>

#epigrafe[Uma área de pesquisa é tão viva quanto a lista de perguntas que ela ainda não sabe responder.]

Este livro apresentou uma teoria — definições, invariantes, teoremas, algoritmos e práticas — para o gerenciamento, a engenharia, o design e a administração de contexto de agentes. Uma teoria honesta declara seus limites. Este capítulo reúne os problemas que permanecem abertos: alguns são questões matemáticas bem definidas; outros são problemas de medição que exigem experimentos ainda não realizados; outros, ainda, são perguntas de projeto para as quais não há consenso.

Para cada problema, damos o enunciado, a razão pela qual importa, o que o livro já estabelece e direções promissoras. A organização segue seis grupos: seleção e orçamento (@sec-ab-selecao); formalização e lógica (@sec-ab-logica); tempo e distribuição (@sec-ab-tempo); autoridade e federação (@sec-ab-autoridade); medição (@sec-ab-medicao); e método e interação (@sec-ab-metodo).

== Seleção e orçamento <sec-ab-selecao>

#aberto([Seleção epistêmica sob orçamento])[
  Estender os resultados de aproximação da cobertura com orçamento a utilidades que dependem do estatuto epistêmico dos itens — em que desconhecidos e omissões declaradas têm custo e valor próprios —, e determinar se existe garantia de aproximação quando a declaração de omissões (P5) é uma restrição dura que consome orçamento.
][
  A seleção é o problema computacional central do gerenciamento de contexto. As garantias clássicas supõem utilidade sobre itens indistintos quanto ao estatuto.
][
  A seleção suficiente é NP-difícil, e, para utilidades submodulares monótonas com orçamento, o guloso por razão combinado com o melhor item isolado garante $(1 - 1\/e)\/2$ @khuller1999, enquanto a garantia $(1 - 1 \/ e)$ exige enumeração parcial @sviridenko2004 (@cap-selecao). A declaração de omissões tem custo limitado pelo número de categorias (@cap-apresentacao).
][
  Modelar a declaração de omissão como item obrigatório de custo dependente da seleção; investigar se a utilidade composta preserva submodularidade; relação com otimização submodular sob restrições de mochila e de matroide.
]

#aberto([Monotonicidade em autoridade sob orçamento fixo])[
  Caracterizar as classes de projeções $pi$ para as quais ampliar a autoridade de leitura nunca reduz a utilidade da perspectiva sob orçamento fixo.
][
  Observou-se (@cap-modelo) que ganhar acesso pode expulsar itens da perspectiva. Consumidores e auditores esperam, intuitivamente, que mais acesso nunca piore.
][
  A monotonicidade em autoridade vale sem orçamento (@prop-monotonia-autoridade) e falha, em geral, com orçamento fixo.
][
  Condições de troca do tipo matroide; separação entre seleção de candidatos (monótona) e alocação de orçamento; definições de monotonicidade fraca (utilidade não diminui, mesmo que o conjunto mude).
]

#aberto([Monotonicidade no refinamento da coordenada])[
  Determinar quando refinar a coordenada (por exemplo, especificar um foco mais estreito) reduz ou mantém o conjunto de asserções aplicáveis, e quando o aumenta.
][
  A navegação por expansão e estreitamento supõe que o refinamento tem efeito previsível.
][
  A aplicabilidade é definida sobre coordenadas, e as coordenadas parciais formam um produto de domínios planos (@cap-modelo, Apêndice A): ínfimos sempre existem; supremos, apenas para coordenadas compatíveis.
][
  Identificar classes de regras de aplicabilidade antimonótonas no refinamento; caracterizar as exceções (asserções aplicáveis apenas a coordenadas específicas).
]

#aberto([Contexto preguiçoso ótimo])[
  Determinar quando compor a perspectiva antecipadamente e quando expandir sob demanda, com um modelo de custo que combine tokens, latência, rodadas e risco de erro.
][
  O custo dominante de agentes é o consumo de contexto; a escolha entre antecipação e demanda é feita hoje por heurística.
][
  O conjunto de trabalho e a analogia com a paginação por demanda (@cap-working-set); a expansão como nova projeção (@cap-fronteira); o resultado de competitividade de algoritmos de paginação.
][
  Modelos de pré-busca com previsão de acesso; análise competitiva com custo de rodada; experimentos com consumidores congelados.
]

#aberto([Compressão por endereçamento])[
  Testar a hipótese de que o contexto por coordenadas e referências, com expansão sob demanda, reduz o consumo de tokens em ordem de grandeza mantendo a acurácia em tarefas de vários passos.
][
  É a afirmação empírica central que motiva a compressão por coordenadas.
][
  A transferência por coordenada basta quando há acervo compartilhado (@teo-transferencia-minima); a compressão por coordenadas é sem perda relativa ao acervo (@cap-compressao).
][
  Experimento fatorial com ablações (com e sem referências; com e sem desconhecidos explícitos; com e sem proveniência), consumidor congelado e tarefas de vários passos (@cap-avaliacao).
]

== Formalização e lógica <sec-ab-logica>

#aberto([A ordem de força epistêmica é total?])[
  Decidir se a força da evidência (prova, medição, relato, inferência) admite uma ordem total ou exige um reticulado parcial — por exemplo, quando se compara uma medição num ambiente com uma prova em outro.
][
  Portões e agregações dependem de comparar forças de evidência.
][
  Os estatutos formam o bireticulado de Belnap, com duas ordens (@cap-epistemologia); a força de evidência foi tratada como ordem auxiliar (@cap-proveniencia).
][
  Produto de ordens (força $times$ escopo); bireticulados; interação com o estatuto conflitante.
]

#aberto([Lógica do escopo da negação])[
  Formalizar "não observado aqui" com lógica epistêmica indexada por agente e coordenada, e determinar quando o conhecimento distribuído de um grupo de domínios decide uma negação global.
][
  Confundir ausência local com ausência global é uma das falhas mais comuns de agentes.
][
  O lema do escopo da negação (Apêndice B) e a regra de que só evidência negativa produz falso (@cap-perspectiva); o conhecimento distribuído (Apêndice B).
][
  Hipóteses de cobertura como fórmulas explícitas; lógicas de mundo fechado local; relação com a hipótese do mundo fechado em bancos de dados @reiter1978.
]

#aberto([Atualidade como relação ternária])[
  Axiomatizar a atualidade como relação entre uma observação, uma referência de comparação e uma pergunta, e determinar quando uma visão não atômica é "coerente o bastante" para uma pergunta.
][
  A atualidade é condição de quase todos os portões; tratá-la como propriedade binária causa falsos positivos e negativos.
][
  A atualidade é relativa à pergunta (@cap-tempo); cortes consistentes e relógios vetoriais dão a base distribuída (Apêndice D).
][
  Relação com níveis de consistência; definição de "corte suficiente para $Q$"; algoritmos para obter o corte mínimo suficiente.
]

#aberto([Conformidade entre superfícies como bissimulação])[
  Definir uma noção de bissimulação ou refinamento entre renderizações que garanta que nenhuma superfície promove estatutos nem nega por omissão.
][
  A conformidade entre superfícies é hoje verificada por testes; uma noção formal permitiria provas.
][
  O teorema de invariância de superfície (@teo-superficie) e a renderização honesta (@cap-apresentacao).
][
  Renderizações como transformações de estruturas rotuladas; preservação de rótulos de estatuto; testes derivados da definição formal.
]

#aberto([Afetação decidível])[
  Identificar aproximações conservadoras e sólidas da relação "a mudança $m$ afeta a afirmação $a$".
][
  A afetação decide que evidências precisam ser refeitas depois de uma mudança; a relação semântica geral é indecidível.
][
  A indecidibilidade decorre do teorema de Rice (@cap-reconciliacao); conjuntos de escrita e dependências dão aproximações.
][
  Análise de dependência estática; contratos tipados; testes de regressão como evidência; quantificação da taxa de falsos negativos.
]

#aberto([Colheita semântica como minimização de descrição])[
  Formalizar as operações da colheita semântica (acrescentar, subsumir, substituir, aposentar) como passos de minimização do comprimento de descrição de um corpo de lições, sem perda de poder preditivo.
][
  A colheita é a operação que impede o acúmulo de lições redundantes; hoje é guiada por julgamento.
][
  A colheita semântica (@cap-compactacao) e o princípio do comprimento mínimo de descrição (Apêndice C).
][
  Medidas de redundância entre lições; critérios de poder preditivo (lições que antecipam falhas); avaliação com consumidores frios.
]

#aberto([Estado vigente incremental])[
  Determinar a complexidade e os algoritmos incrementais para calcular o estado vigente de pendências em registros por acréscimo muito grandes.
][
  O estado vigente é derivado, não mutado (@def-estado-efetivo); com históricos longos, recalculá-lo integralmente é caro.
][
  O cálculo é uma junção expressável em Datalog (@cap-perspectiva).
][
  Manutenção incremental de visões @gupta1995; Datalog diferencial; limites inferiores para atualizações.
]

#aberto([Genericidade e não vazamento de domínio])[
  Dar critérios formais para declarar um substrato de contexto genérico, e investigar se existe um teorema de "não vazamento de domínio" — que o substrato não codifica conhecimento de nenhum domínio específico.
][
  A separação entre núcleo e domínio é a base da reutilização (@cap-arquitetura).
][
  A genericidade de regras sob renomeação (@prop-genericidade) e o teste por consumidor ortogonal (@ex-genericidade).
][
  Parametricidade; genericidade de consultas em bancos de dados; verificação por geração de domínios aleatórios.
]

#aberto([Hermeticidade de contexto])[
  Definir e verificar a hermeticidade de perspectivas: todo insumo semântico é declarado, e dependências ambientais implícitas são detectáveis.
][
  Perspectivas que dependem de estado ambiental não declarado não são reprodutíveis nem auditáveis.
][
  O determinismo (P2), o fechamento de dependências (@cap-durabilidade) e a analogia com construções herméticas.
][
  Execução em ambientes com dependências interceptadas; comparação de perspectivas sob perturbação do ambiente; relação com construções reprodutíveis @dolstra2004.
]

== Tempo e distribuição <sec-ab-tempo>

#aberto([Correlação sem junção retrospectiva])[
  Correlacionar entregas de contexto a ciclos de execução e consumidores com concessões concorrentes, sem relógio global e sem junção retrospectiva.
][
  Recibos de entrega mal correlacionados atribuem contexto ao ciclo errado (@cap-entrada).
][
  A regra "nunca junção retrospectiva" e a falha fechada com ação; relógios lógicos (Apêndice D).
][
  Identificadores de correlação propagados; relógios vetoriais por consumidor; prova de unicidade da correlação.
]

#aberto([Revisão atômica de ambientes compostos])[
  Determinar que propriedades de consistência são alcançáveis para observações de ambientes compostos, que são vetores de coordenadas sem revisão global, e a que custo.
][
  Decisões tomadas sobre observações inconsistentes de componentes podem ser incoerentes.
][
  O ambiente é vetor de coordenadas (@cap-ambiente); instantâneos consistentes distribuídos (Apêndice D).
][
  Adaptação do algoritmo de instantâneo distribuído @chandy1985; consistência causal; custo em latência.
]

#aberto([Resolução de identidade para materialização como serviço])[
  Especificar e provar correto um resolvedor que mapeia identidades a materializações locais sem confundir falha de descoberta com ausência e sem revincular silenciosamente.
][
  A resolução de localização é usada em quase toda operação; seus erros se propagam.
][
  A distinção entre falha de descoberta e ausência e a forense de recuperação (@cap-localizacao, @cap-durabilidade).
][
  Especificação formal com estados de resolução; verificação por modelo; testes de propriedade.
]

#aberto([Memória como crença])[
  Determinar quando uma memória pode ser promovida a conhecimento corrente sem nova prova, com um modelo de decaimento epistêmico por idade e confirmação por observação.
][
  Exigir prova nova para tudo é caro; aceitar memória como prova é perigoso.
][
  Memória não é prova (@cap-epistemologia); o frescor é relativo à pergunta (@cap-tempo).
][
  Modelos de confiança com decaimento; tempos de vida epistêmicos por classe de asserção; calibração empírica.
]

== Autoridade e federação <sec-ab-autoridade>

#aberto([Corroboração federada e confiança])[
  Desenvolver uma teoria da composição de atestações parciais de autoridades heterogêneas, com escopos e níveis de confiança.
][
  Decisões que atravessam domínios dependem de atestações compostas.
][
  A composição por supremo de informação e conjunção prudente, e a sobrevinculação (@cap-federacao); a lógica "fala por".
][
  Extensão da lógica de autenticação com escopos; cadeias de certificação; registros de transparência.
]

#aberto([Delegação atenuada entre agentes])[
  Modelar formalmente a transferência de trabalho com atenuação de autoridade (credenciais atenuáveis) e compará-la com a re-resolução completa no dono, quanto a segurança, latência e revogação. Como caso particular, modelar escopos temporários de perspectiva como capacidades atenuadas, com expiração e propósito, e provar que removê-los restaura exatamente a perspectiva anterior.
][
  Sistemas multiagentes precisam delegar sem ampliar autoridade (@inv-heranca-autoridade).
][
  A delegação em cadeia nunca amplia o escopo quando os tetos são interseccionados (@cap-handoff).
][
  Credenciais atenuáveis @birgisson2014; lógica de autorização; verificação formal da propriedade de restauração.
]

#aberto([Recuperação de raiz de confiança])[
  Projetar mecanismos gerais de recuperação após a perda de chaves de autoridade, sem autoridade central e sem a chave antiga.
][
  A perda de chaves é inevitável em operação longa; a recuperação mal projetada é um vetor de tomada de domínio.
][
  A gênese única e a rotação após perda (@cap-federacao).
][
  Esquemas de limiar; chaves de recuperação fora de linha; atrasos de segurança com contestação.
]

== Medição <sec-ab-medicao>

#aberto([Medida de suficiência])[
  Medir empiricamente se uma perspectiva é suficiente para um consumidor real quando o conjunto de perguntas é implícito.
][
  A suficiência é definida em relação a um conjunto de perguntas (@cap-modelo); consumidores reais não declaram suas perguntas.
][
  A suficiência formal e o ganho de informação por expansão (@cap-selecao).
][
  Suítes de perguntas-sonda; taxa de desconhecidos promovidos; número de expansões necessárias.
]

#aberto([Navegabilidade])[
  Definir e medir quanto um sistema de contexto permite a um consumidor frio chegar à próxima aresta correta.
][
  Um sistema de contexto deve orientar, não apenas informar.
][
  Os protocolos de teste frio (@cap-avaliacao).
][
  Comprimento de caminho até a aresta correta; expansões desnecessárias; erros por dimensão; bateria pré-registrada com sentinelas.
]

#aberto([Fronteira de custo e fidelidade])[
  Caracterizar a fronteira de Pareto entre tokens entregues e fidelidade (acurácia e honestidade epistêmica) para diferentes tipos de tarefa.
][
  O entregue não é o consumido (@cap-llm): posição e volume afetam o uso pelo modelo.
][
  A compressão governada e a seleção com orçamento (@cap-compressao, @cap-selecao).
][
  Experimentos com variação controlada de orçamento; separação entre tarefas de ação e de resposta.
]

#aberto([Degradação com o tamanho sob perspectivas estruturadas])[
  Medir se perspectivas pequenas e estruturadas reduzem a degradação de desempenho com o comprimento da entrada.
][
  A degradação com o comprimento é bem documentada para entradas não estruturadas @liu2024lost @hong2025.
][
  A apresentação estruturada e a ordenação por posição (@cap-apresentacao).
][
  Ver o problema 2 do @cap-avaliacao.
]

#aberto([Reprodutibilidade e conformidade com consumidores estocásticos])[
  Definir o que significa "mesmo contexto, mesma decisão" quando o consumidor é estocástico, e como obter garantias estatísticas de conformidade (taxa de violação com intervalo de confiança), e não apenas a existência de uma execução conforme.
][
  Auditoria e depuração supõem reprodutibilidade.
][
  A reprodutibilidade de perspectivas é exata sob as hipóteses do @teo-reproducao-passada — acervo por acréscimo, entradas registradas, nada compactado, versão da projeção preservada —; a do consumidor não é; a regra de três dá limites (@teo-regra-tres).
][
  Reprodutibilidade em distribuição; testes de hipótese sobre distribuições de decisões; registro do contexto exato.
]

#aberto([Coerência arquitetural])[
  Propor uma métrica operacional de coerência arquitetural de sistemas de contexto.
][
  O papel de supervisor responde pela coerência do sistema (@cap-orquestracao), mas não há medida.
][
  Os donos semânticos e a costura neutra (@cap-arquitetura).
][
  Número de donos por conceito; contagem de junções nas superfícies; divergências entre superfícies; evolução no tempo.
]

== Método e interação <sec-ab-metodo>

#aberto([Objetivo explícito e objetivo inferido])[
  Projetar superfícies para mudança de intenção sem adivinhação e estabelecer limites para a inferência de objetivos a partir de diálogo.
][
  O objetivo faz parte da coordenada; inferi-lo errado muda toda a perspectiva.
][
  O objetivo como componente da coordenada, com proveniência (@cap-relevancia).
][
  Confirmação explícita de mudanças de objetivo; medida de custo de confirmações; estudos com usuários.
]

#aberto([Promoção a protocolo])[
  Formalizar o critério de "necessidade genuína de interoperabilidade" para promover modelos internos a protocolo.
][
  Protocolos prematuros congelam detalhes; protocolos tardios impedem a interoperabilidade.
][
  O princípio do protocolo mínimo (@pri-protocolo-minimo).
][
  Estudos de caso de protocolos; métricas de estabilidade de interfaces.
]

#aberto([Validade do uso reflexivo])[
  Estimar a validade externa da evidência obtida pelo uso do próprio sistema.
][
  Grande parte da teoria deste livro foi descoberta por uso reflexivo (@cap-metodo).
][
  Os vieses identificados e as salvaguardas propostas (@pri-reflexivo-externo).
][
  Comparação com consumidores de outros domínios; consumidor congelado; estudos de replicação.
]

#aberto([Ressonância de linhagem])[
  Testar se princípios que reaparecem independentemente depois de mudanças radicais de arquitetura indicam invariantes do domínio.
][
  Se verdadeira, a hipótese daria um método para descobrir invariantes.
][
  O registro da hipótese como não canonizada (@caso-ressonancia).
][
  Definir "reaparecimento independente"; prever quais princípios reapareceriam e quais não; estudos históricos de outros sistemas.
]

#aberto([Lentes disciplinares emergentes])[
  Verificar empiricamente se gerenciamento, engenharia, design e administração de contexto emergem como agrupamentos naturais de operações em traços de trabalho real.
][
  A organização deste livro em quatro disciplinas é uma hipótese, não um resultado.
][
  As disciplinas foram definidas por suas perguntas (@cap-modelo).
][
  Agrupamento de traços de operação; análise de coocorrência; comparação com a classificação proposta.
]

#quadro[
  - Seleção: garantias sob estatutos e omissões, monotonicidade em autoridade e refinamento, antecipação versus demanda, compressão por endereçamento.
  - Lógica: ordem de força, escopo da negação, atualidade ternária, bissimulação de renderizações, afetação, colheita, estado vigente, genericidade, hermeticidade.
  - Tempo e distribuição: correlação, ambientes compostos, resolução de identidade, memória como crença.
  - Autoridade: corroboração federada, delegação atenuada, recuperação de raiz.
  - Medição: suficiência, navegabilidade, custo e fidelidade, degradação, reprodutibilidade, coerência.
  - Método: objetivos, protocolo, uso reflexivo, ressonância, disciplinas.
]

#notas[
  Os problemas deste capítulo foram coletados ao longo da redação do livro e da pesquisa que o originou. Alguns têm raízes em problemas clássicos — aproximação submodular, manutenção de visões, consistência distribuída, lógica de autenticação —, e o progresso neles provavelmente virá da adaptação de resultados existentes. Outros são específicos de sistemas com consumidores de linguagem estocásticos e exigirão experimentos que ainda não foram feitos. Convidamos o leitor a tratar este capítulo como um programa de pesquisa.
]
