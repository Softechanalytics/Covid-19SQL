select *
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 3,4;

select *
from ProjectPortfolio..CovidVaccinations
where continent is not null
order by 3,4;

use ProjectPortfolio;

--Select data that we are going to be using:
Select 
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
From CovidDeaths
where continent is not null
order by 1,2;


-- Looking at Total Cases vs Total Death
-- Show the likey of dying if you contact covid in your country

Select 
	Location, 
	Date, 
	total_cases, 
	total_deaths, 
	round((total_deaths/Total_cases) * 100,2) as DeathPercentage
From CovidDeaths
where continent is not null
order by 1,2;



-- looking at DeathPercentage for Canada
Select 
	Location, 
	Date, 
	total_cases, 
	total_deaths, 
	round((total_deaths/Total_cases) * 100,2) as DeathPercentage
From CovidDeaths
Where Location like '%Canada%' and continent is not null
order by 1,2;

-- looking at DeathPercentage for United States
-- Show the likey of dying if you contact covid in your country
Select 
	Location, 
	Date, 
	total_cases, 
	total_deaths, 
	round((cast (total_deaths as Int)/Total_cases) * 100,2) as DeathPercentage
From CovidDeaths
Where Location like '%States%' and continent is not null
order by 1,2;

-- looking at total cases vs population
-- Show what percentage of the population has got covid
Select 
	Location,
	date,
	total_cases,
	population, 
	Round((total_cases/population) * 100,2) as Percentage_of_Population_infected
From CovidDeaths
Where Location like '%States%' and continent is not null
order by 1,2;

-- Looking at countries with Highest Infection Rate compared to population

SELECT 
    Location,
    Population,
    MAX(total_cases) AS highestInfectionCount,
    round((MAX(total_cases) / Population) * 100,2) AS PercentPopulationInfected
FROM CovidDeaths
where continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per population
SELECT 
    Location,
    MAX(Cast(total_deaths as Int)) AS TotalDeathCount -- Note, Total_death field is a string variable hence we need to cast it to convert it to Numeric variable
FROM CovidDeaths
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc;

SELECT 
    Location,
    FORMAT(MAX(CAST(NULLIF(total_deaths, '') AS INT)), 'N0') AS TotalDeathCount
FROM CovidDeaths
where continent is not null
GROUP BY Location
ORDER BY MAX(CAST(NULLIF(total_deaths, '') AS INT)) DESC;


--Let's break thing down by continent
SELECT 
    continent,
    FORMAT(MAX(CAST(NULLIF(total_deaths, '') AS INT)), 'N0') AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY MAX(CAST(NULLIF(total_deaths, '') AS INT)) DESC;

-- Showing Continents with the highest death count per population
SELECT 
    continent,
    FORMAT(MAX(CAST(NULLIF(total_deaths, '') AS INT)), 'N0') AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY MAX(CAST(NULLIF(total_deaths, '') AS INT)) DESC;

-- Global Numbers
Select 
	Location,
	date,
	total_cases,
	population, 
	Round((total_cases/population) * 100,2) as Percentage_of_Population_infected
From CovidDeaths
Where continent is not null
order by 1,2;

-- Global Numbers
Select
	Date,
	sum(new_cases)Total_cases,
	sum(cast(new_deaths as int)) Total_Deaths,
	round(sum(cast(new_deaths as Int))/sum(new_cases)* 100,2) Death_Percentage
from CovidDeaths
where continent is not null
group by date
order by 1;


--Total Global figure
SELECT
    
    FORMAT(SUM(CAST(new_cases AS INT)), 'N0') AS Total_Cases,
    FORMAT(SUM(CAST(new_deaths AS INT)), 'N0') AS Total_Deaths,
    FORMAT(ROUND(SUM(CAST(new_deaths AS FLOAT)) / SUM(NULLIF(CAST(new_cases AS FLOAT),0)) * 100, 2), 'N2') AS Death_Percentage
