USE Olist_Ecommerce_Analytics;
GO
--IMPORTED ALL THE CSV INTO THE DATABASE---
SELECT * FROM
Customer;
SELECT * FROM
geolocation;
SELECT * FROM
order_items;
SELECT * FROM
order_payments;
SELECT * FROM
order_reviews;
SELECT * FROM
orders;
SELECT * FROM
product_category_name_translation;
SELECT * FROM
products;
SELECT * FROM
sellers;

---VERIFYING THE ROW COUNT---

SELECT 'customer' AS table_name, COUNT(*) AS row_count FROM customer
UNION ALL SELECT 'orders',          COUNT(*) FROM orders
UNION ALL SELECT 'order_items',     COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments',  COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews',   COUNT(*) FROM order_reviews
UNION ALL SELECT 'products',        COUNT(*) FROM products
UNION ALL SELECT 'sellers',         COUNT(*) FROM sellers
UNION ALL SELECT 'geolocation',     COUNT(*) FROM geolocation
UNION ALL SELECT 'category_translation', COUNT(*) FROM product_category_name_translation;

---VERIFYING THE DIFFERENT COLUMNS---

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY TABLE_NAME, ORDINAL_POSITION;

---PRIMARY KEY CHECK------
-- customers (key: customer_id)
SELECT customer_id, COUNT(*) AS cnt
FROM customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

--  orders (key: order_id)
SELECT order_id, COUNT(*) AS cnt
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--  order_items (composite key: order_id + order_item_id)
SELECT order_id, order_item_id, COUNT(*) AS cnt
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

--  order_payments (composite key: order_id + payment_sequential)
SELECT order_id, payment_sequential, COUNT(*) AS cnt
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- order_reviews (key per dictionary: review_id)
SELECT review_id, COUNT(*) AS cnt
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

-- products (key: product_id)
SELECT product_id, COUNT(*) AS cnt
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

--  sellers (key: seller_id)
SELECT seller_id, COUNT(*) AS cnt
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

--  geolocation (key per dictionary: geolocation_zip_code_prefix)
SELECT geolocation_zip_code_prefix, COUNT(*) AS cnt
FROM geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;

--  product_category_name_translation (key: product_category_name)
SELECT product_category_name, COUNT(*) AS cnt
FROM product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;


ALTER TABLE orders ADD CONSTRAINT FK_orders_customer
  FOREIGN KEY (customer_id) REFERENCES Customer(customer_id);

ALTER TABLE order_items ADD CONSTRAINT FK_items_orders
  FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_items ADD CONSTRAINT FK_items_products
  FOREIGN KEY (product_id) REFERENCES products(product_id);

ALTER TABLE order_items ADD CONSTRAINT FK_items_sellers
  FOREIGN KEY (seller_id) REFERENCES sellers(seller_id);

ALTER TABLE order_payments ADD CONSTRAINT FK_payments_orders
  FOREIGN KEY (order_id) REFERENCES orders(order_id);

ALTER TABLE order_reviews ADD CONSTRAINT FK_reviews_orders
  FOREIGN KEY (order_id) REFERENCES orders(order_id);
--- REFRENTIAL INTEGRITY CHECK---
-- orders.customer_id -> customer
SELECT COUNT(*) AS orders_without_customer
FROM orders o
LEFT JOIN customer c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


SELECT TOP 10
    c.customer_city,
    o.order_status,
    p.product_category_name,
    s.seller_state,
    oi.price,
    pay.payment_type
FROM orders o
JOIN Customer c      ON o.customer_id = c.customer_id
JOIN order_items oi  ON o.order_id = oi.order_id
JOIN products p      ON oi.product_id = p.product_id
JOIN sellers s       ON oi.seller_id = s.seller_id
JOIN order_payments pay ON o.order_id = pay.order_id;


SELECT DISTINCT p.product_category_name
FROM products p
LEFT JOIN product_category_name_translation t
  ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL
  AND p.product_category_name IS NOT NULL;

  INSERT INTO product_category_name_translation (product_category_name, product_category_name_english)
VALUES ('pc_gamer', 'pc_gamer'),
       ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers');

	   ALTER TABLE products ADD CONSTRAINT FK_products_category
  FOREIGN KEY (product_category_name)
  REFERENCES product_category_name_translation(product_category_name);

--  order_items.order_id -> orders
SELECT COUNT(*) AS items_without_order
FROM order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

--  order_items.product_id -> products
SELECT COUNT(*) AS items_without_product
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

--  order_items.seller_id -> sellers
SELECT COUNT(*) AS items_without_seller
FROM order_items oi
LEFT JOIN sellers s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- order_payments.order_id -> orders
SELECT COUNT(*) AS payments_without_order
FROM order_payments op
LEFT JOIN orders o ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

--  order_reviews.order_id -> orders
SELECT COUNT(*) AS reviews_without_order
FROM order_reviews r
LEFT JOIN orders o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- customers who never placed an order (expected: 0)
SELECT COUNT(*) AS customers_without_orders
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- orders with no items (expected: 775)
SELECT COUNT(*) AS orders_without_items
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL;

-- orders with no payment (expected: 1)
SELECT COUNT(*) AS orders_without_payment
FROM orders o
LEFT JOIN order_payments op ON o.order_id = op.order_id
WHERE op.order_id IS NULL;

-- orders with no review (expected: 768)
SELECT COUNT(*) AS orders_without_review
FROM orders o
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE r.order_id IS NULL;

-- products never sold (expected: 0)
SELECT COUNT(*) AS products_never_sold
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL;

-- sellers with no items sold (expected: 0)
SELECT COUNT(*) AS sellers_without_items
FROM sellers s
LEFT JOIN order_items oi ON s.seller_id = oi.seller_id
WHERE oi.seller_id IS NULL;


-- single order with no payment
SELECT o.*
FROM orders o
LEFT JOIN order_payments op ON o.order_id = op.order_id
WHERE op.order_id IS NULL;


--categories missing from the translation table

SELECT p.product_category_name, COUNT(*) AS products
FROM products p
WHERE p.product_category_name IS NOT NULL
  AND p.product_category_name NOT IN (SELECT product_category_name
                                      FROM product_category_name_translation)
GROUP BY p.product_category_name;

-- products with no category at all (expected: 610)
-- This is a missing-values issue, kept separate from the translation gap above
SELECT COUNT(*) AS products_without_category
FROM products
WHERE product_category_name IS NULL;

--  translation categories that no product uses (expected: 0)
SELECT COUNT(*) AS unused_translations
FROM product_category_name_translation t
WHERE NOT EXISTS (SELECT 1 FROM products p
                  WHERE p.product_category_name = t.product_category_name);


-- customers whose ZIP is missing (expected: 278 rows, 157 distinct ZIPs)
SELECT COUNT(*) AS customer_rows,
       COUNT(DISTINCT c.customer_zip_code_prefix) AS distinct_zips
FROM customer c
WHERE NOT EXISTS (SELECT 1 FROM geolocation g
                  WHERE g.geolocation_zip_code_prefix = c.customer_zip_code_prefix);

-- sellers whose ZIP is missing (expected: 7 rows, 7 distinct ZIPs)
SELECT COUNT(*) AS seller_rows,
       COUNT(DISTINCT s.seller_zip_code_prefix) AS distinct_zips
FROM sellers s
WHERE NOT EXISTS (SELECT 1 FROM geolocation g
                  WHERE g.geolocation_zip_code_prefix = s.seller_zip_code_prefix);


--  MISSING VALUES CHECK
-- find NULLs and hidden blanks in every table, then decide
-- which gaps are normal and which are data errors.

-- ---------- 5A. NULL counts: tables WITH missing values ----------

--  orders 
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END)             AS approved_nulls,
       SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END)  AS carrier_nulls,
       SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS customer_nulls
FROM orders;

-- order_reviews
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END)   AS title_nulls,
       SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS message_nulls
FROM order_reviews;

--  products 
SELECT COUNT(*) AS total_rows,
       SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END)      AS category_nulls,
       SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END)        AS name_len_nulls,
       SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS desc_len_nulls,
       SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END)         AS photos_nulls,
       SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END)           AS weight_nulls,
       SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END)          AS length_nulls,
       SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END)          AS height_nulls,
       SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END)           AS width_nulls
FROM products;

-- ----------  NULL counts: tables that should be COMPLETE ----

--  customer
SELECT COUNT(*) - COUNT(customer_id)              AS customer_id_nulls,
       COUNT(*) - COUNT(customer_unique_id)       AS unique_id_nulls,
       COUNT(*) - COUNT(customer_zip_code_prefix) AS zip_nulls,
       COUNT(*) - COUNT(customer_city)            AS city_nulls,
       COUNT(*) - COUNT(customer_state)           AS state_nulls
FROM customer;

--  order_items
SELECT COUNT(*) - COUNT(order_id)            AS order_id_nulls,
       COUNT(*) - COUNT(order_item_id)       AS item_id_nulls,
       COUNT(*) - COUNT(product_id)          AS product_nulls,
       COUNT(*) - COUNT(seller_id)           AS seller_nulls,
       COUNT(*) - COUNT(shipping_limit_date) AS ship_limit_nulls,
       COUNT(*) - COUNT(price)               AS price_nulls,
       COUNT(*) - COUNT(freight_value)       AS freight_nulls
FROM order_items;

--  order_payments
SELECT COUNT(*) - COUNT(order_id)             AS order_id_nulls,
       COUNT(*) - COUNT(payment_sequential)   AS seq_nulls,
       COUNT(*) - COUNT(payment_type)         AS type_nulls,
       COUNT(*) - COUNT(payment_installments) AS installments_nulls,
       COUNT(*) - COUNT(payment_value)        AS value_nulls
FROM order_payments;

--  sellers
SELECT COUNT(*) - COUNT(seller_id)              AS seller_id_nulls,
       COUNT(*) - COUNT(seller_zip_code_prefix) AS zip_nulls,
       COUNT(*) - COUNT(seller_city)            AS city_nulls,
       COUNT(*) - COUNT(seller_state)           AS state_nulls
FROM sellers;

--  geolocation
SELECT COUNT(*) - COUNT(geolocation_zip_code_prefix) AS zip_nulls,
       COUNT(*) - COUNT(geolocation_lat)             AS lat_nulls,
       COUNT(*) - COUNT(geolocation_lng)             AS lng_nulls,
       COUNT(*) - COUNT(geolocation_city)            AS city_nulls,
       COUNT(*) - COUNT(geolocation_state)           AS state_nulls
FROM geolocation;

--  product_category_name_translation
SELECT COUNT(*) - COUNT(product_category_name)         AS pt_nulls,
       COUNT(*) - COUNT(product_category_name_english) AS en_nulls
FROM product_category_name_translation;



-- ---------Are the order-date gaps legitimate? (check by order status) ----------

-- nulls per status
SELECT order_status,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END)             AS no_approved_date,
       SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END)  AS no_carrier_date,
       SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS no_customer_date
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
--

--  the delivered orders with a missing date 
SELECT order_id, order_status, order_approved_at,
       order_delivered_carrier_date, order_delivered_customer_date
FROM orders
WHERE order_status = 'delivered'
  AND (order_approved_at IS NULL
       OR order_delivered_carrier_date IS NULL
       OR order_delivered_customer_date IS NULL);
--- Products ----------

--  do the 610 gaps come from the same rows? (expected: 610)
SELECT COUNT(*) AS rows_missing_all_four
FROM products
WHERE product_category_name IS NULL
  AND product_name_lenght IS NULL
  AND product_description_lenght IS NULL
  AND product_photos_qty IS NULL;

-- 5 products with no weight or dimensions (expected: 2 rows)
SELECT *
FROM products
WHERE product_weight_g IS NULL;

-- DATE LOGIC CHECKS
SET DATEFORMAT mdy;   -- source files use month/day/year
GO

-- --------- Current data type of every date column ----------
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE COLUMN_NAME LIKE '%date%' OR COLUMN_NAME LIKE '%timestamp%' OR COLUMN_NAME LIKE '%_at'
ORDER BY TABLE_NAME;

-- -------- Values that fail to convert to a date (expected: 0 everywhere) ----------
SELECT
  SUM(CASE WHEN order_purchase_timestamp      IS NOT NULL AND TRY_CONVERT(datetime2, order_purchase_timestamp)      IS NULL THEN 1 ELSE 0 END) AS bad_purchase,
  SUM(CASE WHEN order_approved_at             IS NOT NULL AND TRY_CONVERT(datetime2, order_approved_at)             IS NULL THEN 1 ELSE 0 END) AS bad_approved,
  SUM(CASE WHEN order_delivered_carrier_date  IS NOT NULL AND TRY_CONVERT(datetime2, order_delivered_carrier_date)  IS NULL THEN 1 ELSE 0 END) AS bad_carrier,
  SUM(CASE WHEN order_delivered_customer_date IS NOT NULL AND TRY_CONVERT(datetime2, order_delivered_customer_date) IS NULL THEN 1 ELSE 0 END) AS bad_customer,
  SUM(CASE WHEN order_estimated_delivery_date IS NOT NULL AND TRY_CONVERT(datetime2, order_estimated_delivery_date) IS NULL THEN 1 ELSE 0 END) AS bad_estimated
FROM orders;

-- ------- Date ranges (do the min and max make sense?) ----------

