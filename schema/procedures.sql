USE CMPT391Proj1Part2_3;
GO

/*
Returns all courses offered by a specific university with dept, faculty, inst, term, and enrollment count
*/
CREATE PROCEDURE dbo.GetCoursesByUniversity
    @UniversityName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName,
        dt.[Year],
        dt.Semester,
        i.InstructorName,
        COUNT(*) AS EnrollmentCount
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE c.UniversityName = @UniversityName
    GROUP BY
        c.UniversityName, c.FacultyName, c.DepartmentName,
        c.CourseCode, c.CourseName,
        dt.[Year], dt.Semester, i.InstructorName
    ORDER BY dt.[Year], dt.Semester, c.FacultyName, c.DepartmentName, c.CourseCode;
END;
GO

/*
Lists all courses offered within a specfic faculty at a specific university.
*/
CREATE PROCEDURE dbo.GetCoursesByFaculty
    @UniversityName VARCHAR(100),
    @FacultyName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName,
        dt.[Year],
        dt.Semester,
        i.InstructorName,
        COUNT(*) AS EnrollmentCount
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE c.UniversityName = @UniversityName
      AND c.FacultyName = @FacultyName
    GROUP BY
        c.UniversityName, c.FacultyName, c.DepartmentName,
        c.CourseCode, c.CourseName,
        dt.[Year], dt.Semester, i.InstructorName
    ORDER BY dt.[Year], dt.Semester, c.DepartmentName, c.CourseCode;
END;
GO

/*
Returns courses offered by a specific department
under a specific faculty at a specific university
*/
CREATE PROCEDURE dbo.GetCoursesByDepartment
    @UniversityName VARCHAR(100),
    @FacultyName VARCHAR(100),
    @DepartmentName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName,
        dt.[Year],
        dt.Semester,
        i.InstructorName,
        COUNT(*) AS EnrollmentCount
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE c.UniversityName = @UniversityName
      AND c.FacultyName = @FacultyName
      AND c.DepartmentName = @DepartmentName
    GROUP BY
        c.UniversityName, c.FacultyName, c.DepartmentName,
        c.CourseCode, c.CourseName,
        dt.[Year], dt.Semester, i.InstructorName
    ORDER BY dt.[Year], dt.Semester, c.CourseCode;
END;
GO

/*
Returns courses taught by a specific instructor
shows university, faculty, course code, course name, year, semester, and enrollment in that course
*/
CREATE PROCEDURE dbo.GetCoursesByInstructor
    @InstructorName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.UniversityName,
        c.FacultyName,
        c.CourseCode,
        c.CourseName,
        dt.[Year],
        dt.Semester,
        i.InstructorName,
        COUNT(*) AS EnrollmentCount
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    WHERE i.InstructorName = @InstructorName
    GROUP BY
        c.UniversityName, c.FacultyName,
        c.CourseCode, c.CourseName,
        dt.[Year], dt.Semester, i.InstructorName
    ORDER BY dt.[Year], dt.Semester, c.CourseCode;
END;
GO

/*
Returns courses taken by a specific student
does it by student name
*/
CREATE PROCEDURE dbo.GetCoursesByStudent
    @StudentName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.StudentName,
        s.Major,
        s.Gender,
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName,
        dt.[Year],
        dt.Semester,
        i.InstructorName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimStudent s ON f.StudentKey = s.StudentKey
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE s.StudentName = @StudentName
    ORDER BY dt.[Year], dt.Semester, c.CourseCode;
END;
GO

/*
Returns all courses offered during a specific academic term across all universities.
*/
CREATE PROCEDURE dbo.GetCoursesByTerm
    @Year INT,
    @Semester VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        dt.[Year],
        dt.Semester,
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName,
        i.InstructorName,
        COUNT(*) AS EnrollmentCount
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE dt.[Year] = @Year
      AND dt.Semester = @Semester
    GROUP BY
        dt.[Year], dt.Semester,
        c.UniversityName, c.FacultyName, c.DepartmentName,
        c.CourseCode, c.CourseName, i.InstructorName
    ORDER BY c.UniversityName, c.FacultyName, c.DepartmentName, c.CourseCode;
