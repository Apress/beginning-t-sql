/*
Chapter 11 code
*/

--Listing 11-1. Explicit Transactions
DROP TABLE IF EXISTS [dbo].[demoTransaction];
GO
 
CREATE TABLE dbo.demoTransaction (col1 INT NOT NULL);
GO
 
--1
BEGIN TRAN
    INSERT INTO dbo.demoTransaction (col1) VALUES (1);
    INSERT INTO dbo.demoTransaction (col1) VALUES (2);
COMMIT TRAN;
 
--2
BEGIN TRAN
    INSERT INTO dbo.demoTransaction (col1) VALUES (3);
    INSERT INTO dbo.demoTransaction (col1) VALUES ('a');
COMMIT TRAN;
 
GO
--3
SELECT col1
FROM dbo.demoTransaction;


--Listing 11-2. Using a ROLLBACK Command
DROP TABLE IF EXISTS [dbo].[demoTransaction];
GO
 
CREATE TABLE dbo.demoTransaction (col1 INT NOT NULL);
GO
 
--1
BEGIN TRAN
    INSERT INTO dbo.demoTransaction (col1) VALUES (1);
    INSERT INTO dbo.demoTransaction (col1) VALUES (2);
COMMIT TRAN 
  
--2
BEGIN TRAN
    INSERT INTO dbo.demoTransaction (col1) VALUES (3);
    INSERT INTO dbo.demoTransaction (col1) VALUES (4);
ROLLBACK TRAN
 
GO
--3
SELECT col1
FROM dbo.demoTransaction;


 
--Listing 11-3. Nested transactions
--1
DROP TABLE IF EXISTS #table1;
DROP TABLE IF EXISTS #Table2;
CREATE TABLE #Table1 (Col1 INT);
CREATE TABLE #Table2 (Col2 VARCHAR(10));


--2
BEGIN TRANSACTION;
	INSERT INTO #Table1(Col1)
	VALUES(0),(1),(2);
--3
BEGIN TRANSACTION;
	INSERT INTO #Table2(Col2)
	VALUES('a'),('b');
--4
COMMIT;

--5
SELECT * FROM #Table1;
SELECT * FROM #Table2;

	
--Listing 11-4. Using XACT_ABORT with the Setting Off
--1
CREATE TABLE #Test_XACT_OFF(COL1 INT PRIMARY KEY, COL2 VARCHAR(10));
 
--2
--What happens with the default?
BEGIN TRANSACTION
    INSERT INTO #Test_XACT_OFF(COL1,COL2)
    VALUES(1,'A');
     
    INSERT INTO #Test_XACT_OFF(COL1,COL2)
        VALUES(2,'B');
 
    INSERT INTO #Test_XACT_OFF(COL1,COL2)
        VALUES(1,'C');
COMMIT TRANSACTION;
 
--3
SELECT * FROM #Test_XACT_OFF;


--Listing 11-5. Testing XACT_ABORT with the Setting On
--1
CREATE TABLE #Test_XACT_ON(COL1 INT PRIMARY KEY, COL2 VARCHAR(10));
 
--2
--Turn on the setting
SET XACT_ABORT ON;
GO
 
--3
BEGIN TRANSACTION
    INSERT INTO #Test_XACT_ON(COL1,COL2)
    VALUES(1,'A');
     
    INSERT INTO #Test_XACT_ON(COL1,COL2)
        VALUES(2,'B');
 
    INSERT INTO #Test_XACT_ON(COL1,COL2)
        VALUES(1,'C');
COMMIT TRANSACTION;
 
GO
--4
SELECT * FROM #Test_XACT_ON;
GO
 
--5
SET XACT_ABORT OFF;

--Listing 11-6. Using TRY . . . CATCH
--1
BEGIN TRY
    PRINT 1/0;
END TRY
BEGIN CATCH
    PRINT 'Inside the Catch block';
    PRINT ERROR_NUMBER();
    PRINT ERROR_MESSAGE();
    --can access error_number() multiple times
    PRINT ERROR_NUMBER();
