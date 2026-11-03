# Cartilhas Temáticas — Contexto para Agentes de IA

Sínteses conceituais em formato de documento e lâminas para estudo rápido e divulgação técnica, correspondendo aos PDFs gerados na pasta `divulgacao/`.

---

## Parte 1 — `cartilha-01-sete-confusoes.pdf`

**Título do documento:** 7 confusões que fazem agentes de IA errarem

```text
Quando um agente de IA erra, a culpa quase nunca é do modelo.

É do contexto: o agente recebeu informação desatualizada, incompleta ou fora de escopo — ou recebeu a informação certa e a leu errado.

Estudando essas falhas, percebi um padrão: quase todas são uma confusão entre duas coisas parecidas.

→ "Estava disponível" não é "o agente viu".
→ "Não encontrei" não é "não existe".
→ "O comando retornou sucesso" não é "a mudança aconteceu".

No carrossel, as 7 confusões mais comuns — e o teste que evita cada uma.

Qual delas você já viu acontecer no seu time?

#AgentesDeIA #EngenhariaDeContexto #InteligenciaArtificial #LLM
```

---

## Parte 2 — `cartilha-02-o-que-o-agente-ve.pdf`

**Título do documento:** Seu agente não vê o que você acha que ele vê

```text
"Mas a informação estava lá. Por que o agente não usou?"

Porque, entre tudo o que existe e o que o modelo de fato usou, há sete filtros:

universo → ambiente → legível → aplicável → selecionado → entregue → consumido

A cada filtro, parte da informação fica para trás. Às vezes por boas razões (autoridade, relevância, orçamento). Às vezes por defeito.

Quando um agente erra, a pergunta útil não é "o que ele sabia?". É "em que nível a informação se perdeu?" — porque cada nível tem uma correção diferente.

No carrossel, os sete níveis e uma tabela de diagnóstico para usar no próximo incidente.

#AgentesDeIA #EngenhariaDeContexto #RAG #LLM
```

---

## Parte 3 — `cartilha-03-quatro-estados.pdf`

**Título do documento:** Os quatro estados que todo agente precisa distinguir

```text
Sim. Não. Não sei. E "as fontes discordam".

A maioria dos sistemas registra fatos como verdadeiros ou falsos. Mas um agente de IA trabalha com informação incompleta e com fontes que se contradizem.

Com só dois estados, ele é obrigado a inventar certezas:
→ "não sei" vira "não";
→ "as fontes discordam" vira "vale a mais recente".

Com quatro estados — provado, refutado, desconhecido e conflitante —, o agente pode dizer o que realmente sabe. E pode se recusar a agir quando não sabe o suficiente.

É a diferença entre um agente confiável e um agente apenas confiante.

#AgentesDeIA #EngenhariaDeContexto #IAConfiavel #LLM
```
