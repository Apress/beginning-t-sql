/*
Chapter 13 solution
*/
USE tempdb;
GO
--13.1.1
--Here’s a possible solution: 
IF OBJECT_ID ('dbo.testCustomer') IS NOT NULL BEGIN
    DROP TABLE dbo.testCustomer;
END;
GO
CREATE TABLE dbo.testCustomer (
    CustomerID INT NOT NULL IDENTITY,
    FirstName VARCHAR(25), LastName VARCHAR(25),
    Age INT, Active CHAR(1) DEFAULT 'Y',
    CONSTRAINT ch_testCustomer_Age
        CHECK (Age < 120),
    CONSTRAINT ch_testCustomer_Active
        CHECK (Active IN ('Y','N')),
    CONSTRAINT PK_testCustomer PRIMARY KEY (CustomerID)
 
);
GO
INSERT INTO dbo.testCustomer(FirstName, LastName,Age)
VALUES ('Kathy','Morgan',35),
    ('Lady B.','Keller',14),
    ('Dennis','Wayne',30);
 
--13.1.2
IF OBJECT_ID('dbo.testOrder') IS NOT NULL BEGIN
    DROP TABLE dbo.testOrder;
END;
GO
CREATE TABLE dbo.testOrder
    (CustomerID INT NOT NULL,
        OrderID INT NOT NULL IDENTITY,
        OrderDate DATETIME DEFAULT GETDATE(),
        RW ROWVERSION,
        CONSTRAINT fk_testOrders
           FOREIGN KEY (CustomerID)
        REFERENCES dbo.testCustomer(CustomerID),
        CONSTRAINT PK_TestOrder PRIMARY KEY (OrderID)
    );
GO
INSERT INTO dbo.testOrder (CustomerID)
VALUES (1),(2),(3);
 
--13.1.3
IF OBJECT_ID('dbo.testOrderDetail') IS NOT NULL BEGIN
    DROP TABLE dbo.testOrderDetail;
END;
GO
CREATE TABLE dbo.testOrderDetail(
    OrderID INT NOT NULL, ItemID INT NOT NULL,
    Price Money NOT NULL, Qty INT NOT NULL,
    LineItemTotal AS (Price * Qty),
    CONSTRAINT pk_testOrderDetail
        PRIMARY KEY (OrderID, ItemID),
    CONSTRAINT fk_testOrderDetail
        FOREIGN KEY (OrderID)
        REFERENCES dbo.testOrder(OrderID)
);
GO
INSERT INTO dbo.testOrderDetail(OrderID,ItemID,Price,Qty)
VALUES (1,1,10,5),(1,2,5,10);

--13.1.4
CREATE TABLE #AllDefaults(ID INT NOT NULL IDENTITY, ANumber INT DEFAULT 1, TheDate DATETIME2 DEFAULT GETDATE());
INSERT INTO #AllDefaults DEFAULT VALUES;
SELECT * FROM #AllDefaults;

USE	AdventureWorks2019;
GO
--13.2.1
IF OBJECT_ID('dbo.vw_Products') IS NOT NULL BEGIN
   DROP VIEW dbo.vw_Products;
END;
GO
CREATE VIEW dbo.vw_Products AS (
    SELECT P.ProductID, P.Name, P.Color,
        P.Size, P.Style,
        H.StandardCost, H.EndDate, H.StartDate
    FROM Production.Product AS P
    INNER JOIN Production.ProductCostHistory AS H
        ON P.ProductID = H.ProductID);
GO
SELECT ProductID, Name, Color, Size, Style,
    StandardCost, EndDate, StartDate
FROM dbo.vw_Products;

--13.2.2
IF OBJECT_ID('dbo.vw_CustomerTotals') IS NOT NULL BEGIN
   DROP VIEW dbo.vw_CustomerTotals;
END;
GO
CREATE VIEW dbo.vw_CustomerTotals AS (
    SELECT C.CustomerID,
        YEAR(OrderDate) AS OrderYear,
        MONTH(OrderDate) AS OrderMonth,
        SUM(TotalDue) AS TotalSales
    FROM Sales.Customer AS C
    INNER JOIN Sales.SalesOrderHeader
        AS SOH ON C.CustomerID = SOH.CustomerID GROUP BY C.CustomerID,
        YEAR(OrderDate), MONTH(OrderDate));
GO
SELECT CustomerID, OrderYear,
    OrderMonth, TotalSales
FROM dbo.vw_CustomerTotals;

USE WideWorldImporters;
GO
--13.2.3
GO
CREATE VIEW Application.CityView
AS
	SELECT CityID
   		,StateProvinceID AS StateID
		,CityName
	FROM Application.Cities;
GO

--13.2.4
CREATE VIEW vw_BackorderPct
   AS
SELECT CAST(COUNT(BackorderOrderID) * 1.0 / 
   COUNT(OrderID) * 100 AS DECIMAL (5,3)) AS BackPct
FROM Sales.Orders;

--13.3.1
GO
CREATE OR ALTER FUNCTION dbo.fn_AddTwoNumbers
    (@NumberOne INT, @NumberTwo INT)
RETURNS INT AS BEGIN
    RETURN @NumberOne + @NumberTwo;
END;
GO
SELECT dbo.fn_AddTwoNumbers(1,2);

