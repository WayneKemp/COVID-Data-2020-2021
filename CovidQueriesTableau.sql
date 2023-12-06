SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED INTEGER)) AS total_deaths, SUM(cast(new_deaths AS SIGNED INTEGER))/SUM(New_Cases)*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL 
	AND continent != ''
ORDER BY 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location

-- SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS SIGNED)) AS total_deaths, SUM(cast(new_deaths AS SIGNED))/SUM(New_Cases)*100 AS DeathPercentage
-- FROM coviddeaths
-- WHERE location LIKE 'World'
-- ORDER BY 1,2


-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(cast(new_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
WHERE continent LIKE '' 
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


SELECT location, population, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PercentPopulationInfected
From coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


SELECT location, population, date, max(total_cases) AS HighestInfectionCount, max((total_cases/population))*100 AS PercentPopulationInfected
From coviddeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc