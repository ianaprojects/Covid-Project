SELECT * FROM c_deaths
WHERE continent IS NOT NULL;
SELECT * FROM c_vacs
WHERE continent IS NOT NULL;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM c_deaths;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country 
SELECT location, date, total_cases, total_deaths
,100*total_deaths/total_cases::decimal AS death_percentage
FROM c_deaths
WHERE continent IS NOT NULL
-- AND location = 'Russia'
ORDER BY location,date;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases 
,100*total_cases/population::decimal AS percent_population_infected
FROM c_deaths
WHERE continent IS NOT NULL
-- AND location = 'Russia'
ORDER BY location,date;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count 
,MAX(100*total_cases/population::decimal) AS percent_population_infected
FROM c_deaths
WHERE continent IS NOT NULL
-- AND location = 'Russia'
GROUP BY location, population
ORDER BY percent_population_infected DESC NULLS LAST;

-- Showing the countries with the highest death count per population
SELECT location, MAX(total_deaths) AS total_death_count
FROM c_deaths
WHERE continent IS NOT NULL
-- AND location = 'Russia'
GROUP BY location
ORDER BY total_death_count DESC NULLS LAST;

-- Showing continets with the highest death count per population
SELECT location, MAX(total_deaths) AS total_death_count
FROM c_deaths
WHERE continent IS  NULL
GROUP BY location
ORDER BY total_death_count DESC NULLS LAST;


-- GLOBAL NUMBERS
-- DEATHS PER CASES GLOBALLY
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths
, 100*SUM(new_deaths)/SUM(new_cases)::DECIMAL AS death_percentage
FROM c_deaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;



-- Looking at total population vs vaccinations

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
-- AND d.location = 'Albania'
-- AND v.new_vaccinations IS NOT NULL
ORDER BY 2, 3

-- USE CTE
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

-- USE TEMP TABLE
DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TEMP TABLE percent_population_vaccinated
(continent varchar(255),
 location varchar(255),
 date date,
 population bigint,
 new_vaccinations bigint,
 rolling_people_vaccinated bigint
 );
 
 INSERT INTO percent_population_vaccinated
 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
	, SUM(v.new_vaccinations) OVER(PARTITION BY d.location
								   ORDER BY d.location, d.date
								   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
										AS rolling_people_vaccinated
	FROM c_deaths d
	JOIN c_vacs v
		ON d.location = v.location 
		AND d.date = v.date
	WHERE d.continent IS NOT NULL;

SELECT * FROM percent_population_vaccinated;

-- Creating view to store data for later vizualisations

CREATE VIEW percent_population_vaccinated AS
 SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
	, SUM(v.new_vaccinations) OVER(PARTITION BY d.location
								   ORDER BY d.location, d.date
								   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
										AS rolling_people_vaccinated
	FROM c_deaths d
	JOIN c_vacs v
		ON d.location = v.location 
		AND d.date = v.date
	WHERE d.continent IS NOT NULL;

SELECT * FROM 
percent_population_vaccinated