# Petcats – Banco de dados relacional

Implementação física e manipulação de dados (DML) do minimundo **Petcats**, uma clínica veterinária exclusiva para gatos, com agenda de banho e tosa, hotel, atendimento clínico e loja. Projeto desenvolvido na disciplina de Modelagem de Banco de Dados (Experiência Prática IV) do curso de Tecnologia em Inteligência Artificial.

## 1. Minimundo

- **Tutores e pacientes:** tutores (com um ou mais telefones) e seus gatos, classificados por raça.
- **Equipe:** funcionários; os veterinários são uma especialização com CRMV e especialidades.
- **Agenda e hotel:** agendamentos de serviços (banho, tosa, unhas) e hospedagens por quarto, com registro de ocorrências.
- **Clínica:** consultas, diagnósticos, exames com resultados por parâmetro, prescrições, vacinas por lote e anexos do prontuário.
- **Comercial:** produtos por categoria, lotes, movimentação de estoque, fornecedores e vendas, cujos itens são produtos ou serviços.

O modelo lógico foi normalizado até a 3FN: **37 tabelas**, 42 chaves estrangeiras e a visão `vw_total_venda` (o total da venda é calculado a partir dos itens, e não armazenado).

## 2. Pré-requisitos

- PostgreSQL 16 ou superior (testado no PostgreSQL 19 / Postgres.app no macOS).
- Cliente SQL: `psql` (terminal) ou uma ferramenta gráfica como SQLPro for Postgres ou pgAdmin.
- Usuário com permissão para criar bancos (no Postgres.app, o usuário do sistema).

## 3. Estrutura dos arquivos

| Arquivo | Conteúdo |
|---|---|
| `01_criacao_petcats.sql` | DDL: tabelas, PK, FK, UK, CHECK e visão |
| `02_insercao_petcats.sql` | Carga inicial (INSERT) em transação |
| `03_consultas_petcats.sql` | 5 consultas com JOIN, WHERE, ORDER BY e LIMIT |
| `04a_atualizacao_petcats.sql` | 5 atualizações (UPDATE) condicionadas |
| `04b_exclusao_petcats.sql` | 4 exclusões (DELETE) seguras |
| `05_desempenho_petcats.sql` | Medição com `EXPLAIN ANALYZE` antes e depois dos índices (rodar em cópia do banco) |
| `06_indices_petcats.sql` | Índices de apoio às consultas e às FKs |
| `docs/desempenho.md` | Registro dos resultados de desempenho |
| `docs/git-passo-a-passo.md` | Como versionar e publicar este repositório |
| `README.md` | Este manual |

## 4. Configuração do ambiente

1. Inicie o servidor (Postgres.app → **Start**; porta padrão 5432).
2. Abra o `psql` e crie o banco:

```sql
CREATE DATABASE petcats;
\c petcats
```

## 5. Ordem de execução

Execute os scripts **nesta ordem**, a partir da pasta dos arquivos (`\cd <pasta>`):

```sql
\i 01_criacao_petcats.sql     -- cria a estrutura (37 tabelas)
\i 02_insercao_petcats.sql    -- povoa as tabelas
\i 03_consultas_petcats.sql   -- valida a carga com SELECT
\i 04a_atualizacao_petcats.sql -- aplica as atualizações
\i 04b_exclusao_petcats.sql   -- aplica as exclusões
\i 06_indices_petcats.sql     -- cria os índices de apoio (opcional)
```

A ordem respeita a integridade referencial: tabelas "pai" são criadas e povoadas antes das "filhas".

## 6. Validação esperada

- Após o script 01: a contagem de tabelas do esquema `public` em `information_schema.tables` retorna 37.
- Após o script 02: conferência final com 6 tutores, 8 gatos, 6 consultas, 5 vendas e 11 itens.
- Script 03: as consultas retornam 4, 5, 3, 2 e 4 linhas.
- Script 04a: `UPDATE 1, 3, 1, 1, 1`. Script 04b: `DELETE 1` em cada comando.
- Script 06: a conferência final lista 9 índices `idx_*`.

## 7. Regras de segurança adotadas

- Todo UPDATE e DELETE usa **WHERE** por chave ou condição de negócio precisa.
- Cargas e alterações rodam em **transação** (`BEGIN … COMMIT`); em caso de erro, `ROLLBACK`.
- `ON DELETE CASCADE` só em tabelas dependentes (telefones, associativas, ocorrências, resultados e itens).
- Exemplo: `DELETE FROM tutor WHERE id_tutor = 1;` falha com violação de `fk_gato_tutor`, impedindo registros órfãos.

## 8. Desempenho

O PostgreSQL cria índices automaticamente para PRIMARY KEY e UNIQUE, mas **não** para chaves estrangeiras. O script `06_indices_petcats.sql` cria índices nas colunas usadas em JOIN, WHERE e ORDER BY das consultas.

Com a carga acadêmica (poucas linhas), o planejador sempre usa Seq Scan, e o efeito dos índices não aparece. Para medir, o `05_desempenho_petcats.sql` gera volume sintético em uma **cópia** do banco e compara os planos de execução:

```sql
CREATE DATABASE petcats_perf TEMPLATE petcats;
\c petcats_perf
\i 05_desempenho_petcats.sql
```

O script termina em `ROLLBACK`. Os resultados ficam registrados em [`docs/desempenho.md`](docs/desempenho.md).

## 9. Versionamento

O histórico do projeto é mantido com Git. Convenção de mensagens de commit: `tipo: descrição curta`, com os tipos `feat` (nova funcionalidade ou script), `fix` (correção), `docs` (documentação) e `perf` (desempenho). Passo a passo em [`docs/git-passo-a-passo.md`](docs/git-passo-a-passo.md).

## 10. Observações

- Os INSERTs não informam os ids (IDENTITY); a carga supõe um banco recém-criado.
- Para reiniciar do zero: `DROP SCHEMA public CASCADE; CREATE SCHEMA public;` e repita a seção 5.
- Os dados são fictícios e servem apenas para fins acadêmicos.

## Autor

Paulo de Negreiros Ramos – Tecnologia em Inteligência Artificial, Universidade Cruzeiro do Sul.
