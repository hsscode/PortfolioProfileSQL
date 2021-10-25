select * from PortfolioProject..coviddeath
where continent is not null 
order by 3,4

select * from PortfolioProject..covidvaccination2
order by 3,4


--selecting one data to work out 

select location, date, new_cases, total_deaths, population
from PortfolioProject..coviddeath 
where continent is not null 
order by 1,2


-- total death vs population 

select location, date, new_cases, total_deaths, population, (total_deaths/population)*100 as deathpercentage
from PortfolioProject..coviddeath
where location like '%india%'
order by 1,2

----- looking at countries with highest infection rate 

select location, population, max(new_cases)as highestspike,  max((total_deaths/population))*100 as deathpercentage
from PortfolioProject..coviddeath 
where continent is not null 
group by population, location
order by 3,4

 -- showing countries with highest  death count per population 

 select location, max(cast(total_deaths as int))as highesttotaldeath
from PortfolioProject..coviddeath 
where continent is not null 
group by location
order by highesttotaldeath desc

---- Breaking things down by Continent 


 select location, max(cast(total_deaths as int))as highesttotaldeath
from PortfolioProject..coviddeath 
where continent is null 
group by location
order by highesttotaldeath desc


-- showing continents with highest	death per population 

select continent, max(cast(total_deaths as int))as highesttotaldeath
from PortfolioProject..coviddeath 
where continent is not null 
group by continent
order by highesttotaldeath desc

---GLOBALS  NUMBER 



select date, sum(new_cases) as total_cases,  sum(cast(new_deaths as int)) as total_deaths,

SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage	

from PortfolioProject..coviddeath 
--where location like %india%
where continent is not null 
group by  date
order by 3,4 desc

-----------across the world total death percentage 
select sum(new_cases) as total_cases,  sum(cast(new_deaths as int)) as total_deaths,

SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage	

from PortfolioProject..coviddeath 
--where location like %india%
where continent is not null 
--group by  date
order by 1,2 desc

--------LOOKING AT TOTAL VACCINATION VS POPULATION

select dea.continent, dea.location, dea.date,   dea.population, vac.new_vaccinations ,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date)
from PortfolioProject..coviddeath dea
         join  PortfolioProject..covidvaccination2 vac
		 on dea.location = vac.location
		 and dea.date = vac.date 

		 where dea.continent is  not null
		 order by 2,3

-- USE CTE 

WITH popvsvac (continent, location, date, population, new_vaccinations, SummationofVaccination)
as 
(

select dea.continent, dea.location, dea.date,   dea.population, vac.new_vaccinations ,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as SummationofVaccination
 --, (SummationofVaccination/population)*100
from PortfolioProject..coviddeath dea
         join  PortfolioProject..covidvaccination2 vac
		 on dea.location = vac.location
		 and dea.date = vac.date 
 where dea.continent is  not null
		 --order by 2,3
)
select *, (SummationofVaccination/population)*100
from popvsvac



--temp table

DROP table if exists #PercentPopulationVaccinationed

create table #PercentPopulationVaccinationed
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
SummationofVaccination numeric
)
insert into #PercentPopulationVaccinationed

select dea.continent, dea.location, dea.date,   dea.population, vac.new_vaccinations ,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as SummationofVaccination
 --, (SummationofVaccination/population)*100
from PortfolioProject..coviddeath dea
         join  PortfolioProject..covidvaccination2 vac
		 on dea.location = vac.location
		 and dea.date = vac.date 
 --where dea.continent is  not null
		 --order by 2,3



		 select *, (SummationofVaccination/population)*100
from #PercentPopulationVaccinationed


--Creating view to store data for later visaulization

create view PercentPopulationVaccinationed as 
select dea.continent, dea.location, dea.date,   dea.population, vac.new_vaccinations ,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as SummationofVaccination
 --, (SummationofVaccination/population)*100
from PortfolioProject..coviddeath dea
         join  PortfolioProject..covidvaccination2 vac
		 on dea.location = vac.location
		 and dea.date = vac.date 
  --dea.continent is  not null
		 --order by 2,3

		 select * from PercentPopulationVaccinationed