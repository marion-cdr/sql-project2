# Loyalty Program SQL Project 🎯🛍️

This is an intermediate SQL project focused on customer behavior analysis for a **loyalty program** in a retail context. The project uses **SQLite** to simulate a customer database with loyalty cards and purchases.

## 📁 Project Structure

- `project2.sql` – SQLite script to create tables, insert data, and execute analysis queries.
- `screenshots/` – Optional folder for adding screenshots of outputs or visual results.

## 📊 Covered Topics

- Aggregate functions (`SUM`, `COUNT`, `AVG`)
- Date calculations with `julianday()`
- Filtering with `GROUP BY` and `HAVING`
- Conditional updates with `CASE`
- Subqueries and `NOT EXISTS`
- Data cleaning (`DELETE`) and constraints (`TRIGGER`)
- Window functions (`LAG`, `AVG OVER`)
- Customer segmentation logic

## 🔧 How to Use

1. Open a SQLite client (e.g. [DB Browser for SQLite](https://sqlitebrowser.org/)).
2. Create a new database and run the `project2.sql` file.
3. Browse through the different SQL queries and analyze the results!

## 📌 Exercises

### Exercice 1️⃣ – Monthly customer activity
> For each client and each month (YYYY-MM), calculate:
- Number of transactions
- Total spending

### Exercice 2️⃣ – Detect inactive customers
> Find customers who haven’t made any purchase in the last 6 months (or never made one).

### Exercice 3️⃣ – Segment clients based on spending
> Add a `segment` column to the `customers` table:
- `'VIP'` if total spent > €1000
- `'ACTIVE'` if > €500
- `'INACTIVE'` otherwise

### Exercice 4️⃣ – Loyalty card analysis
> For each card type:
- Show the number of customers who have both an active card and segment = `'ACTIVE'`
- Show their average total spending

### Exercice 5️⃣ – Delete expired & unused cards
> Remove loyalty cards with `status = 'expired'` **and** no transaction after activation.

### Exercice 6️⃣ – Prevent invalid transactions
> Create a `TRIGGER` that blocks any transaction where `amount_spent < 0`.

### Bonus – Average frequency of purchases
> For each client, calculate the **average number of days between their purchases**.

---
