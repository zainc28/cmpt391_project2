USE master;
GO

IF DB_ID('CMPT391Proj1Part2_3') IS NOT NULL
BEGIN
    ALTER DATABASE CMPT391Proj1Part2_3 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE CMPT391Proj1Part2_3;
END;
GO

CREATE DATABASE CMPT391Proj1Part2_3;
GO

USE CMPT391Proj1Part2_3;
GO

IF OBJECT_ID('dbo.FactCourseActivity', 'U') IS NOT NULL DROP TABLE dbo.FactCourseActivity;
IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL DROP TABLE dbo.DimDate;
IF OBJECT_ID('dbo.DimStudent', 'U') IS NOT NULL DROP TABLE dbo.DimStudent;
IF OBJECT_ID('dbo.DimInstructor', 'U') IS NOT NULL DROP TABLE dbo.DimInstructor;
IF OBJECT_ID('dbo.DimCourse', 'U') IS NOT NULL DROP TABLE dbo.DimCourse;
GO

CREATE TABLE dbo.DimCourse
(
    CourseKey       INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode      VARCHAR(20) NOT NULL,
    CourseName      VARCHAR(150) NOT NULL,
    DepartmentName  VARCHAR(100) NOT NULL,
    FacultyName     VARCHAR(100) NOT NULL,
    UniversityName  VARCHAR(100) NOT NULL,
    Province        VARCHAR(50) NOT NULL,
    CONSTRAINT UQ_DimCourse UNIQUE
    (
        CourseCode,
        CourseName,
        DepartmentName,
        FacultyName,
        UniversityName
    )
);
GO

CREATE TABLE dbo.DimInstructor
(
    InstructorKey   INT IDENTITY(1,1) PRIMARY KEY,
    InstructorName  VARCHAR(100) NOT NULL,
    [Rank]          VARCHAR(50) NOT NULL,
    FacultyName     VARCHAR(100) NOT NULL,
    UniversityName  VARCHAR(100) NOT NULL,
    CONSTRAINT UQ_DimInstructor UNIQUE
    (
        InstructorName,
        [Rank],
        FacultyName,
        UniversityName
    )
);
GO

CREATE TABLE dbo.DimStudent
(
    StudentKey      INT IDENTITY(1,1) PRIMARY KEY,
    StudentName     VARCHAR(100) NOT NULL,
    Major           VARCHAR(100) NOT NULL,
    Gender          VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_DimStudent UNIQUE (StudentName, Major, Gender)
);
GO

CREATE TABLE dbo.DimDate
(
    DateKey         INT PRIMARY KEY,
    Semester        VARCHAR(20) NOT NULL,
    [Year]          INT NOT NULL,
    CONSTRAINT UQ_DimDate UNIQUE (Semester, [Year])
);
GO

CREATE TABLE dbo.FactCourseActivity
(
    FactKey         INT IDENTITY(1,1) PRIMARY KEY,
    CourseKey       INT NOT NULL,
    InstructorKey   INT NOT NULL,
    StudentKey      INT NOT NULL,
    DateKey         INT NOT NULL,
    ActivityCount   INT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Fact_Course
        FOREIGN KEY (CourseKey) REFERENCES dbo.DimCourse(CourseKey),

    CONSTRAINT FK_Fact_Instructor
        FOREIGN KEY (InstructorKey) REFERENCES dbo.DimInstructor(InstructorKey),

    CONSTRAINT FK_Fact_Student
        FOREIGN KEY (StudentKey) REFERENCES dbo.DimStudent(StudentKey),

    CONSTRAINT FK_Fact_Date
        FOREIGN KEY (DateKey) REFERENCES dbo.DimDate(DateKey)
);
GO