/*
Chapter 12 code
*/

--Listing 12-1. Declaring and Using Variables
--1
SET NOCOUNT ON;
GO

--2
DECLARE @myNumber INT = 10;
PRINT 'The value of @myNumber';
PRINT @myNumber;
SET @myNumber = 20;
PRINT 'The value of @myNumber';
PRINT @myNumber;
GO
 
--3
DECLARE @myString VARCHAR(100), @myBit BIT;
SELECT @myString = 'Hello, World', @myBit = 1;
PRINT 'The value of @myString';
PRINT @myString;
PRINT 'The value of @myBit';
PRINT @myBit;
GO
 
--4
DECLARE @myUnicodeString NVARCHAR(100);
SET @myUnicodeString = N'This is a Unicode String';
PRINT 'The value of @myUnicodeString';
PRINT @myUnicodeString;
GO
 
--5
DECLARE @FirstName NVARCHAR(50), @LastName NVARCHAR(50);
SELECT @FirstName  = FirstName, @LastName = LastName
FROM Person.Person
WHERE BusinessEntityID = 1;
 
PRINT 'The value of @FirstName';
PRINT @FirstName;
PRINT 'The value of @LastName';
PRINT @LastName;
GO
 
--6
PRINT 'The value of @myString';
PRINT @myString;

--Listing 12-2. Using Expressions and Functions to Assign Variable Values
--1
DECLARE @myINT1 INT = 10, @myINT2 INT = 20, @myINT3 INT;
SET @myINT3 = @myINT1 * @myINT2;
PRINT 'Value of @myINT3: ' + CONVERT(VARCHAR(30),@myINT3);
GO
 
--2
DECLARE @myString VARCHAR(100);
SET @myString = 'Hello, ';
SET @myString += 'World';
PRINT 'Value of @myString: ' + @myString;
GO
 
--3
DECLARE @CustomerCount INT;
SELECT @CustomerCount = COUNT(*)
FROM Sales.Customer;
PRINT 'Customer Count: ' + CAST(@CustomerCount AS VARCHAR(30));
 
--4
DECLARE @FullName NVARCHAR(152);
SELECT @FullName = FirstName + ISNULL(' ' + MiddleName,'') + ' ' + LastName
FROM Person.Person
WHERE BusinessEntityID = 1;
PRINT 'FullName: ' + @FullName;

--5
GO
DECLARE @FullName NVARCHAR(152)
SELECT @FullName = FirstName + ISNULL(' ' + MiddleName,'') + ' ' + LastName
FROM Person.Person;
PRINT 'FullName: ' + @FullName;

--Listing 12-3. Using a Variable in a WHERE or HAVING Clause Predicate
--1
DECLARE @ID INT;
SET @ID = 1;
 
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE BusinessEntityID = @ID;
GO
 
--2
DECLARE @FirstName NVARCHAR(50);
SET @FirstName = N'Ke%';
 
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE FirstName LIKE @FirstName
ORDER BY BusinessEntityID;
GO
 
--3
DECLARE @ID INT = 1;
--3.1
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE @ID = CASE @ID WHEN 0 THEN 0 ELSE BusinessEntityID END;
 
--3.2
SET @ID = 0;
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE @ID = CASE @ID WHEN 0 THEN 0 ELSE BusinessEntityID END;
 
GO
 
--4
DECLARE @Amount INT = 10000;
 
SELECT SUM(TotalDue) AS TotalSales, CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID
HAVING SUM(TotalDue) > @Amount;


--Listing 12-4. Using IF to Control Code Execution
--1
DECLARE @Count INT;
 
SELECT @Count = COUNT(*)
FROM Sales.Customer;
 
IF @Count > 500 BEGIN
   PRINT 'The customer count is over 500.';
END;
GO
 
--2
DECLARE @Name VARCHAR(50);
 
SELECT @Name = FirstName + ' ' + LastName
FROM Person.Person
WHERE BusinessEntityID = 1;
 
--2.1
IF CHARINDEX('Ken',@Name) > 0 BEGIN
    PRINT 'The name for BusinessEntityID = 1 contains "Ken"';
END;
--2.2
IF CHARINDEX('Kathi',@Name) > 0 BEGIN
    PRINT 'The name for BusinessEntityID = 1 contains "Kathi"';
END;


--Listing 12-5. Using ELSE
--1
DECLARE @Count INT;
 
SELECT @Count = COUNT(*)
FROM Sales.Customer;
 
IF @Count < 500 PRINT 'The customer count is less than 500.';
ELSE PRINT 'The customer count is 500 or more.';
GO
 
--2
DECLARE @Name NVARCHAR(101);
 
SELECT @Name = FirstName + ' ' + LastName
FROM Person.Person
WHERE BusinessEntityID = 1;
 
--2.1
IF CHARINDEX('Ken', @Name) > 0 BEGIN
    PRINT 'The name for BusinessEntityID = 1 contains "Ken"';
END;
ELSE BEGIN
    PRINT 'The name for BusinessEntityID = 1 does not contain "Ken"';
    PRINT 'The name is ' + @Name;
END;
--2.2
IF CHARINDEX('Kathi', @Name) > 0 BEGIN
    PRINT 'The name for BusinessEntityID = 1 contains "Kathi"';
END;
ELSE BEGIN
    PRINT 'The name for BusinessEntityID = 1 does not contain "Kathi"';
    PRINT 'The name is ' + @Name;
END;


--Listing 12-6. Using Multiple Conditions with IF and ELSE
--1
DECLARE @Count INT;
 
SELECT @Count = COUNT(*)
FROM Sales.Customer;
 
IF @Count > 500 AND DATENAME(WEEKDAY, GETDATE()) = 'Monday' BEGIN
    PRINT 'The count is over 500.';
    PRINT 'Today is Monday.';
END;
ELSE BEGIN
    PRINT 'Either the count is too low or today is not Monday.';
END;
--2
IF @Count > 500 AND (DATENAME(WEEKDAY,GETDATE()) = 'Monday' OR DATEPART(MONTH,getdate())= 3) BEGIN
     PRINT 'The count is over 500.';
     PRINT 'It is either Monday or the month is March.';
END;

--Listing 12-7. Using a Nested IF Block
GO
DECLARE @Count INT;
 
SELECT @Count = COUNT(*)
FROM Sales.Customer;
 
IF @Count > 500 BEGIN
    PRINT 'The count is over 500.';
    IF DATENAME(dw,getdate())= 'Monday' BEGIN
        PRINT 'Today is Monday.';
    END;
    ELSE BEGIN
        PRINT 'Today is not Monday.';
    END;
END;

 
--Listing 12-8. Using IF EXISTS
--1
IF EXISTS(SELECT * FROM Person.Person WHERE BusinessEntityID = 1) BEGIN
   PRINT 'There is a row with BusinessEntityID = 1';
END;
ELSE BEGIN
   PRINT 'There is not a row with BusEntityID = 1';
END;
 
--2
IF (SELECT COUNT(*) FROM Person.Person WHERE FirstName = 'Kathi') = 0 BEGIN
   PRINT 'There is not a person with the first name "Kathi".';
END;


--Listing 12-9. Using WHILE
--1
GO
DECLARE @Count INT = 1;
 
WHILE @Count < 5 BEGIN
    PRINT @Count;
    SET @Count += 1;
END;
GO
 
--2
DROP TABLE IF EXISTS dbo.demoContactType;
GO
CREATE TABLE dbo.demoContactType(ContactTypeID INT NOT NULL PRIMARY KEY,
    Processed BIT NOT NULL);
GO
INSERT INTO dbo.demoContactType(ContactTypeID,Processed)
SELECT ContactTypeID, 0
FROM Person.ContactType;
DECLARE @Count INT = 1;
WHILE EXISTS(SELECT * From dbo.demoContactType  WHERE Processed = 0) BEGIN
    UPDATE dbo.demoContactType SET Processed = 1
    WHERE ContactTypeID = @Count;
    PRINT 'Executed loop #' + CAST(@Count AS VARCHAR(10));
    SET @Count += 1;
END;
PRINT 'Done!';
 

--Listing 12-10. Using a Nested WHILE Loop
DECLARE @OuterCount INT = 1;
DECLARE @InnerCount INT;
 
WHILE @OuterCount < 10 BEGIN
    PRINT 'Outer Loop';
    SET @InnerCount = 1;
    WHILE @InnerCount < 5 BEGIN
        PRINT '    Inner Loop';
        SET @InnerCount += 1;
    END;
    SET @OuterCount += 1;
