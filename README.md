# Contexto para Agentes de IA

**Gerenciamento, Engenharia, Design e Administração — Fundamentos, Algoritmos e Sistemas**

Livro-texto universitário sobre o contexto de agentes de inteligência artificial
baseados em modelos de linguagem: o que um agente deve ver, a cada passo, para agir
corretamente — e como construir, operar e avaliar os sistemas que decidem isso.

Autor: **André Antero de Carvalho** ([ORCID 0009-0008-7737-9318](https://orcid.org/0009-0008-7737-9318)).

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23933493.svg)](https://doi.org/10.5281/zenodo.23933493)
[![Apoiar no Ko-fi](https://img.shields.io/badge/Apoiar%20no-Ko--fi-F16061?logo=ko-fi&logoColor=white)](https://ko-fi.com/and2carvalho)
[![Licença: CC BY-NC-ND 4.0](https://img.shields.io/badge/Licen%C3%A7a-CC%20BY--NC--ND%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/deed.pt-br)
Publicado no Zenodo: <https://doi.org/10.5281/zenodo.23933493>

O PDF compilado está em [`contexto-para-agentes-de-ia.pdf`](contexto-para-agentes-de-ia.pdf).
O livro é distribuído sob a licença CC BY-NC-ND 4.0 (ver [`LICENSE.md`](LICENSE.md)).


## Apoio à Pesquisa Aberta

Este livro-texto é distribuído gratuitamente sob a licença aberta **CC BY-NC-ND 4.0** com o objetivo de democratizar o acesso a fundamentos rigorosos sobre engenharia de contexto para agentes de IA.

Se este material agregou valor ao seu aprendizado, equipe ou projeto e você deseja incentivar a continuidade de pesquisas abertas e novas publicações, considere fazer uma contribuição voluntária:

👉 **[Apoiar no Ko-fi (ko-fi.com/and2carvalho)](https://ko-fi.com/and2carvalho)**

## Estrutura

| Parte | Conteúdo | Capítulos |
|---|---|---|
| I — Fundamentos | o problema, modelos de linguagem, o modelo formal, epistemologia | 1–4 |
| II — Gerenciamento | identidade, domínios, localização, tempo, proveniência, durabilidade, memória | 5–11 |
| III — Engenharia | seleção, conjunto de trabalho, núcleo de projeção, fronteira, compressão, compactação | 12–17 |
| IV — Design | relevância e divulgação, apresentação, entrada | 18–20 |
| V — Administração | autoridade, portões, ciclo da ação, unidades de trabalho, reconciliação, higiene | 21–26 |
| VI — Ambientes, execução, federação e segurança | | 27–30 |
| VII — Sistemas de agentes | orquestração, transferência, arquitetura, observabilidade | 31–34 |
| VIII — Avaliação e método | avaliação, método empírico, problemas em aberto | 35–37 |
| Apêndices | A matemática · B lógica · C informação · D sistemas distribuídos · E invariantes · F algoritmos · G modelos de pacotes · H glossário | |

## Compilação

Requisitos: [Typst](https://typst.app) 0.15 ou superior e Python 3.

```sh
./build.sh
```

Para gerar um exemplar com identificação nominal ou institucional no rodapé de cada
página, use `LICENCIADO="Nome ou Organização" ./build.sh`.

O script regenera os índices automáticos (enunciados do Apêndice E, algoritmos do
Apêndice F e glossário do Apêndice H) e compila `livro.typ`. As fontes tipográficas
(Libertinus e JetBrains Mono, ambas sob licença OFL) estão em `fontes/`; os pacotes
Typst usados (`lovelace` e `fletcher`) são baixados automaticamente na primeira
compilação.

## Organização dos arquivos

```
livro.typ               arquivo-mestre (dados da obra: título, autor, edição, ano)
modelo/estilo.typ       modelo tipográfico e ambientes (definição, teorema, invariante…)
modelo/capa.typ         capa, folha de rosto e créditos
modelo/apa-livro.csl    estilo bibliográfico (APA adaptado)
preliminares/           prefácio
capitulos/              um arquivo por capítulo
apendices/              apêndices A–H (arquivos _gerado-* são produzidos pelos scripts)
referencias.yml         bibliografia (formato Hayagriva)
ferramentas/            geradores dos índices automáticos
fontes/                 fontes tipográficas
divulgacao/             cartilhas para o LinkedIn (carrosséis em PDF) e textos dos posts;
                        gere com divulgacao/build.sh
LICENSE.md              licença da obra (CC BY-NC-ND 4.0)
```

## Convenções para edição

- Cada capítulo começa com `= Título <cap-rotulo>` e importa `/modelo/estilo.typ`.
- Enunciados formais: `#definicao(titulo: [...])[...] <def-...>`, e analogamente
  `teorema`, `lema`, `proposicao`, `corolario`, `fato` (consequência imediata das
  definições), `invariante`, `principio`, `antipadrao`, `exemplo`; estudos de caso
  com `#estudo-de-caso`.
- Algoritmos: `#algoritmo("Nome-Do-Procedimento", params: $...$, legenda: [...])[...] <alg-...>`.
- Cada seção termina com `#exercicios[...]`; cada capítulo, com `#problemas[...]` e `#notas[...]`.
- Estatutos epistêmicos em versalete, apenas para os quatro valores
  `#est[provado]`, `#est[refutado]`, `#est[desconhecido]` e `#est[conflitante]`;
  os demais vocabulários fechados (estados de entrega, vereditos, desfechos de
  verificação…) usam `#estado[...]`.
- Citações: `@chave` (parentética) e `#ct(<chave>)` (narrativa).
- O nome do autor e os dados da edição ficam no topo de `livro.typ`.

## Como citar

ANTERO DE CARVALHO, André. *Contexto para Agentes de IA*: gerenciamento, engenharia,
design e administração — fundamentos, algoritmos e sistemas. 1. ed. [*S. l.*]:
Edição do autor, 2026. DOI: 10.5281/zenodo.23933493.

```bibtex
@book{anterodecarvalho2026contexto,
  author    = {{Antero de Carvalho}, André},
  title     = {Contexto para Agentes de IA: Gerenciamento, Engenharia, Design e
               Administração --- Fundamentos, Algoritmos e Sistemas},
  edition   = {1},
  year      = {2026},
  publisher = {Edição do autor},
  doi       = {10.5281/zenodo.23933493}
}
```

## Registro e Indexação

A obra possui registro de objeto digital permanente e metadados arquivados pelo CERN / DataCite:
- **DOI:** [10.5281/zenodo.23933493](https://doi.org/10.5281/zenodo.23933493)
- **ORCID do autor:** [0009-0008-7737-9318](https://orcid.org/0009-0008-7737-9318)
- **Licença:** Creative Commons Atribuição-NãoComercial-SemDerivações 4.0 Internacional (CC BY-NC-ND 4.0)

Os scripts em `ferramentas/` apoiam a compilação determinística do livro, a extração de enunciados e a sincronização de metadados junto à API de depósito.
