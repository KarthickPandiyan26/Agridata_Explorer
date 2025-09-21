SELECT * FROM agridata.agri;

-- Year-wise Trend of Rice Production Across States (Top 3) -- 

/*ALTER TABLE agridata.agri
CHANGE COLUMN `state name` state_name VARCHAR(255)
ALTER TABLE agridata.agri
CHANGE COLUMN `rice production (1000 tons)` rice_production VARCHAR(255)*/

WITH top_states AS (
  SELECT state_name FROM agridata.agri
  WHERE rice_production IS NOT NULL
  GROUP BY state_name
  ORDER BY SUM(rice_production) DESC
  LIMIT 3
)
SELECT year, state_name, SUM(rice_production) AS total_production FROM agridata.agri
WHERE Rice_production IS NOT NULL AND state_name IN (SELECT state_name FROM top_states)
GROUP BY year, state_name
ORDER BY year, total_production DESC;

-- Top 5 Districts by Wheat Yield Increase Over the Last 5 Years --  

/*ALTER TABLE agridata.agri
CHANGE COLUMN `wheat yield (kg per ha)` wheat_yield int
ALTER TABLE agridata.agri
CHANGE COLUMN `dist name` dist_name VARCHAR(255)*/

WITH wheat_yield AS (
  SELECT dist_name, year, AVG(wheat_yield) AS avg_yield FROM agridata.agri
  WHERE wheat_yield IS NOT NULL
  GROUP BY dist_name, year
),
yield_change AS (
  SELECT dist_name,
         MAX(CASE WHEN year = 2017 THEN avg_yield END) AS recent_yield,
         MAX(CASE WHEN year = 2017 - 5 THEN avg_yield END) AS past_yield
  FROM wheat_yield
  GROUP BY dist_name
)
SELECT dist_name, (recent_yield - past_yield) AS yield_increase FROM yield_change
WHERE recent_yield IS NOT NULL AND past_yield IS NOT NULL
ORDER BY yield_increase DESC
LIMIT 5;

-- States with the Highest Growth in Oilseed Production (5-Year Growth Rate) -- 

/*ALTER TABLE agridata.agri
CHANGE COLUMN `oilseeds production (1000 tons)` oilseeds_production INT*/


WITH oilseed_growth AS (
  SELECT state_name,
         SUM(CASE WHEN year = 2017 THEN oilseeds_production END) AS recent,
         SUM(CASE WHEN year = 2017 - 5 THEN oilseeds_production END) AS past
  FROM agridata.agri
  WHERE oilseeds_production IS NOT NULL
  GROUP BY state_name
)
SELECT state_name, ((recent - past) / NULLIF(past, 0)) * 100 AS growth_rate FROM oilseed_growth
ORDER BY growth_rate DESC
LIMIT 5;

-- District-wise Correlation Between Area and Production for Major Crops (Rice, Wheat, and Maize) -- 

/*ALTER TABLE AGRIDATA.agri
CHANGE COLUMN `RICE AREA (1000 ha)` rice_area INT
ALTER TABLE AGRIDATA.agri
CHANGE COLUMN `WHEAT AREA (1000 ha)` wheat_area INT
ALTER TABLE AGRIDATA.agri
CHANGE COLUMN `WHEAT PRODUCTION (1000 tons)` wheat_production INT
ALTER TABLE AGRIDATA.agri
CHANGE COLUMN `WHEAT AREA (1000 ha)` wheat_area INT
ALTER TABLE AGRIDATA.agri
CHANGE COLUMN `MAIZE AREA (1000 ha)` maize_area INT
ALTER TABLE AGRIDATA.agri
CHANGE COLUMN `MAIZE PRODUCTION (1000 tons)` maize_production INT*/ 
     
SELECT a.state_name, a.dist_name,
    
    -- Rice correlation
    (SUM((a.rice_area - ra.avg_area) * (a.rice_production - rp.avg_prod)) /
     (SQRT(SUM(POW(a.rice_area - ra.avg_area, 2))) * SQRT(SUM(POW(a.rice_production - rp.avg_prod, 2))))) AS rice_corr,

    -- Wheat correlation
    (SUM((a.wheat_area - wa.avg_area) * (a.wheat_production - wp.avg_prod)) /
     (SQRT(SUM(POW(a.wheat_area - wa.avg_area, 2))) * SQRT(SUM(POW(a.wheat_production - wp.avg_prod, 2))))) AS wheat_corr,

    -- Maize correlation
    (SUM((a.maize_area - ma.avg_area) * (a.maize_production - mp.avg_prod)) /
     (SQRT(SUM(POW(a.maize_area - ma.avg_area, 2))) * SQRT(SUM(POW(a.maize_production - mp.avg_prod, 2))))) AS maize_corr

FROM agridata.agri AS a

-- Rice averages
JOIN (
    SELECT dist_name, AVG(rice_area) AS avg_area
    FROM agridata.agri
    GROUP BY dist_name
) AS ra ON a.dist_name = ra.dist_name

