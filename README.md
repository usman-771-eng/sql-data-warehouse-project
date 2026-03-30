# 🏗️ Data Warehouse Project – Medallion Architecture

## 📌 Overview

This project implements a **Data Warehouse solution using the Medallion Architecture** approach:

- 🟤 **Bronze Layer** → Raw data ingestion  
- ⚪ **Silver Layer** → Cleaned and transformed data  
- 🟡 **Gold Layer** → Business-ready analytical model (Star Schema)  

The pipeline is built using **SQL Server (T-SQL)** and designed to simulate a real-world data engineering workflow.

---

## 🏛️ Architecture
```
Source Systems (CSV Files)
↓
Bronze Layer (Raw Data)
↓
Silver Layer (Cleaned Data)
↓
Gold Layer (Analytics / Star Schema)
```
---

## 📂 Project Structure
```
sql-data-warehouse-project/
│
├── Bronze Layer/
│   ├── ddl_bronze.sql
│   └── procedure_load_bronze.sql
│
├── Silver Layer/
│   ├── ddl_silver.sql
│   └── load_silver.sql
│
├── Gold Layer/
│   └── ddl_gold.sql
│
├── Datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── Documents/
│   └── data_catalog.md
│
├── datawarehouse_init.sql
├── README.md
└── LICENSE
```

---

##  Key Features

-  End-to-End ETL Pipeline (Bronze → Silver → Gold)  
-  Data Cleaning & Standardization  
-  Deduplication using Window Functions  
-  Data Validation & Business Rule Implementation  
-  Star Schema Design (Fact & Dimension Tables)  
-  Surrogate Key Implementation  

---

##  Technologies Used

- SQL Server (T-SQL)  
- Data Warehousing Concepts  
- Medallion Architecture  
- ETL Pipeline Design  
- Window Functions (`ROW_NUMBER`, `LEAD`)  
- Data Modeling (Star Schema)  

---

## How to Run

1. Run `datawarehouse_init.sql`  
2. Execute Bronze Load → `EXEC bronze.load_bronze`  
3. Execute Silver Load → `EXEC silver.load_silver`  
4. Run Gold Layer script  

---

## Data Model

- **Dimensions**: `dim_customers`, `dim_products`  
- **Fact Table**: `fact_sales`  

---

## Documentation

- Data Catalog → `Documents/data_catalog.md`  
- Naming Standards → `Documents/naming_conventions.md`  

---

## Author

**Shaik Mahammad Usman**  
Aspiring Data Engineer 
