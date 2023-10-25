create database amazon2;

use amazon2;

create table Sales(
OrderID varchar(100),
Order_Date Date,
shipStatus varchar(100),
Fulfilment	varchar(50),
ServiceLevel varchar(50),
Style varchar(50),
SKU varchar(100),
Category varchar(100),
Size varchar(10),
asin varchar(100),
CourierShipStatus varchar(100),
Quantity int,
Amount int,
ship_city varchar(50),
ship_state varchar(50),
zip int,
promotion varchar(100),
cutomerType varchar(50),
order_month varchar(10));

select * from sales limit 10;

-- data updation --

update sales
set shipstatus = 'Returned to seller'
where shipstatus regexp 'Returning' or shipstatus regexp 'Returned';

update sales 
set shipstatus = 'Delivered'
where shipstatus = 'Shipped - Delivered to Buyer';

update sales
set shipstatus = 'Pending'
where shipstatus regexp 'pending';

update sales
set shipstatus = 'Shipped'
where shipstatus = 'shipping';

update sales 
set shipstatus = 'Rejected by Buyer'
where shipstatus = 'Shipped - Rejected by Buyer';

update sales
set shipstatus = 'Lost in Transit'
where shipstatus = 'Shipped - Lost in Transit';

update sales
set shipstatus = 'Out for Delivery'
where shipstatus = 'Shipped - Out for Delivery';

update sales 
set shipstatus = 'Damaged'
where shipstatus = 'Shipped - Damaged';

select distinct ship_state from sales order by ship_state;

update sales
set ship_state = 'NAGALAND'
WHERE SHIP_STATE regexp '^NL' or ship_state regexp 'NAGALAND';

update sales
set ship_state = 'RAJASTHAN'
WHERE SHIP_STATE regexp 'Rajshthan' or ship_state regexp 'rajsthan' or ship_state regexp 'RJ';

update sales
set ship_state = 'PUNJAB'
WHERE SHIP_STATE regexp 'Punjab/Mohali/Zirakpur' or ship_state regexp 'PB';

update sales
set ship_state = 'ODISHA'
WHERE ship_state regexp 'orissa';

update sales
set ship_state = 'PUDUCHERRY'
WHERE ship_state regexp 'Pondicherry';

update sales
set ship_state = 'unknown'
WHERE ship_state regexp '^APO' ;

update sales
set ship_state = 'ARUNACHAL PRADESH'
WHERE ship_state regexp '^AR' ;

-- constant variables --

set @TotalRevenue := (select sum(amount) from sales);
set @TotalOrders := (select count(orderid) from sales);

-- Prelimary Analysis --

-- Analyzing Amazon's Sales Performance --

-- 1. State with highest orders 
select ship_state , round((count(orderid)/@TotalOrders)*100,2) as no_orders
from sales
group by ship_state
order by no_orders desc
limit 5;

-- 2. Product category with highest orders
select category , round((count(orderid)/@TotalOrders)*100,2) as no_orders
from sales
group by category
order by no_orders desc;


-- 3.Statevise category sales trend
select ship_state , Category , count(orderid) as count
from sales
group by ship_state , category
order by ship_state asc , count desc;

-- 4.customer types
select cutomerType , Round((count(orderid)/@TotalOrders)*100,2) as sales , round(avg(amount),2) as average_amount
from sales
group by cutomertype
order by sales desc;

-- 5.Monthly Trend in sales
with c as(
select 
monthname(order_date) as sales_month,count(orderid) as orders , 
case 
      when monthname(order_date) = 'April' then 1
      when monthname(order_date) = 'May' then 2
      when monthname(order_date) = 'June' then 3
      end as sno
from sales
group by sno , sales_month
order by sno)
select sno , sales_month ,orders ,
round((orders - LAG(orders) OVER(ORDER BY sno))/LAG(orders) OVER(ORDER BY sno) * 100,2) as Percent_Increase
from c
where sno<=3;