SELECT 'purchase'  AS col, MIN(TRY_CONVERT(datetime2, order_purchase_timestamp)) AS min_date, MAX(TRY_CONVERT(datetime2, order_purchase_timestamp)) AS max_date FROM orders
UNION ALL SELECT 'approved',   MIN(TRY_CONVERT(datetime2, order_approved_at)),             MAX(TRY_CONVERT(datetime2, order_approved_at))             FROM orders
UNION ALL SELECT 'carrier',    MIN(TRY_CONVERT(datetime2, order_delivered_carrier_date)),  MAX(TRY_CONVERT(datetime2, order_delivered_carrier_date))  FROM orders
UNION ALL SELECT 'customer',   MIN(TRY_CONVERT(datetime2, order_delivered_customer_date)), MAX(TRY_CONVERT(datetime2, order_delivered_customer_date)) FROM orders
UNION ALL SELECT 'estimated',  MIN(TRY_CONVERT(datetime2, order_estimated_delivery_date)), MAX(TRY_CONVERT(datetime2, order_estimated_delivery_date)) FROM orders
UNION ALL SELECT 'shipping_limit', MIN(TRY_CONVERT(datetime2, shipping_limit_date)),       MAX(TRY_CONVERT(datetime2, shipping_limit_date))       FROM order_items
UNION ALL SELECT 'review_created', MIN(TRY_CONVERT(datetime2, review_creation_date)),      MAX(TRY_CONVERT(datetime2, review_creation_date))      FROM order_reviews
UNION ALL SELECT 'review_answered',MIN(TRY_CONVERT(datetime2, review_answer_timestamp)),   MAX(TRY_CONVERT(datetime2, review_answer_timestamp))   FROM order_reviews;

-- ---------- Is the order timeline in the right sequence? ----------
WITH d AS (
  SELECT order_id, order_status,
         TRY_CONVERT(datetime2, order_purchase_timestamp)      AS purchase_dt,
         TRY_CONVERT(datetime2, order_approved_at)             AS approved_dt,
         TRY_CONVERT(datetime2, order_delivered_carrier_date)  AS carrier_dt,
         TRY_CONVERT(datetime2, order_delivered_customer_date) AS customer_dt,
         TRY_CONVERT(datetime2, order_estimated_delivery_date) AS estimated_dt
  FROM orders)
SELECT
  SUM(CASE WHEN approved_dt  < purchase_dt THEN 1 ELSE 0 END) AS approved_before_purchase,   -- expected 0
  SUM(CASE WHEN carrier_dt   < purchase_dt THEN 1 ELSE 0 END) AS carrier_before_purchase,    -- expected 161
  SUM(CASE WHEN carrier_dt   < approved_dt THEN 1 ELSE 0 END) AS carrier_before_approved,    -- expected 1358
  SUM(CASE WHEN customer_dt  < purchase_dt THEN 1 ELSE 0 END) AS customer_before_purchase,   -- expected 0
  SUM(CASE WHEN customer_dt  < approved_dt THEN 1 ELSE 0 END) AS customer_before_approved,   -- expected 61
  SUM(CASE WHEN customer_dt  < carrier_dt  THEN 1 ELSE 0 END) AS customer_before_carrier,    -- expected 23
  SUM(CASE WHEN estimated_dt < purchase_dt THEN 1 ELSE 0 END) AS estimated_before_purchase   -- expected 0
FROM d;

-- look at a sample of the broken rows
SELECT TOP 20 order_id, order_status, order_purchase_timestamp, order_approved_at,
       order_delivered_carrier_date, order_delivered_customer_date
FROM orders
WHERE TRY_CONVERT(datetime2, order_delivered_carrier_date) < TRY_CONVERT(datetime2, order_approved_at);

-- ---------- Dates in other tables ----------

-- shipping_limit_date far outside the data period (expected: 4 rows after 2018, on 3 orders)
SELECT order_id, shipping_limit_date
FROM order_items
WHERE TRY_CONVERT(datetime2, shipping_limit_date) > '2018-12-31'
ORDER BY TRY_CONVERT(datetime2, shipping_limit_date) DESC;

--  review answered before it was created (expected: 0)
SELECT COUNT(*) AS answer_before_creation
FROM order_reviews
WHERE TRY_CONVERT(datetime2, review_answer_timestamp) < TRY_CONVERT(datetime2, review_creation_date);

--  review created before the order was placed (expected: 74)
SELECT COUNT(*) AS review_before_purchase
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
WHERE TRY_CONVERT(datetime2, r.review_creation_date) < TRY_CONVERT(datetime2, o.order_purchase_timestamp);

-- -------- Coverage: orders per month ----------
SELECT FORMAT(TRY_CONVERT(datetime2, order_purchase_timestamp), 'yyyy-MM') AS order_month,
       COUNT(*) AS orders
FROM orders
GROUP BY FORMAT(TRY_CONVERT(datetime2, order_purchase_timestamp), 'yyyy-MM')
ORDER BY order_month;

-- -------- Delivery observations (insight, not necessarily errors) ----------
-- Late deliveries (expected: 7827) and very long deliveries over 100 days (expected: 63)
SELECT
  SUM(CASE WHEN TRY_CONVERT(datetime2, order_delivered_customer_date) > TRY_CONVERT(datetime2, order_estimated_delivery_date) THEN 1 ELSE 0 END) AS late_orders,
  SUM(CASE WHEN DATEDIFF(day, TRY_CONVERT(datetime2, order_purchase_timestamp), TRY_CONVERT(datetime2, order_delivered_customer_date)) > 100 THEN 1 ELSE 0 END) AS over_100_days
FROM orders;

-- STEP 8: TEXT AND CATEGORY CONSISTENCY


-- ---------- Category columns: are the values valid and consistent? ----------

--  order_status (expected: 8 values)

SELECT order_status, COUNT(*) AS orders
FROM orders
GROUP BY order_status
ORDER BY orders DESC;

--  payment_type (expected: 5 values, including not_defined = 3)
SELECT payment_type, COUNT(*) AS payments
FROM order_payments
GROUP BY payment_type
ORDER BY payments DESC;

-- review_score (expected: only 1 to 5)

SELECT review_score, COUNT(*) AS reviews
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

--  state codes 
SELECT 'customer' AS tbl, COUNT(DISTINCT customer_state) AS distinct_states FROM customer
UNION ALL SELECT 'sellers',     COUNT(DISTINCT seller_state)      FROM sellers
UNION ALL SELECT 'geolocation', COUNT(DISTINCT geolocation_state) FROM geolocation;

--  state codes that are not exactly 2 characters (expected: 0)
SELECT
  (SELECT COUNT(*) FROM customer    WHERE DATALENGTH(customer_state)    <> 4) AS cust_bad_state,
  (SELECT COUNT(*) FROM sellers     WHERE DATALENGTH(seller_state)      <> 4) AS seller_bad_state,
  (SELECT COUNT(*) FROM geolocation WHERE DATALENGTH(geolocation_state) <> 4) AS geo_bad_state;

