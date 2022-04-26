/*
This project looks at two covid datasets up to the 12th April 2022.
One dataset looks at cases and deaths and one looks at vaccinations.
Below we investigate this dataset using SQL.

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE population is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, Population, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE population is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
-- Continent is null to exclude continents as a whole from data

SELECT location, Population, date, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentPopulationInfected desc


-- Showing Countries With Highest Death Count
-- Continent is null to exclude continents as a whole from data

SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

-- Showing Continent With Highest Death Count
-- Continent is Null to include only Continents
-- Exclude all locations that aren't Continents

SELECT location, SUM(CAST(new_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL 
AND location NOT LIKE '%income%' 
AND location NOT in ('International', 'European Union', 'World')
GROUP BY location
ORDER BY TotalDeathCount desc

-- Total Global Numbers up to 11/4/22

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

-- Looking at total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS 
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
AND dea.population is not null
ORDER by 2,3


-- Using a CTE to obtain a percentage of Rolling People Vaccinated

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS 
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
AND dea.population is not null
--ORDER by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac





-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS 
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
AND dea.population is not null
ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated

-- Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER by dea.location, dea.date) AS 
RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
and dea.population is not null