/*
Chapter 16 code
*/

--Listing 16-1. Naming Columns
WITH myCTE ([First Name], [Last Name], [Full Name])
AS(
    SELECT FirstName, LastName, CONCAT(FirstName, ' ', LastName) 
        FROM Person.Person
)
SELECT [First Name], [Last Name], [Full Name]
FROM myCTE;


--Listing 16-2. Create Data for This Section’s Examples
DROP TABLE IF EXISTS #Employees;
DROP TABLE IF EXISTS #JobHistory;
GO
CREATE TABLE #Employees(
	EmployeeID INT, 
	JobTitle NVARCHAR(50), 
	ManagerID INT);
CREATE TABLE #JobHistory(
    EmployeeID INT NOT NULL, 
    EffDate DATE NOT NULL, 
    EffSeq INT NOT NULL,
    EmploymentStatus CHAR(1) NOT NULL,
    JobTitle VARCHAR(50) NOT NULL,
    Salary MONEY NOT NULL,
    ActionDesc VARCHAR(20)
 CONSTRAINT PK_TempJobHistory PRIMARY KEY CLUSTERED 
(
    EmployeeID, EffDate, EffSeq
));


INSERT INTO #Employees (EmployeeID,JobTitle,ManagerID)
SELECT BusinessEntityID, JobTitle, NULL 
FROM HumanResources.Employee
WHERE OrganizationLevel IS NULL; 

INSERT INTO #Employees (EmployeeID,JobTitle,ManagerID)
SELECT BusinessEntityID, JobTitle, (SELECT EmployeeID FROM #Employees) 
FROM HumanResources.Employee
WHERE OrganizationLevel = 1;

INSERT INTO #Employees (EmployeeID,JobTitle,ManagerID)
SELECT E.BusinessEntityID, E.JobTitle, M.BusinessEntityID
FROM HumanResources.Employee AS E 
JOIN HumanResources.Employee AS M 
	ON E.OrganizationNode.GetAncestor(1) = M.OrganizationNode
WHERE E.OrganizationLevel > 1;

INSERT INTO #JobHistory(EmployeeID, EffDate, EffSeq, EmploymentStatus, 
    JobTitle, Salary, ActionDesc)
VALUES 
    (1000,'07-31-2018',1,'A','Intern',2000,'New Hire'),
    (1000,'05-31-2019',1,'A','Production Technician',2000,'Title Change'),
    (1000,'05-31-2019',2,'A','Production Technician',2500,'Salary Change'),
    (1000,'11-01-2019',1,'A','Production Technician',3000,'Salary Change'),
    (1200,'01-10-2019',1,'A','Design Engineer',5000,'New Hire'),
    (1200,'05-01-2019',1,'T','Design Engineer',5000,'Termination'),
    (1100,'08-01-2018',1,'A','Accounts Payable Specialist I',2500,'New Hire'),
    (1100,'05-01-2019',1,'A','Accounts Payable Specialist II',2500,'Title Change'),
    (1100,'05-01-2019',2,'A','Accounts Payable Specialist II',3000,'Salary Change'); 

--Listing 16-3. A Query with Multiple CTEs
WITH 
Emp AS(
    SELECT e.EmployeeID, e.ManagerID,e.JobTitle AS EmpTitle,
        p.FirstName + ISNULL(' ' + p.MiddleName,'') + ' ' + p.LastName AS EmpName
    FROM #Employees AS e
    INNER JOIN Person.Person AS p
    ON e.EmployeeID = p.BusinessEntityID
    ),
Mgr AS(
    SELECT e.EmployeeID AS ManagerID,e.JobTitle AS MgrTitle,
        p.FirstName + ISNULL(' ' + p.MiddleName,'') + ' ' + p.LastName AS MgrName
    FROM #Employees AS e
    INNER JOIN Person.Person AS p
    ON e.EmployeeID = p.BusinessEntityID
    )
SELECT EmployeeID, Emp.ManagerID, EmpName, EmpTitle, MgrName, MgrTitle
FROM Emp LEFT JOIN Mgr ON Emp.ManagerID = Mgr.ManagerID;

--Listing 16-4. Calling a CTE Multiple Times Within a Statement
WITH 
Employees AS(
    SELECT e.EmployeeID, e.ManagerID, e.JobTitle,
        p.FirstName + ISNULL(' ' + p.MiddleName,'') + ' ' +  p.LastName AS EmpName
    FROM #Employees AS e
    INNER JOIN Person.Person AS p
    ON e.EmployeeID = p.BusinessEntityID
    )
SELECT emp.EmployeeID, emp.ManagerID, emp.EmpName, emp.JobTitle AS EmpTitle, 
   mgr.EmpName as MgrName, mgr.JobTitle as MgrTitle
FROM Employees AS Emp 
LEFT JOIN Employees AS Mgr 
ON Emp.ManagerID = Mgr.EmployeeID;

--Listing 16-5. Joining a CTE to Another CTE
--1
DECLARE @Date DATE = '05-02-2019';
 
--2
WITH EffectiveDate AS (
        SELECT MAX(EffDate) AS MaxDate, EmployeeID
        FROM #JobHistory 
        WHERE EffDate <= @Date 
        GROUP BY EmployeeID
    ),
    EffectiveSeq AS (
        SELECT MAX(EffSeq) AS MaxSeq, j.EmployeeID, MaxDate
        FROM #JobHistory AS j 
        INNER JOIN EffectiveDate AS d 
            ON j.EffDate = d.MaxDate AND j.EmployeeID = d.EmployeeID
        GROUP BY j.EmployeeID, MaxDate)
SELECT j.EmployeeID, EmploymentStatus, JobTitle, Salary
FROM #JobHistory AS j 
INNER JOIN EffectiveSeq AS e ON j.EmployeeID = e.EmployeeID 
    AND j.EffDate = e.MaxDate AND j.EffSeq = e.MaxSeq;

--Listing 16-6. A Recursive CTE
WITH OrgChart (EmployeeID, ManagerID, JobTitle, Level,Node)
    AS (SELECT EmployeeID, ManagerID, JobTitle, 0, 
            CONVERT(VARCHAR(30),'/') AS Node
        FROM #Employees
        WHERE ManagerID IS NULL
        UNION ALL
        SELECT Emp.EmployeeID, Emp.ManagerID, Emp.JobTitle, OrgChart.Level + 1,
           CONVERT(VARCHAR(30), OrgChart.Node + 
           CONVERT(VARCHAR(30), ROW_NUMBER() OVER(ORDER BY Emp.ManagerID)) + '/')
        FROM #Employees AS Emp
        INNER JOIN OrgChart  ON Emp.ManagerID = OrgChart.EmployeeID
    )
SELECT EmployeeID, ManagerID, SPACE(Level * 3) + JobTitle AS Title, Level, Node
FROM OrgChart
ORDER BY Node;
 
--2 Incorrectly written Recursive CTE
WITH OrgChart (EmployeeID, ManagerID, JobTitle, Level,Node)
    AS (SELECT EmployeeID, ManagerID, JobTitle, 0, 
            CONVERT(VARCHAR(30),'/') AS Node
        FROM #Employees
        WHERE ManagerID IS NOT NULL
        UNION ALL
        SELECT Emp.EmployeeID, Emp.ManagerID,Emp.JobTitle, OrgChart.Level + 1,
           CONVERT(VARCHAR(30),OrgChart.Node + 
              CONVERT(VARCHAR,ROW_NUMBER()OVER(ORDER BY Emp.ManagerID)) + '/')
        FROM #Employees AS Emp
        INNER JOIN OrgChart  ON Emp.EmployeeID = OrgChart.EmployeeID
    )
SELECT EmployeeID, ManagerID, SPACE(Level * 3) + JobTitle AS Title, Level, Node
FROM OrgChart 
ORDER BY Node OPTION (MAXRECURSION 10);

--Listing 16-7. Using CTEs to Manipulate Data 
--1
USE tempdb;
GO
CREATE TABLE dbo.CTEExample(CustomerID INT, FirstName NVARCHAR(50),
    LastName NVARCHAR(50), Sales Money);
 
--2
WITH Cust AS(
        SELECT CustomerID, FirstName, LastName 
        FROM AdventureWorks2019.Sales.Customer AS C 
        JOIN AdventureWorks2019.Person.Person AS P ON C.CustomerID = P.BusinessEntityID
)
INSERT INTO dbo.CTEExample(CustomerID, FirstName, LastName) 
SELECT CustomerID, FirstName, LastName 
FROM Cust;
 
--3
WITH Totals AS (
        SELECT CustomerID, SUM(TotalDue) AS CustTotal 
        FROM AdventureWorks2017.Sales.SalesOrderHeader
        GROUP BY CustomerID)
UPDATE C SET Sales = CustTotal 
FROM CTEExample AS C 
INNER JOIN Totals ON C.CustomerID = Totals.CustomerID;
 
--4
WITH Cust AS(
        SELECT CustomerID, Sales 
        FROM CTEExample)
DELETE Cust 
WHERE Sales < 10000;


--Listing 16-8. Using a Correlated Subquery in the SELECT List
USE AdventureWorks2019;
GO
SELECT CustomerID, C.StoreID, C.AccountNumber,
    (SELECT COUNT(*) 
     FROM Sales.SalesOrderHeader AS SOH
     WHERE SOH.CustomerID = C.CustomerID) AS CountOfSales
FROM Sales.Customer AS C
ORDER BY CountOfSales DESC;
 
--2
SELECT CustomerID, C.StoreID, C.AccountNumber, 
    (SELECT COUNT(*) AS CountOfSales 
     FROM Sales.SalesOrderHeader AS SOH
     WHERE SOH.CustomerID = C.CustomerID) AS CountOfSales,
    (SELECT SUM(TotalDue)
     FROM Sales.SalesOrderHeader AS SOH
     WHERE SOH.CustomerID = C.CustomerID) AS SumOfTotalDue,
    (SELECT AVG(TotalDue)
     FROM Sales.SalesOrderHeader AS SOH
     WHERE SOH.CustomerID = C.CustomerID) AS AvgOfTotalDue
FROM Sales.Customer AS C
ORDER BY CountOfSales DESC;

--Listing 16-9. Using a Derived Table
SELECT c.CustomerID, c.StoreID, c.AccountNumber, s.CountOfSales,
    s.SumOfTotalDue, s.AvgOfTotalDue
FROM Sales.Customer AS c INNER JOIN
    (SELECT CustomerID, COUNT(*) AS CountOfSales,
         SUM(TotalDue) AS SumOfTotalDue,
         AVG(TotalDue) AS AvgOfTotalDue
     FROM Sales.SalesOrderHeader
     GROUP BY CustomerID) AS s 
ON c.CustomerID = s.CustomerID;

--Listing 16-10. Using a Common Table Expression
WITH s AS 
    (SELECT CustomerID, COUNT(*) AS CountOfSales,
        SUM(TotalDue) AS SumOfTotalDue,
        AVG(TotalDue) AS AvgOfTotalDue
     FROM Sales.SalesOrderHeader
     GROUP BY CustomerID) 
SELECT c.CustomerID, c.StoreID, c.AccountNumber, s.CountOfSales,
    s.SumOfTotalDue, s.AvgOfTotalDue
FROM Sales.Customer AS c INNER JOIN s
ON c.CustomerID = s.CustomerID;


--Listing 16-11. Using CROSS APPLY
--1
SELECT SOH.CustomerID, SOH.OrderDate, SOH.TotalDue, CRT.RunningTotal 
FROM Sales.SalesOrderHeader AS SOH 
CROSS APPLY(
    SELECT SUM(TotalDue) AS RunningTotal
        FROM Sales.SalesOrderHeader RT
        WHERE RT.CustomerID = SOH.CustomerID 
           AND RT.SalesOrderID <= SOH.SalesOrderID) AS CRT
