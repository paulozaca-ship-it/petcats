-- =====================================================================
-- Petcats - Índices de apoio às consultas (DDL: CREATE INDEX)
-- SGBD: PostgreSQL 16+ | Banco: petcats | Pré-requisito: 01_criacao_petcats.sql
--
-- O PostgreSQL cria índice automaticamente para PRIMARY KEY e UNIQUE,
-- mas não para FOREIGN KEY. Os índices abaixo cobrem as colunas usadas
-- em JOIN, WHERE e ORDER BY do 03_consultas_petcats.sql e as FKs mais
-- consultadas. IF NOT EXISTS torna o script seguro para rodar de novo.
--
-- Antes de aplicar, confira no psql se já não existe índice equivalente
-- com outro nome criado no script 01:  \di
-- =====================================================================

BEGIN;

-- CONSULTA 1: filtro por cidade e junção gato -> tutor
CREATE INDEX IF NOT EXISTS idx_tutor_cidade  ON tutor (cidade);
CREATE INDEX IF NOT EXISTS idx_gato_id_tutor ON gato (id_tutor);

-- CONSULTA 2: período das consultas e junção consulta -> gato
CREATE INDEX IF NOT EXISTS idx_consulta_data    ON consulta (data);
CREATE INDEX IF NOT EXISTS idx_consulta_id_gato ON consulta (id_gato);

-- CONSULTA 3: período das vendas e itens por venda
CREATE INDEX IF NOT EXISTS idx_venda_data          ON venda (data);
CREATE INDEX IF NOT EXISTS idx_item_venda_id_venda ON item_venda (id_venda);

-- CONSULTA 4: lembretes de reforço e celular do tutor
CREATE INDEX IF NOT EXISTS idx_aplicacao_vacina_proxima_dose ON aplicacao_vacina (proxima_dose);
CREATE INDEX IF NOT EXISTS idx_telefone_tutor_tutor_tipo     ON telefone_tutor (id_tutor, tipo);

-- CONSULTA 5: estoque por produto
CREATE INDEX IF NOT EXISTS idx_lote_produto_id_produto ON lote_produto (id_produto);

COMMIT;

-- Conferência: lista os índices criados por este script
SELECT tablename, indexname
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname LIKE 'idx\_%'
ORDER BY tablename, indexname;
