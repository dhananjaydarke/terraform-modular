CREATE TABLE IF NOT EXISTS Students (
  RollNo INT PRIMARY KEY,
  Name NVARCHAR(100),
  Grade NVARCHAR(10),
  DOB DATE
);
INSERT INTO Students (RollNo, Name, Grade, DOB) VALUES
(1,'Alice','A','2007-02-14'),
(2,'Bob','B','2007-05-21'),
(3,'Charlie','A','2007-08-03'),
(4,'Diana','A','2007-10-30'),
(5,'Ethan','B','2007-12-11'),
(6,'Fiona','A','2008-01-19'),
(7,'George','C','2008-03-07'),
(8,'Hannah','B','2008-04-25'),
(9,'Ivan','A','2008-06-15'),
(10,'Julia','A','2008-09-09');