ORDER BY SOH.CustomerID, SOH.SalesOrderID;
 
--2
SELECT Prd.ProductID, S.SalesOrderID
FROM Production.Product AS Prd 
OUTER APPLY (
  SELECT TOP(2) SalesOrderID 
  FROM Sales.SalesOrderDetail AS SOD
  WHERE SOD.ProductID = Prd.ProductID
  ORDER BY SalesOrderID) AS S
WHERE Prd.FinishedGoodsFlag = 1
ORDER BY Prd.ProductID;

--Listing 16-12. More uses of CROSS and OUTER APPLY
USE WideWorldImporters;
GO
--1
SELECT InvoiceID
       , DeliveryInstructions
       ,TRIM(value) AS Items  
FROM Sales.Invoices
CROSS APPLY 
	STRING_SPLIT(DeliveryInstructions, ',');

--2
SELECT Backordered.[Status]
	,OrderID
FROM [WideWorldImporters].[Sales].[Orders]
CROSS APPLY 
(VALUES(CASE 
	WHEN BackorderOrderID IS NOT NULL THEN 'Y' 
	ELSE 'N' END)) Backordered ([Status]);

--3
SELECT COUNT(*) AS StatusCount, [Status]
FROM [WideWorldImporters].[Sales].[Orders]
CROSS APPLY 
(VALUES(CASE 
	WHEN BackorderOrderID IS NOT NULL THEN 'Y' 
	ELSE 'N' END)) Backordered ([Status])
GROUP BY [Status];

--Listing 16-13. Viewing the Manipulated Data with OUTPUT
--1
USE tempdb; 
GO
DROP TABLE IF EXISTS dbo.Customers;

CREATE TABLE dbo.Customers (CustomerID INT NOT NULL PRIMARY KEY, 
    Name VARCHAR(150),PersonID INT NOT NULL);
GO
 
--2
INSERT INTO dbo.Customers(CustomerID,Name,PersonID)
OUTPUT inserted.CustomerID,inserted.Name
SELECT c.CustomerID, p.FirstName + ' ' + p.LastName, c.PersonID
FROM AdventureWorks2019.Sales.Customer AS c 
INNER JOIN AdventureWorks2019.Person.Person AS p
ON c.PersonID = p.BusinessEntityID;
 
--3
UPDATE c SET Name = p.FirstName + 
    ISNULL(' ' + p.MiddleName,'') + ' ' + p.LastName 
OUTPUT deleted.CustomerID,deleted.Name AS OldName, inserted.Name AS NewName
FROM dbo.Customers AS c 
INNER JOIN AdventureWorks2019.Person.Person AS p on c.PersonID = p.BusinessEntityID;
 
--4
DELETE FROM dbo.Customers 
OUTPUT deleted.CustomerID, deleted.Name, deleted.PersonID 
WHERE CustomerID = 11000;

--Listing 16-14. Saving the Results of OUTPUT
Use tempdb;
GO
--1
DROP TABLE IF EXISTS dbo.Customers;
DROP TABLE IF EXISTS dbo.CustomerHistory;
 
CREATE TABLE dbo.Customers (CustomerID INT NOT NULL PRIMARY KEY, 
    Name VARCHAR(150),PersonID INT NOT NULL);
 
CREATE TABLE dbo.CustomerHistory(CustomerID INT NOT NULL PRIMARY KEY,
    OldName VARCHAR(150), NewName VARCHAR(150), 
    ChangeDate DATETIME);
GO
 
--2
INSERT INTO dbo.Customers(CustomerID, Name, PersonID)
SELECT c.CustomerID, p.FirstName + ' ' + p.LastName,PersonID
FROM AdventureWorks2019.Sales.Customer AS c 
INNER JOIN AdventureWorks2019.Person.Person AS p
ON c.PersonID = p.BusinessEntityID;
 
--3
UPDATE c SET Name = p.FirstName + 
    ISNULL(' ' + p.MiddleName,'') + ' ' + p.LastName   
