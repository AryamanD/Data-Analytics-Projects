select * from CovidDeaths

select * from CovidVaccinations

select Location, date, total_cases, new_cases, total_deaths, population 
from coviddeaths
order by location, date

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in India

select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as Death_Percentage
from coviddeaths
where location = 'India'
order by location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

select Location, date, total_cases, population, (cast(total_cases as float)/population)*100 as Infection_Rate
from coviddeaths
where location = 'India'
order by location, date

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT *
FROM (
    SELECT 
        location, 
        MAX(total_cases) AS total_cases, 
        population, 
        (CAST(MAX(total_cases) AS float) / population) * 100 AS Infection_Rate
    FROM coviddeaths
    GROUP BY location, population
) AS sub
WHERE Infection_Rate IS NOT NULL
ORDER BY Infection_Rate desc;


-- Showing Countries with the Highest Death Count per Population

SELECT 
    location, max(total_deaths) as TotalDeathCount     
FROM coviddeaths
where continent is not null
GROUP BY location
order by TotalDeathCount desc

-- Showing Continents with the Highest Death Count per Population

SELECT 
    continent, max(total_deaths) as TotalDeathCount     
FROM coviddeaths
where continent is not null
GROUP BY continent
order by TotalDeathCount desc

-- Global Numbers

select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases) * 100 as Death_Percentage
from coviddeaths
where continent is not null
group by date
order by 1, 2

-- Looking at Total Population vs Vaccinations

select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) over (partition by d.location order by d.location,d.date) as cummulative_vaccinations
from coviddeaths d
join covidvaccinations v on d.location = v.location and d.date = v.date
where d.continent is not null and v.new_vaccinations is not null
order by continent, location

WITH PopvsVac (continent, location, date, population, new_vaccinations, cumulative_vaccinations) AS
(
    SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations, 
        SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS cumulative_vaccinations
    FROM coviddeaths d
    JOIN covidvaccinations v 
        ON d.location = v.location AND d.date = v.date
    WHERE 
        d.continent IS NOT NULL 
        AND v.new_vaccinations IS NOT NULL
)
select *, (cumulative_vaccinations/population)*100 as Vaccination_Rate from PopvsVac

-- Creating a view to store data 

create view PercentPopulationVaccinated as
    SELECT 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations, 
        SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS cumulative_vaccinations
    FROM coviddeaths d
    JOIN covidvaccinations v 
        ON d.location = v.location AND d.date = v.date
    WHERE 
        d.continent IS NOT NULL 
        AND v.new_vaccinations IS NOT NULL
