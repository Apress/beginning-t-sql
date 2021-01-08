/*
Chapter 15 code
*/

--Listing 15-1. OPENXML Query
--1
DECLARE @hdoc int;
DECLARE @doc varchar(1000) = N'
<Products>
<Product ProductID="32565451" ProductName="Bicycle Pump">
   <Order ProductID="32565451" SalesID="5" OrderDate="2011-07-04T00:00:00">
      <OrderDetail OrderID="10248" CustomerID="22" Quantity="12"/>
      <OrderDetail OrderID="10248" CustomerID="11" Quantity="10"/>
   </Order>
</Product>
<Product ProductID="57841259" ProductName="Bicycle Seat">
   <Order ProductID="57841259" SalesID="3" OrderDate="2011-015-16T00:00:00">
      <OrderDetail OrderID="54127" CustomerID="72" Quantity="3"/>
   </Order>
</Product>
</Products>';
 
--2
EXEC sp_xml_preparedocument @hdoc OUTPUT, @doc;
 
--3
SELECT *
FROM OPENXML(@hdoc, N'/Products/Product');
 
--4
EXEC sp_xml_removedocument @hdoc; 

--Listing 15-2. OPENXML Query Using the WITH Clause
--1
DECLARE @hdoc int;
DECLARE @doc varchar(1000) = N'
<Products>
<Product ProductID="32565451" ProductName="Bicycle Pump">
   <Order ProductID="32565451" SalesID="5" OrderDate="2011-07-04T00:00:00">
      <OrderDetail OrderID="10248" CustomerID="22" Quantity="12"/>
      <OrderDetail OrderID="10248" CustomerID="11" Quantity="10"/>
   </Order>
</Product>
<Product ProductID="57841259" ProductName="Bicycle Seat">
   <Order ProductID="57841259" SalesID="3" OrderDate="2011-015-16T00:00:00">
      <OrderDetail OrderID="54127" CustomerID="72" Quantity="3"/>
   </Order>
</Product>
</Products>';
 
--2
EXEC sp_xml_preparedocument @hdoc OUTPUT, @doc;
 
--3
SELECT *
FROM OPENXML(@hdoc, N'/Products/Product/Order/OrderDetail')
WITH (CustomerID int '@CustomerID',
     ProductID int '../@ProductID',
     ProductName varchar(30) '../../@ProductName',
     OrderID int '@OrderID',
     Orderdate varchar(30) '../@OrderDate');
 
--4
EXEC sp_xml_removedocument @hdoc; 

--Listing 15-3. Generating XML Using the FOR XML RAW Command
SELECT TOP(5) FirstName
FROM Person.Person
FOR XML RAW;
 
--Listing 15-4. Creating Element-Centric XML Using XML RAW
SELECT TOP(5) FirstName, LastName
FROM Person.Person
FOR XML RAW ('NAME'), ELEMENTS;

--Listing 15-5. Using AUTO Mode
SELECT TOP(5) CustomerID, LastName, FirstName, MiddleName
FROM Person.Person AS Person
INNER JOIN Sales.Customer AS Customer ON Person.BusinessEntityID = Customer.PersonID
ORDER BY CustomerID
FOR XML AUTO;

--Listing 15-6. Using AUTO Mode with the ELEMENTS Option
SELECT TOP(3) CustomerID, LastName, FirstName, MiddleName
FROM Person.Person AS Person
INNER JOIN Sales.Customer AS Customer ON Person.BusinessEntityID = Customer.PersonID
ORDER BY CustomerID
FOR XML AUTO, ELEMENTS;

--Listing 15-7. Using XML FOR EXPLICIT
SELECT 1 AS Tag,
       NULL       AS Parent,
       CustomerID AS [Customer!1!CustomerID],
       NULL       AS [Name!2!FName],
       NULL       AS [Name!2!LName]
FROM Sales.Customer AS C
INNER JOIN Person.Person AS P
ON  P.BusinessEntityID = C.PersonID
UNION ALL
SELECT 2 AS Tag,
       1 AS Parent,
       CustomerID,
       FirstName,
       LastName
FROM Person.Person P
INNER JOIN Sales.Customer AS C
ON P.BusinessEntityID = C.PersonID
ORDER BY [Customer!1!CustomerID], [Name!2!FName]
FOR XML EXPLICIT;

--Listing 15-8. Simple FOR XML PATH Query
SELECT TOP(3) p.FirstName,
       p.LastName,
       s.Bonus,
       s.SalesYTD
FROM Person.Person p
JOIN Sales.SalesPerson s
ON p.BusinessEntityID = s.BusinessEntityID
ORDER BY s.SalesYTD DESC
FOR XML PATH;
 
 --Listing 15-9. Defining XML Hierarchy Using PATH Mode
