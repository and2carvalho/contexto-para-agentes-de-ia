#import "/modelo/estilo.typ": *

#let familia(titulo, ..linhas) = figure(
  {
    set text(size: 8.6pt)
    tabela(
      colunas: (31%, 1fr, 1fr, auto),
      cabecalho: ([Distinção], [Modo de falha quando confundida], [Teste ou salvaguarda], [Cap.]),
      ..linhas,
    )
  },
  kind: table,
  caption: titulo,
)

= Catálogo de invariantes <ap-invariantes>

Este apêndice reúne, para consulta rápida, os invariantes do livro. A primeira parte organiza as _distinções fundamentais_ — pares de coisas que costumam ser confundidas — em nove famílias, cada uma com o modo de falha que a confusão produz, um teste ou salvaguarda e o capítulo onde a distinção é desenvolvida. A segunda parte é um índice de todos os invariantes e princípios enunciados formalmente no texto, na ordem em que aparecem.

Lembramos a convenção do @cap-introducao: uma distinção $X != Y$ não afirma que $X$ e $Y$ nunca coincidem; afirma que a coincidência não pode ser _suposta_ e precisa ser estabelecida com evidência em cada caso.

== Distinções fundamentais <sec-ap-distincoes>

=== Identidade e lugar

#familia([Família I — identidade e lugar.],
  [#neq[CAMINHO][IDENTIDADE]], [um localizador antigo é reutilizado e aponta para outro recurso], [verificar a identidade no destino antes de usar], [@cap-identidade],
  [#neq[NOME][IDENTIDADE]], [dois recursos homônimos são fundidos; um recurso renomeado é duplicado], [junções por identificador estável, nunca por nome], [@cap-identidade],
  [#neq[REPOSITÓRIO][DOMÍNIO]], [cada repositório vira um domínio "porque existe"], [critérios explícitos de soberania], [@cap-espacos],
  [#neq[MATERIALIZAÇÃO][DOMÍNIO]], [apagar uma cópia é tratado como apagar o domínio], [separar identidade, materialização e marcador], [@cap-identidade],
  [#neq[CONTENÇÃO][PERTENCIMENTO]], [inferir composição de "estão no mesmo diretório"], [veredito de diretório enumerado], [@cap-espacos],
  [#neq[COMPOSIÇÃO][AUTORIDADE]], [uma composição é usada para conceder escrita], [composição como relação nomeada, sem direitos], [@cap-espacos],
  [#neq[NÓ][DOMÍNIO]], [o serviço que responde sobre um domínio é tratado como o domínio], [três campos distintos: superfície, locus, nó], [@cap-espacos],
  [#neq[DIRETÓRIO DO PROCESSO][COORDENADA]], [o processo supõe que o lugar onde nasceu é o mundo], [lançar o mesmo consumidor de dois diretórios e comparar], [@cap-localizacao],
  [#neq[FALHA DE DESCOBERTA][AUSÊNCIA]], [declarar perdido algo que está em um locus não consultado], [forense de recuperação antes de concluir], [@cap-localizacao],
  [#neq[SEGUNDO LOCALIZADOR][PERMISSÃO DE REVINCULAR]], [atualização silenciosa apaga o vínculo anterior], [guarda de conflito de identidade], [@cap-identidade],
  [#neq[DESCOBERTA][AQUISIÇÃO]], [resultado de índice tratado como fato], [duas fases com estatutos distintos], [@cap-localizacao],
)

=== Autoridade e divulgação

#familia([Família A — autoridade e divulgação.],
  [#neq[LEITOR][ESCRITOR]], [quem pode ler passa a escrever porque alguém pediu], [relocar para um locus com autoridade de escrita], [@cap-autoridade],
  [#neq[FERRAMENTA][AUTORIDADE]], [o agente age porque tem a ferramenta], [autorização avaliada fora do modelo], [@cap-autoridade],
  [#neq[PERMISSÃO DO SISTEMA][AUTORIZAÇÃO]], [escrever porque o sistema operacional permitiu], [governança acima das permissões de arquivo], [@cap-autoridade],
  [#neq[REFERÊNCIA][ACESSO]], [conhecer um alvo é tratado como poder lê-lo], [arestas de referência sem conteúdo nem autoridade], [@cap-federacao],
  [#neq[PERSPECTIVA][AUTORIDADE]], [a apresentação derivada é usada como fonte para efeitos], [toda mutação cita autoridade externa à perspectiva], [@cap-modelo],
  [#neq[NAVEGAÇÃO][MUDANÇA DE AUTORIDADE]], [mudar de foco "herda" direitos de escrita], [provar que a navegação não altera relações], [@cap-relevancia],
  [#neq[PERFIL][CONCESSÃO]], [um perfil de configuração "libera" ações], [camadas de configuração só restringem], [@cap-ambiente],
  [#neq[AUTORIZAÇÃO][DIVULGAÇÃO]], [existência, contagens e nomes vazam a quem não pode ver], [política de divulgação separada, incluindo existência], [@cap-relevancia],
  [#neq[POSIÇÃO DE SUPERVISÃO][SOBERANIA]], [o supervisor decide como se fosse dono], [atos soberanos exigem ratificação do dono], [@cap-orquestracao],
  [#neq[TOKEN][CONCESSÃO]], [uma credencial de identidade é tratada como permissão], [concessões avaliadas no dono a cada decisão], [@cap-federacao],
  [#neq[CONTEXTO][COMANDO]], [instruções em dados são obedecidas], [efeitos só pelo laço governado], [@cap-seguranca],
  [#neq[FEDERAÇÃO][SINCRONIZAÇÃO]], [estado de outro domínio vira verdade local], [importações em quarentena, com proveniência], [@cap-federacao],
)

=== Epistemologia

#familia([Família E — epistemologia.],
  [#neq[MEMÓRIA][PROVA]], [decisão antiga tratada como fato corrente], [âncora de prova ou rótulo de memória em cada afirmação], [@cap-epistemologia],
  [#neq[AUSÊNCIA DE EVIDÊNCIA][EVIDÊNCIA DE AUSÊNCIA]], ["não provado" vira "não existe"], [só evidência negativa produz falso], [@cap-epistemologia],
  [#neq[DESCONHECIDO][NENHUM]], ["desconhecido" é renderizado como vazio ou falso], [sentinela: o desconhecido aparece literalmente], [@cap-apresentacao],
  [#neq[NÃO OBSERVADO AQUI][NÃO OBSERVADO]], [uma busca local vira afirmação global], [toda negativa carrega seu escopo], [@cap-localizacao],
  [#neq[SIMILARIDADE][RELAÇÃO GOVERNADA]], [proximidade semântica apresentada como dependência], [classificação da relação candidata], [@cap-proveniencia],
  [#neq[DESATUALIZADO][FALSO]], [observação antiga e verdadeira é descartada], [frescor relativo à pergunta], [@cap-tempo],
  [#neq[TRAÇO DE DERIVAÇÃO][EVIDÊNCIA]], [a regra que concluiu é citada como prova], [separar traço e âncoras], [@cap-proveniencia],
  [#neq[RELATÓRIO][VERDADE]], [conclusão de um relatório herdada sem reobservação], [reobservar o crítico; erro de relatório é desfecho legítimo], [@cap-handoff],
  [#neq[ATESTAÇÃO][ATESTAÇÃO DE OUTRO PACOTE]], ["aprovado" estendido a afirmações não avaliadas], [resumo do pacote avaliado na atestação], [@cap-federacao],
  [#neq[CONTRADIÇÃO][ESCOLHA]], [a fonte mais recente vence em silêncio], [estatuto conflitante preservado até ação explícita], [@cap-epistemologia],
  [#neq[INFERÊNCIA][FATO APRESENTADO]], [junção improvisada por uma superfície exibida como fato], [inferência rotulada; superfícies não compõem junções próprias], [@cap-arquitetura],
  [#neq[HIPÓTESE CONTRADITA][CAUSA ALTERNATIVA]], [explicação plausível não verificada ocupa o lugar da causa], [preservar "causa desconhecida"], [@cap-handoff],
)

=== Tempo e atualidade

#familia([Família T — tempo e atualidade.],
  [#neq[MAIS RECENTE][ACEITO]], [a última versão é tratada como a aprovada], [aceitação é ato governado, registrado], [@cap-trabalho],
  [#neq[INSTANTE OBSERVADO][INSTANTE REGISTRADO]], [eventos ordenados pela hora de gravação], [três relógios distintos], [@cap-tempo],
  [#neq[CONVERGÊNCIA ATUAL][CERTEZA RETROATIVA]], [o passado é reconstruído com o presente], [projeção no instante passado], [@cap-tempo],
  [#neq[DESEJADO][MATERIALIZADO]], [um "status" único esconde quatro planos], [quatro planos com dono e estatuto], [@cap-reconciliacao],
  [#neq[DERIVA][ERRO]], [toda divergência dispara alarme], [achado tipado com dono e aplicabilidade], [@cap-reconciliacao],
  [#neq[HISTÓRIAS DIVERGENTES][AFETAÇÃO]], [integrações compulsivas sem conflito semântico], [análise de afetação], [@cap-reconciliacao],
  [#neq[ESTADO REGISTRADO][ESTADO VIGENTE]], [pendência já satisfeita recomendada como próximo passo], [estado vigente derivado por junção], [@cap-trabalho],
  [#neq[ATUALIDADE DO OBSERVADOR][ATUALIDADE DO ALVO]], [verificador desatualizado classifica errado um alvo saudável], [versionar e verificar o observador], [@cap-metodo],
)

=== Ciclo de vida e ação

#familia([Família L — ciclo de vida e ação.],
  [#neq[RECIBO][EFEITO]], ["o comando retornou zero" é tratado como "o efeito ocorreu"], [pós-condição observada], [@cap-ciclo-acao],
  [#neq[EXISTE][AUTORIZADA]], [uma ação disponível é executada sem as demais verificações], [cadeia de sete estágios da ação], [@cap-ciclo-acao],
  [#neq[SELADO][ACEITO]], [encerrar é tratado como aprovar], [campos distintos para selo e desfecho], [@cap-trabalho],
  [#neq[RETENÇÃO][ACEITAÇÃO]], [promover para "garantir" a retenção], [referências de retenção não promocionais], [@cap-durabilidade],
  [#neq[PAUSAR][ABANDONAR]], [unidades em pausa são descartadas], [estados distintos na máquina de ciclo de vida], [@cap-trabalho],
  [#neq[INVENTÁRIO][SELEÇÃO]], [a primeira unidade aberta vira o objetivo], [seleção explícita do titular], [@cap-trabalho],
  [#neq[PROPOR][DECIDIR]], [sínteses e reflexões fecham unidades], [saídas de síntese são só propostas], [@cap-trabalho],
  [#neq[PARECE SEM USO][DESCARTÁVEL]], [apagar materialização com bytes únicos], [critérios conjuntos e ordem por reversibilidade], [@cap-durabilidade],
  [#neq[APLICABILIDADE][IDEMPOTÊNCIA]], [repetir um pedido aplicável produz efeito duplicado], [efeito de garantia; chave de idempotência para efeitos não idempotentes], [@cap-ciclo-acao],
  [#neq[HIGIENE][PERFEIÇÃO]], [unidades nunca fecham], [fechar contra critérios de concluído], [@cap-higiene],
)

=== Navegação, seleção e coordenada

#familia([Família N — navegação, seleção e coordenada.],
  [#neq[PODE VER][VIU]], ["o modelo sabia" porque a informação estava disponível], [recibo por nível da cadeia de restrição], [@cap-introducao],
  [#neq[PEDIDO NÃO RESOLVIDO][PADRÃO]], [o sistema responde sobre outra coisa], [preservar o pedido e devolver "não resolvido"], [@cap-relevancia],
  [#neq[COORDENADA PARCIAL][CONTEXTO INVÁLIDO]], [sessão rejeitada por falta de um componente], [perspectiva calculável com componentes indefinidos], [@cap-localizacao],
  [#neq[OBJETIVO][PRIMEIRA PENDÊNCIA]], [o objetivo é inferido de listas], [objetivo explícito, com três casos], [@cap-relevancia],
  [#neq[COMPRESSÃO][MENOS BYTES]], [resumo curto apaga desconhecidos], [recuperação de dimensões por consumidor frio], [@cap-compressao],
  [#neq[EXEMPLO][REGRA]], [casos de teste codificados como regras], [propriedades metamórficas], [@cap-perspectiva],
  [#neq[VISÍVEL][ACIONÁVEL]], [a interface oferece ação impossível], [visível, elegível, executável, motivo], [@cap-apresentacao],
  [#neq[MEMÓRIA CANDIDATA][VÍNCULO CORRENTE]], [memória promovida sem prova], [memória → candidata → verificação], [@cap-memoria],
  [#neq[MÉDIA][CRITÉRIO]], [escore médio alto esconde falha crítica], [agregação não compensatória], [@cap-avaliacao],
)

=== Renderização e superfícies

#familia([Família R — renderização e superfícies.],
  [#neq[OMISSÃO][NEGAÇÃO]], [campo truncado lido como "não há"], [marcas de omissão em toda superfície], [@cap-apresentacao],
  [#neq[AQUISIÇÃO][COMPOSIÇÃO]], [o renderizador consulta fontes], [núcleo puro sem entrada e saída], [@cap-perspectiva],
  [#neq[SUPERFÍCIE][DONO SEMÂNTICO]], [cada superfície recalcula e diverge], [costura neutra; conformidade entre superfícies], [@cap-arquitetura],
  [#neq[APRESENTAÇÃO DERIVADA][PERSPECTIVA CANÔNICA]], [superfície lê a saída formatada de outra], [consumir a saída canônica do núcleo], [@cap-apresentacao],
  [#neq[POSIÇÃO VISUAL][RELAÇÃO]], [proximidade na tela tratada como vínculo], [arestas antes de linhas], [@cap-apresentacao],
  [#neq[EXPERIÊNCIA INTEGRADA][ARQUITETURA COLAPSADA]], [fundir donos para simplificar a interface], [separação por eixo], [@cap-arquitetura],
  [#neq[PROJEÇÃO][TRANSIÇÃO]], [um núcleo único lê e muta], [execuções ortogonais], [@cap-arquitetura],
)

=== Durabilidade e reprodutibilidade

#familia([Família D — durabilidade e reprodutibilidade.],
  [#neq[REVISÃO ACEITA][FONTE RETIDA]], [a decisão cita um resumo que não reconstrói nada], [aceitação exige raiz de retenção], [@cap-durabilidade],
  [#neq[BYTES RETIDOS][RECUPERÁVEIS]], [o conteúdo existe, mas nenhum consumidor o alcança], [vetor de durabilidade com cinco dimensões], [@cap-durabilidade],
  [#neq[REFERÊNCIA RETIDA][FONTE RETIDA]], ["a governança reteve a fonte"], [nomear com precisão cada retenção], [@cap-durabilidade],
  [#neq[MESMA REVISÃO][MESMA CONSTRUÇÃO]], [dependência por caminho produz artefatos diferentes], [coordenada fechada por tipo de dependência], [@cap-durabilidade],
  [#neq[MARCADOR APAGADO][HISTÓRIA PERDIDA]], [perder tudo ou fingir que nada aconteceu], [separar identidade, marcador e localizador], [@cap-durabilidade],
  [#neq[ARTEFATO][FONTE]], [o executável instalado diverge do código], [cadeia material de proveniência], [@cap-runtime],
  [#neq[IDÊNTICO][COMPATÍVEL]], [componentes compatíveis tratados como iguais], [compatibilidade escopada por requisito; ancestralidade], [@cap-runtime],
)

=== Método

#familia([Família M — método.],
  [#neq[MECANISMO][SEMÂNTICA]], [a conveniência da ferramenta decide o significado], [perguntar o que faz $X$ merecer ser $Y$], [@cap-metodo],
  [#neq[HIPÓTESE][LACUNA CONFIRMADA]], [lacunas congeladas antes do uso real], [exigir uso real antes de confirmar], [@cap-metodo],
  [#neq[FRIO][VAZIO]], [teste com consumidor contaminado], [nova sessão, outro fornecedor, gabarito oculto], [@cap-avaliacao],
  [#neq[CONTINUIDADE DE CONTEXTO][CONTINUIDADE DO OBSERVADOR]], [o contexto morre com a sessão], [recomposição a partir do acervo], [@cap-handoff],
  [#neq[CONVERSA][EVIDÊNCIA]], [o que foi dito vira o que foi medido], [fronteira de promoção explícita], [@cap-metodo],
  [#neq[MÉTRICA][OBJETIVO]], [maquinaria construída só para zerar uma métrica], [justificar cada componente por um consumidor], [@cap-avaliacao],
  [#neq[LEITURA][NÃO MUTAÇÃO PROVADA]], [comando "de leitura" escreve caches], [resumos antes e depois], [@cap-seguranca],
)

== Índice dos invariantes e princípios do texto <sec-ap-indice-invariantes>

A lista abaixo reúne todos os invariantes e princípios enunciados formalmente no livro, agrupados por capítulo. As remissões levam ao enunciado completo.

#include "_gerado-enunciados.typ"
