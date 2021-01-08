/*
Chapter 13 code
*/

--Listing 13-1. Adding a Check Constraint
USE tempdb;
GO
--1
DROP TABLE IF EXISTS table1;

--2
CREATE TABLE table1 (col1 SMALLINT, col2 VARCHAR(20),
    CONSTRAINT ch_table1_col2_months
    CHECK (col2 IN ('January','February','March','April','May',
        'June','July','August','September','October',
        'November','December')
    )
 );
   
--3
ALTER TABLE table1 ADD CONSTRAINT ch_table1_col1
    CHECK (col1 BETWEEN 1 and 12);
PRINT 'Jan';
 
--4
INSERT INTO table1 (col1,col2)
VALUES (1,'Jan');
 
PRINT 'February';
 
--5
INSERT INTO table1 (col1,col2)
VALUES (2,'February');
 
PRINT 13;
 
--6
INSERT INTO table1 (col1,col2)
VALUES (13,'March');
 
PRINT 'Change 2 to 20';
--7
UPDATE table1 SET col1 = 20;


--Listing 13-2. Creating Tables with UNIQUE Constraints
USE tempdb;
GO
--1
DROP TABLE IF EXISTS table1;
 
--2
CREATE TABLE table1 (col1 INT NULL UNIQUE,
    col2 VARCHAR(20) NULL, col3 DATE NULL);
GO
      
--3
ALTER TABLE table1 ADD CONSTRAINT
    unq_table1_col2_col3 UNIQUE (col2,col3);
      
--4
PRINT 'Statement 4'
INSERT INTO table1(col1,col2,col3)
VALUES (1,2,'2020/01/01'),(2,2,'2020/01/02');
 
--5
PRINT 'Statement 5'
INSERT INTO table1(col1,col2,col3)
VALUES (3,2,'2020/01/01');
 
--6
PRINT 'Statement 6'
INSERT INTO table1(col1,col2,col3)
VALUES (1,2,'2020/01/01');
 
--7
PRINT 'Statement 7'
UPDATE table1 SET col3 = '2020/01/01'
WHERE col1 = 1;

--Listing 13-3. Creating Primary Keys
USE tempdb;
GO
 
--1
DROP TABLE IF EXISTS table1;
DROP TABLE IF EXISTS table3;

--2
CREATE TABLE table1 (col1 INT NOT NULL,
    col2 VARCHAR(10)
    CONSTRAINT PK_table1_Col1 PRIMARY KEY (col1));
 
--3
CREATE TABLE table2 (col1 INT NOT NULL,
    col2 VARCHAR(10) NOT NULL, col3 INT NULL,
    CONSTRAINT PK_table2_col1col2 PRIMARY KEY
    (col1, col2)
);
 
--4
CREATE TABLE table3 (col1 INT NOT NULL,
    col2 VARCHAR(10) NOT NULL, col3 INT NULL);
 
--5
ALTER TABLE table3 ADD CONSTRAINT PK_table3_col1col2
    PRIMARY KEY NONCLUSTERED (col1,col2);
 
--Listing 13-4. Adding a Foreign Key
--1
DROP TABLE IF EXISTS table2;
DROP TABLE IF EXISTS table1; 
 
--2
CREATE TABLE table1 (col1 INT NOT NULL,
    col2 VARCHAR(20), col3 DATETIME
    CONSTRAINT PK_table1_Col1 PRIMARY KEY(col1));
 
--3
CREATE TABLE table2 (col4 INT NULL,
    col5 VARCHAR(20) NOT NULL,
    CONSTRAINT pk_table2 PRIMARY KEY (col5),
    CONSTRAINT fk_table2_table1 FOREIGN KEY (col4) REFERENCES table1(col1)
    );
GO
      
--4
PRINT 'Adding to table1';
INSERT INTO table1(col1,col2,col3)
VALUES(1,'a','2014/01/01'),(2,'b','2014/01/01'),(3,'c','1/3/2014');
 
--5
PRINT 'Adding to table2';
INSERT INTO table2(col4,col5)
VALUES(1,'abc'),(2,'def');
 
--6
PRINT 'Violating foreign key with insert';
INSERT INTO table2(col4,col5)
VALUES (7,'aaa');
 