-- ----- City columns ----------

--  leading/trailing spaces (expected: customer 0, sellers 0, geolocation 1)
SELECT
  (SELECT COUNT(*) FROM customer    WHERE DATALENGTH(customer_city)    <> DATALENGTH(LTRIM(RTRIM(customer_city))))    AS cust_space,
  (SELECT COUNT(*) FROM sellers     WHERE DATALENGTH(seller_city)      <> DATALENGTH(LTRIM(RTRIM(seller_city))))      AS seller_space,
  (SELECT COUNT(*) FROM geolocation WHERE DATALENGTH(geolocation_city) <> DATALENGTH(LTRIM(RTRIM(geolocation_city)))) AS geo_space;

--  not all lower case (expected: 0 in all three)
SELECT
  (SELECT COUNT(*) FROM customer    WHERE customer_city    COLLATE Latin1_General_BIN <> LOWER(customer_city))    AS cust_case,
  (SELECT COUNT(*) FROM sellers     WHERE seller_city      COLLATE Latin1_General_BIN <> LOWER(seller_city))      AS seller_case,
  (SELECT COUNT(*) FROM geolocation WHERE geolocation_city COLLATE Latin1_General_BIN <> LOWER(geolocation_city)) AS geo_case;

--  accented / non-ASCII characters
-- 
SELECT
  (SELECT COUNT(*) FROM customer    WHERE customer_city    LIKE '%[^ -~]%' COLLATE Latin1_General_BIN) AS cust_accents,
  (SELECT COUNT(*) FROM sellers     WHERE seller_city      LIKE '%[^ -~]%' COLLATE Latin1_General_BIN) AS seller_accents,
  (SELECT COUNT(*) FROM geolocation WHERE geolocation_city LIKE '%[^ -~]%' COLLATE Latin1_General_BIN) AS geo_accents;

--  digits inside city names (expected: customer 1, sellers 1, geolocation 11)
SELECT
  (SELECT COUNT(*) FROM customer    WHERE customer_city    LIKE '%[0-9]%') AS cust_digits,
  (SELECT COUNT(*) FROM sellers     WHERE seller_city      LIKE '%[0-9]%') AS seller_digits,
  (SELECT COUNT(*) FROM geolocation WHERE geolocation_city LIKE '%[0-9]%') AS geo_digits;

--  seller_city values that are not a clean city name

SELECT seller_id, seller_city, seller_state
FROM sellers
WHERE seller_city LIKE '%[0-9/\@,]%'
   OR seller_city LIKE '% - %'
   OR seller_city LIKE '%(%'
ORDER BY seller_city;

--  ZIP codes that have more than one spelling of the city in geolocation (expected: 8556)
SELECT COUNT(*) AS zips_with_multiple_city_spellings
FROM (SELECT geolocation_zip_code_prefix
      FROM geolocation
      GROUP BY geolocation_zip_code_prefix
      HAVING COUNT(DISTINCT geolocation_city) > 1) x;

-- 8B-7: ZIP codes that map to more than one state in geolocation (expected: 8)
SELECT COUNT(*) AS zips_with_multiple_states
FROM (SELECT geolocation_zip_code_prefix
      FROM geolocation
      GROUP BY geolocation_zip_code_prefix
      HAVING COUNT(DISTINCT geolocation_state) > 1) x;

-- ---------- Coordinates outside Brazil ----------

--  Brazil is roughly lat -33.8 to 5.3 and lng -73.9 to -34.7 (expected: 42 rows)
SELECT COUNT(*) AS points_outside_brazil
FROM geolocation
WHERE geolocation_lat NOT BETWEEN -33.8 AND 5.3
   OR geolocation_lng NOT BETWEEN -73.9 AND -34.7;

-- look at examples
SELECT TOP 10 geolocation_zip_code_prefix, geolocation_lat, geolocation_lng,
       geolocation_city, geolocation_state
FROM geolocation
WHERE geolocation_lat NOT BETWEEN -33.8 AND 5.3
   OR geolocation_lng NOT BETWEEN -73.9 AND -34.7;

-- -------- ZIP prefix format ----------

-- leading zeros lost? (expected: customer 4-digit 23995 / 5-digit 75446)
SELECT LEN(CAST(customer_zip_code_prefix AS VARCHAR(10))) AS zip_length, COUNT(*) AS customers
FROM customer
GROUP BY LEN(CAST(customer_zip_code_prefix AS VARCHAR(10)));

-- ---------- 8E. ID format ----------

-- every ID should be 32 characters (expected: 0 in each)
SELECT
  (SELECT COUNT(*) FROM orders   WHERE LEN(order_id)   <> 32) AS bad_order_id,
  (SELECT COUNT(*) FROM customer WHERE LEN(customer_id) <> 32) AS bad_customer_id,
  (SELECT COUNT(*) FROM products WHERE LEN(product_id) <> 32) AS bad_product_id,
  (SELECT COUNT(*) FROM sellers  WHERE LEN(seller_id)  <> 32) AS bad_seller_id;


/* =====================================================================
   DATA AUDIT SUMMARY: KEY FINDINGS AND OUTCOME
   Dataset : Olist Brazilian E-Commerce (9 tables, about 1.4 million rows in total)
   Scope   : Structure, primary keys, table links, missing values, date logic,
             text and category consistency. No data was changed.

   OUTCOME
   The data is usable but NOT analysis-ready. The core order tables (orders,
   order_items, customer, products, sellers) are structurally sound: keys are
   unique, all table links work, and there are no orphan records. The problems
   are concentrated in three areas: geolocation, order timestamps, and a few
   key columns that do not behave as the data dictionary says.

   KEY FINDINGS

   1. Geolocation is the weakest table
      - 261,836 rows (26%) are exact duplicates.
      - ZIP prefix cannot be a primary key: 17,972 of 19,015 ZIPs repeat.
      - 8,556 ZIPs have more than one spelling of the city; 8 map to two states.
      - 73,442 city names have accents, while customer and seller cities have
        none, so joining on city would fail.
      - 42 coordinates fall outside Brazil.
      Impact: joining customers or sellers to geolocation on ZIP without
      cleaning first would multiply rows and inflate every count and revenue figure.

   2. order_reviews.review_id is not a valid primary key
      - 789 review IDs repeat (814 extra rows), so (review_id, order_id)
        is the real key.

   3. Order timestamps are not always in a logical sequence
      - 1,358 orders were handed to the carrier before approval, and 161 before
        the order was even placed.
      - 61 orders were delivered before approval, and 23 before carrier handover.
      - 74 reviews were created before the order was placed.
      - Delivery-time metrics must exclude or flag these rows.

   4. Missing values
      - Most are legitimate (comment fields, undelivered orders).
      - Real errors: 14 delivered orders have no approval date, 2 no carrier
        date, 8 no customer delivery date.
      - 610 products have no category, name length, description length or
        photo count (all missing together).

   5. Orders that do not follow the normal pattern
      - 775 orders have no items (mostly unavailable and canceled; 1 shipped).
      - 1 delivered order has no payment record.
      - Revenue should therefore be taken from order_items, not order_payments.

   6. Smaller data quality issues
      - 13 products belong to 2 categories with no English translation.
      - 278 customers and 7 sellers have a ZIP missing from geolocation.
      - seller_city has about 25 messy values (for example 'sao paulo / sao paulo',
        'sbc/sp', an email address, a number).
      - payment_type has 3 rows with the value 'not_defined'.
      - 4 shipping_limit_date values fall in 2020, outside the data period.
      - Data dictionary errors: payment key, misspelled column names
        (lenght), and review text length.

   WHAT IS CLEAN
      - Unique keys: customer, orders, order_items, order_payments, products, sellers.
      - All 6 foreign-key links hold (no orphans).
      - All date values convert correctly; no approval before purchase.
      - Valid values for order_status and review_score; state codes are clean.

   NOTES FOR ANALYSIS
      - Count customers by customer_unique_id (96,096 people vs 99,441 customer_ids).
      - Orders cover Sep 2016 to Oct 2018; Nov 2016 is missing and Sep/Oct 2018
        are almost empty, so use full months only.
      - 7,827 orders arrived after the estimated date (an insight, not an error).



   
   ===================================================================== */
