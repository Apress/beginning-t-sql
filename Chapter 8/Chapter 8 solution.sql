/*
Chapter 8 solution
*/
USE AdventureWorks2019;
GO

--8.1.1
SELECT ProductID, ProductSubcategoryID,
    ROW_NUMBER() OVER(PARTITION BY ProductSubCategoryID
ORDER BY ProductID) AS RowNum
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL;

--8.1.2
SELECT CustomerID, SUM(TotalDue) AS TotalSales,
    NTILE(10) OVER(ORDER BY SUM(TotalDue)) AS CustBucket
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2011/1/1' AND '2011/12/31'
GROUP BY CustomerID;

USE WideWorldImporters;
GO
--8.1.3
SELECT OrderID, ROW_NUMBER() OVER (Order By OrderID) AS rownum
FROM Sales.OrderLines;

--8.1.4
SELECT OrderID, DENSE_RANK() OVER (Order By OrderID) AS denserank
FROM Sales.OrderLines;
/*
The row numbers in query 3 will be unique. The dense rank will 
return the same value for duplicate SalesOrderID numbers.
*/

--8.1.5
/*
You could use NTILE(10) to get 10 nearly equal buckets.
*/

USE AdventureWorks2019;
GO
--8.2.1
SELECT SalesOrderID, OrderDate, TotalDue, CustomerID,
    AVG(TotalDue) OVER() AS AvgTotal
FROM Sales.SalesOrderHeader;

--8.2.2
SELECT SalesOrderID, OrderDate, TotalDue, CustomerID,
    AVG(TotalDue) OVER() AS AvgTotal,
    AVG(TotalDue) OVER(PARTITION BY CustomerID) AS AvgCustTotal
FROM Sales.SalesOrderHeader;

USE WideWorldImporters;
GO
--8.2.3
SELECT OrderID, OrderLineID, StockItemID, 
         Description, Quantity, UnitPrice, 
	SUM(Quantity * UnitPrice) OVER() AS GrandTotal
FROM Sales.OrderLines
WHERE OrderID BETWEEN 1 AND 10
ORDER BY OrderID;


--8.2.4
SELECT OrderID, OrderLineID, StockItemID, 
            Description, Quantity, UnitPrice, 
	SUM(Quantity * UnitPrice) OVER() AS GrandTotal, 
	SUM(Quantity * UnitPrice) OVER(PARTITION BY OrderID) AS SubTotal
FROM Sales.OrderLines
WHERE OrderID BETWEEN 1 AND 10
ORDER BY OrderID;


--8.2.5
SELECT OrderID, OrderLineID, StockItemID, 
	Description, Quantity, UnitPrice, 
	SUM(Quantity * UnitPrice) OVER() AS GrandTotal, 
	SUM(Quantity * UnitPrice) OVER(PARTITION BY OrderID) AS SubTotal,
	SUM(Quantity * UnitPrice) OVER(PARTITION BY OrderID) / 
	SUM(Quantity * UnitPrice) OVER() * 100 AS PercentOfSales
FROM Sales.OrderLines
WHERE OrderID BETWEEN 1 AND 10
ORDER BY OrderID;

--To avoid repeating the formula over and over, write the query like this:


WITH OrderLines AS (
	SELECT OrderID, OrderLineID, StockItemID, 
		Description, Quantity, UnitPrice, 
		Quantity * UnitPrice AS LineTotal
	FROM Sales.OrderLines 
	WHERE OrderID BETWEEN 1 AND 10)
SELECT OrderID, OrderLineID, StockItemID, 
	Description, Quantity, UnitPrice, 
	SUM(LineTotal) OVER() AS GrandTotal,
	SUM(LineTotal) OVER(PARTITION BY OrderID) AS SubTotal, 
	SUM(LineTotal) OVER(PARTITION BY OrderID) /
	SUM(LineTotal) OVER() * 100 AS PercentOfSales 
FROM OrderLines 
ORDER BY OrderID;

USE AdventureWorks2019;
GO
--8.3.1
SELECT SalesOrderID, ProductID, LineTotal,
    SUM(LineTotal) OVER(PARTITION BY ProductID
        ORDER BY SalesOrderID
     ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS RunningTotal
FROM Sales.SalesOrderDetail;

--8.3.2
/*
By default, the frame will be RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. 
This will introduce logic differences when the ORDER BY column is not unique. 
ROWS also performs much better than RANGE.
*/

--8.3.3
--ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING

USE WideWorldImporters;
GO
--8.3.4
SELECT CustomerID, InvoiceDate, 
     SUM(TotalDryItems) 
     OVER(PARTITION BY CustomerID ORDER BY InvoiceDate 
	ROWS BETWEEN UNBOUNDED 
   PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Sales.Invoices;

--8.4
CREATE TABLE #Stock (Symbol VARCHAR(4), TradingDate DATE,
    OpeningPrice MONEY, ClosingPrice MONEY);
INSERT INTO #Stock(Symbol, TradingDate, OpeningPrice, ClosingPrice)
VALUES ('A','2014/01/02',5.03,4.90),
    ('B','2014/01/02',10.99,11.25),
    ('C','2014/01/02',23.42,23.44),
    ('A','2014/01/03',4.93,5.10),
    ('B','2014/01/03',11.25,11.25),
    ('C','2014/01/03',25.15,25.06),
    ('A','2014/01/06',5.15,5.20),
    ('B','2014/01/06',11.30,11.12),
    ('C','2014/01/06',25.20,26.00);

CREATE TABLE #Rates
	(ID INT IDENTITY
        ,City varchar(20)
        ,Rate decimal (5,2)
        ,Logdate datetime);
INSERT INTO #Rates (city, rate, logdate) 
VALUES ('Dallas',  1.5, '4/1/20'),
	('Dallas',  2.5, '4/11/20'),
	('Dallas',  4, '4/12/20'),
	('Dallas',  3.5, '4/13/20'),
	('Dallas',  2.5, '4/14/20'),
	('Dallas',  .5, '4/15/20');

--8.4.1
SELECT Symbol, TradingDate, OpeningPrice, ClosingPrice,
    ClosingPrice - LAG(ClosingPrice)
 OVER(PARTITION BY Symbol ORDER BY TradingDate)
 AS ClosingPriceChange
FROM #Stock;

--8.4.2
SELECT Symbol, TradingDate, OpeningPrice, ClosingPrice,
    ClosingPrice - LAG(ClosingPrice,1,ClosingPrice)
    OVER(PARTITION BY Symbol ORDER BY TradingDate)
   AS ClosingPriceChange
FROM #Stock;

--8.4.3
SELECT city, rate, logdate, 
    PERCENT_RANK() OVER (ORDER BY Rate) AS PercentRank
FROM #Rates;

--8.4.4
SELECT city, rate, logdate, 
  PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Rate) OVER() AS Median
FROM #Rates;
