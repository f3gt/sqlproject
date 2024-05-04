select * from 
portfolio..CovidDeath
where continent is not null
order by 3,4

select * 
from portfolio..CovidVaccination
order by 3,4

--select data we are going to use
select location, date,total_cases,new_cases,total_deaths,new_deaths,population
from portfolio..CovidDeath
where continent is not null
order by 1,2

--looking total cases vs total death
--shows the likelihood of dying by covid

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from portfolio..CovidDeath
where location like '%india%'
--where continent is not null
order by 1,2

--total cases vs population

select location, date,population,total_cases,(total_cases/population)*100 as populationCases
from portfolio..CovidDeath
--where location like '%India%'
where continent is not null
order by 1,2

--looking at country with highest infection rate compare to population

select location,population,max(total_cases) as Hihest_infect_count,max(total_cases/population)*100 as maxPopulationCasesPercentage
from portfolio..CovidDeath
--where location like '%India%'
where continent is not null
group by location,population
order by maxPopulationCasesPercentage

--country with highest death rate per population


select location,max(cast( total_deaths as int)) as Death_count
from portfolio..CovidDeath
--where location like '%India%'
where continent is not null
group by location
order by Death_count desc

--let break down by continent

select continent,max(cast( total_deaths as int)) as Death_count_per_continent
from portfolio..CovidDeath
--where location like '%India%'
where continent is not  null
group by continent
order by Death_count_per_continent desc

--Global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)),sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolio..CovidDeath
where location like '%india%'
--where continent is not null
--group by date
order by 1,2


select * 
from portfolio..CovidDeath as dea
join portfolio..CovidVaccination as vacc
	on dea.location=vacc.location
	and dea.date=vacc.date

--total population vs total vaccination

SELECT 
    dea.continent, 
    dea.location,
    dea.date,
    population,
    vacc.new_vaccinations,
    SUM(convert(int,vacc.new_vaccinations)) OVER(partition by dea.location Order by dea.date) as RollingPeopleVaccination,

FROM 
    portfolio..CovidDeath as dea
JOIN 
    portfolio..CovidVaccination as vacc
    ON dea.location = vacc.location
    AND dea.date = vacc.date
WHERE  
    dea.continent IS NOT NULL
ORDER BY 
    2, 3;


--CTE

with PopvsVac(continent,location,date,population,New_Vaccination,RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent, 
    dea.location,
    dea.date,
    population,
    vacc.new_vaccinations,
    SUM(convert(int,vacc.new_vaccinations)) OVER(partition by dea.location Order by dea.date) as RollingPeopleVaccinated

FROM 
    portfolio..CovidDeath as dea
JOIN 
    portfolio..CovidVaccination as vacc
    ON dea.location = vacc.location
    AND dea.date = vacc.date
WHERE  
    dea.continent IS NOT NULL
--ORDER BY 2, 3
)

select *, (RollingPeopleVaccinated/population)/100 as per
from PopvsVac


--Temp table


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
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio..CovidDeath dea
Join portfolio..CovidVaccination vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--creating view to store data for later visualization

create view PercentPopulationVacciated1 as 

Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio..CovidDeath dea
Join portfolio..CovidVaccination vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 
--order by 2,3