--7
PRINT 'Violating foreign key with update';
UPDATE table2 SET col4 = 6
WHERE col4 = 1;


--Listing 13-5. Using Update and Delete Rules
USE tempdb;
GO
SET NOCOUNT ON;
GO
--1
DROP TABLE IF EXISTS Child;
DROP TABLE IF EXISTS Parent;

--2
CREATE TABLE Parent (col1 INT NOT NULL PRIMARY KEY,
    col2 VARCHAR(20), col3 DATE);
 
--3 default rules
PRINT 'No action by default';
CREATE TABLE Child (col4 INT NULL DEFAULT 7,
    col5 VARCHAR(20) NOT NULL,
    CONSTRAINT pk_Child PRIMARY KEY (col5),
    CONSTRAINT fk_Child_Parent FOREIGN KEY (col4) REFERENCES Parent(col1)
    );
 
--4
PRINT 'Adding to Parent';
INSERT INTO Parent(col1,col2,col3)
VALUES(1,'a','2014/01/01'),(2,'b','2014/02/01'),(3,'c','2014/01/03'),
    (4,'d','2014/01/04'),(5,'e','2014/01/06'),(6,'g','2014/01/07'),
    (7,'g','2014/01/08');
 
--5
PRINT 'Adding to Child';
INSERT INTO Child(col4,col5)
VALUES(1,'abc'),(2,'def'),(3,'ghi'),
    (4,'jkl');
 
--6
SELECT col4, col5 FROM Child;
 
--7
PRINT 'Delete from Parent'
DELETE FROM Parent WHERE col1 = 1;
 
--8
ALTER TABLE Child DROP CONSTRAINT fk_Child_Parent;
 
--9
PRINT 'Add CASCADE';
ALTER TABLE Child ADD CONSTRAINT fk_Child_Parent
    FOREIGN KEY (col4) REFERENCES Parent(col1)
    ON DELETE CASCADE
    ON UPDATE CASCADE;
      
--10
PRINT 'Delete from Parent';
DELETE FROM Parent WHERE col1 = 1;
 
--11
PRINT 'Update Parent';
UPDATE Parent SET col1 = 10 WHERE col1 = 4;
 
--12
ALTER TABLE Child DROP CONSTRAINT fk_Child_Parent;
 
--13
PRINT 'Add SET NULL';
ALTER TABLE Child ADD CONSTRAINT fk_Child_Parent
    FOREIGN KEY (col4) REFERENCES Parent(col1)
    ON DELETE SET NULL
    ON UPDATE SET NULL;
 
--14
DELETE FROM Parent WHERE col1 = 2;
 
--15
ALTER TABLE Child DROP CONSTRAINT fk_Child_Parent;
 
--16
PRINT 'Add SET DEFAULT';
ALTER TABLE Child ADD CONSTRAINT fk_Child_Parent
    FOREIGN KEY (col4) REFERENCES Parent(col1)
    ON DELETE SET DEFAULT
    ON UPDATE SET DEFAULT;     
 
--17
PRINT 'Delete from Parent';
DELETE FROM Parent WHERE col1 = 3;
 
--18
SELECT col4, col5 FROM Child;

--Listing 13-6. Defining Tables with Automatically Populating Columns
USE tempdb;
GO
--1
DROP SEQUENCE IF EXISTS MySequence;
CREATE SEQUENCE MySequence START WITH 1;
 
--2
DROP TABLE IF EXISTS table3;
CREATE TABLE table3 (col1 CHAR(1),
    idCol INT NOT NULL IDENTITY,
    rvCol ROWVERSION,
    defCol DATETIME2 DEFAULT GETDATE(),
    SeqCol INT DEFAULT NEXT VALUE FOR dbo.MySequence,
    calcCol1 AS DATEADD(m,1,defCol),
    calcCol2 AS col1 + ':' + col1
    );
GO
 
--3
INSERT INTO table3 (col1)
VALUES ('a'), ('b'), ('c'), ('d'), ('e'), ('g');
 
--4
INSERT INTO table3 (col1, defCol)
VALUES ('h', NULL),('i','2014/01/01');
 
--5
SELECT col1, idCol, rvCol, defCol, calcCol1, calcCol2, SeqCol
FROM table3;