FROM CovidDeaths
WHERE continent IS NOT NULL;


-- Joins
-- Looking at Total Population vs Vaccinations
Select 
	dea.continent, 
	dea.location, 
	cast(dea.date as date) Date, 
	dea.population,
	vac.new_vaccinations
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Looking at Total Population vs Vaccination
Select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	Coalesce(vac.new_vaccinations,0) New_Vacination,
	sum(coalesce(convert(int,vac.new_vaccinations),0)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated--Using running total
From coviddeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3;


-- using CTE
With PopvsVac (
				continent,
				Location,
				Date,
				population,
				New_vaccinations,
				RollingpeopleVaccinated)
AS
	(
		Select 
		dea.continent,
		dea.location,
		dea.date,
		dea.population,
		Coalesce(vac.new_vaccinations,0) New_Vacination,
		sum(coalesce(convert(int,vac.new_vaccinations),0)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated--Using running total
	From coviddeaths dea
	Join CovidVaccinations vac
		on dea.location = vac.location
		and dea.date = vac.date
	Where dea.continent is not null
	
	)
	
Select *,Round((RollingpeopleVaccinated/population)*100,2) as Percentage
From PopvsVac


-- Create Temp Table if it does not already exist
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NULL
BEGIN
    CREATE TABLE #PercentPopulationVaccinated
    (
        Continent NVARCHAR(255),
        Location NVARCHAR(255),
        Date DATETIME,
        Population NUMERIC(18,0),
        New_vaccinations NUMERIC(18,0),
        RollingPeopleVaccinated NUMERIC(18,0)
    );
END

-- Insert data only if the temp table is empty (to prevent duplicates)
IF NOT EXISTS (SELECT TOP 1 * FROM #PercentPopulationVaccinated)
BEGIN
    INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        COALESCE(vac.new_vaccinations, 0) AS New_Vaccinations,
        SUM(COALESCE(vac.new_vaccinations, 0)) OVER (
            PARTITION BY dea.location ORDER BY dea.date
        ) AS RollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL;
END

-- Select final result with vaccination percentage
SELECT 
    *,
    ROUND((RollingPeopleVaccinated / Population) * 100, 2) AS PercentageVaccinated
FROM #PercentPopulationVaccinated
ORDER BY Location, Date;


-- Create Temp Table if it does not already exist
Drop table if exists #PercentPopulationVaccinated
    CREATE TABLE #PercentPopulationVaccinated
    (
        Continent NVARCHAR(255),
        Location NVARCHAR(255),
        Date DATETIME,
        Population NUMERIC(18,0),
        New_vaccinations NUMERIC(18,0),
        RollingPeopleVaccinated NUMERIC(18,0)
    );


    INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        COALESCE(vac.new_vaccinations, 0) AS New_Vaccinations,
        SUM(COALESCE(vac.new_vaccinations, 0)) OVER (
            PARTITION BY dea.location ORDER BY dea.date
        ) AS RollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL;


-- Select final result with vaccination percentage
SELECT 
    *,
    ROUND((RollingPeopleVaccinated / Population) * 100, 2) AS PercentageVaccinated
FROM #PercentPopulationVaccinated
ORDER BY Location, Date;



-- Creating Views to store Data for later vizualizations

Create View PercentagePopulationVaccinated as 

SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        COALESCE(vac.new_vaccinations, 0) AS New_Vaccinations,
        SUM(COALESCE(vac.new_vaccinations, 0)) OVER (
            PARTITION BY dea.location ORDER BY dea.date
        ) AS RollingPeopleVaccinated
    FROM coviddeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
	--order by 2,3


/***** Scrip for SelectTopNRows command from SSMS ****/
-- Selecting from the views
Select Top (1000) 
		Continent,
		Date,
		Population,
		New_vaccinations,
		RollingPeopleVaccinated

	From PercentagePopulationVaccinated;