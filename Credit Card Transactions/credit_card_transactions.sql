1. How many customers have done transactions over 49000?

select count(distinct cust_id) as no_of_customers from card_base cb join transaction_base tb on cb.card_number=tb.credit_card_id
where transaction_value >49000;



2) What kind of customers can get a Premium credit card?

select distinct customer_segment  from Card_base crd join customer_base cst using(cust_id) where lower(card_family)='premium';



3) Identify the range of credit limit of customer who have done fraudulent transactions.

select min(credit_limit),max(credit_limit) from fraud_base fb join transaction_base tb using(transaction_id) 
join card_base crd on crd.card_number=tb.credit_card_id;



4) What is the average age of customers who are involved in fraud transactions based on different card type?

select card_family,round(avg(age),2) avg_age from fraud_base fb join transaction_base tb using(transaction_id) 
join card_base crd on crd.card_number=tb.credit_card_id
join customer_base cst using(cust_id) group by 1;




5) Identify the month when highest no of fraudulent transactions occured.

select to_char(transaction_date,'MON') txn_month,count(transaction_id) from fraud_base fb join transaction_base tb using(transaction_id)
group by 1 order by 2 desc limit 1;



6) Identify the customer who has done the most transaction value without involving in any fraudulent transactions.

select cust_id,sum(transaction_value) max_txnvalue from transaction_base tb join card_base crd on crd.card_number=tb.credit_card_id
where cust_id not in 
(select cust_id from fraud_base fb join transaction_base tb using(transaction_id) 
join card_base crd on crd.card_number=tb.credit_card_id)
group by 1 order by 2 desc limit 1;



7) Check and return any customers who have not done a single transaction.

select cust_id from customer_base where cust_id not in 
(select cust_id from transaction_base tb join card_base crd on crd.card_number=tb.credit_card_id);

Out of 5674 customers, 5192 have not done any txns



8) What is the highest and lowest credit limit given to each card type?

select card_family,max(credit_limit) highest,min(credit_limit) lowest from card_base group by 1;




9) What is the total value of transactions done by customers who come under the age bracket of 20-30 yrs, 30-40 yrs, 40-50 yrs, 50+ yrs and 0-20 yrs.

-- order of case when stmt is important 
select case when age between 0 and 20 then '0-20 yrs'
			when age between 20 and 30  then '20-30 yrs'
			when age between 30 and 40  then '30-40 yrs'
			when age between 40 and 50  then '40-50 yrs'
			else '50+ yrs' end age_cat,sum(transaction_value) total_val
from transaction_base tb join card_base crd on crd.card_number=tb.credit_card_id
join customer_base cst using(cust_id) group by 1 order by 1;

(OR)

select sum(case when age > 0 and age <=20 then transaction_value else 0 end) txnval_0to20,
       sum(case when age > 20 and age <=30 then transaction_value else 0 end) as txnval_20to30,
       sum(case when age > 30 and age <=40   then transaction_value else 0 end) as txnval_30to40,
	   sum(case when age > 40 and age <=50 then transaction_value else 0 end) as txnval_40to50,
	   sum(case when age >50 then transaction_value else 0 end) as txnval_above50  
from transaction_base tb join card_base crd on crd.card_number=tb.credit_card_id
join customer_base cst using(cust_id);



10) Which card type has done the most no of transactions and the total highest value of transactions without having any fraudulent transactions.

with cte as
(select * from transaction_base tb join card_base crd on crd.card_number=tb.credit_card_id)
select card_family,count(transaction_id) hightest_no_of_txns,sum(transaction_value) highest_txn_val from cte 
where card_family not in (select card_family from cte join fraud_base using(transaction_id))
group by 1;

No records are returned because there is at least one customer who has been involved in a fraudulent transaction across every card type.

select * from Card_base; 
select * from Customer_base; 
select * from Fraud_base; 
select * from Transaction_base; 

























































