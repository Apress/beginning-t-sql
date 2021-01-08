/*
Chapter 10 code
*/

--Listing 10-1. Script to create a table
--1
--2016 syntax
DROP TABLE IF EXISTS dbo.demoCustomer;
/*
--pre-2016 way to check for table existence and drop table
IF EXISTS (SELECT * FROM sys.objects
            WHERE object_id = OBJECT_ID(N'[dbo].[demoCustomer]')
                AND type in (N'U'))
    DROP TABLE dbo.demoCustomer;

*/
--2
CREATE TABLE dbo.demoCustomer(CustomerID INT NOT NULL,
    FirstName NVARCHAR(50) NOT NULL, MiddleName NVARCHAR(50) NULL,
    LastName NVARCHAR(50) NOT NULL
    CONSTRAINT PK_demoCustomer PRIMARY KEY (CustomerID)); 

--Listing 10-2. Adding One Row at a Time with Literal Values
--1
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
VALUES (1, N'Orlando', N'N.', N'Gee');
 
--2
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT 3, N'Donna', N'F.', N'Cameras';
 
--3
INSERT INTO dbo.demoCustomer
VALUES (4,N'Janet', N'M.', N'Gates');
 
--4
INSERT INTO dbo.demoCustomer
SELECT 6,N'Rosmarie', N'J.', N'Carroll';
 
--5
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
VALUES (2, N'Keith', NULL, N'Harris');
 
--6
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, LastName)
VALUES (5, N'Lucy', N'Harrington');
 
--7
SELECT CustomerID, FirstName, MiddleName, LastName
FROM dbo.demoCustomer;

--Listing 10-3. Attempting to Insert Rows with Invalid INSERT Statements
PRINT '1';
--1
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
VALUES (1, N'Dominic', N'P.', N'Gash');
 
PRINT '2';
--2
INSERT INTO dbo.demoCustomer (CustomerID, MiddleName, LastName)
VALUES (10, N'M.', N'Garza');
 
GO
PRINT '3';
GO
 
--3
INSERT INTO dbo.demoCustomer
VALUES (11, N'Katherine', N'Harding');
 
GO
PRINT '4';
GO
 
--4
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, LastName)
VALUES (11, N'Katherine', NULL, N'Harding');
 
GO
PRINT '5';
GO
 
--5
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, LastName)
VALUES (N'A', N'Katherine', N'Harding');


--Listing 10-4. Inserting Multiple Rows with One INSERT
--1
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT 7, N'Dominic', N'P.', N'Gash'
UNION ALL
SELECT 10, N'Kathleen', N'M.', N'Garza'
UNION ALL
SELECT 11, N'Katherine', NULL, N'Harding';
 
--2
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
VALUES (12, N'Johnny', N'A.', N'Capino'),
       (16, N'Christopher', N'R.', N'Beck'),
       (18, N'David', N'J.', N'Liu');
 
--3
SELECT CustomerID, FirstName, MiddleName, LastName
FROM dbo.demoCustomer
WHERE CustomerID >=7;

--Listing 10-5. Inserting Rows from Another Table
--1
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE BusinessEntityID BETWEEN 19 AND 35;
 
--2
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT DISTINCT s.SalesOrderID, c.FirstName, c.MiddleName, c.LastName
FROM Person.Person AS c
INNER JOIN Sales.SalesOrderHeader AS s ON c.BusinessEntityID = s.SalesPersonID;
 
--3
SELECT CustomerID, FirstName, MiddleName, LastName
FROM dbo.demoCustomer
WHERE CustomerID > 18;


--Listing 10-6. Inserting Missing Rows
--1
SELECT COUNT(CustomerID) AS CustomerCount
FROM dbo.demoCustomer;
 
--2
INSERT INTO dbo.demoCustomer (CustomerID, FirstName, MiddleName, LastName)
SELECT c.BusinessEntityID, c.FirstName, c.MiddleName, c.LastName
FROM Person.Person AS c
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.demoCustomer a
    WHERE a.CustomerID = c.BusinessEntityID);
 
