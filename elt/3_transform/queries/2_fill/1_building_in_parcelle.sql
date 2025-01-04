INSERT INTO building_in_parcelle (
    SELECT parcelle.gid as parcelle_gid, building.gid as building_gid, ST_AsTWKB(ST_Union(st_intersection(parcelle.geom, building.geom)), 2) as geom
    FROM parcelle
    JOIN building ON st_intersects(parcelle.geom, building.geom)
	GROUP BY parcelle.gid, building.gid
);

UPDATE building_in_parcelle
SET
    area = q.area,
    area_percentage = q.area_percentage
FROM (
    SELECT parcelle_gid, building_gid, ST_area(ST_GeomFromTWKB(building_in_parcelle.geom)) as area, ST_area(ST_GeomFromTWKB(building_in_parcelle.geom)) / ST_area(parcelle.geom) as area_percentage
    FROM building_in_parcelle
    JOIN parcelle ON building_in_parcelle.parcelle_gid = parcelle.gid
) as q
WHERE q.parcelle_gid = building_in_parcelle.parcelle_gid AND q.building_gid = building_in_parcelle.building_gid;