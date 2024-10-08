Select *
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
order by 3, 4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3, 4

--select the Data that we are going to use
Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
order by 1, 2

-- Looking at Total cases vs Total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
order by 1, 2

-- Shows the likelihood of dying if you contact covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
AND continent is not NULL
order by 1, 2

-- Looking at Total cases vs Population
-- shows the percentage of the population that got covid
Select location, date, population, total_cases, (total_cases/population)*100 AS Percentage_of_pop_Infected
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
order by 1, 2

Select location, date, population, total_cases, (total_cases/population)*100 AS Percentage_of_pop_Infected
From [Portfolio Project]..CovidDeaths
WHERE location like '%states%'
AND continent is not NULL
order by 1, 2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percentage_of_pop_Infected
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
Group by location, population
order by Percentage_of_pop_Infected DESC


--Showing Countries with Highest Deaths Count per Population
Select location, MAX(cast(total_deaths AS int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
Group by location
order by TotalDeathCount DESC

-- Let's Break Things Down by Continent
Select continent, MAX(cast(total_deaths AS int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
Group by continent

-- Showing continent with their highest total_deaths
Select location, MAX(cast(total_deaths AS int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is NULL
Group by location
order by TotalDeathCount DESC

-- Showing continent with the highest death count per population
Select continent, MAX(cast(total_deaths AS int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
Group by continent
order by TotalDeathCount DESC

-- Breaking Into Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not NULL
Group by date
order by 1, 2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as INT)) as total_deaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not NULL
order by 1, 2

-- Join covid deaths table and the covid vaccinations table
Select *
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
Order by 1, 2, 3

-- Calculating a running sum of new vaccinations by location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
Order by 2, 3

-- USE CTE to get the percentage of the population that got vaccinated on each rolling peaople vaccination.
WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL
)
Select *, (Rolling_People_Vaccinated/population)*100
From PopvsVac

-- USE TEMP TABLE to get the percentage of the population that got vaccinated on each rolling peaople vaccination.

Drop Table if exists #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)
Insert into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL



Select *, (Rolling_People_Vaccinated/population)*100
From #Percent_Population_Vaccinated


--Creating a view to store data for later visualizations
Create view Percent_Population_Vaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) AS Rolling_People_Vaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not NULL


Select *
From Percent_Population_Vaccinated