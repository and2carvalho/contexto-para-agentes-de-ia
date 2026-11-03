#import "/modelo/estilo.typ": *

= Durabilidade, retenção e reprodutibilidade <cap-durabilidade>

#epigrafe[O resumo criptográfico numa decisão não reconstrói a fonte.]

"Está salvo" é uma das frases mais tranquilizadoras e menos informativas da engenharia. Salvo onde? Recuperável por quem? Ligado a quê? Um sistema de contexto faz afirmações que dependem de artefatos — revisões aceitas, binários implantados, evidências de testes, configurações de composição — e essas afirmações só são verificáveis enquanto os artefatos de que dependem puderem ser recuperados exatamente. A durabilidade é, portanto, uma condição de verdade: uma afirmação cujo suporte se perdeu deixa de ser prova e passa a ser memória.

Este capítulo decompõe a durabilidade e mostra como garanti-la. A @sec-dur-dimensoes apresenta as cinco dimensões da durabilidade. A @sec-dur-retencao distingue retenção, aceitação e promoção. A @sec-dur-fechamento trata do fechamento de dependências entre recursos e prova o lema de reconstrução. A @sec-dur-par trata da determinação do par de linhas de base entre consumidor e dependência. A @sec-dur-forense apresenta a forense de recuperação. A @sec-dur-desmaterializacao trata da desmaterialização segura e da preservação em três camadas.


#observacao(titulo: [Durabilidade, aqui e em bancos de dados])[
  Em bancos de dados, _durabilidade_ é a garantia de que uma transação confirmada sobrevive a falhas — o "D" das propriedades ACID. Aqui o termo é mais amplo: abrange, além da sobrevivência dos bytes, a capacidade de recuperá-los, de ligá-los às afirmações que sustentam e de reconstruir o que deles depende. A obrigação legal de _apagar_ dados é tratada no @cap-higiene.
]

== As cinco dimensões da durabilidade <sec-dur-dimensoes>

#definicao(titulo: [Vetor de durabilidade])[
  A _durabilidade_ de um artefato, em relação a uma pergunta, é um vetor de cinco componentes, cada uma com estatuto epistêmico:
  + _retenção física_: os bytes existem em algum armazenamento;
  + _identidade_: o artefato é identificado de forma estável (por exemplo, por resumo de conteúdo e por identificador lógico);
  + _recuperabilidade canônica_: o sistema sabe recuperar o artefato por um caminho canônico, sem busca ad hoc;
  + _vínculo semântico_: o artefato está ligado às afirmações que dele dependem (e elas a ele);
  + _locus soberano_: o artefato vive (ou está retido) sob a autoridade do domínio que precisa dele.
  O artefato é _durável para a pergunta_ quando todas as componentes relevantes para ela são #est[provado].
] <def-vetor-durabilidade>

#invariante(titulo: [Retido não é recuperável])[
  Bytes retidos em algum lugar não são, por isso, recuperáveis pelo sistema. Um identificador de evidência conhecido não implica conteúdo resolvível; um caminho conhecido por quem escreveu não é resolvível por um consumidor frio.
] <inv-retido-recuperavel>

#invariante(titulo: [A governança retém referências; o armazenamento retém bytes])[
  Registros de governança — decisões, unidades seladas, aceitações — guardam _referências_ a artefatos, não os artefatos. Dizer que "a governança reteve a fonte" é um erro de nomenclatura que esconde a ausência de retenção real.
] <inv-governanca-referencias>

#exercicios[
  + Avalie o vetor de durabilidade de: (a) uma revisão de código presente apenas numa cópia local não publicada; (b) um binário cujo resumo está registrado numa decisão, mas que foi apagado do servidor de artefatos; (c) um relatório de testes anexado a uma evidência e guardado num armazenamento por conteúdo.
  + Para a pergunta "posso reproduzir a compilação da versão aceita?", quais componentes do vetor são relevantes?
  + Para um documento de requisitos mantido num serviço de edição colaborativa, avalie cada componente do vetor de durabilidade e indique qual dimensão é mais frágil.
]

== Retenção, aceitação e promoção <sec-dur-retencao>

#invariante(titulo: [Retenção não é aceitação nem promoção])[
  Reter bytes preserva-os para uso futuro; não os endossa como corretos (aceitação) nem os publica como linha de base (promoção). Referências de retenção não são promocionais.
] <inv-retencao-aceitacao>

#antipadrao(titulo: [Promover para reter])[
  Para garantir que um trabalho não se perca, alguém o integra à linha principal ou o marca como versão. O trabalho, que não foi avaliado, passa a parecer aceito. A forma correta de preservar é criar uma referência de retenção explicitamente não promocional.
] <anti-promover-reter>

O inverso também é perigoso: aceitar sem reter.

#invariante(titulo: [Aceitação exige raiz de retenção])[
  Uma revisão aceita cujo conteúdo não esteja retido de forma durável é uma afirmação irreconstruível: o resumo criptográfico registrado na decisão identifica o conteúdo, mas não o recupera. Toda aceitação deve apontar para uma _raiz de retenção_ — uma referência, num armazenamento durável, que garanta que os objetos da revisão não serão coletados.
] <inv-aceitacao-retencao>

A distinção entre _identificar_ e _recuperar_ é a mesma que separa um resumo criptográfico de seu conteúdo: o resumo permite verificar que um conteúdo apresentado é o certo, mas não permite obtê-lo. Sistemas de controle de versão coletam periodicamente objetos não alcançáveis por nenhuma referência; uma revisão aceita que só é alcançável a partir de um ramo local apagado será, cedo ou tarde, irrecuperável.

#exercicios[
  + Descreva a sequência de eventos pela qual uma revisão aceita, registrada numa decisão, se torna irrecuperável em um sistema de controle de versão distribuído.
  + Proponha um nome e uma convenção para referências de retenção não promocionais, e explique como evitar que sejam confundidas com ramos de trabalho.
  + Explique por que "promover para reter" (@anti-promover-reter) é especialmente perigoso quando agentes leem a linha principal como "o que foi aceito". Dê um cenário de falha.
]

== Fechamento de dependências <sec-dur-fechamento>

Afirmações frequentemente atravessam recursos: "a revisão $r$ do serviço passa nos testes" depende da revisão da biblioteca que o serviço usou, da versão do compilador, da configuração do ambiente de testes. Para que a afirmação seja reconstruível, cada uma dessas dependências precisa ser _fechada_.

#definicao(titulo: [Dependência fechada])[
  Uma dependência de uma afirmação $a$ sobre um recurso $d$ é _fechada_ se é registrada por uma coordenada exata adequada ao tipo de $d$ — revisão para fonte, versão e resumo para pacote, resumo e proveniência de construção para binário, resumo canônico para composição — e se essa coordenada tem uma raiz de retenção durável. O _fechamento_ de $a$ é o conjunto de coordenadas exatas de que $a$ depende, transitivamente.
] <def-dependencia-fechada>

#corolario(titulo: [Reconstrução por fechamento])[
  Se todas as arestas do grafo de dependências de uma afirmação $a$ são fechadas, as atividades que derivam $a$ de suas dependências são determinísticas, herméticas e registradas, e o grafo de dependências é acíclico — ou cada componente fortemente conexa é construída como uma unidade —, então $a$ é reconstruível: pode ser verificada novamente obtendo-se exatamente as mesmas entradas.
] <lem-reconstrucao>

#prova[
  As folhas são coordenadas exatas com raiz de retenção, portanto recuperáveis exatamente; as hipóteses restantes são as do @teo-reprodutibilidade, aplicado ao grafo de dependências (condensado, se houver ciclos, em suas componentes fortemente conexas).
]

O corolário é a versão, para dependências entre recursos, do @teo-reprodutibilidade. A hipótese de aciclicidade não é automática: pacotes mutuamente dependentes e compiladores que se compilam a si mesmos criam ciclos, tratados como unidades. Sua hipótese de fechamento é violada de maneira típica por _dependências por caminho_: quando um projeto usa outro "pelo diretório vizinho", a dependência não tem coordenada exata — ela depende do que estiver naquele diretório no momento da construção.

