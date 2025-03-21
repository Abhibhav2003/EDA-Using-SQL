
-- EXPLORATORY DATA ANALYSIS USING SQL :- 

-------------------------------------------------------------------------
SELECT *
FROM COVIDDEATHS where continent is not null
ORDER BY 3,4;

SELECT *
FROM COVIDVACC
ORDER BY 3,4;

-- DATA THAT WE ARE GONNA USE:
SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES,TOTAL_DEATHS,POPULATION
FROM COVIDDEATHS
where CONTINENT IS NOT NULL
ORDER BY 1,2;

---------------------------------------------------------------------------
-- CHANGING OF DATA TYPES:
ALTER TABLE COVIDDEATHS
ALTER COLUMN total_deaths float; --CHANGED THE DEFAULT DATA TYPE FROM (NVARCHAR) TO (FLOAT)

ALTER TABLE COVIDDEATHS
ALTER COLUMN new_deaths float; --CHANGED THE DEFAULT DATA TYPE FROM (NVARCHAR) TO (FLOAT)

-- ALTERNATE METHODS :-

-- METHOD-1
SELECT CAST(TOTAL_DEATHS AS INT) 
FROM COVIDDEATHS; 

-- METHOD-2
SELECT CONVERT(INT,TOTAL_DEATHS)
FROM COVIDDEATHS;
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- TOTAL CASES VS TOTAL DEATHS :

-- CTE(COMMON TABLE EXPRESSION)
WITH CTE_COVID_DEATHS AS(
SELECT LOCATION, SUM(total_cases) AS TOTAL_CASES_, 
                 SUM(TOTAL_DEATHS) AS TOTAL_DEATHS_,
                 (SUM(TOTAL_DEATHS)/ SUM(TOTAL_CASES) *100) AS DEATH_PERCENTAGE
FROM 
COVIDDEATHS 
where continent is not null
GROUP BY 
LOCATION

)
SELECT LOCATION , DEATH_PERCENTAGE
FROM CTE_COVID_DEATHS
WHERE DEATH_PERCENTAGE = (SELECT MAX(DEATH_PERCENTAGE) FROM CTE_COVID_DEATHS);
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- DOING ANALYSIS OF DATA OF INDIA
SELECT LOCATION, DATE, TOTAL_CASES,TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM CovidDeaths
WHERE continent is not null and TOTAL_DEATHS IS NOT NULL AND LOCATION = 'India'


SELECT LOCATION, DATE, POPULATION, TOTAL_CASES, (TOTAL_CASES/POPULATION)*100 AS PERCENTAGE_OF_POPULATION
FROM CovidDeaths
WHERE continent is not null and TOTAL_DEATHS IS NOT NULL AND LOCATION = 'India'
order by 4 desc;

SELECT MAX(TOTAL_CASES) FROM COVIDDEATHS WHERE LOCATION = 'India';

-- POPULATION : 1.38 BILLION
-- MAXIMUM OF TOTAL_CASES = 19164969 = 19.16 MILLION;
------------------------------------------------------------------------------

SELECT LOCATION , POPULATION, MAX(TOTAL_CASES) AS HIGHEST_INFECTION_COUNT, 
MAX((TOTAL_CASES/POPULATION))*100 AS PERCENT_POPULATION
FROM COVIDDEATHS
where continent is not null
GROUP BY LOCATION,POPULATION
ORDER BY HIGHEST_INFECTION_COUNT DESC;
-------------------------------------------------------------------------------
-- SHOWING TOTAL_DEATH COUNT OF CONTINENTS:
SELECT LOCATION, MAX(TOTAL_DEATHS) AS TOTAL_DEATH_COUNT
FROM COVIDDEATHS
WHERE CONTINENT IS NULL
GROUP BY LOCATION
ORDER BY TOTAL_DEATH_COUNT DESC;
-------------------------------------------------------------------------------
--SHOWING CONTINENT WITH THE HIGHEST DEATH COUNT PER POPULATION:
SELECT LOCATION , MAX(TOTAL_DEATHS/POPULATION)* 100 AS DEATH_COUNT_PER_POPU
FROM COVIDDEATHS
WHERE continent IS NULL AND LOCATION NOT IN ('World','International')
GROUP BY LOCATION;
-------------------------------------------------------------------------------
-- PER DAY CASES AND DEATHS :
SELECT LOCATION, DATE, SUM(NEW_CASES) AS TOTAL_CASES, SUM(NEW_DEATHS) AS TOTAL_DEATHS  
FROM COVIDDEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY LOCATION, DATE
ORDER BY 1,2;
-------------------------------------------------------------------------------
-- DATE WHEN THE FIRST DEATH OCCURED AT THE SPECIFIED LOCATION:
SELECT TOP (1) LOCATION, DATE, SUM(NEW_CASES) AS TOTAL_CASES, SUM(NEW_DEATHS) AS TOTAL_DEATHS  
FROM COVIDDEATHS
WHERE CONTINENT IS NOT NULL AND LOCATION = 'Afghanistan'
GROUP BY LOCATION, DATE
HAVING SUM(NEW_DEATHS) != 0
ORDER BY 2;
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- JOINING THE CovidDeaths TABLE WITH CovidVacc TABLE :

-- TOTAL POPULATION VS VACCINATIONS :- 
SELECT CD.CONTINENT, CD.LOCATION, CD.DATE,CD.POPULATION,(CAST(CV.NEW_VACCINATIONS AS INT)/CD.POPULATION)*100 
AS NEW_VACC
FROM COVIDDEATHS AS CD JOIN CovidVacc AS CV
ON CD.date = CV.date
AND CD.LOCATION = CV.LOCATION
WHERE CD.CONTINENT IS NOT NULL
ORDER BY 1,5 DESC;

--------------------------------------------------------------------------------
-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS:
CREATE VIEW PERCENT_POPULATION AS
SELECT CD.CONTINENT, CD.LOCATION, CD.DATE, CD.POPULATION, CV.NEW_VACCINATIONS
, SUM(CONVERT(INT,CV.NEW_VACCINATIONS)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION,
CD.DATE) AS ROLLING_PEOPLE_VACCINATED
FROM COVIDDEATHS CD JOIN
CovidVacc CV ON CD.location = CV.LOCATION
AND
CD.DATE = CV.DATE
WHERE CD.CONTINENT IS NOT NULL;
---------------------------------------------------------------------------------
-- CREATION OF TEMP TABLE FOR PERFORMING FURTHER OPERATIONS ON A RESULTANT TABLE :-
CREATE TABLE #PERCENT_POPULATION 
(
 CONTINENT VARCHAR(50),
 LOCATION VARCHAR(50),
 DATE DATETIME,
 POPULATION INT,
 NEW_VACCINATIONS INT,
 RollingPeopleVaccinated INT
)
INSERT INTO #PERCENT_POPULATION
SELECT CD.CONTINENT, CD.LOCATION, CD.DATE, CD.POPULATION, CV.NEW_VACCINATIONS
, SUM(CONVERT(INT,CV.NEW_VACCINATIONS)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION,
CD.DATE) AS ROLLING_PEOPLE_VACCINATED
FROM COVIDDEATHS CD JOIN
CovidVacc CV ON CD.location = CV.LOCATION
AND
CD.DATE = CV.DATE
WHERE CD.CONTINENT IS NOT NULL
ORDER BY 2,3;

SELECT* FROM #PERCENT_POPULATION
-------------------------------------------------------------------------------------







