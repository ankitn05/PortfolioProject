use Project;

-- Selecting data that we are going to be using

SELECT  location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- shows the mortality rate in India

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM covid_deaths
WHERE location = 'india'
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows the percentage of population contracted Covid
SELECT location, date, population,  total_cases, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM covid_deaths
ORDER BY 1,2;

--  Top 10 Countries with Highest InfectionRate
SELECT TOP 10 location, population,  MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases)/population)*100 AS PercentOfPopulationInfected
FROM covid_deaths
WHERE continent IS NOT NULL						-- In our dataset continents are also present in location column and corresponding continent column is Null there.
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC;


-- TOP 10 Countries with Highest Death Count

SELECT TOP 10 location, MAX(CAST(total_deaths AS INT)) TotalDeathCount        -- total_deaths column is of VARCHAR datatype.
FROM covid_deaths
WHERE continent IS NOT NULL                  
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- Death Count Continent wise

SELECT location, MAX(CAST(total_deaths AS INT)) TotalDeathCount        -- total_deaths column is of VARCHAR datatype.
FROM covid_deaths
WHERE continent IS  NULL AND location in ('Europe', 'Asia', 'North America', 'Africa', 'South America', 'Oceania')               
GROUP BY location
ORDER BY TotalDeathCount DESC;




-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS MortalityRate
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Let's check the vaccination table

SELECT * FROM covid_vaccinations;


-- Joining covid and vaccination table
SELECT * FROM 
covid_deaths d JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date;


-- Total Vaccination vs Population

With VacRate (Continent, Location, Date, Population, Daily_Vaccinations, Total_Vaccinations)
AS
(
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) 
	FROM covid_deaths d JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
)
SELECT *, (Total_Vaccinations/Population)*100 AS VaccinationPercentage
FROM VacRate;



-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Total_Vacccinations
	FROM covid_deaths d JOIN covid_vaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;

 
SELECT * FROM PercentPopulationVaccinated;