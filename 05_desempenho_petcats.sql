-- =====================================================================
-- Petcats - Medição de desempenho com EXPLAIN ANALYZE (antes x depois)
-- SGBD: PostgreSQL 16+ | Pré-requisito: scripts 01 a 04b executados
--
-- IMPORTANTE: rode este script em uma CÓPIA do banco, nunca no petcats:
--   CREATE DATABASE petcats_perf TEMPLATE petcats;
--   \c petcats_perf
--   \i 05_desempenho_petcats.sql
--
-- Por quê: com 6 tutores e 8 gatos o planejador sempre escolhe Seq Scan
-- (ler a tabela inteira é mais barato que usar um índice). Para o índice
-- fazer diferença, o script gera volume sintético (50 mil tutores,
-- 100 mil gatos, 200 mil consultas). Tudo roda em uma transação que
-- termina em ROLLBACK, mas as sequências IDENTITY avançam mesmo assim
-- (sequências não são transacionais) - mais um motivo para usar a cópia.
-- =====================================================================

\timing on

BEGIN;

-- ---------------------------------------------------------------------
-- ETAPA 1 - Volume sintético
-- Tutores: 1% em São Bernardo do Campo, o restante espalhado em 99
-- cidades fictícias. Isso torna o filtro por cidade seletivo.
-- ---------------------------------------------------------------------
INSERT INTO tutor (nome, cpf, email, cep, logradouro, numero, complemento, bairro, cidade, uf)
SELECT 'Tutor sintético ' || i,
       '8' || LPAD(i::text, 10, '0'),             -- CPF fictício e único
       NULL,
       '09700000',
       'Rua Teste',
       (i % 999 + 1)::text,
       NULL,
       'Centro',
       CASE WHEN i % 100 = 0 THEN 'São Bernardo do Campo'
            ELSE 'Cidade ' || (i % 100) END,
       'SP'
FROM generate_series(1, 50000) AS i;

-- Gatos: 2 por tutor sintético, raças 1 a 6
INSERT INTO gato (id_tutor, id_raca, nome, sexo, data_nascimento, padrao_pelagem, microchip, castrado)
SELECT t.id_tutor,
       1 + (n % 6),
       'Gato ' || t.id_tutor || '-' || n,
       CASE WHEN n % 2 = 0 THEN 'M' ELSE 'F' END,
       DATE '2015-01-01' + (t.id_tutor % 3000),
       'Tigrado',
       NULL,
       (n % 3 <> 0)
FROM tutor t
CROSS JOIN generate_series(1, 2) AS n
WHERE t.nome LIKE 'Tutor sintético %';

-- Consultas: 200 mil espalhadas em ~10 anos, veterinários 1 a 3.
-- Só ~1,5% caem a partir de 01/10/2026 (filtro da CONSULTA 2).
INSERT INTO consulta (id_gato, id_funcionario, data, queixa, peso_kg, conduta)
SELECT g.id_gato,
       1 + (g.id_gato % 3),
       TIMESTAMP '2016-11-30 09:00' + ((g.id_gato * 7 + n) % 3650) * INTERVAL '1 day',
       'Rotina',
       4.00,
       'Sem alterações'
FROM gato g
CROSS JOIN generate_series(1, 2) AS n
WHERE g.nome LIKE 'Gato %-%';

-- Estatísticas atualizadas para o planejador decidir com dados reais
ANALYZE tutor;
ANALYZE gato;
ANALYZE consulta;

-- ---------------------------------------------------------------------
-- ETAPA 2 - ANTES: consultas sem os índices novos
-- Anote no docs/desempenho.md: tipo de scan, "Execution Time" e buffers.
-- ---------------------------------------------------------------------
\echo '===== ANTES - CONSULTA 1 (cidade + gatos) ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT t.nome AS tutor, g.nome AS gato, r.nome AS raca
FROM gato g
JOIN tutor t ON t.id_tutor = g.id_tutor
JOIN raca r ON r.id_raca = g.id_raca
WHERE t.cidade = 'São Bernardo do Campo'
ORDER BY t.nome, g.nome
LIMIT 10;

\echo '===== ANTES - CONSULTA 2 (consultas desde 01/10/2026) ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.id_consulta, c.data, g.nome AS gato, t.nome AS tutor
FROM consulta c
JOIN gato g ON g.id_gato = c.id_gato
JOIN tutor t ON t.id_tutor = g.id_tutor
WHERE c.data >= '2026-10-01'
ORDER BY c.data DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- ETAPA 3 - Índices
-- O PostgreSQL indexa automaticamente PK e UNIQUE, mas NÃO as FKs.
-- As colunas abaixo aparecem em JOIN/WHERE/ORDER BY das consultas.
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_tutor_cidade   ON tutor (cidade);
CREATE INDEX IF NOT EXISTS idx_gato_id_tutor  ON gato (id_tutor);
CREATE INDEX IF NOT EXISTS idx_consulta_data  ON consulta (data);

ANALYZE tutor;
ANALYZE gato;
ANALYZE consulta;

-- ---------------------------------------------------------------------
-- ETAPA 4 - DEPOIS: mesmas consultas, agora com índices
-- ---------------------------------------------------------------------
\echo '===== DEPOIS - CONSULTA 1 ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT t.nome AS tutor, g.nome AS gato, r.nome AS raca
FROM gato g
JOIN tutor t ON t.id_tutor = g.id_tutor
JOIN raca r ON r.id_raca = g.id_raca
WHERE t.cidade = 'São Bernardo do Campo'
ORDER BY t.nome, g.nome
LIMIT 10;

\echo '===== DEPOIS - CONSULTA 2 ====='
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.id_consulta, c.data, g.nome AS gato, t.nome AS tutor
FROM consulta c
JOIN gato g ON g.id_gato = c.id_gato
JOIN tutor t ON t.id_tutor = g.id_tutor
WHERE c.data >= '2026-10-01'
ORDER BY c.data DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- ETAPA 5 - Desfaz tudo (dados sintéticos e índices de teste)
-- Os índices definitivos ficam no 06_indices_petcats.sql.
-- ---------------------------------------------------------------------
ROLLBACK;

\timing off
