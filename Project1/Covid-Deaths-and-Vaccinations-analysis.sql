select * from
PortfolioProject..CovidDeaths
where continent is not null
order by 3,4



select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths for India
--Shows overall Likelihood of dying if you contract covid in India
select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'India'
and continent is not null
order by 1,2

--Total Cases vs Population
--Shows what percentage of population got Covid 
select Location,date,total_cases,population,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select Location,population,MAX(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc

-- Countries with Highest Total Death Count 
select Location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--Showing contintents with the highest total death count
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Exploring The CovidVaccinations Dataset

--Looking at Places with highest vaccinations
select location,max(cast(total_vaccinations as bigint)) as TotalVaccinations
from PortfolioProject..CovidVaccinations
where continent is not null
group by location
order by TotalVaccinations desc



--GLOBAL NUMBERS
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Looking at Total Population vs Deaths
select dea.continent,dea.location,dea.date,dea.population,dea.new_deaths,
SUM(CONVERT(bigint,dea.new_deaths)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleDied
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USING CTE
With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--Creating View to store data for later visualisations

drop view if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null