END CATCH
PRINT 'Outside the catch block';
PRINT CASE WHEN ERROR_NUMBER() IS NULL THEN 'NULL'
    ELSE CAST(ERROR_NUMBER() AS VARCHAR(10)) END;
GO
 
--2
BEGIN TRY
    DROP TABLE testTable;
END TRY
BEGIN CATCH
    PRINT 'An error has occurred.'
    PRINT ERROR_NUMBER();
    PRINT ERROR_MESSAGE();
END CATCH;


--Listing 11-7. Untrappable Errors
--1
PRINT 'Syntax error.';
GO
BEGIN TRY
    SELECT FROM Sales.SalesOrderDetail;
END TRY
BEGIN CATCH
    PRINT ERROR_NUMBER();
END CATCH;
GO
 
--2
PRINT 'Invalid column.';
GO
BEGIN TRY
    SELECT ABC FROM Sales.SalesOrderDetail;
END TRY
BEGIN CATCH
    PRINT ERROR_NUMBER();
END CATCH;
 
--Listing 11-8. Using RAISERROR
USE master;
GO
 
--1 This code section creates a custom error message
IF EXISTS(SELECT * FROM sys.messages where message_id = 50002) BEGIN
    EXEC sp_dropmessage 50002;
END;
GO
PRINT 'Creating a custom error message.'
EXEC sp_addmessage 50002, 16,
   N'Customer missing.';
GO
 
USE AdventureWorks2019;
GO
--2
IF NOT EXISTS(SELECT * FROM Sales.Customer
          WHERE CustomerID = -1) BEGIN
   RAISERROR(50002,16,1);
END;
GO
 
--3
BEGIN TRY
    PRINT 1/0;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() = 8134 BEGIN
        RAISERROR('A bad math error!',16,1);
    END;
END CATCH;

--Listing 11-9. Using TRY . . . CATCH with a Transaction
--1
CREATE TABLE #Test (ID INT NOT NULL PRIMARY KEY);
GO
 
--2
BEGIN TRY
    --2.1
    BEGIN TRAN
        --2.1.1
        INSERT INTO #Test (ID)
        VALUES (1),(2),(3);
        --2.1.2
        UPDATE #Test SET ID = 2 WHERE ID = 1;
    --2.2
    COMMIT
END TRY
 
--3
BEGIN CATCH
    --3.1
    PRINT ERROR_MESSAGE();
    --3.2
    PRINT 'Rolling back transaction';
    IF @@TRANCOUNT > 0 BEGIN
        ROLLBACK;
    END;
END CATCH;

--Listing 11-10. Simple THROW Statement
THROW 999999, 'This is a test error.', 1; 

--Listing 11-11. Using THROW in a transaction
BEGIN TRY
INSERT INTO Person.PersonPhone (BusinessEntityID, PhoneNumber, PhoneNumberTypeID)
VALUES (1, '697-555-0142', 1);
END TRY
BEGIN CATCH
THROW 999999, 'I will not allow you to insert a duplicate value.', 1;
END CATCH;

--Listing 11-12. Begin a transaction in one window 
DROP TABLE IF EXISTS [dbo].[demoTransaction];
GO
 
CREATE TABLE dbo.demoTransaction (col1 INT NOT NULL);
GO
 
BEGIN TRAN
    INSERT INTO dbo.demoTransaction (col1) VALUES (1);
    INSERT INTO dbo.demoTransaction (col1) VALUES (2);

--Listing 11-13. Code from another window
SELECT col1 FROM dbo.demoTransaction;

--Back in first window 
COMMIT;

--Listing 11-14. Change isolation level in window 1
--1
DROP TABLE IF EXISTS [dbo].[demoTransaction];
GO
 
CREATE TABLE dbo.demoTransaction (col1 INT NOT NULL);
GO
--2
INSERT INTO dbo.demoTransaction (col1) VALUES (1);
INSERT INTO dbo.demoTransaction (col1) VALUES (2);
 
--3
BEGIN TRANSACTION
UPDATE dbo.demoTransaction SET Col1 = 100;

--Listing 11-15. Run in window 2
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT col1 FROM dbo.demoTransaction;

--Run in window 1
ROLLBACK;