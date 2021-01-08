/*
Chapter 8 code
*/

--Listing 8-1. Using the Ranking Functions
--1
SELECT CustomerID,
    ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNum,
    RANK() OVER(ORDER BY CustomerID) AS RankNum,
    DENSE_RANK() OVER(ORDER BY CustomerID) AS DenseRankNum,
    ROW_NUMBER() OVER(ORDER BY CustomerID DESC) AS ReverseRowNum
FROM Sales.Customer
WHERE CustomerID BETWEEN 11000 AND 11200
ORDER BY CustomerID;
 
--2
SELECT SalesOrderID, CustomerID,
    ROW_NUMBER() OVER(ORDER BY CustomerID) AS RowNum,
    RANK() OVER(ORDER BY CustomerID) AS RankNum,
    DENSE_RANK() OVER(ORDER BY CustomerID) AS DenseRankNum
FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 11000 AND 11200
ORDER BY CustomerID;

--Listing 8-2. Using the NTILE Function
SELECT SP.FirstName, SP.LastName,
    SUM(SOH.TotalDue) AS TotalSales,
    NTILE(4) OVER(ORDER BY SUM(SOH.TotalDue)) AS Bucket
FROM [Sales].[vSalesPerson] SP
JOIN Sales.SalesOrderHeader SOH ON SP.BusinessEntityID = SOH.SalesPersonID
WHERE SOH.OrderDate >= '2013-01-01' AND SOH.OrderDate < '2014-01-01'
GROUP BY FirstName, LastName
ORDER BY TotalSales;
 
--2
SELECT SP.FirstName, SP.LastName,
        SUM(SOH.TotalDue) AS TotalSales,
        NTILE(4) OVER(ORDER BY SUM(SOH.TotalDue)) * 1000 AS Bonus
FROM [Sales].[vSalesPerson] SP
JOIN Sales.SalesOrderHeader SOH ON SP.BusinessEntityID = SOH.SalesPersonID
WHERE SOH.OrderDate >= '2013-01-01' AND SOH.OrderDate < '2014-01-01'
GROUP BY FirstName, LastName
ORDER BY TotalSales;


--Listing 8-3. Using PARTITION BY
SELECT SalesOrderID, OrderDate, CustomerID,
    ROW_NUMBER() OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS RowNum
FROM Sales.SalesOrderHeader
ORDER BY CustomerID;
 
--Listing 8-4. Using Window Aggregates
--1
SELECT SalesOrderID, CustomerID,
    COUNT(*) OVER() AS CountOfSales,
    COUNT(*) OVER(PARTITION BY CustomerID) AS CountOfCustSales,
    SUM(TotalDue) OVER(PARTITION BY CustomerID) AS SumOfCustSales
FROM Sales.SalesOrderHeader
ORDER BY CustomerID;
 
--2
SELECT SalesOrderID, CustomerID,
    COUNT(*) OVER() AS CountOfSales,
    COUNT(*) OVER(PARTITION BY CustomerID) AS CountOfCustSales,
    SUM(TotalDue) OVER(PARTITION BY CustomerID) AS SumOfCustSales
FROM Sales.SalesOrderHeader
where SalesOrderId > 55000
ORDER BY CustomerID;

--Listing 8-5. Using Window Functions to Calculate Running Totals
--1
SELECT SalesOrderID, CustomerID, TotalDue,
    SUM(TotalDue) OVER(PARTITION BY CustomerID
        ORDER BY SalesOrderID)
        AS RunningTotal
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;
 
--2
SELECT SalesOrderID, CustomerID, TotalDue,
    SUM(TotalDue) OVER(PARTITION BY CustomerID
        ORDER BY SalesOrderID
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING)
        AS ReverseTotal
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;

--Listing 8-6. Demonstrate the Difference Between ROWS and RANGE
SELECT SalesOrderID, OrderDate,CustomerID, TotalDue,
    SUM(TotalDue) OVER(PARTITION BY CustomerID
        ORDER BY OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS ROWS_RT,
        SUM(TotalDue) OVER(PARTITION BY CustomerID
        ORDER BY OrderDate
        RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS RANGE_RT
FROM Sales.SalesOrderHeader
WHERE CustomerID = 29837;

--Listing 8-7. Using LAG and LEAD
--1
SELECT SalesOrderID, OrderDate,CustomerID,
    LAG(OrderDate) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) AS PrevOrderDate,
    LEAD(OrderDate) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID) AS FollowingOrderDate
FROM Sales.SalesOrderHeader;
 
--2
SELECT SalesOrderID, OrderDate,CustomerID,
    DATEDIFF(d,LAG(OrderDate,1,OrderDate)
            OVER(PARTITION BY CustomerID ORDER BY SalesOrderID), OrderDate)
            AS DaysSinceLastOrder
FROM Sales.SalesOrderHeader;

