select *
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4



--select *
--from PortfolioProject..covidvaccinations
--order by 3,4


-- selecting Data i'm going to be using.

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2

-- Using Total cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your Country

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not NULL

-- Taking a look of Total Cases vs Population
-- Shows what Population was infected with Covid

select location,date,total_cases,population, (total_cases/Population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%states%'
order by 1,2

-- Looking at countries with the highest infection rate compared to Population

select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death count per population

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not NULL
Group by location
order by TotalDeathCount desc

-- BREAKING IT DOWN BY CONTINENT

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population
select SUM(New_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinted
--, (RollingpeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 order by 2,3

	-- USE CTE
	With popvsvac (Continent,location,date,population,new_vaccinations,RollingpeopleVaccinted)
	as
	(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinted
--, (RollingpeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
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
from portfolioproject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	-- where dea.continent is not null
	-- order by 2,3

	select*, (RollingpeopleVaccinted/population)*100
	from #PercentpopulationVaccinated



	--Creating views to store Data for Visualization later
	Create view PercentpopulationVaccinated as
	 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingpeopleVaccinted
--, (RollingpeopleVaccinated/population)*100
from portfolioproject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3


select*
from PercentpopulationVaccinated
	 