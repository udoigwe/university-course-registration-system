<?php
//database connect
require_once "DB_CONNECT.php";

//api functions
require_once "functions.php";

//response array
$response = array();

//check api call
if (isset($_GET["call"]) && !empty($_GET["call"])) {
    //sanitize call
    $call  = $mysqli->real_escape_string($_GET["call"]);

    switch ($call) {
        case "courses":

            if (checkAvailability(array("action"))) {
                $action = $mysqli->real_escape_string($_GET["action"]);

                if ($action === "get_all_courses") {
                    try {
                        $stmt = $mysqli->prepare("SELECT * FROM course ORDER BY courseCode ASC");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $courses = array();

                        while ($row = $result->fetch_assoc()) {
                            $courses[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["courses"] = $courses;
                    } catch (Exception $e) {
                        $response["error"] = true;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "get_course_specific_semester_registrations") {

                    if (checkAvailability(array("courseTitle", "semesterID"))) {
                        $courseTitle = $mysqli->real_escape_string($_GET["courseTitle"]);
                        $semesterID = $mysqli->real_escape_string($_GET["semesterID"]);

                        try {
                            $stmt = $mysqli->prepare("SELECT s.FirstName, s.LastName, s.Email 
                                FROM 
                                    Student s
                                JOIN 
                                    courseRegistration r 
                                ON 
                                    s.StudentID = r.StudentID
                                JOIN 
                                    CourseOffering co 
                                ON 
                                    r.courseCode = co.courseCode
                                JOIN 
                                    Course c 
                                ON 
                                    co.CourseCode = c.CourseCode
                                WHERE 
                                    c.CourseTitle = ? 
                                AND 
                                    co.SemesterID = ?;
                            ");
                            $stmt->bind_param("si", $courseTitle, $semesterID);
                            $stmt->execute();
                            $result = $stmt->get_result();
                            $registrations = array();

                            while ($row = $result->fetch_assoc()) {
                                $registrations[] = $row;
                            }

                            // Close the statement
                            $stmt->close();

                            $response["error"] = false;
                            $response["registrations"] = $registrations;
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "Please provide a Course Title and Semester ID";
                    }
                } elseif ($action === "get_department_specific_semester_registrations") {

                    if (checkAvailability(array("departmentName", "semesterID"))) {
                        $departmentName = $mysqli->real_escape_string($_GET["departmentName"]);
                        $semesterID = $mysqli->real_escape_string($_GET["semesterID"]);

                        try {
                            $stmt = $mysqli->prepare("SELECT c.CourseTitle, COUNT(r.StudentID) AS EnrolledStudents
                                FROM CourseOffering co
                                JOIN Course c ON co.CourseCode = c.CourseCode
                                JOIN Department d ON c.DepartmentCode = d.DepartmentCode
                                LEFT JOIN courseRegistration r ON co.CourseCode = r.CourseCode
                                WHERE d.DepartmentName = ? AND co.SemesterID = ?
                                GROUP BY c.CourseTitle
                                ORDER BY CourseTitle;
                            ");
                            $stmt->bind_param("si", $departmentName, $semesterID);
                            $stmt->execute();
                            $result = $stmt->get_result();
                            $registrations = array();

                            while ($row = $result->fetch_assoc()) {
                                $registrations[] = $row;
                            }

                            // Close the statement
                            $stmt->close();

                            $response["error"] = false;
                            $response["registrations"] = $registrations;
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "Please provide a Department Name and Semester ID";
                    }
                } elseif ($action === "get_cross_departmental_instructors") {

                    try {
                        $stmt = $mysqli->prepare("SELECT i.FirstName, i.LastName, COUNT(DISTINCT c.DepartmentCode) AS NumDepartments
                            FROM Instructor i
                            JOIN CourseOffering co ON i.InstructorID = co.InstructorID
                            JOIN Course c ON co.CourseCode = c.CourseCode
                            GROUP BY i.FirstName, i.LastName
                            HAVING COUNT(DISTINCT c.DepartmentCode) > 1;
                        ");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $instructors = array();

                        while ($row = $result->fetch_assoc()) {
                            $instructors[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["instructors"] = $instructors;
                    } catch (Exception $e) {
                        $response["error"] = true;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "get_program_average_course_stats") {

                    if (checkAvailability(array("programName"))) {
                        $programName = $mysqli->real_escape_string($_GET["programName"]);

                        try {
                            $stmt = $mysqli->prepare("SELECT dp.programName, Round(AVG(NumCourses)) AS AvgCoursesTaken
                                FROM (
                                    SELECT s.StudentID, COUNT(r.CourseCode) AS NumCourses
                                    FROM Student s
                                    JOIN DegreeProgram dp ON s.ProgramID = dp.ProgramID
                                    LEFT JOIN courseRegistration r ON s.StudentID = r.StudentID
                                    GROUP BY s.StudentID
                                ) AS StudentCourses
                                JOIN Student s ON StudentCourses.StudentID = s.StudentID
                                JOIN DegreeProgram dp ON s.ProgramID = dp.ProgramID
                                WHERE dp.programName = ?
                                GROUP BY dp.programName;
                            ");
                            $stmt->bind_param("s", $programName);
                            $stmt->execute();
                            $result = $stmt->get_result();
                            $stats = array();

                            while ($row = $result->fetch_assoc()) {
                                $stats[] = $row;
                            }

                            // Close the statement
                            $stmt->close();

                            $response["error"] = false;
                            $response["stats"] = $stats;
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "Please provide a Program Name";
                    }
                } elseif ($action === "get_course_prerequisites") {

                    try {
                        $stmt = $mysqli->prepare("SELECT 
                                c.courseCode AS CourseCode,
                                c.courseTitle AS CourseTitle,
                                p.courseCode AS PrerequisiteCourseCode,
                                p.courseTitle AS PrerequisiteCourseTitle
                            FROM 
                                prerequisite pr
                            JOIN 
                                course c ON pr.courseID = c.coursecode
                            JOIN 
                                course p ON pr.prerequisitecourseID = p.coursecode;
                        ");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $prerequisites = array();

                        while ($row = $result->fetch_assoc()) {
                            $prerequisites[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["prerequisites"] = $prerequisites;
                    } catch (Exception $e) {
                        $response["error"] = true;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "get_department_total_enrollments") {

                    try {
                        $stmt = $mysqli->prepare("SELECT d.DepartmentName, COUNT(r.StudentID) AS TotalEnrollment
                            FROM Department d
                            JOIN Course c ON d.DepartmentCode = c.DepartmentCode
                            JOIN CourseOffering co ON c.CourseCode = co.CourseCode
                            LEFT JOIN courseRegistration r ON co.CourseCode = r.CourseCode
                            GROUP BY d.DepartmentName;
                        ");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $enrollments = array();

                        while ($row = $result->fetch_assoc()) {
                            $enrollments[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["enrollments"] = $enrollments;
                    } catch (Exception $e) {
                        $response["error"] = false;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "get_multi_disciplinary_students") {

                    try {
                        $stmt = $mysqli->prepare("SELECT s.studentID, s.firstName, s.lastName, s.email
                            FROM student s
                            JOIN courseRegistration cr ON s.studentID = cr.studentID
                            JOIN course c ON cr.courseCode = c.courseCode
                            JOIN department d ON c.departmentCode = d.departmentCode
                            GROUP BY s.studentID
                            HAVING COUNT(DISTINCT d.departmentCode) > 1;
                        ");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $students = array();

                        while ($row = $result->fetch_assoc()) {
                            $students[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["students"] = $students;
                    } catch (Exception $e) {
                        $response["error"] = false;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "get_top_careers") {

                    try {
                        $stmt = $mysqli->prepare("SELECT ct.careerTitle, 
                            COUNT(cr.CourseCode) AS NumRecommendations,
                            GROUP_CONCAT(cr.CourseCode ORDER BY cr.CourseCode SEPARATOR ', ') AS RecommendedCourses
                            FROM CareerTag ct
                            JOIN CourseRecommendation cr ON ct.CareerTagID = cr.careerTagCode
                            GROUP BY ct.careerTitle
                            ORDER BY NumRecommendations DESC
                            LIMIT 3;
                        ");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $careers = array();

                        while ($row = $result->fetch_assoc()) {
                            $careers[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["careers"] = $careers;
                    } catch (Exception $e) {
                        $response["error"] = true;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "get_grade_distribution") {

                    try {
                        $stmt = $mysqli->prepare("SELECT
                            c.departmentCode,
                            c.courseCode,
                            d.programName,
                            COUNT(CASE WHEN cr.finalGrade = 'A' THEN 1 END) AS A_count,
                            COUNT(CASE WHEN cr.finalGrade = 'B' THEN 1 END) AS B_count,
                            COUNT(CASE WHEN cr.finalGrade = 'C' THEN 1 END) AS C_count,
                            COUNT(CASE WHEN cr.finalGrade = 'D' THEN 1 END) AS D_count,
                            COUNT(CASE WHEN cr.finalGrade = 'F' THEN 1 END) AS F_count,
                            COUNT(*) AS total_count
                            FROM
                                courseRegistration cr
                            JOIN
                                course c ON cr.courseCode = c.courseCode
                            JOIN
                                degreeProgram d ON c.departmentCode = d.departmentCode
                            GROUP BY
                                c.departmentCode, c.courseCode, d.programName
                            ORDER BY
                                c.departmentCode, c.courseCode;
                        ");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $grades = array();

                        while ($row = $result->fetch_assoc()) {
                            $grades[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["grades"] = $grades;
                    } catch (Exception $e) {
                        $response["error"] = true;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "get_all_course_registrations") {
                    try {
                        $stmt = $mysqli->prepare("SELECT a.*, b.firstName, b.lastName, b.classification, c.programName, d.semesterName, d.academicYear
                            FROM courseRegistration a
                            LEFT JOIN student b ON a.studentID = b.studentID
                            LEFT JOIN degreeProgram c ON b.programID = c.programID
                            LEFT JOIN semester d ON a.semesterID = d.semesterID
                            ORDER BY registrationID DESC
                        ");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $registrations = array();

                        while ($row = $result->fetch_assoc()) {
                            $registrations[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["registrations"] = $registrations;
                    } catch (Exception $e) {
                        $response["error"] = false;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "create_new_course_registration") {

                    if (checkAvailability(array("courseCode", "semesterID", "studentID"))) {
                        $courseCode = $mysqli->real_escape_string($_POST["courseCode"]);
                        $semesterID = $mysqli->real_escape_string($_POST["semesterID"]);
                        $studentID = $mysqli->real_escape_string($_POST["studentID"]);
                        $registrationDate = date("Y-m-d");

                        try {
                            //check if course is already registered for the selected student in the selected semester
                            $stmt = $mysqli->prepare("SELECT * FROM courseRegistration WHERE semesterID = ? AND studentID = ? AND courseCode = ? AND registrationStatus = 'Completed' LIMIT 1");
                            $stmt->bind_param("iss", $semesterID, $studentID, $courseCode);
                            $stmt->execute();
                            $result = $stmt->get_result();

                            if ($result->num_rows > 0) {
                                throw new Exception("Course already registered for the selected semester");
                            }

                            $stmt->close();

                            //get the last inserted course Registration ID
                            $stmt = $mysqli->prepare("SELECT MAX(registrationID) AS last_insert_registration_id FROM courseRegistration");
                            $stmt->execute();
                            $result = $stmt->get_result();
                            $row = $result->fetch_assoc();
                            $registrationID = "REG" . intval(substr($row['last_insert_registration_id'], 3)) + 1;
                            $stmt->close();

                            //prepare insert statement
                            $stmt = $mysqli->prepare("INSERT INTO courseRegistration ( registrationID, studentID, courseCode, semesterID, registrationDate)
                            VALUES (?, ?, ?, ?, ?)");
                            $stmt->bind_param("sssis", $registrationID, $studentID, $courseCode, $semesterID, $registrationDate);
                            $stmt->execute();
                            $stmt->close();

                            $response["error"] = false;
                            $response["message"] = "Course registered successfully";
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "All fields are required";
                    }
                } elseif ($action === "cancel_course_registration") {

                    if (checkAvailability(array("courseCode", "semesterID", "studentID"))) {
                        $courseCode = $mysqli->real_escape_string($_POST["courseCode"]);
                        $semesterID = $mysqli->real_escape_string($_POST["semesterID"]);
                        $studentID = $mysqli->real_escape_string($_POST["studentID"]);

                        try {
                            //check if record exists
                            $stmt = $mysqli->prepare("SELECT * FROM courseRegistration WHERE semesterID = ? AND studentID = ? AND courseCode = ? LIMIT 1");
                            $stmt->bind_param("iss", $semesterID, $studentID, $courseCode);
                            $stmt->execute();
                            $result = $stmt->get_result();

                            if ($result->num_rows === 0) {
                                throw new Exception("Record not found");
                            }

                            $row = $result->fetch_assoc();

                            //check if course is already canceled
                            if ($row["registrationStatus"] === "Canceled") {
                                throw new Exception("Course registration is already canceled");
                            }

                            $stmt->close();

                            //cancel the course registration
                            $stmt = $mysqli->prepare("CALL cancel_course_registration(?, ?, ?)");
                            $stmt->bind_param("ssi", $studentID, $courseCode, $semesterID);
                            $stmt->execute();
                            $stmt->close();

                            $response["error"] = false;
                            $response["message"] = "Course registration canceled successfully";
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "All fields are required";
                    }
                }
            }

        case "semesters":

            if (checkAvailability(array("action"))) {
                $action = $mysqli->real_escape_string($_GET["action"]);

                if ($action === "get_semesters") {
                    try {
                        $stmt = $mysqli->prepare("SELECT * FROM semester ORDER BY semesterID DESC");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $semesters = array();

                        while ($row = $result->fetch_assoc()) {
                            $semesters[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["semesters"] = $semesters;
                    } catch (Exception $e) {
                        $response["error"] = false;
                        $response["message"] = $e->getMessage();
                    }
                }
            }

        case "departments":

            if (checkAvailability(array("action"))) {
                $action = $mysqli->real_escape_string($_GET["action"]);

                if ($action === "get_departments") {
                    try {
                        $stmt = $mysqli->prepare("SELECT * FROM department ORDER BY departmentName ASC");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $departments = array();

                        while ($row = $result->fetch_assoc()) {
                            $departments[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["departments"] = $departments;
                    } catch (Exception $e) {
                        $response["error"] = true;
                        $response["message"] = $e->getMessage();
                    }
                }
            }

        case "degreePrograms":

            if (checkAvailability(array("action"))) {
                $action = $mysqli->real_escape_string($_GET["action"]);

                if ($action === "get_degree_programs") {
                    try {
                        $stmt = $mysqli->prepare("SELECT * FROM degreeprogram ORDER BY programName ASC");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $programs = array();

                        while ($row = $result->fetch_assoc()) {
                            $programs[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["programs"] = $programs;
                    } catch (Exception $e) {
                        $response["error"] = true;
                        $response["message"] = $e->getMessage();
                    }
                }
            }

        case "users":

            if (checkAvailability(array("action"))) {
                $action = $mysqli->real_escape_string($_GET["action"]);

                if ($action === "create_new_student") {
                    if (checkAvailability(array("programID", "firstName", "lastName", "email", "phoneNumber", "gender", "classification"))) {
                        $programID = $mysqli->real_escape_string($_POST["programID"]);
                        $firstName = $mysqli->real_escape_string($_POST["firstName"]);
                        $lastName = $mysqli->real_escape_string($_POST["lastName"]);
                        $email = $mysqli->real_escape_string($_POST["email"]);
                        $phoneNumber = $mysqli->real_escape_string($_POST["phoneNumber"]);
                        $gender = $mysqli->real_escape_string($_POST["gender"]);
                        $classification = $mysqli->real_escape_string($_POST["classification"]);

                        try {
                            //get the last inserted student ID
                            $stmt = $mysqli->prepare("SELECT MAX(studentID) AS last_insert_student_id FROM student");
                            $stmt->execute();
                            $result = $stmt->get_result();
                            $row = $result->fetch_assoc();
                            $studentID = "P" . intval(substr($row['last_insert_student_id'], 1)) + 1;
                            $stmt->close();

                            //prepare insert statement
                            $stmt = $mysqli->prepare("INSERT INTO student (studentID, programID, firstName, lastName, email, classification, phoneNumber, gender)
                            VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                            $stmt->bind_param("sissssss", $studentID, $programID, $firstName, $lastName, $email, $classification, $phoneNumber, $gender);
                            $stmt->execute();

                            // Close the statement
                            $stmt->close();

                            $response["error"] = false;
                            $response["message"] = "Student created successfully";
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "All fields are required";
                    }
                } elseif ($action === "get_students") {
                    try {
                        $stmt = $mysqli->prepare("SELECT a.*, b.programName
                            FROM student a
                            LEFT JOIN degreeProgram b ON a.programID = b.programID
                            ORDER BY a.studentID DESC;
                        ");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $students = array();

                        while ($row = $result->fetch_assoc()) {
                            $students[] = $row;
                        }

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["students"] = $students;
                    } catch (Exception $e) {
                        $response["error"] = false;
                        $response["message"] = $e->getMessage();
                    }
                } elseif ($action === "get_student") {
                    if (checkAvailability(array("studentID"))) {
                        $studentID = $mysqli->real_escape_string($_GET["studentID"]);

                        try {
                            $stmt = $mysqli->prepare("SELECT a.*, b.programName
                                FROM student a
                                LEFT JOIN degreeProgram b ON a.programID = b.programID
                                WHERE a.studentID = ?
                                LIMIT 1;
                            ");

                            $stmt->bind_param("s", $studentID);
                            $stmt->execute();
                            $result = $stmt->get_result();

                            if ($result->num_rows === 0) {
                                throw new Exception("Student record not found");
                            }

                            $row = $result->fetch_assoc();

                            // Close the statement
                            $stmt->close();

                            $response["error"] = false;
                            $response["student"] = $row;
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "Please provide a student ID";
                    }
                } elseif ($action === "update_student") {
                    if (checkAvailability(array("programID", "firstName", "lastName", "email", "phoneNumber", "gender", "classification", "studentID"))) {
                        $programID = $mysqli->real_escape_string($_POST["programID"]);
                        $firstName = $mysqli->real_escape_string($_POST["firstName"]);
                        $lastName = $mysqli->real_escape_string($_POST["lastName"]);
                        $email = $mysqli->real_escape_string($_POST["email"]);
                        $phoneNumber = $mysqli->real_escape_string($_POST["phoneNumber"]);
                        $gender = $mysqli->real_escape_string($_POST["gender"]);
                        $classification = $mysqli->real_escape_string($_POST["classification"]);
                        $studentID = $mysqli->real_escape_string($_POST["studentID"]);

                        try {
                            //check if student exists
                            $stmt = $mysqli->prepare("SELECT * FROM student WHERE studentID = ? LIMIT 1");
                            $stmt->bind_param("s", $studentID);
                            $stmt->execute();
                            $result = $stmt->get_result();

                            if ($result->num_rows === 0) {
                                throw new Exception("Student record not found");
                            }

                            //update student record
                            $stmt = $mysqli->prepare("CALL update_student_info(?, ?, ?, ?, ?, ?, ?, ?);");
                            $stmt->bind_param("sssssssi", $studentID, $firstName, $lastName, $email, $classification, $phoneNumber, $gender, $programID);
                            $stmt->execute();
                            $stmt->close();

                            $response["error"] = false;
                            $response["message"] = "Student record updated successfully";
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "All fields are required";
                    }
                } elseif ($action === "delete_student") {
                    if (checkAvailability(array("studentID"))) {
                        $studentID = $mysqli->real_escape_string($_GET["studentID"]);

                        try {
                            //check if student exists
                            $stmt = $mysqli->prepare("SELECT * FROM student WHERE studentID = ? LIMIT 1");
                            $stmt->bind_param("s", $studentID);
                            $stmt->execute();
                            $result = $stmt->get_result();

                            if ($result->num_rows === 0) {
                                throw new Exception("Student record not found");
                            }

                            $stmt->close();

                            //delete student record
                            $stmt = $mysqli->prepare("DELETE FROM student WHERE studentID = ?");
                            $stmt->bind_param("s", $studentID);
                            $stmt->execute();
                            $stmt->close();

                            $response["error"] = false;
                            $response["message"] = "Student record deleted successfully";
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "All fields are required";
                    }
                } elseif ($action === "get_student_gpa") {
                    if (checkAvailability(array("studentID"))) {
                        $studentID = $mysqli->real_escape_string($_GET["studentID"]);

                        try {
                            $sql = "SET @p0='" . $studentID . "';";
                            $sql .= "CALL calculate_student_gpa(@p0, @p1);";
                            $sql .= "SELECT @p1 AS p_gpa;";
                            $gpa;

                            // Execute the multi-query
                            $mysqli->multi_query($sql);

                            do {
                                // Fetch the result (if any)
                                if ($result = $mysqli->store_result()) {
                                    while ($row = $result->fetch_assoc()) {
                                        $gpa = $row['p_gpa'];
                                    }
                                    $result->free();
                                    $response["error"] = false;
                                    $response["gpa"] = $gpa;
                                }
                            } while ($mysqli->more_results() && $mysqli->next_result());
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "Please provide a Student ID";
                    }
                } elseif ($action === "get_student_transcript") {
                    if (checkAvailability((array("studentID")))) {
                        $studentID = $_GET["studentID"];
                        $query = "CALL generate_student_transcript(?);";
                        $transcript = [];

                        try {
                            // Prepare the statement
                            $stmt = $mysqli->prepare($query);

                            // Bind the parameter
                            $stmt->bind_param("s", $studentID);
                            $stmt->execute();
                            $result = $stmt->get_result();

                            while ($row = $result->fetch_assoc()) {
                                $transcript[] = $row;
                            }

                            $response["error"] = false;
                            $response["transcript"] = $transcript;
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    } else {
                        $response["error"] = true;
                        $response["message"] = "Please provide a Student ID";
                    }
                }
            }

        case "dashboard":

            if (checkAvailability(array("action"))) {
                $action = $mysqli->real_escape_string($_GET["action"]);

                if ($action === "get_dashboard") {

                    try {
                        $stmt = $mysqli->prepare("CALL GetDashboard();");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $row = $result->fetch_assoc();

                        // Close the statement
                        $stmt->close();

                        $response["error"] = false;
                        $response["dashboard"] = $row;
                    } catch (Exception $e) {
                        $response["error"] = false;
                        $response["message"] = $e->getMessage();
                    }
                }
            }

        case "career":

            if (checkAvailability(array("action"))) {
                $action = $mysqli->real_escape_string($_GET["action"]);

                if ($action === "add_career_tag") {
                    if (checkAvailability(array("careerTitle"))) {
                        $careerTitle = $mysqli->real_escape_string(($_POST["careerTitle"]));

                        try {
                            //get the last inserted career ID
                            $stmt = $mysqli->prepare("SELECT MAX(careerTagID) AS last_insert_career_tag_id FROM careertag");
                            $stmt->execute();
                            $result = $stmt->get_result();
                            $row = $result->fetch_assoc();
                            $careerTagID = intval($row['last_insert_career_tag_id']) + 1;
                            $stmt->close();

                            $stmt = $mysqli->prepare("CALL add_career_tag(?, ?);");
                            $stmt->bind_param("is", $careerTagID, $careerTitle);
                            $stmt->execute();
                            $result = $stmt->get_result();

                            // Close the statement
                            $stmt->close();

                            $response["error"] = false;
                            $response["message"] = "Career tag added successfully";
                        } catch (Exception $e) {
                            $response["error"] = true;
                            $response["message"] = $e->getMessage();
                        }
                    }
                } elseif ($action === "get_career_tags") {
                    try {
                        $stmt = $mysqli->prepare("SELECT * FROM careertag ORDER BY careerTagID DESC");
                        $stmt->execute();
                        $result = $stmt->get_result();
                        $careerTags = [];

                        while ($row = $result->fetch_assoc()) {
                            $careerTags[] = $row;
                        }

                        $response["error"] = false;
                        $response["careerTags"] = $careerTags;
                    } catch (Exception $e) {
                        $response["error"] = true;
                        $response["message"] = $e->getMessage();
                    }
                }
            }
    }
} else {
    $response["error"] = true;
    $response["message"] = "No API call";
}

//return json encoded response
echo json_encode($response);
