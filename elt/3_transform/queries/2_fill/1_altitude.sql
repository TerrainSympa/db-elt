ALTER TABLE parcelle
ADD altitude real NULL DEFAULT NULL,
ADD altitude_min real NULL DEFAULT NULL,
ADD altitude_max real NULL DEFAULT NULL;

WITH 
-- our features of interest
   feat AS (SELECT gid, geom FROM parcelle AS pa 
    WHERE MOD(gid,100) = 0
   ),
-- clip of raster tiles to boundaries of builds
-- then get stats for these clipped regions
   parcelle_stats AS
    (SELECT  gid, (stats).*
FROM (SELECT gid, ST_SummaryStats(ST_Clip(rast,geom)) As stats
    FROM altitude INNER JOIN feat ON ST_Intersects(feat.geom, rast) 
 ) As foo
 )

UPDATE parcelle
SET
    altitude = q.avg_pval,
    altitude_min = q.min_pval,
    altitude_max = q.max_pval
FROM (
    -- finally summarize stats
SELECT gid, SUM(count) As num_pixels
  , MIN(min) As min_pval
  , MAX(max) As max_pval
  , SUM(mean*count)/SUM(count) As avg_pval
    FROM parcelle_stats
 WHERE count > 0
    GROUP BY gid
    ORDER BY gid
) as q
WHERE q.gid = parcelle.gid;
