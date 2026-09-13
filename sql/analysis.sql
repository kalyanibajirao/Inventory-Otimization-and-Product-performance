CREATE DATABASE BlueMart_Analytics;
USE BlueMart_Analytics;

CREATE TABLE Customers (
    cust_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(20),
    city VARCHAR(100),
    loyalty_segment VARCHAR(30),
    preferred_channel VARCHAR(30),
    registration_date DATE
);

CREATE TABLE Stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    city VARCHAR(100),
    store_type VARCHAR(50),
    opening_date DATETIME
);

CREATE TABLE SKUs (
    sku_id INT PRIMARY KEY,
    sku_name VARCHAR(200),
    category VARCHAR(100),
    subcategory VARCHAR(100),
    unit_price DECIMAL(12,2),
    cost_price DECIMAL(12,2),
    brand VARCHAR(100),
    profit_per_unit DECIMAL(12,2),
    profit_margin_pct DECIMAL(8,2)
);

CREATE TABLE Promotions (
    promo_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    discount_pct INT,
    promo_type VARCHAR(50),
    promo_id INT PRIMARY KEY,
    promotion_duration_days INT
);

CREATE TABLE Inventory (
    store_id INT,
    sku_id INT,
    stock_on_hand INT,
    reorder_point INT,
    safety_stock INT,
    last_restock_date DATE,
    snapshot_date DATE,
    stock_status VARCHAR(30),

    PRIMARY KEY (
        store_id,
        sku_id,
        snapshot_date
    ),

    FOREIGN KEY (store_id)
        REFERENCES Stores(store_id),

    FOREIGN KEY (sku_id)
        REFERENCES SKUs(sku_id)
);


SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

BULK INSERT Customers
FROM 'C:\Users\kalya\Downloads\PycharmProjects-20260818T143543Z-1-001\Project_01\Product Performance & Inventory Optimization\data\cleaned\bm_Customers_cleaned.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

CREATE TABLE Sales (
    sale_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    date DATE,
    store_id INT,
    sku_id INT,
    customer_id INT NULL,
    quantity INT,
    unit_price DECIMAL(12,2),
    total_value DECIMAL(14,2),
    channel VARCHAR(30),
    discount_pct DECIMAL(5,2),
    calculated_value DECIMAL(14,2),
    value_difference DECIMAL(14,2),
    year INT,
    month INT,
    month_name VARCHAR(20),

    FOREIGN KEY (store_id)
        REFERENCES Stores(store_id),

    FOREIGN KEY (sku_id)
        REFERENCES SKUs(sku_id),

    FOREIGN KEY (customer_id)
        REFERENCES Customers(cust_id)
);

SELECT COUNT(*) AS Total_Customers
FROM Customers;

BULK INSERT Stores
FROM 'C:\Users\kalya\Downloads\PycharmProjects-20260818T143543Z-1-001\Project_01\Product Performance & Inventory Optimization\data\cleaned\bm_stores_cleaned.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
SELECT COUNT(*) AS Total_Stores
FROM Stores;

BULK INSERT SKUs
FROM 'C:\Users\kalya\Downloads\PycharmProjects-20260818T143543Z-1-001\Project_01\Product Performance & Inventory Optimization\data\cleaned\bm_skus_cleaned.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

SELECT COUNT(*) AS Total_SKUs
FROM SKUs

BULK INSERT Inventory
FROM 'C:\Users\kalya\Downloads\PycharmProjects-20260818T143543Z-1-001\Project_01\Product Performance & Inventory Optimization\data\cleaned\bm_inventory_cleaned.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
SELECT COUNT(*) AS Total_Inventory
FROM Inventory;


BULK INSERT Promotions
FROM 'C:\Users\kalya\Downloads\PycharmProjects-20260818T143543Z-1-001\Project_01\Product Performance & Inventory Optimization\data\cleaned\bm_promotions_cleaned.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

SELECT COUNT(*) AS Total_Rows
FROM Promotions;

CREATE TABLE Sales_Staging (
    date DATE,
    store_id INT,
    sku_id INT,
    customer_id INT NULL,
    quantity INT,
    unit_price DECIMAL(12,2),
    total_value DECIMAL(14,2),
    channel VARCHAR(30),
    discount_pct DECIMAL(5,2),
    calculated_value DECIMAL(14,2),
    value_difference DECIMAL(14,2),
    year INT,
    month INT,
    month_name VARCHAR(20)
);

BULK INSERT Sales_Staging
FROM 'C:\Users\kalya\Downloads\bm_sales_cleaned.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);
SELECT COUNT(*) AS Total_Rows
FROM Sales_Staging;

SELECT TOP 10 *
FROM Sales_Staging;

INSERT INTO Sales (
    date,
    store_id,
    sku_id,
    customer_id,
    quantity,
    unit_price,
    total_value,
    channel,
    discount_pct,
    calculated_value,
    value_difference,
    year,
    month,
    month_name
)
SELECT
    date,
    store_id,
    sku_id,
    customer_id,
    quantity,
    unit_price,
    total_value,
    channel,
    discount_pct,
    calculated_value,
    value_difference,
    year,
    month,
    month_name
FROM Sales_Staging;

SELECT COUNT(*) AS Total_Rows
FROM Sales;
SELECT TOP 10 *
FROM Sales
ORDER BY sale_id;