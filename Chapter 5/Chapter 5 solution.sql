/*
Chapter 5 solution
*/

USE AdventureWorks2019;
GO

--5.1.1
SELECT E.JobTitle, E.BirthDate, P.FirstName, P.LastName
FROM HumanResources.Employee AS E
INNER JOIN Person.Person AS P ON
    E.BusinessEntityID = P.BusinessEntityID;

--5.1.2
SELECT C.CustomerID, C.StoreID, C.TerritoryID,
    P.FirstName, P.MiddleName, P.LastName
FROM Sales.Customer AS C
INNER JOIN Person.Person AS P
    ON C.PersonID = P.BusinessEntityID;

--5.1.3
SELECT C.CustomerID, C.StoreID, C.TerritoryID,
    P.FirstName, P.MiddleName,
    P.LastName, S.SalesOrderID
FROM Sales.Customer AS C
INNER JOIN Person.Person AS P
    ON C.PersonID = P.BusinessEntityID
INNER JOIN Sales.SalesOrderHeader AS S
    ON S.CustomerID = C.CustomerID;


--5.1.4
SELECT S.SalesOrderID, SP.SalesQuota, SP.Bonus
FROM Sales.SalesOrderHeader AS S
INNER JOIN Sales.SalesPerson AS SP
    ON S.SalesPersonID = SP.BusinessEntityID;

--5.1.5
SELECT SalesOrderID, SalesQuota, Bonus, FirstName,
    MiddleName, LastName
FROM Sales.SalesOrderHeader AS S
INNER JOIN Sales.SalesPerson AS SP
    ON S.SalesPersonID = SP.BusinessEntityID
INNER JOIN Person.Person AS P
    ON SP.BusinessEntityID = P.BusinessEntityID;

USE WideWorldImporters;
GO
--5.1.6
SELECT 
        Application.Countries.CountryName             
		,Application.Countries.Subregion        
		,Application.StateProvinces.StateProvinceName
FROM Application.Countries 
INNER JOIN Application.StateProvinces
    ON Application.Countries.CountryID = Application.StateProvinces.CountryID;

--5.1.7
SELECT c.CountryName
        ,c.Subregion
        ,SP.StateProvinceName
FROM Application.Countries AS c
INNER JOIN Application.StateProvinces AS SP
    ON c.CountryID = SP.CountryID;


USE AdventureWorks2019;
GO

--5.2.1
SELECT SalesOrderID, P.ProductID, P.Name
FROM Production.Product AS P
LEFT OUTER JOIN Sales.SalesOrderDetail
    AS SOD ON P.ProductID = SOD.ProductID;
 

--5.2.2
SELECT SalesOrderID, P.ProductID, P.Name
FROM Production.Product AS P
LEFT OUTER JOIN Sales.SalesOrderDetail
    AS SOD ON P.ProductID = SOD.ProductID
WHERE SalesOrderID IS NULL;


--5.2.3
SELECT SalesOrderID, SalesPersonID, SalesYTD
FROM Sales.SalesPerson AS SP
LEFT OUTER JOIN Sales.SalesOrderHeader AS SOH
    ON SP.BusinessEntityID = SOH.SalesPersonID;


--5.2.4
SELECT SalesOrderID, SalesPersonID, SalesYTD, 
    FirstName, MiddleName, LastName
FROM Sales.SalesPerson AS SP
LEFT OUTER JOIN Sales.SalesOrderHeader AS SOH
    ON SP.BusinessEntityID = SOH.SalesPersonID
LEFT OUTER JOIN Person.Person AS P
    ON P.BusinessEntityID = SP.BusinessEntityID;
 
--5.2.5
SELECT CR.CurrencyRateID, CR.AverageRate,
    SM.ShipBase, SOH.SalesOrderID
FROM Sales.SalesOrderHeader AS SOH
LEFT OUTER JOIN Sales.CurrencyRate AS CR
    ON SOH.CurrencyRateID = CR.CurrencyRateID
LEFT OUTER JOIN Purchasing.ShipMethod AS SM
    ON SOH.ShipMethodID = SM.ShipMethodID;

USE WideWorldImporters;
GO
 --434 rows (your count may be different)
SELECT *
FROM sys.sysobjects sysobj1     

--434 * 434 rows = 188,356 rows    
SELECT *
FROM sys.sysobjects sysobj1
CROSS JOIN sys.sysobjects sysobj2

--I multiply 434 * 434; each row will be matched to every row of the second sys.sysobjects table.

--5.2.7
SELECT HomeOffice.CustomerName AS HomeOfficeCustName
    ,Stores.CustomerName AS StoresCustNames
    ,HomeOffice.CustomerID AS HomeOfficeCustID
    ,Stores.CustomerID AS StoresCustID
FROM Sales.Customers as HomeOffice
INNER JOIN Sales.Customers as Stores
    ON HomeOffice.CustomerID = Stores.BillToCustomerID
WHERE  Stores.BillToCustomerID = 1;
