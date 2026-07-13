-- warmup 
--d1
select * from claims where lower(state) = "ct"

--d2
select
	"claim_id", "amount"
from claims 
where "amount" > 2000

--d3
select state STATE, count(*) as Total
from claims 
group by state


--d4
select claim_type, Avg(amount)
from claims 
group by claim_type 

--d5
select claim_type, amount
from claims 
group by amount 
order by amount DESC 
limit 3

--d6
select * 
from claims
WHERE amount is NUll