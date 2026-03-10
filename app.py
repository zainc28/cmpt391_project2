import streamlit as st
import pyodbc
import pandas as pd
import xml.etree.ElementTree as ET
from datetime import datetime

# ============================================================================
# DATABASE CONNECTION
# ============================================================================

def get_connection():
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=CMPT391Proj1Part2_3;"
        "Trusted_Connection=yes;"
        "Encrypt=no;"
    )
    return conn

def run_query(query):
    conn = get_connection()
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# ============================================================================
# ETL FUNCTIONS
# ============================================================================

def parse_xml_file(uploaded_file):
    tree = ET.parse(uploaded_file)
    root = tree.getroot()
    records = []
    
    for r in root.findall("record"):
        record = {
            "university": r.find("UniversityName").text,
            "province": r.find("Province").text,
            "faculty": r.find("FacultyName").text,
            "department": r.find("DepartmentName").text,
            "course_code": r.find("CourseCode").text,
            "course_name": r.find("CourseName").text,
            "instructor": r.find("InstructorName").text,
            "rank": r.find("Rank").text,
            "student": r.find("StudentName").text,
            "major": r.find("Major").text,
            "gender": r.find("Gender").text,
            "semester": r.find("Semester").text,
            "year": r.find("Year").text
        }
        records.append(record)
    
    return records

def get_or_insert_course(cursor, rec):
    cursor.execute("""
        SELECT CourseKey FROM DimCourse 
        WHERE CourseCode=? AND CourseName=? AND DepartmentName=? 
              AND FacultyName=? AND UniversityName=?
    """, rec["course_code"], rec["course_name"], rec["department"], 
         rec["faculty"], rec["university"])
    row = cursor.fetchone()
    if row:
        return row[0]
    
    cursor.execute("""
        INSERT INTO DimCourse (CourseCode, CourseName, DepartmentName, FacultyName, UniversityName, Province)
        OUTPUT INSERTED.CourseKey
        VALUES (?, ?, ?, ?, ?, ?)
    """, rec["course_code"], rec["course_name"], rec["department"], 
         rec["faculty"], rec["university"], rec["province"])
    return cursor.fetchone()[0]

def get_or_insert_instructor(cursor, rec):
    cursor.execute("""
        SELECT InstructorKey FROM DimInstructor 
        WHERE InstructorName=? AND [Rank]=? AND FacultyName=? AND UniversityName=?
    """, rec["instructor"], rec["rank"], rec["faculty"], rec["university"])
    row = cursor.fetchone()
    if row:
        return row[0]
    
    cursor.execute("""
        INSERT INTO DimInstructor (InstructorName, [Rank], FacultyName, UniversityName)
        OUTPUT INSERTED.InstructorKey
        VALUES (?, ?, ?, ?)
    """, rec["instructor"], rec["rank"], rec["faculty"], rec["university"])
    return cursor.fetchone()[0]

def get_or_insert_student(cursor, rec):
    cursor.execute("""
        SELECT StudentKey FROM DimStudent WHERE StudentName=? AND Major=? AND Gender=?
    """, rec["student"], rec["major"], rec["gender"])
    row = cursor.fetchone()
    if row:
        return row[0]
    
    cursor.execute("""
        INSERT INTO DimStudent (StudentName, Major, Gender)
        OUTPUT INSERTED.StudentKey
        VALUES (?, ?, ?)
    """, rec["student"], rec["major"], rec["gender"])
    return cursor.fetchone()[0]

def get_or_insert_date(cursor, rec):
    semester = rec["semester"]
    year = int(rec["year"])
    
    cursor.execute("SELECT DateKey FROM DimDate WHERE Semester=? AND [Year]=?", semester, year)
    row = cursor.fetchone()
    if row:
        return row[0]
    
    month = "01" if semester.lower() == "winter" else "04"
    date_key = int(f"{year}{month}")
    
    cursor.execute("INSERT INTO DimDate (DateKey, Semester, [Year]) VALUES (?, ?, ?)", 
                   date_key, semester, year)
    return date_key

def load_records_to_db(records):
    conn = get_connection()
    cursor = conn.cursor()
    
    loaded = 0
    for rec in records:
        course_key = get_or_insert_course(cursor, rec)
        instructor_key = get_or_insert_instructor(cursor, rec)
        student_key = get_or_insert_student(cursor, rec)
        date_key = get_or_insert_date(cursor, rec)
        
        cursor.execute("""
            INSERT INTO FactCourseActivity (CourseKey, InstructorKey, StudentKey, DateKey, ActivityCount)
            VALUES (?, ?, ?, ?, 1)
        """, course_key, instructor_key, student_key, date_key)
        loaded += 1
    
    conn.commit()
    conn.close()
    return loaded

