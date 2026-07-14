--call center


select * from agent a 
limit 1;

--q1
select COUNT(distinct AgentId)
from agent;

--q2
select COUNT(distinct CallID)
from call;

--q3
select COUNT(distinct CallID)
from call
where PickedUp = 1;

--q4
select COUNT(distinct CallID)
from call
where ProductSold > 0;

--q5
select avg(Duration)
from call
where Duration > 0;

--q6
select AgentID, count(CallID), count(ProductSold), AVG(ProductSold) as product_sold_rate
from call
group by AgentID 
order by product_sold_rate DESC;

--q7
select AgentID, count(CallID) as total_calls, count(ProductSold), AVG(ProductSold) as product_sold_rate
from call
group by AgentID having total_calls >= 900
order by product_sold_rate DESC;

--q8
select AgentID, count(CallID) as picked_up_calls, Duration
from call 
where Duration > 0
group by AgentID 
order by picked_up_calls desc;

--q9
select count(CustomerID) as NumberCustomers, Age,
case 
	when Age < 18 then "minor"
	when Age >= 18 and age < 35 then "adult"
	when Age >= 35 then "advanced"
end as AgeGroup
from customer
group by AgeGroup
order by NumberCustomers;

--q10 stretch 
select count(CustomerID) as CustomerAmount, Occupation
from customer 
group by Occupation having CustomerAmount > 20
order by CustomerAmount desc;

--activity three crime
--q1
select date, type, city, country, description
from crime_scene
limit 10 ;

--q2 
select date, type, city, country, description
from crime_scene
where type = "murder";

--q3
select type, count(type) as TypeTotal
from crime_scene
group by type
order by TypeTotal desc;

--q4
select city, count(*) as incidents
from crime_scene 
group by city having incidents > 2;

--q5
select id, hair_color, age, gender, height, eye_color, plate
from drivers
where LOWER(hair_color) = "white";

--q6
select id, age, gender, plate, car_make, car_model, car_model_year
from drivers
where lower(car_make) = "maserati";

--q7 
select count(id) as categoryTotal,
case
	when income < 35000 then "Low"
	when income between 35000 and 50000 then "Medium"
	else "High"
end as income_category
from individual
group by income_category;

--q8
select name, age, gender, hair_color, car_make, car_model
from v_suspects;

-- stretch goal
select individual_id, description
from interrogation 
where description like lower("%poirot%");