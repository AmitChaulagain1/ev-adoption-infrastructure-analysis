
  -- 1) Data Load Verification (Row count + sample)

SELECT COUNT(*) AS total_rows
FROM FINALEV.PUBLIC.FINALEVPROJECT;

SELECT *
FROM FINALEV.PUBLIC.FINALEVPROJECT
LIMIT 5;


 --  2) Data Quality Check (Null completeness on key fields)

SELECT 
    COUNT(*) AS total_rows,
    COUNT(MODEL_YEAR) AS model_year_not_null,
    COUNT(ELECTRIC_RANGE) AS electric_range_not_null,
    COUNT(MAKE) AS make_not_null
FROM FINALEV.PUBLIC.FINALEVPROJECT;


  -- 3) Adoption Trend Over Time (Vehicles by Model Year)


SELECT 
    MODEL_YEAR,
    COUNT(*) AS vehicles
FROM FINALEV.PUBLIC.FINALEVPROJECT
GROUP BY MODEL_YEAR
ORDER BY MODEL_YEAR;


  -- 4) Geographic Concentration (Top 10 Counties)

SELECT 
    COUNTY,
    COUNT(*) AS total_vehicles
FROM FINALEV.PUBLIC.FINALEVPROJECT
GROUP BY COUNTY
ORDER BY total_vehicles DESC
LIMIT 10;


  -- 5) Metro Concentration (Top 15 Cities)

SELECT 
    CITY,
    COUNT(*) AS total_vehicles
FROM FINALEV.PUBLIC.FINALEVPROJECT
GROUP BY CITY
ORDER BY total_vehicles DESC
LIMIT 15;


  -- 6)which utilities serve most EVs?

SELECT 
    ELECTRIC_UTILITY,
    COUNT(*) AS total_vehicles
FROM FINALEV.PUBLIC.FINALEVPROJECT
GROUP BY ELECTRIC_UTILITY
ORDER BY total_vehicles DESC;


  -- 7) BEV vs PHEV by County (Charging dependency)

SELECT 
    COUNTY,
    ELECTRIC_VEHICLE_TYPE,
    COUNT(*) AS total_vehicles
FROM FINALEV.PUBLIC.FINALEVPROJECT
WHERE COUNTY IN ('King','Snohomish','Pierce')
GROUP BY COUNTY, ELECTRIC_VEHICLE_TYPE
ORDER BY COUNTY, total_vehicles DESC;

  -- 8) BEV vs PHEV in Top 3 Counties (King/Snohomish/Pierce)

WITH top3 AS (
  SELECT
      COUNTY,
      ELECTRIC_VEHICLE_TYPE,
      COUNT(*) AS vehicles
  FROM FINALEV.PUBLIC.FINALEVPROJECT
  WHERE COUNTY IN ('King','Snohomish','Pierce')
  GROUP BY COUNTY, ELECTRIC_VEHICLE_TYPE
),
county_totals AS (
  SELECT COUNTY, SUM(vehicles) AS county_total
  FROM top3
  GROUP BY COUNTY
)
SELECT
    t.COUNTY,
    t.ELECTRIC_VEHICLE_TYPE,
    t.vehicles,
    ct.county_total,
    ROUND(100 * t.vehicles / ct.county_total, 1) AS pct_of_county
FROM top3 t
JOIN county_totals ct
  ON t.COUNTY = ct.COUNTY
ORDER BY t.COUNTY, t.vehicles DESC;


  -- 9) Recent Growth in Top 3 Counties (Model Year >= 2021)

SELECT 
    COUNTY,
    MODEL_YEAR,
    COUNT(*) AS vehicles
FROM FINALEV.PUBLIC.FINALEVPROJECT
WHERE MODEL_YEAR >= 2021
  AND COUNTY IN ('King','Snohomish','Pierce')
GROUP BY COUNTY, MODEL_YEAR
ORDER BY COUNTY, MODEL_YEAR;



   --10) Statewide Totals for 2021–2023 (Baseline for share calc)

SELECT 
    MODEL_YEAR,
    COUNT(*) AS total_statewide
FROM FINALEV.PUBLIC.FINALEVPROJECT
WHERE MODEL_YEAR IN (2021, 2022, 2023)
GROUP BY MODEL_YEAR
ORDER BY MODEL_YEAR;


  -- 11) % of Statewide 2021–2023 Growth from Top 3 Counties

WITH statewide AS (
  SELECT MODEL_YEAR, COUNT(*) AS total_statewide
  FROM FINALEV.PUBLIC.FINALEVPROJECT
  WHERE MODEL_YEAR IN (2021, 2022, 2023)
  GROUP BY MODEL_YEAR
),
top3 AS (
  SELECT MODEL_YEAR, COUNT(*) AS total_top3
  FROM FINALEV.PUBLIC.FINALEVPROJECT
  WHERE MODEL_YEAR IN (2021, 2022, 2023)
    AND COUNTY IN ('King','Snohomish','Pierce')
  GROUP BY MODEL_YEAR
)
SELECT
    s.MODEL_YEAR,
    t.total_top3,
    s.total_statewide,
    ROUND(100 * t.total_top3 / s.total_statewide, 1) AS pct_from_top3
FROM statewide s
JOIN top3 t
  ON s.MODEL_YEAR = t.MODEL_YEAR
ORDER BY s.MODEL_YEAR;