# ============================================================================
# DATA LOADING
# ============================================================================

@st.cache_data
def load_all_data():
    query = """
        SELECT 
            c.UniversityName,
            c.FacultyName,
            c.DepartmentName,
            c.CourseCode,
            c.CourseName,
            i.InstructorName,
            i.[Rank] as InstructorRank,
            s.StudentName,
            s.Major,
            s.Gender,
            d.[Year],
            d.Semester
        FROM FactCourseActivity f
        JOIN DimCourse c ON f.CourseKey = c.CourseKey
        JOIN DimInstructor i ON f.InstructorKey = i.InstructorKey
        JOIN DimStudent s ON f.StudentKey = s.StudentKey
        JOIN DimDate d ON f.DateKey = d.DateKey
    """
    return run_query(query)

def get_filter_options(df, column, filters_applied):
    filtered = df.copy()
    for col, val in filters_applied.items():
        if col != column and val:
            filtered = filtered[filtered[col] == val]
    return ["All"] + sorted(filtered[column].unique().tolist())

# ============================================================================
# MAIN APP
# ============================================================================

st.set_page_config(page_title="Course Data Warehouse", layout="wide")

# Initialize upload history
if "upload_history" not in st.session_state:
    st.session_state.upload_history = []

# Sidebar - XML Upload
st.sidebar.header("Load Data")
uploaded_file = st.sidebar.file_uploader("Upload XML", type=["xml"])

if uploaded_file is not None:
    if st.sidebar.button("Load"):
        try:
            records = parse_xml_file(uploaded_file)
            count = load_records_to_db(records)
            st.sidebar.success(f"Loaded {count} records")
            
            st.session_state.upload_history.append({
                "file": uploaded_file.name,
                "date": datetime.now().strftime("%Y-%m-%d %H:%M"),
                "records": count
            })
            
            st.cache_data.clear()
        except Exception as e:
            st.sidebar.error(f"Error: {str(e)}")

# Upload history
if st.session_state.upload_history:
    st.sidebar.markdown("---")
    st.sidebar.markdown("**Uploaded Files**")
    for entry in st.session_state.upload_history:
        st.sidebar.text(entry['file'])
        st.sidebar.caption(entry['date'])

# ============================================================================
# TABS
# ============================================================================

tab1, tab2, tab3 = st.tabs(["Browse & Filter", "Drill-Down", "Trends"])

