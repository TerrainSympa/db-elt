INSERT INTO river_in_parcelle (
    WITH sub_river AS (
            SELECT gid, ST_Subdivide(ST_Segmentize(geom, 64)) as geom FROM river
        )
    SELECT parcelle.gid as parcelle_gid, sub_river.gid as river_gid, ST_AsTWKB(ST_Union(st_intersection(parcelle.geom, river.geom)), 2) as geom,
     ST_LENGTH(ST_Union(st_intersection(parcelle.geom, river.geom))) as river_length
    FROM parcelle
    JOIN sub_river ON st_intersects(parcelle.geom, sub_river.geom)
    JOIN river ON sub_river.gid = river.gid
    GROUP BY parcelle.gid, sub_river.gid
);

