ALTER TABLE IF EXISTS public.communes
    ADD COLUMN numero character varying(255) COLLATE pg_catalog."default" DEFAULT NULL::character varying,
    ADD COLUMN email character varying(127) COLLATE pg_catalog."default" DEFAULT NULL::character varying,
    ADD COLUMN site character varying(255) COLLATE pg_catalog."default" DEFAULT NULL::character varying,
    ADD COLUMN postal_code character varying(255) COLLATE pg_catalog."default" DEFAULT NULL::character varying
    ;

CREATE UNIQUE INDEX communes_insee_com_idx ON public.communes (insee_com);
