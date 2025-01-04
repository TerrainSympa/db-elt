CREATE TABLE forest_essence (
   id smallserial PRIMARY KEY,
   label smallint,
   description VARCHAR(256) UNIQUE
);

INSERT INTO public.forest_essence(label, description)
VALUES
(00, 'Essences non discriminées. Parcelles de surface comprise entre 0,5 ha et 2 ha. Pas de recherche d’identification d’essence par photo-interprétation.'),
(01, 'Chênes décidus'),
(06, 'Chênes sempervirents'),
(09, 'Hêtre'),
(10, 'Châtaignier'),
(14, 'Robinier'),
(49, 'Autre feuillu'),
(51, 'Pin maritime'),
(52, 'Pin sylvestre'),
(53, 'Pin noir ou laricio'),
(57, 'Pin d’Alep'),
(58, 'Pin à crochets'),
(81, 'Autre Pin pur'),
(80, 'Mélange de Pins'),
(61, 'Sapin ou épicéa'),
(63, 'Mélèze'),
(64, 'Douglas'),
(90, 'Mélange de conifères dont aucun n’appartient au Genre pins (Pinus)'),
(91, 'Autre conifère qui n’appartient pas au Genre pins (Pinus)');

INSERT INTO forest_essence (description)
	SELECT essence FROM forest GROUP BY essence
ON CONFLICT DO NOTHING;

ALTER TABLE forest
ADD essence_id smallint,
ADD CONSTRAINT essence_fk FOREIGN KEY(essence_id) REFERENCES forest_essence(id);

CREATE INDEX forest_essence_id_idx
ON forest(essence_id);

UPDATE forest
SET
    essence_id = q.id
FROM (
    SELECT id, description FROM forest_essence
) as q
WHERE q.description = forest.essence;


-- Taken from the official documentation: https://geoservices.ign.fr/sites/default/files/2021-06/DC_BDForet_2-0.pdf
CREATE TABLE public.forest_type
(
    id smallserial PRIMARY KEY,
    label character varying(2) NOT NULL,
    description character varying(256)
);

ALTER TABLE IF EXISTS public.forest_type
    OWNER to admin;

INSERT INTO public.forest_type(label, description)
VALUES
('FF', 'Forêt fermée (plus de 40 % de couvert arboré)'),
('FO', 'Forêt ouverte (entre 10 et 40 % de couvert arboré)'),
('FP', 'Peupleraie (plus de 10 % de couvert arboré et couvert libre relatif des peupliers cultivés supérieur à 75%)'),
('LA', 'Lande (moins de 10% de couvert arboré) et formation herbacée');

CREATE TABLE public.forest_composition
(
    id smallserial PRIMARY KEY,
    label smallint NOT NULL,
    description character varying(256)
);

ALTER TABLE IF EXISTS public.forest_composition
    OWNER to admin;

INSERT INTO public.forest_composition(label, description)
VALUES
(0, 'Composition non discriminée car jeune peuplement, coupe rase ou incident'),
(1, 'Feuillus purs (peuplement pur de feuillus avec un couvert libre relatif supérieur à 75%)'),
(2, 'Conifères purs (peuplement pur de conifères avec un couvert libre relatif supérieur à 75%)'),
(3, 'Mélange de feuillus et de conifères'),
(31, 'Mélange à feuillus prépondérants'),
(32, 'Mélange à confères prépondérants'),
(4, 'Couvert de ligneux bas supérieur ou égal à 25% (landes)'),
(6, 'Couvert de ligneux bas inférieur à 25% (formation herbacées)');

/*
SELECT
code_tfv,
LEFT(code_tfv, 2) as forest_type,
NULLIF(regexp_replace(RIGHT(LEFT(split_part(regexp_replace(code_tfv, 'G', '-', 'g'), '-', 1), 4), 2), '\D', '', 'g'), '')::smallint as forest_composition,
NULLIF(split_part(
	CASE
    WHEN POSITION('-' in code_tfv) = 0 THEN NULL
    ELSE regexp_replace(code_tfv, 'G', '-', 'g')
	END
, '-', 2), '')::smallint as forest_essence_1,
NULLIF(split_part(
	CASE
    WHEN POSITION('-' in code_tfv) = 0 THEN NULL
    ELSE regexp_replace(code_tfv, 'G', '-', 'g')
	END
, '-', 3), '')::smallint as forest_essence_2,
CASE
WHEN POSITION('G' in code_tfv) = 0 THEN false
ELSE true
END as is_group,
tfv,
tfv_g11,
essence,
COUNT(*) as n
FROM forest2
GROUP BY code_tfv, tfv,tfv_g11,essence
ORDER BY code_tfv;
*/

ALTER TABLE forest
ADD type_id smallint,
ADD essence_1_id smallint,
ADD essence_2_id smallint,
ADD composition_id smallint,
ADD CONSTRAINT forest_type_fk FOREIGN KEY(type_id) REFERENCES forest_type(id),
ADD CONSTRAINT forest_essence_1_fk FOREIGN KEY(essence_1_id) REFERENCES forest_essence(id),
ADD CONSTRAINT forest_essence_2_fk FOREIGN KEY(essence_2_id) REFERENCES forest_essence(id),
ADD CONSTRAINT forest_composition_fk FOREIGN KEY(composition_id) REFERENCES forest_composition(id);

UPDATE forest
SET
    type_id = q.id
FROM (
    SELECT id, label FROM forest_type
) as q
WHERE q.label = LEFT(forest.code_tfv, 2);

UPDATE forest
SET
    essence_1_id = q.id
FROM (
    SELECT id, label FROM forest_essence
) as q
WHERE q.label = NULLIF(split_part(
	CASE
    WHEN POSITION('-' in code_tfv) = 0 THEN NULL
    ELSE regexp_replace(code_tfv, 'G', '-', 'g')
	END
, '-', 2), '')::smallint
;

UPDATE forest
SET
    essence_2_id = q.id
FROM (
    SELECT id, label FROM forest_essence
) as q
WHERE q.label = NULLIF(split_part(
	CASE
    WHEN POSITION('-' in code_tfv) = 0 THEN NULL
    ELSE regexp_replace(code_tfv, 'G', '-', 'g')
	END
, '-', 3), '')::smallint
;

UPDATE forest
SET
    composition_id = q.id
FROM (
    SELECT id, label FROM forest_composition
) as q
WHERE q.label = NULLIF(regexp_replace(RIGHT(LEFT(split_part(regexp_replace(code_tfv, 'G', '-', 'g'), '-', 1), 4), 2), '\D', '', 'g'), '')::smallint
;
