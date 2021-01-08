/*
Chapter 12 solution
*/

USE AdventureWorks2019;
GO
--12.1.1
DECLARE @myInt INT = 10;
PRINT @myInt;

--12.1.2
DECLARE @ID TINYINT = 4000;
/*
You will see this error: “Msg 220, Level 16, State 2, Line 8 Arithmetic overflow error for data type tinyint, value = 4000.”
A tinyint can hold values up to 255.
*/

--12.1.3
DECLARE @ID INT = 123.4567;
SELECT @ID;

--123
--Since the variable is an integer, it will not retain the value to the right of the decimal place.


--12.1.4
DECLARE @myString VARCHAR(20) = 'This is a test';
PRINT @myString;
 

--12.1.5
DECLARE @MaxID INT, @MinID INT;
SELECT @MaxID = MAX(SalesOrderID),
    @MinID = MIN(SalesOrderID)
FROM Sales.SalesOrderHeader;
PRINT CONCAT('Max: ', @MaxID);
PRINT CONCAT('Min: ', @MinID);


--12.1.6
DECLARE @ID INT = 70000;
SELECT SalesOrderID
FROM Sales.SalesOrderHeader
WHERE SalesOrderID > @ID;

--12.1.7
DECLARE @ID INT, @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50);
 
SELECT @ID = BusinessEntityID,
    @FirstName = FirstName,
    @LastName = LastName
FROM Person.Person
WHERE BusinessEntityID = 1;
 
PRINT CONVERT(NVARCHAR,@ID) + ': ' + @FirstName + ' ' + @LastName;

--12.1.8
DECLARE @SalesCount INT;
SELECT @SalesCount = COUNT(*)
FROM Sales.SalesOrderHeader;
 
SELECT @SalesCount - COUNT(*) AS CustCountDiff,
    CustomerID
FROM Sales.SalesOrderHeader
GROUP BY CustomerID;

USE WideWorldImporters;
GO

--12.1.9
DECLARE @ID VARCHAR(MAX) = '';
SELECT @ID += colorname 
FROM Warehouse.colors;
SELECT @ID;

/*
The += operator will concatenate the values. You’ll end up with something like this: 
AzureBeigeBlackBlueCharcoalChartreuseCyanDark BrownDark GreenFuchsiaGoldHot 
PinkIndigoIvoryKhakiLavenderLight BrownLight GreenMaroonMauveNavy 
BlueOliveOrangePlumPucePurpleRedRoyal BlueSalmonSilverSteel GrayTanTealWheatWhiteYellow
*/

USE AdventureWorks2019;
GO

--12.2.1
GO
DECLARE @Count INT;
SELECT @Count = COUNT(*)
FROM Sales.SalesOrderDetail;
 
IF @Count > 100000 BEGIN
    PRINT 'Over 100,000';
END
ELSE BEGIN
    PRINT '100,000 or less.';
END;

--12.2.2
IF MONTH(GETDATE()) IN (10,11,8) BEGIN
    PRINT 'The month is ' +
        DATENAME(mm, GETDATE());
    IF YEAR(GETDATE()) % 2 = 0 BEGIN
        PRINT 'The year is even.';
    END
    ELSE BEGIN
        PRINT 'The year is odd.';
    END
END;


--12.2.3
IF EXISTS(SELECT * FROM Sales.SalesOrderHeader
          WHERE SalesOrderID = 1) BEGIN
    PRINT 'There is a SalesOrderID = 1';
END
ELSE BEGIN
    PRINT 'There is not a SalesOrderID = 1';
END;

USE WideWorldImporters;
GO
--12.2.4
DECLARE @count INT;
SELECT @count = COUNT(*)
FROM Purchasing.PurchaseOrderLines;
IF @count <= 8000 BEGIN 
	PRINT '<= 8000 rows'; 
END 
ELSE BEGIN 
	PRINT '> 8000 rows';
END;

--12.2.5
DECLARE @Choice VARCHAR(20) = 'Cities';
IF @Choice = 'Cities'
	SELECT * FROM Application.Cities; 
ELSE
	SELECT * FROM Application.StateProvinces;

USE AdventureWorks2019;
GO
--12.3.1
GO
DECLARE @Letter CHAR(1);
SET @Letter = CHAR(65);
PRINT @Letter;
 
