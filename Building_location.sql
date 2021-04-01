--Case Study – Location analysis for new cafe in Melbourne - SQL

--In the first part of this project data exploration will be conducted, baked down in following area: 
--•	Introduction
--•	Usability
--•	Competition
--•	Audience
--•	Potential growth
--In second part of analysis hypothesis will be tested to choose potential location. 


--Assumptions:
-- location in Melbourne CBD;
-- block with the highest number properties used as offices;
-- properties with the highest number of floors;
-- as a public place it should be accessible for people with disabilities - required moderate rating access
-- no bikes facilities / car parking requred; 
-- due to the weather in Melbourne only seating indoor will be considered

--o	Introduction

--Basic information about dataset: 
-- Available columns in datasets
-- employment_per_block dataset : 43 columns avaliable 
-- cafes_and_restaurants dataset : 14 columns avaliable 
-- building_access_bikes_space dataset : 19 columns avaliable 

SELECT * FROM information_schema.columns WHERE table_name = 'employment_per_block'
SELECT * FROM  information_schema.columns WHERE table_name = 'cafes_and_restaurants'
SELECT * FROM information_schema.columns WHERE table_name = 'building_access_bikes_space'

-- Show 5 top rows 
SELECT * FROM non_public.employment_per_block LIMIT 5
SELECT * FROM non_public.cafes_and_restaurants LIMIT 5
SELECT * FROM non_public.building_access_bikes_space LIMIT 5

-- Location should be - Melbourne (CBD) 
-- There is 83 unique blocks in employment_per_block dataset 
SELECT COUNT(DISTINCT(block_id)) FROM non_public.employment_per_block WHERE clue_small_area = 'Melbourne (CBD)'

-- There is property 81 unique blocks in cafes_and_restaurants
SELECT COUNT(DISTINCT(block_id)) FROM non_public.cafes_and_restaurants  WHERE clue_small_area = 'Melbourne (CBD)'

-- There is property 83 unique blocks in building_access_bikes_space
SELECT COUNT(DISTINCT(block_id)) FROM non_public.building_access_bikes_space  WHERE clue_small_area = 'Melbourne (CBD)'


-- Duplicates check 
-- Check number of unique block id 
-- There are 64 duplicates in cafes_and_restaurants dataset
-- There is 1 duplicate in information_schema.columns dataset
-- There are 22 duplicates in building_access_bikes_space dataset

select count(*), census_year, block_id, property_id, base_property_id, street_address, clue_small_area, trading_name, industry_anzsic4_code industry_anzsic4_description, seating_type, number_of_seats,  x_coordinate, y_coordinate, location
from non_public.cafes_and_restaurants
group by census_year, block_id, property_id, base_property_id, street_address, clue_small_area,trading_name, industry_anzsic4_code, industry_anzsic4_description, 
seating_type, number_of_seats,  x_coordinate, y_coordinate, location
having count(*) > 1 order by count desc

select count(*), total_space_in_block, block_id, census_year, commercial_accommodation, common_area, community_use, educational_research, entertainment_recreation_indoor, equipment_installation, hospital_clinic, house_townhouse, institutional_accommodation,   
manufacturing, office, park_reserve, parking_commercial_uncovered, parking_private_covered, parking_private_uncovered, performances, 
conferences, ceremonies, private_outdoor_space, public_display_area, residential_apartment, retail_cars, retail_shop, retail_showroom,retail_stall, sports_and_recreation_outdoor, square_promenade, storage,student_accommodation,transport, transport_storage__uncovered,unoccupied_under_construction, unoccupied_under_demolition_condemned, unoccupied_under_renovation, unoccupied_undeveloped_site, unoccupied_unused,  wholesale,workshop_studio, clue_small_area  
from non_public.employment_per_block
group by total_space_in_block, block_id, census_year, commercial_accommodation, common_area, community_use, educational_research, entertainment_recreation_indoor, equipment_installation, hospital_clinic, house_townhouse, institutional_accommodation,   
manufacturing, office, park_reserve, parking_commercial_uncovered, parking_private_covered, parking_private_uncovered, performances, 
conferences, ceremonies, private_outdoor_space, public_display_area, residential_apartment, retail_cars, retail_shop, retail_showroom,retail_stall, sports_and_recreation_outdoor, square_promenade, storage,student_accommodation,transport, transport_storage__uncovered,unoccupied_under_construction, unoccupied_under_demolition_condemned, unoccupied_under_renovation, unoccupied_undeveloped_site, unoccupied_unused,  wholesale,workshop_studio, clue_small_area
having count(*) > 1 order by count desc

