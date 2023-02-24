-- Looking at the entire covidDeaths dataset
SELECT *
FROM PortfolioProject..CovidDeaths

-- Selecting neccessary columns that are needed for further analysis

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total deaths in south africa
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%south Africa%'
ORDER BY 1,2

-- Total cases vs population in south africa
SELECT location, date, total_cases, population, (total_cases/population)* 100 AS DeathPerpopulation
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%south Africa%'
ORDER BY 1,2

-- countries with the highest infection rate per population

SELECT location, population, MAX(total_cases) As HighestInfectionCount, MAX(total_cases/population)* 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- countries with the highest death count per population

SELECT location, MAX(CAST (total_deaths as INT)) AS TotaltDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotaltDeathsCount DESC

-- Showing continents with the highest total death

SELECT continent, MAX(CAST (total_deaths as INT)) AS TotalDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathsCount DESC

-- Lets break things down by continents
 
SELECT location, MAX(CAST (total_deaths as INT)) AS HighestDeathsCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location 
ORDER BY HighestDeathsCount DESC

-- Global numbers

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, 
	SUM(CAST (new_deaths as INT))/SUM(new_cases)*100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Total cases world-wide

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, 
	SUM(CAST (new_deaths as INT))/SUM(new_cases)*100 AS DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at the entire vaccination dataset

SELECT *
FROM PortfolioProject..covidvaccinations

-- Joining a CovdVaccination table with coviddeaths table

SELECT *
FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date

 -- total populations vs new vaccinations

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 1,2,3

 -- total populations vs new vaccinations plus rooling count

  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER  (Partition by dea.location ORDER BY dea.location, dea.date) 
  AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 1,2,3

 -- use cases
 
 WITH PopvsVac (continent,location, date, population, new_vaccination, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER  (Partition by dea.location ORDER BY dea.location, dea.date) 
  AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
-- ORDER BY 1,2,3
 )
 
 SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeoplePercentageVacPerPopulation
 FROM PopvsVac


 -- Temp table

 DROP TABLE IF EXISTS #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent NVarchar(255),
 location Nvarchar(255), 
 date datetime, 
 population numeric, 
 new_vaccination numeric, 
 RollingPeopleVaccinated numeric
 )
 INSERT INTO #PercentPopulationVaccinated 
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER  (Partition by dea.location ORDER BY dea.location, dea.date) 
  AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
-- ORDER BY 1,2,3

 SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeoplePercentageVacPerPopulation
 FROM #PercentPopulationVaccinated

 --creating a view to store data for visualisation

 CREATE VIEW PercentPopulationVaccinated AS
   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(int,vac.new_vaccinations)) OVER  (Partition by dea.location ORDER BY dea.location, dea.date) 
  AS RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 INNER JOIN PortfolioProject..CovidVaccinations vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
-- ORDER BY 1,2,3

SELECT *
FROM PercentPopulationVaccinated