#import "/modelo/estilo.typ": *

= Modelos de pacotes e registros <ap-modelos>

Este apêndice oferece modelos para os principais objetos de transferência e registro descritos no livro. Os modelos são escritos numa notação neutra, semelhante a YAML, com valores de exemplo genéricos. Não são formatos padronizados: são pontos de partida, que cada sistema adaptará ao seu domínio, preservando os campos que sustentam os invariantes discutidos no texto. Para cada modelo indicamos a definição correspondente e os campos cuja omissão mais frequentemente causa falhas.

Valores entre sinais de menor e maior, como `<rev-W>` ou `<resumo-S>`, são marcadores simbólicos a substituir por identificadores reais; datas e nomes são ilustrativos.

== Pacote de investigação <sec-ap-pacote-investigacao>

Corresponde à @def-pacote-investigacao. Campos críticos: _mutações proibidas_, _invariantes_ e _próxima aresta_.

```yaml
pacote_de_investigacao:
  proposito:
    - "Determinar a causa da falha intermitente do teste de integração T"
    - "Classificar a falha: regressão, dívida herdada ou não hermética"
  autoridade:
    teto: somente-leitura
    exige_autorizacao_adicional: [qualquer escrita, reinício de serviços]
  coordenada:
    dominio: dominio-servicos
    unidade_de_trabalho: investigacao-teste-T
    instante: 2026-03-14T10:20:00Z
    linha_de_base: revisao-aceita-R
  fundacao:            # já fechado; não reabrir
    - "A configuração do ambiente de integração foi validada em 2026-03-10"
  invariantes:         # distinções que o destino não pode supor
    - "caminho não é identidade"
    - "recibo não é efeito"
    - "ausência local não é ausência global"
  fatos_conhecidos:
    - afirmacao: "T falha em 3 de 20 execuções"
      ancora: registro-execucoes-0314
      estatuto: provado
  desconhecidos:
    - "se a falha depende da ordem de execução dos testes"
  mutacoes_permitidas: []
  mutacoes_proibidas:
    - "alterar código, configuração ou dados"
    - "reexecutar a suíte completa em ambiente compartilhado"
  regra_de_superficie: >
    se uma superfície de leitura não responder, classificar como lacuna
    antes de recorrer a arquivos ou comandos de sistema
  fases: [observar, classificar, propor]
  aceitacao:
    - "classificação com evidência ancorada para cada hipótese"
  condicoes_de_parada:
    - "evidência de efeito colateral em ambiente compartilhado"
  contrato_de_retorno:
    secoes: [coordenada, itens, mutacoes, nao_realizado, desvios,
             desconhecidos, proxima_aresta, veredito]
    vereditos: [aprovado, aprovado-com-emendas, requer-correcao,
                ainda-nao-executavel, bloqueado]
  proxima_aresta_esperada: "uma única ação mínima"
```

== Pacote de retorno <sec-ap-pacote-retorno>

Corresponde à @def-pacote-retorno. Campos críticos: _base_ de cada item, _mutações realizadas_ com prova de não mutação, e _veredito_ de vocabulário fechado.

```yaml
pacote_de_retorno:
  coordenada_de_execucao:
    locus: no-integracao-2
    identidade: agente-executor (somente-leitura)
    instante_inicio: 2026-03-14T10:31:02Z
    instante_fim: 2026-03-14T11:05:40Z
  itens:
    - chave: ordem_de_execucao_afeta
      valor: sim
      estatuto: provado
      base: {fonte: execucoes-ordenadas, metodo: 40 execucoes, confianca: alta}
    - chave: causa_raiz
      valor: desconhecido
      estatuto: desconhecido
      base: {nota: "hipótese H1 (versão de dependência) contradita"}
  mutacoes_realizadas: []
  prova_de_nao_mutacao: {resumo_antes: <resumo-S>, resumo_depois: <resumo-S>}   # iguais
  nao_realizado: ["teste em ambiente isolado (fora do teto)"]
  adiado: []
  desvios: []
  desconhecidos: ["estado compartilhado entre T e o teste U"]
  bloqueios: []
  proxima_aresta: "executar T e U isoladamente em ambiente descartável"
  veredito: requer-correcao
```

== Registro de continuação <sec-ap-continuacao>

Corresponde à @def-projecao-continuacao. Campos críticos: _delta de evidência_ com âncoras e _fronteiras preservadas_.

```yaml
registro_de_continuacao:
  passo: 7
  fronteira_anterior: "isolar a interação entre T e U"
  delta_de_evidencia:
    - {fato: "T passa isoladamente (20/20)", estatuto: provado, ancora: exec-0315-a}
    - {fato: "T falha após U (6/20)", estatuto: provado, ancora: exec-0315-b}
  recomposicao: "a falha depende de estado deixado por U"
  fronteira_corrente: "identificar o estado compartilhado"
  proxima_profundidade:
    acao: "inspecionar recursos temporários criados por U"
    justificativa: "única diferença observável entre as condições"
  falhas_observadas: ["um resumo anterior afirmou causa sem evidência"]
  fronteiras_preservadas:
    - "nenhuma correção foi decidida"
    - "nenhuma unidade de trabalho nova foi aberta"
```

== Semente de continuação <sec-ap-semente>

Corresponde à @def-semente-continuacao. A semente contém referências, não o estado que elas designam; uma semente terminal declara que nenhuma continuação é necessária.

