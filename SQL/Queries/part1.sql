-- Data Overview
--select * from coviddeath order by 9,6 DESC
--select * from covidvaccination order by 5 DESC

--select location, date, total_cases, new_cases, total_deaths, population 
--from coviddeath 
--order by 1,2

-- Total cases vs Total Deaths
--select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
--from coviddeath
--where location='Nepal'
--order by 1,2

-- Total cases vs Population
--select location, date, total_cases, new_cases, total_deaths, (total_cases/population)*100 as Infected_percentage
--from coviddeath
--where location='Nepal'
--order by 1,2

-- Countries with highest Infection Rate.
select location, population,MAX(total_cases) as Total_infected, MAX((total_cases/population)*100) as Infected_percentage
from coviddeath
GROUP by population,location
order by 4 desc
-- Cyprus has the highest percentage of people infected with covid with Infection rate of 72%

-- Death counts of each countries
select location, max(cast(total_deaths as int)) as Total_deaths
from coviddeath
where continent is not null 
group by location
order by Total_deaths desc
-- United State has the highest death count with 1117497 deaths followed by Brazil and India.

-- Death counts of Each continent
select continent, max(cast(total_deaths as int)) as Total_deaths
from coviddeath
where continent is not null 
group by continent
order by Total_deaths desc
-- North America has the highest deaths.

-- Global numbers
-- For each day.
select date,sum(new_cases) as Cases,sum(cast(new_deaths as int)) as Deaths, (sum(cast(new_deaths as int))/sum(new_cases ))*100 as Death_percentage
from coviddeath
where continent is not null
group by date 
order by date
-- Total
select sum(new_cases) as Cases,sum(cast(new_deaths as int)) as Deaths, (sum(cast(new_deaths as int))/sum(new_cases ))*100 as Death_percentage
from coviddeath
where continent is not null
order by 1,2

-- covidvaccination table
select * from covidvaccination

-- Total population vs vaccination
select cd.continent,cd.location,cd.date,cv.new_vaccinations,sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cummulative_number
from coviddeath cd
join covidvaccination cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
order by 2,3

-- Using CTE
with pvc(Continent, location, date, Population,New_vaccinations,cummulative_number)
as 
(
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cummulative_number
from coviddeath cd
join covidvaccination cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null
)
select *,(cummulative_number/population)*100 from pvc 

-- Temp table
drop table if exists #percentpvc
create table #percentpvc
(
Continent nvarchar(55),
location nvarchar(55),
date datetime,
population numeric,
new_vaccinations numeric,
cummulative_no numeric
)
insert into #percentpvc
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cummulative_number
from coviddeath cd
join covidvaccination cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null


select *,(cummulative_no/population)*100 from #percentpvc

-- Creating view for later visualization
create view ppv as 
select cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as cummulative_number
from coviddeath cd
join covidvaccination cv on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null

create view infrate as 
select location, population,MAX(total_cases) as Total_infected, MAX((total_cases/population)*100) as Infected_percentage
from coviddeath
GROUP by population,location
