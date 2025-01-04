CREATE TABLE building_etat (
   id smallserial PRIMARY KEY,
   etat VARCHAR(64) UNIQUE
);

INSERT INTO building_etat (etat)
	SELECT etat FROM building GROUP BY etat
ON CONFLICT DO NOTHING;

ALTER TABLE building
ADD etat_id smallint,
ADD CONSTRAINT etat_fk FOREIGN KEY(etat_id) REFERENCES building_etat(id);

UPDATE building
SET
    etat_id = q.id
FROM (
    SELECT id, etat FROM building_etat
) as q
WHERE q.etat = building.etat;
