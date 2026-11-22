-- =====================================================================
-- Petcats - Script de atualização (DML: UPDATE)
-- SGBD: PostgreSQL 19 | Banco: petcats | Pré-requisito: 02_insercao_petcats.sql
-- Regras adotadas:
--  * todo UPDATE tem WHERE pela PK/UK ou por condição de negócio precisa;
--  * sempre que possível, a condição repete o estado esperado (ex.: saida
--    IS NULL), para que o comando não altere nada se for executado de
--    novo (idempotência). O reajuste de preço (UPDATE 2) deve rodar uma
--    única vez, por isso fica dentro da transação controlada;
--  * o bloco roda em transação; antes do COMMIT os SELECTs conferem o
--    resultado (em caso de erro, usar ROLLBACK).
-- =====================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- UPDATE 1 - Check-out do hotel
-- A hospedagem 3 (gata Mia, quarto 301) está em andamento (saida NULL).
-- Registra a saída; a condição saida IS NULL evita sobrescrever uma
-- data já gravada. O CHECK ck_hosp_periodo garante saida > entrada.
-- ---------------------------------------------------------------------
UPDATE hospedagem
SET    saida = '2026-11-21 17:00'
WHERE  id_hospedagem = 3
  AND  saida IS NULL;

-- ---------------------------------------------------------------------
-- UPDATE 2 - Reajuste de 10% nos serviços de banho e tosa
-- Altera somente os três serviços pelo nome (UK). O preço histórico das
-- vendas e agendamentos já realizados NÃO muda, pois fica gravado em
-- item_venda.preco_cobrado e agendamento_servico.preco_cobrado (3FN).
-- ---------------------------------------------------------------------
UPDATE servico
SET    preco = ROUND(preco * 1.10, 2)
WHERE  nome IN ('Banho', 'Tosa higiênica', 'Tosa completa');

-- ---------------------------------------------------------------------
-- UPDATE 3 - Registro de castração
-- O gato Frajola (id 5) passou pela cirurgia avaliada na consulta 4.
-- ---------------------------------------------------------------------
UPDATE gato
SET    castrado = TRUE
WHERE  id_gato = 5
  AND  castrado = FALSE;

-- ---------------------------------------------------------------------
-- UPDATE 4 - Cancelamento de agendamento futuro
-- A tutora do Simba cancelou o banho de 26/11. Só cancela se ainda
-- estiver 'agendado' (não altera atendimentos já concluídos).
-- O CHECK ck_agend_status aceita apenas valores válidos.
-- ---------------------------------------------------------------------
UPDATE agendamento
SET    status = 'cancelado'
WHERE  id_agendamento = 6
  AND  status = 'agendado';

-- ---------------------------------------------------------------------
-- UPDATE 5 - Atualização cadastral do tutor
-- O tutor João Batista Nunes informou e-mail. A busca é pelo CPF (UK).
-- ---------------------------------------------------------------------
UPDATE tutor
SET    email = 'joao.nunes@email.com'
WHERE  cpf = '45678901234'
  AND  email IS NULL;

-- Conferência antes de confirmar
SELECT id_hospedagem, entrada, saida FROM hospedagem WHERE id_hospedagem = 3;
SELECT nome, preco FROM servico WHERE nome IN ('Banho', 'Tosa higiênica', 'Tosa completa');
SELECT nome, castrado FROM gato WHERE id_gato = 5;
SELECT id_agendamento, data, status FROM agendamento WHERE id_agendamento = 6;
SELECT nome, email FROM tutor WHERE cpf = '45678901234';

COMMIT;
