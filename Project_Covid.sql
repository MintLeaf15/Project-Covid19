--ANALYSIS FOR TABLE 1 (COVID DEATHS)

--COVID DEATH PERCENTAGE IN MALAYSIA 
SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentageinMalaysia
FROM Project_Covid..CovidDeaths 
WHERE location = 'Malaysia' AND continent IS NOT NULL
ORDER BY 1,2


--PERCENTAGE OF POPULATION INFECTED IN MALAYSIA 
SELECT location, date, total_cases, population, ((total_cases/population)*100) AS PercentageofPopulationInfectedinMalaysia
FROM Project_Covid..CovidDeaths 
WHERE location = 'Malaysia' AND continent IS NOT NULL
ORDER BY 1,2


--PERCENTAGE OF POPULATION INFECTED BY COUNTRY [TABLE 3]
SELECT location AS Location, population AS Population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentageofPopulationInfected
FROM Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC


--TIME SERIES GRAPH FOR PERCENTAGE OF POPULATION INFECTED [TABLE 4]
SELECT location AS Location, population AS Population, date AS Date, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentageofPopulationInfected
FROM Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY 5 DESC


--TOTAL NUMBER OF DEATH BY COUNTRY
SELECT location, population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC


--ANALYSIS BY CONTINENTS

--TOTAL NUMBER OF DEATH BY CONTINENTS [TABLE 2]
SELECT location AS Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM Project_Covid..CovidDeaths
WHERE continent IS NULL AND location in ('Europe','North America','Asia','South America','Africa','Oceania')
GROUP BY location
ORDER BY 2 DESC


--GLOBAL NUMBERS [TABLE 1]
SELECT SUM(new_cases) AS Total_Cases, sum(cast(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage
FROM Project_Covid..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1,2


--ANALYSIS FOR TABLE 2 (COVID VACCINATION)

--PERCENTAGE OF POPULATION VACCINATED BY COUNTRY 
--METHOD 1 : USE CTE
WITH CTE_PeopleVaccinated AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Project_Covid..CovidDeaths AS dea 
JOIN Project_Covid..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageofPopulationVaccinated
FROM CTE_PeopleVaccinated


--METHOD 2 : USE TEMP TABLE
DROP TABLE IF EXISTS #PeopleVaccinated
CREATE TABLE #PeopleVaccinated
(continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC, 
new_vaccinations NUMERIC,
rollingpeoplevaccinated BIGINT
)

INSERT INTO #PeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Project_Covid..CovidDeaths AS dea 
JOIN Project_Covid..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageofPopulationVaccinatedbyCountries
FROM #PeopleVaccinated


--CREATE VIEW TO STORE DATA FOR VISUALIZATIONS
CREATE VIEW PeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Project_Covid..CovidDeaths AS dea 
JOIN Project_Covid..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * 
FROM PeopleVaccinated


--NEW CASES VS TOTAL VACCINATED
SELECT dea.location, dea.population, CAST(dea.date AS DATE) AS date, dea.new_cases, vac.total_vaccinations
FROM Project_Covid..CovidDeaths dea
JOIN Project_Covid..CovidVaccination vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 1,2


















