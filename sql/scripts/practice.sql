
use SalesDB
/* TASK 9:
   Find Products that Fall Within the Highest 40% of the Prices
*/
SELECT 
    Product,
    Price,
    DistRank,
    CONCAT(DistRank * 100, '%') AS DistRankPerc
FROM (
    SELECT
        Product,
        Price,
        CUME_DIST() OVER (ORDER BY Price DESC) AS DistRank
    FROM Sales.Products
) AS PriceDistribution
WHERE DistRank <= 1;

SELECT 
    Product,
    Price,
    DistRank,
    CONCAT(DistRank * 100, '%') AS DistRankPerc
FROM (
    SELECT
        Product,
        Price,
        PERCENT_RANK() OVER (ORDER BY Price DESC) AS DistRank
    FROM Sales.Products
) AS PriceDistribution
WHERE DistRank <= 1;



use SalesDB

select *, CurrentMonthSales - PreviousMonthSales as MOM_change,
ROUND(cast((CurrentMonthSales - PreviousMonthSales) AS Float)/previousMonthSales*100,1)  as MOM_perc
from
(select Month(orderdate) OrderMonth, 
sum(Sales) CurrentMonthSales,
lag(sum(sales)) over (ORDER BY MONTH(OrderDate)) previousMonthSales
from sales.Orders
group by Month(orderdate))t



select
CustomerID,
AVG(DaysUnitnxtOrder) AvgDays,
rank() over (ORDER BY COALESCE(AVG(DaysUnitnxtOrder), 999999)) Rankavg from
(
SELECT
        OrderID,
        CustomerID,
        OrderDate,
        LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate) next_order,
        DATEDIFF(day,OrderDate,LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY OrderDate)) DaysUnitnxtOrder
from Sales.Orders)t
GROUP BY CustomerID



SELECT
    OrderID,
    ProductID,
    Sales,
    FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LowestSales,
    LAST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS HighestSales,
    Sales - FIRST_VALUE(Sales) OVER (PARTITION BY ProductID ORDER BY Sales ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) As SalesDifference
    FROM Sales.Orders;


   

use SalesDB
    select product, Category from Sales.Products where price > (select AVG(price) from Sales.Products)


SELECT
*
FROM (
    -- Subquery
    SELECT
        ProductID,
        Price,
        AVG(Price) OVER () AS AvgPrice
    FROM Sales.Products
) AS t
WHERE Price > AvgPrice;




