--KPIs pfcustomer interactions 
-- KPI 1: Email Subscription Rate
SELECT 
    (SUM(CASE WHEN email_subscriptions = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS Email_Subscription_Rate
FROM customer_interaction;

--KPI 2: High App Usage Percentage
SELECT 
    (SUM(CASE WHEN app_usage = 'High' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS High_App_Usage_Percentage
FROM customer_interaction;

--KPI 3: Average Website Visits
SELECT 
    AVG(CAST(website_visits AS FLOAT)) AS Avg_Website_Visits
FROM customer_interaction;
 -- KPI 4: H Social Media Engagement Percentage
SELECT
    ROUND(SUM(CASE WHEN social_media_engagement = 'Low' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Low_Engagement_Percentage,
    ROUND(SUM(CASE WHEN social_media_engagement = 'Medium' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Medium_Engagement_Percentage,
    ROUND(SUM(CASE WHEN social_media_engagement = 'High' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS High_Engagement_Percentage
FROM customer_interaction;

--KPI 5: Customer Support Calls per Website Visit
SELECT 
    AVG(CAST(customer_support_calls AS FLOAT)) AS Avg_Support_Calls_Per_Customer
FROM customer_interaction;
--------------------------------------------------------------------------
-- KPIs for Seasonal Data

-- 1. Seasonal Sales Variation
SELECT 
    s.season,
    CASE 
        WHEN s.holiday_season = 1 THEN 'Yes'
        WHEN s.holiday_season = 0 THEN 'No'
    END AS holiday_season,
    YEAR(t.transaction_Date_only) AS year,
    SUM(t.quantity * sd.unit_price) AS total_revenue
FROM 
    seasonal_temporal s 
    JOIN transactional_data t ON t.transaction_id = s.transaction_id 
    JOIN sales_data sd ON sd.transaction_id = t.transaction_id
GROUP BY 
    s.season, s.holiday_season, YEAR(t.transaction_Date_only)
ORDER BY 
    year, s.season;
--2. Peak Season Performance

SELECT 
    st.season,
    CASE 
        WHEN st.holiday_season = 1 THEN 'Yes'
        WHEN st.holiday_season = 0 THEN 'No'
    END AS holiday_season,
    YEAR(t.transaction_Date_only) AS year,
    SUM(sd.total_sales) AS revenue,
    SUM(sd.revenues) AS profit,
    AVG(cb.avg_items_per_transaction) AS customer_activity
FROM 
    Seasonal_Temporal st
    JOIN Transactional_Data t ON st.transaction_id = t.transaction_id
    JOIN Sales_Data sd ON st.transaction_id = sd.transaction_id
    JOIN Customer_Behavior cb ON st.customer_id = cb.customer_id
WHERE 
    st.holiday_season = 1
GROUP BY 
    st.season,
    st.holiday_season,
    YEAR(t.transaction_Date_only)
ORDER BY 
    year, st.season;

--3. Inventory Turnover by Season
SELECT st.holiday_season, SUM(sd.total_items_purchased) as items_sold
FROM Seasonal_Temporal st
JOIN Sales_Data sd ON st.transaction_id = sd.transaction_id
GROUP BY st.holiday_season;


--4. Seasonal Customer Demand Trends

SELECT 
    CASE 
        WHEN st.holiday_season = 1 THEN 'Yes'
        WHEN st.holiday_season = 0 THEN 'No'
    END AS holiday_season,
    SUM(sd.total_items_purchased) * 1.0 / SUM(sd.total_transactions) AS avg_items,
    COUNT(CASE WHEN cb.purchase_frequency = 'daily' THEN 1 END) AS daily_count,
    COUNT(CASE WHEN cb.purchase_frequency = 'weekly' THEN 1 END) AS weekly_count,
    COUNT(CASE WHEN cb.purchase_frequency = 'monthly' THEN 1 END) AS monthly_count,
    COUNT(CASE WHEN cb.purchase_frequency = 'yearly' THEN 1 END) AS yearly_count
FROM 
    Seasonal_Temporal st
    JOIN Sales_Data sd ON st.transaction_id = sd.transaction_id
    JOIN Customer_Behavior cb ON st.customer_id = cb.customer_id
GROUP BY 
    st.holiday_season
ORDER BY 
    st.holiday_season;

--5. Marketing ROI by Season
SELECT st.holiday_season, SUM(sd.revenues) as campaign_revenue
FROM Seasonal_Temporal st
JOIN Transactional_Data td ON st.transaction_id = td.transaction_id
JOIN Sales_Data sd ON st.transaction_id = sd.transaction_id
WHERE td.promotion_id IS NOT NULL
GROUP BY st.holiday_season;

----------------------

----------------------------------------------------
---- KPIs for sales analysis
--Total sales amount for each customer over the last year 
select c.customer_id,s.total_sales
from customer_info c
left join sales_data  s
on c.customer_id = s.customer_id
left join transactional_data t
on s.customer_id = t.customer_id
where t.transaction_Date_only <'1,jan,2021'

--Total number of transactions made by each customer.
select c.customer_id, s.total_transactions
from customer_info c
left join sales_data  s
on c.customer_id = s.customer_id

--Total number of items purchased by each customer.
select c.customer_id,s.total_items_purchased
from sales_data s
left join customer_info c
on s.customer_id = c.customer_id

--Total discounts received by each customer 
select c.customer_id ,s.total_discounts_received 
from sales_data  s
left join customer_info c
on s.customer_id = c.customer_id
----------------------------------------------------------
--KPIs for promotional analysis
--Measures how successful a promotion is in driving sales.
select promotion_id,promotion_type,promotion_effectiveness
from promotional_data
order by promotion_effectiveness desc;

-- how successful promotional campaigns are in achieving their goals.
select promotion_effectiveness,count(*) as Number_of_promotion 
from promotional_data
group by promotion_effectiveness
order by Number_of_promotion desc;

-- determine the number of promotional offers targeted to each audience category.
select promotion_target_audience,COUNT(*) as number_of_promotions
from promotional_data
group by promotion_target_audience;

--Measures how many customers were exposed to and engaged with a promotion.
select promotion_id, count(distinct customer_id) as engaged_customers
from promotional_data
group by promotion_id
order by engaged_customers DESC;

--Analyzes how many customers used a given discount or promotional offer.
select COUNT(t.customer_id) as customer_used_promotion
from transactional_data t
left join promotional_data p
on t.promotion_id = p.promotion_id
where p.promotion_type = 'Flash Sale'

--Examines whether promotional activities encourage repeat purchases.
select customer_id,count(transaction_id)as total_purchase
from transactional_data t 
where t.transaction_id is not null
group by customer_id

--Evaluates if promotions drive additional purchases of related or premium products.
select p.promotion_type, count(t.transaction_id) as total_transactions
from transactional_data t
left join promotional_data p 
on t.promotion_id = p.promotion_id
group by p.promotion_type
---------------------------------------------
-- Measures the total number of units produced 
select sum(quantity) as [Total produced units]
from transactional_data 



--Compares actual output to expected output based on resources used.
select 
sd.transaction_id,
sd.total_transactions,
td.quantity as [Actual output],
(td.quantity * 5 ) as [Expected output],
((td.quantity *5) - td.quantity) as [Output difference]
from sales_data sd 
join transactional_data td
on sd.transaction_id = td.transaction_id



--Measures the amount of products that fail to meet customer expectations
select product_id,product_name ,count(product_id) as [Products failed to meet customer expectations]
from product_info
where product_rating < 2.5
group by product_id , product_name 
order by product_id asc



-- Measures production responsiveness and customer satisfaction
SELECT 
    pf.product_id,
    pf.product_name,
    pf.product_rating,  
    COUNT(td.transaction_id) AS Total_Orders 
FROM product_info pf
JOIN transactional_data td 
ON td.product_id = pf.product_id
WHERE pf.product_rating > 2.5 
GROUP BY pf.product_id , pf.product_name, pf.product_rating
order by pf.product_rating desc



--Optimizes resource allocation and planning.
SELECT 
    pf.product_id,
    pf.product_name,
    pf.product_rating,
    COUNT(td.transaction_id) AS [Total Orders],
    SUM(td.quantity) AS [Total Quantity Sold]
FROM product_info pf
JOIN transactional_data td ON td.product_id = pf.product_id
GROUP BY pf.product_id, pf.product_name, pf.product_rating
ORDER BY [Total Orders] DESC



--Measures the mean value of all customer purchases.
SELECT 
    AVG(sd.unit_price * td.quantity) AS [Average purchase value]
FROM transactional_data td
JOIN sales_data sd 
ON td.transaction_id = sd.transaction_id



--Identifies which product categories generate the most sales volume.
SELECT 
    td.product_category AS [Product category],
    SUM(td.quantity) AS [Total units sold],
    SUM(td.quantity * sd.unit_price) AS [Total sales amount]
FROM transactional_data td
JOIN sales_data sd 
ON td.transaction_id = sd.transaction_id
JOIN product_info pf 
ON td.product_id = pf.product_id
GROUP BY td.product_category
order by [Total sales amount] desc



--Calculates the average number of items purchased per transaction.
SELECT 
    SUM(quantity) * 1.0 / COUNT(DISTINCT transaction_id) AS [Average items per transaction]
FROM transactional_data



--Tracks how often customers use discounts in their purchases.
SELECT 
    COUNT(td.transaction_id) AS Total_Transactions,
    COUNT(td.discount_applied) AS Discounted_Transactions
FROM transactional_data td
WHERE discount_applied IS NOT NULL



--Measures revenue generated at each store location.
select 
gd.store_city  as [Store location],
sum(sd.Revenues) as [Total revenues]
from geographical_data gd
join sales_data sd
on gd.customer_id = sd.customer_id
group by [store_city]



--Analyses the share of payment methods used across all transactions.
SELECT 
    payment_method,
    COUNT(*) AS [Total Used]
FROM transactional_data
GROUP BY payment_method


--Pinpoints the time of day when sales activity is highest.
SELECT 
    (transaction_Date_time_only) AS [Sale Hour],
    COUNT(*) AS Total_Transactions
FROM transactional_data
GROUP BY (transaction_Date_time_only)
ORDER BY Total_Transactions DESC

------------------------------------------------------------------------------
-- KPIS of customer information

-- 1. Customer Retention Rate (past 12 months)

SELECT
    COUNT(DISTINCT CASE WHEN last_purchase_date >= DATEADD(year, -1, GETDATE()) THEN customer_id END) * 1.0
    / NULLIF(COUNT(DISTINCT customer_id), 0) AS retention_rate
FROM customer_behavior;


-- 2. Churn Rate

SELECT
    COUNT(DISTINCT CASE WHEN churned = 1 THEN customer_id END) * 1.0
    / NULLIF(COUNT(DISTINCT customer_id), 0) AS churn_rate
FROM customer_info;


-- 3. Customer Lifetime Value (CLV)

SELECT
    s.customer_id,
    SUM(s.total_sales) AS total_sales,
    ci.membership_years,
    SUM(s.total_sales) * 1.0 / NULLIF(ci.membership_years, 0) AS clv
FROM sales_data s
JOIN customer_info ci ON s.customer_id = ci.customer_id
GROUP BY s.customer_id, ci.membership_years;


-- 4. Customer Segmentation

SELECT
    customer_id,
    CASE
        WHEN income_bracket = 'High' AND loyalty_program = 1 THEN 'High-Value Loyal'
        WHEN income_bracket = 'High' THEN 'High-Value'
        WHEN loyalty_program = 1 THEN 'Loyal'
        ELSE 'Standard'
    END AS segment
FROM customer_info;


-- 5. Loyalty Program Effectiveness


SELECT 
    COUNT(DISTINCT c.customer_id) AS numberofcustomer,
    COUNT(DISTINCT c.loyalty_program) AS loyalty_members,
    COUNT(t.transaction_id) AS [total transaction]
FROM 
    customer_info c 
LEFT JOIN 
    transactional_data t ON c.customer_id = t.customer_id;


-- 6. New vs. Returning Customers (last 30 days)


WITH customer_activity AS (
    SELECT 
        customer_id,
        MIN(last_purchase_date) AS first_purchase,
        MAX(last_purchase_date) AS last_purchase
    FROM customer_behavior
    GROUP BY customer_id
)
SELECT
    CASE 
        WHEN first_purchase >= DATEADD(day, -30, GETDATE()) THEN 'New'
        ELSE 'Returning'
    END AS customer_type,
    COUNT(DISTINCT customer_id) AS customer_count,
    AVG(DATEDIFF(day, first_purchase, GETDATE())) AS avg_days_active
FROM customer_activity
GROUP BY 
    CASE 
        WHEN first_purchase >= DATEADD(day, -30, GETDATE()) THEN 'New'
        ELSE 'Returning'
    END;
	WITH customer_first_purchases AS (
    SELECT 
        customer_id,
        MIN(last_purchase_date) AS first_purchase_date
    FROM customer_behavior
    GROUP BY customer_id
)
SELECT
    CASE 
        WHEN first_purchase_date >= DATEADD(day, -30, GETDATE()) THEN 'New (≤30 days)'
        WHEN first_purchase_date >= DATEADD(day, -90, GETDATE()) THEN 'Recent (31-90 days)'
        ELSE 'Established (>90 days)'
    END AS customer_type,
    COUNT(DISTINCT customer_id) AS customer_count,
    COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM customer_first_purchases) AS percentage
FROM customer_first_purchases
GROUP BY 
    CASE 
        WHEN first_purchase_date >= DATEADD(day, -30, GETDATE()) THEN 'New (≤30 days)'
        WHEN first_purchase_date >= DATEADD(day, -90, GETDATE()) THEN 'Recent (31-90 days)'
        ELSE 'Established (>90 days)'
    END
ORDER BY 
    MIN(first_purchase_date);

	-- 7. Customer Engagement Score

	SELECT 
    c.customer_id,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(CASE WHEN t.promotion_id IS NOT NULL THEN 1 ELSE 0 END) AS promousagecount
FROM
    customer_info c
LEFT JOIN 
    transactional_data t ON c.customer_id = t.customer_id
GROUP BY 
    c.customer_id
ORDER BY
    total_transactions DESC;


---------------------------------------------------------
-- B. CUSTOMER BEHAVIOR KPIs
-- ------------------------------------------------------------------------------------------------

-- 1. Average Purchase Value
CREATE OR ALTER VIEW vw_AvgPurchaseValue AS
SELECT
    customer_id,
    AVG(total_sales) AS avg_purchase_value
FROM sales_data
GROUP BY customer_id;

-- 2. Purchase Frequency
CREATE OR ALTER VIEW vw_PurchaseFrequency AS
SELECT
    s.customer_id,
    COUNT(*) * 1.0 / NULLIF(DATEDIFF(day, MIN(transaction_Date_only), GETDATE()),0) AS purchases_per_day
FROM sales_data s JOIN transactional_data t ON s.transaction_id = t.transaction_id
GROUP BY s.customer_id;

-- 3. Time Since Last Purchase
CREATE OR ALTER VIEW vw_DaysSinceLastPurchase AS
SELECT
    s.customer_id,
    DATEDIFF(day, MAX(transaction_Date_only), GETDATE()) AS days_since_last
FROM sales_data s join transactional_data t on s.transaction_id = t.transaction_id
GROUP BY s.customer_id;

-- 4. Average Discount Used
CREATE OR ALTER VIEW vw_AvgDiscountUsed AS
SELECT
    customer_id,
    AVG(CAST(REPLACE(discount_applied, '%', '') AS DECIMAL(5,2)) / 100.0) AS avg_discount
FROM transactional_data
GROUP BY customer_id;

-- 5. Preferred Store Location
CREATE OR ALTER VIEW vw_PreferredStore AS
SELECT DISTINCT
    customer_id,
    FIRST_VALUE(store_location) OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS preferred_store
FROM transactional_data
GROUP BY customer_id, store_location;

-- 6. Total Number of Purchases
CREATE OR ALTER VIEW vw_TotalPurchases AS
SELECT
    customer_id,
    SUM(online_purchases + in_store_purchases) AS total_purchases
FROM customer_behavior
GROUP BY customer_id;

-- 7. Average Items per Transaction
CREATE OR ALTER VIEW vw_AvgItemsPerTransaction AS
SELECT
    customer_id,
    AVG(avg_items_per_transaction) AS avg_items
FROM customer_behavior
GROUP BY customer_id;

-- 8. Average Transaction Value
CREATE OR ALTER VIEW vw_AvgTransactionValue AS
SELECT
    customer_id,
    SUM(total_sales) * 1.0 / NULLIF(COUNT(*),0) AS avg_txn_value
FROM sales_data
GROUP BY customer_id;
----------------------------------------------------------------------------
-- H. GEOGRAPHIC KPIs
-- ------------------------------------------------------------------------------------------------

-- 1. Sales by Region / City / Store Location
CREATE OR ALTER VIEW vw_SalesByLocation AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    SUM(s.total_sales) AS total_revenue
FROM sales_data s
JOIN geographical_data g ON s.location_id = g.location_id
GROUP BY g.store_state, g.store_city, g.location_id;

-- 2. Customer Density by Location
CREATE OR ALTER VIEW vw_CustomerDensity AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    COUNT(DISTINCT s.customer_id) AS unique_customers
FROM sales_data s
JOIN geographical_data g ON s.location_id = g.location_id
GROUP BY g.store_state, g.store_city, g.location_id;

-- 3. Revenue per Store Location
CREATE OR ALTER VIEW vw_RevenuePerStore AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    SUM(s.total_sales) * 1.0 / NULLIF(COUNT(DISTINCT g.location_id),0) AS avg_revenue_per_store
FROM sales_data s
JOIN geographical_data g ON s.location_id = g.location_id
GROUP BY g.store_state, g.store_city, g.location_id;

-- 4. Return Rate by Region
CREATE OR ALTER VIEW vw_ReturnRateByRegion AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    SUM(s.total_returned_items) * 1.0 / NULLIF(SUM(s.total_items_purchased),0) AS return_rate
FROM sales_data s
JOIN geographical_data g ON s.location_id = g.location_id
GROUP BY g.store_state, g.store_city, g.location_id;

-- 5. Average Purchase Value by Region
CREATE OR ALTER VIEW vw_AvgPurchaseValueByRegion AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    SUM(s.total_sales) * 1.0 / NULLIF(SUM(s.total_transactions),0) AS avg_purchase_value
FROM sales_data s
JOIN geographical_data g ON s.location_id = g.location_id
GROUP BY g.store_state, g.store_city, g.location_id;

-- 6. Online vs. Offline Sales by Region
CREATE OR ALTER VIEW vw_OnlineVsOfflineByRegion AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    SUM(CASE WHEN t.store_location = 'Online' THEN s.total_sales ELSE 0 END) AS online_sales,
    SUM(CASE WHEN t.store_location <> 'Online' THEN s.total_sales ELSE 0 END) AS in_store_sales
FROM sales_data s
JOIN transactional_data t ON s.transaction_id = t.transaction_id
JOIN geographical_data g ON s.location_id = g.location_id
GROUP BY g.store_state, g.store_city, g.location_id;

-- 7. Product Preferences by Region
CREATE OR ALTER VIEW vw_ProductPreferencesByRegion AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    t.product_id,
    COUNT(*) AS purchase_count
FROM sales_data s
JOIN geographical_data g ON s.location_id = g.location_id join transactional_data t on t.transaction_id = s.transaction_id
GROUP BY g.store_state, g.store_city, g.location_id, t.product_id;

-- 8. Store Visit Frequency by Location
CREATE OR ALTER VIEW vw_VisitFrequencyByLocation AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    AVG(s.total_transactions) AS avg_visits_per_customer
FROM sales_data s
JOIN geographical_data g ON s.customer_id = g.customer_id
GROUP BY g.store_state, g.store_city, g.location_id;

-- 9. Marketing Campaign Response by Region
CREATE OR ALTER VIEW vw_CampaignResponseByRegion AS
SELECT
    g.store_state,
    g.store_city,
    g.location_id,
    COUNT(DISTINCT p.customer_id) AS exposed_customers,
    COUNT(DISTINCT CASE WHEN s.total_sales > 0 THEN p.customer_id END) AS converted_customers,
    CAST(COUNT(DISTINCT CASE WHEN s.total_sales > 0 THEN p.customer_id END) * 1.0 / NULLIF(COUNT(DISTINCT p.customer_id),0) AS DECIMAL(5,4)) AS conversion_rate
FROM promotional_data p
JOIN geographical_data g ON p.customer_id = g.customer_id
LEFT JOIN sales_data s ON p.customer_id = s.customer_id
GROUP BY g.store_state, g.store_city, g.location_id;

