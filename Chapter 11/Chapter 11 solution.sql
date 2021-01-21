/*
Chapter 11 solution
*/
--11
DROP TABLE IF EXISTS dbo.Demo;
CREATE TABLE dbo.Demo(ID INT PRIMARY KEY, Name VARCHAR(25));

--11.1.1
--Here’s a possible solution: 
 
BEGIN TRAN
    INSERT INTO dbo.Demo(ID,Name)
    VALUES (1,'Test1');
 
    INSERT INTO dbo.Demo(ID,Name)
    VALUES(2,'Test2');
COMMIT TRAN;
 
--11.1.2
--Here’s a possible solution: 
 
BEGIN TRAN
    INSERT INTO dbo.Demo(ID,Name)
    VALUES(3,'Test3');
    INSERT INTO dbo.Demo(ID,Name)
    VALUES('a','Test4');
COMMIT TRAN;
GO
SELECT ID,Name
FROM dbo.Demo;

--11.1.3
/*There are uncommitted transactions. Do you wish to commit these transactions? 

This indicates that there are open transactions that are pending, and that I 
have forgotten to close any explicit transactions. Generally, I say no 
if I ever run into this message because I don't know what I am committing!

*/

--11.1.4
BEGIN TRAN
    SELECT * INTO dbo.Demo2 FROM dbo.Demo;
ROLLBACK TRAN;
SELECT * FROM dbo.Demo2;

/*
Invalid object name 'dbo.demo2'
Since the transaction was rolled back, even the creation of the new table was rolled back.
*/

--11.2.1
BEGIN TRY
    INSERT INTO
        HumanResources.Department
        (Name, GroupName, ModifiedDate)
    VALUES ('Engineering','Research and Development', GETDATE());
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS
        ErrorNumber,ERROR_MESSAGE()
             AS ErrorMessage,
        ERROR_SEVERITY() AS ErrorSeverity;
END CATCH;


--11.2.2
BEGIN TRY
    INSERT INTO
        HumanResources.Department
            (Name, GroupName, ModifiedDate)
    VALUES ('Engineering',
        'Research and Development',
        GETDATE());
END TRY
BEGIN CATCH
	IF ERROR_NUMBER() = 2601 BEGIN
        RAISERROR(
           'You attempted to insert a duplicate!',
           16, 1);
   END;
END CATCH;


--11.2.3
BEGIN
    BEGIN TRY
         SELECT 1.234 + 'A';
    END TRY
    BEGIN CATCH
    END CATCH
END;

/*
The error is just ignored instead of being handled or returned back to the calling application.
*/

--11.2.4
RAISERROR('message', 20, 2) WITH LOG;
--The error will be logged into the SQL Server error log and the connection will be killed.

--11.2.5
THROW 59999,'An error has been thrown',1;
