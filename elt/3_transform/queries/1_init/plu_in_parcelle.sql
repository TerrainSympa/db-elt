CREATE TABLE IF NOT EXISTS public.plu_in_parcelle
(
    parcelle_gid integer,
    plu_gid integer,
    plu_gid_part integer,
    wfs_type wfs_type,
    geom bytea,
    area double precision,
    area_percentage real,
    PRIMARY KEY (parcelle_gid, plu_gid, plu_gid_part, wfs_type),
    FOREIGN KEY(parcelle_gid) REFERENCES parcelle(gid),
    FOREIGN KEY(plu_gid, plu_gid_part, wfs_type) REFERENCES plu(gid, gid_part, wfs_type)
);

ALTER TABLE public.plu_in_parcelle
    OWNER to admin;

CREATE INDEX parcelle_pip_gid_idx ON plu_in_parcelle (parcelle_gid);
CREATE INDEX plu_pip_gid_idx ON plu_in_parcelle (plu_gid, plu_gid_part, wfs_type);