END;
 

--Listing 12-11. Using BREAK
GO
DECLARE @Count INT = 1;
 
WHILE @Count < 50  BEGIN
    PRINT @Count;
    IF @Count = 10 BEGIN
        PRINT 'Exiting the WHILE loop';
        BREAK;
    END;
    SET @Count += 1;
END;
 
--Listing 12-12. Using CONTINUE in a WHILE Loop
GO
DECLARE @Count INT = 1;
 
WHILE @Count < 10 BEGIN
    PRINT @Count;
    SET @Count += 1;
    IF @Count = 3 BEGIN
       PRINT 'CONTINUE';
       CONTINUE;
    END;
    PRINT 'Bottom of loop';
END;
 
--Listing 12-13. Creating and Populating Local Temp Table
--1
CREATE TABLE #myCustomers(CustomerID INT, FirstName VARCHAR(25),
    LastName VARCHAR(25));
GO
--2
INSERT INTO #myCustomers(CustomerID,FirstName,LastName)
SELECT C.CustomerID, FirstName, LastName
FROM Person.Person AS P INNER JOIN Sales.Customer AS C
ON P.BusinessEntityID = C.PersonID;

--3
SELECT CustomerID, FirstName, LastName
FROM #myCustomers;
 
--4
DROP TABLE #myCustomers;

--Listing 12-14. Creating and Populating a Global Temp Table
--1
CREATE TABLE ##myCustomers(CustomerID INT, FirstName VARCHAR(25),
    LastName VARCHAR(25));
GO
 
--2
INSERT INTO ##myCustomers(CustomerID,FirstName,LastName)
SELECT C.CustomerID, FirstName,LastName
FROM Person.Person AS P INNER JOIN Sales.Customer AS C
ON P.BusinessEntityID = C.PersonID;
 
--3
SELECT CustomerID, FirstName, LastName
FROM ##myCustomers;
--4 
--Run the drop statement when you are done
--DROP TABLE ##myCustomers;


--Listing 12-15. Creating and Populating Table Variable
--1
DECLARE @myCustomers TABLE (CustomerID INT, FirstName VARCHAR(25),
    LastName VARCHAR(25))
 
--2
INSERT INTO @myCustomers(CustomerID,FirstName,LastName)
SELECT C.CustomerID, FirstName,LastName
FROM Person.Person AS P INNER JOIN Sales.Customer AS C
ON P.BusinessEntityID = C.PersonID;

--3 
SELECT CustomerID, FirstName, LastName
FROM @myCustomers;


--Listing 12-16. Using a Temp Table to Solve a Query Problem
--1
DECLARE @IDTable TABLE (ID INT);
DECLARE @IDList VARCHAR(2000);
SET @IDList = '16496,12506,11390,10798,2191,11235,10879,15040,3086';

--2
INSERT INTO @IDTable(ID)
SELECT * FROM string_split(@IDList,',');

--3
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person AS p
WHERE BusinessEntityID IN (SELECT ID FROM @IDTable); 



--Listing 12-17. Using an Array
--1
GO
DECLARE @IDTable TABLE([Index] INT NOT NULL IDENTITY,
    ID INT);
DECLARE @RowCount INT;
DECLARE @ID INT;
DECLARE @Count INT = 1;
 
--2
INSERT INTO @IDTable(ID)
VALUES(500),(333),(200),(999);
 
--3
SELECT @RowCount = COUNT(*)
FROM @IDTable;
 
--4
WHILE @Count <= @RowCount BEGIN
    --4.1
    SELECT @ID = ID
    FROM @IDTable
    WHERE [Index] = @Count;
    --4.2
    PRINT CAST(@COUNT AS VARCHAR) + ': ' + CAST(@ID AS VARCHAR);
    --4.3
    SET @Count += 1;
END;


--Listing 12-18. Using a Cursor
--1
DECLARE @ProductID INT;
DECLARE @Name NVARCHAR(25);
 
--2
DECLARE products CURSOR FAST_FORWARD FOR
    SELECT ProductID, Name
    FROM Production.Product;
 
--3
OPEN products;
 
--4
FETCH NEXT FROM products INTO @ProductID, @Name;
 
--5
WHILE @@FETCH_STATUS = 0 BEGIN
    --5.1
    PRINT @ProductID;
    PRINT @Name;
    --5.2
    FETCH NEXT FROM products INTO @ProductID, @Name;
