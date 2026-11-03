#import "/modelo/estilo.typ": *

= Algoritmos e procedimentos <ap-procedimentos>

Este apêndice reúne, para consulta, os algoritmos e procedimentos do livro, na ordem em que aparecem, com a finalidade de cada um e a remissão ao texto onde são apresentados e analisados. A @sec-ap-convencoes-pseudo recapitula as convenções de pseudocódigo; a @sec-ap-familias agrupa os procedimentos por finalidade; e a @sec-ap-lista traz a lista completa.

== Convenções de pseudocódigo <sec-ap-convencoes-pseudo>

Os algoritmos são escritos em pseudocódigo no estilo de #ct(<cormen2022>):

- nomes de procedimentos em versalete, com palavras ligadas por hífen: #proc[Projeta], #proc[Verifica-Retorno];
- palavras-chave em negrito: #kw[se], #kw[então], #kw[senão], #kw[para cada], #kw[enquanto], #kw[repita], #kw[faça], #kw[devolva];
- blocos indicados por indentação; linhas numeradas para referência;
- atribuição com $<-$; comentários introduzidos por ▷;
- chamadas a serviços externos — observar, registrar, autorizar — escritas em linguagem natural, com custo e modos de falha discutidos no texto.

Três propriedades recorrentes são indicadas no texto, quando aplicáveis: se o algoritmo é _somente leitura_ (não altera o acervo nem o ambiente); se ele _falha fechado_ (na dúvida, não age); e se ele é _idempotente_ (repeti-lo não produz efeitos adicionais). Os algoritmos centrais — de projeção, seleção, verificação, mutação governada, reconciliação, afetação, poda e atualização — são acompanhados de uma análise de correção e custo, no padrão de invariante, término e complexidade; os demais são esquemas de procedimento, cuja correção depende de serviços externos (observar, autorizar, executar) especificados no texto.

== Famílias de procedimentos <sec-ap-familias>

#figure(
  tabela(
    colunas: (auto, 1fr),
    cabecalho: ([Família], [Finalidade e capítulos principais]),
    [Observação e resolução], [descobrir onde estão os recursos, verificar identidades e classificar relações e diretórios (Parte II)],
    [Tempo e evidência], [estabelecer linhas de base, avaliar atualidade, registrar e verificar evidências (Parte II)],
    [Seleção e projeção], [escolher sob orçamento, compor perspectivas como ponto fixo, preparar turnos, expandir a fronteira (Parte III)],
    [Compactação e continuidade], [compactar por reprojeção, gerar sementes e registros de continuação (Parte III)],
    [Apresentação e entrada], [renderizar honestamente, inicializar e orientar consumidores (Parte IV)],
    [Governança e ação], [avaliar portões, executar o laço de mutação governada, reconciliar, desmaterializar com segurança (Parte V)],
    [Execução e federação], [convergir execuções, vincular domínios, autenticar e autorizar principais (Parte VI)],
    [Coordenação de agentes], [orquestrar, transferir trabalho, verificar retornos, comparar perspectivas (Parte VII)],
    [Avaliação], [testes frios pré-registrados e testes diferenciais (Parte VIII)],
  ),
  caption: [Famílias de procedimentos do livro.],
) <tab-ap-familias>

== Lista completa <sec-ap-lista>

#include "_gerado-algoritmos.typ"
