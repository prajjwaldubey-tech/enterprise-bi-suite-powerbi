-- ============================================================================
-- SCRIPT: 01_star_schema_architecture.sql
-- PROJECT: Enterprise BI Suite (DA-01)
-- PURPOSE: Kimball Star Schema DDL, Constraints, Seed Data & Analytical Audit
-- ============================================================================

-- 1. DROP EXISTING TABLES (CLEAN SLATE)
DROP TABLE IF EXISTS FactResellerSales CASCADE;
DROP TABLE IF EXISTS DimProduct CASCADE;
DROP TABLE IF EXISTS DimGeography CASCADE;
DROP TABLE IF EXISTS DimDate CASCADE;

-- 2. CREATE CONFORMED DIMENSIONS
CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    DayNumberOfMonth INT NOT NULL,
    MonthName VARCHAR(15) NOT NULL,
    MonthNumberOfYear INT NOT NULL,
    FiscalQuarter INT NOT NULL,
    FiscalYear INT NOT NULL
);

CREATE TABLE DimGeography (
    GeographyKey INT PRIMARY KEY,
    Country VARCHAR(50) NOT NULL,
    Region VARCHAR(50) NOT NULL,
    SalesTerritoryGroup VARCHAR(50) NOT NULL
);

CREATE TABLE DimProduct (
    ProductKey INT PRIMARY KEY,
    ProductSKU VARCHAR(50) NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    ProductCategory VARCHAR(50) NOT NULL,
    StandardCost NUMERIC(12, 2) NOT NULL,
    ListPrice NUMERIC(12, 2) NOT NULL
);

-- 3. CREATE CENTRAL FACT TABLE
CREATE TABLE FactResellerSales (
    SalesOrderNumber VARCHAR(30) NOT NULL,
    SalesOrderLineNumber INT NOT NULL,
    DateKey INT NOT NULL REFERENCES DimDate(DateKey),
    GeographyKey INT NOT NULL REFERENCES DimGeography(GeographyKey),
    ProductKey INT NOT NULL REFERENCES DimProduct(ProductKey),
    OrderQuantity INT NOT NULL,
    UnitPrice NUMERIC(12, 2) NOT NULL,
    ExtendedAmount NUMERIC(12, 2) NOT NULL,
    TotalProductCost NUMERIC(12, 2) NOT NULL,
    GrossProfit NUMERIC(12, 2) NOT NULL,
    CONSTRAINT PK_FactResellerSales PRIMARY KEY (SalesOrderNumber, SalesOrderLineNumber)
);

-- 4. PERFORMANCE INDEXING
CREATE INDEX idx_fact_date ON FactResellerSales(DateKey);
CREATE INDEX idx_fact_geography ON FactResellerSales(GeographyKey);
CREATE INDEX idx_fact_product ON FactResellerSales(ProductKey);

-- 5. SEED REPRESENTATIVE DATA
INSERT INTO DimDate (DateKey, FullDate, DayNumberOfMonth, MonthName, MonthNumberOfYear, FiscalQuarter, FiscalYear)
VALUES 
(20251015, '2025-10-15', 15, 'October', 10, 4, 2025),
(20251110, '2025-11-10', 10, 'November', 11, 4, 2025);

INSERT INTO DimGeography (GeographyKey, Country, Region, SalesTerritoryGroup)
VALUES 
(1, 'United States', 'Northwest', 'North America'),
(2, 'Canada', 'Ontario', 'North America'),
(3, 'France', 'Ile-de-France', 'Europe'),
(4, 'Germany', 'Bavaria', 'Europe'),
(5, 'Mexico', 'Central', 'North America');

INSERT INTO DimProduct (ProductKey, ProductSKU, ProductName, ProductCategory, StandardCost, ListPrice)
VALUES 
(101, 'BK-M18B-42', 'Mountain-100 Black, 42', 'Bikes', 1898.09, 3374.99),
(102, 'BK-R93R-62', 'Road-150 Red, 62', 'Bikes', 2171.29, 3578.27);

INSERT INTO FactResellerSales (SalesOrderNumber, SalesOrderLineNumber, DateKey, GeographyKey, ProductKey, OrderQuantity, UnitPrice, ExtendedAmount, TotalProductCost, GrossProfit)
VALUES 
('SO43897', 1, 20251015, 1, 101, 10, 3374.99, 33749.90, 18980.90, 14769.00),
('SO43898', 1, 20251015, 3, 102, 5, 3578.27, 17891.35, 10856.45, 7034.90);

-- 6. ANALYTICAL AUDIT QUERY (DASHBOARD REPLICATION)
SELECT 
    g.Country,
    SUM(f.ExtendedAmount) AS TotalSales,
    SUM(f.TotalProductCost) AS TotalCOGS,
    SUM(f.GrossProfit) AS GrossProfit,
    ROUND((SUM(f.GrossProfit) / NULLIF(SUM(f.ExtendedAmount), 0)) * 100, 2) AS GrossMarginPct
FROM FactResellerSales f
JOIN DimGeography g ON f.GeographyKey = g.GeographyKey
GROUP BY g.Country
ORDER BY TotalSales DESC;
