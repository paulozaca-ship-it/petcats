-- =====================================================================
-- Petcats - Script de povoamento (DML: INSERT)
-- SGBD: PostgreSQL 19 | Banco: petcats | Pré-requisito: 01_criacao_petcats.sql
-- As PKs são geradas por IDENTITY; por isso os INSERTs não informam o id.
-- Em um banco recém-criado, os ids seguem a ordem de inserção (1, 2, 3...),
-- e é essa numeração que as FKs abaixo utilizam (indicada nos comentários).
-- Ordem: catálogos -> pessoas -> especializações -> movimentos,
-- respeitando a integridade referencial (pai sempre antes do filho).
-- =====================================================================

BEGIN;  -- carga em uma única transação: ou tudo é gravado, ou nada

-- ---------------------------------------------------------------------
-- BLOCO 1 - CATÁLOGOS (entidades independentes, sem FK)
-- ---------------------------------------------------------------------

-- Raças (ids 1 a 6). "SRD" = sem raça definida.
INSERT INTO raca (nome, porte, observacoes) VALUES
('SRD',         'medio',   'Sem raça definida'),
('Persa',       'medio',   'Pelagem longa; exige escovação diária'),
('Siamês',      'pequeno', 'Muito vocal e sociável'),
('Maine Coon',  'grande',  'Uma das maiores raças domésticas'),
('Ragdoll',     'grande',  'Temperamento dócil'),
('Bengal',      'medio',   'Muito ativo; pelagem rosetada');

-- Serviços de agenda e de venda (ids 1 a 6)
INSERT INTO servico (nome, descricao, duracao_min, preco) VALUES
('Banho',             'Banho com shampoo neutro e secagem',     60,  80.00),
('Tosa higiênica',    'Tosa de patas, barriga e região íntima', 30,  50.00),
('Tosa completa',     'Tosa em todo o corpo (tosa leão)',       90, 140.00),
('Corte de unhas',    'Corte e lixamento das unhas',            15,  25.00),
('Consulta clínica',  'Atendimento clínico geral',              40, 180.00),
('Aplicação de vacina','Aplicação e registro na carteira',      15,  40.00);

-- Quartos do hotel (ids 1 a 4); a diária pertence ao quarto (3FN)
INSERT INTO quarto (numero, tipo, valor_diaria) VALUES
('101', 'standard',   70.00),
('102', 'standard',   70.00),
('201', 'luxo',      110.00),
('301', 'isolamento',130.00);

-- Categorias de produtos (ids 1 a 4)
INSERT INTO categoria (nome) VALUES
('Ração'), ('Areia sanitária'), ('Brinquedos e acessórios'), ('Farmácia');

-- Vacinas (ids 1 a 3) com intervalo de reforço em dias
INSERT INTO vacina (nome, intervalo_dias) VALUES
('Quádrupla felina (V4)',   365),
('Quíntupla felina (V5)',   365),
('Antirrábica',             365);

-- Doenças prevenidas (ids 1 a 6)
INSERT INTO doenca (nome) VALUES
('Panleucopenia'), ('Rinotraqueíte'), ('Calicivirose'),
('Clamidiose'), ('Leucemia felina (FeLV)'), ('Raiva');

-- Medicamentos (ids 1 a 4)
INSERT INTO medicamento (nome, forma_farmaceutica, concentracao, unidade) VALUES
('Amoxicilina + Clavulanato 50 mg', 'comprimido', 50.00, 'mg'),
('Meloxicam 0,5 mg/mL',             'suspensão',   0.50, 'mg/mL'),
('Gabapentina 100 mg',              'cápsula',   100.00, 'mg'),
('Mirtazapina 2 mg',                'comprimido',  2.00, 'mg');

-- Parâmetros de exame (ids 1 a 5) com faixa de referência felina
INSERT INTO parametro_exame (nome, unidade, valor_referencia) VALUES
('Hematócrito', '%',       '30 - 45'),
('Hemoglobina', 'g/dL',    '9,8 - 15,4'),
('Leucócitos',  'mil/µL',  '5,5 - 19,5'),
('Ureia',       'mg/dL',   '30 - 65'),
('Creatinina',  'mg/dL',   '0,8 - 1,8');

-- ---------------------------------------------------------------------
-- BLOCO 2 - ASSOCIAÇÕES ENTRE CATÁLOGOS (dependem do bloco 1)
-- ---------------------------------------------------------------------