# ----------------------------------------------------------------------------
# TAB 1: BROWSE & FILTER
# ----------------------------------------------------------------------------
with tab1:
    try:
        df = load_all_data()
        
        col_title, col_stat = st.columns([3, 1])
        with col_title:
            st.header("Course Activity Data")
        with col_stat:
            total_courses = df[["CourseCode", "UniversityName"]].drop_duplicates().shape[0]
            st.metric("Total Courses", total_courses)
        
        filter_header, reset_col = st.columns([6, 1])
        with filter_header:
            st.markdown("**Filters**")
        with reset_col:
            if st.button("Reset"):
                st.cache_data.clear()
                for key in list(st.session_state.keys()):
                    if key.startswith("f_"):
                        del st.session_state[key]
                st.rerun()
        
        if "filters" not in st.session_state:
            st.session_state.filters = {}
        
        current_filters = {}
        
        fc1, fc2, fc3 = st.columns(3)
        with fc1:
            uni_opts = ["All"] + sorted(df["UniversityName"].unique().tolist())
            sel_uni = st.selectbox("University", uni_opts, key="f_uni")
            current_filters["UniversityName"] = sel_uni if sel_uni != "All" else None
        
        with fc2:
            fac_opts = get_filter_options(df, "FacultyName", current_filters)
            sel_fac = st.selectbox("Faculty", fac_opts, key="f_fac")
            current_filters["FacultyName"] = sel_fac if sel_fac != "All" else None
        
        with fc3:
            dept_opts = get_filter_options(df, "DepartmentName", current_filters)
            sel_dept = st.selectbox("Department", dept_opts, key="f_dept")
            current_filters["DepartmentName"] = sel_dept if sel_dept != "All" else None
        
        fc4, fc5, fc6 = st.columns(3)
        with fc4:
            year_opts = ["All"] + sorted([str(y) for y in df["Year"].unique().tolist()])
            sel_year = st.selectbox("Year", year_opts, key="f_year")
            current_filters["Year"] = int(sel_year) if sel_year != "All" else None
        
        with fc5:
            sem_opts = ["All"] + sorted(df["Semester"].unique().tolist())
            sel_sem = st.selectbox("Semester", sem_opts, key="f_sem")
            current_filters["Semester"] = sel_sem if sel_sem != "All" else None
        
        with fc6:
            inst_opts = get_filter_options(df, "InstructorName", current_filters)
            sel_inst = st.selectbox("Instructor", inst_opts, key="f_inst")
            current_filters["InstructorName"] = sel_inst if sel_inst != "All" else None
        
        fc7, fc8, fc9 = st.columns(3)
        with fc7:
            major_opts = get_filter_options(df, "Major", current_filters)
            sel_major = st.selectbox("Major", major_opts, key="f_major")
            current_filters["Major"] = sel_major if sel_major != "All" else None
        
        with fc8:
            gender_opts = ["All"] + sorted(df["Gender"].unique().tolist())
            sel_gender = st.selectbox("Gender", gender_opts, key="f_gender")
            current_filters["Gender"] = sel_gender if sel_gender != "All" else None
        
        with fc9:
            student_opts = get_filter_options(df, "StudentName", current_filters)
            sel_student = st.selectbox("Student", student_opts, key="f_student")
            current_filters["StudentName"] = sel_student if sel_student != "All" else None
        
        filtered_df = df.copy()
        for col, val in current_filters.items():
            if val:
                filtered_df = filtered_df[filtered_df[col] == val]
        
        st.markdown("---")
        
        stat1, stat2, stat3, stat4 = st.columns(4)
        with stat1:
            st.metric("Records", len(filtered_df))
        with stat2:
            st.metric("Unique Courses", filtered_df[["CourseCode", "UniversityName"]].drop_duplicates().shape[0])
        with stat3:
            st.metric("Students", filtered_df["StudentName"].nunique())
        with stat4:
            st.metric("Instructors", filtered_df["InstructorName"].nunique())
        
        st.dataframe(filtered_df, use_container_width=True, height=400)
        
    except Exception as e:
        st.error(f"Could not load data: {str(e)}")

