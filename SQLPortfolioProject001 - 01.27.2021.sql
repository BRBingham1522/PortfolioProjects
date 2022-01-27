select *
from SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst]
where continent is not null
order by 3,4

--select *
--from SQLPortfolioProject001.dbo.['Covid Vaccinations - Data Analyst]
--order by 3,4

--Select the data that I need.

select location, date, total_cases, new_cases, total_deaths, population
from SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst]
order by 1,2

--Total Cases vs. Total Deaths. Shows the likelihood of dying from COVID.

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst]
where location like '%states%'
order by 1,2

--Total Cases vs. Population

select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst]
where location like '%states%'
order by 1,2

--Countries with highest infection rate relative to population.

select location, population, MAX(total_cases) as HighestInfectionRate, MAX((total_cases/population))*100 as PercentPopulationInfected
from SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst]
group by location, population
order by PercentPopulationInfected desc

--Countries with highest deaths relative to population.

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst]
where continent is not null
group by location, population
order by TotalDeathCount desc

--Continents with highest death rate per population.

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst]
where continent is not null
group by continent
order by TotalDeathCount desc

--Global data.

select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst]
where continent is not null
order by 1, 2

--Total Population vs Vaccinations >> Did not work

With PopvsVac(Continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinated
FROM SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst] as dea
join SQLPortfolioProject001.dbo.['Covid Vaccinations - Data Analyst] as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temporary Table
Drop table #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingNumberVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinated
FROM SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst] as dea
join SQLPortfolioProject001.dbo.['Covid Vaccinations - Data Analyst] as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *, (RollingNumberVaccinated/Population)*100
from #PercentPopulationVaccinated

--Create view to store visualization data. >> 1:11:43

Drop view PercentPopulationVaccinated
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinated
FROM SQLPortfolioProject001.dbo.['Covid Deaths - Data Analyst] as dea
join SQLPortfolioProject001.dbo.['Covid Vaccinations - Data Analyst] as vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From PercentPopulationVaccinated