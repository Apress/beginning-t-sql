/*
Chapter 7 solution
*/

USE AdventureWorks2019;
GO

--7.1.1


--7.1.2
SELECT SUM(OrderQty) AS TotalProductsOrdered
FROM Sales.SalesOrderDetail;


--7.1.3
SELECT MAX(UnitPrice) AS MostExpensivePrice
FROM Sales.SalesOrderDetail;

--7.1.4
SELECT AVG(Freight) AS AverageFreight
FROM Sales.SalesOrderHeader;

--7.1.5
SELECT MIN(ListPrice) AS Minimum,
    MAX(ListPrice) AS Maximum,
    AVG(ListPrice) AS Average
FROM Production.Product;

USE WideWorldImporters;
GO
--7.1.6
SELECT AVG(UnitPrice) AS AvgPrice
FROM Sales.OrderLines AS OL;

--7.1.7
SELECT MAX(TransactionAmount)
FROM Purchasing.SupplierTransactions;

USE AdventureWorks2019;
GO
--7.2.1
SELECT SUM(OrderQty) AS TotalOrdered, ProductID
FROM Sales.SalesOrderDetail
GROUP BY ProductID;

--7.2.2
SELECT COUNT(*) AS CountOfOrders, SalesOrderID
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;

--7.2.3
SELECT COUNT(*) AS CountOfProducts, ProductLine
FROM Production.Product
GROUP BY ProductLine;

--7.2.4
SELECT CustomerID, COUNT(*) AS CountOfSales,
    YEAR(OrderDate) AS OrderYear
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, YEAR(OrderDate);

USE WideWorldImporters;
GO
--7.2.5
SELECT
    Continent
    ,COUNT(Countryname) AS CountCountries
FROM Application.Countries
GROUP BY continent;


--7.2.6
SELECT InvoiceID, COUNT(*) AS cnt
FROM Sales.InvoiceLines;

/*
Column 'Sales.InvoiceLines.InvoiceID' is invalid in the select list because it is not contained in either an aggregate function or the GROUP BY clause.

This error is common and you will see it more often than others - this says that you need InvoiceID in the GROUP BY clause as below:
*/

SELECT 
    InvoiceID
    ,COUNT(*) AS cnt  
FROM Sales.InvoiceLines
GROUP BY InvoiceID;

--The rule of thumb is...in the SELECT list, any non-aggregated columns must be included in the GROUP BY. 

USE AdventureWorks2019;
GO

--7.3.1
SELECT COUNT(*) AS CountOfDetailLines, SalesOrderID
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING COUNT(*) > 3;

--7.3.2
SELECT SUM(LineTotal) AS SumOfLineTotal, SalesOrderID
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(LineTotal) > 1000;


--7.3.3
SELECT ProductModelID, COUNT(*) AS CountOfProducts
FROM Production.Product
GROUP BY ProductModelID
HAVING COUNT(*) = 1;

--7.3.4
SELECT ProductModelID, COUNT(*) AS CountOfProducts, Color
FROM Production.Product
WHERE Color IN ('Blue','Red')
GROUP BY ProductModelID, Color
HAVING COUNT(*) = 1;

USE WideWorldImporters;
GO
--7.3.5
SELECT StockItemID, SUM(QuantityOnHand) AS SumQTYOnhand
FROM  Warehouse.StockItemHoldings AS h   
GROUP BY StockItemID 
ORDER BY SUM(QuantityOnHand) DESC;

--7.3.6
SELECT TransactionDate, COUNT(*) AS TransactionCount 
FROM Purchasing.SupplierTransactions
WHERE DATEPART(QUARTER,TransactionDate) = 1
	AND YEAR(TransactionDate) = 2016
GROUP BY TransactionDate
HAVING COUNT(*) > 1;


USE AdventureWorks2019;
GO

--7.4.1
SELECT COUNT(DISTINCT ProductID) AS CountOFProductID
FROM Sales.SalesOrderDetail;

--7.4.2
SELECT COUNT(DISTINCT TerritoryID) AS CountOfTerritoryID,
    CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

USE WideWorldImporters;
GO
--7.4.3
SELECT  DISTINCT UnitPrice
FROM Sales.OrderLines
ORDER BY UnitPrice DESC;

--7.4.4
SELECT   UnitPrice
FROM Sales.OrderLines
GROUP BY UnitPrice
ORDER BY UnitPrice DESC;


USE AdventureWorks2019;
GO

--7.5.1
SELECT COUNT(*) AS CountOfOrders, FirstName,
    MiddleName, LastName
FROM Person.Person AS P
INNER JOIN Sales.Customer AS C ON P.BusinessEntityID = C.PersonID
INNER JOIN Sales.SalesOrderHeader
    AS SOH ON C.CustomerID = SOH.CustomerID
GROUP BY FirstName, MiddleName, LastName;


--7.5.2
SELECT SUM(OrderQty) SumOfOrderQty, P.Name, SOH.OrderDate
FROM Sales.SalesOrderHeader AS SOH
INNER JOIN Sales.SalesOrderDetail AS SOD
    ON SOH.SalesOrderID = SOD.SalesOrderDetailID
INNER JOIN Production.Product AS P ON SOD.ProductID = P.ProductID
GROUP BY P.Name, SOH.OrderDate;

USE WideWorldImporters;
GO
--7.5.3
SELECT s.SupplierID,
       s.SupplierName,
	   sc.SupplierCategoryName,
       pp.FullName AS SupplierContact,  
       s.PhoneNumber,
       s.FaxNumber,
       s.WebsiteURL,
       COUNT(O.PurchaseOrderID) AS CountaOfPOs
FROM Purchasing.Suppliers AS s
JOIN Purchasing.SupplierCategories AS sc
    ON s.SupplierCategoryID = sc.SupplierCategoryID
JOIN [Application].People AS pp
ON s.PrimaryContactPersonID = pp.PersonID
LEFT OUTER JOIN Purchasing.PurchaseOrders O 
    ON O.SupplierID = s.SupplierID
GROUP BY
	s.SupplierID,
    s.SupplierName,
	sc.SupplierCategoryName,
	pp.FullName, 
	s.PhoneNumber,
	s.FaxNumber,
	s.WebsiteURL;