--Listing 13-7. Creating and Using a View
--1
USE AdventureWorks2019;
GO
DROP VIEW IF EXISTS dbo.vw_Customer;
GO
 
--2
CREATE VIEW dbo.vw_Customer AS
    SELECT c.CustomerID, c.AccountNumber, c.StoreID,
        c.TerritoryID, p.FirstName, p.MiddleName,
        p.LastName
    FROM Sales.Customer AS c
    INNER JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID;
GO
 
--3
SELECT CustomerID,AccountNumber,FirstName,
    MiddleName, LastName
FROM dbo.vw_Customer;
 
GO
 
--4
ALTER VIEW dbo.vw_Customer AS
    SELECT c.CustomerID,c.AccountNumber,c.StoreID,
        c.TerritoryID, p.FirstName,p.MiddleName,
        p.LastName, p.Title
    FROM Sales.Customer AS c
    INNER JOIN Person.Person AS p ON c.PersonID = p.BusinessEntityID;
 
GO
 
--5
SELECT CustomerID,AccountNumber,FirstName,
    MiddleName, LastName, Title
FROM dbo.vw_Customer
ORDER BY CustomerID;


--Listing 13-8. Common Problems Using Views
--1
DROP VIEW IF EXISTS dbo.vw_Dept;
DROP TABLE IF EXISTS dbo.demoDept;
 
--2
SELECT DepartmentID,Name,GroupName,ModifiedDate
INTO dbo.demoDept
FROM HumanResources.Department;
 
GO
 
--3
CREATE VIEW dbo.vw_Dept AS
    SELECT *
    FROM dbo.demoDept;
GO
 
--4
SELECT DepartmentID, Name, GroupName, ModifiedDate
FROM dbo.vw_Dept;
 
--5
DROP TABLE dbo.demoDept;
GO
 
--6
SELECT DepartmentID, GroupName, Name, ModifiedDate
INTO dbo.demoDept
FROM HumanResources.Department;
GO
 
--7
SELECT DepartmentID, Name, GroupName, ModifiedDate
FROM dbo.vw_Dept;
GO
 
--8
DROP VIEW dbo.vw_Dept;
GO
 
--9
CREATE VIEW dbo.vw_Dept AS
    SELECT TOP(100) PERCENT DepartmentID,
        Name, GroupName, ModifiedDate
    FROM dbo.demoDept
    ORDER BY Name;
GO
 
--10
SELECT DepartmentID, Name, GroupName, ModifiedDate
FROM dbo.vw_Dept;

--Listing 13-9. Modifying Data Through Views
--1
DROP TABLE IF EXISTS dbo.demoCustomer;
DROP TABLE IF EXISTS dbo.demoPerson;
DROP VIEW IF EXISTS dbo.vw_Customer;
 
--2
SELECT CustomerID, TerritoryID, StoreID, PersonID
INTO dbo.demoCustomer
FROM Sales.Customer;
 
SELECT BusinessEntityID, Title, FirstName, MiddleName, LastName
INTO dbo.demoPerson
From Person.Person;
GO
 
--3
CREATE VIEW vw_Customer AS
    SELECT CustomerID, TerritoryID, PersonID, StoreID,
        Title, FirstName, MiddleName, LastName
    FROM dbo.demoCustomer
    INNER JOIN dbo.demoPerson ON PersonID = BusinessEntityID;
GO
 
--4
SELECT CustomerID, FirstName, MiddleName, LastName
FROM dbo.vw_Customer
WHERE CustomerID IN (29484,29486,29489,100000);
 
--5
PRINT 'Update one row';
UPDATE dbo.vw_Customer SET FirstName = 'Kathi'
WHERE CustomerID = 29486;
 
--6
GO
PRINT 'Attempt to update both sides of the join'
GO
UPDATE dbo.vw_Customer SET FirstName = 'Franie',TerritoryID = 5
WHERE CustomerID = 29489;
 
--7
GO
PRINT 'Attempt to delete a row';
GO
DELETE FROM dbo.vw_Customer
WHERE CustomerID = 29484;
 
--8
GO
PRINT 'Insert into dbo.demoCustomer';
INSERT INTO dbo.vw_Customer(TerritoryID,
    StoreID, PersonID)
VALUES (5,5,100000);
 
--9
GO
PRINT 'Attempt to insert a row into demoPerson';
GO
INSERT INTO dbo.vw_Customer(Title, FirstName, LastName)
VALUES ('Mrs.','Lady','Samoyed');
 
--10
SELECT CustomerID, FirstName, MiddleName, LastName
FROM dbo.vw_Customer
WHERE CustomerID IN (29484,29486,29489,100000);
 
--11
SELECT CustomerID, TerritoryID, StoreID, PersonID
FROM dbo.demoCustomer
WHERE PersonID = 100000;

--Listing 13-10. Creating and Using User-Defined Scalar Functions
--1
DROP FUNCTION IF EXISTS dbo.udf_Product;
DROP FUNCTION IF EXISTS dbo.udf_Delim;
GO
 
--2
CREATE FUNCTION dbo.udf_Product(@num1 INT, @num2 INT) RETURNS INT AS
BEGIN
 
    DECLARE @Product INT;
    SET @Product = ISNULL(@num1,0) * ISNULL(@num2,0);
    RETURN @Product;
 
END;
GO
 
--3
CREATE FUNCTION dbo.udf_Delim(@String VARCHAR(100),@Delimiter CHAR(1))
    RETURNS VARCHAR(200) AS
BEGIN
    DECLARE @NewString VARCHAR(200) = '';
    DECLARE @Count INT = 1;
 
    WHILE @Count <= LEN(@String) BEGIN
        SET @NewString += SUBSTRING(@String,@Count,1) + @Delimiter;
        SET @Count += 1;
    END
 
    RETURN @NewString;
END
GO
 
--4
SELECT StoreID, TerritoryID,
    dbo.udf_Product(StoreID, TerritoryID) AS TheProduct,
    dbo.udf_Delim(FirstName,',') AS FirstNameWithCommas
FROM Sales.Customer AS c
INNER JOIN Person.Person AS p ON c.PersonID= p.BusinessEntityID;


--Listing 13-11. Using a Table-Valued UDF
--1
SELECT PersonID,FirstName,LastName,JobTitle,BusinessEntityType
FROM dbo.ufnGetContactInformation(1);
 
--2
SELECT PersonID,FirstName,LastName,JobTitle,BusinessEntityType
FROM dbo.ufnGetContactInformation(7822);
 
--3
SELECT e.BirthDate, e.Gender, c.FirstName,c.LastName,c.JobTitle
FROM HumanResources.Employee as e
CROSS APPLY dbo.ufnGetContactInformation(e.BusinessEntityID ) AS c;
 
--4
SELECT sc.CustomerID,sc.TerritoryID,c.FirstName,c.LastName
FROM Sales.Customer AS sc
CROSS APPLY dbo.ufnGetContactInformation(sc.PersonID) AS c;

--Listing 13-12. Creating and Using a Stored Procedure
--1
GO
CREATE OR ALTER PROC dbo.usp_CustomerName AS
    SET NOCOUNT ON;
 
    SELECT c.CustomerID,p.FirstName,p.MiddleName,p.LastName
    FROM Sales.Customer AS c
    INNER JOIN Person.Person AS p on c.PersonID = p.BusinessEntityID
    ORDER BY p.LastName, p.FirstName,p.MiddleName ;
     
    RETURN 0;
GO
 
--2
EXEC dbo.usp_CustomerName
GO
 
--3
CREATE OR ALTER PROC dbo.usp_CustomerName @CustomerID INT AS
    SET NOCOUNT ON;
 
    IF @CustomerID > 0 BEGIN
 
        SELECT c.CustomerID,p.FirstName,p.MiddleName,p.LastName
        FROM Sales.Customer AS c
        INNER JOIN Person.Person AS p on c.PersonID = p.BusinessEntityID
        WHERE c.CustomerID = @CustomerID;
 
        RETURN 0;
    END
    ELSE BEGIN
       RETURN -1;
    END;     
     
GO
 
--4
EXEC dbo.usp_CustomerName @CustomerID = 15128;

