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
data-warehouse-project/
│
├── datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── sql/
│   ├── bronze/
│   │   ├── ddl_bronze.sql
│   │   └── load_bronze.sql
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql
│   │   └── load_silver.sql
│   │
│   ├── gold/
│   │   └── ddl_gold.sql
│   │
│   └── datawarehouse_init.sql
│
├── docs/
│   ├── data_catalog.md
│   └── naming_conventions.md
│
├── README.md
└── LICENSE
```

---

## ⚙️ Key Features

- ✅ End-to-End ETL Pipeline (Bronze → Silver → Gold)  
- ✅ Data Cleaning & Standardization  
- ✅ Deduplication using Window Functions  
- ✅ Data Validation & Business Rule Implementation  
- ✅ Star Schema Design (Fact & Dimension Tables)  
- ✅ Surrogate Key Implementation  

---

## 🧠 Concepts & Technologies Used

- **SQL Server (T-SQL)**
- Data Warehousing Concepts  
- Medallion Architecture  
- ETL Pipeline Design  
- Window Functions (`ROW_NUMBER`, `LEAD`)  
- Data Modeling (Star Schema)  

---

