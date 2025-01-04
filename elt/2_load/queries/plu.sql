CREATE TYPE wfs_type AS ENUM ('zone_urba', 'secteur_cc');

CREATE TABLE IF NOT EXISTS public.plu
(
    gid integer NOT NULL,
    gid_part integer NOT NULL,
    wfs_type wfs_type NOT NULL,
    part character varying(16) COLLATE pg_catalog."default",
    insee_com character varying(5) COLLATE pg_catalog."default",
    libelle character varying(255) COLLATE pg_catalog."default",
    libelong text COLLATE pg_catalog."default",
    typezone character varying(8) COLLATE pg_catalog."default",
    geom geometry(Geometry,2154),
    PRIMARY KEY (gid, gid_part, wfs_type)
);

ALTER TABLE public.plu
    OWNER to admin;

CREATE INDEX plu_geom_idx
    ON public.plu USING gist
    (geom)
    TABLESPACE pg_default;
