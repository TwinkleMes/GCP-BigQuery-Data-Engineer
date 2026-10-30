-- GCP Query


SELECT COUNT(*) AS total_records
FROM `twinkle-bigquery-practice.ecommerce_dataset.orders`;

-- Task 1 – Remove duplicate orders
CREATE OR REPLACE VIEW
`twinkle-bigquery-practice.ecommerce_dataset.clean_orders` AS

SELECT DISTINCT *
FROM `twinkle-bigquery-practice.ecommerce_dataset.orders`;

-- Verify duplicate removal
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Task 2 – Calculate Net Revenue

SELECT SUM(quantity * unit_price) AS net_revenue
FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`
WHERE LOWER(status) =  'delivereed';

-- Task 3: Find the Top 3 Products in Each Region


SELECT
    region,
    product,
    SUM(quantity * unit_price) AS total_revenue,

    DENSE_RANK() OVER (
        PARTITION BY region
        ORDER BY SUM(quantity * unit_price) DESC
    ) AS product_rank

FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`

WHERE LOWER(status) = 'delivered'

GROUP BY region, product

QUALIFY product_rank <= 3

ORDER BY region, product_rank;



-- Task 4: Identify Inactive Customers

SELECT
    customer_id,
    MAX(order_date) AS last_purchase_date

FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`

WHERE status = 'Delivered'

GROUP BY customer_id

HAVING MAX(order_date) < DATE_SUB(
    CURRENT_DATE(),
    INTERVAL 6 MONTH
)

ORDER BY last_purchase_date;

-- Task 5: Find Customers Who Purchase Continuously for 3 Months




SELECT
    customer_id,
    COUNT(DISTINCT FORMAT_DATE('%Y-%m', order_date)) AS total_months

FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`

WHERE status = 'Delivered'

AND order_date BETWEEN DATE '2026-01-01'
AND DATE '2026-03-31'

GROUP BY customer_id

HAVING COUNT(DISTINCT FORMAT_DATE('%Y-%m', order_date)) = 3;



--Task 6  build a customer lifetime value report


SELECT
    customer_id,
    SUM(quantity * unit_price) AS lifetime_value

FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`

WHERE status = 'Delivered'

GROUP BY customer_id

ORDER BY lifetime_value DESC;




-- Task 7 Find Monthly Sales



SELECT
    FORMAT_DATE('%Y-%m', order_date) AS sales_month,

    SUM(quantity * unit_price) AS monthly_sales

FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`

WHERE status = 'Delivered'

GROUP BY sales_month

ORDER BY sales_month;





--Task 8 - Find products with a unit price below ₹10,000 in a particular month.

SELECT
    order_id,
    product,
    unit_price,
    order_date
FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`
WHERE unit_price < 10000
  AND order_date BETWEEN DATE '2026-01-01'
                     AND DATE '2026-01-31';



--Task 9: Find customers who purchased a particular product multiple times in 6 months

SELECT
    customer_id,
    product,
    COUNT(*) AS purchase_count
FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`
WHERE LOWER(product) = 'laptop'
  AND order_date BETWEEN DATE '2026-01-01'
                     AND DATE '2026-06-30'
  AND LOWER(status) = 'delivered'
GROUP BY customer_id, product
HAVING COUNT(*) > 1
ORDER BY purchase_count DESC;


-- Task 10 : Total sales report for each product in a particular month 


SELECT
    product,
    SUM(quantity * unit_price) AS total_sales
FROM `twinkle-bigquery-practice.ecommerce_dataset.clean_orders`
WHERE LOWER(status) = 'delivered'
  AND order_date BETWEEN DATE '2026-01-01'
                     AND DATE '2026-01-31'
GROUP BY product
ORDER BY total_sales DESC;




