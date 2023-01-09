--------------COVID DEATHS TABLE------------------------------
--------------Looking at Total Cases vs Total Deaths / Percentage of People Dying due to Covid in Malaysia

SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) AS DeathPercentageinMalaysia
FROM Project_Covid..CovidDeaths 
WHERE location = 'Malaysia' AND continent IS NOT NULL
ORDER BY 1,2


--------------Looking at Total Cases vs Population / Percentage of Population that got Covid in Malaysia

SELECT location, date, total_cases, population, ((total_cases/population)*100) AS PercentageofPopulationInfectedinMalaysia
FROM Project_Covid..CovidDeaths 
WHERE location = 'Malaysia' AND continent IS NOT NULL
ORDER BY 1,2


--------------Countries with Highest Infection Rate compare to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentageofPopulationInfected
FROM Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--------------Countries with Highest Death Count per Population

SELECT location, population, MAX(CAST(total_deaths AS INT)) AS TotalDeathCountbyCountries
FROM Project_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 3 DESC

--------------LET'S BREAK THINGS DOWN INTO CONTINENTS
--------------Showing Continents with Highest Death Count per Population

SELECT location AS Continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCountbyContinents
FROM Project_Covid..CovidDeaths
WHERE continent IS NULL AND location in ('Europe','North America','Asia','South America','Africa','Oceania')
GROUP BY location
ORDER BY 2 DESC

--------------GLOBAL NUMBERS

SELECT SUM(new_cases) AS SumNewCases, sum(cast(new_deaths AS INT)) AS SumNewDeaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS GlobalDeathPercentage
FROM Project_Covid..CovidDeaths 
WHERE continent IS NOT NULL
ORDER BY 1,2

--------------COVID VACCINATION TABLE------------------------------
--------------Looking at Total Populations vs Vaccinations
------ 2 method to convert data type to integer-------

-----------USE CTE---------------

WITH CTE_PeopleVaccinated AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Project_Covid..CovidDeaths AS dea 
JOIN Project_Covid..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageofPopulationVaccinatedbyCountries
FROM CTE_PeopleVaccinated


-----------USE TEMP TABLE---------------

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

-----------should be order by date only. same results---------------

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.date) AS RollingPeopleVaccinated
FROM Project_Covid..CovidDeaths AS dea 
JOIN Project_Covid..CovidVaccination AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

------ Creating Views to Store Data for Visualizations Later-------

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