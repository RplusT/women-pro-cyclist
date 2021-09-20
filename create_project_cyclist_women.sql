BEGIN;

DROP TABLE IF EXISTS rider_records_women;

-- Creating the table
CREATE TABLE public.rider_records_women
(
    date character varying,
    result character varying,
    gc_result_on_stage character varying,
    race character varying COLLATE pg_catalog."default",
    distance character varying,
    pointspcs character varying,
    pointsuci character varying,
    stage character varying COLLATE pg_catalog."default",
    rider character varying COLLATE pg_catalog."default",
    team character varying COLLATE pg_catalog."default"
);

\copy public.rider_records_women from 'rider_records_women.csv' CSV HEADER;

-- DATA CLEANING
-- Turn NA into NULL

UPDATE public.rider_records_women
SET
	date = NULL
WHERE
	date = 'NA';

UPDATE public.rider_records_women
SET
	result = NULL
WHERE
	result = 'NA';
	
UPDATE public.rider_records_women
SET
	gc_result_on_stage = NULL
WHERE
	gc_result_on_stage = 'NA';

UPDATE public.rider_records_women
SET
	race = NULL
WHERE
	race = 'NA';
   
UPDATE public.rider_records_women
SET
	distance = NULL
WHERE
	distance = 'NA';

UPDATE public.rider_records_women
SET
	pointspcs = NULL
WHERE
	pointspcs = 'NA';
   
UPDATE public.rider_records_women
SET
	pointsuci = NULL
WHERE
	pointsuci = 'NA';

UPDATE public.rider_records_women
SET
	stage = NULL
WHERE
	stage = 'NA';

UPDATE public.rider_records_women
SET
	rider = NULL
WHERE
	rider = 'NA';

UPDATE public.rider_records_women
SET
	team = NULL
WHERE
	team = 'NA';

-- Update column types
ALTER TABLE public.rider_records_women
ALTER COLUMN date TYPE timestamp without time zone USING date::timestamp without time zone,
ALTER COLUMN result TYPE numeric USING result::numeric,
ALTER COLUMN gc_result_on_stage TYPE numeric USING gc_result_on_stage::numeric,
ALTER COLUMN distance TYPE numeric USING distance::numeric,
ALTER COLUMN pointspcs TYPE numeric USING pointspcs::numeric,
ALTER COLUMN pointsuci TYPE numeric USING pointsuci::numeric;

-- Add year column
ALTER TABLE public.rider_records_women
ADD COLUMN year INTEGER;

UPDATE public.rider_records_women
SET year = EXTRACT(YEAR FROM date);

-- Removing NULL values from rider column
DELETE FROM public.rider_records_women
WHERE rider IS NULL;

COMMIT;
