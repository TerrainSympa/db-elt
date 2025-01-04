-- Indexes
CREATE INDEX parcelle_gid_idx ON parcelle (gid);
CREATE INDEX building_gid_idx ON building (gid);
CREATE INDEX forest_gid_idx ON forest (gid);
CREATE INDEX plu_gid_idx ON plu (gid);
CREATE INDEX river_gid_idx ON river (gid);

UPDATE parcelle
SET geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom), 3))
WHERE NOT ST_IsValid(geom);

UPDATE building
SET geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom), 3))
WHERE NOT ST_IsValid(geom);

UPDATE forest
SET geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom), 3))
WHERE NOT ST_IsValid(geom);

UPDATE river
SET geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom), 2))
WHERE NOT ST_IsValid(geom);

UPDATE plu
SET geom = ST_Multi(ST_CollectionExtract(ST_MakeValid(geom), 3))
WHERE NOT ST_IsValid(geom);

UPDATE parcelle
SET geom = ST_ReducePrecision(parcelle.geom, 0.01)
WHERE 1 = 1;

UPDATE building
SET geom = ST_ReducePrecision(building.geom, 0.01)
WHERE 1 = 1;

UPDATE forest
SET geom = ST_ReducePrecision(forest.geom, 0.01)
WHERE 1 = 1;

UPDATE river
SET geom = ST_ReducePrecision(river.geom, 0.01)
WHERE 1 = 1;

UPDATE plu
SET geom = ST_ReducePrecision(plu.geom, 0.01)
WHERE 1 = 1;


-- Analyze
ANALYZE parcelle;
ANALYZE building;
ANALYZE forest;
ANALYZE plu;
ANALYZE river;

-- Clusters
CLUSTER parcelle USING parcelle_geom_geom_idx;
CLUSTER building USING building_geom_geom_idx;
CLUSTER forest USING forest_geom_geom_idx;
CLUSTER plu USING plu_geom_idx;
CLUSTER river USING river_geom_geom_idx;
