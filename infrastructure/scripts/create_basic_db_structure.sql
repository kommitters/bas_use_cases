CREATE DATABASE bas;

\connect bas;

CREATE TABLE public.generic_data (
    id integer NOT NULL,
    data jsonb,
    tag character varying(255),
    archived boolean,
    stage character varying(255),
    status character varying(255),
    error_message jsonb,
    version character varying(255),
    inserted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.generic_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.generic_data_id_seq OWNED BY public.generic_data.id;

ALTER TABLE ONLY public.generic_data ALTER COLUMN id SET DEFAULT nextval('public.generic_data_id_seq'::regclass);

ALTER TABLE ONLY public.generic_data ADD CONSTRAINT birthday_pkey PRIMARY KEY (id);