--Listing 13-13. Using Default Value Parameters
--1
GO
CREATE OR ALTER PROC dbo.usp_CustomerName @CustomerID INT = -1 AS
    SELECT c.CustomerID,p.FirstName,p.MiddleName,p.LastName
    FROM Sales.Customer AS c
    INNER JOIN Person.Person AS p on c.PersonID = p.BusinessEntityID
    WHERE @CustomerID = CASE @CustomerID WHEN -1 THEN -1 ELSE c.CustomerID END;
     
    RETURN 0;
GO
 
--2
EXEC dbo.usp_CustomerName @CustomerID = 15128;
 
--3
EXEC dbo.usp_CustomerName ;

--Listing 13-14. Using an OUTPUT Parameter
--1
GO
CREATE OR ALTER PROC dbo.usp_OrderDetailCount @OrderID INT,
    @Count INT OUTPUT AS
 
    SELECT @Count = COUNT(*)
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
 
    RETURN 0;
GO
 
--2
DECLARE @OrderCount INT;
 
--3
EXEC usp_OrderDetailCount 71774, @OrderCount OUTPUT;
 
--4
PRINT @OrderCount;


--Listing 13-15. Inserting the Rows from a Stored Procedure into a Table
--1
DROP TABLE IF EXISTS #tempCustomer;
DROP PROC IF EXISTS dbo.usp_CustomerName;
GO
 
--2
CREATE TABLE #tempCustomer(CustomerID INT, FirstName NVARCHAR(50),
    MiddleName NVARCHAR(50), LastName NVARCHAR(50));
GO
 
--3
CREATE PROC dbo.usp_CustomerName @CustomerID INT = -1 AS
	IF @CustomerID = -1 BEGIN 
		SELECT c.CustomerID,p.FirstName,p.MiddleName,p.LastName
		FROM Sales.Customer AS c
		INNER JOIN Person.Person AS p on c.PersonID = p.BusinessEntityID
	END 
	ELSE BEGIN 
		SELECT c.CustomerID,p.FirstName,p.MiddleName,p.LastName
		FROM Sales.Customer AS c
		INNER JOIN Person.Person AS p on c.PersonID = p.BusinessEntityID
		WHERE c.CustomerID = @CustomerID 
	END;
     
    RETURN 0;
GO
 
--4
INSERT INTO #tempCustomer EXEC dbo.usp_CustomerName;
 
--5
SELECT CustomerID, FirstName, MiddleName, LastName
FROM #tempCustomer;
 

--Listing 13-16. Using Logic in a Stored Procedure
USE tempdb;
GO
 
--1
CREATE OR ALTER PROC usp_ProgrammingLogic AS
    CREATE TABLE #Numbers(number INT NOT NULL);
    
    DECLARE @count INT;
    SET @count = ASCII('!');
     
    WHILE @count < 200 BEGIN
        INSERT INTO #Numbers(number) VALUES (@count);
        SET @count = @count + 1;
    END;
 
    ALTER TABLE #Numbers ADD symbol NCHAR(1);
    UPDATE #Numbers SET symbol = CHAR(number);
     
    SELECT number, symbol FROM #Numbers;
GO
 
--2
EXEC usp_ProgrammingLogic;

--Listing 13-17. Creating a User-Defined Data Type
DROP TYPE IF EXISTS dbo.CustomerID;
GO
 
CREATE TYPE dbo.CustomerID FROM INT NOT NULL;

--Listing 13-18. Create a Table Type
--Clean up objects for this section if they exist
GO
DROP PROCEDURE IF EXISTS usp_TestTableVariable;
DROP TYPE IF EXISTS dbo.CustomerInfo;
 
CREATE TYPE dbo.CustomerInfo AS TABLE
(
    CustomerID INT NOT NULL PRIMARY KEY,
        FavoriteColor VARCHAR(20) NULL,
        FavoriteSeason VARCHAR(10) NULL
);
 
--Listing 13-19. Create and Populate Table Variable Based on the Type
DECLARE @myTableVariable [dbo].[CustomerInfo];
 
INSERT INTO @myTableVariable(CustomerID, FavoriteColor, FavoriteSeason)
VALUES(11001, 'Blue','Summer'),(11002,'Orange','Fall');
 
