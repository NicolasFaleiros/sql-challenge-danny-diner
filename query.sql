-- Active: 1713969704077@@127.0.0.1@5432@postgres@dannys_diner
SET search_path TO dannys_diner;

-- Just checking my new tables
SELECT * from sales;
SELECT * FROM temp_dates;
SELECT * from members;
SELECT * FROM menu;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 1 ------------------------------
-- What is the total amount each customer spent at the restaurant?
-- ----------------------------------------------------------------------

SELECT customer_id, sum(price) as total_sales
FROM sales
JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 2 ------------------------------
-- How many days has each customer visited the restaurant?
-- ----------------------------------------------------------------------

SELECT customer_id, COUNT(DISTINCT(order_date)) as visit_count
FROM sales
GROUP BY customer_id;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 3 ------------------------------
-- What was the first item from the menu purchased by each customer?
-- ----------------------------------------------------------------------

WITH ordered_sales_cte AS
(
   SELECT customer_id, order_date, product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rankk
   FROM sales s
   JOIN menu m
      ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM ordered_sales_cte
WHERE rankk = 1
GROUP BY customer_id, product_name;

-- Notice that we are getting two products for some consumers
WITH ordered_sales_cte_ranked AS
(
   SELECT s.customer_id, s.order_date, m.product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rankk
   FROM sales s
   JOIN menu m
      ON s.product_id = m.product_id
)
SELECT customer_id, product_name, order_date, rankk
FROM ordered_sales_cte_ranked
ORDER BY customer_id, order_date;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 4 ------------------------------
-- What is the most purchased item on the menu and how many times was it
--  purchased by all customers?
-- ----------------------------------------------------------------------

SELECT product_name, COUNT(order_date) as orders
FROM sales as S
INNER JOIN menu as M ON S.product_id = M.product_id
GROUP BY product_name
ORDER BY COUNT(order_date) DESC
LIMIT 1;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 5 ------------------------------
-- Which item was the most popular for each customer?
-- ----------------------------------------------------------------------

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

-- ----------------------------------------------------------------------
-- ---------------------------- Question 6 ------------------------------
-- Which item was purchased first by the customer after they became a member?
-- ----------------------------------------------------------------------

WITH CTE AS (
	SELECT DISTINCT
		S.*, 
		M.JOIN_DATE, 
        MN.PRODUCT_NAME,
        DENSE_RANK() OVER (PARTITION BY S.CUSTOMER_ID ORDER BY S.ORDER_DATE) AS RANKK
	FROM SALES S
	INNER JOIN MEMBERS M
		ON S.CUSTOMER_ID = M.CUSTOMER_ID
	INNER JOIN MENU MN
		ON S.PRODUCT_ID = MN.PRODUCT_ID
	WHERE ORDER_DATE >= JOIN_DATE
)
SELECT CUSTOMER_ID, PRODUCT_NAME, ORDER_DATE
FROM CTE
WHERE RANKK = 1
ORDER BY CUSTOMER_ID;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 7 ------------------------------
-- Which item was purchased just before the customer became a member?
-- ----------------------------------------------------------------------

WITH CTE AS (
	SELECT DISTINCT
		S.*, 
      MN.PRODUCT_NAME, 
      ME.JOIN_DATE,
      DENSE_RANK() OVER (PARTITION BY S.CUSTOMER_ID ORDER BY ORDER_DATE DESC) AS RANKK
	FROM SALES S
	INNER JOIN MENU MN ON S.PRODUCT_ID = MN.PRODUCT_ID
	INNER JOIN MEMBERS ME ON S.CUSTOMER_ID = ME.CUSTOMER_ID
	WHERE ORDER_DATE < JOIN_DATE
	ORDER BY CUSTOMER_ID, ORDER_DATE
)
SELECT CUSTOMER_ID, PRODUCT_NAME, ORDER_DATE, JOIN_DATE
FROM CTE
WHERE RANKK = 1;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 8 ------------------------------
-- What is the total items and amount spent for each member before they 
-- became a member?
-- ----------------------------------------------------------------------

SELECT DISTINCT
	S.CUSTOMER_ID, 
   COUNT(*) AS QTD, 
   SUM(PRICE) AS TOTAL
FROM SALES S
INNER JOIN MENU MN ON S.PRODUCT_ID = MN.PRODUCT_ID
INNER JOIN MEMBERS ME ON S.CUSTOMER_ID = ME.CUSTOMER_ID
WHERE ORDER_DATE < JOIN_DATE
GROUP BY S.CUSTOMER_ID
ORDER BY S.CUSTOMER_ID;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 9 ------------------------------
-- If each $1 spent equates to 10 points and sushi has a 2x points 
-- multiplier - how many points would each customer have?
-- ----------------------------------------------------------------------

WITH POINTS_TABLE AS (
	SELECT 
   S.CUSTOMER_ID,
   CASE
	   WHEN MN.PRODUCT_NAME = 'sushi' THEN MN.PRICE*20
      WHEN MN.PRODUCT_NAME != 'sushi' THEN MN.PRICE*10
	   ELSE 0 
   END AS CUSTOMER_POINTS
	FROM SALES S
   INNER JOIN MENU MN ON S.PRODUCT_ID = MN.PRODUCT_ID
)
SELECT CUSTOMER_ID, SUM(CUSTOMER_POINTS) AS TOTAL_POINTS
FROM POINTS_TABLE
GROUP BY CUSTOMER_ID
ORDER BY TOTAL_POINTS DESC;

-- ----------------------------------------------------------------------
-- ---------------------------- Question 9 ------------------------------
-- In the first week after a customer joins the program (including 
-- their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January?
-- ----------------------------------------------------------------------

WITH VALIDPROMOTION AS (
	SELECT
		CUSTOMER_ID,
		JOIN_DATE,
		JOIN_DATE + INTERVAL '6 days' AS VALID_DATE
    FROM MEMBERS
)
SELECT 
	S.CUSTOMER_ID,
    SUM(
		CASE 
			WHEN S.ORDER_DATE BETWEEN ME.JOIN_DATE AND V.VALID_DATE THEN MN.PRICE * 20
         WHEN MN.PRODUCT_NAME = 'sushi' THEN MN.PRICE * 20
         ELSE MN.PRICE * 10 
      END
		) AS TOTAL_POINTS
FROM SALES S
INNER JOIN VALIDPROMOTION V ON S.CUSTOMER_ID = V.CUSTOMER_ID
INNER JOIN MENU MN ON S.PRODUCT_ID = MN.PRODUCT_ID
INNER JOIN MEMBERS ME ON S.CUSTOMER_ID = ME.CUSTOMER_ID
WHERE S.ORDER_DATE <= '2021-01-31'
GROUP BY S.CUSTOMER_ID;