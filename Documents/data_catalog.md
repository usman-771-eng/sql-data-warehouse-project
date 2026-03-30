# 📊 Data Catalog – Gold Layer

## 📌 Overview
The **Gold Layer** represents the final, business-ready data model in the Data Warehouse.  
It is designed using a **Star Schema** to support reporting, analytics, and BI tools like Power BI.

The layer consists of:
- **Dimension Tables** → Descriptive attributes  
- **Fact Table** → Measurable business events  

---

## 🧑‍💼 1. gold.dim_customers

### 📌 Purpose
Stores enriched customer data by combining CRM and ERP sources.  
Provides demographic, geographic, and profile information for analysis.

### 📊 Columns

| Column Name      | Data Type     | Description |
|------------------|---------------|------------|
| customer_key     | INT           | Surrogate key uniquely identifying each customer record. |
| customer_id      | INT           | Unique identifier from the source system. |
| customer_number  | NVARCHAR(50)  | Business key used for tracking customers. |
| first_name       | NVARCHAR(50)  | Customer's first name (cleaned). |
| last_name        | NVARCHAR(50)  | Customer's last name (cleaned). |
| country          | NVARCHAR(50)  | Customer's country (standardized). |
| marital_status   | NVARCHAR(50)  | Customer's marital status (normalized values). |
| gender           | NVARCHAR(50)  | Gender derived from CRM or ERP fallback. |
| birthdate        | DATE          | Customer's date of birth. |
| create_date      | DATE          | Date when the customer record was created. |

---

## 🛒 2. gold.dim_products

### 📌 Purpose
Provides detailed product information including category hierarchy and attributes.  
Used for product-level analysis and reporting.

### 📊 Columns

| Column Name         | Data Type     | Description |
|---------------------|---------------|------------|
| product_key         | INT           | Surrogate key uniquely identifying each product. |
| product_id          | INT           | Unique product identifier from source system. |
| product_number      | NVARCHAR(50)  | Business key representing the product. |
| product_name        | NVARCHAR(50)  | Descriptive product name. |
| category_id         | NVARCHAR(50)  | Identifier linking product to category. |
| category            | NVARCHAR(50)  | High-level product category (e.g., Bikes). |
| subcategory         | NVARCHAR(50)  | Detailed classification within category. |
| maintenance_type    | NVARCHAR(50)  | Indicates maintenance requirement. |
| cost                | INT           | Base cost of the product. |
| product_line        | NVARCHAR(50)  | Product line classification (e.g., Road, Mountain). |
| start_date          | DATE          | Date when the product became active. |

---

## 💰 3. gold.fact_sales

### 📌 Purpose
Stores transactional sales data for analytical reporting.  
Acts as the central fact table connecting customers and products.

### 📊 Columns

| Column Name     | Data Type     | Description |
|-----------------|---------------|------------|
| order_number    | NVARCHAR(50)  | Unique identifier for each sales order. |
| product_key     | INT           | Foreign key referencing dim_products. |
| customer_key    | INT           | Foreign key referencing dim_customers. |
| order_date      | DATE          | Date when the order was placed. |
| shipping_date   | DATE          | Date when the order was shipped. |
| due_date        | DATE          | Payment due date. |
| sales_amount    | INT           | Total sales amount per transaction. |
| quantity        | INT           | Number of units sold. |
| price           | INT           | Price per unit. |

---

## 🧠 Data Model (Star Schema)
