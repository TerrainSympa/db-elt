INSERT INTO forest_in_parcelle (
    WITH sub_forest AS (
        SELECT gid, ST_Subdivide(geom, 64) as geom FROM forest
    )
    SELECT parcelle.gid as parcelle_gid, sub_forest.gid as forest_gid, ST_AsTWKB(ST_Union(st_intersection(parcelle.geom, sub_forest.geom)), 2) as geom
    FROM parcelle
    JOIN sub_forest ON st_intersects(parcelle.geom, sub_forest.geom)
	GROUP BY parcelle.gid, sub_forest.gid
);

UPDATE forest_in_parcelle
SET
    area = q.area,
    area_percentage = q.area_percentage
FROM (
    SELECT parcelle_gid, forest_gid, ST_area(ST_GeomFromTWKB(forest_in_parcelle.geom)) as area, ST_area(ST_GeomFromTWKB(forest_in_parcelle.geom)) / ST_area(parcelle.geom) as area_percentage
    FROM forest_in_parcelle
    JOIN parcelle ON forest_in_parcelle.parcelle_gid = parcelle.gid
) as q
WHERE q.parcelle_gid = forest_in_parcelle.parcelle_gid AND q.forest_gid = forest_in_parcelle.forest_gid;

