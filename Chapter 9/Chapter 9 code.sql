/*
Chapter 9 code
*/

--Listing 9-1. Using LIKE with the Percent Sign
--1
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE 'Sand%';
 
--2
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName NOT LIKE 'Sand%';
 
--3
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE '%Z%';
 
--4
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE 'Bec_';

--Listing 9-2. Using Square Brackets with LIKE
--1
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE 'Cho[i-k]';
 
--2
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE 'Cho[ijk]';
 
--3
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE 'Cho[^i]';

--Listing 9-3. Combining Wildcards in One Pattern
--1
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE 'Ber[rg]%';
 
--2
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE 'Ber[^r]%';
 
--3
SELECT DISTINCT LastName
FROM Person.Person
WHERE LastName LIKE 'Be%n_';


--Listing 9-4. Using PATINDEX
--1
SELECT DISTINCT LastName, PATINDEX('Ber[rg]%', LastName) AS Position
FROM Person.Person
WHERE PATINDEX('Ber[r,g]%', LastName) > 0;
 
--2
SELECT DISTINCT LastName, PATINDEX('%ing%',LastName) AS Position
FROM Person.Person
WHERE LastName LIKE '%ing%'


--Listing 9-5. Using SOME, ALL, and ANY
--1. Create and populate temp tables
CREATE TABLE #Table1 (Col1 INT);
CREATE TABLE #Table2 (Col1 INT);

INSERT INTO #Table1 (Col1) 
VALUES(1),(2),(3),(4),(8);

INSERT INTO #Table2 (Col1) 
VALUES(3),(4),(5),(6),(7);

--2. SOME
SELECT Col1 
FROM #Table1 
WHERE Col1 < SOME (SELECT Col1 FROM #Table2);

--3. ANY 
SELECT Col1 
FROM #Table1 
WHERE Col1 < ANY (SELECT Col1 FROM #Table2);

--4. ALL
SELECT Col1 
FROM #Table1 
WHERE Col1 < ALL (SELECT Col1 FROM #Table2);

--Listing 9-6. WHERE Clauses with Three Predicates
--1
SELECT BusinessEntityID,FirstName,MiddleName,LastName
FROM Person.Person
WHERE FirstName = 'Ken' AND LastName = 'Myer'
    OR LastName = 'Meyer';
 
--2
SELECT BusinessEntityID,FirstName,MiddleName,LastName
FROM Person.Person
WHERE LastName = 'Myer' OR LastName = 'Meyer'
    AND FirstName = 'Ken';
 
--3
SELECT BusinessEntityID,FirstName,MiddleName,LastName
FROM Person.Person
WHERE LastName = 'Meyer'
    AND FirstName = 'Ken' OR LastName = 'Myer';
 
--4
SELECT BusinessEntityID,FirstName,MiddleName,LastName
FROM Person.Person
WHERE FirstName = 'Ken' AND (LastName = 'Myer'
    OR LastName = 'Meyer');
 
 --Listing 9-7. Using NOT with Parentheses
--1
SELECT BusinessEntityID,FirstName,MiddleName,LastName
FROM Person.Person
WHERE FirstName='Ken' AND LastName <> 'Myer'
    AND LastName <> 'Meyer';
 
--2
SELECT BusinessEntityID,FirstName,MiddleName,LastName
FROM Person.Person
WHERE FirstName='Ken'
    AND NOT (LastName = 'Myer' OR LastName = 'Meyer');

----Listing 9-8. Using CONTAINS
--1
SELECT FileName
FROM Production.Document
WHERE CONTAINS(Document,'important');
 
--2
SELECT FileName
FROM Production.Document
WHERE CONTAINS(Document,' "service guidelines" ')
    AND DocumentLevel = 2;

--Listing 9-9. Multiple Terms in CONTAINS
--1
SELECT FileName, DocumentSummary
FROM Production.Document
WHERE CONTAINS(DocumentSummary,'bicycle AND reflectors');
 
--2
SELECT FileName, DocumentSummary
FROM Production.Document
WHERE CONTAINS(DocumentSummary,'bicycle AND NOT reflectors');
 
--3
SELECT FileName, DocumentSummary
FROM Production.Document
WHERE CONTAINS(DocumentSummary,'maintain NEAR bicycle AND NOT reflectors');

--Listing 9-10. Using Multiple Columns
--1
SELECT FileName, DocumentSummary
FROM Production.Document
WHERE CONTAINS((DocumentSummary,Document),'maintain');
 
--2
SELECT FileName, DocumentSummary
FROM Production.Document
WHERE CONTAINS((DocumentSummary),'maintain')
        OR CONTAINS((Document),'maintain')
 
--3
SELECT FileName, DocumentSummary
FROM Production.Document
WHERE CONTAINS(*,'maintain');

--Listing 9-11. Using FREETEXT
--1
SELECT FileName, DocumentSummary
FROM Production.Document
WHERE FREETEXT((DocumentSummary),'provides');
 
--2
SELECT FileName, DocumentSummary
FROM Production.Document
WHERE DocumentSummary LIKE '%provides%';


--Listing 9-12. Using FREETEXTTABLE
--1
SELECT * 
FROM FREETEXTTABLE(Production.ProductReview,Comments,'bike');

--2
SELECT P.ProductID, P.Name, PR.Comments
FROM Production.ProductReview AS PR 
JOIN Production.Product AS P ON PR.ProductID = P.ProductID 
JOIN FREETEXTTABLE(Production.ProductReview,Comments,'bike') AS C
	ON PR.ProductReviewID = C.[Key];


--Listing 9-13. Comparing LIKE with CHARINDEX
--1
SET STATISTICS IO ON;
GO
SELECT Name
FROM Production.Product
WHERE CHARINDEX('Bear',Name) = 1;
 
--2
SELECT Name
FROM Production.Product
WHERE Name LIKE 'Bear%';
 
--3
SELECT Name, Color
FROM Production.Product
WHERE CHARINDEX('B',Color) = 1;
 
--4
SELECT Name, Color
FROM Production.Product
WHERE Color LIKE 'B%';
