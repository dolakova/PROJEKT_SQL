#priprava dat
  
SELECT 
  country,
  date,
  confirmed
 FROM covid19_basic_differences cbd 
 order by date DESC
# date od 2020-01-22 - 2021-05-23

 CREATE VIEW v_Helena_help as
 	SELECT
  		country,
  		date,
  		confirmed,
  		WEEKDAY(date) AS help
 	from covid19_basic_differences cbd 
 
 #seasons 0-jaro,1-leto,2-podzim,3-zima (poznamka - script neni flexibilni pro vsechny roky, ale proste jsem ho nenasla :-(  
 #VYSLEDNA TABULKA PRO    1) Èasové promìnné + 2) population a median age 2018
 	
CREATE VIEW v_Helena_priprava1_new   as
   WITH t_Helena_helphelp as (
	SELECT 
    	*,
    	SUBSTRING(date,1,4) as year,
         case when help <=4 THEN 'week'
        	  when help >=5 THEN 'weekend'
       		  end as "week_vs_weekend"
     from t_Helena_help
         order by country
         ),
       t_Helena_obdobihelp as (   
   SELECT 
   		country,
   		date, 
  	 	 CASE WHEN date  >= '2020-03-21' then '0'
      		  WHEN date  >= '2021-03-21' then '0'
    	      WHEN date  >= '2020-06-21' then '1'
     	      WHEN date  >= '2021-06-21' then '1'
     	      WHEN date  >= '2020-09-23' then '2'
     	      WHEN date  >= '2021-09-23' then '2'
     	      WHEN date  >= '2020-12-21' then '3'
     	      WHEN date  >= '2021-12-21' then '3'
    	      WHEN date  >= '2020-01-01' then '3'
    	      WHEN date  >= '2021-01-01' then '3'
              END AS seasons
        from covid19_basic_differences cbd 
       ),
    v_Helena_priprava as (
     SELECT  
       th.country, th.date, th.confirmed, th.week_vs_weekend, th.year, toh.seasons
       From t_Helena_helphelp  as th
       LEFT JOIN t_Helena_obdobihelp as toh
          ON th.country = toh.country
          AND th.date = toh. date)
     SELECT  vhp.*, cbd.population_density, cbd.median_age_2018
      from v_Helena_priprava as vhp 
      LEFT JOIN countries as cbd 
         on vhp.country = cbd.country

         
   #______________________________________________________________________________________________
 #% podil nabozenstvi
     #na zaklade analyzy dat jsem vybrala rok 2010
CREATE VIEW v_Helena_4 as
 	SELECT c.country , c.population , r.religion , r.population as help_population
	FROM countries c 
	JOIN religions r
    	ON c.country = r.country
   		AND r.year = 2010   

  SELECT*, 
  Max(help_population)
     FROM v_Helena_4
     WHERE 1=1
group by country
     
# pomocna tabulka pro religion
CREATE VIEW v_Helena_religion_new1 as  
    SELECT 
		*,
		Round((help_population/population)*100) as 'religion_in_perc'
	FROM v_Helena_4 
     GROUP BY country, religion



#ocistena vysledna tabulka o data v country (jako zaklad brana tabulka covid19) - VYSLEDNA TABULKA PRO RELIGION
CREATE VIEW v_Helena_religion_update_new2 as
SELECT *,
        CASE WHEN country = 'Cape Verde' THEN 'Cabo Verde'
            WHEN country = 'Czech Republic' THEN 'Czechia'
            WHEN country = 'South Korea' THEN 'Korea, South'
            WHEN country = 'Russian Federation' THEN 'Russia'
            WHEN country = 'United States' THEN 'US'
            ELSE country end as country_updated
           FROM v_Helena_religion_new1
           
 CREATE VIEW v_Helena_zkouskareligion1 as
SELECT *,
max(religion_in_perc)as MAX_religion_in_perc
from v_Helena_religion_update_new2
group by country, religion

#vysledna tabulka pro religion
CREATE view v_Helena_religion_final as
SELECT c.country ,c.religion, vhyk.MAX_religion_in_perc
FROM countries c 
LEFT JOIN v_Helena_zkouskareligion1 as vhyk
on c.country = vhyk.country
 and  c.religion=vhyk.religion

 #__________________________________________________________________________
#rozdily mezi ocekavanou dobou doziti 1965 a 2015 - life_expectancy
 CREATE view v_Helena_life_expectancy as
 	SELECT country, vlec.
    	life_expectancy_2015 - life_expectancy_1965 AS life_expect_diff
	FROM v_life_expectancy_comparison vlec 


#vysledna tabulka pro life expectancy aktualizovana ohledne dat ve sloupci country - 1) Èasové promìnné + 2) population a median age 2018 + life diff
CREATE TABLE v_Helena_priprava2_new as
	WITH v_Helena_pripava4 as (
	SELECT *,
        CASE WHEN country = 'Cape Verde' THEN 'Cabo Verde'
            WHEN country = 'Czech Republic' THEN 'Czechia'
            WHEN country = 'South Korea' THEN 'Korea, South'
            WHEN country = 'Russian Federation' THEN 'Russia'
            WHEN country = 'United States' THEN 'US'
            ELSE country end as country_updated
           FROM t_Helena_life_expectancy)
      SELECT  vhpri.*, vhprip. life_expect_diff
          FROM v_Helena_priprava1_new as vhpri 
          LEFT JOIN v_Helena_pripava4 as vhprip 
            ON vhpri.country = vhprip.country
            
           

