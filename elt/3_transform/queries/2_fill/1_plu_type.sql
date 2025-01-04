CREATE TABLE plu_type (
   id smallserial PRIMARY KEY,
   type1 VARCHAR(64) UNIQUE,
   type1_desc VARCHAR(255) UNIQUE
);

INSERT INTO plu_type (type1, type1_desc) 
VALUES ('n', 'Zone naturelle'),
	('a', 'Zone agricole'),
	('u', 'Zone urbaine'),
	('au', 'Zone à urbaniser'),
	('c', 'Zone constructible');

ALTER TABLE plu
ADD type_id smallint,
ADD CONSTRAINT type_fk FOREIGN KEY(type_id) REFERENCES plu_type(id);

UPDATE plu
SET
    type_id = q.id
FROM (
    SELECT id, type1 FROM plu_type
) as q
WHERE LOWER(plu.libelle) similar to CONCAT('[123]?', q.type1, '%');

CREATE INDEX plu_type_id_idx
ON plu(type_id);