OUTPUT deleted.CustomerID,deleted.Name, inserted.Name, GETDATE()
INTO dbo.CustomerHistory 
FROM dbo.Customers AS c 
INNER JOIN AdventureWorks2019.Person.Person AS p on c.PersonID = p.BusinessEntityID;
 
--4
SELECT CustomerID, OldName, NewName,ChangeDate 
FROM dbo.CustomerHistory
ORDER BY CustomerID;
 
 --Listing 16-15. Using the MERGE Statement
USE tempdb;
GO
--1 
DROP TABLE IF EXISTS dbo.CustomerSource;
DROP TABLE IF EXISTS dbo.CustomerTarget;
 
CREATE TABLE dbo.CustomerSource (CustomerID INT NOT NULL PRIMARY KEY,
    Name VARCHAR(150) NOT NULL, PersonID INT NOT NULL);
CREATE TABLE dbo.CustomerTarget (CustomerID INT NOT NULL PRIMARY KEY,
    Name VARCHAR(150) NOT NULL, PersonID INT NOT NULL);
 
--2
INSERT INTO dbo.CustomerSource(CustomerID,Name,PersonID)
SELECT CustomerID, 
    p.FirstName + ISNULL(' ' + p.MiddleName,'') + ' ' + p.LastName, 
    c.PersonID
FROM AdventureWorks2019.Sales.Customer AS c 
INNER JOIN AdventureWorks2019.Person.Person AS p ON c.PersonID = p.BusinessEntityID
WHERE c.CustomerID IN (29485,29486,29487,20075);
 
--3
INSERT INTO dbo.CustomerTarget(CustomerID,Name,PersonID)
SELECT c.CustomerID, p.FirstName  + ' ' + p.LastName, PersonID
FROM AdventureWorks2019.Sales.Customer AS c 
INNER JOIN AdventureWorks2019.Person.Person AS p ON c.PersonID = p.BusinessEntityID
WHERE c.CustomerID IN (29485,29486,21139);
 
--4
SELECT CustomerID, Name, PersonID
FROM dbo.CustomerSource
ORDER BY CustomerID;
   
--5
SELECT CustomerID, Name, PersonID
FROM dbo.CustomerTarget
ORDER BY CustomerID;
 
--6
MERGE dbo.CustomerTarget AS t
USING dbo.CustomerSource AS s
ON (s.CustomerID = t.CustomerID)
WHEN MATCHED AND s.Name <> t.Name
THEN UPDATE SET Name = s.Name
WHEN NOT MATCHED BY TARGET
THEN INSERT (CustomerID, Name, PersonID) VALUES (CustomerID, Name, PersonID)
WHEN NOT MATCHED BY SOURCE
THEN DELETE
OUTPUT $action, DELETED.*, INSERTED.*;--semi-colon is required 
 
--7
SELECT CustomerID, Name, PersonID
FROM dbo.CustomerTarget
ORDER BY CustomerID;


--Listing 16-16. Using GROUPING SETS
USE AdventureWorks2019;
GO
--1
SELECT NULL AS SalesOrderID, SUM(UnitPrice)AS SumOfPrice, ProductID
FROM Sales.SalesOrderDetail
WHERE SalesOrderID BETWEEN 44175 AND 44178
GROUP BY ProductID
UNION ALL
SELECT SalesOrderID,SUM(UnitPrice), NULL 
FROM Sales.SalesOrderDetail
WHERE SalesOrderID BETWEEN 44175 AND 44178
GROUP BY SalesOrderID;
 
--2
SELECT SalesOrderID, SUM(UnitPrice) AS SumOfPrice,ProductID
FROM Sales.SalesOrderDetail 
WHERE SalesOrderID BETWEEN 44175 AND 44178
GROUP BY GROUPING SETS(SalesOrderID, ProductID);


