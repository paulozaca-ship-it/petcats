-- =====================================================================
-- Petcats - Script de consultas relacionais (DML: SELECT)
-- SGBD: PostgreSQL 19 | Banco: petcats | Pré-requisito: 02_insercao_petcats.sql
-- Cinco consultas exploratórias com JOIN, WHERE, ORDER BY e LIMIT,
-- usadas também para validar a coerência do povoamento.
-- =====================================================================

-- ---------------------------------------------------------------------
-- CONSULTA 1 - Pacientes de São Bernardo do Campo com tutor e raça
-- JOIN de 3 tabelas (gato -> tutor, gato -> raca), filtro por cidade,
-- ordenação por tutor e nome do gato, limitada aos 10 primeiros.
-- ---------------------------------------------------------------------
SELECT t.nome            AS tutor,
       g.nome            AS gato,
       r.nome            AS raca,
       g.sexo,
       DATE_PART('year', AGE(CURRENT_DATE, g.data_nascimento)) AS idade_anos,
       CASE WHEN g.castrado THEN 'Sim' ELSE 'Não' END          AS castrado
FROM gato g
JOIN tutor t ON t.id_tutor = g.id_tutor
JOIN raca  r ON r.id_raca  = g.id_raca
WHERE t.cidade = 'São Bernardo do Campo'
ORDER BY t.nome, g.nome
LIMIT 10;

-- ---------------------------------------------------------------------
-- CONSULTA 2 - Histórico clínico recente (consultas a partir de outubro)
-- JOIN de 5 tabelas: consulta, gato, tutor, funcionario (veterinário)
-- e consulta_diagnostico; os diagnósticos de cada consulta são
-- agrupados em uma única coluna com STRING_AGG.
-- ---------------------------------------------------------------------
SELECT c.id_consulta,
       TO_CHAR(c.data, 'DD/MM/YYYY HH24:MI')                    AS data_consulta,
       g.nome                                                   AS gato,
       t.nome                                                   AS tutor,
       f.nome                                                   AS veterinario,
       c.queixa,
       STRING_AGG(cd.descricao, '; ' ORDER BY cd.descricao)     AS diagnosticos
FROM consulta c
JOIN gato        g  ON g.id_gato        = c.id_gato
JOIN tutor       t  ON t.id_tutor       = g.id_tutor
JOIN veterinario v  ON v.id_funcionario = c.id_funcionario
JOIN funcionario f  ON f.id_funcionario = v.id_funcionario
LEFT JOIN consulta_diagnostico cd ON cd.id_consulta = c.id_consulta
WHERE c.data >= '2026-10-01'
GROUP BY c.id_consulta, c.data, g.nome, t.nome, f.nome, c.queixa
ORDER BY c.data DESC
LIMIT 5;

-- ---------------------------------------------------------------------
-- CONSULTA 3 - Vendas de novembro com maior faturamento
-- O total é calculado a partir dos itens (o valor_total foi removido
-- de VENDA na 3FN). LEFT JOIN com TUTOR mantém a venda de balcão.
-- ---------------------------------------------------------------------
SELECT v.id_venda,
       TO_CHAR(v.data, 'DD/MM/YYYY')                    AS data_venda,
       COALESCE(t.nome, 'Venda de balcão')              AS cliente,
       f.nome                                           AS atendente,
       v.forma_pagamento,
       COUNT(i.id_item)                                 AS qtd_itens,
       SUM(i.quantidade * i.preco_cobrado)              AS valor_total
FROM venda v
JOIN funcionario f   ON f.id_funcionario = v.id_funcionario
JOIN item_venda  i   ON i.id_venda       = v.id_venda
LEFT JOIN tutor  t   ON t.id_tutor       = v.id_tutor
WHERE v.data BETWEEN '2026-11-01' AND '2026-11-30 23:59:59'
GROUP BY v.id_venda, v.data, t.nome, f.nome, v.forma_pagamento
ORDER BY valor_total DESC
LIMIT 3;

-- ---------------------------------------------------------------------
-- CONSULTA 4 - Lembretes de vacina: reforços que vencem até 31/01/2027
-- JOIN de 6 tabelas para montar a lista de contato com o tutor:
-- aplicacao_vacina, lote_vacina, vacina, gato, tutor e telefone_tutor.
-- ---------------------------------------------------------------------
SELECT TO_CHAR(a.proxima_dose, 'DD/MM/YYYY')  AS proxima_dose,
       g.nome                                 AS gato,
       vc.nome                                AS vacina,
       lv.numero_lote,
       t.nome                                 AS tutor,
       tt.numero                              AS celular
FROM aplicacao_vacina a
JOIN lote_vacina    lv ON lv.id_lote   = a.id_lote
JOIN vacina         vc ON vc.id_vacina = lv.id_vacina
JOIN gato           g  ON g.id_gato    = a.id_gato
JOIN tutor          t  ON t.id_tutor   = g.id_tutor
JOIN telefone_tutor tt ON tt.id_tutor  = t.id_tutor AND tt.tipo = 'celular'
WHERE a.proxima_dose <= '2027-01-31'
ORDER BY a.proxima_dose
LIMIT 10;

-- ---------------------------------------------------------------------
-- CONSULTA 5 - Produtos com estoque abaixo do mínimo e fornecedor
-- mais barato. LEFT JOIN com LOTE_PRODUTO para não perder produtos
-- sem lote (estoque zero); subconsulta escolhe o menor custo.
-- ---------------------------------------------------------------------
SELECT p.nome                                   AS produto,
       c.nome                                   AS categoria,
       COALESCE(SUM(lp.quantidade), 0)          AS estoque_atual,
       p.estoque_minimo,
       fo.razao_social                          AS fornecedor_sugerido,
       pf.preco_custo,
       pf.prazo_entrega_dias
FROM produto p
JOIN categoria c ON c.id_categoria = p.id_categoria
LEFT JOIN lote_produto lp ON lp.id_produto = p.id_produto
LEFT JOIN produto_fornecedor pf
       ON pf.id_produto = p.id_produto
      AND pf.preco_custo = (SELECT MIN(x.preco_custo)
                            FROM produto_fornecedor x
                            WHERE x.id_produto = p.id_produto)
LEFT JOIN fornecedor fo ON fo.id_fornecedor = pf.id_fornecedor
WHERE c.nome <> 'Farmácia'
GROUP BY p.id_produto, p.nome, c.nome, p.estoque_minimo,
         fo.razao_social, pf.preco_custo, pf.prazo_entrega_dias
HAVING COALESCE(SUM(lp.quantidade), 0) < p.estoque_minimo
ORDER BY estoque_atual, p.nome
LIMIT 5;
