/*
Chapter 10 solution
*/
--10.1
USE AdventureWorks2019;
GO
DROP TABLE IF EXISTS [dbo].[demoProduct]
GO
 
CREATE TABLE [dbo].[demoProduct](
    [ProductID] [INT] NOT NULL PRIMARY KEY,
    [Name] [dbo].[Name] NOT NULL,
    [Color] [NVARCHAR](15) NULL,
    [StandardCost] [MONEY] NOT NULL,
    [ListPrice] [MONEY] NOT NULL,
    [Size] [NVARCHAR](5) NULL,
    [Weight] [DECIMAL](8, 2) NULL,
);
DROP TABLE IF EXISTS [dbo].[demoSalesOrderHeader]
GO
 
CREATE TABLE [dbo].[demoSalesOrderHeader](
    [SalesOrderID] [INT] NOT NULL PRIMARY KEY,
    [SalesID] [INT] NOT NULL IDENTITY,
    [OrderDate] [DATETIME] NOT NULL,
    [CustomerID] [INT] NOT NULL,
    [SubTotal] [MONEY] NOT NULL,
    [TaxAmt] [MONEY] NOT NULL,
    [Freight] [MONEY] NOT NULL,
    [DateEntered] [DATETIME],
    [TotalDue]  AS (ISNULL(([SubTotal]+[TaxAmt])+[Freight],(0))),
    [RV] ROWVERSION NOT NULL);
GO
 
ALTER TABLE [dbo].[demoSalesOrderHeader] ADD  CONSTRAINT
    [DF_demoSalesOrderHeader_DateEntered]
DEFAULT (getdate()) FOR [DateEntered];
 
GO
DROP TABLE IF EXISTS [dbo].[demoAddress]
GO
 
CREATE TABLE [dbo].[demoAddress](
    [AddressID] [INT] NOT NULL IDENTITY PRIMARY KEY,
    [AddressLine1] [NVARCHAR](60) NOT NULL,
    [AddressLine2] [NVARCHAR](60) NULL,
    [City] [NVARCHAR](30) NOT NULL,
    [PostalCode] [NVARCHAR](15) NOT NULL
);

--10.1.1
SELECT Name, Color, StandardCost, ListPrice, Size, Weight
FROM Production.Product;
INSERT INTO dbo.demoProduct(ProductID,
    Name, Color, StandardCost,
    ListPrice, Size, Weight)
VALUES (680,'HL Road Frame - Black, 58','Black',1059.31,1431.50,'58',1016.04);
  
INSERT INTO dbo.demoProduct(ProductID, Name,
    Color,StandardCost, ListPrice, Size, Weight)
VALUES (706,'HL Road Frame - Red, 58','Red',1059.31, 1431.50,'58',1016.04);
 
INSERT INTO dbo.demoProduct(ProductID, Name,
    Color,StandardCost, ListPrice, Size, Weight)
VALUES (707,'Sport-100 Helmet, Red','Red',13.0863,34.99,NULL,NULL);
 
INSERT INTO dbo.demoProduct(ProductID, Name,
    Color,StandardCost, ListPrice, Size, Weight)
VALUES (708,'Sport-100 Helmet, Black','Black',13.0863,34.99,NULL,NULL);
 
INSERT INTO dbo.demoProduct(ProductID, Name,
    Color,StandardCost, ListPrice, Size, Weight)
VALUES (709,'Mountain Bike Socks, M', 'White',
    3.3963, 9.50, 'M',NULL);

--10.1.2
INSERT INTO dbo.demoProduct(ProductID, Name,
    Color, StandardCost, ListPrice, Size, Weight)
VALUES (711,'Sport-100 Helmet, Blue','Blue',
    13.0863,34.99,NULL,NULL),
    (712,'AWC Logo Cap','Multi',6.9223,
     8.99,NULL,NULL),
    (713,'Long-Sleeve Logo Jersey,S','Multi',
     38.4923,49.99,'S',NULL),
    (714,'Long-Sleeve Logo Jersey,M','Multi',
     38.4923,49.99,'M',NULL),
    (715,'Long-Sleeve Logo Jersey,L','Multi',
     38.4923,49.99,'L',NULL);

--10.1.3
-- Don't insert a value into the SalesID,
-- DateEntered, and RV columns..
 
INSERT INTO dbo.demoSalesOrderHeader(
    SalesOrderID, OrderDate, CustomerID,
    SubTotal, TaxAmt, Freight)
