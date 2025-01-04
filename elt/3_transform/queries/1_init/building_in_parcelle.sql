CREATE TABLE IF NOT EXISTS building_in_parcelle
(
    parcelle_gid integer,
    building_gid integer,
    geom bytea,
    area double precision DEFAULT 0,
    area_percentage real DEFAULT 0,
    PRIMARY KEY (parcelle_gid, building_gid),
    FOREIGN KEY(parcelle_gid) REFERENCES parcelle(gid),
    FOREIGN KEY(building_gid) REFERENCES building(gid)
);

CREATE INDEX parcelle_bip_gid_idx ON building_in_parcelle (parcelle_gid);
CREATE INDEX building_bip_gid_idx ON building_in_parcelle (building_gid);
