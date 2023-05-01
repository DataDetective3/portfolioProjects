--Confirming table
SELECT *
FROM CovidDeathsP$
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM CovidVaccinationP$
--ORDER BY 3,4;

--Select useful data
--Based on countries
SELECT 
location, 
date, 
total_cases, 
new_cases, 
total_deaths, 
population
FROM CovidDeathsP$
ORDER BY 1,2;

--Looking at total_cases vs total_deaths
--Shows the likely hood of dying if infected by covid in Nigeria
SELECT 
location, 
date, 
total_cases, 
total_deaths, 
(total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeathsP$
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2;



--Looking at total_cases vs population
--shows percentage popuation infected with covid in nigeria
SELECT location,
date, 
total_cases, 
population, 
(total_cases/population)*100 AS infected_population_percentage
FROM CovidDeathsP$
WHERE location LIKE '%Nigeria%'
ORDER BY 1,2;

--looking at countries with higest infection rate
SELECT 
location,
population,
MAX(total_cases) AS higest_infection_count, 
MAX((total_cases/population))*100 AS infected_population_percentage
FROM CovidDeathsP$
--WHERE location LIKE '%Nigeria%'
GROUP BY population, location
ORDER BY infected_population_percentage DESC;


--looking at countries with higest death count
SELECT 
location,
MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidDeathsP$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

SELECT 
location,
MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM CovidDeathsP$
--WHERE location LIKE '%Nigeria%'
WHERE continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC;


--By continent

--Looking at total_cases vs total_deaths
SELECT 
continent, 
date, 
total_cases, 
total_deaths, 
(total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeathsP$
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Global numbers
SELECT 
--date, 
SUM(new_cases) AS total_cases,
SUM(CAST(new_deaths AS INT)) AS total_death,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentages
FROM CovidDeathsP$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

--shows continent's higest infection rate
SELECT 
continent,
MAX(total_cases) AS higest_infection_count, 
MAX((total_cases/population))*100 AS highest_infected_percentage
FROM CovidDeathsP$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_infected_percentage DESC;

--shows continent's higest death count
SELECT 
continent,
MAX(CAST(total_deaths AS INT)) AS highest_death_count
FROM CovidDeathsP$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_death_count DESC;


-- using both tables
SELECT *
FROM CovidDeathsP$ AS d
FULL OUTER JOIN CovidVaccinationP$ AS v
ON d.location = v.location
AND d.date = v.date;

-- total population vs vaccination
SELECT
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS roll_vaccination_count
FROM CovidDeathsP$ AS d
FULL OUTER JOIN CovidVaccinationP$ AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 1,2,3;


--Using CTE
WITH PopVsVac AS(
SELECT
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS roll_vaccination_count
FROM CovidDeathsP$ AS d
FULL OUTER JOIN CovidVaccinationP$ AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL
--ORDER BY 1,2,3
)
SELECT *, (roll_vaccination_count/population)*100
FROM PopVsVac

--Using Temp table
DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
roll_vaccination_count NUMERIC
)

INSERT INTO  #PercentPopulationVaccinated
SELECT
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS roll_vaccination_count
FROM CovidDeathsP$ AS d
FULL OUTER JOIN CovidVaccinationP$ AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *,  (roll_vaccination_count/population)*100
FROM #PercentPopulationVaccinated;

--Storing data for later visualizations
--using view
CREATE VIEW  PercentPopulationVaccinated AS 
SELECT
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS roll_vaccination_count
FROM CovidDeathsP$ AS d
FULL OUTER JOIN CovidVaccinationP$ AS v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated;