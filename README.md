# 🍜 Case Study 1 - Danny's Diner

<hr style="border:1px solid indianred">

![Pasted image 20230404183325](https://github.com/NicolasFaleiros/sql-challenge-danny-diner/assets/41973874/c33494c8-8f14-413e-b2e8-91bda6f268a3)


## 📚 Table of Contents

<hr style="border:1px solid indianred">

* 

<hr style="border:2px solid indianred">

## 🧠 Business Task

<hr style="border:1px solid indianred">

Danny loves Japanese food and he opened up a restaurant that sells 3 of his **favorite** foods: **sushi**, **ramen** and **curry**.

His restaurant captured some data from his first months of operation, but have no idea how to analyse it and turn it into useful information that will help the business. They need our assistance to help the restaurant stay afloat.

## 🔎 Entity Relationship Diagram

<hr style="border:1px solid indianred">

![[Pasted image 20230404185248.png]]

## 📋 Case Study Questions

<hr style="border:1px solid indianred">

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

<hr style="border:2px solid indianred">

# Solution

<hr style="border:1px solid indianred">

View the complete SQL code here. Note that for this project I've expanded the original sample data provided by the author. As a result we now have a little bit over **900** orders in the `sales` table and **50** clients in the `members` table.

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
| 1           | 2018        |
| 2           | 1636        |
| 3           | 1246        |
| 4           | 1262        |
| 5           | 1312        |
| 6           | 11          |
| 7           | 156         |
| 8           | 1594        |
| 9           | 1554        |
| 10          | 1552        |
| 11          | 648         |
| 12          | 846         |
| 13          | 79          |
| 14          | 58          |
| 15          | 996         |
| 16          | 982         |
| 17          | 764         |
| 18          | 866         |
| 19          | 624         |
| 20          | 728         |
| 21          | 82          |
| 22          | 734         |
| 23          | 876         |
| 24          | 968         |
| 25          | 792         |
| 26          | 712         |
| 27          | 808         |
| 28          | 85          |
| 29          | 368         |
| 30          | 658         |
| 31          | 964         |
| 32          | 8           |
| 33          | 868         |
| 34          | 784         |
| 35          | 1192        |
| 36          | 878         |
| 37          | 1014        |
| 38          | 854         |
| 39          | 121         |
| 40          | 908         |
| 41          | 908         |
| 42          | 658         |
| 43          | 832         |
| 44          | 762         |
| 45          | 558         |
| 46          | 608         |
| 47          | 65          |
| 48          | 1064        |
| 49          | 66          |
| 50          | 896         |

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
| 1           | 67          |
| 2           | 54          |
| 3           | 42          |
| 4           | 5           |
| 5           | 49          |
| 6           | 45          |
| 7           | 6           |
| 8           | 61          |
| 9           | 58          |
| 10          | 57          |
| 11          | 27          |
| 12          | 34          |
| 13          | 32          |
| 14          | 22          |
| 15          | 39          |
| 16          | 38          |
| 17          | 3           |
| 18          | 36          |
| 19          | 25          |
| 20          | 28          |
| 21          | 34          |
| 22          | 31          |
| 23          | 31          |
| 24          | 36          |
| 25          | 32          |
| 26          | 27          |
| 27          | 3           |
| 28          | 34          |
| 29          | 16          |
| 30          | 24          |
| 31          | 38          |
| 32          | 32          |
| 33          | 33          |
| 34          | 31          |
| 35          | 44          |
| 36          | 35          |
| 37          | 4           |
| 38          | 34          |
| 39          | 47          |
| 40          | 32          |
| 41          | 36          |
| 42          | 26          |
| 43          | 34          |
| 44          | 29          |
| 45          | 22          |
| 46          | 25          |
| 47          | 25          |
| 48          | 42          |
| 49          | 24          |
| 50          | 34          |

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

| customer_id | product_name |
|-------------|--------------|
| 1           | sushi        |
| 1           | curry        |
| 1           | ramen        |
| 2           | curry        |
| 3           | ramen        |
| 4           | sushi        |
| 5           | ramen        |
| 6           | sushi        |
| 7           | sushi        |
| 8           | curry        |
| 9           | curry        |
| 10          | curry        |
| 11          | curry        |
| 12          | curry        |
| 13          | ramen        |
| 14          | sushi        |
| 15          | sushi        |
| 16          | curry        |
| 17          | sushi        |
| 18          | ramen        |
| 19          | ramen        |
| 20          | sushi        |
| 21          | ramen        |
| 22          | ramen        |
| 23          | ramen        |
| 24          | ramen        |
| 25          | curry        |
| 26          | ramen        |
| 27          | curry        |
| 28          | curry        |
| 29          | sushi        |
| 30          | ramen        |
| 31          | curry        |
| 32          | sushi        |
| 33          | sushi        |
| 34          | sushi        |
| 35          | ramen        |
| 36          | sushi        |
| 37          | ramen        |
| 38          | ramen        |
| 39          | ramen        |
| 40          | ramen        |
| 41          | ramen        |
| 42          | ramen        |
| 43          | ramen        |
| 44          | curry        |
| 45          | curry        |
| 46          | curry        |
| 47          | sushi        |
| 48          | sushi        |
| 49          | curry        |
| 50          | sushi        |

<hr style="border:2px solid indianred">

### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
