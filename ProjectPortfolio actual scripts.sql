SELECT *
FROM [Portfolio PROJECT]..covidDeath
ORDER BY 3,4

--SELECT *
--FROM [Portfolio PROJECT]..covidVacinations
--ORDER BY 3,4

SELECT location, date ,total_cases, new_cases, total_deaths, population_density
FROM [Portfolio PROJECT]..covidDeath
ORDER BY 1,2

--lOOKING AT TOTAL  CASES VS Total CASES
SELECT location, date, total_cases, total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float) AS DeathPercentage
FROM [Portfolio PROJECT]..covidDeath
where location like 'Gambia'
ORDER BY location,date
--simple query to check the values in the location column
select DISTINCT location
FROM [Portfolio PROJECT]..covidDeath

--LOOKING AT THE TOTAL CASES VS POLPULATON
SELECT location, date, total_cases, population_density, CAST(population_density AS float)/CAST(total_cases AS float)*100 AS DeathPercentage
FROM [Portfolio PROJECT]..covidDeath
where location like 'Gambia' AND total_cases IN (1,2)
ORDER BY  location, date

--countries with highest infection ratscompared to population
SELECT location, population_density, MAX(total_cases) HighestInfectionCount, population_density, MAX(CAST(total_cases AS float))/MAX(CAST(population_density AS float))*100 
AS PercentPopulationInfected
FROM [Portfolio PROJECT]..covidDeath
--where location like 'Gambia' AND total_cases (1,2)
GROUP BY  location, population_density
ORDER BY PercentPopulationInfected DESC


--countries with highest death  per Population
SELECT location, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM [Portfolio PROJECT]..covidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LETS BREAK THINGS DOWN

SELECT continent, MAX(CAST(total_deaths AS float)) AS TotalDeathCount
FROM [Portfolio PROJECT]..covidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases), SUM(new_deaths)
FROM [Portfolio PROJECT]..covidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [Portfolio PROJECT]..covidDeath dea
JOIN [Portfolio PROJECT]..covidVacinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 1,2,3

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

select*
from #PercentPopulationVaccinated

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [Portfolio PROJECT]..covidDeath dea
JOIN [Portfolio PROJECT]..covidVacinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
--ORDER BY 1,2,3




---creating view to store data for later use



--EXAMPLE QUERY USING THE VIEW
SELECT *,
CASE
	WHEN population_density = 0 THEN 0
	ELSE (RollingPeopleVaccinated * 100)/population_density 
	END AS PercentPeopleVaccinated
FROM PercentPopulationVaccinated
--check if it exists
SELECT*
FROM sys.objects
WHERE name = 'PercentPopulationVaccinated'

DROP VIEW PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM [Portfolio PROJECT]..covidDeath dea
JOIN [Portfolio PROJECT]..covidVacinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3


SELECT name, type_desc
FROM sys.objects
WHERE name = 'PercentPopulationVaccinated'
--check permission  to ensure necessary permission to view objects in the database
SELECT *
FROM fn_my_permissions(NULL,'DATABASE')
--Ensure you are conncted to the correct database
USE [Portfolio PROJECT];
GO 
SELECT*FROM sys.views;
--verify that the view is listef in the system catalog
SELECT*
FROM sys.objects
WHERE type = 'V'
	AND name = 'PercentPopulationVaccinated';

SELECT TOP 10 * 
FROM PercentPopulationVaccinated;

--ensure that the view is not created under a different schema
SELECT SCHEMA_NAME(schema_id) AS schema_name, name
FROM sys.objects
WHERE type = 'V'
 AND name = 'PercentPopulationVaccinated';

 --CREATE NEW VIEW
 CREATE VIEW TestView AS 
 SELECT 1 AS TestColumn
