/*
Chapter 14 code
*/

--Listing 14-1. Using VARCHAR(MAX)
--1
CREATE TABLE #maxExample (maxCol VARCHAR(MAX),
    line INT NOT NULL IDENTITY PRIMARY KEY);
GO
 
--2
INSERT INTO #maxExample(maxCol)
VALUES ('This is a varchar(max)');
 
--3
INSERT INTO #maxExample(maxCol)
VALUES (REPLICATE('aaaaaaaaaa',9000));
 
--4
INSERT INTO #maxExample(maxCol)
VALUES (REPLICATE(CONVERT(VARCHAR(MAX),'bbbbbbbbbb'),9000));
 
--5
SELECT LEFT(MaxCol,10) AS Left10,LEN(MaxCol) AS varLen
FROM #maxExample;
 
GO
DROP TABLE #maxExample;
 
--Listing 14-2. Using VARBINARY(MAX) Data
--1
CREATE TABLE #BinaryTest (DataDescription VARCHAR(50),
    BinaryData VARBINARY(MAX));
--2
INSERT INTO #BinaryTest (DataDescription,BinaryData)
VALUES ('Test 1', CONVERT(VARBINARY(MAX),'this is the test 1 row')),
    ('Test 2', CONVERT(VARBINARY(MAX),'this is the test 2 row'));
 
--3
SELECT DataDescription, BinaryData, CONVERT(VARCHAR(MAX), BinaryData)
FROM #BinaryTest;
 
--4
DROP TABLE #BinaryTest;
 
EXEC sp_configure filestream_access_level, 2  
RECONFIGURE

--Listing 14-3. Working with a FILESTREAM Column
--1
DROP TABLE IF EXISTS dbo.NotepadFiles;
 
--2
CREATE table dbo.NotepadFiles(Name VARCHAR(25),
    FileData VARBINARY(MAX) FILESTREAM,
    RowID UNIQUEIDENTIFIER ROWGUIDCOL
        NOT NULL UNIQUE DEFAULT NEWSEQUENTIALID());
 
--3
INSERT INTO dbo.NotepadFiles(Name,FileData)
VALUES ('test1', CONVERT(VARBINARY(MAX),'This is a test')),
    ('test2', CONVERT(VARBINARY(MAX),'This is the second test'));
 
--4
SELECT Name,FileData,CONVERT(VARCHAR(MAX),FileData) TheData, RowID
FROM dbo.NotepadFiles;
 

DROP TABLE NotepadFiles;
CHECKPOINT;

--Listing 14-4. Creating a FileTable
USE MASTER;
GO
ALTER DATABASE AdventureWorks2019
    SET FILESTREAM ( NON_TRANSACTED_ACCESS = FULL, DIRECTORY_NAME = 'FileTableDocuments');
GO
 
USE AdventureWorks2019;
GO
 
CREATE TABLE MyDocuments AS FileTable
    WITH (
          FileTable_Directory = 'Misc Documents',
          FileTable_Collate_Filename = SQL_Latin1_General_CP1_CI_AS
         );
GO
 
INSERT INTO [dbo].[MyDocuments]
           ([file_stream]
           ,[name])
     VALUES
           (cast('hello' as varbinary(max)),'MyNewFile.txt');
GO

--Listing 14-5. Using DATE and TIME
USE tempdb;
 
--1
DROP TABLE IF EXISTS dbo.DateDemo;
 
--2
CREATE TABLE dbo.DateDemo(JustTheDate DATE, JustTheTime TIME(1),
    NewDateTime2 DATETIME2(3), UTCDate DATETIME2); 
 
--3
INSERT INTO dbo.DateDemo (JustTheDate, JustTheTime, NewDateTime2,
    UTCDate)
VALUES (SYSDATETIME(), SYSDATETIME(), SYSDATETIME(), SYSUTCDATETIME());
 
--4
SELECT JustTheDate, JustTheTime, NewDateTime2, UTCDate
FROM dbo.DateDemo;


--Listing 14-6. Using the DATETIMEOFFSET Data Type
USE tempdb;
 
--1
DROP TABLE IF EXISTS dbo.OffsetDemo;
 
--2
CREATE TABLE dbo.OffsetDemo(Date1 DATETIMEOFFSET); 
 