SELECT SalesOrderID, OrderDate, CustomerID,
    SubTotal, TaxAmt, Freight
FROM Sales.SalesOrderHeader;

--10.1.4
SELECT COUNT(ISNULL(SalesOrderID,0))
    AS CountOfOrders, c.CustomerID,
    SUM(TotalDue) AS TotalDue
INTO dbo.tempCustomerSales
FROM Sales.Customer AS c
LEFT JOIN Sales.SalesOrderHeader
    AS soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID;

--10.1.5
INSERT INTO dbo.demoProduct (ProductID, Name,
    Color, StandardCost,
    ListPrice, Size, Weight)
SELECT ProductID, Name, Color, StandardCost,
    ListPrice, Size, Weight
FROM Production.Product AS P
WHERE NOT EXISTS (
    SELECT ProductID
    FROM dbo.demoProduct AS DP
    WHERE DP.ProductID = P.ProductID);


--10.1.6
SET IDENTITY_INSERT dbo.demoAddress ON;
 
INSERT INTO dbo.demoAddress(AddressID,
          AddressLine1, AddressLine2,
          City, PostalCode)
      SELECT AddressID, AddressLine1, AddressLine2,
          City, PostalCode
      FROM Person.Address AS A
      JOIN Person.StateProvince AS SP ON A.StateProvinceID = SP.StateProvinceID;
      --to turn the setting off
SET IDENTITY_INSERT dbo.demoAddress OFF;

USE WideWorldImporters;
GO

--10.1.7
--Here’s a possible solution
--Since VehicleTemperatureID is an IDENTITY column, you cannot
--insert a value into it
INSERT INTO Warehouse.VehicleTemperatures
     (VehicleRegistration, ChillerSensorNumber,RecordedWhen, Temperature, FullSensorData, IsCompressed,CompressedSensorData)
VALUES ('Registration', -1,  '5/1/2020', 0.00, NULL, 1, NULL);

--10.1.8
SELECT * 
INTO dbo.VehicleTemperatures
FROM Warehouse.VehicleTemperatures;

USE AdventureWorks2019;
GO

--10.2.1
DELETE FROM dbo.demoCustomer
WHERE LastName LIKE 'S%';

--10.2.2
DELETE C FROM  dbo.demoCustomer AS C
WHERE NOT EXISTS (
    SELECT *
    FROM dbo.demoSalesOrderHeader AS SOH
    WHERE C.CustomerID = SOH.CustomerID
    GROUP BY SOH.CustomerID
    HAVING SUM(TotalDue) >=1000);

--10.2.3
DELETE P FROM dbo.demoProduct AS P
WHERE NOT EXISTS    (
    SELECT *
    FROM dbo.demoSalesOrderDetail AS SOD
    WHERE P.ProductID = SOD.ProductID);

USE WideWorldImporters;
GO
--10.2.4
--Modify to use the value you used
SELECT * 
FROM Warehouse.VehicleTemperatures
WHERE RecordedWhen = '2020-05-01';

DELETE 
FROM Warehouse.VehicleTemperatures
WHERE RecordedWhen = '2020-05-01';

--10.2.5
TRUNCATE TABLE dbo.VehicleTemperatures;

USE AdventureWorks2019;
GO

--10.3.1
UPDATE dbo.demoAddress SET AddressLine2 = 'N/A'
WHERE AddressLine2 IS NULL;

--10.3.2
UPDATE dbo.demoProduct
SET ListPrice =ListPrice *  1.1;

--10.3.3
UPDATE SOD
SET UnitPrice = P.ListPrice
FROM dbo.demoSalesOrderDetail AS SOD
INNER JOIN dbo.demoProduct AS P
    ON SOD.ProductID = P.ProductID;

USE WideWorldImporters;
GO
--10.3.4
SELECT * FROM Sales.Orders
WHERE PickedByPersonID IS NULL;

UPDATE [Sales].[Orders]
SET PickedByPersonID = 1
WHERE PickedByPersonID IS NULL;

--10.3.5
--One solution
UPDATE [Sales].[Orders]
SET InternalComments = COALESCE(InternalComments, DeliveryInstructions);

--Another solution
UPDATE [Sales].[Orders]
SET InternalComments = DeliveryInstructions
WHERE DeliveryInstructions IS NULL;