-- Vacina x Doença (N:N): V4 = 4 doenças; V5 = V4 + FeLV; Antirrábica = raiva
INSERT INTO vacina_doenca (id_vacina, id_doenca) VALUES
(1,1),(1,2),(1,3),(1,4),
(2,1),(2,2),(2,3),(2,4),(2,5),
(3,6);

-- Princípios ativos de cada medicamento (1FN: atributo multivalorado)
INSERT INTO med_principio_ativo (id_medicamento, principio_ativo, concentracao) VALUES
(1, 'Amoxicilina',          '40 mg'),
(1, 'Ácido clavulânico',    '10 mg'),
(2, 'Meloxicam',            '0,5 mg/mL'),
(3, 'Gabapentina',          '100 mg'),
(4, 'Mirtazapina',          '2 mg');

-- Lotes de vacina (ids 1 a 4): validade pertence ao lote (3FN)
INSERT INTO lote_vacina (id_vacina, numero_lote, validade, fabricante) VALUES
(1, 'V4-2026A',  '2027-03-31', 'Zoetis'),
(2, 'V5-2026B',  '2027-05-31', 'Boehringer Ingelheim'),
(2, 'V5-2025K',  '2026-12-31', 'Boehringer Ingelheim'),
(3, 'RAB-2026C', '2027-08-31', 'MSD Saúde Animal');

-- ---------------------------------------------------------------------
-- BLOCO 3 - PESSOAS: TUTORES E EQUIPE
-- ---------------------------------------------------------------------

-- Tutores (ids 1 a 6). O tutor 6 ainda não tem gato cadastrado (0..N),
-- o que permite testar LEFT JOIN nas consultas.
INSERT INTO tutor (nome, cpf, email, cep, logradouro, numero, complemento, bairro, cidade, uf) VALUES
('Mariana Souza Lima',    '12345678901', 'mariana.lima@email.com',  '09750000', 'Rua Marechal Deodoro', '1200', 'Apto 42', 'Centro',         'São Bernardo do Campo', 'SP'),
('Ricardo Alves Pereira', '23456789012', 'ricardo.pereira@email.com','09710080', 'Av. Kennedy',          '540',  NULL,      'Jardim do Mar',  'São Bernardo do Campo', 'SP'),
('Fernanda Costa Rocha',  '34567890123', 'fernanda.rocha@email.com', '09015010', 'Rua das Figueiras',    '88',   'Casa 2',  'Jardim',         'Santo André',           'SP'),
('João Batista Nunes',    '45678901234', NULL,                       '09850300', 'Rua Joaquim Nabuco',   '15',   NULL,      'Assunção',       'São Bernardo do Campo', 'SP'),
('Camila Ferreira Dias',  '56789012345', 'camila.dias@email.com',    '04101000', 'Rua Vergueiro',        '3100', 'Apto 81', 'Vila Mariana',   'São Paulo',             'SP'),
('Paulo Henrique Mota',   '67890123456', 'paulo.mota@email.com',     '09720000', 'Rua Jurubatuba',       '702',  NULL,      'Centro',         'São Bernardo do Campo', 'SP');

-- Telefones dos tutores (1..N por tutor, 1FN)
INSERT INTO telefone_tutor (id_tutor, tipo, numero) VALUES
(1, 'celular',     '11987654321'),
(1, 'residencial', '1143321100'),
(2, 'celular',     '11976543210'),
(3, 'celular',     '11965432109'),
(4, 'celular',     '11954321098'),
(4, 'comercial',   '1141234567'),
(5, 'celular',     '11943210987'),
(6, 'celular',     '11932109876');

-- Funcionários (ids 1 a 6). Os ids 1, 2 e 3 também serão veterinários.
INSERT INTO funcionario (nome, cargo, email) VALUES
('Dra. Beatriz Andrade',  'Médica-veterinária',  'beatriz@petcats.com.br'),
('Dr. Lucas Moreira',     'Médico-veterinário',  'lucas@petcats.com.br'),
('Dra. Helena Takahashi', 'Médica-veterinária',  'helena@petcats.com.br'),
('Juliana Prado',         'Recepcionista',       'juliana@petcats.com.br'),
('Rafael Santos',         'Banhista e tosador',  'rafael@petcats.com.br'),
('Aline Vieira',          'Cuidadora do hotel',  'aline@petcats.com.br');

-- Telefones da equipe (0..N)
INSERT INTO telefone_funcionario (id_funcionario, tipo, numero) VALUES
(1, 'celular', '11991110001'),
(2, 'celular', '11991110002'),
(3, 'celular', '11991110003'),
(4, 'celular', '11991110004'),
(5, 'celular', '11991110005');

