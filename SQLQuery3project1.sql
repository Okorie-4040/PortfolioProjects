/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[population]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
      ,[new_deaths_smoothed]
      ,[total_cases_per_million]
      ,[new_cases_per_million]
      ,[new_cases_smoothed_per_million]
      ,[total_deaths_per_million]
      ,[new_deaths_per_million]
      ,[new_deaths_smoothed_per_million]
      ,[reproduction_rate]
      ,[icu_patients]
      ,[icu_patients_per_million]
      ,[hosp_patients]
      ,[hosp_patients_per_million]
      ,[weekly_icu_admissions]
      ,[weekly_icu_admissions_per_million]
      ,[weekly_hosp_admissions]
      ,[weekly_hosp_admissions_per_million]
  FROM [My_Portfolio_Project].[dbo].[CovidDeathsCSV]

  select location, date, total_cases, new_cases, total_deaths, population
    from CovidDeathsCSV

	select  distinct substring (cast (date as varchar),1,4) as yr, population
	from CovidDeathsCSV
	where location like '%Nigeria%'

	select  distinct substring (cast (date as varchar),1,4) as yr, population
	from CovidDeathsCSV

-- LOOKING FOR TOTAL CASES VS TOTAL DEATH

 select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
    from CovidDeathsCSV
	where location like '%Nigeria%'


---LOOKING FOR TOTAL CASES VS POPULATION

 select location, date, population, total_cases, (total_cases/population)*100 AS Case_per_population
    from CovidDeathsCSV
	where location like '%Nigeria%'


	--- LOOKING FOR COUNTRY WITH HIGHEST INFECTION RATE OMPARED TO POPULATION

	select location, population, max(total_cases) as Max_cases, max(total_cases/population)*100 AS MAX_Case_per_population
    from CovidDeathsCSV
	Group by location, population
	order by MAX_Case_per_population desc


	--Country qith the highest death count per location

	select location,  max(total_deaths) as highest_death_count
    from CovidDeathsCSV
	where continent is not null
	Group by location
	order by highest_death_count desc
	

---GLOBAL NUMBERS 

select  date, sum(new_cases) as total_new_cases, sum(new_deaths)as total_new_deaths, sum(new_deaths) / sum(new_cases)*100 AS New_Death_percentage
    from CovidDeathsCSV
	where continent is not null
	group by date
	order by 1,2 


----LOOKING AT TOTAL POPULATION VS VACCINATION 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date
)as Rolling_count_of_people_vaccinated  
from CovidDeathsCSV dea
join CovidVaccinations23 vac
  on dea.location = vac.location  
  and dea.date = vac.date 
  where dea.continent is not null
  order by 2,3

 

  
  --USE CTE 

  With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_people_VAC)
  as 
  (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date
)as Rolling_people_VAC  
from CovidDeathsCSV dea
join CovidVaccinations23 vac
  on dea.location = vac.location  
  and dea.date = vac.date 
  where dea.continent is not null
  --order by 2,3
  )
  select *, (Rolling_people_VAC /population)*100
  from PopvsVac


  --creating view for visualization later 


  create view TOTAL_CASES_VS_POPULATION as 

 select location, date, population, total_cases, (total_cases/population)*100 AS Case_per_population
    from CovidDeathsCSV
	where location like '%Nigeria%'


  ---------TEMP TABLE 
  DROP TABLE IF EXISTS #PERCENT_POPULATION_VACCINATED 

  CREATE TABLE #PERCENT_POPULATION_VACCINATED
  ( continent nvarchar(50),
  location nvarchar(50),
  DATE DATE, 
  POPULATION FLOAT ,
  new_vaccinations  VARCHAR(MAX),
  Rolling_count_of_people_vaccinated  FLOAT
  )

  INSERT INTO #PERCENT_POPULATION_VACCINATED
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.date
)as Rolling_count_of_people_vaccinated  
from CovidDeathsCSV dea
join CovidVaccinations23 vac
  on dea.location = vac.location  
  and dea.date = vac.date 
  where dea.continent is not null
  order by 2,3

  select *, (Rolling_count_of_people_vaccinated / population)*100
  from #PERCENT_POPULATION_VACCINATED













  