#proposicao(titulo: [Dependências por caminho não são reprodutíveis])[
  Se um consumidor depende de um recurso por caminho, então duas construções da mesma revisão do consumidor podem produzir resultados diferentes. Se, ao contrário, a dependência é fechada, duas construções da mesma revisão do consumidor, com atividades determinísticas, produzem o mesmo resultado.
] <prop-dependencia-caminho>

#prova[
  Com dependência por caminho, a entrada efetiva da construção inclui o conteúdo do diretório vizinho, que não é função da revisão do consumidor; basta alterá-lo entre as duas construções para obter resultados diferentes. Com dependência fechada, todas as entradas são função da revisão do consumidor (que registra as coordenadas exatas), e atividades determinísticas sobre as mesmas entradas produzem o mesmo resultado.
]

#invariante(titulo: [Mesma revisão, vizinho diferente, construção diferente])[
  Um arquivo de travamento de versões de pacotes não trava fontes de outros repositórios usadas por caminho. A mesma revisão de um consumidor, construída ao lado de materializações diferentes de suas dependências, é uma construção efetivamente diferente — e um agente que valida "a mesma revisão" em máquinas diferentes pode estar validando coisas diferentes.
] <inv-vizinho-diferente>

Sistemas de construção _herméticos_, que derivam todas as entradas de uma construção de coordenadas declaradas e retidas, são a resposta de engenharia a esse problema @dolstra2004.

#exercicios[
  + Identifique, num projeto que você conhece, uma dependência por caminho e proponha como fechá-la.
  + Mostre que a hipótese de atividades determinísticas é necessária no @lem-reconstrucao, com um exemplo de construção não determinística.
  + #avancado Formalize o fechamento de dependências como fecho transitivo num grafo de dependências tipado, e mostre que verificar se uma coordenada é fechada pode ser feito em tempo linear no tamanho do grafo.
]

== O par de linhas de base <sec-dur-par>

Quando um consumidor e uma dependência evoluem em repositórios separados, a pergunta "esta revisão do consumidor funciona?" só tem sentido junto com a pergunta "com qual revisão da dependência?".

#estudo-de-caso(titulo: [O build que dependia do vizinho])[
  Uma revisão de um consumidor passava na validação numa máquina e falhava noutra. Ambas tinham a mesma revisão do consumidor. A diferença estava num repositório irmão, usado por caminho, cuja revisão era diferente nas duas máquinas e desconhecida nos registros. Três hipóteses eram plausíveis: deriva da materialização vizinha, deriva de interface na dependência, ou diferença na fronteira de validação. A tentação foi "corrigir" a dependência atual até o consumidor antigo compilar — alterando um domínio soberano para satisfazer uma combinação que nunca tinha sido aceita. O procedimento correto foi determinar o par.
] <caso-vizinho>

#algoritmo("Determina-Par", params: $c, r$, legenda: [Determinação do par de linhas de base entre um consumidor $c$ na revisão $r$ e sua dependência.])[
  + $d <- $ identidade da dependência de $c$ #h(1fr) ▷ identidade, não caminho
  + $r_d <- $ revisão de $d$ pretendida para $(c, r)$ #h(1fr) ▷ por proveniência, travamento ou aceitação
  + #kw[se] $r_d = bot$ #kw[então] #kw[devolva] #estado[par desconhecido]
  + valide $(c @ r, d @ r_d)$ numa instalação limpa, com repetições suficientes para descartar falhas intermitentes
  + #kw[se] passa #kw[e] a fronteira de validação é a mesma da aceitação original #kw[então] #kw[devolva] (par válido; a materialização vizinha atual era a coordenada errada)
  + #kw[se] passa #kw[e] a fronteira de validação difere #kw[então] #kw[devolva] (par válido sob a validação atual; a diferença de fronteira é um desconhecido explicado)
  + #kw[senão] #kw[devolva] (defeito real no par; decidir, com evidência, qual lado é defeituoso)
] <alg-determina-par>

