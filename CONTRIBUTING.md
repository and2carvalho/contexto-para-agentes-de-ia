# Contribuindo com "Contexto para Agentes de IA"

Agradecemos o interesse em colaborar com o livro-texto. Como se trata de uma obra formal de referência sob licença **Creative Commons Atribuição-NãoComercial-SemDerivações 4.0 Internacional (CC BY-NC-ND 4.0)**, as diretrizes de contribuição seguem regras claras:

---

## 1. Tipos de contribuições bem-vindas

1. **Erratas e correções ortográficas ou gramaticais:** Pequenos ajustes no texto que corrijam pontuação, concordância ou digitação.
2. **Correções em notações matemáticas e provas:** Notificações de inconsistências em índices, subscritos, definições ou etapas de demonstração nos capítulos e apêndices.
3. **Erratas em referências bibliográficas:** Correções de metadados, links de DOIs quebrados ou citações no arquivo `referencias.yml`.
4. **Clarificações em algoritmos e pseudocódigo:** Ajustes de clareza que tornem procedimentos mais fiéis às convenções de Cormen et al.

> **Nota sobre escopo conceitual:** A obra possui tese central, estrutura teórica e capítulos fechados para a primeira edição. Não são aceitas adições de novos capítulos, seções opinativas ou alterações da arquitetura formal da obra via Pull Request. Sugestões de novos temas podem ser abertas como *Issue* para consideração em edições futuras.

---

## 2. Como propor uma alteração

1. **Abra uma Issue:** Para discussões ou dúvidas sobre uma passagem do livro, use a aba [Issues](https://github.com/and2carvalho/contexto-para-agentes-de-ia/issues) com o modelo de **Relato de Errata**.
2. **Envie um Pull Request:**
   - Crie um *fork* deste repositório;
   - Crie um branch descritivo para sua correção (ex.: `fix/cap03-formula-projecao`);
   - Faça a alteração pontual no arquivo `.typ` correspondente dentro de `capitulos/` ou `apendices/`;
   - Teste a compilação local com `./build.sh`;
   - Abra o Pull Request apontando para a branch `main`.

---

## 3. Verificação Contínua (CI)

Ao submeter um Pull Request, a suíte de testes automatizados do GitHub Actions compilará o livro integralmente em Typst para garantir que:
- Não há erros de sintaxe;
- Todos os rótulos cruzados (`@def-...`, `@cap-...`) continuam resolvendo;
- O índice remissivo e o glossário são gerados com sucesso.

---

## 4. Reconhecimento

Contribuições aceitas serão registradas no histórico de versões do repositório e creditadas na lista de agradecimentos e erratas das revisões subsequentes da obra.
