--CovidDeaths' table
SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;


--CovidVaccinations table
SELECT *
FROM PortfolioProject..CovidVaccination
ORDER BY location, date;


--Main Colums of CovidDeaths' table
SELECT continent, location, date, population, new_cases, total_cases, new_deaths, total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;


--Main Colums of CovidVaccinations table
SELECT location, date, new_vaccinations, total_vaccinations, new_tests, total_tests
FROM PortfolioProject..CovidVaccination
ORDER BY location, date;


--Total cases for each country
WITH Total_deaths_for_each_country (location, total_cases)
AS
(
SELECT location, SUM(new_cases) OVER(PARTITION BY location ORDER BY location) AS total_cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
)

SELECT DISTINCT location,  total_cases
FROM Total_deaths_for_each_country
ORDER BY location;


--Total Deaths for each country
WITH Total_deaths_for_each_country (location, total_deaths)
AS
(
SELECT location, SUM(new_deaths) OVER(PARTITION BY location ORDER BY location) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
)

SELECT DISTINCT location,  total_deaths
FROM Total_deaths_for_each_country
ORDER BY location;


--Total Deaths For Each continent
WITH Total_deaths_for_each_country (location, total_cases)
AS
(
SELECT location
,SUM(new_cases) OVER(PARTITION BY location ORDER BY location) AS total_cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location IN ('asia', 'africa', 'europe', 'south america', 'north america', 'oceania') 
)
SELECT DISTINCT location, total_cases
FROM Total_deaths_for_each_country
ORDER BY location;


--Total Deaths For Each continent
WITH Total_deaths_for_each_country (location, total_deaths)
AS
(
SELECT location
,SUM(new_deaths) OVER(PARTITION BY location ORDER BY location) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND location IN ('asia', 'africa', 'europe', 'south america', 'north america', 'oceania') 
)
SELECT DISTINCT location, total_deaths
FROM Total_deaths_for_each_country
ORDER BY location;


--World's Total cases
SELECT location, SUM(new_cases) AS total_cases
FROM PortfolioProject..CovidDeaths
WHERE location = 'world' 
GROUP BY location;


--World's Total Deaths
SELECT location, SUM(new_deaths) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE location = 'world' 
GROUP BY location;


--Inffection Parcentage of the population for each country
WITH InffectionParcentage (location, population, total_cases)
AS
(
SELECT DISTINCT location, population
,SUM(new_cases) OVER (PARTITION BY location ORDER BY location) AS total_cases
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
)
SELECT location, population, total_cases, ROUND(((total_cases/population)* 100), 2) AS Inffection_rat
FROM InffectionParcentage
WHERE total_cases != 0
ORDER BY location;


--Death Parcentage of the population
WITH DeathOfPopulation (location, population, total_death)
AS
(
SELECT DISTINCT location, population
,SUM(new_deaths) OVER (PARTITION BY location ORDER BY location) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
)
SELECT location, population, total_death
,ROUND(((total_death/population)*100), 2) AS death_percentage
FROM DeathOfPopulation
ORDER BY location;


--Death percentage of total cases for each country
WITH deathrat (location, total_cases, total_deaths)
AS
(
SELECT DISTINCT location
,SUM(new_cases) OVER (PARTITION BY location ORDER BY location) AS total_cases
,SUM(new_deaths) OVER (PARTITION BY location ORDER BY location) AS total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
)
SELECT location, total_cases, total_deaths, ROUND(((total_deaths/total_cases)* 100), 2) AS death_rat
FROM deathrat
WHERE total_cases != 0
ORDER BY location;


--Latest records of new cases & deaths: 31/05/2023
SELECT Location, date, population, New_cases, New_deaths
FROM PortfolioProject..CovidDeaths
WHERE date = '2023-05-31' AND  continent IS NOT NULL
ORDER BY location;


--The Peak of covid in Jordan
DROP TABLE IF EXISTS #OneCountryTable
CREATE TABLE #OneCountryTable(
location NVARCHAR(255),
date NVARCHAR(255),
new_cases FLOAT
)
INSERT INTO #OneCountryTable
SELECT location, date, new_cases FROM PortfolioProject..CovidDeaths
WHERE location = 'Jordan'
SELECT location, date, new_cases
FROM PortfolioProject..CovidDeaths
WHERE new_cases = (SELECT MAX(new_cases) FROM #OneCountryTable);


--vaccinated peapole of each country
SELECT location, SUM(new_vaccinations) AS total_vaccinations
FROM PortfolioProject..CovidVaccination
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY location;


--The Percentage of vaccinated people for each country
DROP TABLE IF EXISTS #VacPop
CREATE TABLE #VacPop(
location NVARCHAR(255)
, population FLOAT
, total_vaccinated FLOAT
)
INSERT INTO #VacPop
SELECT DISTINCT location, population, SUM(new_vaccinations)
FROM PortfolioProject..CovidVaccination
WHERE continent IS NOT NULL
GROUP BY location, population
SELECT location, population, total_vaccinated, ROUND(((total_vaccinated/population)*100), 2) AS PerOfVac
FROM #VacPop
ORDER BY PerOfVac DESC;


