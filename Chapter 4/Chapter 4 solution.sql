/*
Chapter 4 solution
*/

USE AdventureWorks2019;
GO

--4.1.1
SELECT AddressLine1 + '  (' + City + ' ' + PostalCode + ') ' 
FROM Person.Address;

--4.1.2
SELECT ProductID, ISNULL(Color, 'No Color') AS Color, Name 
FROM Production.Product;

--4.1.3
SELECT ProductID, Name + ISNULL(': ' + Color,'') AS Description 
FROM Production.Product;
--You can also use COALESCE in place of ISNULL in both Questions 2 and 3.


--4.1.4
--Here are two possible answers:
SELECT CAST(ProductID AS VARCHAR) + ': ' +  Name AS IDName 
FROM Production.Product;

SELECT CONVERT(VARCHAR, ProductID) + ': ' + Name AS IDName 
FROM Production.Product;

USE WideWorldImporters;
GO

--4.1.5
SELECT CONCAT(CityName, '-', LatestRecordedPopulation) AS  'City-Pop'
FROM Application.Cities;
--Notice how CONCAT handles the conversion of the integer to varchar for you.

--4.1.6
SELECT CONCAT(FullName, ' (', SearchName, ')') 
FROM Application.People;

--4.1.7
SELECT  [CityName]   
      ,[LatestRecordedPopulation]
      ,ISNULL(LatestRecordedPopulation, 0)
FROM  [Application].[Cities];

--4.1.8
/*
This error is returned
Msg 8114, Level 16, State 5, Line 1
Error converting data type varchar to bigint.

*/

--4.1.9
/*
You can use ISNULL to replace a NULL value or column with another 
value or column. You can use COALESCE to return the first non-NULL 
value from a list of values or columns.
*/

USE AdventureWorks2019;
GO
--4.2.1
SELECT SpecialOfferID, Description,
     MaxQty - MinQty AS Diff 
FROM Sales.SpecialOffer;

--4.2.2
SELECT SpecialOfferID, Description, MinQty * DiscountPct AS Discount 
FROM Sales.SpecialOffer;

--4.2.3
SELECT SpecialOfferID, Description,
     ISNULL(MaxQty,10) * DiscountPct AS Discount 
FROM Sales.SpecialOffer;

USE WideWorldImporters;
GO

--4.2.4
SELECT StockItemID, 
     Quantity * UnitPrice AS ExtendedPrice, 
     Quantity * UnitPrice * .15 AS Tax, 
     Quantity * UnitPrice  + (Quantity * UnitPrice * .15) As ExtendedAmount
FROM sales.orderlines;


--4.2.5
/*

When performing division, you divide two numbers, and the result, the quotient, is the answer. 
If you are using modulo, you divide two numbers, but the reminder is the answer. If the numbers 
are evenly divisible, the answer will be zero.
*/

USE AdventureWorks2019;
GO

--4.3.1
--Here are two possible solutions:
SELECT LEFT(AddressLine1,10) AS Address10 
FROM Person.Address;

SELECT SUBSTRING(AddressLine1,1,10) AS Address10 
FROM Person.Address;

--4.3.2
SELECT SUBSTRING(AddressLine1,10,6) AS Address10to15 
FROM Person.Address;

--4.3.3
SELECT UPPER(FirstName) AS FirstName,
     UPPER(LastName) AS LastName 
FROM Person.Person;


--4.3.4
--Step 1 
SELECT ProductNumber, CHARINDEX('-',ProductNumber) 
FROM Production.Product;

--Step 2 
SELECT ProductNumber,
     SUBSTRING(ProductNumber,CHARINDEX('-',ProductNumber)+1,25) AS ProdNumber 
FROM Production.Product;


USE WideWorldImporters;
GO
--4.3.5
SELECT UPPER(LEFT(CountryName,3)) AS NewCode, IsoAlpha3Code
FROM Application.Countries;


--4.3.6
SELECT  SUBSTRING(customername, 
    CHARINDEX('(', customername), CHARINDEX(')',     CustomerName))
FROM [Sales].[Customers];


USE AdventureWorks2019;
GO
--4.4.1
SELECT SalesOrderID, OrderDate, ShipDate,
      DATEDIFF(day,OrderDate,ShipDate) AS NumberOfDays 
