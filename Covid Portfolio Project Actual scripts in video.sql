select *
from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from Portfolioproject..CovidVaccinations
--order by 3,4

-- select data that we're going to be using
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- how many cases are there in this country? 
--and then how many deaths do they have for there entire cases?
-- what's the percentage of people who died wiht covid?


-- troubleshoot 
--alter table PortfolioProject..CovidDeaths
--alter column total_deaths float

--shows the likelyhood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'United States'
order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Philippines'
order by 1,2


--lookign at total cases vs population
--show the percentage of the population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as CovidCasesPercentage
from PortfolioProject..CovidDeaths
where location = 'Philippines'
order by 1,2

select Location, date, total_cases, population, (total_cases/population)*100 as CovidCasesPercentage
from PortfolioProject..CovidDeaths
where location = 'United States'
order by 1,2

--looking at country with highest infection rate compared to population

select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as CovidCasesPercentage
from PortfolioProject..CovidDeaths
--where location = 'United States'
group by location, population
order by CovidCasesPercentage desc


--shows the countries with highest death count per population
select Location, population, max(total_deaths) as HighestDeathCounts, max((total_deaths/population))*100 as CovidDeathPercentage
from PortfolioProject..CovidDeaths
--where location = 'United States'
where continent is not null
group by location, population
order by CovidDeathPercentage desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc



--troubleshoot
update PortfolioProject..CovidDeaths
SET new_cases = null 
where new_cases = 0


update PortfolioProject..CovidDeaths
SET new_deaths = null 
where new_deaths = 0


--global numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--looking total population vs total vacinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


--USE CTE
with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)

select*, (RollingPeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(250),
location nvarchar(250),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating views to store data for later visualizations

create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3


select *
from PortfolioProject..PercentagePopulationVaccinated