#priprava z tabulky economies - HDP/obyv, GINI, umrtnost
SELECT 
 max(date),
 Min(date)
 from covid19_basic_differences cbd 
 # roky 2020 a 2021 -- v tabulce economies je posledni rok 2020

 # vysledna tabulka s HDP/obyv, GINI, umrtnost -   VYSLEDNA TABULKA PRO 1) Èasové promìnné + 2) population a median age 2018 + life diff + HDP/obyv + GINI, umrtnost
CREATE view v_Helena_priprava3_new as
  WITH v_Helena_econ as (
  SELECT 
    country,
    year,
    REPLACE ('2,020','2,020','2020') as help_year,
    mortaliy_under5, 
    gini, 
    GDP / population as GDP_per_capita,
        CASE WHEN country = 'Bahamas, The' THEN 'Bahamas'
            WHEN country = 'Czech Republic' THEN 'Czechia'
            WHEN country = 'South Korea' THEN 'Korea, South'
            WHEN country = 'Russian Federation' THEN 'Russia'
            WHEN country = 'United States' THEN 'US'
            WHEN country = 'Brunei Darussalam' THEN 'Brunei'
            ELSE country end as country_updated
            From economies e 
            WHERE year = '2020')
      SELECT 
         vh.*, vhe.mortaliy_under5, vhe.gini, vhe.GDP_per_capita
        FROM v_Helena_priprava2_new as vh 
        LEFT JOIN v_Helena_econ as vhe 
          on vh.country = vhe.country
          #and vh.year=vhe.help_year
        
  SELECT * from   v_Helena_priprava3_new    
     #_______________________________________________________________________
 #priprava dat ohledne weather 
           
 SELECT
     DISTINCT city      
     from weather 
   # 34 mest Evropa + Rusko  

SELECT
  Max(`date`),
  MIN(`date`)
  from weather w 
  # 2016 - 2021-04-30

  #den - od 6:00 - 18:00
  
CREATE view v_Helena_pocasi_zaklad AS
SELECT 
  city,
  date,
  temp,
  rain,
  gust, 
  time,
  SUBSTRING(temp,1,2) as new_temp,
  SUBSTRING(date,1,4) as date_year,
  SUBSTRING(date,1,10) as date_days
    from weather w
    where city is not null 
    

Create view v_Helena_pocasi_maxgust as
 SELECT *,
 MAX(gust) as gust_MAX
 from v_Helena_pocasi_zaklad 
  group by city,date 


 CREATE VIEW v_Helena_pocjoin as
 SELECT 
  thpz.*, thm.gust_MAX
  FROM v_Helena_pocasi_zaklad as thpz 
  left Join v_Helena_pocasi_maxgust as thm
    ON thpz.city = thm.city
    and thpz.date = thm.date
    
   
 CREATE view v_Helena_pocasi_rain as
    SELECT 
   *,
 count( time) as rain_hours
  from v_Helena_pocasi_zaklad 
 where rain <> '0.0 mm'
  group by city,date_days 
    
  
  
 CREATE VIEW v_Helena_pocasi as
    SELECT 
  thep.*, tpr.rain_hours 
FROM v_Helena_pocjoin as thep
left Join v_Helena_pocasi_rain as tpr
    ON thep.city = tpr.city 
    and  thep.date = tpr.date 

#VYSLEDNA TABULKA PRO 1) Èasové promìnné + 2) population a median age 2018 + life diff + HDP/obyv + GINI, umrtnost + GUSt max + rain hours
 CREATE VIEW v_Helena_priprava4_new as
  WITH v_Helena_join as (
    SELECT 
      th.*, c.country 
      FROM v_Helena_pocasi as th 
      LEFT JOIN countries as c 
       ON th.city=c.capital_city)
    SELECT 
      vh.*, vhpo.gust_MAX, vhpo.rain_hours
      FROM v_Helena_priprava3_new as vh 
      LEFT JOIN v_Helena_join as vhpo 
       ON vh.country = vhpo.country
       and vh.year=vhpo.date_year
    
  #____________________________________________________________________________________
   

CREATE VIEW v_Helena_prumer1 as
  SELECT 
    city,
    date,
    time,
    SUBSTRING (temp,1,2) as help_temp
   FROM weather w 
   WHERE time <> '00:00' and time <> '03:00' and time <> '21:00'
  
  CREATE view v_Helena_avg1 as
  SELECT  
    *,
    AVG(help_temp) as AVG_day_temp,
    SUBSTRING(date,1,10) as help_year
    From v_Helena_prumer1
    WHERE city is not null
    group by city, date
 
    CREATE view v_Helena_avg2 as 
  SELECT 
    vhpo.*, c.country
    FROM v_Helena_avg1 as vhpo
    LEFT JOIN countries c 
      ON vhpo.city = c.capital_city 
      
  CREATE VIEW t_Helena_final1 as    
    SELECT 
    vhpr.*, AVG_day_temp
    FROM v_Helena_priprava4_new as vhpr
    LEFT JOIN v_Helena_avg2 as vjc 
      ON vhpr.country = vjc.country
       and vhpr.year = vjc.help_year
         
 
 SELECT * from t_Helena_final1
 
   
SELECT * from v_Helena_religion_final

#FINALNI TABULKA

Create Table t_Helena_Dolakova_projekt_SQL_final
SELECT thf.*, v.religion, v.MAX_religion_in_perc
FROM t_Helena_final1 as thf
LEFT JOIN v_Helena_religion_final as v
on thf.country = v.country


  
  