-- Especialização FUNCIONARIO -> VETERINARIO (PK também é FK)
INSERT INTO veterinario (id_funcionario, numero_crmv, uf_crmv) VALUES
(1, '45210', 'SP'),
(2, '51877', 'SP'),
(3, '39654', 'SP');

-- Especialidades (atributo multivalorado separado na 1FN)
INSERT INTO vet_especialidade (id_funcionario, especialidade) VALUES
(1, 'Clínica médica felina'),
(1, 'Nefrologia'),
(2, 'Dermatologia'),
(3, 'Cirurgia de tecidos moles'),
(3, 'Odontologia');

-- ---------------------------------------------------------------------
-- BLOCO 4 - PACIENTES (dependem de TUTOR e RACA)
-- ---------------------------------------------------------------------

-- Gatos (ids 1 a 8)
INSERT INTO gato (id_tutor, id_raca, nome, sexo, data_nascimento, padrao_pelagem, microchip, castrado) VALUES
(1, 2, 'Luna',     'F', '2019-04-12', 'Branca',              '985112000123451', TRUE),
(1, 1, 'Tom',      'M', '2021-09-03', 'Tigrado cinza',       NULL,              TRUE),
(2, 4, 'Thor',     'M', '2020-01-20', 'Tabby marrom',        '985112000123452', TRUE),
(3, 3, 'Mia',      'F', '2018-07-30', 'Seal point',          '985112000123453', TRUE),
(3, 1, 'Frajola',  'M', '2023-02-14', 'Preto e branco',      NULL,              FALSE),
(4, 5, 'Nina',     'F', '2022-11-05', 'Bicolor azul',        '985112000123454', TRUE),
(5, 6, 'Simba',    'M', '2024-03-18', 'Marrom rosetado',     '985112000123455', FALSE),
(5, 1, 'Pretinha', 'F', '2016-05-25', 'Preta',               NULL,              TRUE);

-- ---------------------------------------------------------------------
-- BLOCO 5 - AGENDA DE SERVIÇOS (banho, tosa, unhas)
-- ---------------------------------------------------------------------

-- Agendamentos (ids 1 a 6), feitos com o banhista (funcionário 5)
INSERT INTO agendamento (id_gato, id_funcionario, data, hora, status) VALUES
(1, 5, '2026-11-03', '09:00', 'concluido'),
(3, 5, '2026-11-05', '10:30', 'concluido'),
(4, 5, '2026-11-10', '14:00', 'cancelado'),
(6, 5, '2026-11-12', '09:30', 'concluido'),
(1, 5, '2026-11-24', '09:00', 'agendado'),
(7, 5, '2026-11-26', '15:00', 'agendado');

-- Serviços de cada agendamento (N:N) com o preço praticado na data
INSERT INTO agendamento_servico (id_agendamento, id_servico, preco_cobrado) VALUES
(1, 1,  80.00), (1, 2,  50.00),
(2, 1,  80.00), (2, 3, 140.00),
(3, 4,  25.00),
(4, 1,  80.00), (4, 4,  25.00),
(5, 1,  80.00),
(6, 1,  80.00), (6, 4,  25.00);

-- ---------------------------------------------------------------------
-- BLOCO 6 - HOTEL (hospedagens e ocorrências)
-- ---------------------------------------------------------------------

-- Hospedagens (ids 1 a 3). A de id 3 está em andamento (saida NULL).
INSERT INTO hospedagem (id_gato, id_quarto, entrada, saida) VALUES
(3, 3, '2026-10-20 08:00', '2026-10-27 18:00'),
(6, 1, '2026-11-01 10:00', '2026-11-04 17:00'),
(4, 4, '2026-11-18 09:00', NULL);

-- Ocorrências registradas durante as estadias
INSERT INTO ocorrencia_hospedagem (id_hospedagem, data_hora, descricao) VALUES
(1, '2026-10-21 20:00', 'Comeu pouco no primeiro dia; adaptação normal'),
(1, '2026-10-24 09:30', 'Escovação realizada; sem intercorrências'),
(2, '2026-11-02 15:00', 'Vômito de bola de pelo; tutora avisada'),
(3, '2026-11-19 11:00', 'Medicação administrada conforme prescrição');

-- ---------------------------------------------------------------------
-- BLOCO 7 - ATENDIMENTO CLÍNICO
-- ---------------------------------------------------------------------

