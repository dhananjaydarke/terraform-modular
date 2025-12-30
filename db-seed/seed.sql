IF DB_ID(N'StudentsDB') IS NULL
BEGIN
  CREATE DATABASE StudentsDB;
END
GO

USE StudentsDB;
GO

IF OBJECT_ID(N'dbo.Students', N'U') IS NULL
BEGIN
  CREATE TABLE dbo.Students (
    RollNo INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Grade NVARCHAR(10) NOT NULL,
    DOB DATE NOT NULL
  );
END
GO

INSERT INTO dbo.Students (RollNo, Name, Grade, DOB)
SELECT * FROM (VALUES
  (1, N'Alice', N'A', '2005-01-15'),
  (2, N'Bob',   N'B', '2005-05-22'),
  (3, N'Cara',  N'A', '2006-03-10')
) AS v(RollNo, Name, Grade, DOB)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Students);
GO