--Listing 8-8. Using FIRST_VALUE and LAST_VALUE
SELECT SalesOrderID, OrderDate,CustomerID,
    FIRST_VALUE(OrderDate) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS FirstOrderDate,
    LAST_VALUE(OrderDate) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID
        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS LastOrderDate,
        LAST_VALUE(OrderDate) OVER(PARTITION BY CustomerID ORDER BY SalesOrderID)
            AS DefaultFrame
FROM Sales.SalesOrderHeader
ORDER BY CustomerID, SalesOrderID;


--Listing 8-9. Using PERCENT_RANK and CUME_DIST
SELECT COUNT(*) NumberOfOrders, Month(OrderDate) AS OrderMonth,
     PERCENT_RANK() OVER(ORDER BY COUNT(*)) AS PercentRank,
     CUME_DIST() OVER(ORDER BY COUNT(*)) AS CumeDist
FROM Sales.SalesOrderHeader
GROUP BY Month(OrderDate);

--Listing 8-10. Using PERCENTILE_CONT and PERCENTILE_DISC
SELECT COUNT(*) NumberOfOrders, Month(OrderDate) AS OrderMonth,
     PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY COUNT(*)) OVER() AS PercentileCont,
     PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY COUNT(*)) OVER() AS PercentileDisc
FROM Sales.SalesOrderHeader
GROUP BY Month(OrderDate);


--Listing 8-11. Using ROW_NUMBER() to Remove Duplicate Rows
--1
CREATE TABLE #Dupes (
    COL1 INT, Col2 INT, Col3 INT);
 
INSERT INTO #Dupes (Col1, Col2, Col3)
VALUES (1,1,1),(1,1,1),(1,2,3),(1,2,2),(1,2,2),
    (2,3,3),(2,3,3),(2,3,3),(2,3,3);
 
--2
SELECT Col1, Col2, Col3,
    ROW_NUMBER() OVER(PARTITION BY Col1, Col2, Col3 ORDER BY Col1, Col2, Col3) AS RowNum
FROM #Dupes;
 
--3
WITH Dupes AS (
        SELECT Col1, Col2, Col3,
          ROW_NUMBER() OVER(PARTITION BY Col1, Col2, Col3 ORDER BY Col1, Col2, Col3) AS RowNum
    FROM #Dupes)
SELECT Col1, Col2, Col3, RowNum
FROM Dupes
WHERE RowNum = 1;
 
--4
WITH Dupes AS (
        SELECT Col1, Col2, Col3,
          ROW_NUMBER() OVER(PARTITION BY Col1, Col2, Col3 ORDER BY Col1, Col2, Col3) AS RowNum
    FROM #Dupes)
DELETE Dupes
WHERE RowNum > 1;
 
--5
SELECT Col1, Col2, Col3
FROM #Dupes;


--Listing 8-12. Solving an Island Problem
--1
CREATE TABLE #Island(Col1 INT);
 
INSERT INTO #Island (Col1)
VALUES(1),(2),(3),(5),(6),(7),(9),(9),(10);
 
--2
SELECT Col1, DENSE_RANK() OVER(ORDER BY Col1) AS RankNum,
       Col1 - DENSE_RANK() OVER(ORDER BY Col1) AS Diff
FROM #Island;
 
--3
WITH islands AS (
    SELECT Col1, Col1 - DENSE_RANK() OVER(ORDER BY Col1) AS Diff
    FROM #Island)
SELECT MIN(Col1) AS Beginning, MAX(Col1) AS Ending
FROM islands
GROUP BY Diff;


--Listing 8-13. The Difference Between Using Window Aggregates and Traditional Techniques
--1
ALTER DATABASE [AdventureWorks2019] SET COMPATIBILITY_LEVEL = 140
GO
SET STATISTICS IO ON;
GO
--2
SELECT CustomerID, SalesOrderID, TotalDue,
    SUM(TotalDue) OVER(PARTITION BY CustomerID) AS CustTotal
FROM Sales.SalesOrderHeader;
 
--3
WITH Totals AS (
   SELECT CustomerID, SUM(TotalDue) AS CustTotal
   FROM Sales.SalesOrderHeader
   GROUP BY CustomerID)
SELECT Totals.CustomerID, SalesOrderID, TotalDue, CustTotal
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Totals ON SOH.CustomerID = Totals.CustomerID;

--Listing 8-14. Performance Differences Between ROWS and RANGE
--1
SELECT SalesOrderID, TotalDue, CustomerID,
    SUM(TotalDue) OVER(PARTITION BY CustomerID ORDER BY OrderDate) AS RunningTotal
FROM Sales.SalesOrderHeader;
 
--2
SELECT SalesOrderID, TotalDue, CustomerID,
    SUM(TotalDue) OVER(PARTITION BY CustomerID ORDER BY OrderDate
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Sales.SalesOrderHeader;