select *,
RANK() OVER (ORDER BY TotalSales DESC) AS Customerrank 
from 

 (SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t;




-- main Query
Select 
PRODUCTID,
PRODUCT,
Price,
--subquery
(select count(*) from Sales.orders) as TotalOrders
from 
Sales.Products



-- main query

select c.*, o.total_orders  from Sales.Customers c
LEFT JOIN(

    select count(*) total_orders, customerID from Sales.orders GROUP BY CustomerID) o
     on c.CustomerID=o.CustomerID



SELECT c.*, 
       (SELECT COUNT(*) FROM Sales.Orders o 
        WHERE o.CustomerID = c.CustomerID) AS total_orders
FROM Sales.Customers c;


WITH CustomerOrders AS (
    SELECT customerID, COUNT(*) AS total_orders 
    FROM Sales.Orders 
    GROUP BY CustomerID
)
SELECT c.*, CO.total_orders
FROM Sales.Customers c
LEFT JOIN CustomerOrders CO ON c.CustomerID = CO.customerID;



use SalesDB
-- write sql query to get the product list with price less than 20
SELECT Product, Price FROM Sales.Products WHERE Price < 20

 -- start  13:31:37 for advance sql Subqueries sql


SELECT *,
RANK() OVER (ORDER BY TotalSales DESC) AS Customerrank
 from (
SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders GROUP BY CustomerID) AS t


/*
====
   SUBQUERY | COMPARISON OPERATORS
===============================================================================*/
use SalesDB
/* TASK 6:
   Find the products that have a price higher than the average price of all products.
*/
-- Main Query
SELECT
    ProductID,
    Price,
    (SELECT AVG(Price) FROM Sales.Products) AS AvgPrice -- Subquery
FROM Sales.Products
WHERE Price > (SELECT AVG(Price) FROM Sales.Products); -- Subquery



SELECT
    *
FROM Sales.Orders
WHERE CustomerID NOT IN (
    -- Subquery
    SELECT
        CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany');
    
    use SalesDB
/* TASK 9:
   Find female employees whose salaries are greater than the salaries of any male employees.
*/
SELECT
    EmployeeID, 
    FirstName,
    Salary
FROM Sales.Employees
WHERE Gender = 'F'
  AND Salary > ALL (
      SELECT Salary
      FROM Sales.Employees
      WHERE Gender = 'M'
  );




  use SalesDB
/* TASK 10:
   Show all customer details and the total orders for each customer using a correlated subquery.
*/
SELECT * , (Select count(*) from sales.Orders o where o.CustomerID = c.CustomerID) as TotalSales FROM Sales.customers c;



/* ==============================================================================
   SQL Common Table Expressions (CTEs)   14:18:24   
-------------------------------------------------------------------------------*/
use SalesDB;

WITH CTE_Total_Sales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
),


 CTE_Last_Order AS
(
    SELECT
        CustomerID,
        MAX(OrderDate) AS Last_Order
    FROM Sales.Orders
    GROUP BY CustomerID
)

--Main Query
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    cts.TotalSales,
    clo.Last_Order 
    from Sales.Customers c
    LEFT JOIN CTE_Total_Sales AS cts
    ON cts.CustomerID = c.CustomerID
    left join CTE_Last_Order AS clo
    on clo.CustomerID = c.CustomerID



/* ==============================================================================
   RECURSIVE CTE | BUILD HIERARCHY
===============================================================================*/

USE SalesDB;
WITH CTE_Emp_Hierarchy AS
(
    -- Anchor Member
    SELECT
        EmployeeID,
        FirstName,
        ManagerID,
        1 AS Level
    FROM Sales.Employees
    WHERE ManagerID IS NULL

    Union All

    -- Recursive Member
    SELECT
        e.EmployeeID,
        e.FirstName,
        e.ManagerID,
        Level + 1
    FROM Sales.Employees AS e
    INNER JOIN CTE_Emp_Hierarchy AS ceh
        ON e.ManagerID = ceh.EmployeeID
    
)

select * from CTE_Emp_Hierarchy



select EmployeeID,
        FirstName,
        ManagerID from Sales.Employees





/* =========================================================================
   SQL Views        15:45:30  
=========================================================================
*/
use salesDB
with CTE_Monthly_Summary AS
(
    SELECT
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS OrderMonth,
        SUM(Sales)                                          AS TotalSales
    FROM Sales.Orders
    GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
)

Select 
orderMonth,
TotalSales,
sum(TotalSales) over (order by orderMonth) as RunningTotal
from CTE_Monthly_Summary;




CREATE VIEW Sales.V_Monthly_Summary AS
(
    SELECT 
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS OrderMonth,
        SUM(Sales) AS TotalSales,
        COUNT(OrderID) AS TotalOrders,
        SUM(Quantity) AS TotalQuantities
    FROM Sales.Orders
    GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
)


select * from Sales.V_Monthly_Summary


Select 
orderMonth,
TotalSales,
sum(TotalSales) over (order by orderMonth) as RunningTotal
from sales.V_Monthly_Summary;




/* TASK:
   Create a view that combines details from Orders, Products, Customers, and Employees.
   This view abstracts the complexity of multiple table joins.
*/

select * from sales.orders
select * from sales.products
select * from sales.Customers
select * from sales.Employees
select 
o.CustomerID,
o.OrderID,
o.ProductID,
p.Product,
p.Category,
COALESCE(c.FirstName,'')  + ' ' + COALESCE(c.LastName,'') AS CustomerName,
COALESCE(e.FirstName, '') + ' ' + COALESCE(e.LastName, '') AS SalesName,
c.Country AS CustomerCountry,
o.Sales,
o.Quantity

from Sales.Orders o
left JOIN Sales.Products p
on o.ProductID = p.ProductID
left JOIN Sales.Customers c
on o.CustomerID = c.CustomerID
left JOIN Sales.Employees e
on e.EmployeeID = o.SalesPersonID


select * from sales.V_Order_Details




/* ==============================================================================
   SQL Temporary Tables     16:39:30
==============================================================================*/


Use SalesDB
select DateName(month, OrderDate) as OrderMonth, count(OrderID) as TotalOrders
into sales.MonthlyOrders
from Sales.Orders 
group by DateName(month, OrderDate)


DROP TABLE IF EXISTS sales.MonthlyOrders



IF OBJECT_ID('Sales.MonthlyOrders', 'U') IS NOT NULL
    DROP TABLE Sales.MonthlyOrders;
GO
select DateName(month, OrderDate) as OrderMonth, count(OrderID) as TotalOrders
into sales.MonthlyOrders
from Sales.Orders 
group by DateName(month, OrderDate)




/* ==============================================================================
17:02:00

==============================================================================*/