END;
GO

/*
Returns courses based off university name and department name
so all courses under a dept in a uni.
*/
CREATE PROCEDURE dbo.GetCoursesByUniversityAndDepartment
    @UniversityName VARCHAR(100),
    @DepartmentName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    WHERE c.UniversityName = @UniversityName
      AND c.DepartmentName = @DepartmentName
    ORDER BY c.CourseCode;
END;
GO

/*
Returns courses based on faculty and university name
*/
CREATE PROCEDURE dbo.GetCoursesByUniversityAndFaculty
    @UniversityName VARCHAR(100),
    @FacultyName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    WHERE c.UniversityName = @UniversityName
      AND c.FacultyName = @FacultyName
    ORDER BY c.DepartmentName, c.CourseCode;
END;
GO

/*
Returns courses based on faculty and department from all universities.
*/
CREATE PROCEDURE dbo.GetCoursesByFacultyAndDepartment
    @FacultyName VARCHAR(100),
    @DepartmentName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    WHERE c.FacultyName = @FacultyName
      AND c.DepartmentName = @DepartmentName
    ORDER BY c.UniversityName, c.CourseCode;
END;
GO

/*
Returns courses based on:
university name, faculty name, department name
*/
CREATE PROCEDURE dbo.GetCoursesByUniversityFacultyDepartment
    @UniversityName VARCHAR(100),
    @FacultyName VARCHAR(100),
    @DepartmentName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    WHERE c.UniversityName = @UniversityName
      AND c.FacultyName = @FacultyName
      AND c.DepartmentName = @DepartmentName
    ORDER BY c.CourseCode;
END;
GO

/*
Returns all courses taught by a specific instructor at a specific university
*/
CREATE PROCEDURE dbo.GetCoursesByUniversityAndInstructor
    @UniversityName VARCHAR(100),
    @InstructorName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        i.InstructorName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName,
        dt.[Year],
        dt.Semester
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    WHERE c.UniversityName = @UniversityName
      AND i.InstructorName = @InstructorName
    ORDER BY dt.[Year], dt.Semester, c.CourseCode;
END;
GO

/*
Return courses using the parameters:
    department name, instructor name
*/
CREATE PROCEDURE dbo.GetCoursesByDepartmentAndInstructor
    @DepartmentName VARCHAR(100),
    @InstructorName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        c.DepartmentName,
        i.InstructorName,
        c.CourseCode,
        c.CourseName,
        dt.[Year],
        dt.Semester
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    WHERE c.DepartmentName = @DepartmentName
      AND i.InstructorName = @InstructorName
    ORDER BY c.UniversityName, dt.[Year], dt.Semester, c.CourseCode;
END;
GO

/*
Returns courses based on:
    University, department, term
*/
CREATE PROCEDURE dbo.GetCoursesByUniversityDepartmentAndTerm
    @UniversityName VARCHAR(100),
    @DepartmentName VARCHAR(100),
    @Year INT,
    @Semester VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        c.DepartmentName,
        dt.[Year],
        dt.Semester,
        c.CourseCode,
        c.CourseName,
        i.InstructorName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE c.UniversityName = @UniversityName
      AND c.DepartmentName = @DepartmentName
      AND dt.[Year] = @Year
      AND dt.Semester = @Semester
    ORDER BY c.CourseCode;
END;
GO

/*
Returns courses using:
    faculty, department, term
*/
CREATE PROCEDURE dbo.GetCoursesByFacultyDepartmentAndTerm
    @FacultyName VARCHAR(100),
    @DepartmentName VARCHAR(100),
    @Year INT,
    @Semester VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        dt.[Year],
        dt.Semester,
        c.CourseCode,
        c.CourseName,
        i.InstructorName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE c.FacultyName = @FacultyName
      AND c.DepartmentName = @DepartmentName
      AND dt.[Year] = @Year
      AND dt.Semester = @Semester
    ORDER BY c.UniversityName, c.CourseCode;
END;
GO

