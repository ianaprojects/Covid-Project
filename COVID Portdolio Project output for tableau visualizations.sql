/*
Queries used for Tableau Project
*/



-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths
, 100*SUM(new_deaths)/SUM(new_cases)::DECIMAL AS death_percentage
FROM c_deaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths
, 100*SUM(new_deaths)/SUM(new_cases)::DECIMAL AS death_percentage
FROM c_deaths
WHERE location = 'World'
-- GROUP BY date
ORDER BY 1, 2;


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, 
SUM(new_deaths) as total_death_count
FROM c_deaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International', 
	'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count desc


-- 3.

SELECT location, population
	, MAX(total_cases) as highest_infection_count
	, (100.0*MAX(total_cases)/population) as percent_population_infected
FROM c_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC NULLS LAST;


-- 4.


SELECT location, population,date
, MAX(total_cases) as highest_infection_count
, (100.0*MAX(total_cases)/population) as percent_population_infected
FROM c_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC NULLS LAST;












-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

SELECT d.continent, d.location, d.date, d.population, MAX(v.new_vaccinations) AS rolling_people_vaccinated
FROM c_deaths d
JOIN c_vacs v
	ON d.location = v.location 
	AND d.date = v.date
WHERE d.continent IS NOT NULL
-- AND d.location = 'Albania'
-- AND v.new_vaccinations IS NOT NULL
GROUP BY d.continent, d.location, d.date, d.population
ORDER BY 1, 2, 3


-- 2.
SELECT SUM(new_cases) as total_cases
, SUM(new_deaths ) as total_deaths
, 100.0*SUM(new_deaths)/SUM(New_Cases) as death_percentage
FROM c_deaths 
WHERE continent IS NOT NULL
--Group By date
ORDER BY 1, 2

-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(new_deaths) as total_death_count
FROM c_deaths
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European Union', 'International', 
	'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY total_death_count DESC NULLS LAST;



-- 4.

SELECT location, population
, MAX(total_cases) as highest_infection_count
,  100.0*MAX(total_cases)/population as percent_population_infected
FROM c_deaths
--Where location like '%states%'
GROUP BY location, population
ORDER BY highest_infection_count DESC NULLS LAST;



-- 5.


-- took the above query and added population
SELECT location, date, population, total_cases, total_deaths
FROM c_deaths
--Where location like '%states%'
WHERE continent IS NOT NULL 
ORDER BY 1,2;


-- 6. 


WITH pop_vs_vac AS(
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
	, SUM(v.new_vaccinations) OVER(PARTITION BY d.location
								   ORDER BY d.location, d.date
								   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
										AS rolling_people_vaccinated
	FROM c_deaths d
	JOIN c_vacs v
		ON d.location = v.location 
		AND d.date = v.date
	WHERE d.continent IS NOT NULL
	)
SELECT *,  100*rolling_people_vaccinated/population::DECIMAL
FROM pop_vs_vac;