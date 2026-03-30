/*
===============================================================================
DDL Script: Bronze Layer Table Creation
===============================================================================

📌 Purpose:
    This script creates all tables required for the Bronze layer of the 
    Data Warehouse using the Medallion Architecture approach.

    The Bronze layer stores raw, unprocessed data exactly as received 
    from source systems such as CRM and ERP.

📌 Key Characteristics of Bronze Layer:
    - No transformations applied (data stored as-is)
    - Maintains source system structure
    - Supports reprocessing and auditing
    - Acts as the foundation for Silver layer transformations

📌 Execution Notes:
    - Existing tables will be dropped and recreated
    - Ensures schema consistency during development
    - Recommended for development/testing environments

⚠️ Warning:
    Dropping tables will permanently delete existing data.
    Ensure backups are taken before running in production.

===============================================================================
*/

-- Ensure correct database context
USE DataWarehouse;
GO

/* =============================================================================
   SECTION 1: CRM SOURCE TABLES
============================================================================= */

-- Table: bronze.crm_cust_info
-- Description: Raw customer data from CRM system
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,            -- Unique customer identifier
    cst_key             NVARCHAR(50),   -- Business key from source system
    cst_firstname       NVARCHAR(50),   -- First name
    cst_lastname        NVARCHAR(50),   -- Last name
    cst_marital_status  NVARCHAR(50),   -- Marital status
    cst_gndr            NVARCHAR(50),   -- Gender
    cst_create_date     DATE            -- Record creation date
);
GO


-- Table: bronze.crm_prd_info
-- Description: Product master data from CRM system
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,            -- Product ID
    prd_key      NVARCHAR(50),   -- Product business key
    prd_nm       NVARCHAR(50),   -- Product name
    prd_cost     INT,            -- Product cost
    prd_line     NVARCHAR(50),   -- Product category/line
    prd_start_dt DATETIME,       -- Product start date
    prd_end_dt   DATETIME        -- Product end date
);
GO


-- Table: bronze.crm_sales_details
-- Description: Sales transaction data from CRM system
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),   -- Order number
    sls_prd_key  NVARCHAR(50),   -- Product key
    sls_cust_id  INT,            -- Customer ID
    sls_order_dt INT,            -- Order date (raw format)
    sls_ship_dt  INT,            -- Shipping date
    sls_due_dt   INT,            -- Due date
    sls_sales    INT,            -- Total sales amount
    sls_quantity INT,            -- Quantity sold
    sls_price    INT             -- Price per unit
);
GO


/* =============================================================================
   SECTION 2: ERP SOURCE TABLES
============================================================================= */

-- Table: bronze.erp_loc_a101
-- Description: Customer location data from ERP system
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),   -- Customer ID
    cntry  NVARCHAR(50)    -- Country
);
GO


-- Table: bronze.erp_cust_az12
-- Description: Customer demographic data from ERP system
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),   -- Customer ID
    bdate  DATE,           -- Birthdate
    gen    NVARCHAR(50)    -- Gender
);
GO


-- Table: bronze.erp_px_cat_g1v2
-- Description: Product category and classification data
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),   -- Product ID
    cat          NVARCHAR(50),   -- Category
    subcat       NVARCHAR(50),   -- Sub-category
    maintenance  NVARCHAR(50)    -- Maintenance type
);
GO


/* =============================================================================
   END OF SCRIPT
===============================================================================

Summary:
    ✔ Created Bronze schema tables
    ✔ Structured raw ingestion layer
    ✔ Ready for Silver layer transformations

Next Steps:
    → Load raw data into Bronze tables
    → Build transformation logic for Silver layer
    → Design analytical models in Gold layer

===============================================================================
*/