select count(*), census_year, block_id, property_id, base_property_id, construction_year, refurbished_year, number_of_floors_above_ground,
accessibility_rating, bicycle_spaces, x_coordinate, y_coordinate, accessibility_type, building_name, street_address,
clue_small_area, accessibility_type_description, has_showers, location, predominant_space_use 
from non_public.building_access_bikes_space
group by census_year, block_id, property_id, base_property_id, construction_year, refurbished_year, number_of_floors_above_ground,
accessibility_rating, bicycle_spaces, x_coordinate, y_coordinate, accessibility_type, building_name, street_address,
clue_small_area, accessibility_type_description, has_showers, location, predominant_space_use
having count(*) > 1 order by count desc

-- Buplicates will be ignored. 

-- For further analysis, datasets will be combined for the lowest number of blocks 81 (cafes_and_restaurants dataese) 
-- cte table has 81 unique blocks 

WITH cte_table AS (
	SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment,
	q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats,
	e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
	e.number_of_floors_above_ground, e.refurbished_year
	FROM non_public.cafes_and_restaurants q  
	LEFT JOIN non_public.employment_per_block w 
	ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
	LEFT JOIN non_public.building_access_bikes_space e
	On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
	) 
	SELECT COUNT(DISTINCT(block_id)) FROM cte_table WHERE clue_small_area = 'Melbourne (CBD)'



-- In that block area we have 50 different types of businesses in CBD including 2567 Cafes and Restaurants
WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment,
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT industry_anzsic4_description, COUNT(industry_anzsic4_description) AS total_number FROM cte_table WHERE clue_small_area = 'Melbourne (CBD)'
GROUP BY industry_anzsic4_description ORDER BY total_number DESC

-- Checking on the original dataset 
SELECT industry_anzsic4_description, clue_small_area, COUNT(DISTINCT(trading_name)) AS total_unique FROM non_public.cafes_and_restaurants 
GROUP BY industry_anzsic4_description,clue_small_area HAVING clue_small_area = 'Melbourne (CBD)'ORDER BY total_unique DESC


-- It will be identify number of street addresses per block(in 2019 Melbourne (CBD) ) 

WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment,
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT block_id, COUNT(DISTINCT(street_address)) AS numbers_of_street_addresses
FROM cte_table WHERE (clue_small_area = 'Melbourne (CBD)' AND census_year = 2019)
GROUP BY (block_id) ORDER BY block_id


