/*
Chapter 7 code
*/

--Listing 7-1. Using Aggregate Functions
--1
SELECT COUNT(*) AS CountOfRows,
    MAX(TotalDue) AS MaxTotal,
    MIN(TotalDue) AS MinTotal,
    SUM(TotalDue) AS SumOfTotal,
    AVG(TotalDue) AS AvgTotal
FROM Sales.SalesOrderHeader;
 
--2
SELECT MIN(Name) AS MinName,
    MAX(Name) AS MaxName,
    MIN(SellStartDate) AS MinSellStartDate
FROM Production.Product;
 
--3
SELECT COUNT(*) AS CountOfRows,
    COUNT(Color) AS CountOfColor,
        COUNT(DISTINCT Color) AS CountOfDistinctColor
FROM Production.Product;


SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader;
 
--Listing 7-2. Using the GROUP BY Clause
--1
SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;
 
--2
SELECT TerritoryID,AVG(TotalDue) AS AveragePerTerritory
FROM Sales.SalesOrderHeader
GROUP BY TerritoryID;
 
--Listing 7-3. How to Group on an Expression
--1
SELECT COUNT(*) AS CountOfOrders, YEAR(OrderDate) AS OrderYear
FROM Sales.SalesOrderHeader
GROUP BY OrderDate;
 
--2
SELECT COUNT(*) AS CountOfOrders, YEAR(OrderDate) AS OrderYear
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate);

SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY TerritoryID;

--Listing 7-4. Using ORDER BY
--1
SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY CustomerID;
 
--2
SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY MAX(TotalDue) DESC;
 
--3
SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
ORDER BY TotalPerCustomer DESC;


--Listing 7-5. Using the WHERE Clause
SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
WHERE TerritoryID in (5,6)
GROUP BY CustomerID;
 
--Listing 7-6. Using the HAVING Clause
--1
SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING SUM(TotalDue) > 5000;
 
--2
SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING COUNT(*) = 10 AND SUM(TotalDue) > 5000;
 
--3
SELECT CustomerID,SUM(TotalDue) AS TotalPerCustomer
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING CustomerID > 27858;

--Listing 7-7. Using DISTINCT and GROUP BY
--1
SELECT DISTINCT SalesOrderID
FROM Sales.SalesOrderDetail;
 
--2
SELECT SalesOrderID
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;


--Listing 7-8. Using DISTINCT in an Aggregate Expression
--1
SELECT COUNT(*) AS CountOfRows,
    COUNT(SalesPersonID) AS CountOfSalesPeople,
    COUNT(DISTINCT SalesPersonID) AS CountOfUniqueSalesPeople
FROM Sales.SalesOrderHeader;
 
--2
SELECT SUM(TotalDue) AS TotalOfAllOrders,
    SUM(Distinct TotalDue) AS TotalOfDistinctTotalDue
FROM Sales.SalesOrderHeader;


--Listing 7-9. Writing Aggregate Queries with Two Tables
--1
SELECT c.CustomerID, c.AccountNumber, COUNT(*) AS CountOfOrders,
    SUM(TotalDue) AS SumOfTotalDue
FROM Sales.Customer AS c
INNER JOIN Sales.SalesOrderHeader AS s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.AccountNumber
ORDER BY c.CustomerID;
 
--2
SELECT c.CustomerID, c.AccountNumber, COUNT(*) AS CountOfOrders,
    SUM(TotalDue) AS SumOfTotalDue
FROM Sales.Customer AS c
LEFT OUTER JOIN Sales.SalesOrderHeader AS s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.AccountNumber
ORDER BY c.CustomerID;
 
--3
SELECT c.CustomerID, c.AccountNumber,COUNT(s.SalesOrderID) AS CountOfOrders,
    SUM(COALESCE(TotalDue,0)) AS SumOfTotalDue
FROM Sales.Customer AS c
LEFT OUTER JOIN Sales.SalesOrderHeader AS s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID, c.AccountNumber
ORDER BY c.CustomerID;


--Listing 7-10. Average and NULL
--1
CREATE TABLE #AvgDemo (CustID INT, OrderID INT NOT NULL, Total MONEY NOT NULL,
    DiscountAmt MONEY NULL);
INSERT INTO #AvgDemo (CustID, OrderID, Total, DiscountAmt)
SELECT CustomerID, SOD.SalesOrderID, LineTotal, NULLIF(SUM(UnitPriceDiscount * LineTotal), 0.00)
FROM sales.SalesOrderDetail AS SOD
INNER JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID = SOH.SalesOrderID
WHERE CustomerID IN (29648, 30048, 30043, 29716)
GROUP BY CustomerID, SOD.SalesOrderID, LineTotal;
 
--2
SELECT CustID, AVG(DiscountAmt) AS AvgDiscount,
    AVG(ISNULL(DiscountAmt,0)) AS AvgWithNullRows,
        SUM(DiscountAmt) AS SumOfDiscount,
        COUNT(*) AS CountOfRows,
        COUNT(DiscountAmt) AS NonNullCount
FROM #AvgDemo
GROUP BY CustID;

--Listing 7-11. Using Statistics IO
SET STATISTICS IO ON;
GO
 
SELECT *
FROM Sales.SalesOrderHeader;
 
SELECT SalesOrderID
FROM Sales.SalesOrderHeader;
 
SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader;
 

