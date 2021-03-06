-- EXPLORATORY DATA ANALYSIS
-- UCI points per rider; using Window functions
SELECT date, race, rider, team,
SUM(pointsuci) OVER(PARTITION BY rider) AS totalpointsuci
FROM
	public.rider_records_women
WHERE rider IS NOT NULL
ORDER BY totalpointsuci DESC;

-- UCI points per rider; regular aggregation
SELECT 
	rider, 
	SUM (pointsuci) AS totalpointsuci
FROM
	public.rider_records_women
GROUP BY
	rider
ORDER BY
	totalpointsuci DESC;

-- Total and average yearly UCI points per rider; 
-- Option 1: Using subqueries
SELECT
	rider,
	team,
	totalpointsuci,
	totalpointsuci/yearsactive AS yearlyaveragepoints,
	yearsactive,
	yearlatest,
	yearstarted
FROM(
---- Calculating years active per rider on record
	SELECT
		rider,
		team,
		CASE 
		WHEN yearlatest = yearstarted THEN 1
		WHEN yearlatest > yearstarted THEN yearlatest - yearstarted
		END AS yearsactive,
		yearlatest,
		yearstarted,
		totalpointsuci
	FROM(
---- Inserting latest active year and earliest year recorded per rider
		SELECT
			rider,
			team,
			MAX(year) AS yearlatest,
			MIN(year) AS yearstarted,
			SUM(pointsuci) AS totalpointsuci
		FROM
			public.rider_records_women
		GROUP BY
			rider, team
		ORDER BY
			totalpointsuci DESC
		) AS first_layer
	) AS second_layer

ORDER BY yearlyaveragepoints DESC;

-- Option 2: Using Window functions
--- Option 2.1: Using CTE
WITH UCIpointsvsYearsActive AS (
SELECT
	rider,
	team,
	pointsuci,
	SUM(pointsuci) OVER (PARTITION BY rider) AS totalucipoints,
	year,
	MAX(year) OVER (PARTITION BY rider) AS yearlatest,
	MIN(year) OVER (PARTITION BY rider) AS yearstarted
FROM
	public.rider_records_women
)
SELECT
	DISTINCT(rider),
	team,
	totalucipoints,
	totalucipoints / CASE 
	WHEN yearlatest = yearstarted THEN 1
	WHEN yearlatest > yearstarted THEN yearlatest - yearstarted
	END
	AS yearlyaveragepoints,
	yearstarted,
	yearlatest - yearstarted AS yearsactive
FROM
	UCIpointsvsYearsActive
ORDER BY
	yearlyaveragepoints DESC;

--- Option 2.2: Using a Temp Table
DROP TABLE IF EXISTS ucipoints_vs_years_active;

CREATE TABLE ucipoints_vs_years_active
(
	rider character varying,
	team character varying,
	pointsuci numeric,
	totalucipoints numeric,
	year numeric,
	yearlatest numeric,
	yearstarted numeric
);
INSERT INTO ucipoints_vs_years_active
SELECT
	rider,
	team,
	pointsuci,
	SUM(pointsuci) OVER (PARTITION BY rider) AS totalucipoints,
	year,
	MAX(year) OVER (PARTITION BY rider) AS yearlatest,
	MIN(year) OVER (PARTITION BY rider) AS yearstarted
FROM
	public.rider_records_women;

SELECT
	DISTINCT(rider),
	team,
	totalucipoints,
	totalucipoints / CASE 
	WHEN yearlatest = yearstarted THEN 1
	WHEN yearlatest > yearstarted THEN yearlatest - yearstarted
	END
	AS yearlyaveragepoints,
	yearstarted,
	yearlatest - yearstarted AS yearsactive
FROM
	ucipoints_vs_years_active
ORDER BY
	yearlyaveragepoints DESC;


-- Number of races per rider
DROP TABLE IF EXISTS races_women;

CREATE TABLE races_women
(
	rider character varying,
	team character varying,
	race character varying,
	year numeric,
	yearlatest numeric,
	yearstarted numeric
);
INSERT INTO races_women
SELECT
	rider,
	team,
	race,
	year,
	MAX(year) OVER (PARTITION BY rider) AS yearlatest,
	MIN(year) OVER (PARTITION BY rider) AS yearstarted
FROM
	public.rider_records_women
WHERE 
	date IS NOT NULL;

SELECT
	COUNT(*) AS race_count,
	rider,
	team,
	yearlatest - yearstarted AS yearsactive
FROM 
	public.races_women
GROUP BY
	rider,
	team,
	yearsactive
ORDER BY
	race_count DESC;
	 

-- Create views for later visualization
CREATE VIEW ucipoints_summary_women AS
SELECT
	DISTINCT(rider),
	team,
	totalucipoints,
	totalucipoints / CASE 
	WHEN yearlatest = yearstarted THEN 1
	WHEN yearlatest > yearstarted THEN yearlatest - yearstarted
	END
	AS yearlyaveragepoints,
	yearstarted,
	yearlatest - yearstarted AS yearsactive
FROM
	ucipoints_vs_years_active;


CREATE VIEW count_races_women AS
SELECT
	COUNT(*) AS race_count,
	rider,
	team,
	yearlatest - yearstarted AS yearsactive
FROM 
	public.races_women
GROUP BY
	rider,
	team,
	yearsactive;
 
 
CREATE VIEW ucipoints_races_women AS
SELECT
	p.rider,
	p.team,
	p.totalucipoints,
	p.yearlyaveragepoints,
	c.race_count,
	p.yearstarted,
	p.yearsactive
FROM
	public.ucipoints_summary_women p
	LEFT JOIN public.count_races_women c
	ON p.rider = c.rider;
