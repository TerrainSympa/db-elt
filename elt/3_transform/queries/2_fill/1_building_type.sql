-- Nature type
CREATE TABLE building_nature (
   id smallserial PRIMARY KEY,
   nature VARCHAR(64) UNIQUE
);

INSERT INTO building_nature (nature)
	SELECT nature FROM building GROUP BY nature
ON CONFLICT DO NOTHING;

ALTER TABLE building
ADD nature_id smallint,
ADD CONSTRAINT nature_fk FOREIGN KEY(nature_id) REFERENCES building_nature(id);

UPDATE building
SET
    nature_id = q.id
FROM (
    SELECT id, nature FROM building_nature
) as q
WHERE q.nature = building.nature;

-- Usage type

CREATE TABLE building_usage (
   id smallserial PRIMARY KEY,
   busage VARCHAR(64) UNIQUE
);

INSERT INTO building_usage (busage)
	WITH q1 as (
		SELECT usage1 as u
		FROM building
		GROUP BY usage1
	),
	q2 as (
		SELECT usage2 as u
		FROM building
		GROUP BY usage2
	)
	SELECT DISTINCT u
	FROM q1 FULL OUTER JOIN q2 USING(u)
ON CONFLICT DO NOTHING;

ALTER TABLE building
ADD usage1_id smallint,
ADD CONSTRAINT usage1_fk FOREIGN KEY(usage1_id) REFERENCES building_usage(id);

ALTER TABLE building
ADD usage2_id smallint,
ADD CONSTRAINT usage2_fk FOREIGN KEY(usage2_id) REFERENCES building_usage(id);

UPDATE building
SET
    usage1_id = q.id
FROM (
    SELECT id, busage FROM building_usage
) as q
WHERE q.busage = building.usage1;

UPDATE building
SET
    usage2_id = q.id
FROM (
    SELECT id, busage FROM building_usage
) as q
WHERE q.busage = building.usage2;

ALTER TABLE building
ADD lightweight BOOLEAN;

UPDATE building
SET
    lightweight = true
WHERE leger = 'oui';
UPDATE building
SET
    lightweight = false
WHERE leger = 'non';

ALTER TABLE building
ADD mat_wall_id smallint,
ADD CONSTRAINT building_mat_wall_fk FOREIGN KEY(mat_wall_id) REFERENCES building_mat_wall(id);
UPDATE building
SET
    mat_wall_id = q.id
FROM (
    SELECT id, label FROM building_mat_wall
) as q
WHERE q.label = building.mat_murs;

ALTER TABLE building
ADD mat_roof_id smallint,
ADD CONSTRAINT building_mat_roof_fk FOREIGN KEY(mat_roof_id) REFERENCES building_mat_roof(id);
UPDATE building
SET
    mat_roof_id = q.id
FROM (
    SELECT id, label FROM building_mat_roof
) as q
WHERE q.label = building.mat_toits;

CREATE TABLE building_origin (
   id smallserial PRIMARY KEY,
   label VARCHAR(64) UNIQUE
);
INSERT INTO building_origin (label)
	SELECT origin_bat FROM building GROUP BY origin_bat
ON CONFLICT DO NOTHING;
ALTER TABLE building
ADD origin_id smallint,
ADD CONSTRAINT building_origin_fk FOREIGN KEY(origin_id) REFERENCES building_origin(id);

UPDATE building
SET
    origin_id = q.id
FROM (
    SELECT id, label FROM building_origin
) as q
WHERE q.label = building.origin_bat;

-- This part is pending...
-- INSERT INTO building_type (etat)
	-- SELECT CASE WHEN COALESCE(usage1, 'Indifférencié') != 'Indifférencié' THEN 
	-- CASE WHEN COALESCE(usage2, 'Indifférencié') != 'Indifférencié' THEN usage1 || ', ' || usage2 ELSE usage1 END
	-- ELSE nature END
	-- FROM building
	-- GROUP BY nature, usage1, usage2;
-- ON CONFLICT DO NOTHING;

-- ALTER TABLE building_etat
-- ADD etat_id smallint,
-- ADD CONSTRAINT etat_fk FOREIGN KEY(etat_id) REFERENCES building_etat(id);

-- UPDATE building
-- SET
    -- etat_id = q.id
-- FROM (
    -- SELECT id, etat FROM building_etat
-- ) as q
-- WHERE q.etat = forest.etat;