SELECT TOP(3) p.FirstName "@FirstName",
       p.LastName "@LastName",
           s.Bonus "Sales/Bonus",
           s.SalesYTD "Sales/YTD"
FROM Person.Person p
JOIN Sales.SalesPerson s
ON p.BusinessEntityID = s.BusinessEntityID
ORDER BY s.SalesYTD DESC
FOR XML PATH;

--Listing 15-10. Simple FOR XML PATH Query with NAME Option
SELECT TOP(5) ProductID "@ProductID",
       Name "Product/ProductName",
       Color "Product/Color"
FROM Production.Product
ORDER BY ProductID
FOR XML PATH ('Product');

--Listing 15-11. Built-in XML Data Type
USE tempdb;
GO
 
CREATE TABLE dbo.ProductList (ProductInfo XML);

--Listing 15-12. Using XML as a Data Type
--1
USE AdventureWorks2019;
GO
CREATE TABLE #CustomerList (CustomerInfo XML);
 
--2
DECLARE @XMLInfo XML;
 
--3
SET @XMLInfo = (SELECT TOP(5) CustomerID, LastName, FirstName, MiddleName
FROM Person.Person AS p
INNER JOIN Sales.Customer AS c ON p.BusinessEntityID = c.PersonID
FOR XML PATH);
 
--4
INSERT INTO #CustomerList(CustomerInfo)
VALUES(@XMLInfo);
 
--5
SELECT CustomerInfo FROM #CustomerList;
DROP TABLE #CustomerList;
 

--Listing 15-13 Create a Temp Table with an XML Column
--1
CREATE TABLE #Bikes(ProductID INT, ProductDescription XML);
 
--2
INSERT INTO #Bikes(ProductID, ProductDescription)
SELECT ProductID,
        (SELECT ProductID, Product.Name, Color, Size, ListPrice, SC.Name AS BikeSubCategory
        FROM Production.Product AS Product
        JOIN Production.ProductSubcategory SC
                ON Product.ProductSubcategoryID = SC.ProductSubcategoryID
        JOIN Production.ProductCategory C
                ON SC.ProductCategoryID = C.ProductCategoryID
        WHERE Product.ProductID = Prod.ProductID
        FOR XML RAW('Product'), ELEMENTS) AS ProdXML
FROM  Production.Product AS Prod
        JOIN Production.ProductSubcategory SC
                ON Prod.ProductSubcategoryID = SC.ProductSubcategoryID
        JOIN Production.ProductCategory C
                ON SC.ProductCategoryID = C.ProductCategoryID
WHERE C.Name = 'Bikes';
 
--3
SELECT *
FROM #Bikes;

--Listing 15-14. Using the QUERY method
SELECT ProductID,
    ProductDescription.query('Product/ListPrice') AS ListPrice
FROM #Bikes; 

--Listing 15-15. Using the VALUE Method
SELECT ProductID,
    ProductDescription.value('(/Product/ListPrice)[1]', 'MONEY') AS ListPrice
FROM #Bikes;

--Listing 15-16. Using the  VALUE Method with an Attribute
DECLARE @test XML = '
<root>
<Product ProductID="123" Name="Road Bike"/>
<Product ProductID="124" Name="Mountain Bike"/>
</root>';
 
SELECT @test.value('(/root/Product/@Name)[2]','NVARCHAR(25)');


--Listing 15-17. Using the EXIST method
SELECT ProductID,
    ProductDescription.value('(/Product/ListPrice)[1]', 'MONEY') AS ListPrice
FROM #Bikes
WHERE ProductDescription.exist('/Product/ListPrice[text()[1] lt 3000]') = 1;


--Listing 15-18. Using EXIST with Dates
--1
DECLARE @test1 XML = '
<root>
    <Product ProductID="123" LastOrderDate="2014-06-02"/>
</root>';
 
--2
DECLARE @test2 XML = '
<root>
    <Product>
            <ProductID>123</ProductID>
                <LastOrderDate>2014-06-02</LastOrderDate>
        </Product>
</root>';
 
--3
SELECT @test1.exist('/root/Product[(@LastOrderDate cast as xs:date?)
    eq xs:date("2014-06-02")]'),
@test2.exist('/root/Product/LastOrderDate[(text()[1] cast as xs:date?)
    eq xs:date("2014-06-02")]');

--Listing 15-19. Using the MODIFY method
--1
DECLARE @x xml =
'<Product ProductID = "521487">
  <ProductType>Paper Towels</ProductType>
  <Price>15</Price>
  <Vendor>Johnson Paper</Vendor>
  <VendorID>47</VendorID>
  <QuantityOnHand>500</QuantityOnHand>
</Product>';
 
--2
SELECT @x;
 