/*=============================================================================
  SECTION 1 — CLEANING VIEWS
  These views do not alter raw tables. Re-run safely with CREATE OR ALTER VIEW.
=============================================================================*/

-- 3A. Geolocation view:
--   * DISTINCT removes only exact duplicate combinations across selected fields.
--   * Text is trimmed and standardized to lowercase/uppercase.
--   * Coordinate issues are flagged, not deleted.
-- Note: multiple rows per ZIP prefix may remain.
CREATE OR ALTER VIEW dbo.vw_geolocation_clean AS
SELECT DISTINCT
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    LOWER(NULLIF(LTRIM(RTRIM(geolocation_city)), '')) AS geolocation_city,
    UPPER(NULLIF(LTRIM(RTRIM(geolocation_state)), '')) AS geolocation_state,
    CASE
        WHEN geolocation_lat IS NULL OR geolocation_lng IS NULL THEN 'Missing coordinate'
        WHEN geolocation_lat NOT BETWEEN -33.8 AND 5.3
          OR geolocation_lng NOT BETWEEN -73.9 AND -34.7 THEN 'Review coordinate'
        ELSE 'Within screening bounds'
    END AS coordinate_quality_status
FROM dbo.geolocation;
GO

--   * Normalize city/state text for grouping.
--   * Keep customer_id and customer_unique_id distinct: they serve different purposes.
CREATE OR ALTER VIEW dbo.vw_customer_clean AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    LOWER(NULLIF(LTRIM(RTRIM(customer_city)), '')) AS customer_city,
    UPPER(NULLIF(LTRIM(RTRIM(customer_state)), '')) AS customer_state
FROM dbo.Customer;
GO

-- 3D. Product view:
--   * Standardize category formatting and convert empty strings to NULL.
--   * Preserve missing measurements and misspelled source column names as imported.
--   * Do not invent missing product details.
CREATE OR ALTER VIEW dbo.vw_products_clean AS
SELECT
    product_id,
    LOWER(NULLIF(LTRIM(RTRIM(product_category_name)), '')) AS product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM dbo.products;
GO

-- 3E. Category translation view:
--   * Trim category labels and convert blank labels to NULL.
--   * Does not create or guess translations.
CREATE OR ALTER VIEW dbo.vw_category_translation_clean AS
SELECT
    LOWER(NULLIF(LTRIM(RTRIM(product_category_name)), '')) AS product_category_name,
    LOWER(NULLIF(LTRIM(RTRIM(product_category_name_english)), '')) AS product_category_name_english
FROM dbo.product_category_name_translation;
GO

-- 3F. Orders view:
--   * TRY_CONVERT safely parses date/time values.
--   * Invalid strings become NULL in the view and can be audited separately.
--   * Delivery status is derived only when both actual and estimated dates exist.
--   * Missing delivery dates are not assumed to mean zero days or a failed order.
CREATE OR ALTER VIEW dbo.vw_orders_clean AS
SELECT
    order_id,
    customer_id,
    order_status,
    TRY_CONVERT(datetime2, order_purchase_timestamp) AS purchase_datetime,
    TRY_CONVERT(datetime2, order_approved_at) AS approved_datetime,
    TRY_CONVERT(datetime2, order_delivered_carrier_date) AS carrier_datetime,
    TRY_CONVERT(datetime2, order_delivered_customer_date) AS delivered_datetime,
    TRY_CONVERT(datetime2, order_estimated_delivery_date) AS estimated_delivery_datetime,
    CASE
        WHEN order_delivered_customer_date IS NULL
          OR order_estimated_delivery_date IS NULL THEN 'Not assessable'
        WHEN TRY_CONVERT(datetime2, order_delivered_customer_date) IS NULL
          OR TRY_CONVERT(datetime2, order_estimated_delivery_date) IS NULL THEN 'Not assessable'
        WHEN TRY_CONVERT(datetime2, order_delivered_customer_date)
           > TRY_CONVERT(datetime2, order_estimated_delivery_date) THEN 'Late'
        ELSE 'On time or early'
    END AS delivery_status
FROM dbo.orders;
GO

-- 3G. Order items view:
--   * Convert shipping limit date for consistent date analysis.
--   * Preserve price and freight values without changing monetary values.
CREATE OR ALTER VIEW dbo.vw_order_items_clean AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    TRY_CONVERT(datetime2, shipping_limit_date) AS shipping_limit_datetime,
    price,
    freight_value
FROM dbo.order_items;
GO

-- 3H. Reviews view:
--   * Trim review text and convert empty strings to NULL.
--   * Keep every row; do not deduplicate based on review_id alone.
--   * Convert review timestamps for analysis.
CREATE OR ALTER VIEW dbo.vw_order_reviews_clean AS
SELECT
    review_id,
    order_id,
    review_score,
    NULLIF(LTRIM(RTRIM(review_comment_title)), '') AS review_comment_title,
    NULLIF(LTRIM(RTRIM(review_comment_message)), '') AS review_comment_message,
    TRY_CONVERT(datetime2, review_creation_date) AS review_creation_datetime,
    TRY_CONVERT(datetime2, review_answer_timestamp) AS review_answer_datetime
