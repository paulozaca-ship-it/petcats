# Registro de desempenho – Petcats

Comparação dos planos de execução antes e depois dos índices, gerada com `05_desempenho_petcats.sql` em uma cópia do banco (`petcats_perf`) com volume sintético: 50 mil tutores, 100 mil gatos e 200 mil consultas.

## Como ler o EXPLAIN ANALYZE

- **Seq Scan**: lê a tabela inteira. Bom para tabelas pequenas ou quando a maior parte das linhas será usada.
- **Index Scan / Bitmap Index Scan**: usa o índice para ir direto às linhas filtradas.
- **Execution Time**: tempo real da execução, em milissegundos.
- **Buffers (shared hit/read)**: páginas lidas da memória ou do disco; quanto menos, melhor.

## Resultados

Preencha com os números da sua máquina (os da coluna "Referência" vêm de um teste em PostgreSQL 16 com um esquema simplificado).

| Consulta | Plano antes | Tempo antes | Plano depois | Tempo depois | Referência (antes → depois) |
|---|---|---|---|---|---|
| 1 – Gatos de São Bernardo do Campo | Seq Scan em `tutor` e `gato` | | Bitmap Index Scan em `idx_tutor_cidade` | | 21 ms → 17 ms |
| 2 – Consultas desde 01/10/2026 | Parallel Seq Scan + Sort | | Index Scan Backward em `idx_consulta_data` | | 12 ms → 0,06 ms |

## Análise

- **Consulta 2** é o caso clássico: o filtro por data seleciona cerca de 1,5% das linhas e o `ORDER BY data DESC LIMIT 5` é atendido percorrendo o índice de trás para frente. O banco lê só 5 linhas em vez de 200 mil e não precisa ordenar.
- **Consulta 1** melhora menos. O índice de cidade é usado, mas o planejador continua lendo `gato` inteira e fazendo Hash Join, porque considera isso mais barato do que 500 buscas no índice `idx_gato_id_tutor`. Lição: **criar um índice não garante que ele será usado**; quem decide é o planejador, com base nas estatísticas (`ANALYZE`).
- Com a carga acadêmica (6 tutores, 8 gatos), nenhum índice é usado: ler poucas páginas inteiras custa menos que consultar o índice.

## Custos dos índices

Cada índice acelera leituras, mas ocupa espaço e deixa INSERT, UPDATE e DELETE um pouco mais lentos, pois também precisa ser atualizado. Por isso o `06_indices_petcats.sql` cobre só as colunas que aparecem de fato em JOIN, WHERE e ORDER BY.