```yaml
semente_de_continuacao:
  origem: {unidade: investigacao-teste-T, instante: 2026-03-15T17:00:00Z}
  composicao: ref:composicao-servicos
  objetivo: ref:objetivo-estabilizar-integracao
  perfil: ref:perfil-depuracao
  focos_intencionais: [ref:teste-T, ref:teste-U]
  escopo_de_requisitos: ref:requisitos-integracao
  proveniencia: [ref:registro-continuacao-passo-7, ref:retorno-0314]
  terminal: false
  # semente terminal:
  # terminal: true
  # ancora_de_encerramento: ref:decisao-encerramento-0320
```

== Registro de decisão <sec-ap-decisao>

Corresponde à @def-registro-decisao. Decisões são imutáveis; uma decisão revista é suplantada por outra que a referencia.

```yaml
registro_de_decisao:
  identificador: decisao-0316-isolamento
  problema: "testes de integração compartilham estado temporário"
  alternativas:
    - "executar testes em ordem fixa"
    - "isolar o estado temporário por teste"
  escolha: "isolar o estado temporário por teste"
  razao: "a ordem fixa esconde a dependência em vez de removê-la"
  autoridade: {quem: titular-do-dominio, papel: titular}
  evidencias: [ref:exec-0315-a, ref:exec-0315-b]
  condicoes_de_revisao:
    - "se o isolamento aumentar o tempo da suíte em mais de 30%"
  instante: 2026-03-16T09:00:00Z
  suplanta: null
```

== Registro de evidência <sec-ap-evidencia>

Corresponde às definições de evidência e proveniência do @cap-proveniencia. O registro é uma asserção sobre a afirmação, com estatuto, força e âncora: aqui, a afirmação positiva "X contém C" é #est[refutado] por evidência negativa explícita. Campo crítico: _escopo_ — onde, como e quando a observação foi feita —, sem o qual uma negativa local vira negativa global.

```yaml
registro_de_evidencia:
  afirmacao: "o recurso X contém a configuração C"
  estatuto: refutado            # evidência negativa explícita, escopada
  escopo:
    locus: materializacao-local-1
    metodo: "busca textual exaustiva no diretório de configuração"
    instante: 2026-03-16T11:12:00Z
  ancora: {tipo: saida-de-comando, resumo: <resumo-da-saida>}
  fonte: agente-executor
  forca: medida
  pacote_avaliado: <resumo-do-pacote>   # contra sobrevinculação
```

== Manifesto de convergência <sec-ap-manifesto>

Corresponde à @def-manifesto. O manifesto é calculado, não editado à mão.

```yaml
manifesto_de_convergencia:
  calculado_em: 2026-03-20T08:00:00Z
  recursos:
    - recurso: repositorio-servicos
      revisao_de_trabalho: <rev-W>
      referencia_local: principal@<rev-W>
      referencia_remota: principal@<rev-R>
      revisao_integrada_proposta: <rev-W>
      linha_de_base_aceita: <rev-B>
      nao_realizado: ["publicação na linha remota (aguarda portão)"]
  termos_precisos:
    integrado: "presente na linha principal local"
    aceito: "promovido à linha de base por decisão registrada"
```

== Matriz de disposição <sec-ap-disposicao>

Corresponde à @def-matriz-disposicao. A coluna "planos inalterados" registra o que foi considerado e deliberadamente não mudou.

#figure(
  {
    set text(size: 8.2pt)
    tabela(
      colunas: (1.4fr, 1fr, 1fr, 1fr, 1.2fr, 1fr),
      cabecalho: ([Afirmação], [Autoridade], [Atualidade], [Planos alterados], [Planos inalterados], [Desconhecidos]),
      [T depende do estado deixado por U], [observação do executor], [2026-03-15], [plano de testes], [arquitetura dos serviços; linha de base], [qual recurso temporário],
      [isolar estado por teste], [decisão do titular], [2026-03-16], [estratégia de testes], [ordem de execução; ferramentas], [impacto no tempo da suíte],
    )
  },
  kind: table,
  caption: [Exemplo de matriz de disposição (colunas principais).],
) <tab-ap-disposicao>

== Prévia de turno <sec-ap-previa>

Corresponde ao turno preparado e à prévia do @cap-orquestracao. Campo crítico: _coordenada aceita_, à qual a aceitação do titular se liga.

```yaml
previa_de_turno:
  objetivo: ref:objetivo-estabilizar-integracao
  contexto_selecionado: [ref:teste-T, ref:teste-U, ref:decisao-0316-isolamento]
  alvos: [ref:teste-U]
  funcionalidades: [editar-codigo-de-teste]
  lacunas_de_autoridade: ["publicação exige portão de revisão"]
  fluxo: [editar, executar-localmente, registrar-evidencia, propor-integracao]
  efeitos_bloqueados: ["publicar na linha remota"]
  validacoes_esperadas: ["T e U passam 50/50 em ordens aleatórias"]
  evidencias_esperadas: [registro-de-execucoes, resumo-do-diff]
  coordenada_aceita: {linha_de_base: <rev-B>, instante: 2026-03-16T09:30:00Z}
  aceitacao_do_titular: pendente
```

#notas[
  Os modelos deste apêndice condensam os formatos discutidos nos Capítulos sobre memória, compactação, proveniência, higiene, orquestração e transferência. Formatos semelhantes aparecem, com outros nomes, em registros de decisões de arquitetura, em relatórios de incidentes sem atribuição de culpa @beyer2016 e em padrões de proveniência como o PROV @prov2013; o que os distingue aqui é a ênfase em estatuto epistêmico, escopo de negação, autoridade e fronteiras preservadas.
]
