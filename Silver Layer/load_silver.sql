/*
===============================================================================
Stored Procedure: Silver Layer Load (Bronze → Silver)
===============================================================================

 Purpose:
    This stored procedure performs ETL (Extract, Transform, Load) operations
    to move data from Bronze layer into Silver layer.

 Transformation Logic:
    - Data Cleaning (TRIM, NULL handling)
    - Standardization (Gender, Marital Status, Country)
    - Deduplication using ROW_NUMBER()
    - Data Type Conversion (INT → DATE)
    - Business Rule Application
    - Derived Columns (Category ID, Price Fixing, etc.)

 Load Strategy:
    - Full Load (TRUNCATE + INSERT)

 Tables Processed:
    CRM:
        - crm_cust_info
        - crm_prd_info
        - crm_sales_details

    ERP:
        - erp_cust_az12
        - erp_loc_a101
        - erp_px_cat_g1v2

 Usage:
    EXEC silver.load_silver;

===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @start_time DATETIME,
        @end_time DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT ' START: Loading Silver Layer';
        PRINT '================================================';

        /* ===============================================================
           SECTION 1: CRM TRANSFORMATIONS
        =============================================================== */

        PRINT '------------------------------------------------';
        PRINT ' Processing CRM Tables';
        PRINT '------------------------------------------------';

        -- ================================
        -- Customer Info (Dedup + Clean)
        -- ================================
        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info (
            cst_id, cst_key, cst_firstname, cst_lastname,
            cst_marital_status, cst_gndr, cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),

            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,

            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,

            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE rn = 1;

        SET @end_time = GETDATE();
        PRINT '✔ crm_cust_info Loaded in ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' sec';


        -- ================================
        -- Product Info (Derived Columns)
        -- ================================
        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_prd_info;

        INSERT INTO silver.crm_prd_info (
            prd_id, cat_id, prd_key, prd_nm,
            prd_cost, prd_line, prd_start_dt, prd_end_dt
        )
        SELECT
            prd_id,

            REPLACE(SUBSTRING(prd_key,1,5),'-','_'),

            SUBSTRING(prd_key,7,LEN(prd_key)),

            prd_nm,

            ISNULL(prd_cost,0),

            CASE 
                WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
                ELSE 'n/a'
            END,

            CAST(prd_start_dt AS DATE),

            CAST(
                LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 
                AS DATE
            )

        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '✔ crm_prd_info Loaded';


        -- ================================
        -- Sales Data (Data Fixing Logic)
        -- ================================
        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_sales_details;

        INSERT INTO silver.crm_sales_details (
            sls_ord_num, sls_prd_key, sls_cust_id,
            sls_order_dt, sls_ship_dt, sls_due_dt,
            sls_sales, sls_quantity, sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE WHEN sls_order_dt=0 OR LEN(sls_order_dt)!=8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END,

            CASE WHEN sls_ship_dt=0 OR LEN(sls_ship_dt)!=8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END,

            CASE WHEN sls_due_dt=0 OR LEN(sls_due_dt)!=8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END,

            CASE 
                WHEN sls_sales IS NULL OR sls_sales<=0 
                     OR sls_sales != sls_quantity*ABS(sls_price)
                THEN sls_quantity*ABS(sls_price)
                ELSE sls_sales
            END,

            sls_quantity,

            CASE 
                WHEN sls_price IS NULL OR sls_price<=0
                THEN sls_sales/NULLIF(sls_quantity,0)
                ELSE sls_price
            END

        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '✔ crm_sales_details Loaded';


        /* ===============================================================
           SECTION 2: ERP TRANSFORMATIONS
        =============================================================== */

        PRINT '------------------------------------------------';
        PRINT ' Processing ERP Tables';
        PRINT '------------------------------------------------';

        -- Customer Demographics
        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12 (cid, bdate, gen)
        SELECT
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) ELSE cid END,
            CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
            CASE 
                WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
                ELSE 'n/a'
            END
        FROM bronze.erp_cust_az12;


        -- Location Cleanup
        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (cid, cntry)
        SELECT
            REPLACE(cid,'-',''),
            CASE
                WHEN TRIM(cntry)='DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
                WHEN cntry IS NULL OR TRIM(cntry)='' THEN 'n/a'
                ELSE TRIM(cntry)
            END
        FROM bronze.erp_loc_a101;


        -- Product Category (Direct Load)
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
        SELECT id, cat, subcat, maintenance
        FROM bronze.erp_px_cat_g1v2;


        /* ===============================================================
           FINAL SUMMARY
        =============================================================== */

        SET @batch_end_time = GETDATE();

        PRINT '================================================';
        PRINT ' SUCCESS: Silver Layer Loaded';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' sec';
        PRINT '================================================';

    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT ' ERROR: Silver Load Failed';
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END;
GO
