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