--3
INSERT INTO dbo.OffsetDemo(Date1)
VALUES (SYSDATETIMEOFFSET()),
    (SWITCHOFFSET(SYSDATETIMEOFFSET(),'+00:00')),
    (TODATETIMEOFFSET(SYSDATETIME(),'+05:00'));     
    
--4
SELECT Date1
FROM dbo.OffsetDemo;
 
--Listing 14-7. Viewing the OrganizationalNode
USE AdventureWorks2019;
GO
SELECT BusinessEntityID,
    SPACE((OrganizationLevel) * 3) + JobTitle AS Title,
    OrganizationNode, OrganizationLevel,
    OrganizationNode.ToString() AS Readable
FROM HumanResources.Employee
ORDER BY Readable;

--Listing 14-8. Creating a Hierarchy with HIERARCHYID
Use tempdb; 
 
--1
DROP TABLE IF EXISTS SportsOrg;
 
--2
CREATE TABLE SportsOrg
    (DivNode HIERARCHYID NOT NULL PRIMARY KEY CLUSTERED,
    DivLevel AS DivNode.GetLevel(), --Calculated column
    DivisionID INT NOT NULL,
    Name VARCHAR(30) NOT NULL); 
 
--3
INSERT INTO SportsOrg(DivNode,DivisionID,Name)
VALUES(HIERARCHYID::GetRoot(),1,'State'); 
 
--4
DECLARE @ParentNode HIERARCHYID, @LastChildNode HIERARCHYID;
 
--5
SELECT @ParentNode = DivNode
FROM SportsOrg
WHERE DivisionID = 1;
 
--6
SELECT @LastChildNode = max(DivNode)
FROM SportsOrg
WHERE DivNode.GetAncestor(1) = @ParentNode;
 
--7
INSERT INTO SportsOrg(DivNode,DivisionID,Name)
VALUES (@ParentNode.GetDescendant(@LastChildNode,NULL),
2,'Madison County');
 
--8
SELECT DivisionID,DivLevel,DivNode.ToString() AS Node,Name
FROM SportsOrg;
 
--Listing 14-9. Using a Stored Procedure to Insert New Nodes
USE tempdb;
GO
 
--1
DROP PROC IF EXISTS dbo.usp_AddDivision;
DROP TABLE IF EXISTS dbo.SportsOrg;
GO
 
--2
CREATE TABLE SportsOrg
    (DivNode HierarchyID NOT NULL PRIMARY KEY CLUSTERED,
    DivLevel AS DivNode.GetLevel(), --Calculated column
    DivisionID INT NOT NULL,
    Name VARCHAR(30) NOT NULL);
GO
 
--3
INSERT INTO SportsOrg(DivNode,DivisionID,Name)
VALUES(HIERARCHYID::GetRoot(),1,'State');
GO
 
--4
CREATE PROC usp_AddDivision @DivisionID INT,
    @Name VARCHAR(50),@ParentID INT AS
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
 
    DECLARE @ParentNode HierarchyID, @LastChildNode HierarchyID;
  
    --Grab the parent node
    SELECT @ParentNode = DivNode
    FROM SportsOrg
    WHERE DivisionID = @ParentID;
     
    BEGIN TRANSACTION
        --Find the last node added to the parent
        SELECT @LastChildNode = max(DivNode)
        FROM SportsOrg
        WHERE DivNode.GetAncestor(1) = @ParentNode;
        --Insert the new node using the GetDescendant function
        INSERT INTO SportsOrg(DivNode,DivisionID,Name)
        VALUES (@ParentNode.GetDescendant(@LastChildNode,NULL),
            @DivisionID,@Name);
    COMMIT TRANSACTION;
GO
 
--5
EXEC usp_AddDivision 2,'Madison County',1;
EXEC usp_AddDivision 3,'Macoupin County',1;
EXEC usp_AddDivision 4,'Green County',1;
EXEC usp_AddDivision 5,'Edwardsville',2;
EXEC usp_AddDivision 6,'Granite City',2;
EXEC usp_AddDivision 7,'Softball',5;
EXEC usp_AddDivision 8,'Baseball',5;
EXEC usp_AddDivision 9,'Basketball',5;
EXEC usp_AddDivision 10,'Softball',6;
EXEC usp_AddDivision 11,'Baseball',6;
EXEC usp_AddDivision 12,'Basketball',6;
EXEC usp_AddDivision 13,'Ages 10 - 12',7;
EXEC usp_AddDivision 14,'Ages 13 - 17',7;
EXEC usp_AddDivision 15,'Adult',7;
EXEC usp_AddDivision 16,'Preschool',8;
EXEC usp_AddDivision 17,'Grade School League',8;
EXEC usp_AddDivision 18,'High School League',8;
 
--6
SELECT DivNode.ToString() AS Node,
    DivisionID, SPACE(DivLevel * 3) + Name AS Name
FROM SportsOrg
ORDER BY DivNode;


--Listing 14-10. Using the GEOMETRY Data Type
USE tempdb;
GO
 
--1
DROP TABLE IF EXISTS dbo.GeometryData;
 
--2
CREATE TABLE dbo.GeometryData (
    Point1 GEOMETRY, Point2 GEOMETRY,
    Line1 GEOMETRY, Line2 GEOMETRY,
    Polygon1 GEOMETRY, Polygon2 GEOMETRY);
 
--3
INSERT INTO dbo.GeometryData (Point1, Point2, Line1, Line2, Polygon1, Polygon2)
VALUES (
    GEOMETRY::Parse('Point(1 4)'),
    GEOMETRY::Parse('Point(2 5)'),
    GEOMETRY::Parse('LineString(1 4, 2 5)'),
    GEOMETRY::Parse('LineString(4 1, 5 2, 7 3, 10 6)'),
    GEOMETRY::Parse('Polygon((1 4, 2 5, 5 2, 0 4, 1 4))'),
    GEOMETRY::Parse('Polygon((1 4, 2 7, 7 2, 0 4, 1 4))'));
 
--4
SELECT Point1.ToString() AS Point1, Point2.ToString() AS Point2,
    Line1.ToString() AS Line1, Line2.ToString() AS Line2,
    Polygon1.ToString() AS Polygon1, Polygon2.ToString() AS Polygon2
FROM dbo.GeometryData;
 
--5
SELECT Point1.STX AS Point1X, Point1.STY AS Point1Y,
    Line1.STIntersects(Polygon1) AS Line1Poly1Intersects,
    Line1.STLength() AS Line1Len,
    Line1.STStartPoint().ToString() AS Line1Start,
    Line2.STNumPoints() AS Line2PtCt,
    Polygon1.STArea() AS Poly1Area,
    Polygon1.STIntersects(Polygon2) AS Poly1Poly2Intersects
FROM dbo.GeometryData;


--Listing 14-11. Using the GEOGRAPHY Data Type
USE AdventureWorks2019;
GO
 
--1
DECLARE @OneAddress GEOGRAPHY;
 
--2
SELECT @OneAddress = SpatialLocation
FROM Person.Address
WHERE AddressID = 91;
 
--3
SELECT AddressID,PostalCode, SpatialLocation.ToString(),
    @OneAddress.STDistance(SpatialLocation) AS DiffInMeters
FROM Person.Address
WHERE AddressID IN (1,91, 831,11419);

--Listing 14-12. Viewing Spatial Results
--1
DECLARE @Area GEOMETRY;
 
--2
SET @Area = geometry::Parse('Polygon((1 4, 2 5, 5 2, 0 4, 1 4))');
 
--3
SELECT @Area AS Area;


--Listing 14-13. Example of Curved Lines Using CIRCULARSTRING and COMPOUNDCURVE
DECLARE @g geometry;
 
SET @g = geometry:: STGeomFromText('CIRCULARSTRING(1 2, 2 1, 4 3)', 0);
SELECT @g.ToString();
 
SET @g = geometry::STGeomFromText('
COMPOUNDCURVE(
CIRCULARSTRING(1 2, 2 1, 4 3),
CIRCULARSTRING(4 3, 3 4, 1 2))', 0);
SELECT @g AS Area;

--Listing 14-14. Example of Mixing Straight and Curved Lines Using COMPOUNDCURVE
DECLARE @g geometry = 'COMPOUNDCURVE(CIRCULARSTRING(2 0, 0 2, -2 0), (-2 0, 2 0))';
SELECT @g;


--Listing 14-15. Using Sparse Columns
USE tempdb;
GO
 
--1
DROP TABLE IF EXISTS dbo.SparseData;
GO
 
--2
CREATE TABLE dbo.SparseData
    (ID INT NOT NULL PRIMARY KEY,
    sc1 INT SPARSE NULL,
    sc2 INT SPARSE NULL,
    sc3 INT SPARSE NULL,
    cs XML COLUMN_SET FOR ALL_SPARSE_COLUMNS);
GO
 
--3
INSERT INTO dbo.SparseData(ID,sc1,sc2,sc3)
VALUES  (1,1,NULL,3),(2,NULL,1,1),(3,NULL,NULL,1);
 
--4
INSERT INTO SparseData(ID,cs)
SELECT 4,'<sc2>5</sc2>';
 
--5
SELECT * FROM dbo.SparseData;
 
--6
SELECT ID, sc1, sc2, sc3, cs FROM SparseData;


--Listing 14-16. Create node tables
USE tempdb;
GO
--1
CREATE TABLE dbo.People(
	PeopleID INT IDENTITY PRIMARY KEY,
	Name NVARCHAR(25) NOT NULL
) AS NODE;

--2
CREATE TABLE dbo.Toppings(
	ToppingID INT IDENTITY PRIMARY KEY,
	ToppingName NVARCHAR(25) NOT NULL
) AS NODE;

--3
INSERT INTO People(Name) 
VALUES ('Thomas'),('Gwen'),
	('Elliott'),('Wyatt'),('Nate'),
	('Elle'),('Nala'),('Yadi');

--4
INSERT INTO Toppings(ToppingName)
VALUES ('Extra cheese'),('Peppeoni'),
	('Sausage'),('Mushroom'),('Onion'),
	('Pineapple'),('Ham'),('Olives'),
	('Peppers');

--5
SELECT * FROM People;
--6
SELECT * FROM Toppings;

--Listing 14-17. Create and populate edge tables
--1
CREATE TABLE Likes AS EDGE;
--2
INSERT INTO Likes VALUES
	(
	(SELECT $node_id FROM People WHERE PeopleID = 1),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 1)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 2),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 3)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 6),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 6)
	),
		(
	(SELECT $node_id FROM People WHERE PeopleID = 6),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 7)
	),
		(
	(SELECT $node_id FROM People WHERE PeopleID = 5),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 2)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 8),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 4)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 8),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 8)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 4),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 3)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 4),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 5)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 3),
	(SELECT $node_id FROM Toppings WHERE ToppingID = 1)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 4),
	(SELECT $node_id FROM Toppings WHERE ToppingID =9)
	);
--3
SELECT P.Name, T.ToppingName
FROM People AS P JOIN Likes AS LK 
ON p.$node_id = lk.$from_id
JOIN Toppings AS T 
ON T.$node_id = lk.$to_id
ORDER BY P.Name;


--Listing 14-18. A hierarchy in a graph database
--1
CREATE TABLE WorksFor AS EDGE;
--2
INSERT INTO WorksFor VALUES 
	(
	(SELECT $node_id FROM People WHERE PeopleID = 2),
	(SELECT $node_id FROM People WHERE PeopleID = 1)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 4),
	(SELECT $node_id FROM People WHERE PeopleID = 2)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 3),
	(SELECT $node_id FROM People WHERE PeopleID = 1)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 7),
	(SELECT $node_id FROM People WHERE PeopleID = 4)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 5),
	(SELECT $node_id FROM People WHERE PeopleID = 3)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 6),
	(SELECT $node_id FROM People WHERE PeopleID = 5)
	),
	(
	(SELECT $node_id FROM People WHERE PeopleID = 8),
	(SELECT $node_id FROM People WHERE PeopleID = 5)
	);
	
--3
SELECT emp1.Name Employee, emp2.Name Manager
FROM People emp1, WorksFor, People emp2
WHERE MATCH(emp1-(WorksFor)->emp2)
ORDER BY Employee, Manager;


--Listing 14-19. Implicit conversions
USE AdventureWorks2019;
GO
 
--1
CREATE TABLE #Test(ID VARCHAR(20) PRIMARY KEY, LastName VARCHAR(25), FirstName VARCHAR(25));
CREATE INDEX ndxTest ON #Test(LastName);
 
INSERT INTO #Test(ID, LastName, FirstName)
SELECT BusinessEntityID, LastName, FirstName
FROM Person.Person;
 
--2
SELECT ID
FROM #Test
WHERE ID = 285;
 
--3
SELECT ID
FROM #Test
WHERE ID = '285';


