-- Alter column from nvarchar to float
--alter table CovidDeaths alter column total_cases float
--alter table CovidDeaths alter column total_deaths float

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs. Total Deaths in the U.S.
-- Shows chance of dying from Covid in the U.S.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100.0 as DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1, 2

-- Looking at Total Cases vs. Population
-- Shows percentage of the population getting Covid
SELECT location, date, total_cases, population, (total_cases/population)*100.0 as ChanceOfGettingCovid
FROM CovidPortfolioProject..CovidDeaths
WHERE location like '%states%'
order by 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100.0 as ChanceOfGettingCovid
FROM CovidPortfolioProject..CovidDeaths
GROUP BY Location, Population
order by 4 DESC

-- Looking at Countries with Highest Death Count per Population
SELECT location, MAX(Total_deaths) as TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
GROUP BY Location
order by 2 DESC

-- Death Count by continent per population
SELECT continent, MAX(Total_deaths) as TotalDeathCount
FROM CovidPortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by 2 DESC

-- Global numbers for Death Percentage
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
FROM CovidPortfolioProject..CovidDeaths
where continent is not null
order by 1, 2

-- Looking at Total Population vs. Vaccinations
-- Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(float, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidPortfolioProject..CovidDeaths dea
JOIN CovidPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated