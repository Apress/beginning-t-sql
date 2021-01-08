/*
Chapter 6 solution
*/

USE AdventureWorks2019;
GO

--6.1.1
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID IN
(SELECT ProductID FROM Sales.SalesOrderDetail);


--6.1.2
SELECT ProductID, Name
FROM Production.Product
WHERE ProductID NOT IN (
    SELECT ProductID FROM Sales.SalesOrderDetail
    WHERE ProductID IS NOT NULL);

--6.1.3
SELECT Color
FROM Production.ProductColor
WHERE Color NOT IN (
    SELECT Color FROM Production.Product
    WHERE Color IS NOT NULL);

--6.1.4
SELECT DISTINCT Color
FROM Production.Product AS P
WHERE NOT EXISTS (
    SELECT * FROM Production.ProductColor AS PC
    WHERE P.Color = PC.Color);


--6.1.5
SELECT ModifiedDate
FROM Person.Person
UNION
SELECT HireDate
FROM HumanResources.Employee;

USE WideWorldImporters;
GO

--6.1.6
SELECT CityName
FROM Application.Cities AS SP
WHERE StateProvinceID 
IN (SELECT StateProvinceID FROM Application.StateProvinces WHERE StateProvinceName = 'Texas');


--6.1.7
SELECT *
FROM Warehouse.StockItems WH
WHERE NOT EXISTS
        (SELECT * FROM Sales.OrderLines   AS OL
WHERE OL.StockItemID=WH.StockItemID);
--No results because every item has been ordered.


--6.1.8
SELECT CityName
FROM Application.Cities c
INNER JOIN Application.StateProvinces s
    ON c.StateProvinceID=s.StateProvinceID
WHERE StateProvinceName = 'utah'
UNION 
SELECT CityName
FROM Application.Cities c
INNER JOIN Application.StateProvinces s
    ON c.StateProvinceID=s.StateProvinceID
WHERE StateProvinceName = 'wyoming';


--6.1.9
SELECT CityName
 FROM Application.Cities c
 INNER JOIN Application.StateProvinces s
    ON c.StateProvinceID=s.StateProvinceID
 WHERE StateProvinceName = 'utah'
 INTERSECT
 SELECT CityName
FROM Application.Cities c
              INNER JOIN Application.StateProvinces s
              ON c.StateProvinceID=s.StateProvinceID
              WHERE StateProvinceName = 'wyoming';


USE AdventureWorks2019;
GO

--6.2.1
 
SELECT SOH.SalesOrderID, SOH.OrderDate, ProductID
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN (
    SELECT SalesOrderID, ProductID
    FROM Sales.SalesOrderDetail) AS SOD
    ON SOH.SalesOrderID = SOD.SalesOrderID;

--6.2.2
WITH SOD AS (
    SELECT SalesOrderID, ProductID
    FROM Sales.SalesOrderDetail)
SELECT SOH.SalesOrderID, SOH.OrderDate, ProductID
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN SOD ON SOH.SalesOrderID = SOD.SalesOrderID;

--6.2.3
WITH SOH AS (
    SELECT SalesOrderID, OrderDate, CustomerID
    FROM Sales.SalesOrderHeader
    WHERE OrderDate BETWEEN '2011-01-01' AND '2011-12-31'
)
SELECT C.CustomerID, SalesOrderID, OrderDate
FROM Sales.Customer AS C
LEFT OUTER JOIN SOH ON C.CustomerID = SOH.CustomerID;

USE WideWorldImporters;
GO

--6.2.4
SELECT
    CustomerName
    ,CustomerID
FROM
    (
        SELECT CustomerName, CustomerID FROM Sales.Customers
    ) CDerivTbl;

/*
If you include a column in the outer query that doesn’t exist in the inner query,
	you’ll get an error. 
*/

--6.2.5
/*
The query will not run if you do not include an alias for the derived table.
*/