SELECT CustomerID, FavoriteColor, FavoriteSeason
FROM @myTableVariable;
 
--Listing 13-20. Create a Stored Procedure and Use a Table Variable
GO
--1
CREATE PROC dbo.usp_TestTableVariable @myTable CustomerInfo READONLY AS
    SELECT c.CustomerID, AccountNumber, FavoriteColor, FavoriteSeason
    FROM AdventureWorks2019.Sales.Customer AS C INNER JOIN @myTable MT
        ON C.CustomerID = MT.CustomerID;
 
GO
--2
DECLARE @myTableVariable [dbo].[CustomerInfo]
INSERT INTO @myTableVariable(CustomerID, FavoriteColor, FavoriteSeason)
VALUES(11001, 'Blue','Summer'),(11002,'Orange','Fall');
 
--3
EXEC usp_TestTableVariable @myTableVariable;


--Listing 13-21.  A table with a trigger
--1
DROP TABLE IF EXISTS dbo.Customers;
--2
CREATE TABLE dbo.Customers
	(ID int IDENTITY
	,FirstName varchar(70)
	,LastName varchar(80)
	,CreateDate datetime DEFAULT GETDATE()
	,ModifyDate datetime
	,CreateUser varchar(50) DEFAULT SYSTEM_USER
	,ModifyUser varchar(50)
	);
GO

--3
CREATE TRIGGER trCustomers
ON Customers
AFTER UPDATE 
AS
BEGIN
SET NOCOUNT ON
	UPDATE Customers
		SET ModifyDate=GETDATE()
		,ModifyUser=SYSTEM_USER
	WHERE ID IN 
			(SELECT ID FROM Inserted i);
END
GO

--4
INSERT INTO Customers(FirstName,LastName) 
VALUES ('Joe','Smith'), ('Mary','Jones');

--5
SELECT * FROM Customers;

--6
UPDATE dbo.Customers SET FirstName='Jack'
WHERE ID=1;

--7
SELECT * FROM Customers;

--8
DROP TABLE IF EXISTS dbo.Customers;

--Listing 13-22. Inline scalar UDF
SET STATISTICS IO ON;
GO
USE AdventureWorks2019;
GO
--1 Create a scalar function
CREATE OR ALTER FUNCTION dbo.udf_GetSalesCount(@ProductID INT, @Year INT = 0)
RETURNS INT AS 
BEGIN
	DECLARE @Count INT;
	IF @Year = 0 BEGIN 
		SELECT @Count = COALESCE(SUM(OrderQty),0)
		FROM Sales.SalesOrderDetail 
		WHERE ProductID = @ProductID;
	END ELSE 
		SELECT @Count = COALESCE(SUM(OrderQty),0)
		FROM Sales.SalesOrderDetail AS SOD 
		JOIN Sales.SalesOrderHeader AS SOH 
		ON SOD.SalesOrderID = SOH.SalesOrderID
		WHERE ProductID = @ProductID
			AND YEAR(OrderDate) = @Year;
	RETURN @Count;
END

GO
--2 Switch to 2017 compat mode
ALTER DATABASE [AdventureWorks2019] SET COMPATIBILITY_LEVEL = 140
GO

--3 Use the function
SELECT ProductID, Name, ListPrice, dbo.udf_GetSalesCount(ProductID,0) AS QtySold
FROM Production.Product
WHERE ProductSubcategoryID = 1;

--4 Switch to 2019 Compat
ALTER DATABASE [AdventureWorks2019] SET COMPATIBILITY_LEVEL = 150
GO

--5 Use the function
SELECT ProductID, Name, ListPrice, dbo.udf_GetSalesCount(ProductID,0) AS QtySold
FROM Production.Product
WHERE ProductSubcategoryID = 1;

 
--Listing 13-23. Inline multi-statement table-valued function 
--Create a function
GO
CREATE OR ALTER FUNCTION dbo.getColors()
RETURNS @Colors TABLE 
(
	Color varchar(20)
)
AS
BEGIN
	INSERT INTO @Colors(Color) 
	SELECT DISTINCT Color 
	FROM Production.Product 

	INSERT INTO @Colors(Color)
	VALUES('Lime'),('Turquoise');
	
	RETURN;
END
GO
