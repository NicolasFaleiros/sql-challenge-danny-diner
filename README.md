# 🍜 Case Study 1 - Danny's Diner


![1_resized (1)](https://github.com/NicolasFaleiros/sql-challenge-danny-diner/assets/41973874/bd0866be-7ecc-434c-9bbf-4777be5f1649)

# 📚 Table of Contents


# 🧠 Business Problem

Danny loves Japanese food and he opened up a restaurant that sells 3 of his **favorite** foods: **sushi**, **ramen** and **curry**.

His restaurant captured some data from his first months of operation, but have no idea how to analyse it and turn it into useful information that will help the business. They need our assistance to help the restaurant stay afloat.

# 🔎 Entity Relationship Diagram

![Pasted image 20230404185248](https://github.com/NicolasFaleiros/sql-challenge-danny-diner/assets/41973874/07619140-2911-4338-8049-cb57ea947418)

# 📋 Case Study Questions

1.  What is the total amount each customer spent at the restaurant?
2.  How many days has each customer visited the restaurant?
3.  What was the first item from the menu purchased by each customer?
4.  What is the most purchased item on the menu and how many times was it purchased by all customers?
5.  Which item was the most popular for each customer?
6.  Which item was purchased first by the customer after they became a member?
7.  Which item was purchased just before the customer became a member?
8.  What is the total items and amount spent for each member before they became a member?
9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10.  In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

# Solution

View the complete SQL code [here](https://github.com/NicolasFaleiros/sql-challenge-danny-diner/blob/main/query.sql). 

[comment]: <> (Note that for this project I've expanded the original sample data provided by the author. As a result we now have a little bit over **900** orders in the `sales` table and **50** clients in the `members` table.)

<hr style="border:2px solid indianred">

### 1. What is the total amount each customer spent at the restaurant?

```sql
SELECT customer_id, sum(price) as total_sales
FROM sales
JOIN menu
	ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY customer_id;
```

* Use **SUM** and **GROUP BY** to find out `total_sales` by each customer.
* Use **JOIN** to merge `sales` and `menu` tables as the information of price of each item and who bought what are stored in different tables.

| customer_id | total_sales |
|-------------|-------------|
| A           | 76          |
| B           | 74          |
| C           | 36          |

<hr style="border:2px solid indianred">

### 2.  How many days has each customer visited the restaurant?

```sql
SELECT customer_id, COUNT(DISTINCT(order_date)) as visit_count
FROM sales
GROUP BY customer_id;
```

* Use the **DISTINCT** inside of a **COUNT** to identify and count each particular visit of a customer.
* The **DISTINCT** is necessary here because a customer might have gone to the restaurant twice in a day, but I should only count it as one visit, not two.

| customer_id | visit_count |
|-------------|-------------|
| A           | 4           |
| B           | 6           |
| C           | 2           |

<hr style="border:2px solid indianred">

### 3. What was the first item from the menu purchased by each customer?

```sql
WITH sales_cte AS
(
   SELECT customer_id, order_date, product_name,
      DENSE_RANK() OVER(PARTITION BY s.customer_id
      ORDER BY s.order_date) AS rankk
   FROM sales AS s
   JOIN menu AS m
      ON s.product_id = m.product_id
)

SELECT customer_id, product_name
FROM sales_cte
WHERE rankk = 1
GROUP BY customer_id, product_name;
```
- To retrieve the product associated with the clients first purchase we rank all their purchases by order date and pick the first one (first order).
- In terms of SQL, the way we do this ranking is using the `DENSE_RANK()` function.

| customer_id | product_name |
|-------------|--------------|
| A           | curry        |
| A           | sushi        |
| B           | curry        |
| C           | ramen        |

- The reason that we have two products for some customers is that they might have ordered more than one product at their first purchase. 
- In the context of our database, as we have only the day of the purchase, and not the exact hour or minute, the customer might have ordered multiple products at the same purchase, or multiple orders in the same day.

```sql
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
```

| customer_id | product_name | order_date | rankk |
|-------------|--------------|------------|-------|
| A           | curry        | 2021-01-01 | 1     |
| A           | sushi        | 2021-01-01 | 1     |
| A           | curry        | 2021-01-07 | 2     |
| A           | ramen        | 2021-01-10 | 3     |
| A           | ramen        | 2021-01-11 | 4     |
| A           | ramen        | 2021-01-11 | 4     |
| B           | curry        | 2021-01-01 | 1     |
| B           | curry        | 2021-01-02 | 2     |
| B           | sushi        | 2021-01-04 | 3     |
| B           | sushi        | 2021-01-11 | 4     |
| B           | ramen        | 2021-01-16 | 5     |
| B           | ramen        | 2021-02-01 | 6     |
| C           | ramen        | 2021-01-01 | 1     |
| C           | ramen        | 2021-01-01 | 1     |
| C           | ramen        | 2021-01-07 | 2     |



<hr style="border:2px solid indianred">

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