with c as(
select 
monthname(order_date) as sales_month,count(orderid) as orders , 
case 
      when monthname(order_date) = 'April' then 1
      when monthname(order_date) = 'May' then 2
      when monthname(order_date) = 'June' then 3
      end as sno
from sales
group by sno , sales_month
order by sno)
select sno , sales_month ,orders ,
round((orders - LAG(orders) OVER(ORDER BY sno))/LAG(orders) OVER(ORDER BY sno) * 100,2) as Percent_Increase
from c
where sno =1 or sno = 3;





-- Analyzing Amazon's Revenue Trends --

-- 1. Monthly trend in revenue

with c as(
select 
monthname(order_date) as sales_month,sum(amount) as revenue , 
case 
      when monthname(order_date) = 'April' then 1
      when monthname(order_date) = 'May' then 2
      when monthname(order_date) = 'June' then 3
      end as sno
from sales
group by sno , sales_month
order by sno)
select sno , sales_month ,revenue ,
round((revenue - LAG(revenue) OVER(ORDER BY sno))/LAG(revenue) OVER(ORDER BY sno) * 100,2) as Percent_Increase
from c
where sno<=3;

-- 2. Start an End of Quater Comparison
with c as(
select 
monthname(order_date) as sales_month,sum(amount) as revenue , 
case 
      when monthname(order_date) = 'April' then 1
      when monthname(order_date) = 'May' then 2
      when monthname(order_date) = 'June' then 3
      end as sno
from sales
group by sno , sales_month
order by sno)
select sno , sales_month ,revenue ,
(revenue - LAG(revenue) OVER(ORDER BY sno))/LAG(revenue) OVER(ORDER BY sno) * 100 as Percent_Increase
from c
where sno =1 or sno =3;

-- 3. Avg monthly order
select 
monthname(order_date) as sales_month,avg(amount) as avg_order_amount , 
case 
      when monthname(order_date) = 'April' then 1
      when monthname(order_date) = 'May' then 2
      when monthname(order_date) = 'June' then 3
      end as sno
from sales
group by sno , sales_month
having sno<=3
order by sno;

----------------------------------------------------------------------------------------------

-- Finding solutions to grow sales and revenue --

-- 1. Category with highest revenue

select Category , round((sum(amount)/@TotalRevenue)*100,2) as percent_revenue
from sales 
group by category
order by percent_revenue desc;

-- 2.Monthly trend in the sales
with c as
(select 
monthname(order_date) as sales_month,category,count(orderid) as orders , 
case 
      when monthname(order_date) = 'April' then 1
      when monthname(order_date) = 'May' then 2
      when monthname(order_date) = 'June' then 3
      end as sno
from sales
group by category , sales_month , sno
having sno <= 3
order by category , sno asc)
select category , sales_month , sno , ((orders-lag(orders) over (partition by category order by sno))/lag(orders) over (partition by category order by sno))*100 as percent
from c;

-- 3.Statewise monthly sales
with c as
(select 
monthname(order_date) as sales_month,ship_state,count(orderid) as orders , 
case 
      when monthname(order_date) = 'April' then 1
      when monthname(order_date) = 'May' then 2
      when monthname(order_date) = 'June' then 3
      end as sno
from sales
group by ship_state , sales_month , sno
having sno <= 3 
order by ship_state , sno asc)
select ship_state , sales_month , sno , ((orders-lag(orders) over (partition by ship_state order by sno))/lag(orders) over (partition by ship_state order by sno))*100 as percent
from c;


-- 4.Order Cancellations or Rejections

select shipstatus , (count(orderid)/@TotalOrders)*100 as count
from sales
group by shipstatus
order by count desc;


select shipstatus ,round((sum(case when fulfilment = 'amazon' then 1 else 0 end)/count(orderid))*100,2) as Amazon ,
round((sum(case when fulfilment = 'merchant' then 1 else 0 end)/count(orderid))*100,2) as Merchant
from sales 
group by shipstatus;



















