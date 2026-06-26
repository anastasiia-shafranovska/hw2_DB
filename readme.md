# Practical assignment 2

### The purpose of this task

Learn how to optimize queries in PostgreSQL.

### Requirements (_for 15 points_)

Provide step-by-step optimization of a complex query with execution plan comparison.

1. In the query to optimize, use at least 2 joins. You have to join at least 3 tables.
2. You have to have at least 10000 rows in each table.
3. You should demonstrate 2 variants of the query: optimized and non-optimized.
4. Your 2 query variants have to return the same result.
5. You should use CTE for optimization.
6. You must use the index/indexes for optimization.
7. You must show a comparison of execution plans.
8. Your code should be on GitHub.
9. Explain your solution using the correct terminology.
10. Be ready to answer questions about query optimization.

### Additional points (for 2 points):
* Demonstrate optimizer control in PostgreSQL using planner settings (2 points)

### Additional info

I suggest you look at my example of the task, which is described below: PostgreSQL Optimization Demo.

### PostgreSQL Optimization Demo

#### Requirements

- Python 3.9.6+
- PostgreSQL Server
- `psycopg2-binary` package
- `Faker` package
- `python-dotenv` package

### How to run

1. Create a database manually if needed:

```sql
CREATE DATABASE opt_db;
```

2. Connect to this database.

3. Run **script_01_create_tables.sql** in your database.

4. Install Python dependencies:

```sh
pip install -r requirements_postgres.txt
```

5. Run your Python script **main.py** to insert fake data into the tables.

6. Execute queries from **optimization_demo.sql** using `EXPLAIN ANALYZE`.

### What was optimized

The non-optimized query recalculates the same joined and grouped dataset several times in nested subqueries.

The optimized query:

1. Filters and joins the needed rows once in the `filtered_orders` CTE.
2. Aggregates product counts once in the `cnt_products` CTE.
3. Uses window functions to find the minimum and maximum product counts.
4. Uses indexes on filtered and joined columns:
   - `opt_orders(order_date)`
   - `opt_orders(product_id)`
   - `opt_orders(client_id)`
   - `opt_clients(status)`
