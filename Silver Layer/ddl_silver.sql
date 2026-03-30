/*
===============================================================================
DDL Script: Silver Layer Table Creation
===============================================================================

 Purpose:
    This script creates all tables required for the Silver layer of the 
    Data Warehouse.

    The Silver layer contains cleaned, standardized, and transformed data 
    derived from the Bronze layer.

 Key Characteristics of Silver Layer:
    - Data cleansing and standardization applied
    - Data type corrections (e.g., INT → DATE conversions)
    - Deduplication and normalization
    - Enriched data ready for business logic

 Enhancements Over Bronze Layer:
    - Corrected data types (dates, formats)
    - Additional metadata column: dwh_create_date
    - Improved structure for downstream analytics

 Execution Notes:
    - Existing tables will be dropped and recreated
    - Ensures schema consistency during development

 Warning:
    Dropping tables will permanently delete existing data.
    Ensure backups are taken before running in production.

===============================================================================
*/

USE DataWarehouse;
GO

/* =============================================================================
   SECTION 1: CRM CLEANED TABLES
============================================================================= */

-- Table: silver.crm_cust_info
-- Description: Cleaned and standardized customer data
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,            -- Unique customer ID
    cst_key            NVARCHAR(50),   -- Business key
    cst_firstname      NVARCHAR(50),   -- First name (cleaned)
    cst_lastname       NVARCHAR(50),   -- Last name (cleaned)
    cst_marital_status NVARCHAR(50),   -- Standardized marital status
    cst_gndr           NVARCHAR(50),   -- Standardized gender
    cst_create_date    DATE,           -- Converted to proper DATE format
    dwh_create_date    DATETIME2 DEFAULT GETDATE() -- Record load timestamp
);
GO


-- Table: silver.crm_prd_info
-- Description: Cleaned product master data with category mapping
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,            -- Product ID
    cat_id          NVARCHAR(50),   -- Category ID (derived)
    prd_key         NVARCHAR(50),   -- Product key
    prd_nm          NVARCHAR(50),   -- Product name
    prd_cost        INT,            -- Product cost
    prd_line        NVARCHAR(50),   -- Product line/category
    prd_start_dt    DATE,           -- Start date (converted)
    prd_end_dt      DATE,           -- End date (converted)
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


-- Table: silver.crm_sales_details
-- Description: Cleaned transactional sales data
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),   -- Order number
    sls_prd_key     NVARCHAR(50),   -- Product key
    sls_cust_id     INT,            -- Customer ID
    sls_order_dt    DATE,           -- Converted order date
    sls_ship_dt     DATE,           -- Converted ship date
    sls_due_dt      DATE,           -- Converted due date
    sls_sales       INT,            -- Sales amount
    sls_quantity    INT,            -- Quantity
    sls_price       INT,            -- Price
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/* =============================================================================
   SECTION 2: ERP CLEANED TABLES
============================================================================= */

-- Table: silver.erp_loc_a101
-- Description: Cleaned location data
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),   -- Customer ID
    cntry           NVARCHAR(50),   -- Standardized country
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


-- Table: silver.erp_cust_az12
-- Description: Cleaned customer demographic data
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),   -- Customer ID
    bdate           DATE,           -- Birthdate
    gen             NVARCHAR(50),   -- Standardized gender
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


-- Table: silver.erp_px_cat_g1v2
-- Description: Cleaned product category hierarchy
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),   -- Product ID
    cat             NVARCHAR(50),   -- Category
    subcat          NVARCHAR(50),   -- Sub-category
    maintenance     NVARCHAR(50),   -- Maintenance type
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


/* =============================================================================
   END OF SCRIPT
===============================================================================

Summary:
    ✔ Created Silver layer tables
    ✔ Applied data type standardization
    ✔ Added metadata tracking column
    ✔ Prepared clean data for transformation into Gold layer

Next Steps:
    → Build transformation procedures (Bronze → Silver)
    → Apply joins, deduplication, and business rules
    → Create Gold layer (Star Schema / Analytics)

===============================================================================
*/
