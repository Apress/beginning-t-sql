/*
Chapter 9 solution
*/

USE AdventureWorks2019;
GO

--9.1.1
SELECT ProductID, Name
FROM Production.Product
WHERE Name LIKE 'Chain%';

--9.1.2
SELECT ProductID, Name
FROM Production.Product
WHERE Name LIKE '%Paint%';
 

--9-1.3
SELECT ProductID, Name
FROM Production.Product
WHERE Name NOT LIKE '%Paint%';

--9.1.4
SELECT BusinessEntityID,
     FirstName, MiddleName,
     LastName
FROM Person.Person
WHERE MiddleName LIKE '%[EB]%';


--9.1.5
SELECT FirstName
FROM Person.Person
WHERE LastName LIKE 'Ja%es';
 
SELECT FirstName
FROM Person.Person
WHERE LastName LIKE 'Ja_es'; 

/*

The first query will find any rows with a last name that starts with Ja and ends with es. 
There can be any number of characters in between. The second query allows only one character in between Ja and es.
*/

USE WideWorldImporters;
GO
--9.1.6
SELECT StockItemID, StockItemName 
FROM Warehouse.StockItems
WHERE StockItemName LIKE 'USB%';

--9.1.7
SELECT TOP (5000) [CustomerID]
      ,[CustomerName]
FROM [WideWorldImporters].[Sales].[Customers]
WHERE CustomerName LIKE 'Jo';

/*
Since there are no wildcards (%_), only rows where the CustomerName is exactly Jo will be returned. Since there are none, no rows come back.
*/

USE AdventureWorks2019;
GO

--9.2.1
SELECT SalesOrderID, OrderDate, TotalDue, CreditCardID
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2012/01/01'
    AND OrderDate < '2013/01/01'
    AND (TotalDue > 1000 OR CreditCardID IS NOT NULL);

--9.2.2
SELECT SUB.Name AS [SubCategory Name],
    P.Name AS [Product Name], ProductID, Color
FROM Production.Product P
JOIN Production.ProductSubcategory SUB
    ON P.ProductSubcategoryID = SUB.ProductSubcategoryID
WHERE (SUB.Name LIKE '%mountain%' OR P.name like '%mountain%')
    AND Color = 'Silver';

USE WideWorldImporters;
GO
--9.2.3
SELECT SP.StateProvinceName, SP.LatestRecordedPopulation, 
       C.CityName, C.LatestRecordedPopulation
FROM Application.Cities AS C
JOIN Application.StateProvinces AS SP 
	ON C.StateProvinceID = SP.StateProvinceID
WHERE C.LatestRecordedPopulation > 1000000
	AND SP.LatestRecordedPopulation > 10000000;

--9.2.4
SELECT SP.StateProvinceName, SP.LatestRecordedPopulation, 
    C.CityName, C.LatestRecordedPopulation
FROM Application.Cities AS C
JOIN Application.StateProvinces AS SP 
	ON C.StateProvinceID = SP.StateProvinceID
WHERE C.LatestRecordedPopulation > 1000000
	OR SP.LatestRecordedPopulation > 10000000;

USE AdventureWorks2019;
GO

--9.3.1
SELECT ProductID, Comments
FROM Production.ProductReview
WHERE CONTAINS(Comments,'socks');

--9.3.2
SELECT Title, FileName
FROM Production.Document
WHERE CONTAINS(*,'reflector');

--9.3.3
SELECT Title, FileName
FROM Production.Document
WHERE CONTAINS(*,'reflector AND NOT seat');


--9.3.4
SELECT Title, FileName, DocumentSummary
FROM Production.Document
WHERE FREETEXT(*,'replaced');

USE WideWorldImporters;
GO
--9.3.5
EXEC [Application].[Configuration_ApplyFullTextIndexing]
GO
SELECT StockItemID, StockItemName
FROM Warehouse.StockItems
WHERE CONTAINS(SearchDetails,'SELECT');

--9.3.6
SELECT PersonID, FullName, CustomFields
FROM Application.People AS P 
INNER JOIN 
FREETEXTTABLE(Application.People,CustomFields,'member') AS M
ON P.PersonID = M.[key];