# ----------------------------------------------------------------------------
# TAB 2: DRILL-DOWN
# ----------------------------------------------------------------------------
with tab2:
    st.header("Drill-Down")
    
    if "breadcrumb" not in st.session_state:
        st.session_state.breadcrumb = []
    
    levels = ["University", "Faculty", "Department", "Course"]
    
    bc_cols = st.columns(len(levels) + 1)
    
    with bc_cols[0]:
        if st.button("All"):
            st.session_state.breadcrumb = []
            st.rerun()
    
    for i, item in enumerate(st.session_state.breadcrumb):
        with bc_cols[i + 1]:
            if st.button(f"> {item}", key=f"bc_{i}"):
                st.session_state.breadcrumb = st.session_state.breadcrumb[:i]
                st.rerun()
    
    st.markdown("---")
    
    try:
        depth = len(st.session_state.breadcrumb)
        
        if depth == 0:
            query = """
                SELECT c.UniversityName as Name, 
                       COUNT(DISTINCT c.CourseKey) as Courses,
                       COUNT(DISTINCT f.StudentKey) as Students,
                       COUNT(*) as Enrollments
                FROM FactCourseActivity f
                JOIN DimCourse c ON f.CourseKey = c.CourseKey
                GROUP BY c.UniversityName
                ORDER BY c.UniversityName
            """
            current_level = "University"
            
        elif depth == 1:
            uni = st.session_state.breadcrumb[0]
            query = f"""
                SELECT c.FacultyName as Name,
                       COUNT(DISTINCT c.CourseKey) as Courses,
                       COUNT(DISTINCT f.StudentKey) as Students,
                       COUNT(*) as Enrollments
                FROM FactCourseActivity f
                JOIN DimCourse c ON f.CourseKey = c.CourseKey
                WHERE c.UniversityName = '{uni}'
                GROUP BY c.FacultyName
                ORDER BY c.FacultyName
            """
            current_level = "Faculty"
            
        elif depth == 2:
            uni = st.session_state.breadcrumb[0]
            fac = st.session_state.breadcrumb[1]
            query = f"""
                SELECT c.DepartmentName as Name,
                       COUNT(DISTINCT c.CourseKey) as Courses,
                       COUNT(DISTINCT f.StudentKey) as Students,
                       COUNT(*) as Enrollments
                FROM FactCourseActivity f
                JOIN DimCourse c ON f.CourseKey = c.CourseKey
                WHERE c.UniversityName = '{uni}' AND c.FacultyName = '{fac}'
                GROUP BY c.DepartmentName
                ORDER BY c.DepartmentName
            """
            current_level = "Department"
            
        else:
            uni = st.session_state.breadcrumb[0]
            fac = st.session_state.breadcrumb[1]
            dept = st.session_state.breadcrumb[2]
            query = f"""
                SELECT c.CourseCode, c.CourseName,
                       i.InstructorName,
                       d.[Year], d.Semester,
                       COUNT(DISTINCT f.StudentKey) as Students
                FROM FactCourseActivity f
                JOIN DimCourse c ON f.CourseKey = c.CourseKey
                JOIN DimInstructor i ON f.InstructorKey = i.InstructorKey
                JOIN DimDate d ON f.DateKey = d.DateKey
                WHERE c.UniversityName = '{uni}' 
                  AND c.FacultyName = '{fac}'
                  AND c.DepartmentName = '{dept}'
                GROUP BY c.CourseCode, c.CourseName, i.InstructorName, d.[Year], d.Semester
                ORDER BY d.[Year] DESC, d.Semester, c.CourseCode
            """
            current_level = "Course"
        
        drill_df = run_query(query)
        
        if depth < 3:
            st.subheader(f"{current_level}")
            
            for idx, row in drill_df.iterrows():
                col1, col2, col3, col4 = st.columns([3, 1, 1, 1])
                with col1:
                    if st.button(row['Name'], key=f"drill_{idx}"):
                        st.session_state.breadcrumb.append(row['Name'])
                        st.rerun()
                with col2:
                    st.caption(f"{row['Courses']} courses")
                with col3:
                    st.caption(f"{row['Students']} students")
                with col4:
                    st.caption(f"{row['Enrollments']} enrollments")
        else:
            st.subheader("Courses")
            st.dataframe(drill_df, use_container_width=True)
            
    except Exception as e:
        st.error(f"Error: {str(e)}")

# ----------------------------------------------------------------------------
# TAB 3: TRENDS
# ----------------------------------------------------------------------------
with tab3:
    st.header("Trends Over Time")
    
    try:
        # Get instructor list for filter
        instructors = run_query("SELECT DISTINCT InstructorName FROM DimInstructor ORDER BY InstructorName")
        instructor_list = ["All Instructors"] + instructors["InstructorName"].tolist()
        
        selected_instructor = st.selectbox("Filter by Instructor", instructor_list, key="trend_inst")
        
        st.markdown("---")
        
        # Build query based on filter
        if selected_instructor == "All Instructors":
            trend_query = """
                SELECT 
                    d.[Year],
                    COUNT(DISTINCT c.CourseKey) as Courses,
                    COUNT(*) as Enrollments
                FROM FactCourseActivity f
                JOIN DimDate d ON f.DateKey = d.DateKey
                JOIN DimCourse c ON f.CourseKey = c.CourseKey
                GROUP BY d.[Year]
                ORDER BY d.[Year]
            """
        else:
            trend_query = f"""
                SELECT 
                    d.[Year],
                    COUNT(DISTINCT c.CourseKey) as Courses,
                    COUNT(*) as Enrollments
                FROM FactCourseActivity f
                JOIN DimDate d ON f.DateKey = d.DateKey
                JOIN DimCourse c ON f.CourseKey = c.CourseKey
                JOIN DimInstructor i ON f.InstructorKey = i.InstructorKey
                WHERE i.InstructorName = '{selected_instructor}'
                GROUP BY d.[Year]
                ORDER BY d.[Year]
            """
        
        trend_df = run_query(trend_query)
        
        if len(trend_df) > 0:
            # Prepare data for line chart
            chart_data = trend_df.set_index("Year")[["Courses", "Enrollments"]]
            
            st.subheader("Courses and Enrollments by Year")
            st.line_chart(chart_data)
            
            # Show data table
            st.subheader("Data")
            st.dataframe(trend_df, use_container_width=True)
        else:
            st.info("No data available")
            
    except Exception as e:
        st.error(f"Error: {str(e)}")

# Footer
st.markdown("---")
st.caption("CMPT 391 Project")