#antipadrao(titulo: [Corrigir o soberano para satisfazer o consumidor])[
  Ao encontrar uma incompatibilidade, altera-se a dependência — um domínio com seu próprio dono e sua própria linha de base — até que um consumidor antigo volte a funcionar. A incompatibilidade pode nem existir no par correto; e, se existir, decidir qual lado deve mudar é uma decisão governada de dois donos.
] <anti-corrigir-soberano>

#exercicios[
  + Aplique o @alg-determina-par ao @caso-vizinho, supondo que o registro de proveniência da validação original contém a revisão da dependência.
  + Que registro, feito no momento da aceitação do consumidor, tornaria o passo 2 do algoritmo trivial?
  + Descreva o antipadrão "corrigir o soberano para satisfazer o consumidor" com um exemplo de biblioteca compartilhada, e proponha a ação correta.
]

== Forense de recuperação <sec-dur-forense>

Quando algo parece perdido — uma revisão, um trabalho, um artefato —, a tentação é concluir a perda e reimplementar. O @inv-descoberta-ausencia já advertiu: falha de descoberta não é ausência. A forense de recuperação torna isso operacional.

#algoritmo("Forense-de-Recuperação", params: $x, b$, legenda: [Busca limitada por um artefato $x$ antes de qualquer conclusão de perda, em ordem aproximada de custo crescente, sob um orçamento $b$ de esforço.])[
  + procure referências alcançáveis a $x$ em todas as materializações conhecidas
  + consulte registros de movimentação de referências (históricos de ponteiros)
  + procure objetos não alcançáveis ainda presentes nos armazenamentos
  + procure em outras cópias e armazenamentos alternativos conhecidos
  + inspecione metadados de cópias de trabalho (inclusive removidas)
  + consulte cópias de segurança e instantâneos
  + consulte o armazenamento por conteúdo e estados retidos de experimentos
  + procure referências não enumeradas e outros loci legítimos, enquanto o orçamento $b$ não se esgotar
  + classifique o resultado por dimensão do vetor de durabilidade
  + #kw[se] nada encontrado #kw[então] registre a decisão governada de perda operacional, com o escopo da busca
] <alg-forense>

#estudo-de-caso(titulo: [A perda que era falha de descoberta])[
  O titular abriu uma cópia antiga de um projeto, aninhada dentro de outro diretório, e não encontrou o trabalho das últimas semanas. Parecia uma divergência grave e uma perda. A forense mostrou que a história era linear e que nada se perdera: o trabalho recente existia noutra linhagem, materializada noutro lugar. A falha era de _descoberta_ — e de ausência de garantia de retenção remota. O diagnóstico sistêmico foi mais incômodo que qualquer perda: múltiplas linhagens, múltiplos loci, aceitação de revisões apenas locais e resolução de "qual projeto" pelo diretório corrente faziam com que o titular não soubesse qual produto estava executando.
] <caso-tres-produtos>

#exercicios[
  + Por que a forense deve seguir uma ordem de custo crescente? Dê um caso em que inverter a ordem desperdiça muito esforço.
  + Escreva o registro de decisão de perda operacional para um artefato não encontrado, incluindo o escopo da busca e as condições de reabertura.
  + Aplique o @alg-forense a um artefato de construção que não aparece no armazém de artefatos. Escreva os passos em ordem de custo crescente e o critério de parada.
]

== Desmaterialização segura e preservação em três camadas <sec-dur-desmaterializacao>

Remover materializações — cópias de trabalho, ramos locais, diretórios temporários — é necessário para manter o ambiente gerenciável. O @cap-higiene tratará da classificação e da ordem; aqui registramos os critérios de durabilidade.

#definicao(titulo: [Critérios de remoção segura])[
  Uma materialização pode ser removida quando, conjuntamente: (i) não contém bytes únicos não retidos; (ii) seu conteúdo está integrado à linha canônica ou retido numa raiz de retenção; (iii) nenhuma afirmação ou consumidor depende dela por caminho; e (iv) a remoção está autorizada.
] <def-remocao-segura>

