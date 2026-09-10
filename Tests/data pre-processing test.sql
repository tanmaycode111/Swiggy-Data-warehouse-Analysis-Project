use SwiggyDataWarehouse;
-- DUPLICATE ROWS
select * from
(select 
*,
row_number() over (partition by state,
                city,
                order_date,
                restaurant_name,
                location,
                category,
                dish_name,
                price,
                rating,
                rating_count order by dwh_create_date) as rn 
 from
bronze.swiggy_data)t where rn>1;


-- NULL VALUE 
select 
coalesce(rating_count,0) from 
bronze.swiggy_data
where rating_count is null;

-- UNWANTED SPACE
select state
from bronze.swiggy_data
where state != Trim(state);

select city
from bronze.swiggy_data
where city != Trim(city);

select restaurant_name
from bronze.swiggy_data
where restaurant_name != Trim(restaurant_name);


select category
from bronze.swiggy_data
where category != Trim(category);

select dish_name
from bronze.swiggy_data
where dish_name != Trim(dish_name);

-- data validation
select price 
from bronze.swiggy_data
where price < 0; -- no negative data

select price 
from bronze.swiggy_data
where price > 10000;  -- data under the range

select rating 
from bronze.swiggy_data
where rating < 0;   -- no negative data

select rating 
from bronze.swiggy_data  -- data under the range
where rating > 5;