--Listing 16-17. Using CUBE and ROLLUP
--1
SELECT COUNT(*) AS CountOfRows, 
    ISNULL(Color, CASE WHEN GROUPING(Color)=0 THEN 'UNK' ELSE 'ALL' END) AS Color,
        ISNULL(Size,CASE WHEN GROUPING(Size) = 0 THEN 'UNK' ELSE 'ALL' END) AS Size
FROM Production.Product
GROUP BY CUBE(Color,Size)
ORDER BY Color, Size;
 
--2
SELECT COUNT(*) AS CountOfRows,
    ISNULL(Color, CASE WHEN GROUPING(Color)=0 THEN 'UNK' ELSE 'ALL' END) AS Color,
        ISNULL(Size,CASE WHEN GROUPING(Size) = 0 THEN 'UNK' ELSE 'ALL' END) AS Size
FROM Production.Product
GROUP BY ROLLUP(Color,Size)
ORDER BY Color, Size;
 
 --Listing 16-18. Using CASE to Pivot Data
SELECT YEAR(OrderDate) AS OrderYear,
ROUND(SUM(CASE MONTH(OrderDate) WHEN 1 THEN TotalDue ELSE 0 END),0) 
    AS Jan,
ROUND(SUM(CASE MONTH(OrderDate) WHEN 2 THEN TotalDue ELSE 0 END),0) 
    AS Feb,
ROUND(SUM(CASE MONTH(OrderDate) WHEN 3 THEN TotalDue ELSE 0 END),0) 
    AS Mar,
ROUND(SUM(CASE MONTH(OrderDate) WHEN 4 THEN TotalDue ELSE 0 END),0) 
    AS Apr,
ROUND(SUM(CASE MONTH(OrderDate) WHEN 5 THEN TotalDue ELSE 0 END),0) 
    AS May,
ROUND(SUM(CASE MONTH(OrderDate) WHEN 6 THEN TotalDue ELSE 0 END),0) 
    AS Jun
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate)
ORDER BY OrderYear;


--Listing 16-19. Pivoting weather data with CASE
--1 
CREATE TABLE #test
    (dt date
    ,Plant varchar(30)
    ,Weather varchar(30));

--2 Set up the data
INSERT INTO #test VALUES  ('2020/1/1', 'TX', 'Sunny'), 
('2020/1/1','CA', 'Cloudy'), 
('2020/1/2', 'OK', 'Rain');

--3 Analyze the data
SELECT * FROM #test;

--4
SELECT  dt AS [WeatherDate],TX,CA,OK 
FROM
    (SELECT
        dt
        ,MAX(CASE WHEN PLANT = 'TX' THEN weather END) AS TX
        ,MAX(CASE WHEN PLANT = 'CA' THEN weather END) AS CA
        ,MAX(CASE WHEN PLANT = 'OK' THEN weather END) AS OK
        FROM #Test
        GROUP BY dt
        )x;


--Listing 16-20. Pivoting Results with PIVOT
--1
SELECT OrderYear, [1] AS Jan, [2] AS Feb, [3] AS Mar, 
    [4] AS Apr, [5] AS May, [6] AS Jun
FROM (SELECT YEAR(OrderDate) AS OrderYear, TotalDue, 
    MONTH(OrderDate) AS OrderMonth
    FROM Sales.SalesOrderHeader) AS MonthData
PIVOT ( 
    SUM(TotalDue)
    FOR OrderMonth IN ([1],[2],[3],[4],[5],[6])
    ) AS PivotData
ORDER BY OrderYear;
 
--2
SELECT OrderYear, ROUND(ISNULL([1],0),0) AS Jan, 
    ROUND(ISNULL([2],0),0) AS Feb, ROUND(ISNULL([3],0),0) AS Mar, 
    ROUND(ISNULL([4],0),0) AS Apr, ROUND(ISNULL([5],0),0) AS May, 
    ROUND(ISNULL([6],0),0) AS Jun
FROM (SELECT YEAR(OrderDate) AS OrderYear, TotalDue, 
    MONTH(OrderDate) AS OrderMonth
    FROM Sales.SalesOrderHeader) AS MonthData
