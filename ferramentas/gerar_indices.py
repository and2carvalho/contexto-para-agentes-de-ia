#!/usr/bin/env python3
"""Extrai enunciados formais e algoritmos dos capítulos, na ordem do livro,
e gera apendices/_gerado-enunciados.typ e apendices/_gerado-algoritmos.typ."""
import re, sys, os

RAIZ = sys.argv[1] if len(sys.argv) > 1 else "."
ORDEM = [
    "cap01-introducao", "cap02-llm", "cap03-modelo", "cap04-epistemologia",
    "cap-identidade", "cap-espacos", "cap-localizacao", "cap-tempo", "cap-proveniencia", "cap-durabilidade", "cap-memoria",
    "cap-selecao", "cap-working-set", "cap-perspectiva", "cap-fronteira", "cap-compressao", "cap-compactacao",
    "cap-relevancia", "cap-apresentacao", "cap-entrada",
    "cap-autoridade", "cap-portoes", "cap-ciclo-acao", "cap-trabalho", "cap-reconciliacao", "cap-higiene",
    "cap-ambiente", "cap-runtime", "cap-federacao", "cap-seguranca",
    "cap-orquestracao", "cap-handoff", "cap-arquitetura", "cap-observabilidade",
    "cap-avaliacao", "cap-metodo", "cap-abertos",
]


def casa(s, i, abre="[", fecha="]"):
    """s[i] == abre; devolve o índice do fechamento correspondente, ignorando
    trechos de matemática ($...$), strings e escapes."""
    prof = 0
    em_mat = False
    j = i
    while j < len(s):
        c = s[j]
        if c == "\\":
            j += 2
            continue
        if c == "$":
            em_mat = not em_mat
        elif not em_mat:
            if c == abre:
                prof += 1
            elif c == fecha:
                prof -= 1
                if prof == 0:
                    return j
        j += 1
    raise ValueError("colchete sem par")


def extrai(texto, amb):
    itens = []
    padrao = "#" + amb + "(titulo: ["
    pos = 0
    while True:
        i = texto.find(padrao, pos)
        if i < 0:
            break
        a = i + len(padrao) - 1
        f = casa(texto, a)
        titulo = texto[a + 1:f]
        # corpo
        k = texto.find("[", f + 1)
        fk = casa(texto, k)
        m = re.match(r"\s*<([a-z0-9-]+)>", texto[fk + 1:])
        rot = m.group(1) if m else None
        itens.append((titulo.strip(), rot))
        pos = fk + 1
    return itens


def extrai_alg(texto):
    itens = []
    for m in re.finditer(r'#algoritmo\("([^"]+)"', texto):
        i = m.end()
        # parâmetros e legenda até o ")" que precede o corpo "["
        j = texto.find(")[", i)
        cab = texto[i:j]
        pm = re.search(r"params:\s*(\$[^$]*\$)", cab)
        lg = re.search(r"legenda:\s*\[", cab)
        legenda = ""
        if lg:
            a = i + lg.end() - 1
            legenda = texto[a + 1:casa(texto, a)]
        k = j + 1
        fk = casa(texto, k)
        r = re.match(r"\s*<([a-z0-9-]+)>", texto[fk + 1:])
        itens.append((m.group(1), pm.group(1) if pm else "", legenda.strip(), r.group(1) if r else None))
    return itens


def rotulo_cap(texto):
    m = re.search(r"^= (.*?)\s*<([a-z0-9-]+)>", texto, re.M)
    return m.group(2), m.group(1)


enun, algs = [], []
for nome in ORDEM:
    caminho = os.path.join(RAIZ, "capitulos", nome + ".typ")
    t = open(caminho, encoding="utf-8").read()
    cap = rotulo_cap(t)
    inv = [x for x in extrai(t, "invariante") if x[1]]
    pri = [x for x in extrai(t, "principio") if x[1]]
    if inv or pri:
        enun.append((cap, inv, pri))
    al = [x for x in extrai_alg(t) if x[3]]
    if al:
        algs.append((cap, al))

with open(os.path.join(RAIZ, "apendices", "_gerado-enunciados.typ"), "w", encoding="utf-8") as o:
    o.write("// GERADO AUTOMATICAMENTE por gerar_indices.py — não editar à mão.\n")
    o.write('#import "/modelo/estilo.typ": *\n\n')
    for cap, inv, pri in enun:
        o.write(f"=== @{cap[0]}: {cap[1]}\n\n")
        for tit, rot in inv:
            o.write(f"/ @{rot}: {tit}\n")
        for tit, rot in pri:
            o.write(f"/ @{rot}: {tit}\n")
        o.write("\n")

with open(os.path.join(RAIZ, "apendices", "_gerado-algoritmos.typ"), "w", encoding="utf-8") as o:
    o.write("// GERADO AUTOMATICAMENTE por gerar_indices.py — não editar à mão.\n")
    o.write('#import "/modelo/estilo.typ": *\n\n')
    o.write("#figure(\n  tabela(\n    colunas: (34%, 19%, 1fr),\n")
    o.write("    cabecalho: ([Procedimento], [Onde], [Finalidade]),\n")
    for cap, al in algs:
        for nome, params, leg, rot in al:
            p = f"({params})" if params else "()"
            o.write(f"    [#proc[{nome}];{p}], [@{rot}], [{leg}],\n")
    o.write("  ),\n  kind: table, caption: [Algoritmos e procedimentos do livro, na ordem em que aparecem.],\n) <tab-ap-algoritmos>\n")

n_inv = sum(len(i) for _, i, _ in enun)
n_pri = sum(len(p) for _, _, p in enun)
n_alg = sum(len(a) for _, a in algs)
print(f"invariantes={n_inv} princípios={n_pri} algoritmos={n_alg}")
