--activity 0 - close the murder mystery
SELECT COUNT(*) AS person_driver_rows
FROM individual AS i
INNER JOIN drivers AS d
  ON i.driver_id = d.id;

--q1
select d.id, i.name, d.gender, d.hair_color, d.eye_color, d.car_make, d.car_model, d.plate
from drivers as d
join individual as i 
	on d.id = i.driver_id 
limit 20;

--q2
select d.id, i.name, d.gender, d.hair_color, d.eye_color, d.car_make, d.car_model, d.plate
from drivers as d
join individual as i 
	on i.driver_id = d.id
where i.id  = 45 or i.id = 146 or i.id = 647 or i.id = 981
limit 20;

--q3
select i.name, it.description
from individual as i 
left join interrogation as it 
on i.id = it.individual_id 
where lower(i.name) = "tris macvagh"

--q4
select d.id, i.name, d.gender, d.hair_color, d.eye_color, d.car_make, d.car_model, d.plate
from drivers as d
join individual as i 
	on i.driver_id = d.id
where lower(d.gender) = "female" and lower(d.hair_color) = "blonde" and lower(d.eye_color) = "green" and lower(d.car_make) = "pontiac";

--q5

select d.id, i.name, d.gender, d.hair_color, d.eye_color, d.car_make, d.car_model, d.plate, f.individual_id, f.event_description 
from drivers as d
join individual as i
	on d.id = i.driver_id
join facebook_event as f
	on i.id = f.individual_id 
where lower(d.gender) = "female" and lower(d.hair_color) = "blonde" and lower(d.eye_color) = "green" and lower(d.car_make) = "pontiac" and lower(f.event_description) like "%rock%";




--q6
select d.id, i.name
from drivers as d
join individual as i
	on d.id = i.driver_id
join facebook_event as f
	on i.id = f.individual_id 
where lower(d.gender) = "female" and lower(d.hair_color) = "blonde" and lower(d.eye_color) = "green" and lower(d.car_make) = "pontiac" and lower(f.event_description) like "%rock%";