select * from daily_activity;
select * from sleep_day;
select * from weight_log;

Problem Statements:

1. Identify the day of the week when the customers are most active and least
active. Active is determined based on the no of steps.

with cte as
(select day_of_week,sum(total_steps) total,dense_rank()over(order by sum(total_steps)) rnk from daily_activity group by 1)
select case when rnk=1 then 'least active' else 'most active'end activity,day_of_week,
total from cte where rnk=1 or rnk=(select max(rnk) from cte);

select distinct
first_value(day_of_week) over(order by sum(total_steps) asc) least_active,
first_value(day_of_week) over(order by sum(total_steps) desc) most_active
from daily_activity group by day_of_week; 

-- Tuesday is the most active day with 1,235,001 steps, while Sunday is the least active with 838,921 steps.

2. Identify the customer who has the most effective sleep. Effective sleep is
determined based on is customer spent most of the time in bed sleeping.

with cte as 
(select customer_id,sum (total_time_in_bed-total_minutes_asleep) awake from sleep_day group by 1)
select customer_id from cte where awake = (select min(awake) from cte);

-- The customer with the most effective sleep is 7007744171, as they spent the most time in bed sleeping.

3. Identify customers with no sleep record.

select distinct customer_id from daily_activity where customer_id not in (select customer_id from sleep_day);

-- There are 9 customers without sleep record

4. Fetch all customers whose daily activity, sleep and weight logs are all present

select distinct customer_id from daily_activity da join sleep_day sd using(customer_id) join weight_log wl using(customer_id);

select customer_id from daily_activity
intersect
select customer_id from sleep_day
intersect
select customer_id from weight_log;

-- There are 6 customers whose daily activity, sleep, and weight logs are all present.

5. For each customer, display the total hours they slept for each day of the week.
Your output should contains 8 columns, first column is the customer id and the
next 7 columns are the day of the week (like monday, tuesday etc)

select customer_id, 
sum(case when day_of_week= 'Monday' then total_minutes_asleep else 0 end) Monday,
sum(case when day_of_week= 'Tuesday' then total_minutes_asleep else 0 end) Tuesday,
sum(case when day_of_week= 'Wednesday' then total_minutes_asleep else 0 end) Wednesday,
sum(case when day_of_week= 'Thursday' then total_minutes_asleep else 0 end) Thursday,
sum(case when day_of_week= 'Friday' then total_minutes_asleep else 0 end) Friday,
sum(case when day_of_week= 'Saturday' then total_minutes_asleep else 0 end) Saturday,
sum(case when day_of_week= 'Sunday' then total_minutes_asleep else 0 end) Sunday
from sleep_day group by customer_id;

6) For each customer, display the following:
customer_id
date when they had the highest_weight(also mention weight in kg) 
date when they had the lowest_weight(also mention weight in kg)

select distinct customer_id,
coalesce(first_value(dates||' ('||weight_kg||' kgs)')over(partition by customer_id order by weight_kg desc),'NA') highest_weight,
coalesce(first_value(dates||' ('||weight_kg||' kgs)')over(partition by customer_id order by weight_kg asc),'NA') lowest_weight
from weight_log right join daily_activity using(customer_id) order by 2;

7. Fetch the day when customers sleep the most.

select distinct first_value(day_of_week)over(order by sum(total_minutes_asleep) desc) most_slept_day from sleep_day group by day_of_week;

-- The day when customers sleep the most is Wednesday

8. For each day of the week, determine the percentage of time customers spend
lying on bed without sleeping.

select day_of_week,round(((sum(total_time_in_bed)-sum(total_minutes_asleep))::decimal/sum(total_time_in_bed)) * 100,2) percentage_mins
from sleep_day group by day_of_week order by 2 desc;

-- Sunday has the highest percentage (10.08%) of time spent lying on the bed without sleeping, while Wednesday has the lowest (7.52%).

9. Identify the most repeated day of week. Repeated day of week is when a day
has been mentioned the most in entire database.

select day_of_week,count(day_of_week) occurence from daily_activity full join sleep_day using(day_of_week) full join weight_log using(day_of_week) 
group by 1 order by 2 desc;

with cte as(
select day_of_week from daily_activity 
union all
select day_of_week from sleep_day 
union all
select day_of_week from weight_log),
cte_final as (
select day_of_week,count(*),dense_rank()over(order by count(*) desc) rnk from cte group by 1)
select day_of_week most_repeated from cte_final where rnk=1;

-- The most repeated day of the week in the database is Wednesday.

10. Based on the given data, identify the average kms a customer walks based on 6000 steps.

select customer_id,round(avg(total_distance),2) from daily_activity where total_steps>6000 group by 1 order by 2 desc;



































































































