/*
Chapter 6 code
*/

--Listing 6-1. Using a Subquery in the IN List
SELECT CustomerID, AccountNumber
FROM Sales.Customer
WHERE CustomerID IN (SELECT CustomerID FROM Sales.SalesOrderHeader);

--Listing 6-2. A Subquery with NOT IN
SELECT CustomerID, AccountNumber
FROM Sales.Customer
WHERE CustomerID NOT IN
    (SELECT CustomerID FROM Sales.SalesOrderHeader);


--Listing 6-3. A Subquery with NOT IN
--1
SELECT CurrencyRateID, FromCurrencyCode, ToCurrencyCode
FROM Sales.CurrencyRate
WHERE CurrencyRateID NOT IN
    (SELECT CurrencyRateID
     FROM Sales.SalesOrderHeader);
 
--2
SELECT CurrencyRateID, FromCurrencyCode, ToCurrencyCode
FROM Sales.CurrencyRate
WHERE CurrencyRateID NOT IN
    (SELECT CurrencyRateID
     FROM Sales.SalesOrderHeader
     WHERE CurrencyRateID IS NOT NULL);

--Listing 6-4. Using the EXISTS Subquery
--1
SELECT CustomerID, AccountNumber
FROM Sales.Customer AS Cust
WHERE EXISTS
    (SELECT* FROM Sales.SalesOrderHeader AS SOH
     WHERE SOH.CustomerID = Cust.CustomerID);
 
--2
SELECT CustomerID, AccountNumber
FROM Sales.Customer AS Cust
WHERE NOT EXISTS
    (SELECT * FROM Sales.SalesOrderHeader AS SOH
     WHERE SOH.CustomerID = Cust.CustomerID);

--Listing 6-5. Using CROSS APPLY and OUTER APPLY
--1
SELECT CustomerID, AccountNumber, SalesOrderID
FROM Sales.Customer AS Cust
CROSS APPLY(SELECT  SalesOrderID
FROM Sales.SalesOrderHeader AS SOH
WHERE Cust.CustomerID = SOH.CustomerID) AS A;
 
--2
SELECT CustomerID, AccountNumber, SalesOrderID
FROM Sales.Customer AS Cust
OUTER APPLY(SELECT  SalesOrderID
FROM Sales.SalesOrderHeader AS SOH
WHERE Cust.CustomerID = SOH.CustomerID) AS A;


--Listing 6-6. Using UNION
--1
SELECT BusinessEntityID AS ID
FROM HumanResources.Employee
UNION
SELECT BusinessEntityID
FROM Person.Person
UNION
SELECT SalesOrderID
FROM Sales.SalesOrderHeader
ORDER BY ID;
 
--2
SELECT BusinessEntityID AS ID
FROM HumanResources.Employee
UNION ALL
SELECT BusinessEntityID
FROM Person.Person
UNION ALL
SELECT SalesOrderID
FROM Sales.SalesOrderHeader
ORDER BY ID;

--Incompatible types
SELECT 1
UNION ALL
SELECT 'a'
--Number of columns don't match up
SELECT 1
UNION ALL
SELECT 1,2

--Listing 6-7. Using EXCEPT and INTERSECT
--1
SELECT BusinessEntityID AS ID
FROM HumanResources.Employee
EXCEPT
SELECT BusinessEntityID
FROM Person.Person;

--2
SELECT BusinessEntityID AS ID
FROM HumanResources.Employee
INTERSECT
SELECT BusinessEntityID
FROM Person.Person;


--Listing 6-8. Using a Derived Table
SELECT c.CustomerID, s.SalesOrderID
FROM Sales.Customer AS c
INNER JOIN (SELECT SalesOrderID, CustomerID
            FROM Sales.SalesOrderHeader) AS s ON c.CustomerID = s.CustomerID;


--Listing 6-9. Using Common Table Expressions
--1
WITH orders AS (
    SELECT SalesOrderID, CustomerID, TotalDue + Freight AS Total
    FROM Sales.SalesOrderHeader
    )
SELECT c.CustomerID, orders.SalesOrderID, Orders.Total
FROM Sales.Customer AS c
INNER JOIN orders ON c.CustomerID = orders.CustomerID;
 
--2
WITH orders ([Order ID],[Customer ID], Total)
AS (SELECT SalesOrderID, CustomerID, TotalDue + Freight
    FROM Sales.SalesOrderHeader )
SELECT c.CustomerID, orders.[Order ID], Orders.Total
FROM Sales.Customer AS c
INNER JOIN orders ON c.CustomerID = orders.[Customer ID];


--Listing 6-10. Using a CTE to Solve a Problem
--1
SELECT c.CustomerID, s.SalesOrderID, s.OrderDate
FROM Sales.Customer AS c
LEFT OUTER JOIN Sales.SalesOrderHeader AS s ON c.CustomerID = s.CustomerID
WHERE s.OrderDate = '2011/07/01';
 
--2
;WITH orders AS (
    SELECT SalesOrderID, CustomerID, OrderDate
    FROM Sales.SalesOrderHeader
    WHERE OrderDate = '2011/07/01'
    )
SELECT c.CustomerID, orders.SalesOrderID, orders.OrderDate
FROM Sales.Customer AS c
LEFT OUTER JOIN orders ON c.CustomerID = orders.CustomerID
ORDER BY orders.OrderDate DESC;
 
 --Listing 6-11. Compare UNION to UNION ALL
--1
SELECT SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID <= 59549
UNION
SELECT SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID > 59549;
 
--2
SELECT SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID <= 59549
UNION ALL
SELECT SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID > 59549;

--Listing 6-12. An Attempt to Get Better Performance and Eliminate Duplicates
SELECT DISTINCT SalesOrderDetailID
FROM (
SELECT SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID <= 59549
UNION ALL
SELECT SalesOrderDetailID
FROM Sales.SalesOrderDetail
WHERE SalesOrderDetailID > 59549
) AS SOD;
 