--13.3.2
GO
CREATE OR ALTER FUNCTION dbo.fn_RemoveNumbers
    (@Expression VARCHAR(250))
RETURNS VARCHAR(250) AS BEGIN
    RETURN REPLACE( REPLACE (REPLACE (REPLACE( REPLACE( REPLACE( REPLACE( REPLACE( REPLACE(
       REPLACE( @Expression,'1', ''),'2', ''),'3', ''),'4', ''),'5', ''),'6', ''),'7', ''),
          '8', ''),'9', ''),'0', '');
END;
GO
SELECT dbo.fn_RemoveNumbers
    ('abc 123 this is a test');


--13.3.3
GO
CREATE OR ALTER FUNCTION dbo.fn_FormatPhone
    (@Phone VARCHAR(10))
RETURNS VARCHAR(14) AS BEGIN
    DECLARE @NewPhone VARCHAR(14);
    SET @NewPhone = '(' + SUBSTRING(@Phone,1,3)
        + ') ';
    SET @NewPhone = @NewPhone +
        SUBSTRING(@Phone, 4, 3) + '-';
    SET @NewPhone = @NewPhone +
        SUBSTRING(@Phone, 7, 4);
    RETURN @NewPhone;
END;
GO
SELECT dbo.fn_FormatPhone('5555551234');

--13.3.4
GO
CREATE OR ALTER FUNCTION temperature (@temp DECIMAL(3,1), @ReturnUnitsIn char(1))
RETURNS DECIMAL(3,1)
AS
BEGIN
    DECLARE @Result DECIMAL(3,1) = 0
    IF @ReturnUnitsIn = 'C'
        SET @Result = (@temp - 32) / 1.8;
    ELSE IF @ReturnUnitsIn = 'F'
        SET @Result = (@temp * 1.8) + 32;
    RETURN @result;
END
GO
SELECT dbo.Temperature( 32 , 'C');

USE AdventureWorks2019;
GO
--13.4.1
CREATE OR ALTER PROCEDURE dbo.usp_CustomerTotals AS
    SELECT C.CustomerID,
        YEAR(OrderDate) AS OrderYear,
        MONTH(OrderDate) AS OrderMonth,
        SUM(TotalDue) AS TotalSales
    FROM Sales.Customer AS C
    INNER JOIN Sales.SalesOrderHeader
        AS SOH ON C.CustomerID = SOH.CustomerID
    GROUP BY C.CustomerID, YEAR(OrderDate),
        MONTH(OrderDate);
GO
EXEC dbo.usp_CustomerTotals;

--13.4.2
GO
CREATE OR ALTER PROCEDURE dbo.usp_CustomerTotals
    @CustomerID INT AS
    SELECT C.CustomerID,
        YEAR(OrderDate) AS OrderYear,
        MONTH(OrderDate) AS OrderMonth,
        SUM(TotalDue) AS TotalSales
    FROM Sales.Customer AS C
    INNER JOIN Sales.SalesOrderHeader
        AS SOH ON C.CustomerID = SOH.CustomerID
    WHERE C.CustomerID = @CustomerID
    GROUP BY C.CustomerID,
        YEAR(OrderDate), MONTH(OrderDate);
GO
EXEC dbo.usp_CustomerTotals 17910;
GO
--13.4.3
CREATE OR ALTER PROCEDURE dbo.usp_ProductSales
    @ProductID INT,
    @TotalSold INT = NULL OUTPUT AS
 
    SELECT @TotalSold = SUM(OrderQty)
    FROM Sales.SalesOrderDetail
    WHERE ProductID = @ProductID;
GO
DECLARE @TotalSold INT;
EXEC dbo.usp_ProductSales @ProductID = 776,
    @TotalSold =  @TotalSold OUTPUT;
PRINT @TotalSold;

--13.4.4
--Here is a possible solution
GO
CREATE OR ALTER PROCEDURE [dbo].[procAddNewPmtType] @pmtType varchar(40), @UserID int=1
AS
SET NOCOUNT ON
BEGIN
    BEGIN TRY
            DECLARE @MessageExists varchar(100) = (
                   SELECT TOP 1 PaymentMethodName 
                   FROM Application.PaymentMethods
                   WHERE PaymentMethodName = @pmtType
                                              )
			IF (@MessageExists) IS NOT NULL
			BEGIN
				PRINT 'Check for this type if it already exists'
				RETURN;
			END
			ELSE
			BEGIN
				SET XACT_ABORT ON
				DECLARE @PMI table (pmi int)
				BEGIN TRAN
					INSERT INTO Application.PaymentMethods (PaymentMethodName, LastEditedBy)
					OUTPUT Inserted.PaymentMethodID INTO @pmi
					VALUES (@pmtType, @UserID)				
				COMMIT TRAN
				SELECT pmi as ID 
				FROM @PMI				
			END														
    END TRY
    BEGIN CATCH	
		IF @@TRANCOUNT>0
			ROLLBACK

		UPDATE @PMI SET PMI=NULL--TRANSACTION ROLLED BACK; ID canceled';
		PRINT ERROR_NUMBER();
		PRINT ERROR_MESSAGE();
		PRINT ERROR_NUMBER();
		THROW  665555,  'ERROR OCCURRED - TRY AGAIN LATER',1;
    END CATCH
END