FROM dbo.order_reviews;
GO
--   * Does not create or guess translations.
CREATE OR ALTER VIEW dbo.vw_category_translation_clean AS
SELECT
    LOWER(NULLIF(LTRIM(RTRIM(product_category_name)), '')) AS product_category_name,
    LOWER(NULLIF(LTRIM(RTRIM(product_category_name_english)), '')) AS product_category_name_english
FROM dbo.product_category_name_translation;
GO

-- 3F. Orders view:
--   * TRY_CONVERT safely parses date/time values.
--   * Invalid strings become NULL in the view and can be audited separately.
--   * Delivery status is derived only when both actual and estimated dates exist.
--   * Missing delivery dates are not assumed to mean zero days or a failed order.
CREATE OR ALTER VIEW dbo.vw_orders_clean AS
SELECT
    order_id,
    customer_id,
    order_status,
    TRY_CONVERT(datetime2, order_purchase_timestamp) AS purchase_datetime,
    TRY_CONVERT(datetime2, order_approved_at) AS approved_datetime,
    TRY_CONVERT(datetime2, order_delivered_carrier_date) AS carrier_datetime,
    TRY_CONVERT(datetime2, order_delivered_customer_date) AS delivered_datetime,
    TRY_CONVERT(datetime2, order_estimated_delivery_date) AS estimated_delivery_datetime,
    CASE
        WHEN order_delivered_customer_date IS NULL
          OR order_estimated_delivery_date IS NULL THEN 'Not assessable'
        WHEN TRY_CONVERT(datetime2, order_delivered_customer_date) IS NULL
          OR TRY_CONVERT(datetime2, order_estimated_delivery_date) IS NULL THEN 'Not assessable'
        WHEN TRY_CONVERT(datetime2, order_delivered_customer_date)
           > TRY_CONVERT(datetime2, order_estimated_delivery_date) THEN 'Late'
        ELSE 'On time or early'
    END AS delivery_status
FROM dbo.orders;
GO

-- 3G. Order items view:
--   * Convert shipping limit date for consistent date analysis.
--   * Preserve price and freight values without changing monetary values.
CREATE OR ALTER VIEW dbo.vw_order_items_clean AS
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    TRY_CONVERT(datetime2, shipping_limit_date) AS shipping_limit_datetime,
    price,
    freight_value
FROM dbo.order_items;
GO

-- 3H. Reviews view:
--   * Trim review text and convert empty strings to NULL.
--   * Keep every row; do not deduplicate based on review_id alone.
--   * Convert review timestamps for analysis.
CREATE OR ALTER VIEW dbo.vw_order_reviews_clean AS
SELECT
    review_id,
    order_id,
    review_score,
    NULLIF(LTRIM(RTRIM(review_comment_title)), '') AS review_comment_title,
    NULLIF(LTRIM(RTRIM(review_comment_message)), '') AS review_comment_message,
    TRY_CONVERT(datetime2, review_creation_date) AS review_creation_datetime,
    TRY_CONVERT(datetime2, review_answer_timestamp) AS review_answer_datetime
FROM dbo.order_reviews;
GO

-- 3I. Payments view:
--   * Normalize payment type text and flag unspecified values.
--   * Preserve payment values and installments unchanged.
CREATE OR ALTER VIEW dbo.vw_order_payments_clean AS
SELECT
    order_id,
    payment_sequential,
    LOWER(NULLIF(LTRIM(RTRIM(payment_type)), '')) AS payment_type,
    payment_installments,
    payment_value,
    CASE
        WHEN payment_type IS NULL OR LTRIM(RTRIM(payment_type)) = '' THEN 'Missing type'
        WHEN LOWER(LTRIM(RTRIM(payment_type))) = 'not_defined' THEN 'Unspecified type'
        ELSE 'Specified type'
    END AS payment_type_quality_status
FROM dbo.order_payments;
GO
USE Olist_Ecommerce_Analytics;
GO

SELECT
    DB_NAME() AS current_database,
    OBJECT_ID('dbo.vw_sellers_clean', 'V') AS view_object_id;

CREATE OR ALTER VIEW dbo.vw_sellers_clean AS
SELECT
    seller_id,
    seller_zip_code_prefix,
    LOWER(NULLIF(LTRIM(RTRIM(seller_city)), '')) AS seller_city,
    UPPER(NULLIF(LTRIM(RTRIM(seller_state)), '')) AS seller_state
FROM dbo.sellers;
GO

/*=============================================================================
  SECTION 2 — VALIDATE CLEANING VIEWS
=============================================================================*/

-- 4A. Confirm raw and view row counts.
-- Geolocation may have fewer rows because exact duplicate rows are collapsed.
SELECT 'Customer raw' AS object_name, COUNT_BIG(*) AS row_count FROM dbo.Customer
UNION ALL SELECT 'Customer clean view', COUNT_BIG(*) FROM dbo.vw_customer_clean
UNION ALL SELECT 'Sellers raw', COUNT_BIG(*) FROM dbo.sellers
UNION ALL SELECT 'Sellers clean view', COUNT_BIG(*) FROM dbo.vw_sellers_clean
UNION ALL SELECT 'Products raw', COUNT_BIG(*) FROM dbo.products
UNION ALL SELECT 'Products clean view', COUNT_BIG(*) FROM dbo.vw_products_clean
UNION ALL SELECT 'Orders raw', COUNT_BIG(*) FROM dbo.orders
UNION ALL SELECT 'Orders clean view', COUNT_BIG(*) FROM dbo.vw_orders_clean
UNION ALL SELECT 'Order items raw', COUNT_BIG(*) FROM dbo.order_items
UNION ALL SELECT 'Order items clean view', COUNT_BIG(*) FROM dbo.vw_order_items_clean
UNION ALL SELECT 'Reviews raw', COUNT_BIG(*) FROM dbo.order_reviews
UNION ALL SELECT 'Reviews clean view', COUNT_BIG(*) FROM dbo.vw_order_reviews_clean
UNION ALL SELECT 'Payments raw', COUNT_BIG(*) FROM dbo.order_payments
UNION ALL SELECT 'Payments clean view', COUNT_BIG(*) FROM dbo.vw_order_payments_clean
UNION ALL SELECT 'Geolocation raw', COUNT_BIG(*) FROM dbo.geolocation
UNION ALL SELECT 'Geolocation clean view', COUNT_BIG(*) FROM dbo.vw_geolocation_clean;
GO

-- 4B. Confirm the clean views contain no blank city labels where source was blank.
SELECT 'Customer' AS table_name, COUNT_BIG(*) AS blank_city_rows
FROM dbo.vw_customer_clean WHERE customer_city IS NULL
UNION ALL
SELECT 'Sellers', COUNT_BIG(*) FROM dbo.vw_sellers_clean WHERE seller_city IS NULL
UNION ALL
SELECT 'Geolocation', COUNT_BIG(*) FROM dbo.vw_geolocation_clean WHERE geolocation_city IS NULL;
GO

