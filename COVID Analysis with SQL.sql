
select * from PortfolioProject..CovidDeath

-- select * from PortfolioProject..covidVaccinations

select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..CovidDeath
order by 1,2

-- Looking at total cases vs total deaths
-- show mortality of Covid in US
select location,date,total_cases,total_deaths, (total_deaths/total_cases) as Death_rate
from PortfolioProject..CovidDeath
where location='United States'
order by 2 desc

-- Looking at total cases vs popukation
-- shows what percentage of population got Covid
select location,date,population,total_cases, (total_cases/population) as infection_rate
from PortfolioProject..CovidDeath
where location='United States'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount, max((total_cases/population))as Population_infection_rate
from PortfolioProject..CovidDeath
group by location,population
order by Population_infection_rate desc

-- show countries with highest death count per population
select location,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by location
order by TotalDeathCount desc

-- Break the death count by continent
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

-- Looking at total population vs vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations
from PortfolioProject..CovidDeath d
join PortfolioProject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3

-- Rolling sum of vaccinated people by location
select d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(cast(v.new_vaccinations as BIGINT)) over (partition by d.location order by d.location,d.date) as RollingSumVaccinated
from PortfolioProject..CovidDeath d
join PortfolioProject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3

-- CTE
with cte as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(cast(v.new_vaccinations as BIGINT)) over (partition by d.location order by d.location,d.date) as RollingSumVaccinated
from PortfolioProject..CovidDeath d
join PortfolioProject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null
)
select *,(RollingSumVaccinated/population)
from cte

-- TEMP Table
drop table if exists #percentPopVaccinated
create Table #percentPopVaccinated
(continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingSumVaccinated numeric)

insert into #percentPopVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations
,SUM(cast(v.new_vaccinations as BIGINT)) over (partition by d.location order by d.location,d.date) as RollingSumVaccinated
from PortfolioProject..CovidDeath d
join PortfolioProject..CovidVaccinations v
on d.location=v.location
and d.date=v.date
where d.continent is not null

select *,(RollingSumVaccinated/population)
from #percentPopVaccinated