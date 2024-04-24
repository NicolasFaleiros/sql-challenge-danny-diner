SET search_path TO dannys_diner;

-- Just checking my new tables
SELECT * from sales;
SELECT * FROM temp_dates;
SELECT * from members;
SELECT * FROM menu;

-- Question 1
SELECT customer_id, sum(price) as total_sales
FROM sales
JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- Question 2
SELECT customer_id, COUNT(DISTINCT(order_date)) as visit_count
FROM sales
GROUP BY customer_id;

-- Question 3
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

-- Question 4
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