--3
SELECT COUNT(CustomerID) AS CustomerCount
FROM dbo.demoCustomer;

--Listing 10-7. Using SELECT INTO to Create and Populate a Table
--1
DROP TABLE IF EXISTS dbo.demoCustomer;
GO
 
--2
SELECT BusinessEntityID, FirstName, MiddleName, LastName,
    FirstName + ISNULL(' ' + MiddleName,'') + ' ' +  LastName AS FullName
INTO dbo.demoCustomer
FROM Person.Person;
  
--3
SELECT BusinessEntityID, FirstName, MiddleName, LastName, FullName
FROM dbo.demoCustomer;

--Listing 10-8. Inserting Data with a Column Default Constraint
DROP TABLE IF EXISTS dbo.demoDefault;
GO
 
CREATE TABLE dbo.demoDefault(
    KeyColumn int NOT NULL PRIMARY KEY,
    HasADefault1 DATETIME2 (1) NOT NULL,
    HasADefault2 NVARCHAR (50) NULL,
);
GO
ALTER TABLE dbo.demoDefault ADD  CONSTRAINT DF_demoDefault_HasADefault
    DEFAULT (GETDATE()) FOR HasADefault1;
GO
ALTER TABLE dbo.demoDefault ADD  CONSTRAINT DF_demoDefault_HasADefault2
    DEFAULT ('the default') FOR HasADefault2;
GO
 
--1
INSERT INTO dbo.demoDefault(KeyColumn, HasADefault1, HasADefault2)
VALUES (1,'2020-04-24', N'Test 1'),(2,'2020-10-1', NULL);
 
--2
INSERT INTO dbo.demoDefault (HasADefault1, HasADefault2, KeyColumn)
VALUES (DEFAULT, DEFAULT, 3), (DEFAULT, DEFAULT, 4);
 
--3
INSERT INTO dbo.demoDefault (KeyColumn)
VALUES (5),(6);
 
--4
SELECT HasADefault1,HasADefault2,KeyColumn
FROM dbo.demoDefault;

 
INSERT INTO TableWithAllDefaults
DEFAULT VALUES;

--Listing 10-9. Inserting Rows into Tables with Autopopulated Columns
--1
DROP TABLE IF EXISTS [dbo].[demoAutoPopulate];
 
CREATE TABLE [dbo].[demoAutoPopulate](
     [RegularColumn] [NVARCHAR](50) NOT NULL PRIMARY KEY,
     [IdentityColumn] [INT] IDENTITY(1,1) NOT NULL,
     [RowversionColumn] [ROWVERSION] NOT NULL,
     [ComputedColumn] AS ([RegularColumn]+CONVERT([NVARCHAR],
     [IdentityColumn],(0))) PERSISTED);
GO
 
--2
INSERT INTO dbo.demoAutoPopulate (RegularColumn)
VALUES (N'a'), (N'b'), (N'c');
 
--3
SELECT RegularColumn, IdentityColumn, RowversionColumn, ComputedColumn
FROM demoAutoPopulate;

--Listing 10-10. Creating Demo Tables
DROP TABLE IF EXISTS [dbo].[demoProduct];
GO
 
SELECT * INTO dbo.demoProduct FROM Production.Product;
 
DROP TABLE IF EXISTS [dbo].[demoCustomer];
GO
 
SELECT C.*, LastName, FirstName 
INTO dbo.demoCustomer
FROM Sales.Customer AS C
JOIN Person.Person AS P ON C.CustomerID = P.BusinessEntityID;

DROP TABLE IF EXISTS [dbo].[demoPerson];
GO
SELECT *, ' ' Gender INTO dbo.demoPerson
FROM Person.Person
WHERE Title in ('Mr.', 'Mrs.', 'Ms.', 'Miss');
 
