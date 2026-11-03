#import "/modelo/estilo.typ": *
#set heading(numbering: none)
#show heading.where(level: 2): set heading(outlined: false)

#heading(numbering: none)[Prefácio] <prefacio>

Este livro trata de uma pergunta que, até pouco tempo atrás, não precisava de um livro: _o que um agente de inteligência artificial deve ver, a cada passo, para agir corretamente?_ Enquanto modelos de linguagem eram usados para responder perguntas isoladas, a pergunta se resolvia com uma boa instrução e alguns exemplos. Quando passaram a trabalhar por horas, em ambientes reais, com ferramentas, memória e outros agentes, ela se tornou o problema central de engenharia desses sistemas — e um problema para o qual a prática corrente oferece técnicas, mas não uma teoria.

O livro propõe essa teoria. Ele trata o contexto de agentes como objeto de quatro disciplinas — gerenciamento, engenharia, design e administração de contexto — e as desenvolve com o mesmo tipo de tratamento que se espera de um texto universitário de computação: definições precisas, invariantes, teoremas com prova, algoritmos em pseudocódigo com análise, estudos de caso, exercícios e problemas, notas históricas e bibliográficas.

== A quem se destina

O livro foi escrito para três públicos.

/ Estudantes: alunos de graduação e pós-graduação em computação e áreas afins, num curso sobre agentes de inteligência artificial, engenharia de sistemas com modelos de linguagem ou sistemas de informação. Os Capítulos 1 a 4 não supõem mais do que familiaridade com programação e matemática discreta elementar; os apêndices revisam o necessário.

/ Engenheiros: profissionais que constroem sistemas de agentes e precisam de vocabulário, critérios e técnicas para decidir o que entra no contexto, como verificar que está certo e como operar esses sistemas com segurança.

/ Pesquisadores: interessados nos fundamentos — a epistemologia do contexto, a teoria da seleção sob orçamento, a lógica da autoridade, a avaliação com consumidores estocásticos — e nos problemas em aberto reunidos no @cap-abertos.

== Organização

O livro tem oito partes. A *Parte I* apresenta o problema, os modelos de linguagem como processadores de contexto, o modelo formal que serve de espinha ao livro e seus fundamentos epistemológicos. As Partes II a V correspondem às quatro disciplinas: *gerenciamento* (identidade, domínios, localização, tempo, proveniência, durabilidade, memória), *engenharia* (seleção, conjunto de trabalho, o núcleo de projeção, fronteira, compressão, compactação), *design* (relevância e divulgação, apresentação, entrada) e *administração* (autoridade, portões, o ciclo da ação, unidades de trabalho, reconciliação, higiene). A *Parte VI* leva a teoria a ambientes reais, execução, federação entre domínios soberanos e segurança. A *Parte VII* trata de sistemas com vários agentes — orquestração, transferência, arquitetura e observabilidade. A *Parte VIII* trata de avaliação, do método empírico da área e dos problemas em aberto.

Oito apêndices completam o texto: matemática discreta (A), lógica (B), probabilidade, informação e otimização (C), sistemas distribuídos (D), o catálogo de invariantes (E), o índice de algoritmos e procedimentos (F), modelos de pacotes (G) e um glossário português–inglês (H).

#figure(
  diagram(
    spacing: (7mm, 7mm),
    node-stroke: 0.5pt + cor.primaria, node-fill: cor.tinta-def, node-corner-radius: 2pt,
    node((1.5, 0), text(size: 8pt)[I. Fundamentos], name: <i>),
    node((0, 1), text(size: 8pt)[II. Gerenciamento], name: <ii>),
    node((1, 1), text(size: 8pt)[III. Engenharia], name: <iii>),
    node((2, 1), text(size: 8pt)[IV. Design], name: <iv>),
    node((3, 1), text(size: 8pt)[V. Administração], name: <v>),
    node((0.5, 2), text(size: 8pt)[VI. Ambientes, federação\ e segurança], name: <vi>),
    node((2.5, 2), text(size: 8pt)[VII. Sistemas\ de agentes], name: <vii>),
    node((1.5, 3), text(size: 8pt)[VIII. Avaliação e método], name: <viii>),
    edge(<i>, <ii>, "-|>"), edge(<i>, <iii>, "-|>"), edge(<i>, <iv>, "-|>"), edge(<i>, <v>, "-|>"),
    edge(<ii>, <iii>, "-|>"), edge(<iii>, <iv>, "-|>"),
    edge(<ii>, <vi>, "-|>"), edge(<v>, <vi>, "-|>"),
    edge(<iii>, <vii>, "-|>"), edge(<v>, <vii>, "-|>"),
    edge(<vi>, <viii>, "-|>"), edge(<vii>, <viii>, "-|>"),
  ),
  caption: [Dependências entre as partes. Uma seta de $X$ para $Y$ indica que $Y$ usa conceitos introduzidos em $X$.],
) <fig-dependencias>

== Trilhas de leitura

/ Curso introdutório (um semestre): Capítulos 1 a 4; da Parte II, identidade, tempo e proveniência; da Parte III, seleção, conjunto de trabalho e compactação; da Parte IV, apresentação; da Parte V, autoridade, portões e ciclo da ação; da Parte VII, transferência. Omitir as seções marcadas com ★.

/ Curso avançado ou de pós-graduação: o livro inteiro, com ênfase nas seções ★, nos apêndices A a D e nos problemas de fim de capítulo; o @cap-abertos fornece temas de projeto e de pesquisa.

/ Engenheiros de sistemas de agentes: Capítulos 1 a 3; Partes III, IV e V; Capítulos sobre segurança, orquestração, transferência, arquitetura e observabilidade; Apêndices E, F e G como referência.

/ Responsáveis pela operação de sistemas de agentes: Capítulos 1 e 3; Parte V; Capítulos sobre ambientes, federação, segurança, observabilidade e avaliação.

== Convenções

=== Ambientes formais

O texto usa ambientes numerados por capítulo, com um único contador compartilhado — "Definição 3.4" é o quarto enunciado formal do Capítulo 3, seja ele definição, teorema ou invariante. _Definições_ introduzem termos, que aparecem em itálico e são registrados no índice remissivo. _Teoremas_, _lemas_, _proposições_ e _corolários_ vêm acompanhados de prova. _Invariantes_ são propriedades que um sistema de contexto bem projetado preserva sempre; _princípios_ são recomendações de projeto justificadas no texto; _antipadrões_ são soluções tentadoras e erradas, documentadas para serem reconhecidas. _Estudos de caso_ relatam situações reais, anonimizadas e generalizadas.

Muitos invariantes têm a forma de uma _distinção_ entre duas coisas que costumam ser confundidas, escrita em forma compacta como #neq[MEMÓRIA][PROVA]. A distinção não afirma que as duas coisas nunca coincidem, mas que a coincidência não pode ser suposta.

=== Notação