-- 4C. Review flagged geolocation rows.
SELECT coordinate_quality_status, COUNT_BIG(*) AS row_count
FROM dbo.vw_geolocation_clean
GROUP BY coordinate_quality_status
ORDER BY row_count DESC;
GO

-- 4D. Review missing product category values after standardization.
SELECT COUNT_BIG(*) AS products_without_category
FROM dbo.vw_products_clean
WHERE product_category_name IS NULL;
GO

-- 4E. Review date conversion failures in the source orders table.
-- Non-NULL source values that cannot convert are possible invalid values.
SELECT
    SUM(CASE WHEN order_purchase_timestamp IS NOT NULL
              AND TRY_CONVERT(datetime2, order_purchase_timestamp) IS NULL THEN 1 ELSE 0 END) AS bad_purchase_dates,
    SUM(CASE WHEN order_approved_at IS NOT NULL
              AND TRY_CONVERT(datetime2, order_approved_at) IS NULL THEN 1 ELSE 0 END) AS bad_approval_dates,
    SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL
              AND TRY_CONVERT(datetime2, order_delivered_carrier_date) IS NULL THEN 1 ELSE 0 END) AS bad_carrier_dates,
    SUM(CASE WHEN order_delivered_customer_date IS NOT NULL
              AND TRY_CONVERT(datetime2, order_delivered_customer_date) IS NULL THEN 1 ELSE 0 END) AS bad_delivery_dates,
    SUM(CASE WHEN order_estimated_delivery_date IS NOT NULL
              AND TRY_CONVERT(datetime2, order_estimated_delivery_date) IS NULL THEN 1 ELSE 0 END) AS bad_estimated_dates
FROM dbo.orders;
GO

-- 4F. Recheck repeated review/order combinations after text/date view creation.
-- The view preserves rows; this query is diagnostic only.
SELECT review_id, order_id, COUNT_BIG(*) AS occurrences
FROM dbo.vw_order_reviews_clean
GROUP BY review_id, order_id
HAVING COUNT_BIG(*) > 1
ORDER BY occurrences DESC;
GO

/*=============================================================================
  SECTION 3 — SAFE GEOGRAPHIC JOIN PATTERN
  The geolocation view can still have multiple rows per ZIP prefix because ZIP
  prefixes are not unique. Aggregate to one row per ZIP before joining when
  approximate mapping coordinates are needed. This CTE is illustrative and
  does not create or modify a table.
=============================================================================*/
;WITH GeoByZip AS
(
    SELECT
        geolocation_zip_code_prefix,
        AVG(geolocation_lat) AS average_latitude,
        AVG(geolocation_lng) AS average_longitude
    FROM dbo.vw_geolocation_clean
    WHERE coordinate_quality_status = 'Within screening bounds'
    GROUP BY geolocation_zip_code_prefix
)
SELECT TOP (100)
    c.customer_id,
    c.customer_city,
    c.customer_state,
    g.average_latitude,
    g.average_longitude
FROM dbo.vw_customer_clean AS c
LEFT JOIN GeoByZip AS g
  ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;
GO
/*==============================================================
  OLIST E-COMMERCE ANALYTICS
  SQL EXPLORATORY DATA ANALYSIS (EDA)
  Database: Olist_Ecommerce_Analytics
  Platform: Microsoft SQL Server
==============================================================*/


/*==============================================================
  SECTION 1: OVERALL BUSINESS PERFORMANCE
==============================================================*/

-- 1.1 Overall order and customer-record counts

SELECT
    COUNT(*) AS total_order_records,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(DISTINCT customer_id) AS unique_customer_records
FROM dbo.orders;


-- 1.2 Order distribution by status

SELECT
    order_status,
    COUNT(DISTINCT order_id) AS total_orders,
    CAST(
        COUNT(DISTINCT order_id) * 100.0 /
        NULLIF(
            (SELECT COUNT(DISTINCT order_id)
             FROM dbo.orders), 0
        )
        AS DECIMAL(5,2)
    ) AS percentage_of_orders
FROM dbo.orders
GROUP BY order_status
ORDER BY total_orders DESC;


/*==============================================================
  SECTION 2: MONTHLY ORDER TRENDS
==============================================================*/

-- 2.1 Monthly order volume

SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;


-- 2.2 Monthly sales revenue and order volume
-- Revenue here means item price only, excluding freight.
-- Aggregate order_items before joining to avoid row multiplication.

WITH OrderSales AS (
    SELECT
        order_id,
        SUM(price) AS item_revenue
    FROM dbo.order_items
    GROUP BY order_id
)
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    COUNT(DISTINCT o.order_id) AS orders_with_items,
    SUM(os.item_revenue) AS total_item_revenue
FROM dbo.orders AS o
INNER JOIN OrderSales AS os
    ON o.order_id = os.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;


/*==============================================================
  SECTION 3: REVENUE AND AVERAGE ORDER VALUE
==============================================================*/

-- 3.1 Overall sales KPIs
-- AOV denominator includes orders represented in order_items.

WITH OrderSales AS (
    SELECT
        order_id,
        SUM(price) AS item_revenue
    FROM dbo.order_items
    GROUP BY order_id
)
SELECT
    COUNT(*) AS orders_with_items,
    SUM(item_revenue) AS total_item_revenue,
    AVG(item_revenue) AS average_order_value,
    SUM(item_revenue) / NULLIF(COUNT(*), 0)
        AS calculated_average_order_value
FROM OrderSales;


-- 3.2 Monthly average order value

WITH OrderSales AS (
    SELECT
        order_id,
        SUM(price) AS item_revenue
    FROM dbo.order_items
    GROUP BY order_id
)
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    COUNT(*) AS orders_with_items,
    SUM(os.item_revenue) AS total_item_revenue,
    AVG(os.item_revenue) AS average_order_value
FROM dbo.orders AS o
INNER JOIN OrderSales AS os
    ON o.order_id = os.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;


/*==============================================================
  SECTION 4: PRODUCT CATEGORY ANALYSIS
==============================================================*/

-- 4.1 Revenue and units sold by category

SELECT
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    COUNT(*) AS item_records,
    SUM(oi.order_item_id * 0 + 1) AS units_sold,
    SUM(oi.price) AS total_item_revenue,
    SUM(oi.freight_value) AS total_freight_value
FROM dbo.order_items AS oi
INNER JOIN dbo.products AS p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY total_item_revenue DESC;


-- 4.2 Top 10 product categories by item revenue

SELECT TOP (10)
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    SUM(oi.price) AS total_item_revenue,
    COUNT(*) AS item_records
FROM dbo.order_items AS oi
INNER JOIN dbo.products AS p
    ON oi.product_id = p.product_id
LEFT JOIN dbo.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    )
ORDER BY total_item_revenue DESC;


/*==============================================================
  SECTION 5: SELLER PERFORMANCE
==============================================================*/

