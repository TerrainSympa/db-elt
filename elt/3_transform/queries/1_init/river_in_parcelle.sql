CREATE TABLE IF NOT EXISTS river_in_parcelle
(
    parcelle_gid integer,
    river_gid integer,
    geom bytea,
    river_length double precision DEFAULT 0,
    PRIMARY KEY (parcelle_gid, river_gid),
    FOREIGN KEY(parcelle_gid) REFERENCES parcelle(gid),
    FOREIGN KEY(river_gid) REFERENCES river(gid)
);

CREATE INDEX parcelle_rip_gid_idx ON river_in_parcelle (parcelle_gid);
CREATE INDEX river_rip_gid_idx ON river_in_parcelle (river_gid);
CREATE INDEX river_in_parcelle_length_idx
ON river_in_parcelle(river_length);
