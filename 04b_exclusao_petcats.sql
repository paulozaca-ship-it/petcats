-- =====================================================================
-- Petcats - Script de exclusão (DML: DELETE)
-- SGBD: PostgreSQL 19 | Banco: petcats | Pré-requisito: 04a_atualizacao_petcats.sql
-- Regras adotadas:
--  * todo DELETE tem WHERE preciso (PK ou condição de negócio);
--  * antes de excluir um registro "pai", NOT EXISTS confirma que não há
--    filhos com FK RESTRICT (gatos, vendas, itens, lotes...);
--  * ON DELETE CASCADE existe apenas para tabelas dependentes
--    (telefones, associativas e itens), que não fazem sentido sozinhas;
--  * tudo em transação, com conferência antes do COMMIT.
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- DELETE 1 - Limpeza de agendamentos cancelados já vencidos
-- Remove apenas os cancelados com data anterior a hoje (agendamento 3).
-- O agendamento 6, cancelado mas futuro, é preservado pelo filtro de
-- data. Os serviços ligados em agendamento_servico são removidos por
-- ON DELETE CASCADE (fk_agserv_agendamento).
-- ---------------------------------------------------------------------
DELETE FROM agendamento
WHERE  status = 'cancelado'
  AND  data < CURRENT_DATE;

-- ---------------------------------------------------------------------
-- DELETE 2 - Remoção de telefone desatualizado
-- A tutora Mariana (id 1) não usa mais o telefone residencial.
-- A condição EXISTS garante que ela continue com pelo menos um
-- outro telefone, respeitando a cardinalidade 1..N do modelo.
-- ---------------------------------------------------------------------
DELETE FROM telefone_tutor tt
WHERE  tt.id_tutor = 1
  AND  tt.tipo = 'residencial'
  AND  EXISTS (SELECT 1 FROM telefone_tutor o
               WHERE o.id_tutor = tt.id_tutor
                 AND o.id_telefone <> tt.id_telefone);

-- ---------------------------------------------------------------------
-- DELETE 3 - Exclusão de tutor sem vínculos
-- O tutor Paulo Henrique Mota (id 6) pediu a exclusão do cadastro.
-- Só é excluído se não tiver gatos nem vendas (FKs RESTRICT); o
-- telefone dele é removido junto por CASCADE (fk_teltutor_tutor).
-- ---------------------------------------------------------------------
DELETE FROM tutor t
WHERE  t.id_tutor = 6
  AND  NOT EXISTS (SELECT 1 FROM gato  g WHERE g.id_tutor = t.id_tutor)
  AND  NOT EXISTS (SELECT 1 FROM venda v WHERE v.id_tutor = t.id_tutor);

-- ---------------------------------------------------------------------
-- DELETE 4 - Produto descontinuado sem histórico
-- A "Areia de Madeira 3 kg" (id 5) saiu de linha. Só pode ser removida
-- porque nunca foi vendida, não tem lote nem movimentação de estoque.
-- O vínculo com o fornecedor (produto_fornecedor) sai por CASCADE.
-- ---------------------------------------------------------------------
DELETE FROM produto p
WHERE  p.id_produto = 5
  AND  NOT EXISTS (SELECT 1 FROM item_venda i           WHERE i.id_produto = p.id_produto)
  AND  NOT EXISTS (SELECT 1 FROM lote_produto l         WHERE l.id_produto = p.id_produto)
  AND  NOT EXISTS (SELECT 1 FROM movimentacao_estoque m WHERE m.id_produto = p.id_produto);

-- Conferência antes de confirmar
SELECT id_agendamento, data, status FROM agendamento ORDER BY id_agendamento;
SELECT id_tutor, tipo, numero FROM telefone_tutor WHERE id_tutor IN (1, 6);
SELECT COUNT(*) AS tutores FROM tutor;
SELECT COUNT(*) AS vinculos_produto_5 FROM produto_fornecedor WHERE id_produto = 5;

COMMIT;

-- ---------------------------------------------------------------------
-- EXEMPLO DE EXCLUSÃO BLOQUEADA PELA INTEGRIDADE REFERENCIAL
-- (deixado comentado de propósito)
-- DELETE FROM tutor WHERE id_tutor = 1;
-- Resultado esperado: ERROR: update or delete on table "tutor" violates
-- foreign key constraint "fk_gato_tutor" on table "gato".
-- A tutora 1 tem gatos e vendas; o banco impede apagar o "pai" e
-- deixar registros "órfãos". O correto é tratar antes as dependências
-- (transferir os gatos ou inativar o cadastro), nunca forçar a exclusão.
-- ---------------------------------------------------------------------
