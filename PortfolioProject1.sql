-- check for the data loaded

select * from PortfolioProjectSQL..CovidDeaths
where continent is not null
order by 3,4;

select * from PortfolioProjectSQL..CovidVaccinations
where continent is not null
order by 3,4;

-- select the data that will be used ahead

SELECT location,date,total_cases,new_cases,total_deaths, population
from PortfolioProjectSQL..CovidDeaths
where continent is not null
order by 1,2


-- TO FIND THE TOTAL CASES VS TOTAL DEATH RATE

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS CASE_TO_DEATH_RATE
from PortfolioProjectSQL..CovidDeaths
WHERE location LIKE '%RICA%' AND  continent is not null
order by 1,2

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS CASE_TO_DEATH_RATE
from PortfolioProjectSQL..CovidDeaths
WHERE location IN ('Afghanistan','Africa') AND
total_cases BETWEEN 20000 AND 26000 AND  continent is not null
order by 1,2

-- The above queries shows the likelihood of dying if you contract covid in your country


-- TOTAL CASES VS POPULATION
--Shows what percentage of population is affected with covid

SELECT location,date,population,total_cases, (total_cases/population)*100 AS "Population to Infection rate"
from PortfolioProjectSQL..CovidDeaths
WHERE location LIKE '%RICA%' AND continent is not null
order by 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) as "Highest cases", MAX((total_cases/population))*100 AS "Infection Rate"
from PortfolioProjectSQL..CovidDeaths
WHERE location LIKE '%RICA%' AND  continent is not null
group by  location, population
order by 1,2


SELECT location, population, MAX(total_cases) as "Highest cases", MAX((total_cases/population))*100 AS "Infection Rate"
from PortfolioProjectSQL..CovidDeaths
where continent is not null
group by  location, population
order by [Infection Rate] DESC

--LOOKING INTO COUNTRIES WITH HIGHEST DEATH COUNT WRT POPULATION

SELECT location,population, MAX(total_deaths) as Total_deathCount
from PortfolioProjectSQL..CovidDeaths
where continent is not null
group by location,population
order by Total_deathCount desc


--LOOKING INTO CONTINENTS WITH HIGHEST DEATH COUNT WRT POPULATION

SELECT location, MAX(total_deaths) as Total_deathCount
from PortfolioProjectSQL..CovidDeaths
where continent is  null
group by location
order by Total_deathCount desc

SELECT continent, MAX(total_deaths) as Total_deathCount
from PortfolioProjectSQL..CovidDeaths
where continent is not null
group by continent
order by Total_deathCount desc

-- GLOBAL NUMBERS

select date,SUM(new_cases) AS NEW_CASES, SUM(new_deaths) AS NEW_DEATHS 
from PortfolioProjectSQL..CovidDeaths
where continent is not null 
group by date
order by date 

-- to find the overall death rate over the world using the total cases and total deaths

select SUM(total_cases) AS total_CASES, SUM(total_deaths) AS total_DEATHS , 
sum(total_deaths)/SUM(total_cases)*100 as deathrate
from PortfolioProjectSQL..CovidDeaths
where continent is not null 
--group by date
order by 1,2 

-- JOIN THE TWO TABLES CovidDeaths AND CovidVaccinations

select * from PortfolioProjectSQL..CovidDeaths as dea
join PortfolioProjectSQL..CovidVaccinations as vac
on dea.location=vac.location and
dea.date=vac.date

-- LOOKING AT THE TOTAL POPULATION VS VACCINATION
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
from PortfolioProjectSQL..CovidDeaths as dea
left join PortfolioProjectSQL..CovidVaccinations as vac  
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null  
order by 2,3

-- to show the rolling sum of new_vaccinations on daily basis

select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as "rolling count of vaccinations"
from PortfolioProjectSQL..CovidDeaths as dea
left join PortfolioProjectSQL..CovidVaccinations as vac  
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null  
order by 2,3

-- to find the percentage of MAx(rolling count of vaccinations)/ total population, we will have to use the parameter 
--rolling count of vaccinations, since it is just created , it cannnot be used in the same query 

-- use of CTE

With PopVsVac (continent, location, date,population,New_vaccinations,Rollingpeoplevaccinated )
as 
(
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as "Rollingpeoplevaccinated"
from PortfolioProjectSQL..CovidDeaths as dea
 join PortfolioProjectSQL..CovidVaccinations as vac  
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null  

)
select * ,(Rollingpeoplevaccinated/population)*100 as Vaccination_rate
from PopVsVac


-- USING A TEMP TABLE

drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as "Rollingpeoplevaccinated"
from PortfolioProjectSQL..CovidDeaths as dea
 join PortfolioProjectSQL..CovidVaccinations as vac  
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null  

select * ,(Rollingpeoplevaccinated/population)*100 as Vaccination_rate
from #PercentPopulationVaccinated

-- creating VIEW to store data for later visualizations

create view 

percentpopvaccinated as

select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as "Rollingpeoplevaccinated"
from PortfolioProjectSQL..CovidDeaths as dea
 join PortfolioProjectSQL..CovidVaccinations as vac  
on dea.location=vac.location and
dea.date=vac.date
where dea.continent is not null  

select * from percentpopvaccinated