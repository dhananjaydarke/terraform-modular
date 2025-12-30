CREATE TABLE IF NOT EXISTS students (
  rollno INT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  grade VARCHAR(10) NOT NULL,
  dob DATE NOT NULL
);
INSERT INTO students (rollno, name, grade, dob) VALUES
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
