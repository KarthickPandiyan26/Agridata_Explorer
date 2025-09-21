-- 1 -- Top 7 RICE PRODUCTION State Data

SELECT state_name, SUM(rice_production) AS total_production
FROM agridata.agri
WHERE rice_production IS NOT NULL
GROUP BY state_name
ORDER BY total_production DESC
LIMIT 7;

-- 2 -- Top 5 Wheat Producing States Data and its percentage(%)

SELECT state_name,
SUM(wheat_production) AS total_wheat_production,
ROUND(SUM(wheat_production) * 100.0 / 
	(SELECT SUM(wheat_production) 
         FROM agridata.agri
         WHERE wheat_production IS NOT NULL
           AND year = (SELECT MAX(year) FROM agridata.agri)
        ), 2 ) AS percentage_contribution
FROM agridata.agri
WHERE wheat_production IS NOT NULL
AND year = (SELECT MAX(year) FROM agridata.agri)
GROUP BY state_name
ORDER BY total_wheat_production DESC
LIMIT 5;

-- 3 -- Oil seed production by top 5 states

SELECT state_name, SUM(oilseeds_production) AS total_production
FROM agridata.agri
GROUP BY state_name
ORDER BY total_production DESC
LIMIT 5;

-- 4 -- Top 7 SUNFLOWER PRODUCTION  State

ALTER TABLE agridata.agri
CHANGE COLUMN `SUNFLOWER PRODUCTION (1000 TONS)` sunflower_production INT

SELECT state_name, SUM(sunflower_production) AS total_sunflower_production
FROM agridata.agri
GROUP BY state_name
ORDER BY total_sunflower_production DESC
LIMIT 7;

-- 5 -- India's SUGARCANE PRODUCTION From Last 50 Years

ALTER TABLE agridata.agri
CHANGE COLUMN `SUGARCANE PRODUCTION (1000 TONS)` sugarcane_production INT

SELECT year, SUM(sugarcane_production) AS total_sugarcane_production
FROM agridata.agri
WHERE year BETWEEN 1968 AND 2017
GROUP BY year
ORDER BY year;

-- 6 -- Rice Production Vs Wheat Production (Last 50y)

SELECT year, 
       SUM(CASE WHEN rice_production IS NOT NULL THEN rice_production ELSE 0 END) AS total_rice_production,
       SUM(CASE WHEN wheat_production IS NOT NULL THEN wheat_production ELSE 0 END) AS total_wheat_production
FROM agridata.agri
WHERE year BETWEEN 1968 AND 2017
GROUP BY year
ORDER BY year;

-- 7 -- Rice Production By West Bengal Districts 

SELECT dist_name, SUM(rice_production) AS Total_rice_production
FROM agridata.agri
WHERE rice_production IS NOT NULL AND state_name = 'West Bengal'
GROUP BY dist_name
ORDER BY SUM(rice_production) DESC;

-- 8 -- Top 10 Wheat Production Years From UP 

SELECT year, SUM(wheat_production) AS total_wheat_production
FROM agridata.agri
WHERE wheat_production IS NOT NULL AND state_name = 'Uttar Pradesh'
GROUP BY year
ORDER BY SUM(wheat_production) DESC
LIMIT 10;

-- 9 -- Millet Production (Last 50y)

ALTER TABLE agridata.agri
CHANGE COLUMN `finger_production` finger_millet_production INT

SELECT year, SUM(finger_millet_production) AS total_millet_production
FROM agridata.agri
WHERE finger_millet_production IS NOT NULL AND year BETWEEN 1968 AND 2017
GROUP BY year
ORDER BY year;

-- 10 -- Sorghum Production (Kharif and Rabi) by Region

ALTER TABLE agridata.agri
CHANGE COLUMN `KHARIF SORGHUM PRODUCTION (1000 Tons)` kharif_production INT

ALTER TABLE agridata.agri
CHANGE COLUMN `RABI SORGHUM PRODUCTION (1000 Tons)` rabi_production INT

SELECT state_name, 
SUM(kharif_production) AS total_kharif_production, 
SUM(rabi_production) AS total_rabi_production
FROM agridata.agri
GROUP BY state_name
ORDER BY state_name;

-- 11 -- Top 7 States for Groundnut Production

SELECT state_name, SUM(groundnut_production) AS total_groundnut_production
FROM agridata.agri
WHERE groundnut_production IS NOT NULL
GROUP BY state_name
ORDER BY SUM(groundnut_production) DESC
LIMIT 7;

-- 12 -- Soybean Production by Top 5 States and Yield Efficiency

ALTER TABLE agridata.agri
CHANGE COLUMN `SOYABEAN PRODUCTION (1000 Tons)` soyabean_production INT

ALTER TABLE agridata.agri
CHANGE COLUMN `SOYABEAN YIELD (Kg per ha)` soyabean_yield INT

SELECT state_name,
       SUM(soyabean_production) AS total_soyabean_production,
       SUM(soyabean_production) / SUM(soyabean_yield) AS yield_efficiency
FROM agridata.agri
WHERE soyabean_production IS NOT NULL
GROUP BY state_name
ORDER BY total_soyabean_production DESC
LIMIT 5;

-- 13 -- Oilseed Production in Major States

SELECT state_name, SUM(oilseeds_production) AS total_oilseed_production
FROM agridata.agri
GROUP BY state_name
ORDER BY total_oilseed_production DESC;

-- 14 -- Impact of Area Cultivated on Production (Rice, Wheat, Maize)

SELECT state_name,
    
    -- Rice
    rice_area, rice_production,
    ROUND(rice_production / NULLIF(rice_area, 0), 2) AS rice_yield_tph,
    
    -- Wheat
    wheat_area, wheat_production,
    ROUND(wheat_production / NULLIF(wheat_area, 0), 2) AS wheat_yield_tph,
    
    -- Maize
    maize_area, maize_production,
    ROUND(maize_production / NULLIF(maize_area, 0), 2) AS maize_yield_tph

FROM agridata.agri
ORDER BY year, state_name;

-- 15 -- Rice vs. Wheat Yield Across States

SELECT state_name,
       SUM(CASE WHEN rice_production IS NOT NULL THEN rice_production ELSE 0 END) / 
       NULLIF(SUM(CASE WHEN rice_production IS NOT NULL THEN rice_yield ELSE 0 END), 0) AS total_rice_yield,
       
       SUM(CASE WHEN wheat_production IS NOT NULL THEN wheat_production ELSE 0 END) / 
       NULLIF(SUM(CASE WHEN wheat_production IS NOT NULL THEN wheat_yield ELSE 0 END), 0) AS total_wheat_yield
FROM agridata.agri 
GROUP BY state_name
ORDER BY state_name;