DECLARE @Count INT = 65;
WHILE @Count < 91 BEGIN
    PRINT CHAR(@Count);
    SET @Count += 1;
END;
 
--12.3.2
DECLARE @i INT = 1;
DECLARE @j INT;
 
WHILE @i <= 100 BEGIN
    SET @j = 1;
    WHILE @j <= 5 BEGIN
        PRINT @i * @j;
        SET @j += 1;
    END;
    SET @i += 1;
END;
 
--12.3.3
GO
DECLARE @i INT = 1;
DECLARE @j INT;
WHILE @i <= 100 BEGIN
    SET @j = 1;
    WHILE @j <= 5 BEGIN
        IF @i % 5 = 0 BEGIN
            PRINT 'Breaking out of loop.'
            BREAK;
        END;
        PRINT @i * @j;
        SET @j += 1;
    END;
    SET @i += 1;
END;

--12.3.4
GO
DECLARE @Count INT = 1;
WHILE @Count <= 100 BEGIN
    IF @Count % 2 = 0 BEGIN
        PRINT 'Even';
    END
    ELSE BEGIN
        PRINT 'Odd';
    END
    SET @Count += 1;
END;

 
 --12.3.5
 WHILE 1=1
     PRINT 'Oops';

--	This is an example of the dreaded infinite loop.

USE AdventureWorks2019;
GO
--12.4.1
CREATE TABLE #CustomerInfo(
    CustomerID INT, FirstName NVARCHAR(50),
    LastName NVARCHAR(50),CountOfSales INT,
    SumOfTotalDue MONEY);
GO
INSERT INTO #CustomerInfo(CustomerID,FirstName,LastName,
    CountOfSales, SumOfTotalDue)
SELECT C.CustomerID, FirstName, LastName,COUNT(*),SUM(TotalDue)
FROM Sales.Customer AS C
INNER JOIN Person.Person AS P ON C.CustomerID = P.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader
    AS SOH ON C.CustomerID = SOH.CustomerID
GROUP BY C.CustomerID, FirstName, LastName;

--12.4.2
DECLARE @CustomerInfo TABLE (
    CustomerID INT, FirstName VARCHAR(50),
    LastName VARCHAR(50),CountOfSales INT,
    SumOfTotalDue MONEY);
INSERT INTO @CustomerInfo(CustomerID,
    FirstName, LastName,
    CountOfSales, SumOfTotalDue)
 
SELECT C.CustomerID, FirstName,
    LastName,COUNT(*),SUM(TotalDue)
FROM Sales.Customer AS C
INNER JOIN Person.Person AS P
    ON C.CustomerID = P.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader
    AS SOH ON C.CustomerID = SOH.CustomerID
GROUP BY C.CustomerID, FirstName, LastName;

--12.4.3

--CAST(RAND() * 10000 AS INT) + 1

DECLARE @test TABLE (ID INTEGER NOT NULL IDENTITY, Random INT)
DECLARE @Count INT = 1;
DECLARE @Value INT;
  
WHILE @Count <= 1000 BEGIN
    SET @Value = CAST(RAND()*10000 AS INT) + 1;
    INSERT INTO @test(Random)
    VALUES(@Value);
    SET @Count += 1;
END;
SET @Count = 1;
WHILE @Count <= 1000 BEGIN
    SELECT @Value = Random
    FROM @test
    WHERE ID = @Count;
    PRINT @Value;
    SET @Count += 1;
END;

--12.4.4
 CREATE TABLE #TestTemp(
      ID INT NOT NULL PRIMARY KEY,
      VAL1 VARCHAR(20),
      VAL2 VARCHAR(30));

--12.4.5
DECLARE @TestTemp TABLE(
	  ID INT NOT NULL PRIMARY KEY,
	  VAL1 VARCHAR(20),
	  VAL2 VARCHAR(30));

--12.4.6
GO
--your values will vary
DECLARE @TestTemp TABLE(
	  ID INT NOT NULL PRIMARY KEY,
	  VAL1 VARCHAR(20),
	  VAL2 VARCHAR(30));
INSERT INTO @TestTemp(ID, Val1, Val2) 
VALUES(1,'abc','test');

UPDATE @TestTemp 
SET Val1 = 'happy';

SELECT * FROM @TestTemp;