END
 
--6
CLOSE products;
DEALLOCATE products;


--Listing 12-19. Using a Cursor to Populate a Report
DECLARE @Year INT;
DECLARE @Month INT;
DECLARE @TerritoryID INT;
DECLARE @Total MONEY;
DECLARE @PreviousTotal MONEY;
DECLARE @FirstYear INT;
DECLARE @LastYear INT;
DECLARE @BeginDate DATETIME;
DECLARE @EndDate DATETIME;
 
--Create a table to hold the results
CREATE TABLE #Totals(OrderYear INT, OrderMonth INT,
    TerritoryID INT, TotalSales MONEY,
    PreviousSales MONEY);
 
--Grab the first and last years from the sales
SELECT @FirstYear = MIN(YEAR(OrderDate)),
    @LastYear = MAX(YEAR(OrderDate))
FROM Sales.SalesOrderHeader;
 
--Here we declare the cursor
DECLARE Territory CURSOR FAST_FORWARD FOR
    SELECT TerritoryID
    FROM Sales.SalesTerritory;
 
--Open the cursor
OPEN Territory;
--Save the values of the first row in variables
FETCH NEXT FROM Territory INTO @TerritoryID;
WHILE @@FETCH_STATUS = 0 BEGIN
    SET @Year = @FirstYear;
    --loop once for every year
    WHILE @Year <= @LastYear BEGIN
        --loop once for each month
        SET @Month = 1;
        WHILE @Month <= 12 BEGIN
            --find the beginning or end of the month
            SET @BeginDate = CAST(@Year AS VARCHAR) + '/' +
                CAST(@Month AS VARCHAR) + '/1';
            SET @EndDate = DATEADD(M,1,@BeginDate);
            --reset the total
            SET @Total = 0;
            --save the current value in the variable
            SELECT @Total = SUM(LineTotal)
            FROM Sales.SalesOrderDetail AS SOD
            INNER JOIN Sales.SalesOrderHeader AS SOH
            ON SOD.SalesOrderID = SOH.SalesOrderID
            WHERE TerritoryID = @TerritoryID
                AND OrderDate >= @BeginDate AND OrderDate < @EndDate;
            --set variables for this month
            SET @PreviousTotal = 0;
            SET @EndDate = @BeginDate;
            SET @BeginDate = DATEADD(M,-1,@BeginDate);
 
            --save the previous total
            SELECT @PreviousTotal = SUM(LineTotal)
            FROM Sales.SalesOrderDetail AS SOD
            INNER JOIN Sales.SalesOrderHeader AS SOH
            ON SOD.SalesOrderID = SOH.SalesOrderID
            WHERE TerritoryID = @TerritoryID
               AND OrderDate >= @BeginDate AND OrderDate < @EndDate;
 
            --insert the values
            INSERT INTO #Totals(TerritoryID, OrderYear,
            OrderMonth,TotalSales, PreviousSales)
            SELECT @TerritoryID, @Year, @Month,
            ISNULL(@Total,0), ISNULL(@PreviousTotal,0);
 
            SET @Month +=1;
        END; -- Month loop
        SET @Year += 1;
    END; -- Year Loop
    FETCH NEXT FROM Territory INTO @TerritoryID;
END; -- Territory cursor
CLOSE Territory;
DEALLOCATE Territory;
 
SELECT OrderYear, OrderMonth, TerritoryID,
    TotalSales, PreviousSales
FROM #Totals
WHERE TotalSales <> 0
ORDER BY OrderYear, OrderMonth, TerritoryID;
 
DROP TABLE #Totals;
 

--Listing 12-20. Producing the Report Without a Cursor or Temp Table
SELECT YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
        TerritoryID,
        SUM(LineTotal) AS TotalSales,
        LAG(SUM(TotalDue),1,0)
            OVER(PARTITION BY TerritoryID
            ORDER BY YEAR(OrderDate),MONTH(OrderDate)) AS PreviousSales
FROM Sales.SalesOrderHeader AS SOH
JOIN Sales.SalesOrderDetail AS SOD
ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY YEAR(OrderDate),
    MONTH(OrderDate), TerritoryID
    ORDER BY OrderYear, OrderMonth, TerritoryID;