PIVOT ( 
    SUM(TotalDue)
    FOR OrderMonth IN ([1],[2],[3],[4],[5],[6])
    ) AS PivotData
ORDER BY OrderYear;


--Listing 16-21. Pivoting the weather data
--1
SELECT dt AS [WeatherDate],[TX],[CA],[OK]
FROM  
  (  
    SELECT dt, plant,weather
    FROM #test 
  ) src 
PIVOT  
(  max(weather)  FOR  plant IN ( [TX], [CA], [OK])  
) AS pvt;


--Listing 16-22. Using UNPIVOT
--1
CREATE TABLE #pivot(OrderYear INT, Jan DECIMAL(10,2),
    Feb DECIMAL(10,2), Mar DECIMAL(10,2), 
        Apr DECIMAL(10,2), May DECIMAL(10,2),
        Jun DECIMAL(10,2));
 
--2
INSERT INTO #pivot(OrderYear, Jan, Feb, Mar, 
    Apr, May, Jun)
VALUES (2012, 4458337.00, 1649052.00, 350568.00, 1727690.00, 3299799.00, 1920507.00),
       (2007, 1968647.00, 3226056.00, 2297693.00, 2660724.00, 3866365.00, 2852210.00),
       (2008, 3359927.00, 4662656.00, 4722358.00, 4269365.00, 5813557.00, 6004156.00);
 
--3
SELECT * FROM #pivot;
 
--4
SELECT OrderYear, Amt, OrderMonth 
FROM (
    SELECT OrderYear, Jan, Feb, Mar, Apr, May, Jun 
        FROM #pivot) P 
UNPIVOT (
    Amt FOR OrderMonth IN 
                (Jan, Feb, Mar, Apr, May, Jun)
        ) AS unpvt;


--Listing 16-23 Some examples of querying temporal tables
USE WideWorldImporters;
GO
--1
SELECT CityID, CityName, LatestRecordedPopulation, ValidFrom, ValidTo
FROM Application.Cities
WHERE CityID = 13570;

--2 
SELECT CityID, CityName, LatestRecordedPopulation, ValidFrom, ValidTo
FROM Application.Cities
FOR SYSTEM_TIME AS OF '2013-01-02'
WHERE CityID = 13570;

--3
SELECT CityID, CityName, LatestRecordedPopulation, ValidFrom, ValidTo
FROM Application.Cities
FOR SYSTEM_TIME BETWEEN '2013-01-01' AND '2013-07-02'
WHERE CityID = 13570;


--Listing 16-24. Paging with T-SQL
USE AdventureWorks2019;
GO
--1
DECLARE @PageSize INT = 5;
DECLARE @PageNo INT = 1;
 
--2
WITH Products AS(
    SELECT ProductID, P.Name, Color, Size, 
        ROW_NUMBER() OVER(ORDER BY P.Name, Color, Size) AS RowNum
    FROM Production.Product AS P 
    JOIN Production.ProductSubcategory AS S 
        ON P.ProductSubcategoryID = S.ProductSubcategoryID
        JOIN Production.ProductCategory AS C 
            ON S.ProductCategoryID = C.ProductCategoryID 
        WHERE C.Name = 'Bikes'
) 
SELECT TOP(@PageSize) ProductID, Name, Color, Size 
FROM Products 
WHERE RowNum BETWEEN (@PageNo -1) * @PageSize + 1 
    AND @PageNo * @PageSize
ORDER BY Name, Color, Size;
 
--3
SELECT ProductID, P.Name, Color, Size
FROM Production.Product AS P 
JOIN Production.ProductSubcategory AS S 
    ON P.ProductSubcategoryID = S.ProductSubcategoryID
JOIN Production.ProductCategory AS C 
    ON S.ProductCategoryID = C.ProductCategoryID 
WHERE C.Name = 'Bikes'
ORDER BY P.Name, Color, Size 
    OFFSET @PageSize * (@PageNo -1) ROWS FETCH NEXT @PageSize ROWS ONLY;
 
