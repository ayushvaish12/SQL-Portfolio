--Select data for exploration

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM ProjectPortfolio..COVIDDEATHS
WHERE continent is not null
ORDER BY 1,2

--Total cases vs Total Deaths (Death Percentage)

SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS Death_per_case
FROM ProjectPortfolio..COVIDDEATHS
WHERE continent is not null --and location like '%ALG%' 
ORDER BY 1,2

--Percentage of population affected by COVID

SELECT Location,date,population,total_cases,(total_cases/population)*100 AS Positive_percentage
FROM ProjectPortfolio..COVIDDEATHS
WHERE location like 'Ang%' and continent is not null
ORDER BY 1,2

--Countries with Highest Infection compared to population

SELECT Location,population,MAX(total_cases) AS HighestInfectionCount,(max(total_cases/population))*100 AS Highest_infection_rate
FROM ProjectPortfolio..COVIDDEATHS
GROUP BY Location,population
ORDER BY Highest_infection_rate desc

--Countries with highest Death Count compared to population

SELECT Location,MAX(total_deaths) AS HighestDeathCount
FROM ProjectPortfolio..COVIDDEATHS
WHERE continent is not null
GROUP BY Location
ORDER BY HighestDeathCount desc

-- Continents with Highest Death Counts

SELECT continent,MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM ProjectPortfolio..COVIDDEATHS
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc

-- GLOBAL Numbers


SELECT  SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, COALESCE(SUM(new_deaths)/NULLIF(SUM(new_cases),0) ,0)*100 as Death_per_new_case
FROM ProjectPortfolio..COVIDDEATHS
WHERE continent is not null
--GROUP BY date
ORDER BY 1

--Total population who got vaccinated

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations)  OVER (Partition BY dea.location order by dea.date) as rollingCountofVac
FROM ProjectPortfolio..COVIDDEATHS dea
JOIN ProjectPortfolio..COVIDVACCINATIONS vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null --and dea.location like '%Afgan%'
ORDER BY 1,2,3


--USE CTE

WITH PerPopVac (Continent, Location, Date, Population,NewVacc, RollingCountOfVac) as (
	SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations)  OVER (Partition BY dea.location order by dea.date) as rollingCountofVac
	FROM ProjectPortfolio..COVIDDEATHS dea
	JOIN ProjectPortfolio..COVIDVACCINATIONS vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null --and dea.location like '%Afgan%'
	--ORDER BY 1,2,3
)
SELECT *, (RollingCountOfVac/Population)*100 as percentageOfpeopleVacc
FROM PerPopVac


--Temp Table


DROP Table if exists #PerPopVaccinated
CREATE Table #PerPopVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date nvarchar(255),
	Population float,
	NewVacc numeric,
	RollingCountOfVac numeric
)

Insert into #PerPopVaccinated
	SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(vac.new_vaccinations)  OVER (Partition BY dea.location order by dea.date) as rollingCountofVac
	FROM ProjectPortfolio..COVIDDEATHS dea
	JOIN ProjectPortfolio..COVIDVACCINATIONS vac
	ON dea.location = vac.location
	and dea.date = vac.date
	WHERE dea.continent is not null

SELECT MAX(RollingCountOfVac) as Totalvac,Location
FROM #PerPopVaccinated
GROUP BY Location
--SELECT *, (RollingCountOfVac/Population)*100 as percentageOfpeopleVacc
--FROM #PerPopVaccinated


--VIEWS

CREATE View PercentageOfPopulationVacc as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(vac.new_vaccinations)  OVER (Partition BY dea.location order by dea.date) as rollingCountofVac
FROM ProjectPortfolio..COVIDDEATHS dea
JOIN ProjectPortfolio..COVIDVACCINATIONS vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
