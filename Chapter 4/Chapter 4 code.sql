/*
Chapter 4 code
*/

--Listing 4-1. Concatenating Strings
--1
SELECT 'ab' + 'c';
 
--2
SELECT BusinessEntityID, FirstName + ' ' + LastName AS [Full Name]
FROM Person.Person;
 
--3
SELECT BusinessEntityID, LastName + ', ' + FirstName AS [Full Name]
FROM Person.Person;

--Listing 4-2. Concatenating Strings with NULL Values
SELECT BusinessEntityID, FirstName + ' ' + MiddleName +
    ' ' + LastName AS [Full Name]
FROM Person.Person;

--Listing 4-3. CONCAT Examples
--1 Simple CONCAT function
SELECT CONCAT ('I ', 'love', ' writing', ' T-SQL') AS RESULT;
 
--2 Using variable with CONCAT
DECLARE @a VARCHAR(30) = 'My birthday is on '
DECLARE @b DATE = '1980/08/25'
SELECT CONCAT (@a, @b) AS RESULT;
 
--3 Using CONCAT with table rows
SELECT CONCAT (AddressLine1, PostalCode) AS Address
FROM Person.Address;
 
--4 Using CONCAT with NULL
SELECT CONCAT ('I',' ','love', ' ', 'using',' ','CONCAT',' ',
    'because',' ','NULL',' ','values',
    ' ','vanish',' ','SEE:',NULL,'!') AS RESULT;

--Listing 4-4. Using the ISNULL and COALESCE Functions
--1
SELECT BusinessEntityID, FirstName + ' ' + ISNULL(MiddleName,'') +
    ' ' + LastName AS [Full Name]
FROM Person.Person;
 
--2
SELECT BusinessEntityID, FirstName + ISNULL(' ' + MiddleName,'') +
    ' ' + LastName AS [Full Name]
FROM Person.Person;
 
--3
SELECT BusinessEntityID, FirstName + COALESCE(' ' + MiddleName,'') +
    ' ' + LastName AS [Full Name]
FROM Person.Person;

--Listing 4-5. Using CAST and CONVERT
--1
SELECT CAST(BusinessEntityID AS NVARCHAR) + ': ' + LastName
    + ', ' + FirstName AS ID_Name
FROM Person.Person;
 
--2
SELECT CONVERT(NVARCHAR(10),BusinessEntityID) + ': ' + LastName
    + ', ' + FirstName AS ID_Name
FROM Person.Person;
 
--3
SELECT BusinessEntityID, BusinessEntityID + 1 AS "Adds 1",
    CAST(BusinessEntityID AS NVARCHAR(10)) + '1' AS "Appends 1"
FROM Person.Person;


--Listing 4-6. Using Mathematical Operators
--1
SELECT 1 + 1 AS ADDITION, 10.0 / 3 AS DIVISION, 10 / 3 AS [Integer Division], 10 % 3 AS MODULO;
 
--2
SELECT OrderQty, OrderQty * 10 AS Times10
FROM Sales.SalesOrderDetail;
 
--3
SELECT OrderQty * UnitPrice * (1.0 - UnitPriceDiscount)
    AS Calculated, LineTotal
FROM Sales.SalesOrderDetail;
 
--4
SELECT SpecialOfferID,MaxQty,DiscountPct,
    DiscountPct * ISNULL(MaxQty, 1000) AS MaxDiscount
FROM Sales.SpecialOffer;

--Listing 4-7. Using the RTRIM, LTRIM, and TRIM  Functions
--Create the temp table
CREATE TABLE #trimExample (COL1 VARCHAR(10));
GO
--Populate the table
INSERT INTO #trimExample (COL1)
VALUES ('a'),('b  '),('  c'),('  d  ');
 
--Select the values using the functions
SELECT COL1, '*' + RTRIM(COL1) + '*' AS "RTRIM",
    '*' + LTRIM(COL1) + '*' AS "LTRIM", 
    '*' + TRIM(COL1) + '*' AS "TRIM"
FROM #trimExample; 
--Clean up
DROP TABLE #trimExample;

--Listing 4-8. Using the LEFT and RIGHT Functions
SELECT LastName,LEFT(LastName,5) AS "LEFT",
    RIGHT(LastName,4) AS "RIGHT"
FROM Person.Person
WHERE BusinessEntityID IN (293,295,211,297,299,3057,15027);


