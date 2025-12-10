create database Final_Project;
use Final_project;

select * from brands;
select * from categories;
select * from customers;
select * from order_items;
select * from orders;
select * from products;
select * from staffs;
select * from stocks;
select * from stores;

#1. Create Tables Based on ERD
#Use CREATE TABLE statements to replicate the exact structure of the ER diagram (with constraints).

# brands
desc brands;
alter table brands modify column brand_name varchar(50);
alter table brands add primary key (brand_id);

    
# categories
desc categories;
alter table categories add constraint unique_category_id unique (category_id);
alter table categories modify column category_name varchar(50);
alter table categories add primary key (category_id);    

# customers
desc customers;
alter table customers add primary key (customer_id);
alter table customers modify column first_name varchar(50);
alter table customers modify column last_name varchar(50);
alter table customers modify column phone varchar(50);
alter table customers modify column email varchar(50);
alter table customers modify column street varchar(50);
alter table customers modify column city varchar(50);
alter table customers modify column state varchar(50);
alter table customers modify column zip_code varchar(50);

# order items
desc order_items;
alter table order_items add foreign key (order_id) references orders (order_id);
alter table order_items add foreign key (product_id) references products (product_id);
alter table order_items add foreign key (category_id) references categories (category_id);
alter table order_items modify column product_name varchar(100);
alter table order_items modify column category_name varchar(50);

# orders
desc orders;
alter table orders add primary key (order_id);
alter table orders add foreign key (customer_id) references customers (customer_id);
alter table orders modify column order_status varchar(50);
alter table orders modify column order_date varchar(50);
alter table orders modify column required_date varchar(50);
alter table orders modify column shipped_date varchar(50);
alter table orders modify column store_id int;
alter table orders modify column staff_id int;
alter table orders add foreign key (staff_id) references staffs (staff_id);
alter table orders add foreign key (store_id) references stores (store_id);

#products
desc products;
alter table products modify column product_name varchar(255);
alter table products add primary key (product_id);
alter table products add foreign key (brand_id) references brands (brand_id);
alter table products add foreign key (category_id) references categories (category_id);

#staffs
desc staffs;
alter table staffs add primary key (staff_id);
alter table staffs modify column first_name varchar(50);
alter table staffs modify column last_name varchar(50);
alter table staffs modify column phone varchar(50);
alter table staffs modify column email varchar(50);
alter table staffs modify column active varchar(50);
alter table staffs modify column manager_id varchar(50);
alter table staffs add foreign key (store_id) references stores (store_id);

#stocks
desc stocks;
alter table stocks add foreign key (store_id) references stores (store_id);
alter table stocks add foreign key (product_id) references products (product_id);

#stores
desc stores;
alter table stores add primary key (store_id);
alter table stores modify column store_name varchar(50);
alter table stores modify column phone varchar(50);
alter table stores modify column email varchar(50);
alter table stores modify column street varchar(50);
alter table stores modify column city varchar(50);
alter table stores modify column state varchar(50);
alter table stores modify column zip_code varchar(50);

# Order_status update
-- For orders
ALTER TABLE orders MODIFY COLUMN order_status VARCHAR(50);
UPDATE orders
SET order_status = CASE 
    WHEN order_info = '4' THEN 'Delivered'
    WHEN order_info = '3' THEN 'Shipped'
    WHEN order_info = '2' THEN 'Processing'
    WHEN order_info = '1' THEN 'Pending'
    else order_status
END;

#3. Inner Join for Order Details
# Join orders, order_items, and products to display detailed line items.

SELECT 
    o.order_id,
    o.order_date,
    oi.item_id,
    oi.quantity,
    oi.list_price,
    (oi.quantity * oi.list_price) AS total_price,
    p.product_id,
    p.product_name,
    p.model_year,
    p.brand_id,
    p.category_id
FROM orders o
INNER JOIN order_items oi 
    ON o.order_id = oi.order_id
INNER JOIN products p 
    ON oi.product_id = p.product_id
ORDER BY o.order_id, oi.item_id;

#4. Total Sales by Store
#Write a query to group sales (total_price) by each store_id.

select stores.store_id,store_name,round(sum(total_price),2) as Total_sales from stores
inner join orders on stores.store_id=orders.store_id
inner join order_items on orders.order_id=order_items.order_id
group by store_id,store_name;

#5. Top 5 Selling Products
#Use ORDER BY and LIMIT to get the top 5 most sold products by quantity.

select product_id,product_name,sum(quantity) as Total_quantities_sold from order_items
group by product_id,product_name
order by Total_quantities_sold desc
limit 5;

#6. Customer Purchase Summary
#For each customer, return total orders placed, total items purchased,and total revenue.

select customers.customer_id,first_name,last_name,count(distinct orders.order_id) as Total_orders,sum(item_id) as Total_items,
round(sum(total_price),2) as Total_revenue from customers 
inner join orders on customers.customer_id=orders.customer_id 
inner join order_items on orders.order_id=order_items.order_id	
group by customer_id,first_name,last_name;

#7. Segment Customers by Total Spend
#Write a query to classify customers into spending brackets (e.g., low,medium, high).

select
	customers.customer_id,first_name,last_name,
    round(sum(total_price),2) as Total_spent,
    case
		when sum(total_price) >=10000 then 'High'
        when sum(total_price) >=1000 then 'Medium'
        else 'Low'
	end as Customer_segment
from customers inner join orders on customers.customer_id=orders.customer_id
inner join order_items on orders.order_id=order_items.order_id
group by customer_id,first_name,last_name;

#8. Staff Performance Analysis
#Analyze total revenue generated by each staff member based on their handled orders.

select staffs.staff_id,first_name,last_name,count(orders.order_id) as Total_handled_orders,
round(sum(total_price),2) as Total_revenue_generated from staffs
inner join orders on staffs.staff_id=orders.staff_id
inner join order_items on orders.order_id=order_items.order_id
group by staff_id,first_name,last_name;

#9. Stock Alert Query
#Write a query to list products where stock quantity < 10 in any store.

select products.product_id,product_name,sum(quantity) as Total_stocks from stores
inner join stocks on stores.store_id=stocks.store_id
inner join products on stocks.product_id=products.product_id
group by product_id,product_name
having sum(quantity) < 10;

#10.Create Final Segmentation Table
#Create a table customer_segments that will be populated from Python ML results later.

SELECT * FROM `customer segment`;

ALTER TABLE `customer segment`
ADD COLUMN segments VARCHAR(50);

SET SQL_SAFE_UPDATES = 0;
UPDATE `customer segment`
SET type_of_segments = CASE
    WHEN segment = 0 THEN 'at_risk'
    WHEN segment = 1 THEN 'loyal'
    WHEN segment = 2 THEN 'new'
    WHEN segment = 3 THEN 'need_attention'
    ELSE type_of_segments
END;























    
    
    




