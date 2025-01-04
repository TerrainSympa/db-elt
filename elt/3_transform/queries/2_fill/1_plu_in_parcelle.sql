INSERT INTO plu_in_parcelle (
    WITH sub_plu AS (
        SELECT gid, gid_part, wfs_type, ST_Subdivide(geom, 64) as geom FROM plu
    )
    SELECT parcelle.gid as parcelle_gid, sub_plu.gid as plu_gid, sub_plu.gid_part as plu_gid_part, sub_plu.wfs_type as wfs_type, ST_AsTWKB(ST_Union(st_intersection(parcelle.geom, sub_plu.geom)), 2) as geom
    FROM parcelle
    JOIN sub_plu ON st_intersects(parcelle.geom, sub_plu.geom)
	GROUP BY parcelle.gid, sub_plu.gid, sub_plu.gid_part, sub_plu.wfs_type
);

UPDATE plu_in_parcelle
SET
    area = q.area,
    area_percentage = q.area_percentage
FROM (
    SELECT parcelle_gid, plu_gid, plu_gid_part, wfs_type, ST_area(ST_GeomFromTWKB(plu_in_parcelle.geom)) as area, ST_area(ST_GeomFromTWKB(plu_in_parcelle.geom)) / ST_area(parcelle.geom) as area_percentage
    FROM plu_in_parcelle
    JOIN parcelle ON plu_in_parcelle.parcelle_gid = parcelle.gid
) as q
WHERE q.parcelle_gid = plu_in_parcelle.parcelle_gid AND q.plu_gid = plu_in_parcelle.plu_gid AND q.plu_gid_part = plu_in_parcelle.plu_gid_part AND q.wfs_type = plu_in_parcelle.wfs_type;