--Listing 4-9. Using the LEN and DATALENGTH Functions
SELECT LastName,LEN(LastName) AS "Length",
    DATALENGTH(LastName) AS "Internal Data Length"
FROM Person.Person
WHERE BusinessEntityID IN (293,295,211,297,299,3057,15027);

--Listing 4-10. Using the CHARINDEX Function
SELECT LastName, CHARINDEX('e',LastName) AS "Find e",
    CHARINDEX('e',LastName,4) AS "Skip 3 Characters",
    CHARINDEX('be',LastName) AS "Find be",
    CHARINDEX('Be',LastName) AS "Find Be"
FROM Person.Person
WHERE BusinessEntityID IN (293,295,211,297,299,3057,15027);


--Listing 4-11. Using the SUBSTRING Function
SELECT LastName, SUBSTRING(LastName,1,4) AS "First 4",
    SUBSTRING(LastName,5,50) AS "Characters 5 and later"
FROM Person.Person
WHERE BusinessEntityID IN (293,295,211,297,299,3057,15027);

--Listing 4-12. Using the CHOOSE Function
SELECT CHOOSE (4, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i');


SELECT REVERSE('!dlroW ,olleH');

--Listing 4-13. Using the UPPER and LOWER Functions
SELECT LastName, UPPER(LastName) AS "UPPER",
    LOWER(LastName) AS "LOWER"
FROM Person.Person
WHERE BusinessEntityID IN (293,295,211,297,299,3057,15027);

--Listing 4-14. Using the REPLACE Function
--1
SELECT LastName, REPLACE(LastName,'A','Z') AS "Replace A",
    REPLACE(LastName,'A','ZZ') AS "Replace with 2 characters",
    REPLACE(LastName,'ab','') AS "Remove string"
FROM Person.Person
WHERE BusinessEntityID IN (293,295,211,297,299,3057,15027);
 
--2
SELECT BusinessEntityID,LastName,MiddleName,
    REPLACE(LastName,'a',MiddleName) AS "Replace with MiddleName",
    REPLACE(LastName,MiddleName,'a') AS "Replace MiddleName"
FROM Person.Person
WHERE BusinessEntityID IN (285,293,10314);


--Listing 4-15. Using STRING_SPLIT and STRING_AGG
--1
SELECT value 
FROM STRING_SPLIT('1,2,3,4,5,6,7,8,9,10',',');

--2
SELECT value 
FROM STRING_SPLIT('dog cat fish bird lizard',' ');

--3
SELECT STRING_AGG(Name, ', ') AS List
FROM Production.ProductCategory;


--Listing 4-16. Nesting Functions
--1
SELECT EmailAddress,
    SUBSTRING(EmailAddress,CHARINDEX('@',EmailAddress) + 1,50) AS DOMAIN
FROM Production.ProductReview;
 
--2
SELECT physical_name,
    RIGHT(physical_name,CHARINDEX('\',REVERSE(physical_name))-1) AS FileName
FROM sys.database_files;

SELECT GETDATE(), SYSDATETIME();

--Listing 4-17. Using the DATEADD Function
--1
SELECT OrderDate, DATEADD(year,1,OrderDate) AS OneMoreYear,
    DATEADD(month,1,OrderDate) AS OneMoreMonth,
    DATEADD(day,-1,OrderDate) AS OneLessDay
FROM Sales.SalesOrderHeader
WHERE SalesOrderID in (43659,43714,60621);
 
--2
SELECT DATEADD(month,1,'2009-01-29') AS FebDate;
 

--Listing 4-18. Using the DATEDIFF Function
--1
SELECT OrderDate, GETDATE() CurrentDateTime,
    DATEDIFF(year,OrderDate,GETDATE()) AS YearDiff,
    DATEDIFF(month,OrderDate,GETDATE()) AS MonthDiff,
    DATEDIFF(d,OrderDate,GETDATE()) AS DayDiff
FROM Sales.SalesOrderHeader
WHERE SalesOrderID in (43659,43714,60621);
 
--2
SELECT DATEDIFF(year,'2008-12-31','2009-01-01') AS YearDiff,
    DATEDIFF(month,'2008-12-31','2009-01-01') AS MonthDiff,
    DATEDIFF(d,'2008-12-31','2009-01-01') AS DayDiff;
 
 --Listing 4-19. Using the DATENAME and DATEPART Functions
--1
SELECT OrderDate, DATEPART(year,OrderDate) AS OrderYear,
    DATEPART(month,OrderDate) AS OrderMonth,
    DATEPART(day,OrderDate) AS OrderDay,
    DATEPART(weekday,OrderDate) AS OrderWeekDay
FROM Sales.SalesOrderHeader
WHERE SalesOrderID in (43659,43714,60621);
 
--2
SELECT OrderDate, DATENAME(year,OrderDate) AS OrderYear,
    DATENAME(month,OrderDate) AS OrderMonth,
    DATENAME(day,OrderDate) AS OrderDay,
    DATENAME(weekday,OrderDate) AS OrderWeekDay
FROM Sales.SalesOrderHeader
WHERE SalesOrderID in (43659,43714,60621);

--Listing 4-20. Using the DAY, MONTH, and YEAR Functions
SELECT OrderDate, YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    DAY(OrderDate) AS OrderDay
FROM Sales.SalesOrderHeader
WHERE SalesOrderID in (43659,43714,60621);


--Listing 4-21. Using CONVERT to Format a Date/Time Value
--1 The hard way!
SELECT CAST(DATEPART(YYYY,GETDATE()) AS VARCHAR) + '/' +
    CAST(DATEPART(MM,GETDATE()) AS VARCHAR) +
    '/' +  CAST(DATEPART(DD,GETDATE()) AS VARCHAR) AS DateCast;
 
--2 The easy way!
SELECT CONVERT(VARCHAR,GETDATE(),111) AS DateConvert;
 
--3
SELECT CONVERT(VARCHAR,OrderDate,1) AS "1",
    CONVERT(VARCHAR,OrderDate,101) AS "101",
    CONVERT(VARCHAR,OrderDate,2) AS "2",
    CONVERT(VARCHAR,OrderDate,102) AS "102"
FROM Sales.SalesOrderHeader
WHERE SalesOrderID in (43659,43714,60621);

SELECT CAST(OrderDate AS Date)
FROM Sales.SalesOrderHeader;

--Listing 4-22. FORMAT Function Examples
DECLARE @d DATETIME = GETDATE();
 
SELECT FORMAT( @d, 'dd', 'en-US' ) AS Result;
SELECT FORMAT( @d, 'yyyy-M-d') AS Result;
SELECT FORMAT( @d, 'MM/dd/yyyy', 'en-US' ) AS Result;

--Listing 4-23. DATEFROMPARTS Examples
SELECT DATEFROMPARTS(2012, 3, 10) AS RESULT;
SELECT TIMEFROMPARTS(12, 10, 32, 0, 0) AS RESULT;
SELECT DATETIME2FROMPARTS (2012, 3, 10, 12, 10, 32, 0, 0) AS RESULT;

SELECT EOMONTH(GETDATE()) AS [End of this month],
    EOMONTH(GETDATE(),1) AS [End of next month],
    EOMONTH('2020-01-01') AS [Another month];

SELECT ABS(2) AS "2", ABS(-2) AS "-2";

--Listing 4-24. Using the POWER Function
SELECT POWER(10,1) AS "Ten to the First",
    POWER(10,2) AS "Ten to the Second",
    POWER(10,3) AS "Ten to the Third";



select power(10,10)
select power(cast(10 as float),10);

--Listing 4-25. Using the SQUARE and SQRT Functions
SELECT SQUARE(10) AS "Square of 10",
    SQRT(10) AS "Square Root of 10",
    SQRT(SQUARE(10)) AS "The Square Root of the Square of 10";

--Listing 4-26. Using the ROUND Function
SELECT ROUND(1234.1294,2) AS "2 places on the right",
    ROUND(1234.1294,-2) AS "2 places on the left",
    ROUND(1234.1294,2,1) AS "Truncate 2",
    ROUND(1234.1294,-2,1) AS "Truncate -2";


--Listing 4-27. Using the RAND Function
SELECT CAST(RAND() * 100 AS INT) + 1 AS "1 to 100",
    CAST(RAND()* 1000 AS INT) + 900 AS "900 to 1900",
    CAST(RAND() * 5 AS INT)+ 1 AS "1 to 5";
 
SELECT RAND(3),RAND(),RAND();

SELECT RAND(),RAND(),RAND(),RAND()
FROM sys.objects;


--Listing 4-28. Using Simple CASE
SELECT Title,
    CASE Title
    WHEN 'Mr.' THEN 'Male'
    WHEN 'Ms.' THEN 'Female'
    WHEN 'Mrs.' THEN 'Female'
    WHEN 'Miss' THEN 'Female'
    ELSE 'Unknown' END AS Gender
FROM Person.Person
WHERE BusinessEntityID IN (1,5,6,357,358,11621,423);


--Listing 4-29. Using Searched CASE
SELECT Title,
    CASE WHEN Title IN ('Ms.','Mrs.','Miss') THEN 'Female'
    WHEN Title = 'Mr.' THEN 'Male'
    ELSE 'Unknown' END AS Gender
FROM Person.Person
WHERE BusinessEntityID IN (1,5,6,357,358,11621,423);


SELECT Title,
    CASE WHEN Title IN ('Ms.','Mrs.','Miss') THEN 1
    WHEN Title = 'Mr.' THEN 'Male'
    ELSE '1' END AS Gender
FROM Person.Person
WHERE BusinessEntityID IN (1,5,6,357,358,11621,423);

--Listing 4-30. Returning a Column Name in CASE
SELECT VacationHours,SickLeaveHours,
    CASE WHEN VacationHours > SickLeaveHours THEN VacationHours
    ELSE SickLeaveHours END AS 'More Hours'
FROM HumanResources.Employee;

--Listing 4-31. Using the IIF Function
--1 IIF function without variables
SELECT IIF (50 > 20, 'TRUE', 'FALSE') AS RESULT;
 
--2 IIF function with variables
DECLARE @a INT = 50
DECLARE @b INT = 20
SELECT IIF (@a > @b, 'TRUE', 'FALSE') AS RESULT;


--Listing 4-32. Using the COALESCE Function
SELECT ProductID,Size, Color,
    COALESCE(Size, Color,'No color or size') AS 'Description'
FROM Production.Product
where ProductID in (1,2,317,320,680,706);
 

--Listing 4-33. A Few System Functions
SELECT DB_NAME() AS "Database Name",
    HOST_NAME() AS "Host Name",
    CURRENT_USER AS "Current User",
    SUSER_NAME() AS "Login",
    USER_NAME() AS "User Name",
    APP_NAME() AS "App Name";
 

 --Listing 4-34. Using Functions in WHERE and ORDER BY
--1
SELECT FirstName
FROM Person.Person
WHERE CHARINDEX('ke',FirstName) > 0;
 
--2
SELECT LastName,REVERSE(LastName)
FROM Person.Person
ORDER BY REVERSE(LastName);
 
--3
SELECT BirthDate
FROM HumanResources.Employee
ORDER BY YEAR(BirthDate);


--Listing 4-35. Limiting Results with TOP
--1
DECLARE @Percent INT = 2;
SELECT TOP(@Percent) PERCENT CustomerID, OrderDate, SalesOrderID
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;
 
--2
SELECT TOP(2) CustomerID, OrderDate, SalesOrderID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate;
 
--3
SELECT TOP(2) WITH TIES CustomerID, OrderDate, SalesOrderID
FROM Sales.SalesOrderHeader
ORDER BY OrderDate;
 
--4
SELECT TOP(2) CustomerID, OrderDate, SalesOrderID
FROM Sales.SalesOrderHeader
ORDER BY NEWID();


--Add an index
IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id =
    OBJECT_ID(N'[Sales].[SalesOrderHeader]')
    AND name = N'DEMO_SalesOrderHeader_OrderDate')
DROP INDEX [DEMO_SalesOrderHeader_OrderDate]
    ON [Sales].[SalesOrderHeader] ;
GO
 
CREATE NONCLUSTERED INDEX [DEMO_SalesOrderHeader_OrderDate]
    ON [Sales].[SalesOrderHeader]
([OrderDate] ASC);


--Listing 4-36. Compare the Performance When Using a Function in the WHERE Clause
--1
SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2011-01-01 00:00:00'
    AND OrderDate <= '2012-01-01 00:00:00';
 
--2 
SELECT SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2011;
 
 IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id =
    OBJECT_ID(N'[Sales].[SalesOrderHeader]')
    AND name = N'DEMO_SalesOrderHeader_OrderDate')
DROP INDEX [DEMO_SalesOrderHeader_OrderDate]
    ON [Sales].[SalesOrderHeader];
