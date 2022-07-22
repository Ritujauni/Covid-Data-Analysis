/*Covid-19 Data Exploration

Skills used : Joins, Temp Tables, Window Functions, Aggregate Functions, Views, Converting Data Types

*/
select *
from CovidData..CovidDeaths$
order by 2,3,4

select *
from CovidData..CovidVaccinations$
 order by 3,4

---selecting the data to be used

Select location,date,total_cases,new_cases,total_deaths,population
from CovidData..CovidDeaths$
where continent is not NULL
order by 1,2

-- Total Cases and Total Deaths

Select location,sum(cast(total_cases as bigint)) as total_cases,sum(cast(total_deaths as bigint)) as total_deaths
from CovidData..CovidDeaths$
where continent is not NULL
group by location
order by 2 desc

-- Likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,round(((total_deaths/total_cases)*100),2) as death_percent
from CovidData..CovidDeaths$
where location like '%states%' and continent is not NULL
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population  got covid

Select location,date,total_cases,population,round(((total_cases/population)*100),2) as percent_covidcases
from CovidData..CovidDeaths$
where location like '%states%' and continent is not NULL
order by 1,2

--- Countries with highest infection rate based on population

Select location,population,MAX(cast(total_cases as bigint)) as HighestInfectionCount,
max(round(((total_cases/population)*100),2)) as percentpopulation_infected
from CovidData..CovidDeaths$
where continent is not NULL
group by location,population
order by 4 desc

--- Countries with highest death rate per population

Select location,MAX(cast(total_deaths as bigint)) as HighestInfectionCount
from CovidData..CovidDeaths$
where continent is not NULL
group by location
order by 2 desc

--Breaking things with respect to continent

---- Continents with highest death count per population

Select continent,MAX(cast(total_deaths as bigint)) as HighestInfectionCount
from CovidData..CovidDeaths$
where continent is not NULL
group by continent
order by 2 desc

--- Global Numbers by day

Select  date,sum(new_cases) as new_cases,sum(cast(new_deaths as int)) as New_deaths,
ROUND(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as death_percent
from CovidData..CovidDeaths$
where continent is NOT NULL
group by date
order by 1


-- overall global numbers

Select sum(new_cases) as new_cases,sum(cast(new_deaths as int)) as New_deaths,
ROUND(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as death_percent
from CovidData..CovidDeaths$
where continent is NOT NULL
order by 1

--- Total Population vs Vaccination

select d.continent, d.location,d.date,cast(d.population as bigint)  as population,v.new_vaccinations,
sum(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)
as RollingPeopleVaccinated
from CovidData..CovidDeaths$ d
join CovidData..CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
where d.continent is NOT NULL
order by 2,3

-- Using CTE for previous query

With PopVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select d.continent,d.location,d.date,cast(d.population as bigint)  as population,v.new_vaccinations,
sum(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)
as RollingPeopleVaccinated
from CovidData..CovidDeaths$ d
join CovidData..CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
where d.continent is NOT NULL and d.location  like '%states%'
)
select *, round((RollingPeopleVaccinated/population)*100,2) from PopVac


-- Using Temp Table for previous query

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select d.continent,d.location,d.date,cast(d.population as bigint)  as population,v.new_vaccinations,
sum(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)
as RollingPeopleVaccinated
from CovidData..CovidDeaths$ d
join CovidData..CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
--where d.continent is NOT NULL

select *, round((RollingPeopleVaccinated/population)*100,2) from #PercentPopulationVaccinated

-- Views

Create View PercentPopulationVaccinated as
select d.continent, d.location,d.date,cast(d.population as bigint)  as population,v.new_vaccinations,
sum(CONVERT(bigint,v.new_vaccinations)) over (partition by d.location order by d.location,d.date)
as RollingPeopleVaccinated
from CovidData..CovidDeaths$ d
join CovidData..CovidVaccinations$ v
on d.location = v.location
and d.date = v.date
where d.continent is NOT NULL