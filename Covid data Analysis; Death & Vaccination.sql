USE PortfolioProject

-- SELECTING RELEVANT DATA

SELECT LOCATION, DATE, TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, POPULATION 
FROM Covid_deaths
ORDER BY 1,2

-- TOTAL_CASES VS TOTAL_DEATHS IN NIGERIA 
-- DEATH_PERCENTAGE of COVID in Nigeria

SELECT LOCATION, DATE, TOTAL_CASES, TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATH_PERCENTAGE
FROM Covid_deaths
WHERE LOCATION LIKE '%NIGERIA%'
ORDER BY 1,2

-- TOTAL_CASES VS POPULATION IN NIGERIA
-- % of popluation that haS covid in Nigeria

SELECT LOCATION, DATE, POPULATION, TOTAL_CASES, (TOTAL_CASES/POPULATION)*100 AS '%_POPULATION_INFECTED'
FROM Covid_deaths
WHERE LOCATION LIKE '%NIGERIA%'
ORDER BY 1,2

-- COUNTRIES WITH HIGHEST INFECTION RATE PER POPULATION

SELECT LOCATION, POPULATION, MAX(TOTAL_CASES) AS HighestInfectionCount, MAX(TOTAL_CASES/POPULATION)*100 AS '%_POPULATION_INFECTED'
FROM Covid_deaths
-- WHERE LOCATION LIKE '%NIGERIA%'
GROUP BY LOCATION,POPULATION
ORDER BY 4 DESC

-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT LOCATION, MAX(CAST(TOTAL_deaths AS INT)) AS TotalDeathCount
FROM Covid_deaths
-- WHERE LOCATION LIKE '%NIGERIA%'
WHERE CONTINENT IS NOT NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC

--  COUNTRIES WITH HIGHEST DEATH COUNT BY CONTINENT
-- ShoWing continent With higheSt death count

SELECT LOCATION, MAX(CAST(TOTAL_deaths AS INT)) AS TotalDeathCount
FROM Covid_deaths
-- WHERE LOCATION LIKE '%STATE%'
WHERE CONTINENT IS NULL
GROUP BY LOCATION
ORDER BY TotalDeathCount DESC

SELECT CONTINENT, MAX(CAST(TOTAL_deaths AS INT)) AS TotalDeathCount
FROM Covid_deaths
-- WHERE LOCATION LIKE '%STATE%'
WHERE CONTINENT IS NOT NULL
GROUP BY CONTINENT
ORDER BY TotalDeathCount DESC


-- GLOBAL CASES PER DAY

SELECT DATE, SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_DEATHs AS INT)) AS TOTAL_DEATHS, SUM(CAST(new_DEATHs AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Covid_deaths
-- WHERE LOCATION LIKE '%STATE%'
WHERE CONTINENT IS NOT NULL
GROUP BY DATE
ORDER BY 1,2

-- GLOBAL CASES AROUND THE WORLD

SELECT SUM(new_cases) AS TOTAL_CASES, SUM(CAST(new_DEATHs AS INT)) AS TOTAL_DEATHS, SUM(CAST(new_DEATHs AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Covid_deaths
-- WHERE LOCATION LIKE '%NIGERIA%'
WHERE CONTINENT IS NOT NULL
ORDER BY 1,2

-- TOTAL POPULATION VS VACCINATION

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations  
FROM Covid_deaths CD
JOIN Covid_Vaccinations CV
ON CD.LOCATION = CV.LOCATION
AND CD.DATE = CV.DATE
WHERE CD.CONTINENT IS NOT NULL
ORDER BY 2,3


SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,  
SUM(CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE)
AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Covid_deaths CD
JOIN Covid_Vaccinations CV
ON CD.LOCATION = CV.LOCATION
AND CD.DATE = CV.DATE
WHERE CD.CONTINENT IS NOT NULL
ORDER BY 2,3

-- USING CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,  
SUM(CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE)
AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Covid_deaths CD
JOIN Covid_Vaccinations CV
ON CD.LOCATION = CV.LOCATION
AND CD.DATE = CV.DATE
WHERE CD.CONTINENT IS NOT NULL
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF ExISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,  
SUM(CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE)
AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Covid_deaths CD
JOIN Covid_Vaccinations CV
ON CD.LOCATION = CV.LOCATION
AND CD.DATE = CV.DATE
-- WHERE CD.CONTINENT IS NOT NULL
-- ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 
FROM #PercentPopulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS 
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,  
SUM(CONVERT(INT, CV.new_vaccinations)) OVER (PARTITION BY CD.LOCATION ORDER BY CD.LOCATION, CD.DATE)
AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
FROM Covid_deaths CD
JOIN Covid_Vaccinations CV
ON CD.LOCATION = CV.LOCATION
AND CD.DATE = CV.DATE
WHERE CD.CONTINENT IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated






