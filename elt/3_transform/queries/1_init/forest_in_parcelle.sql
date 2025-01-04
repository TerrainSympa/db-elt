CREATE TABLE IF NOT EXISTS forest_in_parcelle
(
    parcelle_gid integer,
    forest_gid integer,
    geom bytea,
    area double precision DEFAULT 0,
    area_percentage real DEFAULT 0,
    PRIMARY KEY (parcelle_gid, forest_gid),
    FOREIGN KEY(parcelle_gid) REFERENCES parcelle(gid),
    FOREIGN KEY(forest_gid) REFERENCES forest(gid)
);

CREATE INDEX parcelle_fip_gid_idx ON forest_in_parcelle (parcelle_gid);
CREATE INDEX forest_fip_gid_idx ON forest_in_parcelle (forest_gid);
