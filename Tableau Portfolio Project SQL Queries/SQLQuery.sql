--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3, 4

SELECT *
FROM PortfolioProject..CovidVaccinations vac
ORDER BY 3, 4

-- Select Data that we are going to be using
Select  location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in specific country
Select  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location = 'Poland' AND continent is not null
ORDER BY 1, 2

-- Total Cases vs Population
-- shows what  percentage of populaton got covid
SELECT  location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Poland' AND continent is not null
ORDER BY 1, 2

-- Countries with highest infection rate
SELECT  location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectedPercentage desc

-- Countries with highest Death Count per population
SELECT Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc

-- Continates with highest Death Count per population
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null AND location not in ('High income', 'Upper middle income', 'Lower middle income', 'Low income', 'International')
GROUP BY continent
ORDER BY TotalDeathCount desc



-- Global numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2

-- DeathPercentage Gloaly by date
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3 

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac