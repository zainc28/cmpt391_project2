USE CMPT391Proj1Part2_3;
GO

-- View tests
-- SELECT * FROM dbo.vw_CoursesByUniversity;
-- SELECT * FROM dbo.vw_CoursesByFaculty;
-- SELECT * FROM dbo.vw_CoursesByDepartment;
-- SELECT * FROM dbo.vw_CoursesByTerm;
-- SELECT * FROM dbo.vw_CoursesByInstructor;
-- SELECT * FROM dbo.vw_StudentEnrollments;
-- SELECT * FROM dbo.vw_CoursePopularity;
-- SELECT * FROM dbo.vw_CoursesByUniversityAndDepartment;
GO

-- Stored procedure tests
-- EXEC dbo.GetCoursesByUniversity @UniversityName = 'University of Alberta';
-- EXEC dbo.GetCoursesByFaculty
--     @UniversityName = 'University of Alberta',
--     @FacultyName = 'Science';

-- EXEC dbo.GetCoursesByDepartment
--     @UniversityName = 'University of Alberta',
--     @FacultyName = 'Science',
--     @DepartmentName = 'Computer Science';

-- EXEC dbo.GetCoursesByInstructor
--     @InstructorName = 'John Smith';

-- EXEC dbo.GetCoursesByStudent
--     @StudentName = 'Alice Brown';

-- EXEC dbo.GetCoursesByTerm
--     @Year = 2024,
--     @Semester = 'Fall';

-- EXEC dbo.GetCoursesByUniversityAndDepartment
--     @UniversityName = 'University of Alberta',
--     @DepartmentName = 'Computer Science';

-- EXEC dbo.GetCoursesByUniversityAndFaculty
--     @UniversityName = 'University of Alberta',
--     @FacultyName = 'Science';

-- EXEC dbo.GetCoursesByFacultyAndDepartment
--     @FacultyName = 'Science',
--     @DepartmentName = 'Computer Science';

-- EXEC dbo.GetCoursesByUniversityFacultyDepartment
--     @UniversityName = 'University of Alberta',
--     @FacultyName = 'Science',
--     @DepartmentName = 'Computer Science';

-- EXEC dbo.GetCoursesByUniversityAndInstructor
--     @UniversityName = 'University of Alberta',
--     @InstructorName = 'John Smith';

-- EXEC dbo.GetCoursesByDepartmentAndInstructor
--     @DepartmentName = 'Computer Science',
--     @InstructorName = 'John Smith';

-- EXEC dbo.GetCoursesByUniversityDepartmentAndTerm
--     @UniversityName = 'University of Alberta',
--     @DepartmentName = 'Computer Science',
--     @Year = 2025,
--     @Semester = 'Winter';

-- EXEC dbo.GetCoursesByFacultyDepartmentAndTerm
--     @FacultyName = 'Science',
--     @DepartmentName = 'Computer Science',
--     @Year = 2024,
--     @Semester = 'Fall';

-- EXEC dbo.GetCoursesByUniversityFacultyDepartmentAndTerm
--     @UniversityName = 'University of Calgary',
--     @FacultyName = 'Science',
--     @DepartmentName = 'Computer Science',
--     @Year = 2025,
--     @Semester = 'Winter';

EXEC dbo.GetCoursesByUniversityAndStudent
    @UniversityName = 'MacEwan University',
    @StudentName = 'Alice Brown';

EXEC dbo.GetCoursesByMajorAndGender
    @Major = 'Computer Science',
    @Gender = 'Male';
GO