-- It is worth to look at building age (KNAUDIA - nie wiem jak z³apaæ null - wiec zamienilam na 0 a pozniej zlapalam - ale to nie wyglada 

WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment,
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT DISTINCT(street_address), refurbished_year, COALESCE(refurbished_year, 0),

CASE WHEN refurbished_year < 2000  THEN 'older_than_20y'
	   WHEN refurbished_year < 2010 AND refurbished_year >= 2000 THEN 'between_10_and_20_yo'
	   WHEN refurbished_year < 2010 THEN 'less_than_10_yo' 
	   WHEN  '0' THEN 'no_information_provided'
	   ELSE 'no_information_provided'
	   END AS building_age

FROM cte_table 
WHERE (clue_small_area = 'Melbourne (CBD)' AND census_year = 2019)


--o	Accessibility 

-- Unique type of accessibility rating
-- Ther are 4 types of accesibility: Not determined or not applicable - (Rating = null) Moderate level of accessibility (Rating = 2)/ High level of accessibility (Rating = 3) /Low level of accessibility (Rating = 1) 

SELECT accessibility_type, accessibility_rating FROM non_public.building_access_bikes_space 
GROUP BY accessibility_rating, accessibility_type, clue_small_area
HAVING clue_small_area = 'Melbourne (CBD)'

-- There are few types of accessibility _type_ description : Main Entrance has ramp, Main Entrance is at grade and has no steps or ramp, Entrance(s) have limited access via a small lip or a steep ramp, All entrances have steps, Building is not considered to be publicly accessible so access has not been rated, Access has not been rated, Configuration of entrance does not fit into any of the other categories, Main entrance has steps; Alternative entrance is step free or has ramp
SELECT DISTINCT(accessibility_type_description) FROM non_public.building_access_bikes_space 
WHERE clue_small_area = 'Melbourne (CBD)'

-- Types of predominant space use
-- The dataset contains 24 predominant space use types.
SELECT DISTINCT(predominant_space_use) FROM non_public.building_access_bikes_space WHERE clue_small_area = 'Melbourne (CBD)'


-- Number of floors divided by use will give information about potential number of customers - dwie wersje z where i having 
KLAUDIA - tytaj te dwie liczby sie roznia, nie wiem z czego o wynika 
WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment,
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT DISTINCT(predominant_space_use), COUNT(DISTINCT(property_id)) AS number_of_property, 
SUM(number_of_floors_above_ground) AS cumulative_number_of_floors_in_space_use_category
FROM cte_table 
GROUP BY predominant_space_use, clue_small_area, census_year
HAVING clue_small_area = 'Melbourne (CBD)' AND census_year = 2019
ORDER BY  cumulative_number_of_floors_in_space_use_category DESC



SELECT DISTINCT(predominant_space_use), COUNT(DISTINCT(property_id)) AS number_of_property, 
SUM(number_of_floors_above_ground) AS cumulative_number_of_floors_in_space_use_category
FROM non_public.building_access_bikes_space 
GROUP BY predominant_space_use, clue_small_area, census_year
HAVING clue_small_area = 'Melbourne (CBD)' AND census_year = 2019
ORDER BY  cumulative_number_of_floors_in_space_use_category DESC




WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment,
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT DISTINCT(predominant_space_use), COUNT(DISTINCT(property_id)) AS number_of_property, 
SUM(number_of_floors_above_ground) AS cumulative_number_of_floors_in_space_use_category
FROM cte_table WHERE  clue_small_area = 'Melbourne (CBD)' AND census_year = 2019
GROUP BY predominant_space_use, clue_small_area, census_year
ORDER BY  cumulative_number_of_floors_in_space_use_category DESC


SELECT DISTINCT(predominant_space_use), COUNT(DISTINCT(property_id)) AS number_of_property, 
SUM(number_of_floors_above_ground) AS cumulative_number_of_floors_in_space_use_category
FROM non_public.building_access_bikes_space WHERE clue_small_area = 'Melbourne (CBD)' AND census_year = 2019
GROUP BY predominant_space_use, clue_small_area, census_year
ORDER BY  cumulative_number_of_floors_in_space_use_category DESC

--o	Competition

-- In Melbourne (CBD) in 2019 was 931 unique trading names with industry anzsic4 description as Cafes and Restaurants

WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment,
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats,q.trading_name,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT COUNT(DISTINCT(trading_name)) AS unique_trading_names 
FROM cte_table 
WHERE (clue_small_area = 'Melbourne (CBD)' AND census_year = 2019 AND industry_anzsic4_description = 'Cafes and Restaurants')

-- Checking on the original dataset 
SELECT COUNT(DISTINCT(trading_name)) AS unique_trading_names  FROM non_public.cafes_and_restaurants 
WHERE (clue_small_area = 'Melbourne (CBD)' AND census_year = 2019 AND industry_anzsic4_description = 'Cafes and Restaurants')

-- In Melbourne (CBD) in 2019 was 799 unique trading names with indoor seating type and 321 unique trading names with  outdoor seating  with industry anzsic4 description as Cafes and Restaurants and Moderate level of accessibility
WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment,
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats,q.trading_name,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT seating_type, COUNT(DISTINCT(trading_name)) AS unique_trading_names , accessibility_type
FROM cte_table 
WHERE (clue_small_area = 'Melbourne (CBD)' AND census_year = 2019 AND industry_anzsic4_description = 'Cafes and Restaurants' AND accessibility_type = 'Moderate level of accessibility')
GROUP BY seating_type, accessibility_type


o	Audience

--  Block 78 has 14710 office employee, followed by 14913 wholesale employees
- - 
WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment, w.office,  
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats, q.trading_name,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT DISTINCT(block_id), SUM(DISTINCT(office))AS number_of_employee_in_office, SUM(DISTINCT(wholesale))AS wholesale_employee
FROM cte_table
GROUP BY block_id, clue_small_area, census_year
HAVING (clue_small_area = 'Melbourne (CBD)' AND census_year = 2019)  ORDER BY number_of_employee_in_office DESC

-- Checking on the original dataset 
SELECT block_id, SUM(office) AS number_of_employee_in_office ,  SUM(DISTINCT(wholesale)) AS  wholesale_employee FROM non_public.employment_per_block GROUP BY block_id, clue_small_area, census_year
HAVING (clue_small_area = 'Melbourne (CBD)' AND census_year = 2019) ORDER BY number_of_employee_in_office DESC

-- Total number of employees in office and wholesale by year 

WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment, w.office,  
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats, q.trading_name,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT census_year, block_id, SUM(DISTINCT(office)) AS office_employee , SUM(DISTINCT(wholesale)) AS  wholesale_employee ,
SUM(DISTINCT(COALESCE(office,0))) + SUM(DISTINCT(COALESCE(wholesale,0) ))AS total_number_of_employee
FROM cte_table
WHERE clue_small_area = 'Melbourne (CBD)' 
GROUP BY block_id, census_year 
ORDER BY block_id DESC, census_year ASC

-- Checking on the original dataset 

SELECT census_year, block_id, SUM(office) AS office_employee , SUM(wholesale) AS  wholesale_employee ,
SUM(COALESCE(office,0)) + SUM(COALESCE(wholesale,0) )AS total_number_of_employee
FROM non_public.employment_per_block 
WHERE clue_small_area = 'Melbourne (CBD)' 
GROUP BY block_id, census_year 
ORDER BY block_id DESC, census_year ASC


-- Next number of  employees in office and wholesale by year with including next year and change in percentages
-- blocks 52, 78, 34 , 24 and 47 has the highest number of employee in 2019 

WITH cte_table AS (
SELECT census_year, block_id, SUM(office) AS office_employee , SUM(wholesale) AS  wholesale_employee ,
SUM(COALESCE(office,0)) + SUM(COALESCE(wholesale,0)) AS total_number_of_employee FROM non_public.employment_per_block 
WHERE clue_small_area = 'Melbourne (CBD)' GROUP BY block_id, census_year ORDER BY block_id DESC, census_year ASC ) 
SELECT *, LEAD(total_number_of_employee, 1) OVER( PARTITION BY block_id ORDER BY census_year) AS next_total_number_of_employee, 
CAST(
	total_number_of_employee - (LEAD(total_number_of_employee, 1) OVER( PARTITION BY block_id ORDER BY census_year)) 
	as float) /  total_number_of_employee * 100
	AS  total_number_of_employee_in_percent
FROM cte_table



-- Hypothesis 1. 
-- Block 52 (between 78, 52,47) has the highest number of floors with the highest number of people working in offices between 2017 and 2019 

-- Block number 78: 
-- 	has 11 unique street adresses with cummulative 14710 office employeee - cummulative 153 floors - in 2019;
-- 	has 12 unique street adresses with cummulative 9415 office employeee - cummulative 139 floors -  in 2018;
--  has 12 unique street adresses with cummulative 9415 office employeee - cummulative 139 floors -  in 2017;
-- Block number 52: 
-- 	has 8 unique street adresses with cummulative 11633 office employeee - cummulative 146 floors - in 2019;
-- 	has 8 unique street adresses with cummulative 9700 office employeee - cummulative 146 floors -  in 2018;
--  has 8 unique street adresses with cummulative 9700 office employeee - cummulative 146 floors -  in 2017;
-- Block number 47: 
-- 	has 25 unique street adresses with cummulative 6696 office employeee - cummulative 190 floors - in 2019;
-- 	has 25 unique street adresses with cummulative 6696 office employeee - cummulative 190 floors -  in 2018;
--  has 25 unique street adresses with cummulative 6696 office employeee - cummulative 190 floors -  in 2017;

-- Conclusion 1. 
-- Block 52 do not has the highest number of  office employeee between 2017 and 2019.  
-- Block 78 has the highest number of office employee. The increase of office employeee between 2018 and 2019 was 56%. The number of floors between 2017 and 2019 increased by 10%. This may be related to the commissioning of the new building in 2019. The number of addresses (where office workers are employed) decreased from 11 to 10 between 2017 and 2019. 


WITH cte_table AS 
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment, w.office,  
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats, q.trading_name,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT  SUM(DISTINCT(number_of_floors_above_ground)), block_id, census_year, street_address,  SUM(DISTINCT(office)) AS office_employee , SUM(DISTINCT(wholesale) )AS  wholesale_employee ,
SUM(DISTINCT(COALESCE( office ,0))) + SUM(DISTINCT(COALESCE(wholesale,0) ))AS total_number_of_employee
FROM cte_table
WHERE  clue_small_area = 'Melbourne (CBD)'AND census_year BETWEEN 2017 AND 2019 AND block_id = 47
GROUP BY block_id, census_year, number_of_floors_above_ground, street_address
ORDER BY office_employee DESC, census_year ASC

-- block 78 informtion about refurbished and construction 
-- 267-271 Spring Street MELBOURNE 3000 has been build in year 2019

SELECT DISTINCT(street_address), refurbished_year,construction_year FROM non_public.building_access_bikes_space 
WHERE clue_small_area = 'Melbourne (CBD)' and block_id = 78 
GROUP BY street_address, refurbished_year, construction_year
ORDER BY construction_year ASC 


SELECT SUM(sum_number_of_floors), block_id, census_year FROM 
(WITH cte_table AS 							  
(
SELECT w.clue_small_area, w.block_id, w.census_year, w.wholesale, w.residential_apartment, w.office,  
q.property_id, q.base_property_id, q.industry_anzsic4_description, q.seating_type, q.number_of_seats, q.trading_name,
e.predominant_space_use, e.accessibility_type, e.street_address, e.construction_year, e.bicycle_spaces, e.accessibility_rating,
e.number_of_floors_above_ground, e.refurbished_year
FROM non_public.cafes_and_restaurants q  
LEFT JOIN non_public.employment_per_block w 
ON w.block_id = q.block_id AND w.census_year=q.census_year AND w.clue_small_area = q.clue_small_area
LEFT JOIN non_public.building_access_bikes_space e
On w.block_id = e.block_id AND w.census_year=e.census_year AND w.clue_small_area = e.clue_small_area
) 
SELECT  SUM(DISTINCT(number_of_floors_above_ground)) AS sum_number_of_floors, block_id, census_year, street_address,  SUM(DISTINCT(office)) AS office_employee , SUM(DISTINCT(wholesale) )AS  wholesale_employee ,
SUM(DISTINCT(COALESCE( office ,0))) + SUM(DISTINCT(COALESCE(wholesale,0)))AS total_number_of_employee
FROM cte_table
WHERE  clue_small_area = 'Melbourne (CBD)'AND census_year BETWEEN 2017 AND 2019 AND block_id IN (78,47,52)
GROUP BY block_id, census_year, number_of_floors_above_ground, street_address
ORDER BY office_employee DESC, census_year ASC) as table_floors 
GROUP BY block_id, census_year 


-- Hypothesis 2.
-- Block 52 has min 5 unique addresse where accessibility_rating > 2

-- Conclusion 2.
-- Block 78 has 5 unique addresses with accessibility rating a minimum o 2. Out of 11 unique street addresses in this block. Only 45,5% has minimum 2 accessibility rating. 
-- Block 52 has 7 unique addresses with accessibility rating a minimum o 2. Out of 8 unique street addresses in this block. Only 87,5% has minimum 2 accessibility rating. 
-- Block 47 has 7 unique addresses with accessibility rating a minimum o 2. Out of 25 unique street addresses in this block. Only 28% has minimum 2 accessibility rating. 

-- Nevertheless unique addresses with accessibility rating minim 2 constitude 87,5% of all unique addresses in that block. Followed by block 78 with 45,5% of addresses with accesibility rating minimum 2. 


SELECT block_id, COUNT(DISTINCT(street_address)) AS number_od_street_address FROM non_public.building_access_bikes_space 
WHERE block_id IN (78,47,52)  AND clue_small_area = 'Melbourne (CBD)' AND accessibility_rating > 2 AND census_year= 2019
GROUP BY block_id 


-- Hypothesis 3.
-- Block 52 between (78, 52,47) has the lowest number of competitors in 2019 

-- Conclusion 3.
-- Block 47 has 45 Cafes and Restaurants in 2019.
-- Block 52 has 30 Cafes and Restaurants in 2019. 
-- Block 78 has 21 Cafes and Restaurants in 2019.

SELECT SUM(total_number) AS total_number_cafes_and_restaurants, block_id FROM
(SELECT block_id, street_address, industry_anzsic4_description, COUNT(industry_anzsic4_description) AS total_number FROM non_public.cafes_and_restaurants
WHERE block_id IN (78,47,52) AND clue_small_area = 'Melbourne (CBD)' AND census_year = 2019 AND industry_anzsic4_description = 'Cafes and Restaurants'
GROUP BY industry_anzsic4_description, street_address, block_id
ORDER BY block_id ASC) AS table1
GROUP BY block_id 


-- Hypothesis 4.
-- Block 52 between (78, 52,47) has the lowest number of indoor seating in 2019 

-- Conclusion 2.
-- Block 47 has 1287 indoor seats (27 number of unique busnesses) in 2019.
-- Block 52 has 888 indoor seats (15 number of unique busnesses) in 2019.
-- Block 78 has 622 indoor seats (13 number of unique busnesses) in 2019.


SELECT seating_type, block_id, COUNT(DISTINCT(trading_name)) AS number_of_busnesses, SUM(number_of_seats) AS total_number_of_seats FROM non_public.cafes_and_restaurants WHERE block_id IN (78,47,52) AND clue_small_area = 'Melbourne (CBD)' AND census_year = 2019 AND industry_anzsic4_description = 'Cafes and Restaurants' GROUP BY seating_type, block_id


-- Hypothesis 5.
-- Block 52 between (78, 52,47) has the highest growth potential between 2015 - 2019 

-- Conclusion 5.
-- Block 47 has 4,3% average yearly increase in number of employee between 2015 and 2019. Total increase is 17.4%
-- Block 52 has 6,1% average yearly increase in number of employee between 2015 and 2019. Total increase is 24.4%
-- Block 78 has 2,3% average yearly increase in number of employee between 2015 and 2019. Total increase is 9,2%
-- 

SELECT AVG(total_number_of_employee_in_percent) AS average_yearly_employee_increase, SUM(total_number_of_employee_in_percent) AS total_number_of_increase, block_id 
FROM
(WITH cte_table AS (
SELECT census_year, block_id, SUM(office) AS office_employee , SUM(wholesale) AS  wholesale_employee ,
SUM(COALESCE(office,0)) + SUM(COALESCE(wholesale,0)) AS total_number_of_employee FROM non_public.employment_per_block 
WHERE clue_small_area = 'Melbourne (CBD)' AND census_year BETWEEN 2015 AND 2019 GROUP BY block_id, census_year ORDER BY block_id DESC, census_year ASC ) 
SELECT *, LEAD(total_number_of_employee, 1) OVER( PARTITION BY block_id ORDER BY census_year) AS next_total_number_of_employee, 
CAST(
	total_number_of_employee - (LAG(total_number_of_employee, 1) OVER( PARTITION BY block_id ORDER BY census_year)) 
	as float) /  total_number_of_employee * 100
	AS  total_number_of_employee_in_percent
FROM cte_table
WHERE block_id IN (78,47,52)
ORDER BY block_id ASC ) AS table1
GROUP BY block_id 

-- unique addresses : 2 Lonsdale Street MELBOURNE 3000, 242-284 Exhibition Street MELBOURNE 3000, 32-54 Lonsdale Street MELBOURNE 3000

SELECT DISTINCT(street_address) FROM non_public.cafes_and_restaurants 
WHERE block_id = 78 AND clue_small_area = 'Melbourne (CBD)' AND census_year = 2019 

-- Block 78 has the highest number of office employees in 2019 (11633), with the lowest number of competitors - 21 Cafes and Restaurants with 622 indoor seats. 
-- Required accesibility rating meets 45,5% of total cafees number.
-- Potencial growth is 2.3% per year. 

-- In this block will be recommended as potential location that comply with all assumptions. 
















