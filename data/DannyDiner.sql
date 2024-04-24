
CREATE TABLE sales (
  customer_id INT,
  order_date DATE,
  product_id INT
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  (1, '2021-01-01', 1),
  (1, '2021-01-01', 2),
  (1, '2021-01-07', 2),
  (1, '2021-01-10', 3),
  (1, '2021-01-11', 3),
  (1, '2021-01-11', 3),
  (2, '2021-01-01', 2),
  (2, '2021-01-02', 2),
  (2, '2021-01-04', 1),
  (2, '2021-01-11', 1),
  (2, '2021-01-16', 3),
  (2, '2021-02-01', 3),
  (3, '2021-01-01', 3),
  (3, '2021-01-01', 3),
  (3, '2021-01-07', 3);
 

CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(5),
  price INT
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),
  (2, 'curry', 15),
  (3, 'ramen', 12);  

# Insert random sales records in the sales table
INSERT INTO sales (customer_id, order_date, product_id)
SELECT
  FLOOR(1 + RAND() * 50) AS customer_id,
  DATE_ADD('2021-01-01', INTERVAL FLOOR(RAND() * 360) DAY) AS order_date,
  FLOOR(1 + RAND() * 3) AS product_id
FROM
  (SELECT RAND() as rand_num FROM sales LIMIT 100000000) AS subquery
ORDER BY
  rand_num;

CREATE TABLE members (
  customer_id INT,
  join_date DATE
);

# Insert 50 customer_id's and their respective random join_date in 2021
INSERT INTO members (customer_id, join_date)
SELECT 
  num,
  DATE_ADD('2021-01-01', INTERVAL FLOOR(RAND() * 365) DAY) AS join_date
FROM (
  SELECT 1 AS num
  UNION SELECT 2
  UNION SELECT 3
  UNION SELECT 4
  UNION SELECT 5
  UNION SELECT 6
  UNION SELECT 7
  UNION SELECT 8
  UNION SELECT 9
  UNION SELECT 10
  UNION SELECT 11
  UNION SELECT 12
  UNION SELECT 13
  UNION SELECT 14
  UNION SELECT 15
  UNION SELECT 16
  UNION SELECT 17
  UNION SELECT 18
  UNION SELECT 19
  UNION SELECT 20
  UNION SELECT 21
  UNION SELECT 22
  UNION SELECT 23
  UNION SELECT 24
  UNION SELECT 25
  UNION SELECT 26
  UNION SELECT 27
  UNION SELECT 28
  UNION SELECT 29
  UNION SELECT 30
  UNION SELECT 31
  UNION SELECT 32
  UNION SELECT 33
  UNION SELECT 34
  UNION SELECT 35
  UNION SELECT 36
  UNION SELECT 37
  UNION SELECT 38
  UNION SELECT 39
  UNION SELECT 40
  UNION SELECT 41
  UNION SELECT 42
  UNION SELECT 43
  UNION SELECT 44
  UNION SELECT 45
  UNION SELECT 46
  UNION SELECT 47
  UNION SELECT 48
  UNION SELECT 49
  UNION SELECT 50
) AS subquery;

# Just checking my new tables
SELECT * from sales;
SELECT * FROM temp_dates;
SELECT * from members;
SELECT * FROM menu;

# Question 1
SELECT customer_id, sum(price) as total_sales
FROM sales
JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;

# Question 2
SELECT customer_id, COUNT(DISTINCT(order_date)) as visit_count
FROM sales
GROUP BY customer_id;

# Question 3
WITH ordered_sales_cte AS
(
   SELECT customer_id, order_date, product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rankk
   FROM sales AS s
   JOIN menu AS m
      ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE rankk = 1
GROUP BY customer_id, product_name;

# Question 4
SELECT product_name, COUNT(order_date) as orders
FROM sales as S
INNER JOIN menu as M ON S.product_id = M.product_id
GROUP BY product_name
ORDER BY COUNT(order_date) DESC
LIMIT 1;

# Question 5
WITH cte AS (
	SELECT product_name, customer_id, COUNT(order_date) as orders,
	RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rnk
	FROM sales as S
	INNER JOIN menu as M ON S.product_id = M.product_id
	GROUP BY product_name, customer_id
)
SELECT customer_id, product_name, orders
FROM cte
WHERE rnk = 1;


