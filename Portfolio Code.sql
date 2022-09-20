select * from Portfolio.dbo.Data1;

select * from Portfolio.dbo.Data2;

-- number of rows into our dataset
select count(*) from Portfolio.dbo.Data1;
select count(*) from Portfolio.dbo.Data2;

-- dataset for Jharkhand and Bihar
select * from Portfolio.dbo.Data1 where state in ('Jharkhand','Bihar');

-- total population of India
select SUM(Population) as Population from Portfolio.dbo.Data2;

--average growth of India
select AVG(Growth)*100 as Average_Growth from Portfolio.dbo.Data1;

-- average growth percentage grouped by State
select State,avg(Growth)*100 as Average from Portfolio..Data1 group by State;

-- average sex ratio
select State,round(avg(Sex_Ratio),0) as Average from Portfolio..Data1 group by State order by Average desc;

--avergae literacy rate
select State, round(avg(Literacy),0) as Average_literacy from Portfolio..Data1 
group by State having round(avg(Literacy),0)>90 order by Average_literacy asc;

-- top 3 states showing highest growth ratio
select top 2 State,avg(Growth)*100 as Average from Portfolio..Data1 group by State order by Average desc;

-- bottom 3 states showing lowest sex ratio
select top 3 State,round(avg(Sex_Ratio),0) as Average from Portfolio..Data1 group by State order by Average asc;

-- top and bottom 3 states in literacy rate

-- creating a temporary table and inserting values onto it
drop table if exists #topstates;
create table #topstates(
state nvarchar(255),
value float
);

insert into #topstates
select State, round(avg(Literacy),0) as Average_literacy from Portfolio..Data1 
group by State order by Average_literacy desc;

select top 3 * from #topstates order by #topstates.value desc;
	
	
drop table if exists #bottomstates;
create table #bottomstates(
state nvarchar(255),
bottomvalue float
);

insert into #bottomstates
select State, round(avg(Literacy),0) as Average_literacy from Portfolio..Data1 
group by State order by Average_literacy asc;

select top 3 * from #bottomstates order by #bottomstates.bottomvalue asc;


--union operator(used to merge output of two queries)
--conditions for union:- the no. of columns of both the queries and datatype of both commands have to be exactly the same 

select * from(
select top 3 * from #topstates order by #topstates.value desc)a

union

select * from(
select top 3 * from #bottomstates order by #bottomstates.bottomvalue asc)b;

-- states starting with letter a
select distinct(State) from Portfolio..Data1 where State like 'A%';

-- states starting with letter a or b
select distinct(State) from Portfolio..Data1 where State like 'A%' or state like 'B%';

--states starting with letter a or ending with letter i 
select distinct(State) from Portfolio..Data1 where State like 'A%' or state like '%I';

--joining both the tables
select a.district, a.state, a.sex_ratio, b.population from Portfolio..Data1 a 
inner join
Portfolio..Data2 b on a.District=b.District

-- calculating no. of literate and no. of illiterate people from districts

-- Formula for calculating this is:-
-- Total Literate People/Population = Literacy Ratio
-- Total Literate People = Literacy Ratio * Population
-- Total Illiterate People = (1-Literacy Ratio) * Population

select d.district,d.state,round(d.literacy_ratio*d.population,0) as Literate_People, round((1-d.literacy_ratio) * d.population,0) as Illiterate_People from
(select a.district, a.state, a.Literacy/100 as Literacy_Ratio, b.population from Portfolio..Data1 a 
inner join
Portfolio..Data2 b on a.District=b.District) d


--Grouping the above literate and illiterate by state rather than district

select c.state, sum(c.Literate_People) as Total_Literate_People, sum(c.Illiterate_People) as Total_Illiterate_People from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) as Literate_People, round((1-d.literacy_ratio) * d.population,0) as Illiterate_People from
(select a.district, a.state, a.Literacy/100 as Literacy_Ratio, b.population from Portfolio..Data1 a 
inner join
Portfolio..Data2 b on a.District=b.District) d) c
group by c.State

-- population in previous census is calculated from growth rate and population and grouped by state
--previous census+growth*previous_census = population
--previous census = population/(1+growth)

select c.state, sum(c.previous_census_population) as Previous_census_population, sum(c.current_census_population) as Current_census_population from
(select d.district, d.state, round(d.population/(1+d.growth),0) as previous_census_population, d.population as current_census_population from 
(select a.district, a.state, a.Growth, b.population from Portfolio..Data1 a 
inner join
Portfolio..Data2 b on a.District=b.District)d) c
group by c.state


--total population in india of previous and current census calculated from above code
select sum(g.previous_census_population) as Sum_of_previous_census_population, sum(g.current_census_population) as Sum_of_current_census_population from
(select c.state, sum(c.previous_census_population) as Previous_census_population, sum(c.current_census_population) as Current_census_population from
(select d.district, d.state, round(d.population/(1+d.growth),0) as previous_census_population, d.population as current_census_population from 
(select a.district, a.state, a.Growth, b.population from Portfolio..Data1 a 
inner join
Portfolio..Data2 b on a.District=b.District)d) c
group by c.state) g

-- window functions

-- Q. output top 3 districts from each state with highest literacy rate

select a.* from
(select district,state,literacy, rank() over (partition by state order by literacy desc) rnk from Portfolio..Data1) a
where a.rnk in (1,2,3) order by state

