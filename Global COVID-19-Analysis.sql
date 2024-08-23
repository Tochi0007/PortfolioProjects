select *
from CovidDeaths
where continent is not NULL
order by 3,4



--select *
--from covidvaccinations
--order by 3,4


select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
where continent is not NULL
order by 1,2

-- Using Total cases vs Total Deaths
-- Showing the likelihood of dying if one contracts Covid in the UK

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%United kingdom%'
and continent is not NULL

-- Total Cases vs Population
-- Showing what Population was infected with Covid

select location,date,total_cases,population, (total_cases/Population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%United Kingdom%'
order by 1,2

-- Grouping Countries with Highest Death count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not NULL
Group by location
order by TotalDeathCount desc

--Grouping Continents with Highest Death count per population
select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where continent like '%America%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc

--Grouping Countries with the highest infection rate per Population

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
from CovidDeaths
--where location like '%states%'
Group by location, Population
order by PercentPopulationInfected desc


--Grouping Countries, Continent with the highest infection rate vs Population infected

select Location, continent, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
from CovidDeaths
--where continent is not null
Group by Location,continent,Population
order by PercentPopulationInfected desc

-- TOTAL DEATH COUNT BY CONTINENT

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--TOTAL DEATH COUNT BY COUNTRY

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%states%'
Group by Location
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population
select SUM(New_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinted
--, (RollingpeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

	-- Using CTE
	With popvsvac (Continent,location,date,population,new_vaccinations,RollingpeopleVaccinted)
	as
	(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinted
--, (RollingpeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3
	 )
	 select*, (RollingpeopleVaccinted/POPULATION)*100
	 from popvsvac

	 -- Temp Table
	 Drop Table if exists #PercentpopulationVaccinated
	 Create Table #PercentpopulationVaccinated
	 (
	 Continent nvarchar(255),
	 Location nvarchar(255),
	 Date Datetime,
	 Population numeric,
	 new_vaccinations numeric,
	 RollingpeopleVaccinted numeric
	 )
	 
	 insert into #PercentpopulationVaccinated
	 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinted
--, (RollingpeopleVaccinated/population)*100
from CovidDeaths dea
join CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	-- where dea.continent is not null
	-- order by 2,3

	select*, (RollingpeopleVaccinted/population)*100
	from #PercentpopulationVaccinated



	--Creating views
 Create view PercentpopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinted
from portfolioproject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null

	 Create view DeathCountbyCountry as 
	 select location, MAX(Cast(total_deaths as int)) as DeathCounts
	 from CovidDeaths
	 --where location is not NULL
	 Group by location


	 