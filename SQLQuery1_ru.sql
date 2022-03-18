-- Выведем данные, которые планируем использовать

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Ïîñìîòðèì íà Total Cases vs Total Deaths
-- Ïîëó÷èì âåðîÿòíîñòü ñìåðòè, åñëè âû íàõîäèòåñü â ÑØÀ
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2


-- Ïîñìîòðèì íà Total Cases vs Population
-- Íàéäåì ïðîöåíò íàñåëåíèÿ, êîòîðûé çàáîëåë Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2


-- Âûâåäåì ñòðàíû ñ ñàìûì âûñîêèì ïîêàçàòåëåì çàáîëåâàåìîñòè (Highest Infection Rate) â ñðàâíåíèè ñ íàñåëåíèåì (Population)
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

-- Âûâåäåì ñòðàíû ñ ñàìûì áîëèøèì êîëè÷åñòâîì ñìåðòåé
Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- Âûâåäåì êîëè÷åñòâî ñìåðòåé ïî êîíòèíåíòàì
Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Ìèðîâûå ïîêàçàòåëè
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2


-- Ïîñìîòðèì íà Total Population vs Vaccinations

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