-- 5.1 Seller revenue and item volume

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(*) AS item_records,
    COUNT(DISTINCT oi.order_id) AS orders_served,
    SUM(oi.price) AS total_item_revenue,
    SUM(oi.freight_value) AS total_freight_value
FROM dbo.sellers AS s
INNER JOIN dbo.order_items AS oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_item_revenue DESC;


-- 5.2 Top 10 sellers by item revenue

SELECT TOP (10)
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS orders_served,
    SUM(oi.price) AS total_item_revenue
FROM dbo.sellers AS s
INNER JOIN dbo.order_items AS oi
    ON s.seller_id = oi.seller_id
GROUP BY
    s.seller_id,
    s.seller_city,
    s.seller_state
ORDER BY total_item_revenue DESC;


/*==============================================================
  SECTION 6: CUSTOMER ANALYSIS
==============================================================*/

-- 6.1 Customer distribution by state

SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM dbo.Customer AS c
INNER JOIN dbo.orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY unique_customers DESC;


-- 6.2 Repeat-purchase analysis
-- Counts distinct orders per customer_unique_id.
-- Includes all statuses; consider delivered-only analysis separately.

WITH CustomerOrders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM dbo.Customer AS c
    INNER JOIN dbo.orders AS o
        ON c.customer_id = o.customer_id
    WHERE c.customer_unique_id IS NOT NULL
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS unique_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        AS repeat_customers,
    CAST(
        SUM(CASE WHEN order_count > 1 THEN 1.0 ELSE 0 END)
        * 100.0 / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS repeat_customer_percentage
FROM CustomerOrders;


/*==============================================================
  SECTION 7: PAYMENT ANALYSIS
==============================================================*/

-- 7.1 Payment method distribution
-- Counts payment records, not unique orders.

SELECT
    payment_type,
    COUNT(*) AS payment_records,
    COUNT(DISTINCT order_id) AS orders_using_method,
    SUM(payment_value) AS total_recorded_payment_value,
    AVG(payment_value) AS average_payment_record_value
FROM dbo.order_payments
GROUP BY payment_type
ORDER BY total_recorded_payment_value DESC;


-- 7.2 Payment installments

SELECT
    payment_installments,
    COUNT(*) AS payment_records,
    SUM(payment_value) AS total_payment_value
FROM dbo.order_payments
GROUP BY payment_installments
ORDER BY payment_installments;


/*==============================================================
  SECTION 8: DELIVERY PERFORMANCE
==============================================================*/

-- 8.1 Average delivery time for delivered orders
-- DATEDIFF uses calendar-day boundaries.

SELECT
    COUNT(*) AS delivered_orders_with_dates,
    AVG(
        CAST(
            DATEDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date
            ) AS DECIMAL(10,2)
        )
    ) AS average_purchase_to_delivery_days
FROM dbo.orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp;


-- 8.2 Late deliveries versus estimated delivery date

SELECT
    COUNT(*) AS delivered_orders_with_both_dates,
    SUM(
        CASE
            WHEN order_delivered_customer_date >
                 order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS late_delivered_orders,
    SUM(
        CASE
            WHEN order_delivered_customer_date <=
                 order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS on_time_or_early_orders,
    CAST(
        SUM(
            CASE
                WHEN order_delivered_customer_date >
                     order_estimated_delivery_date
                THEN 1.0 ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage
FROM dbo.orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_estimated_delivery_date IS NOT NULL;


-- 8.3 Delivery performance by order purchase month

SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    MONTH(order_purchase_timestamp) AS order_month,
    COUNT(*) AS delivered_orders_with_dates,
    AVG(
        CAST(
            DATEDIFF(
                DAY,
                order_purchase_timestamp,
                order_delivered_customer_date
            ) AS DECIMAL(10,2)
        )
    ) AS average_delivery_days
FROM dbo.orders
WHERE order_status = 'delivered'
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;


/*==============================================================
  SECTION 9: CUSTOMER REVIEW ANALYSIS
==============================================================*/

-- 9.1 Review score distribution

SELECT
    review_score,
    COUNT(*) AS review_records,
    CAST(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*)
                FROM dbo.order_reviews
                WHERE review_score IS NOT NULL), 0)
        AS DECIMAL(5,2)
    ) AS percentage_of_reviews
FROM dbo.order_reviews
WHERE review_score IS NOT NULL
GROUP BY review_score
ORDER BY review_score;


-- 9.2 Average review score

SELECT
    COUNT(*) AS reviews_with_scores,
    AVG(CAST(review_score AS DECIMAL(10,2)))
        AS average_review_score
FROM dbo.order_reviews
WHERE review_score IS NOT NULL;


-- 9.3 Average review score by delivery timing
-- First aggregate review records to one row per order to avoid
-- multiplying order rows when joining reviews.

WITH ReviewByOrder AS (
    SELECT
        order_id,
        AVG(CAST(review_score AS DECIMAL(10,2)))
            AS average_order_review_score
    FROM dbo.order_reviews
    WHERE review_score IS NOT NULL
    GROUP BY order_id
)
SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        WHEN o.order_delivered_customer_date <=
             o.order_estimated_delivery_date
        THEN 'On time or early'
        ELSE 'Missing delivery date'
    END AS delivery_timing,
    COUNT(*) AS orders_with_reviews,
    AVG(r.average_order_review_score) AS average_review_score
FROM dbo.orders AS o
INNER JOIN ReviewByOrder AS r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        WHEN o.order_delivered_customer_date <=
             o.order_estimated_delivery_date
        THEN 'On time or early'
        ELSE 'Missing delivery date'
    END
ORDER BY delivery_timing;


/*==============================================================
  SECTION 10: FINAL RECONCILIATION CHECKS
==============================================================*/

-- 10.1 Compare total item revenue with total recorded payment value.
-- These are different measures and may not match exactly.

SELECT
    (SELECT SUM(price)
     FROM dbo.order_items) AS total_item_revenue,
    (SELECT SUM(payment_value)
     FROM dbo.order_payments) AS total_recorded_payment_value,
    (SELECT SUM(freight_value)
     FROM dbo.order_items) AS total_item_freight;


-- 10.2 Check whether any order items lack a matching order.

SELECT
    COUNT(*) AS unmatched_item_records
FROM dbo.order_items AS oi
LEFT JOIN dbo.orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 10.3 Check whether any order items lack a matching product.

SELECT
    COUNT(*) AS unmatched_product_item_records
FROM dbo.order_items AS oi
LEFT JOIN dbo.products AS p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- 10.4 Check whether any order items lack a matching seller.

SELECT
    COUNT(*) AS unmatched_seller_item_records
FROM dbo.order_items AS oi
LEFT JOIN dbo.sellers AS s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


/*==============================================================
  END OF SQL EDA SCRIPT
==============================================================*/