-- Consultas (ids 1 a 6); id_funcionario referencia VETERINARIO
INSERT INTO consulta (id_gato, id_funcionario, data, queixa, peso_kg, conduta) VALUES
(4, 1, '2026-09-15 10:00', 'Aumento da sede e perda de peso',      3.60, 'Solicitado hemograma e bioquímico'),
(1, 2, '2026-10-02 14:30', 'Coceira intensa e falhas no pelo',     4.20, 'Tratamento tópico e retorno em 30 dias'),
(3, 1, '2026-10-10 09:00', 'Check-up anual',                       7.80, 'Paciente saudável; vacinação em dia'),
(5, 3, '2026-10-22 16:00', 'Avaliação pré-castração',              4.50, 'Exames pré-operatórios solicitados'),
(4, 1, '2026-11-17 11:00', 'Retorno: acompanhamento renal',        3.50, 'Ajuste de dieta e medicação'),
(8, 2, '2026-11-19 15:30', 'Inapetência há três dias',             3.10, 'Estimulante de apetite e reavaliação');

-- Diagnósticos (1..N por consulta; atributo multivalorado na 1FN)
INSERT INTO consulta_diagnostico (id_consulta, descricao) VALUES
(1, 'Doença renal crônica (suspeita)'),
(2, 'Dermatite alérgica'),
(3, 'Hígido'),
(4, 'Apto para procedimento cirúrgico'),
(5, 'Doença renal crônica estágio 2'),
(6, 'Hiporexia'),
(6, 'Doença periodontal');

-- Exames (ids 1 a 3)
INSERT INTO exame (id_consulta, tipo, data) VALUES
(1, 'Hemograma e bioquímico', '2026-09-15'),
(4, 'Hemograma pré-operatório', '2026-10-22'),
(5, 'Bioquímico renal', '2026-11-17');

-- Resultados por parâmetro (PK composta exame + parâmetro, 2FN)
INSERT INTO resultado_exame (id_exame, id_parametro, valor) VALUES
(1, 1, 33.000), (1, 2, 11.200), (1, 3, 12.400), (1, 4, 88.000), (1, 5, 2.400),
(2, 1, 38.000), (2, 2, 13.100), (2, 3,  9.800),
(3, 4, 79.000), (3, 5, 2.100);

-- Prescrições (ids 1 a 4)
INSERT INTO prescricao (id_consulta, id_medicamento, dose_qtd, dose_unidade, intervalo_h, duracao_dias) VALUES
(2, 1, 1.00, 'comprimido', 12, 10),
(2, 2, 0.20, 'mL',         24,  5),
(5, 3, 0.50, 'cápsula',    12, 30),
(6, 4, 0.50, 'comprimido', 72, 15);

-- Aplicações de vacina (lote 3 tem validade 2026-12-31)
INSERT INTO aplicacao_vacina (id_gato, id_lote, id_funcionario, data_aplicacao, proxima_dose) VALUES
(3, 2, 1, '2026-10-10', '2027-10-10'),
(3, 4, 1, '2026-10-10', '2027-10-10'),
(1, 1, 2, '2026-03-05', '2027-03-05'),
(6, 3, 3, '2025-12-01', '2026-12-01'),
(7, 2, 3, '2026-06-18', '2027-06-18'),
(2, 1, 2, '2026-01-15', '2027-01-15');

-- Anexos do prontuário (consulta e exame são opcionais)
INSERT INTO anexo (id_gato, id_consulta, id_exame, tipo, caminho, data) VALUES
(4, 1,    1,    'laudo',  '/anexos/gato4/laudo_2026-09-15.pdf', '2026-09-15'),
(1, 2,    NULL, 'foto',   '/anexos/gato1/lesao_2026-10-02.jpg', '2026-10-02'),
(7, NULL, NULL, 'documento','/anexos/gato7/pedigree.pdf',       '2026-03-20');

-- ---------------------------------------------------------------------
-- BLOCO 8 - COMERCIAL: PRODUTOS, ESTOQUE E FORNECEDORES
-- ---------------------------------------------------------------------

-- Produtos (ids 1 a 8)
INSERT INTO produto (id_categoria, nome, preco, estoque_minimo) VALUES
(1, 'Ração Premium Gatos Castrados 3 kg', 139.90, 10),
(1, 'Ração Renal Felina 1,5 kg',          189.90,  5),
(1, 'Sachê Úmido Salmão 85 g',              4.90, 50),
(2, 'Areia Sílica 1,8 kg',                 39.90, 20),
(2, 'Areia de Madeira 3 kg',               29.90, 15),
(3, 'Arranhador Torre 70 cm',             159.00,  3),
(3, 'Varinha com Penas',                   19.90, 10),
(4, 'Vermífugo Felino 2 comprimidos',      34.50, 10);

