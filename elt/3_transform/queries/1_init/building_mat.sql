-- Values taken from DBTOPO doc references :
-- http://piece-jointe-carto.developpement-durable.gouv.fr/NAT004/DTerNP/html3/annexes/desc_pb40_pevprincipale_dmatto.html
-- http://piece-jointe-carto.developpement-durable.gouv.fr/NAT004/DTerNP/html3/annexes/desc_pb40_pevprincipale_dmatgm.html

CREATE TABLE public.building_mat_wall
(
    id smallserial PRIMARY KEY,
    label character varying(2) NOT NULL,
    description character varying(32)
);

ALTER TABLE IF EXISTS public.building_mat_wall
    OWNER to admin;

CREATE TABLE public.building_mat_roof
(
    id smallserial PRIMARY KEY,
    label character varying(2) NOT NULL,
    description character varying(32)
);

ALTER TABLE IF EXISTS public.building_mat_roof
    OWNER to admin;

INSERT INTO public.building_mat_wall(label, description)
VALUES
('0', 'INDETERMINE'),
('1', 'PIERRE'),
('2', 'MEULIERE'),
('3', 'BETON'),
('4', 'BRIQUES'),
('5', 'AGGLOMERE'),
('6', 'BOIS'),
('9', 'AUTRES'),
('10', 'PIERRE'),
('11', 'PIERRE'),
('12', 'MEULIERE - PIERRE'),
('13', 'BETON - PIERRE'),
('14', 'BRIQUES - PIERRE'),
('15', 'AGGLOMERE - PIERRE'),
('16', 'BOIS - PIERRE'),
('19', 'PIERRE - AUTRES'),
('20', 'MEULIERE'),
('21', 'MEULIERE - PIERRE'),
('22', 'MEULIERE'),
('23', 'BETON - MEULIERE'),
('24', 'BRIQUES - MEULIERE'),
('25', 'AGGLOMERE - MEULIERE'),
('26', 'BOIS - MEULIERE'),
('29', 'MEULIERE - AUTRES'),
('30', 'BETON'),
('31', 'BETON - PIERRE'),
('32', 'BETON - MEULIERE'),
('33', 'BETON'),
('34', 'BETON - BRIQUES'),
('35', 'AGGLOMERE - BETON'),
('36', 'BETON - BOIS'),
('39', 'BETON - AUTRES'),
('40', 'BRIQUES'),
('41', 'BRIQUES - PIERRE'),
('42', 'BRIQUES - MEULIERE'),
('43', 'BETON - BRIQUES'),
('44', 'BRIQUES'),
('45', 'AGGLOMERE - BRIQUES'),
('46', 'BOIS - BRIQUES'),
('49', 'BRIQUES - AUTRES'),
('50', 'AGGLOMERE'),
('51', 'AGGLOMERE - PIERRE'),
('52', 'AGGLOMERE - MEULIERE'),
('53', 'AGGLOMERE - BETON'),
('54', 'AGGLOMERE - BRIQUES'),
('55', 'AGGLOMERE'),
('56', 'AGGLOMERE - BOIS'),
('59', 'AGGLOMERE - AUTRES'),
('60', 'BOIS'),
('61', 'BOIS - PIERRE'),
('62', 'BOIS - MEULIERE'),
('63', 'BETON - BOIS'),
('64', 'BOIS - BRIQUES'),
('65', 'AGGLOMERE - BOIS'),
('66', 'BOIS'),
('69', 'BOIS - AUTRES'),
('90', 'AUTRES'),
('91', 'PIERRE - AUTRES'),
('92', 'MEULIERE - AUTRES'),
('93', 'BETON - AUTRES'),
('94', 'BRIQUES - AUTRES'),
('95', 'AGGLOMERE - AUTRES'),
('96', 'BOIS - AUTRES'),
('99', 'AUTRES');

INSERT INTO public.building_mat_roof(label, description)
VALUES
('0', 'INDETERMINE'),
('1', 'TUILES'),
('2', 'ARDOISES'),
('3', 'ZINC ALUMINIUM'),
('4', 'BETON'),
('9', 'AUTRES'),
('00', 'INDETERMINE'),
('01', 'TUILES'),
('02', 'ARDOISES'),
('03', 'ZINC ALUMINIUM'),
('04', 'BETON'),
('09', 'AUTRES'),
('10', 'TUILES'),
('11', 'TUILES'),
('12', 'ARDOISES - TUILES'),
('13', 'TUILES - ZINC ALUMINIUM'),
('14', 'BETON - TUILES'),
('19', 'TUILES - AUTRES'),
('20', 'ARDOISES'),
('21', 'ARDOISES - TUILES'),
('22', 'ARDOISES'),
('23', 'ARDOISES - ZINC ALUMINIUM'),
('24', 'ARDOISES - BETON'),
('29', 'ARDOISES - AUTRES'),
('30', 'ZINC ALUMINIUM'),
('31', 'TUILES - ZINC ALUMINIUM'),
('32', 'ARDOISES - ZINC ALUMINIUM'),
('33', 'ZINC ALUMINIUM'),
('34', 'BETON - ZINC ALUMINIUM'),
('39', 'ZINC ALUMINIUM - AUTRES'),
('40', 'BETON'),
('41', 'BETON - TUILES'),
('42', 'ARDOISES - BETON'),
('43', 'BETON - ZINC ALUMINIUM'),
('44', 'BETON'),
('49', 'BETON - AUTRES'),
('90', 'AUTRES'),
('91', 'TUILES - AUTRES'),
('92', 'ARDOISES - AUTRES'),
('93', 'ZINC ALUMINIUM - AUTRES'),
('94', 'BETON - AUTRES'),
('99', 'AUTRES');