--3
/* inserting data into xml with the modify method */
SET @x.modify('
insert <WarehouseID>77</WarehouseID>
into (/Product)[1]');
 
--4
SELECT @x;
  
--5
/* updating xml with the modify method */
SET @x.modify('
replace value of (/Product/QuantityOnHand[1]/text())[1]
with "250"');
 
--6
SELECT @x;
 
--7
/* deleting xml with the modify method */
SET @x.modify('
delete (/Product/Price)[1]');
 
--8
SELECT @x;
 
--Listing 15-20. Using the NODES method
--1
DECLARE @XML XML = '
<Product>
        <ProductID>749</ProductID>
        <ProductID>749</ProductID>
        <ProductID>750</ProductID>
        <ProductID>751</ProductID>
        <ProductID>752</ProductID>
        <ProductID>753</ProductID>
        <ProductID>754</ProductID>
        <ProductID>755</ProductID>
        <ProductID>756</ProductID>
        <ProductID>757</ProductID>
        <ProductID>758</ProductID>
</Product>';
 
--2
SELECT P.ProdID.value('.', 'INT') as ProductID
FROM @XML.nodes('/Product/ProductID') P(ProdID);


--Listing 15-21. Return JSON data
SELECT TOP(3) BusinessEntityID AS [Customer.CustomerID], 
FirstName AS [Customer.FirstName], 
LastName AS [Customer.LastName]
FROM Person.Person 
FOR JSON AUTO;

--Listing 15-22. Using the PATH option
 SELECT TOP(3) BusinessEntityID AS [Customer.CustomerID], 
    FirstName AS [Customer.FirstName], 
    LastName AS [Customer.LastName]
FROM Person.Person 
FOR JSON PATH;

--Listing 15-23. Storing a JSON document in a table
--1
DROP TABLE IF EXISTS #Documents;

--2
CREATE TABLE #Documents
(
        DocumentID INT NOT NULL IDENTITY PRIMARY KEY,
        Document NVARCHAR(MAX)
);

--3
ALTER TABLE #Documents 
ADD CONSTRAINT [Document is JSON]
    CHECK (ISJSON(Document)=1);

--4
DECLARE @JSONDoc NVARCHAR(MAX);
--5
SET @JSONDoc  = N'
[
    {
        "Customer": {
            "CustomerID": 285,
            "FirstName": "Syed",
            "LastName": "Abbas"
        }
    },
    {
        "Customer": {
            "CustomerID": 293,
            "FirstName": "Catherine",
            "LastName": "Abel"
        }
    },
    {
        "Customer": {
            "CustomerID": 295,
            "FirstName": "Kim",
            "LastName": "Abercrombie"
        }
    }
]'

--6
INSERT INTO #Documents(Document)
SELECT @JSONDoc;

--Listing 15-24. Import a JSON document
INSERT INTO #Documents(Document)
SELECT BulkColumn 
FROM OPENROWSET(BULK 'C:\Temp\Test.JSON', SINGLE_CLOB) AS J;


--Listing 15-25. Shredding JSON data
--1
GO
DECLARE @jsonDoc NVARCHAR(MAX);

--2
SET @jsonDoc = N'
  {
    "ProductID": 771,
    "Name": "Mountain-100 Silver, 38",
    "Color": "Silver",
    "Size": "38",
    "ListPrice": 3399.9900,
    "DaysToManufacture": 4
  }'

--3
SELECT * 
FROM OPENJSON(@jsonDoc);

--Listing 15-26. Using the WITH clause
--1
DECLARE @jsonDoc NVARCHAR(MAX) = 
N'[
    {
        "Product": {
            "ID": 771,
            "Name": "Mountain-100 Silver, 38",
            "Color": "Silver",
            "Size": "38",
            "ListPrice": 3399.9900,
            "DaysToManufacture": 4
        }
    },
    {
        "Product": {
            "ID": 772,
            "Name": "Mountain-100 Silver, 42",
            "Color": "Silver",
            "Size": "42",
            "ListPrice": 3399.9900,
            "DaysToManufacture": 4
        }
    },
    {
        "Product": {
            "ID": 773,
            "Name": "Mountain-100 Silver, 44",
            "Color": "Silver",
            "Size": "44",
            "ListPrice": 3399.9900,
            "DaysToManufacture": 4
        }
    }
]';

--2
SELECT * 
FROM OPENJSON(@jsonDoc)
WITH (
        ProductID INT '$.Product.ID',
        [Name] NVARCHAR(25) '$.Product.Name', 
        Color NVARCHAR(15) '$.Product.Color',
        Size NVARCHAR(5) '$.Product.Size',
        ListPrice MONEY '$.Product.ListPrice',
        DaysToManufacture INT '$.Product.DaysToManufacture'
);