DROP TABLE IF EXISTS [dbo].[demoAddress];
GO
 
SELECT * INTO dbo.demoAddress FROM Person.Address;
 
DROP TABLE IF EXISTS [dbo].[demoSalesOrderHeader];
GO
 
SELECT * INTO dbo.demoSalesOrderHeader FROM Sales.SalesOrderHeader;
 
DROP TABLE IF EXISTS [dbo].[demoSalesOrderDetail];
GO
 
SELECT * INTO dbo.demoSalesOrderDetail FROM Sales.SalesOrderDetail;

DROP TABLE IF EXISTS [dbo].[demoPersonStore];
GO
 
CREATE TABLE [dbo].[demoPersonStore] (
[FirstName] [NVARCHAR] (60),
[LastName] [NVARCHAR] (60),
[CompanyName] [NVARCHAR] (60)
);
 
INSERT INTO dbo.demoPersonStore (FirstName, LastName, CompanyName)
SELECT a.FirstName, a.LastName, c.Name
FROM Person.Person a
JOIN Sales.SalesPerson b
ON a.BusinessEntityID = b.BusinessEntityID
JOIN Sales.Store c
ON b.BusinessEntityID = c.SalesPersonID;

--Listing 10-11. Deleting Rows from Tables
--1
SELECT CustomerID
FROM dbo.demoCustomer;
 
--2
DELETE dbo.demoCustomer;
 
--3
SELECT CustomerID
FROM dbo.demoCustomer;
 
--4
SELECT ProductID
FROM dbo.demoProduct
WHERE ProductID > 900;
 
--5
DELETE dbo.demoProduct
WHERE ProductID > 900;
 
--6
SELECT ProductID
FROM dbo.demoProduct
WHERE ProductID > 900;

--Listing 10-12. Deleting as part of a JOIN
--1
SELECT d.SalesOrderID, SalesOrderNumber
FROM dbo.demoSalesOrderDetail AS d
INNER JOIN dbo.demoSalesOrderHeader 
AS h ON d.SalesOrderID = h.SalesOrderID
WHERE h.SalesOrderNumber = 'SO71797';
 
--2
DELETE d
FROM dbo.demoSalesOrderDetail AS d
INNER JOIN dbo.demoSalesOrderHeader 
AS h ON d.SalesOrderID = h.SalesOrderID
WHERE h.SalesOrderNumber = 'SO71797'; 

--3
SELECT d.SalesOrderID, SalesOrderNumber
FROM dbo.demoSalesOrderDetail AS d
INNER JOIN dbo.demoSalesOrderHeader 
AS h ON d.SalesOrderID = h.SalesOrderID
WHERE h.SalesOrderNumber = 'SO71797';
 
--4
SELECT SalesOrderID, ProductID
FROM dbo.demoSalesOrderDetail AS SOD
WHERE NOT EXISTS
    (SELECT *
         FROM dbo.demoProduct AS P
         WHERE P.ProductID = SOD.ProductID);
--5
DELETE SOD
FROM dbo.demoSalesOrderDetail AS SOD
WHERE NOT EXISTS
    (SELECT *
         FROM dbo.demoProduct AS P
         WHERE P.ProductID = SOD.ProductID);
 
--6
SELECT SalesOrderID, ProductID
FROM dbo.demoSalesOrderDetail AS SOD
WHERE NOT EXISTS
    (SELECT *
         FROM dbo.demoProduct AS P
         WHERE P.ProductID = SOD.ProductID); 

--Don't do this!
DELETE dbo.demoSalesOrderDetail
SELECT d.SalesOrderID
FROM dbo.demoSalesOrderDetail AS d
WHERE EXISTS(
    SELECT *
        FROM dbo.demoSalesOrderHeader AS h
        WHERE d.SalesOrderID = h.SalesOrderID
    AND h.SalesOrderNumber = 'SO71797');

