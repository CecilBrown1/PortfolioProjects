Select *
From Portfolioprojec1..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From Portfolioprojec1..CovidVaccinations
--order by 3,4

--select data hat we going to use 


Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolioprojec1..CovidDeaths
order by 1,2


--total cases vs total deaths
-- shows likelyhood of dying of covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
From Portfolioprojec1..CovidDeaths
where location like '%states%'
order by 1,2

--total cases vs population
--shows what % of populaction got Covid

Select Location, date, Population, total_cases,  (total_cases/Population)*100 as PercentPopulationInfected 
From Portfolioprojec1..CovidDeaths
where location like '%states%'
order by 1,2

--look at countries with the higest infection rate compared to populaction

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/Population))*100 as PercentPopulationInfected
From Portfolioprojec1..CovidDeaths
group by Location, Population
order by PercentPopulationInfected desc

--look at countries with the highest death count per populaction

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioprojec1..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc


--break up by continent

--contitents with the higest death count per population


Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioprojec1..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



--Global numbers
Select date, SUM(new_cases)as total_caes, SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(total_deaths as int))/SUM(New_cases) as Deathpercentage 
From Portfolioprojec1..CovidDeaths
where continent is not null
group by date
order by 1,2


Select  SUM(new_cases)as total_caes, SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(total_deaths as int))/SUM(New_cases) as Deathpercentage 
From Portfolioprojec1..CovidDeaths
where continent is not null
order by 1,2

--Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From Portfolioprojec1..CovidDeaths dea
Join Portfolioprojec1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From Portfolioprojec1..CovidDeaths dea
Join Portfolioprojec1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date)
as RollingPeopleVaccinated
From Portfolioprojec1..CovidDeaths dea
Join Portfolioprojec1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--creating view to store data for visualizations 


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
From Portfolioprojec1..CovidDeaths dea
Join Portfolioprojec1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



Select *
From PercentPopulationVaccinated