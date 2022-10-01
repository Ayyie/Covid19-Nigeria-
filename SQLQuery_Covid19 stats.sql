
SELECT *
FROM portfoliop..covidDeaths1$
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfoliop..covidDeaths1$

--finding the total death percentage in Nigeria

SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM portfoliop..covidDeaths1$
WHERE location like '%Nigeria%'
ORDER BY 1,2


-- finding the percentage of the poulation infected

SELECT location, date, total_cases,  population, (total_cases/population)*100 AS infected_percentage
FROM portfoliop..covidDeaths1$
WHERE location like '%Nigeria%'
ORDER BY 1,2


--comparing with total percentage of infections worldwide

SELECT location, date, total_cases,  population, (total_cases/population)*100 AS infected_percentage
FROM portfoliop..covidDeaths1$
ORDER BY 1,2

--fining highest infected populations


SELECT location,  population, MAX(total_cases) as highestInfectionCount, MAX((total_cases/population))*100 AS infected_percentage
FROM portfoliop..covidDeaths1$
 GROUP BY location, population
 ORDER BY infected_percentage desc


 --finding death rate in pouplations

 
SELECT location,   MAX(cast(total_deaths as int)) as totaldeathcount
FROM portfoliop..covidDeaths1$
WHERE continent is not null
 GROUP BY location
 ORDER BY totaldeathcount desc


 --looking at death rate by continent

 
SELECT continent,   MAX(cast(total_deaths as int)) as totaldeathcount
FROM portfoliop..covidDeaths1$
WHERE continent is not null
 GROUP BY continent
 ORDER BY totaldeathcount desc

 --deaths by continent
 SELECT continent, date, total_cases,  population, (total_cases/population)*100 AS infected_percentage
FROM portfoliop..covidDeaths1$
where continent is not null
ORDER BY 1,2
--african numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 as deathpercentage
FROM portfoliop..covidDeaths1$
WHERE continent  is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/
SUM(new_cases)*100 as deathpercentage
FROM portfoliop..covidDeaths1$
WHERE continent  is not null
--GROUP BY date
ORDER BY 1,2


--combining tables
SELECT*
FROM portfoliop..CovidVaccinations$ vac
JOIN portfoliop..covidDeaths1$ dea
ON dea.location = vac.location
and dea.date = vac.date


--finding total vaccinated worldwide

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM portfoliop..CovidVaccinations$ vac
JOIN portfoliop..covidDeaths1$ dea
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
ORDER BY 1,2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as vaccinatedtotal
FROM portfoliop..CovidVaccinations$ vac
JOIN portfoliop..covidDeaths1$ dea
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
ORDER BY 1,2,3


--CTE
with popvac (continent, location, date, population, new_vaccinations, vaccinatedtotal)
as (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as vaccinatedtotal
FROM portfoliop..CovidVaccinations$ vac
JOIN portfoliop..covidDeaths1$ dea
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 1,2,3
)
SELECT*, (vaccinatedtotal/population)*100
FROM popvac


--Temp Table
DROP Table if exists #percentagevaccinated
create Table #percentagevaccinated
(
continent nvarchar (225),
location nvarchar (225),
Date datetime,
population numeric,
new_vaccinations numeric,
vaccinatedtotal numeric
)
Insert into #percentagevaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as vaccinatedtotal
FROM portfoliop..CovidVaccinations$ vac
JOIN portfoliop..covidDeaths1$ dea
ON dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--ORDER BY 1,2,3
SELECT*, (vaccinatedtotal/population)*100
FROM #percentagevaccinated

--creating views for visualizations
Create View  coviddeaths as
 SELECT location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM portfoliop..covidDeaths1$
WHERE location like '%Nigeria%'
--ORDER BY 1,2

Create View  percentagevaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location ORDER BY dea.location,dea.date) as vaccinatedtotal
FROM portfoliop..CovidVaccinations$ vac
JOIN portfoliop..covidDeaths1$ dea
ON dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--ORDER BY 1,2,3

Create View infectionrate as
SELECT location, date, total_cases,  population, (total_cases/population)*100 AS infected_percentage
FROM portfoliop..covidDeaths1$
WHERE location like '%Nigeria%'