FROM Sales.SalesOrderHeader;

--4.4.2
SELECT CONVERT(VARCHAR(12),OrderDate,111) AS OrderDate,
     CONVERT(VARCHAR(12), ShipDate,111) AS ShipDate 
FROM Sales.SalesOrderHeader;
--another solution
SELECT CAST(OrderDate AS DATE) AS OrderDate, 
	CAST(ShipDate AS DATE) AS ShipDate
FROM Sales.SalesOrderHeader;

--4.4.3
SELECT SalesOrderID, OrderDate,
     DATEADD(month,6,OrderDate) AS Plus6Months 
FROM Sales.SalesOrderHeader;

--4.4.4
--Here are two possible solutions:
SELECT SalesOrderID, OrderDate, YEAR(OrderDate) AS OrderYear,
     MONTH(OrderDate) AS OrderMonth 
FROM Sales.SalesOrderHeader;

SELECT SalesOrderID, OrderDate, DATEPART(yyyy,OrderDate) AS OrderYear,
     DATEPART(month,OrderDate) AS OrderMonth 
FROM Sales.SalesOrderHeader;

--4.4.5
SELECT SalesOrderID, OrderDate,
     DATEPART(yyyy,OrderDate) AS OrderYear,
     DATENAME(month,OrderDate) AS OrderMonth
FROM Sales.SalesOrderHeader;

--4.4.6
SELECT DATEADD(QQ, -5, GETDATE());

--4.5.1
SELECT SalesOrderID, ROUND(SubTotal,2) AS SubTotal 
FROM Sales.SalesOrderHeader;

--4.5.2
SELECT SalesOrderID, ROUND(SubTotal,0) AS SubTotal 
FROM Sales.SalesOrderHeader;

--4.5.3
SELECT SQRT(SalesOrderID) AS OrderSQRT 
FROM Sales.SalesOrderHeader;

--4.5.4
SELECT CAST(RAND() * 10 AS INT) + 1;

--4.5.5
SELECT ROUND(55.6854, 0); -- 56.0000
SELECT ROUND(55.6854, 1); -- 55.7000
SELECT ROUND(55.6854, 2); -- 55.6900
SELECT ROUND(55.6854, 3); -- 55.6850
SELECT ROUND(55.6854, 4); -- 55.6854

--4.5.6
/*

The SQRT function works well for both integers and decimals. Use the SQUARE function and square the value - it doesn't exactly equal 9.3...why?
*/


--4.6.1
SELECT BusinessEntityID,
     CASE BusinessEntityID % 2
     WHEN 0 THEN 'Even' ELSE 'Odd' END 
FROM HumanResources.Employee;

--4.6.2
SELECT SalesOrderID, OrderQty,
     CASE WHEN OrderQty BETWEEN 0 AND 9
            THEN 'Under 10'
        WHEN OrderQty BETWEEN 10 AND 19
            THEN '10-19'
        WHEN OrderQty BETWEEN 20 AND 29
            THEN '20-29'
        WHEN OrderQty BETWEEN 30 AND 39
            THEN '30-39'
        ELSE '40 and over' end AS range 
FROM Sales.SalesOrderDetail;


--4.6.3
SELECT COALESCE(Title + ' ', '') + FirstName +
     COALESCE(' ' + MiddleName,'') + ' ' + LastName +
     COALESCE(', ' + Suffix,'') 
FROM Person.Person;

--4.6.4
SELECT SERVERPROPERTY('Edition'),
     SERVERPROPERTY('InstanceName'),
     SERVERPROPERTY('MachineName');

USE WideWorldImporters;
GO
--4.6.5
SELECT PurchaseOrderID
	,CASE WHEN DeliveryMethodID IN (7,8,9,10) THEN 'Freight'		
		ELSE 'Courier/Other'
	END AS DeliveryMethod
FROM Purchasing.PurchaseOrders;

--4.6.6
SELECT PurchaseOrderID
	  , IIF(DeliveryMethodID IN (7,8,9,10), 'Freight', 'Courier/Other')  as DeliveryMethod 
FROM Purchasing.PurchaseOrders;

