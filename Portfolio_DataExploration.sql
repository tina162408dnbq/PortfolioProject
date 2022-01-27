-- Data Exploration

Select *
From PorfolioProject.Deaths
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject.Deaths
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject.Deaths
Where location like '%states%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PorfolioProject.Deaths
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PorfolioProject.Deaths
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as signed)) as TotalDeathCount
From PorfolioProject.Deaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as signed)) as TotalDeathCount
From PorfolioProject.Deaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From PorfolioProject.Deaths
where continent is not null 
Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

alter table CovidVaccinations 
modify column new_vaccinations int;

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) as RollingPeopleVaccinated, 
-- (RollingPeopleVaccinated/population)*100
From PorfolioProject.Deaths dea
Join PorfolioProject.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.vac_date
where dea.continent is not null 
order by 2,3;