#figure(
  tabela(
    colunas: (34%, 1fr, 21%),
    cabecalho: ([Símbolo], [Significado], [Onde]),
    [$Sigma$, $Sigma_t$], [acervo de asserções (no instante $t$)], [@cap-modelo],
    [$a$, $sigma(a)$], [asserção e seu estatuto epistêmico], [@cap-modelo],
    [#est[provado], #est[refutado], \ #est[desconhecido], #est[conflitante]], [estatutos epistêmicos (bireticulado de Belnap)], [@cap-epistemologia],
    [$scripts(lt.eq)_i$, $scripts(lt.eq)_t$], [ordens de informação e de verdade], [Apêndice B],
    [$kappa = (u, ell, o, tau, t, alpha)$], [coordenada: consumidor, locus, objetivo, transição, instante, teto de autoridade], [@cap-modelo],
    [$"apl"$], [aplicabilidade, com valores em ${sans(V), sans(F), sans(D)}$], [@cap-modelo],
    [$pi$], [projeção], [@cap-modelo, @cap-perspectiva],
    [$P = (F, R, U, X, Phi, mu)$], [perspectiva: fatos, relações, desconhecidos, exclusões, fronteira, metadados (inclui o traço $theta$)], [@cap-modelo],
    [$rho$], [renderização], [@cap-apresentacao],
    [$W$, $W_"ef"$], [janela de contexto e janela efetiva], [@cap-llm],
    [$alpha$], [teto de autoridade da coordenada], [@cap-autoridade],
    [$sigma_(Sigma, alpha)$], [estatuto sustentado sobre o legível], [@cap-modelo],
    [$a -> b$], [aconteceu-antes (ordem causal)], [@cap-tempo],
  ),
  caption: [Principais símbolos do livro.],
) <tab-notacao>

As letras gregas da tabela — $Sigma$, $kappa$, $pi$, $rho$, $alpha$, $sigma$, $Phi$, $mu$ — têm, em todo o livro, apenas o sentido indicado; outros símbolos de uso local são declarados onde aparecem. Os valores $sans(V)$, $sans(F)$ e $sans(D)$ são os da lógica de três valores de Kleene (verdadeiro, falso, indeterminado), usados para aplicabilidade e para pré-condições de portões; os estatutos epistêmicos aparecem em versalete, e os demais estados operacionais, em _itálico sem serifa_.

=== Pseudocódigo

Os algoritmos seguem as convenções de #ct(<cormen2022>), adaptadas ao português. Os nomes de procedimentos aparecem em versalete com hífens (#proc[Projeta], #proc[Expande-Fronteira]); as palavras-chave aparecem em negrito (#kw[se], #kw[então], #kw[senão], #kw[para cada], #kw[enquanto], #kw[faça], #kw[devolva]); a indentação indica a estrutura de blocos; e comentários são introduzidos por ▷. A atribuição é escrita $x <- e$. Os algoritmos descrevem procedimentos, não implementações: operações como "observe o estado do recurso" ou "registre a evidência" denotam chamadas a serviços cujo custo e cujas falhas são discutidos no texto.

=== Exercícios, problemas e notas

Cada seção termina com exercícios, que verificam a compreensão e treinam a aplicação dos conceitos; o número "3.2-1" designa o primeiro exercício da Seção 3.2. Cada capítulo termina com problemas mais longos, divididos em partes, e com notas que situam o conteúdo na literatura e indicam as origens empíricas das ideias. Exercícios e seções mais difíceis são marcados com ★.

== Sobre a origem do material

A teoria deste livro foi desenvolvida a partir de trabalho de pesquisa e engenharia sobre sistemas de contexto para agentes. Os estudos de caso generalizam falhas recorrentes nesse tipo de sistema: não se referem a nenhum produto, organização ou pessoa, mas a situações que qualquer equipe que construa sistemas de agentes provavelmente encontrará. Quando uma ideia tem antecedentes na literatura — e muitas têm, em bancos de dados, sistemas distribuídos, segurança, lógica e ciências cognitivas —, as notas de fim de capítulo os indicam; quando é proposta do livro, as notas o dizem.

O livro também reflete um compromisso metodológico descrito no @cap-metodo: nenhuma abstração foi incluída sem um consumidor que dela precisasse, e as hipóteses que ainda não têm objeto matemático definido nem experimento capaz de refutá-las aparecem como problemas em aberto, não como resultados.

== Agradecimentos

Este livro deve muito às inúmeras sessões de trabalho — com colegas humanos e com agentes — em que as distinções aqui apresentadas foram descobertas, frequentemente depois de terem sido violadas. Erros que permaneçam são de responsabilidade do autor; correções e sugestões são bem-vindas.
