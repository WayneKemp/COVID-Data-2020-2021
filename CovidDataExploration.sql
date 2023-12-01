SELECT *
FROM coviddeaths
ORDER BY 3

SELECT location, cast(date AS DATE) AS date1, total_cases, new_cases, cast(total_deaths AS SIGNED) AS total_deaths1, population
FROM coviddeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths in United States
SELECT location, cast(date AS DATE) AS date1, total_cases, cast(total_deaths AS SIGNED) AS total_deaths1, (cast(total_deaths AS SIGNED)/total_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE location LIKE 'United States'
ORDER BY 1,2

-- Looking at Total Cases vs Population in United States
SELECT location, cast(date AS DATE) AS date1, total_cases, population, (total_cases/population)*100 AS TotalCasesPercent
FROM coviddeaths
WHERE location LIKE 'United States'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate per Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Looking at Countries with Highest Death Count per Population
-- Noticed empty string in Continent column and where data in being grouped under Location column (i.e. 'World', 'European Union', 'North America', etc.).
SELECT location, MAX(cast(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL AND continent != "" 
GROUP BY location
ORDER BY TotalDeathCount desc

-- Looking at Break Down by Continent
-- Showing the Continents with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent IS NOT NULL AND continent != "" 
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers by Day
SELECT cast(date AS DATE) AS date1, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED)) AS total_deaths, SUM(cast(new_deaths AS SIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY date1
ORDER BY 1,2

-- Global Numbers Total
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED)) AS total_deaths, SUM(cast(new_deaths AS SIGNED))/SUM(new_cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Joining Vaccination Table
-- Looking at Total Population vs Vaccinations

-- USE CTE
WITH PopvsVac AS
	(
	SELECT deaths.continent, deaths.location, cast(deaths.date AS DATE) AS date1, population, cast(vaccinations.new_vaccinations AS SIGNED) AS new_vaccinations1, SUM(cast(vaccinations.new_vaccinations AS SIGNED)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS RollingTotalVaccinations
	FROM coviddeaths deaths
	JOIN covidvaccinations vaccinations 
		ON deaths.location = vaccinations.location
        AND deaths.date = vaccinations.date
	WHERE deaths.continent IS NOT NULL
    -- ORDER BY 2,3
    )
SELECT *, (RollingTotalVaccinations/Population)*100 AS VaccinationPercentage
FROM PopvsVac

-- TEMP TABLE
DROP TEMPORARY TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated AS
	SELECT deaths.continent, deaths.location, cast(deaths.date AS DATE) AS date1, population, vaccinations.new_vaccinations, SUM(vaccinations.new_vaccinations) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS RollingTotalVaccinations
	FROM coviddeaths deaths
	JOIN covidvaccinations vaccinations
		ON deaths.location = vaccinations.location
		AND deaths.date = vaccinations.date
	WHERE deaths.continent IS NOT NULL
	-- ORDER BY 2,3
	;
SELECT *, (RollingTotalVaccinations/Population)*100 AS VaccinationPercentage 
FROM PercentPopulationVaccinated

-- Creating View to Store Data for Later Visualizations
CREATE VIEW PercentPopulationVaccinated AS
	SELECT deaths.continent, deaths.location, cast(deaths.date AS DATE) AS date1, population, cast(vaccinations.new_vaccinations AS SIGNED) AS new_vaccinations1, SUM(cast(vaccinations.new_vaccinations AS SIGNED)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) AS RollingTotalVaccinations
	FROM coviddeaths deaths
	JOIN covidvaccinations vaccinations
		ON deaths.location = vaccinations.location
		AND deaths.date = vaccinations.date
	WHERE deaths.continent IS NOT NULL
	-- ORDER BY 2,3