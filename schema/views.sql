USE CMPT391Proj1Part2_3;
GO

-- Total distinct courses offered by university
CREATE VIEW dbo.vw_CoursesByUniversity
AS
SELECT
    c.UniversityName,
    COUNT(DISTINCT c.CourseKey) AS TotalCoursesOffered
FROM dbo.FactCourseActivity f
JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
GROUP BY c.UniversityName;
GO

-- Total distinct courses offered by faculty
CREATE VIEW dbo.vw_CoursesByFaculty
AS
SELECT
    c.UniversityName,
    c.FacultyName,
    COUNT(DISTINCT c.CourseKey) AS TotalCoursesOffered
FROM dbo.FactCourseActivity f
JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
GROUP BY c.UniversityName, c.FacultyName;
GO

-- Total distinct courses offered by department
CREATE VIEW dbo.vw_CoursesByDepartment
AS
SELECT
    c.UniversityName,
    c.FacultyName,
    c.DepartmentName,
    COUNT(DISTINCT c.CourseKey) AS TotalCoursesOffered
FROM dbo.FactCourseActivity f
JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
GROUP BY c.UniversityName, c.FacultyName, c.DepartmentName;
GO

-- Courses by year and semester
CREATE VIEW dbo.vw_CoursesByTerm
AS
SELECT
    dt.[Year],
    dt.Semester,
    COUNT(DISTINCT c.CourseKey) AS TotalCoursesOffered
FROM dbo.FactCourseActivity f
JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
GROUP BY dt.[Year], dt.Semester;
GO

-- Instructor summary
CREATE VIEW dbo.vw_CoursesByInstructor
AS
SELECT
    i.UniversityName,
    i.InstructorName,
    i.[Rank],
    COUNT(DISTINCT c.CourseKey) AS TotalCoursesTaught,
    COUNT(*) AS TotalEnrollments
FROM dbo.FactCourseActivity f
JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
GROUP BY i.UniversityName, i.InstructorName, i.[Rank];
GO

-- Student summary
CREATE VIEW dbo.vw_StudentEnrollments
AS
SELECT
    s.StudentName,
    s.Major,
    s.Gender,
    COUNT(*) AS TotalEnrollments
FROM dbo.FactCourseActivity f
JOIN dbo.DimStudent s ON f.StudentKey = s.StudentKey
GROUP BY s.StudentName, s.Major, s.Gender;
GO

-- Course popularity
CREATE VIEW dbo.vw_CoursePopularity
AS
SELECT
    c.UniversityName,
    c.CourseCode,
    c.CourseName,
    COUNT(*) AS TotalEnrollments
FROM dbo.FactCourseActivity f
JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
GROUP BY c.UniversityName, c.CourseCode, c.CourseName;
GO

-- Distinct course list by university + department
CREATE VIEW dbo.vw_CoursesByUniversityAndDepartment
AS
SELECT DISTINCT
    c.UniversityName,
    c.FacultyName,
    c.DepartmentName,
    c.CourseCode,
    c.CourseName
FROM dbo.FactCourseActivity f
JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey;
GO