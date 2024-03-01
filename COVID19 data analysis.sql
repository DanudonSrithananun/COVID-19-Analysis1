Select * 
From [Dataanyltics Porfolio].dbo.CovidVaccinations$
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From [Dataanyltics Porfolio].dbo.CovidDeaths$
order by 1,2


--looking at Total cases vs Total Deaths 
--Show the chance of dying in percentage from Covid based on total_cases by total_deaths
Select Location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as DeathPercentage
From [Dataanyltics Porfolio].dbo.CovidDeaths$
where location like '%Thai%'
order by total_cases desc

--Looking at Total Cases vs Population 
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationinfected
From [Dataanyltics Porfolio].dbo.CovidDeaths$
where location like '%Thai%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population 

Select Location,Population, Max(total_cases) as HighestInfectioncount, (Max((total_cases)/population))*100 as PercentPopulationinfected
From [Dataanyltics Porfolio].dbo.CovidDeaths$
--where location like '%Thai%'
Group by Location,Population
order by PercentPopulationinfected desc

--Looking at Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Dataanyltics Porfolio].dbo.CovidDeaths$
--where location like '%Thai%'
where continent is not null
Group by Location,Population
order by TotalDeathCount desc

--Now, we will look at each continents with Highest Death Count per populatio
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Dataanyltics Porfolio].dbo.CovidDeaths$
where continent is null 
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Dataanyltics Porfolio].dbo.CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking at Total Population vs Vaccianations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order by dea.Location, dea.date)
 as Added_Totalvaccinated
From [Dataanyltics Porfolio]..CovidDeaths$ dea
join [Dataanyltics Porfolio]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Added_Totalvaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) over (Partition by dea.Location Order by dea.Location, dea.date)
 as Added_Totalvaccinated
From [Dataanyltics Porfolio]..CovidDeaths$ dea
join [Dataanyltics Porfolio]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
Select *, (Added_Totalvaccinated/Population)*100
From PopvsVac


--  TEMP Table 

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeaths$ dea
Join dbo.CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as VaccinatedpeoplePercentage
From #PercentPopulationVaccinated