-- Lotes de produto (validade opcional para itens não perecíveis)
INSERT INTO lote_produto (id_produto, numero_lote, validade, quantidade) VALUES
(1, 'RP-2611', '2027-06-30', 18),
(2, 'RR-2609', '2027-03-31',  4),
(3, 'SU-2610', '2027-01-31', 120),
(4, 'AS-2608', NULL,          25),
(6, 'AT-2601', NULL,           2),
(8, 'VF-2605', '2028-05-31',  14);

-- Movimentações de estoque (entrada, saída, ajuste)
INSERT INTO movimentacao_estoque (id_produto, tipo, quantidade, data) VALUES
(1, 'entrada', 20,  '2026-11-01 08:30'),
(2, 'entrada',  6,  '2026-11-01 08:30'),
(3, 'entrada', 120, '2026-11-01 08:30'),
(4, 'entrada', 30,  '2026-11-01 08:30'),
(1, 'saida',    1,  '2026-11-03 10:15'),
(2, 'saida',    2,  '2026-11-17 12:00'),
(4, 'saida',    5,  '2026-11-12 16:20'),
(6, 'ajuste',   1,  '2026-11-15 18:00');

-- Fornecedores (ids 1 a 3)
INSERT INTO fornecedor (razao_social, cnpj, email) VALUES
('Nutripet Distribuidora Ltda',   '12345678000190', 'vendas@nutripet.com.br'),
('ABC Pet Acessórios Ltda',        '23456789000101', 'contato@abcpet.com.br'),
('VetFarma Comércio de Medicamentos Ltda','34567890000112', 'pedidos@vetfarma.com.br');

INSERT INTO telefone_fornecedor (id_fornecedor, tipo, numero) VALUES
(1, 'comercial', '1140041000'),
(2, 'comercial', '1144332211'),
(3, 'celular',   '11988887777');

-- Produto x Fornecedor (N:N) com custo e prazo de entrega
INSERT INTO produto_fornecedor (id_produto, id_fornecedor, preco_custo, prazo_entrega_dias) VALUES
(1, 1,  92.00, 3), (2, 1, 128.00, 5), (3, 1, 2.60, 3),
(4, 2,  22.00, 4), (5, 2, 16.00, 4),  (6, 2, 95.00, 7), (7, 2, 9.50, 4),
(8, 3,  19.00, 2), (2, 3, 131.50, 2);

-- ---------------------------------------------------------------------
-- BLOCO 9 - VENDAS (dependem de TUTOR, FUNCIONARIO, PRODUTO e SERVICO)
-- ---------------------------------------------------------------------

-- Vendas (ids 1 a 5). A venda 4 é de balcão: sem tutor cadastrado (0..1).
INSERT INTO venda (id_tutor, id_funcionario, data, forma_pagamento) VALUES
(1,    4, '2026-11-03 10:15', 'pix'),
(2,    4, '2026-11-05 12:20', 'credito'),
(3,    4, '2026-11-17 12:05', 'debito'),
(NULL, 4, '2026-11-12 16:20', 'dinheiro'),
(5,    4, '2026-11-19 16:10', 'credito');

-- Itens: cada item é produto OU serviço (CHECK ck_item_exclusivo);
-- preco_cobrado guarda o preço histórico praticado na venda.
INSERT INTO item_venda (id_venda, id_produto, id_servico, quantidade, preco_cobrado) VALUES
(1, NULL, 1, 1,  80.00),
(1, NULL, 2, 1,  50.00),
(1, 1,    NULL, 1, 139.90),
(2, NULL, 1, 1,  80.00),
(2, NULL, 3, 1, 140.00),
(2, 7,    NULL, 2,  19.90),
(3, 2,    NULL, 2, 179.90),   -- desconto sobre o preço de tabela
(3, NULL, 5, 1, 180.00),
(4, 4,    NULL, 5,  39.90),
(5, NULL, 5, 1, 180.00),
(5, 3,    NULL, 12,  4.90);

COMMIT;

-- Conferência rápida da carga
SELECT 'tutor' AS tabela, COUNT(*) FROM tutor
UNION ALL SELECT 'gato', COUNT(*) FROM gato
UNION ALL SELECT 'consulta', COUNT(*) FROM consulta
UNION ALL SELECT 'venda', COUNT(*) FROM venda
UNION ALL SELECT 'item_venda', COUNT(*) FROM item_venda;
