--SELECT *
--FROM COVID19..COVID_Deaths
--ORDER BY 3,4

--SELECT *
--FROM COVID19..COVID_Vaccines
--ORDER BY 3,4

--Shows likelihood of dying
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM COVID19..COVID_Deaths
WHERE location = 'Canada'
ORDER BY 1,2

--Looking for total cases vs population
--Shows what percentage of poplulation got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS population_finfected_percentage
FROM COVID19..COVID_Deaths
ORDER BY 1,2

--Looking at countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_cases, MAX(total_cases/population)*100 AS total_cases_per_population_rate
FROM COVID19..COVID_Deaths
GROUP BY location, population
ORDER BY 4 DESC

--Looking at countries with highest death rate compared to poplulation
SELECT location, population, MAX(total_deaths) AS highest_death_cases, MAX(total_deaths/population)*100 AS total_deaths_per_population_rate
FROM COVID19..COVID_Deaths
GROUP BY location, population
ORDER BY 4 DESC

--Looking at countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM COVID19..COVID_Deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC

--Looking at contients with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM COVID19..COVID_Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM COVID19..COVID_Deaths
WHERE continent is null AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY total_death_count DESC

--Global numbers of total deaths per population rate for the day
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
	AS total_deaths_per_population_rate
FROM COVID19..COVID_Deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at percentage of total vaccinations for the population
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.total_vaccinations, 
--	(vac.total_vaccinations/population)*100 AS vaccinations_rate
--FROM COVID19..COVID_Deaths dea
--JOIN COVID19..COVID_Vaccines vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL AND dea.location = 'China'
--ORDER BY 1,2,3

--Looking at the number of total vaccinations increasing everyday in the country
WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_ppl_vaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS rolling_ppl_vaccinated
FROM COVID19..COVID_Deaths dea
JOIN COVID19..COVID_Vaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_ppl_vaccinated/population)*100 AS vaccinated_rate
FROM PopvsVac




--Temp table
--DROP TABLE #PercentPopulationVaccinated
--ALTER TABLE COVID19..COVID_Deaths ALTER COLUMN location NVARCHAR(255)
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(150),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
rolling_ppl_vaccinated BIGINT
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS rolling_ppl_vaccinated
FROM COVID19..COVID_Deaths dea
JOIN COVID19..COVID_Vaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (rolling_ppl_vaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for later
DROP VIEW IF EXISTS PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	AS rolling_ppl_vaccinated
FROM COVID19..COVID_Deaths dea
JOIN COVID19..COVID_Vaccines vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *
FROM PercentPopulationVaccinated