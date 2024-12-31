-- Problem statements

-- QUESTIONS RELATED TO CUSTOMERS
-- [Q1] What is the distribution of customers across states?

select state,count(customer_id) distribution from customer group by 1 order by 2 desc;

/*
California and Texas has the highest customer count as 97
and Maine, Wyoming, Vermont being the least with only 1 customer.
*/

-- [Q2] What is the average rating in each quarter? Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

select quarter_number,
		round(avg(case 
			when customer_feedback = 'Very Bad' then 1 
			when customer_feedback = 'Bad' then 2
			when customer_feedback = 'Okay' then 3
			when customer_feedback = 'Good' then 4
			else 5 end), 2) as customer_rating
from  orders group by 1 order by 1;
            
-- we could clearly see a trend of customer ratings receding over each quater.          

-- [Q3] Are customers getting more dissatisfied over time?

-- Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
-- 	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
-- 	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
--       Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.

with each_cat as
(select quarter_number,customer_feedback,count(*) each_cat from orders group by 1,2),
total as 
(select quarter_number,count(*) total_count from orders group by 1)
select each_cat.quarter_number,each_cat.customer_feedback,round(each_cat/total_count*100,2) percentage
from each_cat join total using(quarter_number) group by 1,2 order by 1,2;

-- OR

with cte as(
select quarter_number,customer_feedback,count(*) each_cat from orders group by 1,2 order by 1)
select quarter_number,customer_feedback,
round(each_cat/(select count(order_id) from orders o where o.quarter_number=cte.quarter_number group by quarter_number)*100,2) percentage
from cte;

/*
The feedback percentage of very good being 30% in first quarter being decreased to 10% in fourth quarter clearly states that customers are
dissatisfied over the period of time.
*/

-- [Q4] Which are the top 5 vehicle makers preferred by the customer.

select vehicle_maker,count(customer_id) no_of_customers from orders o join product p using(product_id) group by 1 order by 2 desc limit 5;

/*
Chevrolet, Ford, Toyota, Dodge, Pontiac are the top 5 vehicle makers preferred by the customers over the given period of time.
*/

-- [Q5] What is the most preferred vehicle make in each state?

with cte as 
(select vehicle_maker,state,count(customer_id) no_of_customers,dense_rank() over(partition by state order by count(customer_id) desc) rnk 
from customer c join orders o using (customer_id) join product p using(product_id) group by 1,2)
select vehicle_maker,state,no_of_customers from cte where rnk=1;

/* 
In certain states, we have multiple vehicle makers because the highest number of customers from those states is equally distributed among them.
*/

-- QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

select quarter_number,count(order_id) no_of_orders from orders group by 1 order by 1;

/*
It evident from the result that order count has marginally reduced for each subsequent quarters.
*/

-- [Q7] What is the quarter over quarter % change in revenue? 

with cte as
(select *,lag(quarter_revenue) over(order by quarter_number) prvs_quarter from     
(select quarter_number,sum(revenue) quarter_revenue from (select quarter_number,quantity*vehicle_price revenue from orders) t1 group by 1)t2)
select quarter_number,round((quarter_revenue-prvs_quarter)/prvs_quarter*100,2) qoq_change from cte;

/*
The values indicate a consistent decline across four periods, suggesting a downward trend or negative performance progression.
*/

-- [Q8] What is the trend of revenue and orders by quarters?

select quarter_number,sum(quantity*vehicle_price) revenue,count(order_id) number_of_orders from orders group by 1 order by 1;

/*
The revenue and number of orders consistently decrease from Quarter 1 to Quarter 4, indicating a declining trend in sales performance over the year.
*/

-- QUESTIONS RELATED TO SHIPPING 

-- [Q9] What is the average discount offered for different types of credit cards?

select credit_card_type,round(avg(discount)*100,2) avg_discount from orders o join customer c using(customer_id) group by 1 order by 2 desc;

/*
Laser card has offered the highest discount of 64% and diners-club-international being the least among the dataset with a discount of 58%.
*/

-- [Q10] What is the average time taken to ship the placed orders for each quarters?

select quarter_number,round(avg(datediff(ship_date,order_date)),2) avg_timetaken from orders group by 1 order by 1;

/*
The average time taken to ship orders increases significantly each quarter, peaking at 174.10 days in Q4. This delay in shipping likely contributes 
to customer dissatisfaction and operational inefficiencies, exacerbating the company's financial losses.
*/

select * from customer;
select* from orders;
select * from product;
select * from shipper;


























































































































































