# Git passo a passo – Petcats (macOS)

Repositório: https://github.com/paulozaca-ship-it/petcats

## 1. Configurar o Git (uma única vez)

```bash
git --version                     # se não estiver instalado, o macOS oferece instalar
git config --global user.name  "Paulo de Negreiros Ramos"
git config --global user.email "seu-email@exemplo.com"   # o mesmo e-mail da conta GitHub
git config --global init.defaultBranch main
```

## 2. Clonar o repositório

```bash
cd ~/Documents                    # ou a pasta onde você guarda projetos
git clone https://github.com/paulozaca-ship-it/petcats.git
cd petcats
```

## 3. Adicionar os scripts originais em commits pequenos

Copie para a pasta `petcats` os scripts `01_criacao_petcats.sql` a `04b_exclusao_petcats.sql` e registre um commit por etapa. Isso conta a história do projeto e mostra método a quem avaliar o repositório:

```bash
git add 01_criacao_petcats.sql
git commit -m "feat: estrutura do banco Petcats (37 tabelas, 3FN)"

git add 02_insercao_petcats.sql
git commit -m "feat: carga inicial com integridade referencial"

git add 03_consultas_petcats.sql
git commit -m "feat: consultas relacionais com JOIN, WHERE, ORDER BY e LIMIT"

git add 04a_atualizacao_petcats.sql 04b_exclusao_petcats.sql
git commit -m "feat: UPDATE e DELETE condicionais em transação"

git push                          # envia para o GitHub
git log --oneline                 # confere o histórico
```

Na primeira vez que você rodar `git push`, o GitHub pede login. Use um *personal access token* no lugar da senha, ou instale o GitHub CLI (`brew install gh`) e rode `gh auth login`.

**Alternativa sem terminal:** no GitHub, abra o repositório, clique em **Add file → Upload files**, arraste os quatro scripts e confirme o commit.

## 4. Estrutura final

```
petcats/
├── 01_criacao_petcats.sql
├── 02_insercao_petcats.sql
├── 03_consultas_petcats.sql
├── 04a_atualizacao_petcats.sql
├── 04b_exclusao_petcats.sql
├── 05_desempenho_petcats.sql
├── 06_indices_petcats.sql
├── docs/
│   ├── desempenho.md
│   └── git-passo-a-passo.md
├── .gitignore
└── README.md
```

## 5. Fluxo do dia a dia

```bash
git pull                          # traz alterações feitas pelo site
git status                        # o que mudou
git diff                          # ver as alterações linha a linha
git add <arquivo>
git commit -m "fix: corrige filtro de data na consulta 2"
git push
```

## 6. Boas práticas para este projeto

- Nunca versione dumps do banco nem senhas; o `.gitignore` já exclui `*.dump`, `*.backup` e logs.
- Os dados de exemplo são fictícios; mantenha assim, pois o repositório é público.
- Ao mudar o esquema, crie um script novo (`07_...sql`) em vez de editar o 01 já publicado. Isso preserva a reprodutibilidade de quem já rodou a versão anterior.
- Use tags para marcar entregas: `git tag -a v1.0 -m "Entrega Experiência Prática IV"` e `git push --tags`.
