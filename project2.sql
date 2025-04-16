.mode column 
.headers on 

DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS cards;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    signup_date DATE,
    birth_date DATE
);


CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    transaction_date DATE,
    amount REAL,
    store_location TEXT, 
    payement_method TEXT
);


CREATE TABLE IF NOT EXISTS cards (
    card_id INTEGER,
    customer_id INTEGER, 
    card_type TEXT, 
    activation_date DATE,
    status TEXT CHECK (status IN ('active', 'expired', 'suspended'))
);

INSERT INTO customers (customer_id, first_name, last_name, signup_date, birth_date) VALUES
(1, 'Alice', 'Martin', '2021-06-01', '1988-04-10'),
(2, 'Bob', 'Durand', '2022-01-15', '1992-09-03'),
(3, 'Chloe', 'Lemoine', '2023-03-20', '1985-12-01'),
(4, 'David', 'Moreau', '2020-05-20', '1980-06-18'),
(5, 'Emma', 'Bernard', '2019-11-30', '1990-01-25');

INSERT INTO transactions (customer_id, transaction_date, amount, store_location, payement_method) VALUES
(1, '2024-10-10', 120.00, 'Paris', 'card'),
(1, '2024-10-20', 55.00, 'Paris', 'cash'),
(1, '2024-11-10', 80.00, 'Paris', 'cash'),
(1, '2024-11-15', 90.00, 'Lyon', 'card'),
(1, '2025-01-12', 100.00, 'Lyon', 'card'),
(1, '2025-01-20', 75.00, 'Paris', 'card'),
(2, '2024-08-05', 60.00, 'Lille', 'card'),
(2, '2024-08-15', 45.00, 'Lille', 'card'),
(2, '2024-10-01', 40.00, 'Lille', 'card'),
(2, '2024-10-25', 100.00, 'Lyon', 'cash'),
(3, '2025-03-01', 300.00, 'Marseille', 'card'),
(3, '2025-03-10', 120.00, 'Paris', 'card'),
(3, '2025-03-15', 60.00, 'Lille', 'card'),
(4, '2024-01-10', 220.00, 'Paris', 'card'),
(4, '2024-02-14', 150.00, 'Paris', 'cash'),
(4, '2024-03-01', 180.00, 'Lyon', 'card');

INSERT INTO cards (card_id, customer_id, card_type, activation_date, status) VALUES
(101, 1, 'Premium', '2021-06-01', 'active'),
(102, 2, 'Standard', '2022-01-15', 'expired'),
(103, 3, 'VIP', '2023-03-20', 'active'),
(104, 4, 'Standard', '2020-05-20', 'active'),
(105, 5, 'VIP', '2019-11-30', 'expired');


-- ---------------------------------------------
-- 📌 Exercice 1 – Monthly Activity per Client
-- ---------------------------------------------
SELECT
    c.first_name || ' ' || c.last_name AS name,
    strftime('%Y-%m', t.transaction_date) AS year_month,
    COUNT(*) AS nb_transactions,
    SUM(t.amount) AS total_amount
FROM transactions t 
INNER JOIN customers c ON c.customer_id = t.customer_id 
GROUP BY c.customer_id, year_month

-- ---------------------------------------------
-- 📌 Exercice 2 – Inactive Clients (1 year)
-- ---------------------------------------------
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS name,
    MAX(t.transaction_date) AS last_transaction
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id -- desn't exclude not existing customers 
GROUP BY c.customer_id
HAVING last_transaction IS NULL 
    OR julianday('now') - julianday(last_transaction) > 365; --converts a date into a number of days

-- ----------------------------------------------------
-- 📌 Exercice 3 – Create Segmentation Column + Update
-- ----------------------------------------------------
ALTER TABLE customers ADD COLUMN segment TEXT;

UPDATE customers
SET segment = (
    SELECT CASE 
        WHEN SUM(t.amount) > 500 THEN 'VIP'
        WHEN SUM(t.amount) > 300 THEN 'ACTIVE'
        ELSE 'INACTIVE'
    END
    FROM transactions t
    WHERE t.customer_id = customers.customer_id
);

SELECT customer_id, first_name, last_name, segment FROM customers;

-- ----------------------------------------------------
-- 📌 Exercice 4 – Loyalty Card Usage by Type
-- ----------------------------------------------------
SELECT 
    cd.card_type,
    c.first_name,
    COUNT(DISTINCT t.customer_id) AS nb_customer,
    ROUND(AVG(t.amount)) AS avg_amount
FROM transactions t 
INNER JOIN cards cd ON cd.customer_id = t.customer_id
INNER JOIN customers c ON c.customer_id = t.customer_id
WHERE c.segment = 'ACTIVE' AND cd.status = 'active' 
GROUP BY cd.card_type, c.first_name;

-- ----------------------------------------------------
-- 📌 Exercice 5 – Delete Inactive Expired Cards
-- ----------------------------------------------------
DELETE FROM cards
WHERE status = 'expired'
AND NOT EXISTS (
    SELECT 1 FROM transactions t
    WHERE t.customer_id = cards.customer_id
    AND t.transaction_date > cards.activation_date
);

-- ----------------------------------------------------
-- 📌 Exercice 6 – Prevent Negative Transaction (TRIGGER)
-- ----------------------------------------------------
DROP TRIGGER IF EXISTS prevent_negative_transaction;

CREATE TRIGGER prevent_negative_transaction
BEFORE INSERT ON transactions
FOR EACH ROW
WHEN NEW.amount < 0
BEGIN
    SELECT RAISE(ABORT, 'Negative transaction not allowed');
END;

-- ----------------------------------------------------
-- 📌 Bonus – Average Time Between Purchases
-- ----------------------------------------------------
WITH ranked AS (
  SELECT
    customer_id,
    transaction_date,
    julianday(transaction_date) - julianday(LAG(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date)) AS days_between
  FROM transactions
)
SELECT 
    customer_id,
    ROUND(AVG(days_between), 2) AS avg_days_between
FROM ranked
WHERE days_between IS NOT NULL
GROUP BY customer_id;