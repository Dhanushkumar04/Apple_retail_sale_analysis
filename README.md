![Apple Logo](https://github.com/Dhanushkumar04/Apple_retail_sale_analysis/blob/main/Apple_logo.webp)


# Apple Retail Sales Analysis | PostgreSQL

## Project Overview
A PostgreSQL-based data analytics project focused on Apple retail sales data. The project involves relational database design, data import, SQL querying, and analyzing retail sales, product performance, store performance, and warranty claims.

## Technologies Used
- PostgreSQL
- SQL

## Database Schema

Designed a relational database consisting of five interconnected tables:

| Table | Description |
|---|---|
| `stores` | Store information, city, and country |
| `category` | Product category details |
| `products` | Product information, pricing, and launch dates |
| `sales` | Sales transactions and quantities |
| `warranty` | Warranty claims and repair status |

### Database Relationships
- Stores → Sales (One-to-Many)
- Category → Products (One-to-Many)
- Products → Sales (One-to-Many)
- Sales → Warranty (One-to-Many)

## Key Implementations
- Designed a relational database using primary and foreign keys.
- Established table relationships and referential integrity.
- Imported CSV datasets using PostgreSQL `COPY`.
- Configured date formats using `SET datestyle`.
- Performed data validation using SQL queries.
- Structured interconnected retail datasets for analytical querying.

## SQL Concepts Applied
- DDL and DML operations
- Primary and Foreign Key Constraints
- INNER JOIN and LEFT JOIN
- GROUP BY and HAVING
- Aggregate Functions
- Subqueries and CTEs
- Window Functions
- Data Import and Validation

## Business Analysis & Insights

The database supports retail business analysis through questions such as:

- Which products and categories generate the highest sales?
- Which stores contribute the most to overall sales?
- What are the sales trends across different periods?
- Which products have the highest warranty claim rates?
- What is the distribution of warranty repair statuses?
- Which product categories perform best across different locations?

## Project Structure

```text
Apple-Retail-Sales-Analysis/
│
├── dataset/
│   ├── sales.csv
│   ├── stores.csv
│   ├── category.csv
│   ├── products.csv
│   └── warranty.csv
│
├── sql/
│   └── apple_retail_analysis.sql
│
├── images/
│   └── database_erd.png
│
└── README.md
```

## How to Run
1. Install PostgreSQL and open pgAdmin or psql.
2. Create a database for the project.
3. Execute the SQL script to create the database tables.
4. Import the respective CSV datasets.
5. Execute SQL queries to validate and analyze the data.

## Key Learning Outcomes
- Practical experience in relational database design.
- Understanding primary keys, foreign keys, and referential integrity.
- Working with multiple interconnected datasets.
- Applying SQL concepts to retail business analysis.
- Developing database management and analytical problem-solving skills.

---

**Project Category:** Data Analytics | SQL | PostgreSQL  
**Author:** Dhanush Kumar
