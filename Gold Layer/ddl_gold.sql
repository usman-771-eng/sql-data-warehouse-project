/*
===============================================================================
DDL Script: Gold Layer (Star Schema Views)
===============================================================================

 Purpose:
    This script creates analytical views for the Gold layer of the 
    Data Warehouse.

    The Gold layer represents the final business-ready data model using
    a Star Schema design (Dimensions + Fact table).

 Key Features:
    - Surrogate keys for dimensions
    - Business-friendly column naming
    - Enriched data via joins across Silver layer
    - Optimized for reporting and analytics tools (Power BI, Tableau)

 Data Model:
    - Dimension Tables:
        → dim_customers
        → dim_products

    - Fact Table:
        → fact_sales

 Usage:
    SELECT * FROM gold.fact_sales;
    SELECT * FROM gold.dim_customers;
    SELECT * FROM gold.dim_products;

===============================================================================
*/

USE DataWarehouse;
GO

/* =============================================================================
   DIMENSION 1: CUSTOMERS
============================================================================= */

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key, -- Surrogate Key

    ci.cst_id              AS customer_id,
    ci.cst_key             AS customer_number,
    ci.cst_firstname       AS first_name,
    ci.cst_lastname        AS last_name,

    la.cntry               AS country,

    ci.cst_marital_status  AS marital_status,

    CASE 
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END                    AS gender,

    ca.bdate               AS birthdate,
    ci.cst_create_date     AS create_date

FROM silver.crm_cust_info ci

LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;
GO


/* =============================================================================
   DIMENSION 2: PRODUCTS
============================================================================= */

IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,

    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,

    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance_type,

    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date

FROM silver.crm_prd_info pn

LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id

WHERE pn.prd_end_dt IS NULL; -- Keep only active products
GO


/* =============================================================================
   FACT TABLE: SALES
============================================================================= */

IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,

    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,

    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,

    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price

FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;
GO


/* =============================================================================
   END OF SCRIPT
===============================================================================

Summary:
    ✔ Created Customer Dimension (dim_customers)
    ✔ Created Product Dimension (dim_products)
    ✔ Created Sales Fact Table (fact_sales)
    ✔ Implemented Star Schema
    ✔ Enabled analytics-ready dataset

Business Value:
    → Enables KPI reporting (Revenue, Sales, Customers)
    → Supports BI tools (Power BI, Tableau)
    → Simplifies complex joins into a clean model

Next Steps:
    → Connect to Power BI
    → Build dashboards (Sales Trends, Customer Insights)
    → Add indexes / performance tuning if needed

===============================================================================
*/
