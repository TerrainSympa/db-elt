--ALTER TABLE parcelle
--ADD center geometry null,
--ADD area double precision default 0,
--ADD forest_area double precision default 0,
--ADD forest_area_percentage real default 0,
--ADD building_area double precision default 0,
--ADD building_area_percentage real default 0,
--ADD non_building_area double precision default 0,
--ADD non_building_area_percentage real default 0,
--ADD plu_area double precision default 0,
--ADD plu_area_percentage real default 0,
--ADD river_length double precision default 0,
--ADD commune_insee_com VARCHAR(5) null,
--ADD COLUMN geom_twkb bytea
--;
--
--CREATE INDEX parcelle_area_idx
--ON parcelle(area);
--CREATE INDEX parcelle_forest_area_idx
--ON parcelle(forest_area);
--CREATE INDEX parcelle_building_area_idx
--ON parcelle(building_area);
--CREATE INDEX parcelle_river_length_idx
--ON parcelle(river_length);
--CREATE INDEX parcelle_commune_insee_com_idx
--ON parcelle(commune_insee_com);
--CREATE INDEX parcelle_idu_idx
--    ON public.parcelle (idu)
--;
--CREATE INDEX parcelle_center_idx
--ON parcelle
--USING GIST (center);
--
--CREATE INDEX parcelle_code_com_idx
--ON parcelle(code_com);
--CREATE INDEX parcelle_code_dep_idx
--ON parcelle(code_dep);


UPDATE parcelle
SET
    forest_area = COALESCE(q.sum_forest_area, 0),
    forest_area_percentage = COALESCE(q.area_forest_percentage, 0)
FROM (
    SELECT gid, SUM(fip.area) as sum_forest_area,
     SUM(fip.area_percentage) as area_forest_percentage
    FROM parcelle p
    LEFT JOIN forest_in_parcelle fip ON p.gid = fip.parcelle_gid
    GROUP BY p.gid
) as q
WHERE q.gid = parcelle.gid;


UPDATE parcelle
SET
    building_area = COALESCE(q.sum_building_area, 0),
    building_area_percentage = COALESCE(q.area_building_percentage, 0)
FROM (
     SELECT gid, SUM(bip.area) as sum_building_area,
     SUM(bip.area_percentage) as area_building_percentage
    FROM parcelle p
    LEFT JOIN building_in_parcelle bip ON p.gid = bip.parcelle_gid
    GROUP BY p.gid
) as q
WHERE q.gid = parcelle.gid;

UPDATE parcelle
SET
    plu_area = COALESCE(q.sum_plu_area, 0),
    plu_area_percentage = COALESCE(q.area_plu_percentage, 0)
FROM (
    SELECT gid,
     SUM(pip.area) as sum_plu_area,
     SUM(pip.area_percentage) as area_plu_percentage
    FROM parcelle p
    LEFT JOIN plu_in_parcelle pip ON p.gid = pip.parcelle_gid
    GROUP BY p.gid
) as q
WHERE q.gid = parcelle.gid;


UPDATE parcelle
SET
    river_length = COALESCE(q.sum_river_length, 0)
FROM (
    SELECT gid,
     SUM(rip.river_length) as sum_river_length
    FROM parcelle p
    LEFT JOIN river_in_parcelle rip ON p.gid = rip.parcelle_gid
    GROUP BY p.gid
) as q
WHERE q.gid = parcelle.gid;

--UPDATE parcelle
--SET
--    area = COALESCE(q.area, 0),
--    center = q.center,
--    geom_twkb = q.twkb,
--    commune_insee_com = q.commune_insee_com
--FROM (
--    SELECT p.gid,
--     ST_Area(p.geom) as area,
--     ST_Centroid(p.geom) as center,
--     code_dep || code_com as commune_insee_com,
--     ST_AsTWKB(p.geom, 2) as twkb
--    FROM parcelle p
--) as q
--WHERE q.gid = parcelle.gid;

UPDATE parcelle
SET
    non_building_area = COALESCE(q.non_building_area, 0),
    non_building_area_percentage = COALESCE(q.non_building_area_percentage, 0)
FROM (
    SELECT gid,
     p.area - building_area as non_building_area,
     100 - building_area_percentage as non_building_area_percentage
    FROM parcelle p
) as q
WHERE q.gid = parcelle.gid;

--UPDATE parcelle
--SET
--    area = q.area
--FROM (
--    SELECT gid, ST_Area(parcelle.geom) as area
--    FROM parcelle
--) as q
--WHERE q.gid = parcelle.gid;
--
--UPDATE parcelle
--SET
--    forest_area = q.sum_area,
--    forest_area_percentage = q.area_percentage
--FROM (
--    SELECT SUM(area) as sum_area, SUM(area_percentage) as area_percentage, parcelle_gid
--    FROM forest_in_parcelle
--    GROUP BY parcelle_gid
--) as q
--WHERE q.parcelle_gid = parcelle.gid;
--
--UPDATE parcelle
--SET
--    building_area = q.sum_area,
--    building_area_percentage = q.area_percentage
--FROM (
--    SELECT SUM(area) as sum_area, SUM(area_percentage) as area_percentage, parcelle_gid
--    FROM building_in_parcelle
--    GROUP BY parcelle_gid
--) as q
--WHERE q.parcelle_gid = parcelle.gid;
--
--UPDATE parcelle
--SET
--    non_building_area = q.non_building_area,
--    non_building_area_percentage = q.non_building_area_percentage
--FROM (
--    SELECT gid, area - building_area as non_building_area, 100 - building_area_percentage as non_building_area_percentage
--    FROM parcelle
--) as q
--WHERE q.gid = parcelle.gid;
--
--
--UPDATE parcelle
--SET
--    plu_area = q.sum_area,
--    plu_area_percentage = q.area_percentage
--FROM (
--    SELECT SUM(area) as sum_area, SUM(area_percentage) as area_percentage, parcelle_gid
--    FROM plu_in_parcelle
--    GROUP BY parcelle_gid
--) as q
--WHERE q.parcelle_gid = parcelle.gid;
--
--UPDATE parcelle
--SET
--    river_length = q.sum_length
--FROM (
--    SELECT SUM(river_length) as sum_length, parcelle_gid
--    FROM river_in_parcelle
--    GROUP BY parcelle_gid
--) as q
--WHERE q.parcelle_gid = parcelle.gid;
--
--UPDATE parcelle
--SET
--    center = q.center
--FROM (
--    SELECT gid, ST_Centroid(parcelle.geom) as center
--    FROM parcelle
--) as q
--WHERE q.gid = parcelle.gid;

--UPDATE parcelle
--SET commune_insee_com = code_dep || code_com;


--UPDATE parcelle
--SET
--    geom_twkb = q.twkb
--FROM (
--    SELECT gid, ST_AsTWKB(parcelle.geom, 2) as twkb FROM parcelle
--) as q
--WHERE q.gid = parcelle.gid;