--Listing 10-13. Truncating Tables
--1
SELECT SalesOrderID, OrderDate
FROM dbo.demoSalesOrderHeader;
 
--2
TRUNCATE TABLE dbo.demoSalesOrderHeader;
 
--3
SELECT SalesOrderID, OrderDate
FROM dbo.demoSalesOrderHeader;

--Listing 10-14. Updating Data in a Table
--1
SELECT BusinessEntityID, Title, Gender
FROM dbo.demoPerson
ORDER BY BusinessEntityID;
 
--2
UPDATE dbo.demoPerson
SET Gender = CASE 
    WHEN Title = 'Mr.' THEN 'M' 
	WHEN Title in ('Miss','Mrs.','Ms.') THEN 'F' END; 
--3
SELECT BusinessEntityID, Title, Gender
FROM dbo.demoPerson
ORDER BY BusinessEntityID;

--Listing 10-15. Update with Expressions, Columns, or Data from Another Table
--1
SELECT FirstName,LastName, CompanyName,
   LEFT(FirstName,3) + '-' + LEFT(LastName,3) AS NewCompany
FROM dbo.demoPersonStore;
 
--2
UPDATE dbo.demoPersonStore
SET CompanyName = LEFT(FirstName,3) + '-' + LEFT(LastName,3);
 
--3
SELECT FirstName,LastName, CompanyName,
    LEFT(FirstName,3) + '-' + LEFT(LastName,3) AS NewCompany
FROM dbo.demoPersonStore;

--Listing 10-16. Updating with a Join
--1
SELECT AddressLine1, AddressLine2
FROM dbo.demoAddress;
 
--2
UPDATE dA
SET AddressLine1 = P.FirstName + ' ' + P.LastName,
    AddressLine2 = AddressLine1 + ISNULL(' ' + AddressLine2,'')
FROM dbo.demoAddress AS dA
INNER JOIN Person.BusinessEntityAddress BEA ON dA.AddressID = BEA.AddressID
INNER JOIN Person.Person P ON P.BusinessEntityID = BEA.BusinessEntityID;
 
--3
SELECT AddressLine1, AddressLine2
FROM dbo.demoAddress;


--Listing 10-17. The Difference between the Set-Based and Iterative Approaches
SET NOCOUNT ON; -- turns off rows affected message
--Create a work table
DROP TABLE IF EXISTS [dbo].[demoPerformance];
GO
 
CREATE TABLE [dbo].[demoPerformance](
    [CustomerID] [int] NOT NULL
 CONSTRAINT [PK_demoPerformance] PRIMARY KEY CLUSTERED
(
    CustomerID ASC
) )
  
GO
 
PRINT 'Insert all rows start';
PRINT SYSDATETIME();
 
--Insert all rows from the Sales.SalesOrderDetail table at once
INSERT INTO demoPerformance
SELECT CustomerID
FROM Sales.Customer;
 
PRINT 'Insert all rows end';
PRINT SYSDATETIME();
 
--Remove all rows from the first insert
TRUNCATE TABLE [dbo].[demoPerformance];
 
PRINT 'Insert rows one at a time begin';
PRINT SYSDATETIME();
   
--Set up a loop to insert one row at a time
WHILE EXISTS(
 
    SELECT *
    FROM Sales.Customer AS c
        WHERE NOT EXISTS(
            SELECT * FROM dbo.demoPerformance AS p
        WHERE c.CustomerID = p.CustomerID)
        ) BEGIN
 
    INSERT INTO demoPerformance(CustomerID)
        SELECT TOP(1) CustomerID
        FROM Sales.Customer AS c
        WHERE NOT EXISTS(SELECT * FROM dbo.demoPerformance WHERE CustomerID = c.CustomerID);
  
END
PRINT 'Insert rows one at a time end';
PRINT SYSDATETIME();

SELECT COUNT(*) FROM dbo.demoPerformance; 
