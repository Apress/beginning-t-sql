/*
Chapter 3 solution
*/
USE AdventureWorks2019;
GO

--3.1.1
SELECT CustomerID, StoreID, AccountNumber 
FROM Sales.Customer;

--3.1.2
SELECT Name, ProductNumber, Color
FROM Production.Product;

--3.1.3
SELECT CustomerID, SalesOrderID
FROM Sales.SalesOrderHeader;

USE WideWorldImporters;
GO

--3.1.4
SELECT 'State Abbr/Name:' 
      ,[StateProvinceCode] 
      ,[StateProvinceName]
 FROM [Application].[StateProvinces];

 --3.1.5
/*
(No column name) is visually defaulted as the header row value, however this is not a valid alias 
for the column; each column should have a name. Change the query to
*/

SELECT  'State Abbr/Name:' AS [ST/Name]
             ,[StateProvinceCode] 
            ,[StateProvinceName]
FROM [Application].[StateProvinces];

--3.1.6
/*
The word table is a reserved word in this case, and must either be wrapped in brackets [], 
or optionally single/double quotes. You can correct the query like this:
*/

SELECT '[Application].[StateProvinces]' AS [table];

--3.1.7
/*
You would do this to decrease the amount of network traffic and increase the performance of the query, 
retrieving only the columns needed for the application or report. 
You can also keep users from seeing confidential information by retrieving only the columns they should see.
*/



USE AdventureWorks2019;
GO
--3.2.1
SELECT BusinessEntityID, JobTitle, LoginID
FROM HumanResources.Employee
WHERE JobTitle = 'Research and Development Engineer';


--3.2.2
SELECT [ProductID]
      ,[StartDate]
      ,[EndDate]
      ,[StandardCost]
      ,[ModifiedDate] 
FROM [Production].[ProductCostHistory] 
WHERE StandardCost BETWEEN 10 and 13; 


--3.2.3
SELECT BusinessEntityID, JobTitle, LoginID 
FROM HumanResources.Employee 
WHERE JobTitle <> 'Research and Development Engineer';

USE WideWorldImporters;
GO

--3.2.4
SELECT CityName, LatestRecordedPopulation 
FROM Application.Cities 
WHERE CityName = 'Simi Valley';


--3.2.5
SELECT CustomerID, CustomerName, AccountOpenedDate
FROM Sales.Customers 
WHERE AccountOpenedDate BETWEEN '2016-01-01' AND '2016-12-31';

--3.2.6
/*
Most of the time the application or report will not require all the rows. 
The query should be filtered to include only the required rows to cut down on
network traffic and increase SQL Server performance because returning a smaller 
number of rows is usually more efficient.
*/


USE AdventureWorks2019;
GO
--3.3.1
SELECT SalesOrderID, OrderDate, TotalDue 
FROM Sales.SalesOrderHeader 
WHERE OrderDate >= '2012-09-01'
     AND OrderDate < '2012-10-01';

--3.3.2
SELECT SalesOrderID, OrderDate, TotalDue 
FROM Sales.SalesOrderHeader 
WHERE TotalDue >=10000 OR SalesOrderID < 43000;

USE WideWorldImporters;
Go
--3.3.3
SELECT * 
FROM [Application].[StateProvinces]
WHERE StateProvinceID IN (1,45);

--3.3.4
SELECT     *
FROM [Application].[StateProvinces] 
WHERE StateProvinceID = 1 OR StateProvinceID = 45;
/*
The same result should be achieved. Therefore, the IN is 
simply resolved by SQL Server as an OR operation.
*/

--3.3.5
SELECT     *
FROM [Application].[StateProvinces]
WHERE StateProvinceID NOT IN (1,45);

/*
Adding a NOT returns all StateProvinceIDs that are equal to something other than 1 or 45. 
Neither Alabama nor Texas are included in the results. Also notice that SQL Server has to 
look at each and every row in order to determine whether or not [StateProvinceID] is equal to 
1 or 45 in order to exclude those rows.
*/


--3.3.6
/*
You will want to use the IN operator when you have a small number of literal values to compare to one column.
*/

USE AdventureWorks2019;
GO
--3.4.1
SELECT ProductID, Name, Color 
FROM Production.Product 
WHERE Color IS NULL;


--3.4.2
SELECT ProductID, Name, Color 
FROM Production.Product 
WHERE Color <>'BLUE ';


--3.4.3
SELECT ProductID, Name, Style, Size, Color  
FROM Production.Product 
WHERE Color IS NOT NULL 
     OR Size IS NOT NULL;

USE WideWorldImporters;
GO
--3.4.4
SELECT *
FROM [WideWorldImporters].[Purchasing].[Suppliers]
WHERE DeliveryMethodID IS NULL;

--3.4.5
/*
Here are possible answers that are valid:
a.	A CSR forgot to enter the DeliveryMethodID into the system
b.	The DeliveryMethodID will get specified in the future by the system
c.	There was no valid delivery method
d.	The valid delivery method will be specified in the future as it is processed.
e.	The DeliveryMethodID is missing.
f.	A representative has the ID on a post-it note on her desk; she made a note and will input later.

*/

USE AdventureWorks2019;
GO

--3.5.1
SELECT BusinessEntityID, LastName, FirstName, MiddleName 
FROM Person.Person 
ORDER BY LastName, FirstName, MiddleName;

--3.5.2
SELECT BusinessEntityID, LastName, FirstName, MiddleName 
FROM Person.Person 
ORDER BY LastName DESC, FirstName DESC, MiddleName DESC; 

USE WideWorldImporters;
GO
--3.5.3
SELECT [CountryID]
      ,[CountryName]
      ,[FormalName]  
  FROM [Application].[Countries]
  ORDER BY FormalName;

--3.5.4
/*
The query still executes; it demonstrates that the 
ORDER BY specified column(s) does not need to be in the 
SELECT list as a requirement for the query to execute. 
This is not true for other syntax that will be introduced.
*/