/*
Returns courses using:
    university, faculty, department, term
*/
CREATE PROCEDURE dbo.GetCoursesByUniversityFacultyDepartmentAndTerm
    @UniversityName VARCHAR(100),
    @FacultyName VARCHAR(100),
    @DepartmentName VARCHAR(100),
    @Year INT,
    @Semester VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        dt.[Year],
        dt.Semester,
        c.CourseCode,
        c.CourseName,
        i.InstructorName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE c.UniversityName = @UniversityName
      AND c.FacultyName = @FacultyName
      AND c.DepartmentName = @DepartmentName
      AND dt.[Year] = @Year
      AND dt.Semester = @Semester
    ORDER BY c.CourseCode;
END;
GO

/*
Return courses based on:
    university name and student name
*/
CREATE PROCEDURE dbo.GetCoursesByUniversityAndStudent
    @UniversityName VARCHAR(100),
    @StudentName VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.StudentName,
        c.UniversityName,
        c.CourseCode,
        c.CourseName,
        dt.[Year],
        dt.Semester,
        i.InstructorName
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimStudent s ON f.StudentKey = s.StudentKey
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    JOIN dbo.DimInstructor i ON f.InstructorKey = i.InstructorKey
    WHERE c.UniversityName = @UniversityName
      AND s.StudentName = @StudentName
    ORDER BY dt.[Year], dt.Semester, c.CourseCode;
END;
GO

/*
Return courses based on:
    Major, gender
*/
CREATE PROCEDURE dbo.GetCoursesByMajorAndGender
    @Major VARCHAR(100),
    @Gender VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.Major,
        s.Gender,
        c.UniversityName,
        c.CourseCode,
        c.CourseName,
        COUNT(*) AS EnrollmentCount
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimStudent s ON f.StudentKey = s.StudentKey
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    WHERE s.Major = @Major
      AND s.Gender = @Gender
    GROUP BY
        s.Major, s.Gender,
        c.UniversityName,
        c.CourseCode, c.CourseName
    ORDER BY c.UniversityName, c.CourseCode;
END;
GO

/*
Returns number of students based on optional filters:
    University
    Faculty
    Department
    Course
*/
CREATE PROCEDURE dbo.GetStudentCounts
    @UniversityName VARCHAR(100) = NULL,
    @FacultyName VARCHAR(100) = NULL,
    @DepartmentName VARCHAR(100) = NULL,
    @CourseCode VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName,
        COUNT(DISTINCT f.StudentKey) AS TotalStudents
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    WHERE
        (@UniversityName IS NULL OR c.UniversityName = @UniversityName)
        AND (@FacultyName IS NULL OR c.FacultyName = @FacultyName)
        AND (@DepartmentName IS NULL OR c.DepartmentName = @DepartmentName)
        AND (@CourseCode IS NULL OR c.CourseCode = @CourseCode)
    GROUP BY
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode,
        c.CourseName
    ORDER BY
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        c.CourseCode;
END;
GO
    
/*
Returns student counts with optional filters:
    University
    Faculty
    Department
    Year
    Semester
*/
CREATE PROCEDURE dbo.GetStudentCountsByTerm
    @UniversityName VARCHAR(100) = NULL,
    @FacultyName VARCHAR(100) = NULL,
    @DepartmentName VARCHAR(100) = NULL,
    @Year INT = NULL,
    @Semester VARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        dt.[Year],
        dt.Semester,
        COUNT(DISTINCT f.StudentKey) AS TotalStudents
    FROM dbo.FactCourseActivity f
    JOIN dbo.DimCourse c ON f.CourseKey = c.CourseKey
    JOIN dbo.DimDate dt ON f.DateKey = dt.DateKey
    WHERE
        (@UniversityName IS NULL OR c.UniversityName = @UniversityName)
        AND (@FacultyName IS NULL OR c.FacultyName = @FacultyName)
        AND (@DepartmentName IS NULL OR c.DepartmentName = @DepartmentName)
        AND (@Year IS NULL OR dt.[Year] = @Year)
        AND (@Semester IS NULL OR dt.Semester = @Semester)
    GROUP BY
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName,
        dt.[Year],
        dt.Semester
    ORDER BY
        dt.[Year],
        dt.Semester,
        c.UniversityName,
        c.FacultyName,
        c.DepartmentName;
END;
GO