/*
Chapter 3 code
*/

--Listing 3-1. Statements Returning Literal Values
SELECT 1;
SELECT 'ABC';

--Listing 3-2. Writing a Query with a FROM Clause
USE AdventureWorks2019;
GO
SELECT BusinessEntityID, JobTitle
FROM HumanResources.Employee;

--Listing 3-3. A Scripted SELECT Statement
SELECT TOP (1000) [BusinessEntityID]
      ,[NationalIDNumber]
      ,[LoginID]
      ,[OrganizationNode]
      ,[OrganizationLevel]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [AdventureWorks2019].[HumanResources].[Employee]  

--Listing 3-4. Mixing Literal Values and Column Names
SELECT 'A Literal Value' AS "Literal Value",
    BusinessEntityID AS EmployeeID,
    LoginID JobTitle
FROM HumanResources.Employee;

--Listing 3-5. How to Use the WHERE Clause
--1
SELECT CustomerID, SalesOrderID
FROM Sales.SalesOrderHeader
WHERE CustomerID = 11000;
 
--2
SELECT CustomerID, SalesOrderID
FROM Sales.SalesOrderHeader
WHERE SalesOrderID = 43793;
 
--3
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate = '2011-07-02';
 
--4
SELECT BusinessEntityID, LoginID, JobTitle
FROM HumanResources.Employee
WHERE JobTitle = 'Chief Executive Officer';

--Listing 3-6. Using Operators with the WHERE Clause
--Using a DateTime column
--1
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate > '2011-07-05';
 
--2
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate < '2011-07-05';
 
--3
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '2011-07-05';
 
--4
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate <> '2011-07-05';
 
--5
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate != '2011-07-05';
 
--Using a number column
--6
SELECT SalesOrderID, SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE OrderQty > 10;
 
--7
SELECT SalesOrderID, SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE OrderQty <= 10;
 
--8
SELECT SalesOrderID, SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE OrderQty <> 10;
 
--9
SELECT SalesOrderID, SalesOrderDetailID, OrderQty
FROM Sales.SalesOrderDetail
WHERE OrderQty != 10;
 
--Using a string column
--10
SELECT BusinessEntityID, FirstName
FROM Person.Person
WHERE FirstName <> 'Catherine';
 
--11
SELECT BusinessEntityID, FirstName
FROM Person.Person
WHERE FirstName != 'Catherine';
 
--12
SELECT BusinessEntityID, FirstName
FROM Person.Person
WHERE FirstName > 'M';
 
--13
SELECT BusinessEntityID, FirstName
FROM Person.Person
WHERE FirstName !> 'M';

--Listing 3-7. Using BETWEEN
--1
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate BETWEEN '2011-07-02' AND '2011-07-04';
 
--2
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 25000 AND 25005;
 
--3
SELECT BusinessEntityID, JobTitle
FROM HumanResources.Employee
WHERE JobTitle BETWEEN 'C' and 'E';
 
--4 An illogical BETWEEN expression
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE CustomerID BETWEEN 25005 AND 25000;



--Listing 3-8. Using NOT BETWEEN
--1
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE OrderDate NOT BETWEEN '2011-07-02' AND '2011-07-04';
 
--2
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE CustomerID NOT BETWEEN 25000 AND 25005;
 
--3
SELECT BusinessEntityID, JobTitle
FROM HumanResources.Employee
WHERE JobTitle NOT BETWEEN 'C' and 'E';
 
--4 An illogical BETWEEN expression
SELECT CustomerID, SalesOrderID, OrderDate
FROM Sales.SalesOrderHeader
WHERE CustomerID NOT BETWEEN 25005 AND 25000;
 

 --Listing 3-9. Table Setup for Date/Time Example
CREATE TABLE #DateTimeExample(
    ID INT NOT NULL IDENTITY PRIMARY KEY,
    MyDate DATETIME2(0) NOT NULL,
    MyValue VARCHAR(25) NOT NULL
);
GO
INSERT INTO #DateTimeExample
    (MyDate,MyValue)
VALUES ('2020-01-02 10:30','Bike'),
    ('2020-01-03 13:00','Trike'),
    ('2020-01-03 13:10','Bell'),
    ('2020-01-03 17:35','Seat');

--Listing 3-10. Filtering on Date and Time Columns
--1
SELECT ID, MyDate, MyValue
FROM #DateTimeExample
WHERE MyDate = '2020-01-03';
 
--2
SELECT ID, MyDate, MyValue
FROM #DateTimeExample
WHERE MyDate BETWEEN '2020-01-03 00:00:00' AND '2020-01-03 23:59:59';


--Listing 3-11. How to Use AND and OR
--1
SELECT BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE FirstName = 'Ken' AND LastName = 'Myer';
 
--2
SELECT BusinessEntityID, FirstName, MiddleName, LastName
FROM Person.Person
WHERE LastName = 'Myer' OR LastName = 'Meyer';
 
--3
DROP TABLE IF EXISTS #DateTimeExample;

CREATE TABLE #DateTimeExample(
    ID INT NOT NULL IDENTITY PRIMARY KEY,
    MyDate DATETIME2(0) NOT NULL,
    MyValue VARCHAR(25) NOT NULL
);
GO
INSERT #DateTimeExample (MyDate, MyValue)
VALUES ('2020-01-01 10:30','Bike'),
    ('2020-01-01 11:30','Bike'),
    ('2020-01-02 13:00','Trike'),
    ('2020-01-03 13:10','Bell'),
    ('2020-01-03 17:35','Seat'),
    ('2020-01-04 00:00','Bike');
 
--4
SELECT ID, MyDate, MyValue
FROM #DateTimeExample
WHERE MyDate >= '2020-01-02' AND MyDate < '2020-01-04';

--Listing 3-12. Using the IN Operator
--1
SELECT BusinessEntityID,FirstName,MiddleName,LastName
FROM Person.Person
WHERE FirstName = 'Ken' AND
    LastName IN ('Myer','Meyer');
 
--2
SELECT TerritoryID, Name
FROM Sales.SalesTerritory
WHERE TerritoryID IN (2,2,1,4,5);
 
--3
SELECT TerritoryID, Name
FROM Sales.SalesTerritory
WHERE TerritoryID NOT IN (2,1,4,5);


--Listing 3-13. An Example Illustrating NULL
--1 Returns 19,972 rows
SELECT MiddleName
FROM Person.Person;
 
--2 Returns 291 rows
SELECT MiddleName
FROM Person.Person
WHERE MiddleName = 'B';
 
--3 Returns 11,182 but 19,681 were expected
SELECT MiddleName
FROM Person.Person
WHERE MiddleName != 'B';
 
--4 Returns 19,681
SELECT MiddleName
FROM Person.Person
WHERE MiddleName IS NULL
    OR MiddleName !='B';
 

 --Listing 3-14. How to Use ORDER BY
--1
SELECT ProductID, LocationID
FROM Production.ProductInventory
ORDER BY LocationID;
 
--2
SELECT ProductID, LocationID
FROM Production.ProductInventory
ORDER BY ProductID, LocationID DESC;


SELECT BusinessEntityID, 1 as LastName, LastName, FirstName, MiddleName
FROM Person.Person
ORDER BY LastName DESC, FirstName DESC, MiddleName DESC;


--Listing 3-15. Learning How to View Execution Plans
--1
SELECT LastName, FirstName
FROM Person.Person
WHERE LastName = 'Smith';
 
--2
SELECT LastName, FirstName
FROM Person.Person
WHERE FirstName = 'Ken';
 
--3
SELECT ModifiedDate
FROM Person.Person
WHERE ModifiedDate BETWEEN '2011-01-01' and '2011-01-31';