JOIN (
    SELECT dist_name, AVG(rice_production) AS avg_prod
    FROM agridata.agri
    GROUP BY dist_name
) AS rp ON a.dist_name = rp.dist_name

-- Wheat averages
JOIN (
    SELECT dist_name, AVG(wheat_area) AS avg_area
    FROM agridata.agri
    GROUP BY dist_name
) AS wa ON a.dist_name = wa.dist_name

JOIN (
    SELECT dist_name, AVG(wheat_production) AS avg_prod
    FROM agridata.agri
    GROUP BY dist_name
) AS wp ON a.dist_name = wp.dist_name

-- Maize averages
JOIN (
    SELECT dist_name, AVG(maize_area) AS avg_area
    FROM agridata.agri
    GROUP BY dist_name
) AS ma ON a.dist_name = ma.dist_name

JOIN (
    SELECT dist_name, AVG(maize_production) AS avg_prod
    FROM agridata.agri
    GROUP BY dist_name
) AS mp ON a.dist_name = mp.dist_name

WHERE 
    a.rice_area IS NOT NULL AND a.rice_production IS NOT NULL AND
    a.wheat_area IS NOT NULL AND a.wheat_production IS NOT NULL AND
    a.maize_area IS NOT NULL AND a.maize_production IS NOT NULL

GROUP BY a.state_name, a.dist_name
ORDER BY a.state_name;

-- Yearly Production Growth of Cotton in Top 5 Cotton Producing States --  

/*ALTER TABLE AGRIDATA.AGRI
CHANGE COLUMN `COTTON PRODUCTION (1000 Tons)` cotton_production INT*/

WITH top_states AS (
  SELECT state_name FROM agridata.agri
  WHERE cotton_production is not null
  GROUP BY state_name
  ORDER BY SUM(cotton_production) DESC
  LIMIT 5
)
SELECT year, state_name, SUM(cotton_production) AS total_production FROM agridata.agri
WHERE cotton_production IS NOT NULL AND state_name IN (SELECT state_name FROM top_states)
GROUP BY year, state_name
ORDER BY year, total_production DESC;

-- Districts with the Highest Groundnut Production in 2017 -- 

SELECT a.state_name, a.dist_name, a.groundnut_production
FROM agridata.agri AS a
JOIN (
    SELECT state_name, MAX(groundnut_production) AS max_production
    FROM agridata.agri
    WHERE year = 2017 AND groundnut_production IS NOT NULL
    GROUP BY state_name
) AS top_districts
ON 
    a.state_name = top_districts.state_name
    AND a.groundnut_production = top_districts.max_production
WHERE a.year = 2017
ORDER BY groundnut_production DESC;

-- Annual Average Maize Yield Across All States -- 

/*ALTER TABLE AGRIDATA.AGRI
CHANGE COLUMN `MAIZE YIELD (Kg per ha)` maize_yield INT*/

SELECT year, state_name, ROUND(AVG(maize_yield), 2) AS Avg_maize_yield
FROM agridata.agri
WHERE maize_yield IS NOT NULL
GROUP BY year, state_name
ORDER BY year;

-- Total Area Cultivated for Oilseeds in Each State -- 

/*ALTER TABLE AGRIDATA.AGRI 
CHANGE COLUMN `OILSEEDS AREA (1000 ha)` oilseeds_area INT*/

SELECT state_name, SUM(oilseeds_area) AS Total_oilseed_area
FROM agridata.agri
WHERE oilseeds_area IS NOT NULL
GROUP BY state_name
ORDER BY total_oilseed_area DESC;

-- Districts with the Highest Rice Yield -- 

/*ALTER TABLE agridata.agri
CHANGE COLUMN `RICE YIELD (Kg per ha)` rice_yield int*/

WITH ranked_districts AS (
    SELECT state_name, dist_name, rice_yield,
        RANK() OVER (PARTITION BY state_name ORDER BY rice_yield DESC) AS rank_within_state
    FROM agridata.agri
)

SELECT state_name, dist_name, rice_yield
FROM ranked_districts
WHERE rank_within_state = 1
ORDER BY state_name;

-- Compare the Production of Wheat and Rice for the Top 5 States Over 10 Years -- 

WITH top_states AS (
    SELECT state_name
    FROM agridata.agri
    GROUP BY state_name
    ORDER BY SUM(rice_production + wheat_production) DESC
    LIMIT 5
)

SELECT a.year, a.state_name,
    SUM(a.rice_production) AS Total_rice_production,
    SUM(a.wheat_production) AS Total_wheat_production
FROM agridata.agri AS a
JOIN top_states AS t ON a.state_name = t.state_name
WHERE a.year AND a.rice_production IS NOT NULL AND a.wheat_production IS NOT NULL
AND a.year BETWEEN 1966 AND 1976
GROUP BY a.year, a.state_name
ORDER BY a.year;




