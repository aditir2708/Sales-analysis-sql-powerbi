-- ============================================
--  DATABASE SETUP
-- ============================================

CREATE database prj;
USE prj;

-- ============================================
--  DATA LOADING
-- ============================================

-- Load CSV data into table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/train.csv'
INTO TABLE salestore
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Check system settings (optional)
SHOW VARIABLES LIKE 'secure_file_priv';
SHOW VARIABLES LIKE 'local_infile';
SELECT COUNT(*) FROM salestore;
DESCRIBE salestore;

-- ============================================
-- 🧹 DATA CLEANING
-- ============================================

ALTER TABLE salestore RENAME COLUMN `customer name` TO cus_name;
ALTER TABLE salestore RENAME COLUMN `sub-category` TO sub_category;
ALTER TABLE salestore RENAME COLUMN `Ship Mode` TO ship_mode;

CREATE VIEW sum_sale_proname AS
SELECT SUM(sales), product_name
FROM salestore
GROUP BY product_name;



-- ============================================
--  DATE TRANSFORMATION
-- ============================================

-- Preview date conversion
SELECT 
STR_TO_DATE(
    REPLACE(`order date`, '/', '-'),
    '%d-%m-%Y'
) AS order_date,
sales
FROM salestore;

-- Handle multiple date formats
SELECT 
COALESCE(
    STR_TO_DATE(REPLACE(`Order Date`, '/', '-'), '%d-%m-%Y'),
    STR_TO_DATE(REPLACE(`Order Date`, '/', '-'), '%m-%d-%Y'),
    STR_TO_DATE(REPLACE(`Order Date`, '/', '-'), '%Y-%m-%d')
) AS order_date
FROM salestore;

-- Add new column for cleaned date
ALTER TABLE salestore 
ADD COLUMN order_date DATE;

-- Update with cleaned date
UPDATE salestore
SET order_date = COALESCE(
    STR_TO_DATE(REPLACE(`Order Date`, '/', '-'), '%d-%m-%Y'),
    STR_TO_DATE(REPLACE(`Order Date`, '/', '-'), '%m-%d-%Y'),
    STR_TO_DATE(REPLACE(`Order Date`, '/', '-'), '%Y-%m-%d')
);

-- Drop old column
ALTER TABLE salestore DROP COLUMN `Order Date`;

-- ============================================
--  ANALYSIS VIEWS
-- ============================================

-- Sales over time (Year-Month)
CREATE VIEW sale_over_time AS
SELECT 
YEAR(order_date) as year,
MONTH(order_date) AS month,
SUM(sales) AS total_sales
FROM salestore
GROUP BY year, month
ORDER BY year, month;

-- Top states by sales
CREATE VIEW topstate_sale AS
SELECT state, SUM(sales) AS total_sales
FROM salestore
GROUP BY state
ORDER BY total_sales DESC;

-- Top cities by sales
CREATE VIEW topcity_sale AS
SELECT city, SUM(sales) AS total_sales
FROM salestore
GROUP BY city
ORDER BY total_sales DESC;

-- Sales by category and sub-category
CREATE VIEW sale_by_category AS
SELECT category, sub_category, SUM(sales) AS total_sales
FROM salestore
GROUP BY category, sub_category
ORDER BY category, total_sales DESC;

-- Total Products by Sales
CREATE VIEW sale_by_product AS
SELECT product_name, SUM(sales) AS total_sales
FROM salestore
GROUP BY product_name
ORDER BY total_sales DESC;

-- Sales by region
CREATE VIEW sale_by_region AS
SELECT region, SUM(sales) as total_sales
FROM salestore
GROUP BY region
ORDER BY total_sales DESC;

-- Sales by segment
CREATE VIEW sale_by_segment AS
SELECT segment, SUM(sales) AS total_sales
FROM salestore
GROUP BY segment
ORDER BY total_sales DESC;

-- Customer distribution by segment
CREATE VIEW cus_distribution_bysegment AS
SELECT segment, COUNT(cus_name) AS total_customers
FROM salestore
GROUP BY segment
ORDER BY segment;

-- Top customers by total sales
SELECT cus_name, SUM(sales) AS total_sales
FROM salestore
GROUP BY cus_name
ORDER BY total_sales DESC;

-- Sales by shipping mode
CREATE VIEW sale_shipmode AS
SELECT ship_mode, SUM(sales) AS total_sales
FROM salestore
GROUP BY ship_mode
ORDER BY total_sales DESC;

