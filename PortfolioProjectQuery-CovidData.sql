Select * 
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 3,4;

--Select * 
--from [Portfolio Project]..CovidVaccinations
--order by 3,4;

--Select Data we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2;


--Looking at totl cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, ((CAST(total_deaths AS FLOAT))/(CAST(total_cases AS FLOAT)))*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2;


--Looking at total cases vs population
--Shows what percentage of population got covid
Select Location, date, population, total_cases, ((CAST(total_cases AS FLOAT))/population)*100 as CovidPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
order by 1,2;


--Looking at countries with highest infection rate compared to population
--Shows what percentage of population got covid
Select Location, population, MAX(total_cases) as HighestInfection, MAX((CAST(total_cases AS FLOAT))/population)*100 as PercentagePopulationInfected
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
Group by Location, population
order by PercentagePopulationInfected desc;


--Showing countries with highest death count per population
Select Location,  MAX(CAST(total_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc;



--LET'S BREAK THINGS DON BY CONTINENT
--Showing continents with highest death count per population

Select continent,  MAX(CAST(total_deaths as float)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc;



--GLOBAL NUMBERS

Select date, SUM(CAST(new_cases as float)) as sum_cases, SUM(CAST(new_deaths as float)) as sum_deaths, ( SUM(CAST(new_deaths as float)) / SUM(CAST(new_cases as float))  ) * 100 as DeathPercentage --, total_deaths, ((CAST(total_deaths AS FLOAT))/(CAST(total_cases AS FLOAT)))*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%states%' and continent is not null
group by date
order by 1,2;


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
;


--Use CTE

With PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
from PopVsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--VIEWS 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated


