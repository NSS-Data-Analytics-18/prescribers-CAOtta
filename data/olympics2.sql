
--2a.How many rows are there in the athletes table? How many distinct athlete ids?
SELECT COUNT(*) 
FROM athletes;

SELECT COUNT(DISTINCT id) AS no_athletes
FROM athletes;

--2b.What years are represented in the summer games table?
--The winter games table? The country stats table?

SELECT DISTINCT EXTRACT(YEAR FROM year) 
FROM summer_games;

SELECT DISTINCT EXTRACT(YEAR FROM year) 
FROM winter_games;

SELECT DISTINCT LEFT (year, 4) AS year
FROM country_stats
ORDER BY year DESC;


--2c.How many distinct countries are represented in the countries table? 
--The country stats table?
SELECT COUNT(DISTINCT countries) AS countries
FROM countries;

SELECT COUNT(DISTINCT country_id) AS countries
FROM country_stats;

--2d.How many distinct events are represented in the  winter games table? The summer games table?
SELECT COUNT(DISTINCT event) AS wg_events
FROM winter_games;

SELECT COUNT(DISTINCT event) AS sg_events
FROM summer_games;

--3.Count the number of athletes who participated in the summer games for each country.
--Your output should have country name in one column and number of athletes in another.
--******Did any country in the countries table have no athletes? **********

SELECT country,COUNT (DISTINCT athlete_id) AS athlete_count
FROM summer_games INNER JOIN countries ON summer_games.country_id = countries.id
GROUP BY country;

--4.Write a query that gives country names along with each country’s total number of bronze
--medals from the winter games, with countries who got more bronze medals at the top. 
--Do some searching to see how to put the nulls down at the bottom of the output
--(not eliminate the nulls). Now adjust your query to only return the country that earned 
--the most bronze medals.

SELECT country, SUM(bronze) AS total_bronze
FROM countries INNER JOIN winter_games ON countries.id = winter_games.country_id
GROUP BY country
ORDER BY total_broNze DESC NULLS LAST
LIMIT 1;

--5.What is the average population across all years in the country stats table for each
--country that participated in the winter games? You will need to do 2 joins for this
--question. First, write a query that gives you country names and the average population 
--for each. Then think about adding a second join to return only the countries that 
--participated in the winter games.

SELECT country, AVG(pop_in_millions::numeric) AS avg_pop
FROM countries INNER JOIN country_stats ON countries.id = country_stats.country_id
 INNER JOIN winter_games ON winter_games.country_id = countries.id
GROUP BY country;

--6.Find country names where the population decreased from 2000 to 2006.
SELECT * 
FROM countries INNER JOIN country_stats ON countries.id = country_stats.country_id;