#definicao(titulo: [Preservação em três camadas])[
  O trabalho de uma unidade está _preservado_ quando está garantido em três camadas: _governança_ (os registros — decisões, evidências, selo — referenciam o resultado), _controle de versão_ (a fonte está alcançável a partir de referências duráveis) e _retenção_ (os bytes que precisam sobreviver, inclusive artefatos construídos, têm raiz de retenção).
] <def-tres-camadas>

#invariante(titulo: [Marcador apagado não é identidade perdida])[
  Se o marcador local de identidade de um domínio é apagado, a identidade e a história do domínio não se perdem — elas vivem no registro e na história. O correto não é fingir que nada aconteceu, nem recriar uma identidade nova, mas separar identidade e história, marcador local e localizador, e restaurar o marcador a partir do registro.
] <inv-marcador-apagado>

#exercicios[
  + Aplique os critérios da @def-remocao-segura a uma cópia de trabalho com alterações não registradas cujo ramo já foi integrado.
  + Por que a preservação precisa das três camadas? Dê um exemplo de falha quando falta cada uma delas.
  + Ordene, por irreversibilidade, as operações: apagar uma cópia de trabalho; remover uma referência de ramo; coletar objetos inalcançáveis; apagar um registro do acervo. Justifique e relacione com a ordem de desmaterialização segura.
]

#quadro[
  - Durabilidade tem cinco dimensões: retenção física, identidade, recuperabilidade canônica, vínculo semântico, locus soberano.
  - Retido não é recuperável; a governança retém referências, o armazenamento retém bytes.
  - Retenção não é aceitação nem promoção; aceitação exige raiz de retenção.
  - Dependências fechadas tornam afirmações reconstruíveis (@lem-reconstrucao); dependências por caminho não são reprodutíveis.
  - Determine o par de linhas de base antes de "corrigir" um domínio soberano.
  - Forense de recuperação antes de concluir perda; perda é decisão governada com escopo.
  - Remova só sob critérios conjuntos; preserve em governança, controle de versão e retenção.
]

#problemas[
  #problema([Hermeticidade de contexto])[
    Uma perspectiva calculada para um agente é _hermética_ se é função apenas de entradas declaradas e retidas.
    + Formule a hermeticidade de perspectivas por analogia com construções herméticas.
    + Identifique três fontes típicas de não hermeticidade em projeções reais (por exemplo, leitura do diretório corrente, variáveis de ambiente, índices não versionados).
    + Proponha um teste que detecte não hermeticidade comparando projeções calculadas em ambientes diferentes.
  ]
  #problema([Política de retenção])[
    Projete uma política de retenção para uma organização em que agentes produzem dezenas de candidatos por dia.
    + Defina o que deve ter raiz de retenção permanente, temporária ou nenhuma.
    + Estime o custo de armazenamento e proponha uma coleta segura do que não é necessário.
    + Mostre que a política preserva a reconstrução exata de todas as decisões aceitas.
  ]
  #problema([Fechamento transitivo e custo])[
    O fechamento de uma afirmação pode ser grande (todas as dependências transitivas).
    + Analise o custo de registrar e reter o fechamento completo.
    + Proponha uma representação compartilhada (por exemplo, por resumos de árvores de dependências) e mostre que ela reduz o custo sem perder reconstrução.
    + Relacione com árvores de Merkle @merkle1987.
  ]
]

#notas[
  A distinção entre identificar e recuperar conteúdo é central em sistemas endereçados por conteúdo @merkle1987 @chacon2014. Construções herméticas e reprodutíveis, em que cada artefato é função de entradas declaradas, foram sistematizadas por sistemas de implantação puramente funcionais @dolstra2004; a verificação de cadeias de suprimento de software @torresarias2019 e a resistência de sistemas de atualização ao comprometimento de chaves @samuel2010 tratam de garantir que o artefato recuperado é o artefato aceito. A noção de proveniência fechada liga este capítulo ao @cap-proveniencia, e a condição de reconstrução exata, ao @cap-tempo.

  O vetor de durabilidade, o par de linhas de base e a forense de recuperação são propostas deste livro, motivadas por duas falhas recorrentes: afirmações aceitas que apontam para revisões que só existem localmente, e trabalho "perdido" que se revela apenas mal localizado.
]
