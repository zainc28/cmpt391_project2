USE CMPT391Proj1Part2_3;
GO

-- Courses
INSERT INTO dbo.DimCourse
(
    CourseCode,
    CourseName,
    DepartmentName,
    FacultyName,
    UniversityName,
    Province
)
VALUES
('CMPUT101', 'Intro to Computing',              'Computer Science',       'Science',     'University of Alberta', 'Alberta'),
('CMPUT201', 'Data Structures',                 'Computer Science',       'Science',     'University of Alberta', 'Alberta'),
('MATH101',  'Calculus I',                      'Mathematics',            'Science',     'University of Alberta', 'Alberta'),
('ECON101',  'Microeconomics',                  'Economics',              'Arts',        'University of Alberta', 'Alberta'),
('MECE201',  'Thermodynamics',                  'Mechanical Engineering', 'Engineering', 'University of Alberta', 'Alberta'),

('CPSC231',  'Intro to Computer Science',       'Computer Science',       'Science',     'University of Calgary', 'Alberta'),
('CPSC331',  'Algorithms and Data Structures',  'Computer Science',       'Science',     'University of Calgary', 'Alberta'),
('MATH211',  'Linear Methods I',                'Mathematics',            'Science',     'University of Calgary', 'Alberta'),
('ECON201',  'Macroeconomics',                  'Economics',              'Arts',        'University of Calgary', 'Alberta'),
('ENEL101',  'Circuit Analysis',                'Electrical Engineering', 'Engineering', 'University of Calgary', 'Alberta'),

('CMPT101',  'Computing I',                     'Computer Science',       'Science',     'MacEwan University',    'Alberta'),
('CMPT201',  'Object-Oriented Programming',     'Computer Science',       'Science',     'MacEwan University',    'Alberta'),
('ACCT101',  'Intro Accounting',                'Accounting',             'Business',    'MacEwan University',    'Alberta'),
('NURS120',  'Foundations of Nursing',          'Nursing',                'Nursing',     'MacEwan University',    'Alberta');
GO

-- Instructors
INSERT INTO dbo.DimInstructor
(
    InstructorName,
    [Rank],
    FacultyName,
    UniversityName
)
VALUES
('John Smith',   'Professor',           'Science',     'University of Alberta'),
('Mary Johnson', 'Associate Professor', 'Science',     'University of Alberta'),
('Susan Lee',    'Assistant Professor', 'Arts',        'University of Alberta'),
('Mark Taylor',  'Professor',           'Engineering', 'University of Alberta'),

('Robert Chen',  'Professor',           'Science',     'University of Calgary'),
('Nancy Adams',  'Associate Professor', 'Science',     'University of Calgary'),
('Linda Turner', 'Assistant Professor', 'Arts',        'University of Calgary'),
('Paul Miller',  'Professor',           'Engineering', 'University of Calgary'),

('Derek Fox',    'Professor',           'Science',     'MacEwan University'),
('Emily Grant',  'Assistant Professor', 'Business',    'MacEwan University'),
('Fiona Reid',   'Associate Professor', 'Nursing',     'MacEwan University');
GO

-- Students
INSERT INTO dbo.DimStudent (StudentName, Major, Gender)
VALUES
('Alice Brown',  'Computer Science',       'Female'),
('Bob Green',    'Computer Science',       'Male'),
('Carol White',  'Software Engineering',   'Female'),
('David Black',  'Mathematics',            'Male'),
('Eva Stone',    'Economics',              'Female'),
('Frank Hall',   'Mechanical Engineering', 'Male'),
('Grace Lee',    'Computer Science',       'Female'),
('Henry Ward',   'Accounting',             'Male'),
('Ivy Chen',     'Nursing',                'Female'),
('Jack Moore',   'Electrical Engineering', 'Male'),
('Karen Li',     'Computer Science',       'Female'),
('Liam Scott',   'Economics',              'Male');
GO

-- Dates
INSERT INTO dbo.DimDate (DateKey, Semester, [Year])
VALUES
(202401, 'Winter', 2024),
(202404, 'Fall',   2024),
(202501, 'Winter', 2025),
(202504, 'Fall',   2025);
GO

-- Fact rows
INSERT INTO dbo.FactCourseActivity
(
    CourseKey,
    InstructorKey,
    StudentKey,
    DateKey,
    ActivityCount
)
VALUES
-- University of Alberta
(1,  1,  1, 202404, 1),
(1,  1,  2, 202404, 1),
(2,  1,  3, 202501, 1),
(2,  1,  7, 202501, 1),
(3,  2,  4, 202404, 1),
(3,  2,  1, 202404, 1),
(4,  3,  5, 202404, 1),
(4,  3, 12, 202404, 1),
(5,  4,  6, 202501, 1),

-- University of Calgary
(6,  5,  7, 202404, 1),
(6,  5, 11, 202404, 1),
(7,  5,  3, 202501, 1),
(7,  5,  2, 202501, 1),
(8,  6,  4, 202404, 1),
(9,  7,  5, 202404, 1),
(9,  7, 12, 202404, 1),
(10, 8, 10, 202501, 1),

-- MacEwan University
(11, 9,  1, 202404, 1),
(11, 9, 11, 202404, 1),
(12, 9,  2, 202501, 1),
(12, 9,  7, 202501, 1),
(13,10,  8, 202404, 1),
(14,11,  9, 202501, 1);
GO

-- Indexes
CREATE INDEX IX_FactCourseActivity_CourseKey
    ON dbo.FactCourseActivity(CourseKey);
CREATE INDEX IX_FactCourseActivity_InstructorKey
    ON dbo.FactCourseActivity(InstructorKey);
CREATE INDEX IX_FactCourseActivity_StudentKey
    ON dbo.FactCourseActivity(StudentKey);
CREATE INDEX IX_FactCourseActivity_DateKey
    ON dbo.FactCourseActivity(DateKey);
GO