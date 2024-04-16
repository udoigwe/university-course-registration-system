-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 16, 2024 at 05:30 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ucrs`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_career_tag` (IN `p_careerTagID` INT(11), IN `p_careerTitle` VARCHAR(255))   BEGIN
    INSERT INTO careerTag (careerTagID, careerTitle)
    VALUES (p_careerTagID, p_careerTitle)
    ON DUPLICATE KEY UPDATE careerTitle = p_careerTitle;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `assign_degree_advisors` ()   BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE v_programID INT;
    DECLARE v_instructorID VARCHAR(10);

    DECLARE program_cursor CURSOR FOR
        SELECT programID
        FROM degreeProgram
        WHERE degreeAdvisor IS NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN program_cursor;
    program_loop: LOOP
        FETCH program_cursor INTO v_programID;
        IF done THEN
            LEAVE program_loop;
        END IF;

        SELECT i.instructorID
        INTO v_instructorID
        FROM instructor i
        INNER JOIN department d ON i.departmentCode = d.departmentCode
        INNER JOIN degreeProgram dp ON d.departmentCode = dp.departmentCode
        WHERE dp.programID = v_programID
        ORDER BY RAND()
        LIMIT 1;

        UPDATE degreeProgram
        SET degreeAdvisor = v_instructorID
        WHERE programID = v_programID;
    END LOOP program_loop;
    CLOSE program_cursor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `calculate_student_gpa` (IN `p_studentID` VARCHAR(10), OUT `p_gpa` DECIMAL(4,2))   BEGIN
    DECLARE total_credits INT DEFAULT 0;
    DECLARE total_points DECIMAL(10,2) DEFAULT 0;

    SELECT SUM(c.creditUnit), SUM(c.creditUnit * CASE finalGrade
            WHEN 'A' THEN 4
            WHEN 'B' THEN 3
            WHEN 'C' THEN 2
            WHEN 'D' THEN 1
            ELSE 0
        END)
    INTO total_credits, total_points
    FROM courseRegistration cr
    JOIN course c ON cr.courseCode = c.courseCode
    WHERE cr.studentID = p_studentID
    AND cr.registrationStatus = 'Completed';

    IF total_credits > 0 THEN
        SET p_gpa = total_points / total_credits;
    ELSE
        SET p_gpa = 0;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cancel_course_registration` (IN `p_studentID` VARCHAR(10), IN `p_courseCode` VARCHAR(10), IN `p_semesterID` INT)   BEGIN
    DECLARE v_currentDate DATE;

    SELECT CURDATE() INTO v_currentDate;

    UPDATE courseRegistration
    SET registrationStatus = 'Canceled',
        withdrawalDate = v_currentDate
    WHERE studentID = p_studentID
      AND courseCode = p_courseCode
      AND semesterID = p_semesterID;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_course_offerings` (IN `p_semesterID` INT)   BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE v_courseCode VARCHAR(10);
    DECLARE v_instructorID VARCHAR(10);
    DECLARE course_cursor CURSOR FOR
        SELECT c.courseCode, i.instructorID
        FROM course c
        INNER JOIN department d ON c.departmentCode = d.departmentCode
        INNER JOIN instructor i ON d.departmentCode = i.departmentCode
        WHERE i.position IN ('Professor', 'Associate Professor', 'Assistant Professor')
        ORDER BY RAND();

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN course_cursor;
    course_loop: LOOP
        FETCH course_cursor INTO v_courseCode, v_instructorID;
        IF done THEN
            LEAVE course_loop;
        END IF;

        INSERT INTO courseOffering (courseCode, semesterID, instructorID)
        VALUES (v_courseCode, p_semesterID, v_instructorID);
    END LOOP course_loop;
    CLOSE course_cursor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_student_transcript` (IN `p_studentID` VARCHAR(10))   BEGIN
    SELECT s.studentID, s.firstName, s.lastName, s.classification, c.courseTitle, c.creditUnit, cr.finalGrade
    FROM student s
    JOIN courseRegistration cr ON s.studentID = cr.studentID
    JOIN course c ON cr.courseCode = c.courseCode
    WHERE s.studentID = p_studentID
    AND cr.registrationStatus = 'Completed'
    ORDER BY cr.registrationDate;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GetDashboard` ()   BEGIN
    DECLARE total_students INT;
    DECLARE total_courses INT;
    DECLARE total_departments INT;
    DECLARE total_programs INT;
    DECLARE total_instructors INT;

    -- Get count of students
    SELECT COUNT(*) INTO total_students FROM student;

    -- Get count of courses
    SELECT COUNT(*) INTO total_courses FROM course;

    -- Get count of departments
    SELECT COUNT(*) INTO total_departments FROM department;
    
    -- Get count of programs
    SELECT COUNT(*) INTO total_programs FROM degreeprogram;
    
    -- Get count of instructors
    SELECT COUNT(*) INTO total_instructors FROM instructor;

    -- Return the counts
    SELECT total_students AS student_count, total_courses AS course_count, total_departments AS department_count, total_programs AS program_count, total_instructors AS instructor_count;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_student_info` (IN `p_studentID` VARCHAR(10), IN `p_firstName` VARCHAR(50), IN `p_lastName` VARCHAR(50), IN `p_email` VARCHAR(100), IN `p_classification` VARCHAR(50), IN `p_phoneNumber` VARCHAR(20), IN `p_gender` VARCHAR(15), IN `p_programID` INT(11) UNSIGNED)   BEGIN
    UPDATE student
    SET firstName = p_firstName,
        lastName = p_lastName,
        email = p_email,
        classification = p_classification,
        phoneNumber = p_phoneNumber,
        programID = p_programID,
        gender = p_gender
    WHERE studentID = p_studentID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `careertag`
--

CREATE TABLE `careertag` (
  `careerTagID` int(11) NOT NULL,
  `careerTitle` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `careertag`
--

INSERT INTO `careertag` (`careerTagID`, `careerTitle`) VALUES
(7, 'Biotechnology'),
(6, 'Cybersecurity'),
(1, 'Data Science'),
(9, 'Digital Electronics'),
(5, 'Education Technology'),
(11, 'Engineering'),
(2, 'Environmental Chemistry'),
(8, 'Mechanical Design'),
(4, 'Renewable Energy'),
(3, 'Software Development'),
(10, 'Special Education');

-- --------------------------------------------------------

--
-- Table structure for table `course`
--

CREATE TABLE `course` (
  `courseCode` varchar(10) NOT NULL,
  `departmentCode` varchar(10) NOT NULL,
  `courseTitle` varchar(255) NOT NULL,
  `creditUnit` int(11) NOT NULL CHECK (`creditUnit` > 0),
  `maxEnrollment` int(11) NOT NULL CHECK (`maxEnrollment` >= 5 and `maxEnrollment` <= 35)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `course`
--

INSERT INTO `course` (`courseCode`, `departmentCode`, `courseTitle`, `creditUnit`, `maxEnrollment`) VALUES
('CENG301', 'CENG', 'Digital Systems Design', 4, 20),
('CENG401', 'CENG', 'Microprocessors', 4, 20),
('CENG501', 'CENG', 'Embedded Systems', 4, 20),
('CENG601', 'CENG', 'Signal Processing', 4, 20),
('CENG701', 'CENG', 'Control Systems', 4, 20),
('CENG801', 'CENG', 'Computer Architecture', 4, 20),
('CHEM101', 'CHEM', 'Introduction to Chemistry', 3, 30),
('CHEM201', 'CHEM', 'Organic Chemistry I', 4, 30),
('CHEM301', 'CHEM', 'Physical Chemistry', 3, 25),
('CHEM401', 'CHEM', 'Analytical Chemistry', 3, 25),
('CHEM501', 'CHEM', 'Inorganic Chemistry', 3, 25),
('CHEM601', 'CHEM', 'Environmental Chemistry', 3, 30),
('CIS201', 'CIS', 'Fundamentals of Information Systems', 4, 25),
('CIS301', 'CIS', 'Database Management Systems', 4, 25),
('CIS401', 'CIS', 'Computer Networks', 4, 25),
('CIS501', 'CIS', 'Software Engineering', 4, 25),
('CIS601', 'CIS', 'Information Security', 4, 25),
('CIS701', 'CIS', 'Human-Computer Interaction', 4, 25),
('CIS801', 'CIS', 'Data Structure and Algorithm', 4, 25),
('CIS901', 'CIS', 'Data Communication', 4, 30),
('EDU1001', 'EDU', 'Special Education Fundamentals', 3, 25),
('EDU501', 'EDU', 'Principles of Education', 3, 30),
('EDU601', 'EDU', 'Curriculum Development', 3, 30),
('EDU701', 'EDU', 'Educational Psychology', 3, 25),
('EDU801', 'EDU', 'Instructional Technology', 3, 30),
('EDU901', 'EDU', 'Assessment in Education', 3, 25),
('ME401', 'ME', 'Thermodynamics', 3, 35),
('ME501', 'ME', 'Fluid Mechanics', 3, 35),
('ME601', 'ME', 'Machine Design', 3, 30),
('ME701', 'ME', 'Dynamics', 3, 35),
('ME801', 'ME', 'Heat Transfer', 3, 30),
('ME901', 'ME', 'Advanced Mechanics of Materials', 3, 30);

-- --------------------------------------------------------

--
-- Table structure for table `courseoffering`
--

CREATE TABLE `courseoffering` (
  `courseCode` varchar(10) NOT NULL,
  `semesterID` int(11) NOT NULL,
  `instructorID` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courseoffering`
--

INSERT INTO `courseoffering` (`courseCode`, `semesterID`, `instructorID`) VALUES
('CHEM101', 1, 'INS0001'),
('CHEM101', 3, 'INS0001'),
('CHEM601', 4, 'INS0001'),
('CIS201', 1, 'INS0002'),
('CIS601', 4, 'INS0002'),
('CENG301', 1, 'INS0003'),
('ME401', 1, 'INS0004'),
('EDU501', 1, 'INS0005'),
('CHEM201', 2, 'INS0006'),
('CHEM501', 3, 'INS0006'),
('CIS301', 2, 'INS0007'),
('CIS801', 2, 'INS0007'),
('CIS901', 2, 'INS0007'),
('CENG401', 2, 'INS0008'),
('ME501', 2, 'INS0009'),
('ME501', 3, 'INS0009'),
('ME601', 4, 'INS0009'),
('ME901', 3, 'INS0009'),
('EDU601', 2, 'INS0010'),
('CHEM301', 2, 'INS0011'),
('CHEM301', 3, 'INS0011'),
('CIS401', 3, 'INS0012'),
('CENG501', 3, 'INS0013'),
('ME401', 2, 'INS0014'),
('ME601', 3, 'INS0014'),
('ME801', 3, 'INS0014'),
('EDU701', 3, 'INS0015'),
('CHEM101', 4, 'INS0016'),
('CHEM401', 4, 'INS0016'),
('CHEM601', 1, 'INS0016'),
('CIS301', 3, 'INS0017'),
('CIS501', 4, 'INS0017'),
('CIS601', 2, 'INS0017'),
('CENG601', 4, 'INS0018'),
('ME701', 4, 'INS0019'),
('EDU801', 4, 'INS0020'),
('CHEM201', 4, 'INS0021'),
('CHEM501', 1, 'INS0021'),
('CIS201', 4, 'INS0022'),
('CIS501', 1, 'INS0022'),
('CIS601', 1, 'INS0022'),
('CENG701', 1, 'INS0023'),
('ME801', 1, 'INS0024'),
('EDU901', 1, 'INS0025'),
('CHEM301', 4, 'INS0026'),
('CHEM601', 2, 'INS0026'),
('CIS701', 2, 'INS0027'),
('CIS901', 4, 'INS0027'),
('CENG801', 2, 'INS0028'),
('ME601', 2, 'INS0029'),
('ME801', 4, 'INS0029'),
('ME901', 1, 'INS0029'),
('ME901', 2, 'INS0029'),
('EDU1001', 2, 'INS0030');

-- --------------------------------------------------------

--
-- Table structure for table `courserecommendation`
--

CREATE TABLE `courserecommendation` (
  `courseCode` varchar(10) NOT NULL,
  `careerTagCode` int(11) NOT NULL,
  `recommendationWeight` int(11) NOT NULL CHECK (`recommendationWeight` between 1 and 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courserecommendation`
--

INSERT INTO `courserecommendation` (`courseCode`, `careerTagCode`, `recommendationWeight`) VALUES
('CENG301', 9, 8),
('CENG401', 3, 7),
('CENG601', 9, 7),
('CENG701', 3, 8),
('CHEM101', 2, 5),
('CHEM201', 7, 8),
('CHEM301', 2, 7),
('CHEM601', 2, 10),
('CIS201', 3, 7),
('CIS301', 6, 9),
('CIS501', 3, 9),
('CIS601', 6, 10),
('EDU1001', 10, 10),
('EDU501', 5, 6),
('EDU601', 5, 7),
('EDU701', 10, 9),
('ME401', 4, 7),
('ME501', 4, 8),
('ME701', 8, 8),
('ME901', 8, 9);

-- --------------------------------------------------------

--
-- Table structure for table `courseregistration`
--

CREATE TABLE `courseregistration` (
  `registrationID` varchar(10) NOT NULL,
  `studentID` varchar(10) NOT NULL,
  `courseCode` varchar(10) NOT NULL,
  `semesterID` int(11) NOT NULL,
  `registrationDate` date NOT NULL,
  `withdrawalDate` date DEFAULT NULL,
  `registrationStatus` varchar(50) NOT NULL DEFAULT 'Completed',
  `finalGrade` char(1) DEFAULT NULL CHECK (`finalGrade` in ('A','B','C','D','E','F'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courseregistration`
--

INSERT INTO `courseregistration` (`registrationID`, `studentID`, `courseCode`, `semesterID`, `registrationDate`, `withdrawalDate`, `registrationStatus`, `finalGrade`) VALUES
('REG23001', 'P22719811', 'CHEM101', 1, '2023-08-15', '2023-12-15', 'Completed', 'A'),
('REG23002', 'P22455511', 'CIS201', 1, '2023-08-15', '2023-12-15', 'Completed', 'B'),
('REG230021', 'P22728768', 'CHEM501', 1, '2023-08-15', '2023-12-15', 'Completed', 'B'),
('REG230022', 'P22455515', 'CIS601', 1, '2023-08-15', '2023-12-15', 'Completed', 'C'),
('REG230023', 'P22234463', 'CENG701', 1, '2023-08-15', '2023-12-15', 'Completed', 'A'),
('REG230024', 'P22998747', 'ME801', 1, '2023-08-15', '2023-12-15', 'Completed', 'B'),
('REG230025', 'P22876547', 'EDU901', 1, '2023-08-15', '2023-12-15', 'Completed', 'D'),
('REG230026', 'P22455511', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230027', 'P22455514', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230028', 'P23019801', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230029', 'P23019802', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG23003', 'P22234459', 'CENG301', 1, '2023-08-15', '2023-12-15', 'Completed', 'B'),
('REG230030', 'P23019803', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230031', 'P23019804', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230032', 'P23019805', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230033', 'P23019806', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230034', 'P23019807', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230035', 'P23019808', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230036', 'P23019809', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230037', 'P23019810', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230038', 'P23019811', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230039', 'P23019812', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG23004', 'P22998743', 'ME401', 1, '2023-08-15', '2023-12-15', 'Completed', 'C'),
('REG230040', 'P23019813', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230041', 'P23019814', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230042', 'P23019815', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230043', 'P23019816', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230044', 'P23019817', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230045', 'P23019818', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230046', 'P23019819', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230047', 'P23019820', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230048', 'P22455511', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230049', 'P22455514', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG23005', 'P22876543', 'EDU501', 1, '2023-08-15', '2023-12-15', 'Completed', 'A'),
('REG230050', 'P23019801', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230051', 'P23019802', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230052', 'P23019803', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230053', 'P23019810', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230054', 'P23019809', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230055', 'P23019808', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230056', 'P23019807', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230057', 'P23019805', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'C'),
('REG230058', 'P23019806', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230059', 'P23019804', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230060', 'P22455511', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230061', 'P22455514', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230062', 'P23019801', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230063', 'P23019802', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230064', 'P23019803', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230065', 'P23019810', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230066', 'P23019809', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230067', 'P23019808', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230068', 'P22455511', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230069', 'P22455514', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230070', 'P23019801', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230071', 'P23019802', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230072', 'P23019803', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230073', 'P23019810', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230074', 'P23019809', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG240010', 'P22876544', 'EDU601', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG240011', 'P22728766', 'CHEM301', 3, '2024-06-05', '2024-08-20', 'Completed', 'B'),
('REG240012', 'P22455513', 'CIS401', 3, '2024-06-05', '2024-08-20', 'Completed', 'C'),
('REG240013', 'P22234461', 'CENG501', 3, '2024-06-05', '2024-08-20', 'Completed', 'A'),
('REG240014', 'P22998745', 'ME601', 3, '2024-06-05', '2024-08-20', 'Completed', 'B'),
('REG240015', 'P22876545', 'EDU701', 3, '2024-06-05', '2024-08-20', 'Completed', 'A'),
('REG240016', 'P22728767', 'CHEM401', 4, '2024-08-15', '2024-12-15', 'Completed', 'A'),
('REG240017', 'P22455514', 'CIS501', 4, '2024-08-15', '2024-12-15', 'Completed', 'B'),
('REG240018', 'P22234462', 'CENG601', 4, '2024-08-15', '2024-12-15', 'Completed', 'C'),
('REG240019', 'P22998746', 'ME701', 4, '2024-08-15', '2024-12-15', 'Completed', 'B'),
('REG240020', 'P22876546', 'EDU801', 4, '2024-08-15', '2024-12-15', 'Completed', 'A'),
('REG24006', 'P22728765', 'CHEM201', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG24007', 'P22455512', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG24008', 'P22234460', 'CENG401', 2, '2024-01-10', '2024-05-15', 'Completed', 'C'),
('REG24009', 'P22998744', 'ME501', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG24010', 'P23019917', 'CENG301', 4, '2024-04-16', '2024-04-16', 'Canceled', NULL),
('REG24011', 'P23019919', 'CENG301', 4, '2024-04-16', NULL, 'Completed', NULL),
('REG24012', 'P23019918', 'CENG301', 4, '2024-04-16', '2024-04-16', 'Canceled', NULL);

--
-- Triggers `courseregistration`
--
DELIMITER $$
CREATE TRIGGER `check_credit_unit_limit` BEFORE INSERT ON `courseregistration` FOR EACH ROW BEGIN
    DECLARE total_credits INT;

    SELECT SUM(c.creditUnit) INTO total_credits
    FROM courseRegistration cr
    JOIN course c ON cr.courseCode = c.courseCode
    WHERE cr.studentID = NEW.studentID
    AND cr.semesterID = NEW.semesterID
    AND cr.registrationStatus NOT IN ('Canceled');

    IF total_credits + (SELECT creditUnit FROM course WHERE courseCode = NEW.courseCode) > 12 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student has exceeded the maximum credit unit limit for the semester.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_enrollment_limit` BEFORE INSERT ON `courseregistration` FOR EACH ROW BEGIN
    DECLARE current_enrollment INT;

    SELECT COUNT(*) INTO current_enrollment
    FROM courseRegistration
    WHERE courseCode = NEW.courseCode
    AND semesterID = NEW.semesterID;

    IF current_enrollment >= (
        SELECT maxEnrollment
        FROM course
        WHERE courseCode = NEW.courseCode
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course enrollment limit has been reached.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `check_prerequisite` BEFORE INSERT ON `courseregistration` FOR EACH ROW BEGIN
    IF EXISTS (
        SELECT 1
        FROM prerequisite p
        WHERE p.courseID = NEW.courseCode
        AND p.prerequisitecourseID NOT IN (
            SELECT courseCode
            FROM courseRegistration
            WHERE studentID = NEW.studentID
            AND registrationStatus = 'Completed'
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student must complete prerequisite courses before registering for this course.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `courseregistration2`
--

CREATE TABLE `courseregistration2` (
  `registrationID` varchar(50) NOT NULL,
  `studentID` varchar(50) NOT NULL,
  `courseCode` varchar(50) NOT NULL,
  `semesterID` int(11) NOT NULL,
  `registrationDate` date NOT NULL,
  `withdrawalDate` date NOT NULL,
  `registrationStatus` varchar(255) NOT NULL,
  `finalGrade` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `courseregistration2`
--

INSERT INTO `courseregistration2` (`registrationID`, `studentID`, `courseCode`, `semesterID`, `registrationDate`, `withdrawalDate`, `registrationStatus`, `finalGrade`) VALUES
('REG23001', 'P22719811', 'CHEM101', 1, '2023-08-15', '2023-12-15', 'Completed', 'A'),
('REG23002', 'P22455511', 'CIS201', 1, '2023-08-15', '2023-12-15', 'Completed', 'B'),
('REG23003', 'P22234459', 'CENG301', 1, '2023-08-15', '2023-12-15', 'Completed', 'B'),
('REG23004', 'P22998743', 'ME401', 1, '2023-08-15', '2023-12-15', 'Completed', 'C'),
('REG23005', 'P22876543', 'EDU501', 1, '2023-08-15', '2023-12-15', 'Completed', 'A'),
('REG24006', 'P22728765', 'CHEM201', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG24007', 'P22455512', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG24008', 'P22234460', 'CENG401', 2, '2024-01-10', '2024-05-15', 'Completed', 'C'),
('REG24009', 'P22998744', 'ME501', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG240010', 'P22876544', 'EDU601', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG240011', 'P22728766', 'CHEM301', 3, '2024-06-05', '2024-08-20', 'Completed', 'B'),
('REG240012', 'P22455513', 'CIS401', 3, '2024-06-05', '2024-08-20', 'Completed', 'C'),
('REG240013', 'P22234461', 'CENG501', 3, '2024-06-05', '2024-08-20', 'Completed', 'A'),
('REG240014', 'P22998745', 'ME601', 3, '2024-06-05', '2024-08-20', 'Completed', 'B'),
('REG240015', 'P22876545', 'EDU701', 3, '2024-06-05', '2024-08-20', 'Completed', 'A'),
('REG240016', 'P22728767', 'CHEM401', 4, '2024-08-15', '2024-12-15', 'Completed', 'A'),
('REG240017', 'P22455514', 'CIS501', 4, '2024-08-15', '2024-12-15', 'Completed', 'B'),
('REG240018', 'P22234462', 'CENG601', 4, '2024-08-15', '2024-12-15', 'Completed', 'C'),
('REG240019', 'P22998746', 'ME701', 4, '2024-08-15', '2024-12-15', 'Completed', 'B'),
('REG240020', 'P22876546', 'EDU801', 4, '2024-08-15', '2024-12-15', 'Completed', 'A'),
('REG230021', 'P22728768', 'CHEM501', 1, '2023-08-15', '2023-12-15', 'Completed', 'B'),
('REG230022', 'P22455515', 'CIS601', 1, '2023-08-15', '2023-12-15', 'Completed', 'C'),
('REG230023', 'P22234463', 'CENG701', 1, '2023-08-15', '2023-12-15', 'Completed', 'A'),
('REG230024', 'P22998747', 'ME801', 1, '2023-08-15', '2023-12-15', 'Completed', 'B'),
('REG230025', 'P22876547', 'EDU901', 1, '2023-08-15', '2023-12-15', 'Completed', 'D'),
('REG230026', 'P22455511', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230027', 'P22455514', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230028', 'P23019801', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230029', 'P23019802', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230030', 'P23019803', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230031', 'P23019804', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230032', 'P23019805', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230033', 'P23019806', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230034', 'P23019807', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230035', 'P23019808', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230036', 'P23019809', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230037', 'P23019810', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230038', 'P23019811', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230039', 'P23019812', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230040', 'P23019813', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230041', 'P23019814', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230042', 'P23019815', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230043', 'P23019816', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230044', 'P23019817', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230045', 'P23019818', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230046', 'P23019819', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230047', 'P23019820', 'CIS301', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230048', 'P22455511', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230049', 'P22455514', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230050', 'P23019801', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230051', 'P23019802', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230052', 'P23019803', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230053', 'P23019810', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230054', 'P23019809', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230055', 'P23019808', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230056', 'P23019807', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230058', 'P23019806', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230057', 'P23019805', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'C'),
('REG230059', 'P23019804', 'CIS801', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230060', 'P22455511', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230061', 'P22455514', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230062', 'P23019801', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230063', 'P23019802', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230064', 'P23019803', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230065', 'P23019810', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230066', 'P23019809', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230067', 'P23019808', 'CIS901', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230068', 'P22455511', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'B'),
('REG230069', 'P22455514', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230070', 'P23019801', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230071', 'P23019802', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230072', 'P23019803', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230073', 'P23019810', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A'),
('REG230074', 'P23019809', 'CIS701', 2, '2024-01-10', '2024-05-15', 'Completed', 'A');

-- --------------------------------------------------------

--
-- Table structure for table `degreeprogram`
--

CREATE TABLE `degreeprogram` (
  `programID` int(11) NOT NULL,
  `programName` varchar(255) NOT NULL,
  `programDescription` text DEFAULT NULL,
  `departmentCode` varchar(10) NOT NULL,
  `degreeLevel` varchar(50) NOT NULL,
  `degreeAdvisor` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `degreeprogram`
--

INSERT INTO `degreeprogram` (`programID`, `programName`, `programDescription`, `departmentCode`, `degreeLevel`, `degreeAdvisor`) VALUES
(1, 'BS in Chemistry', 'The Bachelor of Science in Chemistry provides a strong foundation in the principles of chemistry. It prepares students for careers in the chemical industry or for advanced studies in chemistry.', 'CHEM', 'Bachelor', 'INS0001'),
(2, 'MS in Computer Information Systems', 'This program offers advanced education in the areas of software development, database systems, and computer networks, preparing students for technology leadership roles.', 'CIS', 'Master', 'INS0002'),
(3, 'BS in Computer Engineering', 'The Bachelor of Science in Computer Engineering integrates electrical engineering and computer science to prepare students for the development of computer systems.', 'CENG', 'Bachelor', 'INS0003'),
(4, 'MS in Mechanical Engineering', 'Graduate program focused on the design, analysis, and manufacture of machines and mechanical systems.', 'ME', 'Master', 'INS0004'),
(5, 'MEd in Education', 'Designed for educators seeking to advance their understanding of instructional methods, educational theory, and student development.', 'EDU', 'Master', 'INS0005'),
(6, 'PhD in Chemistry', 'Doctoral program focusing on research in various branches of chemistry including organic, inorganic, physical, and analytical chemistry.', 'CHEM', 'PhD', 'INS0006'),
(7, 'BS in Education', 'Undergraduate program preparing students for teaching careers at the elementary, middle, and high school levels.', 'EDU', 'Bachelor', 'INS0007'),
(8, 'BS in Mechanical Engineering', 'The Bachelor of Science in Mechanical Engineering prepares students for careers in the design and manufacturing sectors.', 'ME', 'Bachelor', 'INS0008'),
(9, 'PhD in Computer Engineering', 'Advanced program aimed at research and development in the field of computer engineering.', 'CENG', 'PhD', 'INS0009'),
(10, 'MS in Education', 'Graduate program designed to deepen the educational, administrative, and curriculum development skills of educators.', 'EDU', 'Master', 'INS0010'),
(11, 'BS in Information Technology', 'This program covers the study of the utilization of computers and telecommunications to retrieve, store, and transmit information.', 'CIS', 'Bachelor', 'INS0011'),
(12, 'PhD in Mechanical Engineering', 'This doctoral program focuses on research in areas such as thermodynamics, fluid mechanics, and material science.', 'ME', 'PhD', 'INS0012'),
(13, 'MS in Chemistry', 'Graduate program focusing on advanced studies in chemical research and analysis.', 'CHEM', 'Master', 'INS0013'),
(14, 'PhD in Information Systems', 'Doctoral program designed for advanced research in the field of information systems with a focus on technology management.', 'CIS', 'PhD', 'INS0014'),
(15, 'BS in Applied Mathematics', 'This program offers a comprehensive education in mathematical concepts applicable to various engineering and scientific disciplines.', 'ME', 'Bachelor', 'INS0015');

-- --------------------------------------------------------

--
-- Table structure for table `department`
--

CREATE TABLE `department` (
  `departmentCode` varchar(10) NOT NULL,
  `departmentName` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `department`
--

INSERT INTO `department` (`departmentCode`, `departmentName`, `address`) VALUES
('CENG', 'Computer Engineering Department', 'Engineering Bldg 5'),
('CHEM', 'Chemistry Department', 'Science Bldg 1'),
('CIS', 'Computer Information Systems', 'Tech Center 3'),
('EDU', 'Education Department', 'Liberal Arts Bldg 4'),
('ME', 'Mechanical Engineering Department', 'Engineering Bldg 2');

-- --------------------------------------------------------

--
-- Table structure for table `instructor`
--

CREATE TABLE `instructor` (
  `instructorID` varchar(10) NOT NULL,
  `departmentCode` varchar(10) DEFAULT NULL,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `position` varchar(50) NOT NULL CHECK (`position` in ('Professor','Assistant Professor','Senior Lecturer','Associate Professor','Lecturer'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `instructor`
--

INSERT INTO `instructor` (`instructorID`, `departmentCode`, `firstName`, `lastName`, `email`, `position`) VALUES
('INS0001', 'CHEM', 'John', 'Doe', 'jdoe@pvamu.edu', 'Professor'),
('INS0002', 'CIS', 'Jane', 'Smith', 'jsmith@pvamu.edu', 'Assistant Professor'),
('INS0003', 'CENG', 'James', 'Brown', 'jbrown@pvamu.edu', 'Senior Lecturer'),
('INS0004', 'ME', 'Linda', 'Green', 'lgreen@pvamu.edu', 'Associate Professor'),
('INS0005', 'EDU', 'Brian', 'Clark', 'bclark@pvamu.edu', 'Lecturer'),
('INS0006', 'CHEM', 'Nancy', 'Allen', 'nallen@pvamu.edu', 'Professor'),
('INS0007', 'CIS', 'Gary', 'Wilson', 'gwilson@pvamu.edu', 'Assistant Professor'),
('INS0008', 'CENG', 'Lisa', 'Moore', 'lmoore@pvamu.edu', 'Senior Lecturer'),
('INS0009', 'ME', 'Kevin', 'Taylor', 'ktaylor@pvamu.edu', 'Associate Professor'),
('INS0010', 'EDU', 'Dorothy', 'Anderson', 'danderson@pvamu.edu', 'Lecturer'),
('INS0011', 'CHEM', 'Christopher', 'Thomas', 'cthomas@pvamu.edu', 'Professor'),
('INS0012', 'CIS', 'Daniel', 'Jackson', 'djackson@pvamu.edu', 'Assistant Professor'),
('INS0013', 'CENG', 'Paul', 'White', 'pwhite@pvamu.edu', 'Senior Lecturer'),
('INS0014', 'ME', 'Mark', 'Harris', 'mharris@pvamu.edu', 'Associate Professor'),
('INS0015', 'EDU', 'Patricia', 'Martin', 'pmartin@pvamu.edu', 'Lecturer'),
('INS0016', 'CHEM', 'Jennifer', 'Garcia', 'jgarcia@pvamu.edu', 'Professor'),
('INS0017', 'CIS', 'Elizabeth', 'Martinez', 'emartinez@pvamu.edu', 'Assistant Professor'),
('INS0018', 'CENG', 'William', 'Robinson', 'wrobinson@pvamu.edu', 'Senior Lecturer'),
('INS0019', 'ME', 'David', 'Walker', 'dwalker@pvamu.edu', 'Associate Professor'),
('INS0020', 'EDU', 'Barbara', 'Lewis', 'blewis@pvamu.edu', 'Lecturer'),
('INS0021', 'CHEM', 'Jessica', 'Lee', 'jlee@pvamu.edu', 'Professor'),
('INS0022', 'CIS', 'Sarah', 'Young', 'syoung@pvamu.edu', 'Assistant Professor'),
('INS0023', 'CENG', 'Frank', 'Hernandez', 'fhernandez@pvamu.edu', 'Senior Lecturer'),
('INS0024', 'ME', 'Laura', 'King', 'lking@pvamu.edu', 'Associate Professor'),
('INS0025', 'EDU', 'Susan', 'Wright', 'swright@pvamu.edu', 'Lecturer'),
('INS0026', 'CHEM', 'Robert', 'Lopez', 'rlopez@pvamu.edu', 'Professor'),
('INS0027', 'CIS', 'Michael', 'Hill', 'mhill@pvamu.edu', 'Assistant Professor'),
('INS0028', 'CENG', 'Karen', 'Scott', 'kscott@pvamu.edu', 'Senior Lecturer'),
('INS0029', 'ME', 'Steven', 'Green', 'sgreen@pvamu.edu', 'Associate Professor'),
('INS0030', 'EDU', 'Betty', 'Adams', 'badams@pvamu.edu', 'Lecturer');

-- --------------------------------------------------------

--
-- Table structure for table `prerequisite`
--

CREATE TABLE `prerequisite` (
  `courseID` varchar(10) NOT NULL,
  `prerequisitecourseID` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `prerequisite`
--

INSERT INTO `prerequisite` (`courseID`, `prerequisitecourseID`) VALUES
('CENG401', 'CENG301'),
('CENG501', 'CENG401'),
('CENG601', 'CENG501'),
('CHEM201', 'CHEM101'),
('CHEM301', 'CHEM201'),
('CHEM401', 'CHEM301'),
('CIS301', 'CIS201'),
('CIS401', 'CIS301'),
('CIS501', 'CIS401'),
('EDU601', 'EDU501'),
('EDU701', 'EDU601'),
('EDU801', 'EDU701'),
('ME501', 'ME401'),
('ME601', 'ME501'),
('ME701', 'ME601');

-- --------------------------------------------------------

--
-- Table structure for table `semester`
--

CREATE TABLE `semester` (
  `semesterID` int(11) NOT NULL,
  `semesterName` varchar(10) NOT NULL,
  `academicYear` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `semester`
--

INSERT INTO `semester` (`semesterID`, `semesterName`, `academicYear`) VALUES
(1, 'Fall', 2023),
(2, 'Spring', 2024),
(3, 'Summer', 2024),
(4, 'Fall', 2024);

-- --------------------------------------------------------

--
-- Table structure for table `student`
--

CREATE TABLE `student` (
  `studentID` varchar(10) NOT NULL,
  `programID` int(11) NOT NULL,
  `firstName` varchar(50) NOT NULL,
  `lastName` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `classification` varchar(50) NOT NULL CHECK (`classification` in ('Freshman','Sophomore','Junior','Senior','Graduate')),
  `phoneNumber` varchar(20) NOT NULL,
  `gender` varchar(15) NOT NULL CHECK (`gender` in ('Male','Female','Non-Binary','Other'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student`
--

INSERT INTO `student` (`studentID`, `programID`, `firstName`, `lastName`, `email`, `classification`, `phoneNumber`, `gender`) VALUES
('', 3, 'Joy', 'Onuoha', 'ou@gmail.com', 'Graduate', '09081728172', 'Female'),
('P22234459', 3, 'Noah', 'Brown', 'nbrown@pvamu.edu', 'Junior', '345-678-9012', 'Male'),
('P22234460', 8, 'Ethan', 'Martinez', 'emartinez@pvamu.edu', 'Junior', '890-123-4567', 'Male'),
('P22234461', 13, 'Charlotte', 'Anderson', 'canderson@pvamu.edu', 'Junior', '345-678-9012', 'Female'),
('P22234462', 3, 'Logan', 'Martin', 'lmartin@pvamu.edu', 'Junior', '890-123-4567', 'Male'),
('P22234463', 8, 'Elizabeth', 'Clark', 'eclark@pvamu.edu', 'Junior', '345-678-9012', 'Female'),
('P22455511', 2, 'Olivia', 'Williams', 'owilliams@pvamu.edu', 'Sophomore', '234-567-8901', 'Female'),
('P22455512', 7, 'Isabella', 'Garcia', 'igarcia@pvamu.edu', 'Sophomore', '789-012-3456', 'Female'),
('P22455513', 12, 'Alexander', 'Wilson', 'awilson@pvamu.edu', 'Sophomore', '234-567-8901', 'Male'),
('P22455514', 2, 'Mia', 'Jackson', 'mjackson@pvamu.edu', 'Sophomore', '789-012-3456', 'Other'),
('P22455515', 7, 'Sebastian', 'Harris', 'sharris@pvamu.edu', 'Sophomore', '234-567-8901', 'Male'),
('P22719811', 1, 'Emma', 'Johnson', 'ejohnson@pvamu.edu', 'Freshman', '123-456-7890', 'Female'),
('P22728765', 6, 'Mason', 'Davis', 'mdavis@pvamu.edu', 'Freshman', '678-901-2345', 'Male'),
('P22728766', 11, 'Emily', 'Gonzalez', 'egonzalez@pvamu.edu', 'Freshman', '123-456-7890', 'Female'),
('P22728767', 1, 'Lucas', 'Moore', 'lmoore@pvamu.edu', 'Freshman', '678-901-2345', 'Male'),
('P22728768', 6, 'Abigail', 'White', 'awhite@pvamu.edu', 'Freshman', '123-456-7890', 'Female'),
('P22728769', 11, 'Sofia', 'Walker', 'swalker@pvamu.edu', 'Freshman', '678-901-2345', 'Female'),
('P22876543', 5, 'Sophia', 'Miller', 'smiller@pvamu.edu', 'Graduate', '567-890-1234', 'Female'),
('P22876544', 10, 'Michael', 'Lopez', 'mlopez@pvamu.edu', 'Graduate', '012-345-6789', 'Male'),
('P22876545', 15, 'Amelia', 'Taylor', 'ataylor@pvamu.edu', 'Graduate', '567-890-1234', 'Female'),
('P22876546', 5, 'Elijah', 'Perez', 'eperez@pvamu.edu', 'Graduate', '012-345-6789', 'Male'),
('P22876547', 10, 'Avery', 'Robinson', 'arobinson@pvamu.edu', 'Graduate', '567-890-1234', 'Female'),
('P22998743', 4, 'Liam', 'Jones', 'ljones@pvamu.edu', 'Senior', '456-789-0123', 'Other'),
('P22998744', 9, 'Ava', 'Hernandez', 'ahernandez@pvamu.edu', 'Senior', '901-234-5678', 'Female'),
('P22998745', 14, 'Benjamin', 'Thomas', 'bthomas@pvamu.edu', 'Senior', '456-789-0123', 'Male'),
('P22998746', 4, 'Harper', 'Lee', 'hlee@pvamu.edu', 'Senior', '901-234-5678', 'Female'),
('P22998747', 9, 'Matthew', 'Lewis', 'mlewis@pvamu.edu', 'Senior', '456-789-0123', 'Male'),
('P22998748', 11, 'Vigil', 'Vandyke', 'vv@pvamu.edu', 'Freshman', '123-456-789', 'Male'),
('P23019801', 2, 'Noah', 'Smith', 'nsmith@pvamu.edu', 'Junior', '123-456-7890', 'Male'),
('P23019802', 2, 'Mabel', 'Johnson', 'mjohnson@pvamu.edu', 'Junior', '234-567-8901', 'Male'),
('P23019803', 2, 'Charlotte', 'Brown', 'cbrown@pvamu.edu', 'Graduate', '345-678-9012', 'Female'),
('P23019804', 2, 'Logan', 'Martinez', 'lmartinez@pvamu.edu', 'Graduate', '456-789-0123', 'Male'),
('P23019805', 2, 'Matthias', 'Clarke', 'mclarke@pvamu.edu', 'Junior', '567-890-1234', 'Female'),
('P23019806', 2, 'Olivia', 'Williyms', 'owilliyms@pvamu.edu', 'Sophomore', '678-901-2345', 'Female'),
('P23019807', 2, 'Isabella', 'Georgecia', 'igeorgecia@pvamu.edu', 'Sophomore', '789-012-3456', 'Female'),
('P23019808', 2, 'Alexander', 'Davis', 'adavis@pvamu.edu', 'Graduate', '890-123-4567', 'Male'),
('P23019809', 2, 'Mia', 'Rodriguez', 'mrodriguez@pvamu.edu', 'Sophomore', '901-234-5678', 'Other'),
('P23019810', 2, 'Sebastian', 'Martinez', 'smartinez@pvamu.edu', 'Sophomore', '012-345-6789', 'Male'),
('P23019811', 2, 'Emma', 'Wilson', 'ewilson@pvamu.edu', 'Freshman', '123-456-7890', 'Female'),
('P23019812', 2, 'Mason', 'Lee', 'mlee@pvamu.edu', 'Freshman', '234-567-8901', 'Male'),
('P23019813', 2, 'Emily', 'Gomez', 'egomez@pvamu.edu', 'Freshman', '345-678-9012', 'Female'),
('P23019814', 2, 'Lucas', 'Harris', 'lharris@pvamu.edu', 'Freshman', '456-789-0123', 'Male'),
('P23019815', 2, 'Abigail', 'Clark', 'aclark@pvamu.edu', 'Graduate', '567-890-1234', 'Female'),
('P23019816', 2, 'Sofia', 'Young', 'syoung@pvamu.edu', 'Freshman', '678-901-2345', 'Female'),
('P23019817', 2, 'Sophia', 'Lee', 'slee@pvamu.edu', 'Graduate', '789-012-3456', 'Female'),
('P23019818', 2, 'Michael', 'Robinson', 'mrobinson@pvamu.edu', 'Graduate', '890-123-4567', 'Male'),
('P23019819', 2, 'Amelia', 'Nelson', 'anelson@pvamu.edu', 'Graduate', '901-234-5678', 'Female'),
('P23019820', 2, 'Elijah', 'Cook', 'ecook@pvamu.edu', 'Graduate', '012-345-6789', 'Male'),
('P23019901', 1, 'David', 'Smith', 'dsmith@pvamu.edu', 'Graduate', '123-456-7890', 'Male'),
('P23019902', 1, 'Sophie', 'Johnson', 'sjohnson@pvamu.edu', 'Graduate', '234-567-8901', 'Female'),
('P23019903', 1, 'Christopher', 'Bryani', 'cbryani@pvamu.edu', 'Senior', '345-678-9012', 'Male'),
('P23019904', 1, 'Lily', 'Martine', 'lmartine@pvamu.edu', 'Sophomore', '456-789-0123', 'Female'),
('P23019905', 1, 'Daniel', 'Clark', 'dclark@pvamu.edu', 'Freshman', '567-890-1234', 'Male'),
('P23019906', 1, 'Grace', 'Williams', 'gwilliams@pvamu.edu', 'Freshman', '678-901-2345', 'Female'),
('P23019907', 1, 'Ryan', 'Garcia', 'rgarcia@pvamu.edu', 'Graduate', '789-012-3456', 'Male'),
('P23019908', 1, 'Chloe', 'Davis', 'cdavis@pvamu.edu', 'Graduate', '890-123-4567', 'Female'),
('P23019909', 1, 'Ethan', 'Rodriguez', 'erodriguez@pvamu.edu', 'Junior', '901-234-5678', 'Male'),
('P23019910', 1, 'Avery', 'Martinez', 'amartinez@pvamu.edu', 'Graduate', '612-345-6789', 'Other'),
('P23019911', 14, 'Oliver', 'Smith', 'osmith@pvamu.edu', 'Junior', '123-456-7890', 'Male'),
('P23019912', 14, 'Fella', 'Johnson', 'fjohnson@pvamu.edu', 'Graduate', '234-567-8901', 'Female'),
('P23019913', 14, 'Lucas', 'Brown', 'lbrown@pvamu.edu', 'Senior', '345-678-9012', 'Male'),
('P23019914', 14, 'Scarlett', 'Mcrtinez', 'smcrtinez@pvamu.edu', 'Sophomore', '456-789-0123', 'Female'),
('P23019915', 14, 'Mason', 'Clark', 'mclark@pvamu.edu', 'Freshman', '567-890-1234', 'Male'),
('P23019916', 14, 'Ava', 'Williams', 'awilliams@pvamu.edu', 'Graduate', '678-901-2345', 'Female'),
('P23019917', 14, 'Henry', 'Garcia', 'hgarcia@pvamu.edu', 'Graduate', '789-012-3456', 'Male'),
('P23019918', 14, 'Sophia', 'Davis', 'sdavis@pvamu.edu', 'Graduate', '890-123-4567', 'Female'),
('P23019919', 14, 'Liam', 'Rodriguez', 'lrodriguez@pvamu.edu', 'Junior', '901-234-5678', 'Male'),
('P23019920', 14, 'Amelia', 'Douglas', 'adouglas@pvamu.edu', 'Graduate', '012-345-6789', 'Other');

--
-- Triggers `student`
--
DELIMITER $$
CREATE TRIGGER `delete_student_trigger` AFTER DELETE ON `student` FOR EACH ROW BEGIN
    INSERT INTO student_audit (studentID, programID, firstName, lastName, email, classification, phoneNumber, gender, action)
    VALUES (OLD.studentID, OLD.programID, OLD.firstName, OLD.lastName, OLD.email, OLD.classification, OLD.phoneNumber, OLD.gender, 'DELETE');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `new_student_trigger` AFTER INSERT ON `student` FOR EACH ROW BEGIN
    INSERT INTO student_audit (studentID, programID, firstName, lastName, email, classification, phoneNumber, gender, action)
    VALUES (NEW.studentID, NEW.programID, NEW.firstName, NEW.lastName, NEW.email, NEW.classification, NEW.phoneNumber, NEW.gender, 'INSERT');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_student_trigger` AFTER UPDATE ON `student` FOR EACH ROW BEGIN
    INSERT INTO student_audit (studentID, programID, firstName, lastName, email, classification, phoneNumber, gender, action)
    VALUES (OLD.studentID, NEW.programID, NEW.firstName, NEW.lastName, NEW.email, NEW.classification, NEW.phoneNumber, NEW.gender, 'UPDATE');
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `student2`
--

CREATE TABLE `student2` (
  `studentID` varchar(50) NOT NULL,
  `programID` int(11) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `lastName` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `classification` varchar(255) NOT NULL,
  `phoneNumber` varchar(255) NOT NULL,
  `gender` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student2`
--

INSERT INTO `student2` (`studentID`, `programID`, `firstName`, `lastName`, `email`, `classification`, `phoneNumber`, `gender`) VALUES
('P22234459', 3, 'Noah', 'Brown', 'nbrown@pvamu.edu', 'Junior', '345-678-9012', 'Male'),
('P22234460', 8, 'Ethan', 'Martinez', 'emartinez@pvamu.edu', 'Junior', '890-123-4567', 'Male'),
('P22234461', 13, 'Charlotte', 'Anderson', 'canderson@pvamu.edu', 'Junior', '345-678-9012', 'Female'),
('P22234462', 3, 'Logan', 'Martin', 'lmartin@pvamu.edu', 'Junior', '890-123-4567', 'Male'),
('P22234463', 8, 'Elizabeth', 'Clark', 'eclark@pvamu.edu', 'Junior', '345-678-9012', 'Female'),
('P22455511', 2, 'Olivia', 'Williams', 'owilliams@pvamu.edu', 'Sophomore', '234-567-8901', 'Female'),
('P22455512', 7, 'Isabella', 'Garcia', 'igarcia@pvamu.edu', 'Sophomore', '789-012-3456', 'Female'),
('P22455513', 12, 'Alexander', 'Wilson', 'awilson@pvamu.edu', 'Sophomore', '234-567-8901', 'Male'),
('P22455514', 2, 'Mia', 'Jackson', 'mjackson@pvamu.edu', 'Sophomore', '789-012-3456', 'Other'),
('P22455515', 7, 'Sebastian', 'Harris', 'sharris@pvamu.edu', 'Sophomore', '234-567-8901', 'Male'),
('P22719811', 1, 'Emma', 'Johnson', 'ejohnson@pvamu.edu', 'Freshman', '123-456-7890', 'Female'),
('P22728765', 6, 'Mason', 'Davis', 'mdavis@pvamu.edu', 'Freshman', '678-901-2345', 'Male'),
('P22728766', 11, 'Emily', 'Gonzalez', 'egonzalez@pvamu.edu', 'Freshman', '123-456-7890', 'Female'),
('P22728767', 1, 'Lucas', 'Moore', 'lmoore@pvamu.edu', 'Freshman', '678-901-2345', 'Male'),
('P22728768', 6, 'Abigail', 'White', 'awhite@pvamu.edu', 'Freshman', '123-456-7890', 'Female'),
('P22728769', 11, 'Sofia', 'Walker', 'swalker@pvamu.edu', 'Freshman', '678-901-2345', 'Female'),
('P22876543', 5, 'Sophia', 'Miller', 'smiller@pvamu.edu', 'Graduate', '567-890-1234', 'Female'),
('P22876544', 10, 'Michael', 'Lopez', 'mlopez@pvamu.edu', 'Graduate', '012-345-6789', 'Male'),
('P22876545', 15, 'Amelia', 'Taylor', 'ataylor@pvamu.edu', 'Graduate', '567-890-1234', 'Female'),
('P22876546', 5, 'Elijah', 'Perez', 'eperez@pvamu.edu', 'Graduate', '012-345-6789', 'Male'),
('P22876547', 10, 'Avery', 'Robinson', 'arobinson@pvamu.edu', 'Graduate', '567-890-1234', 'Female'),
('P22998743', 4, 'Liam', 'Jones', 'ljones@pvamu.edu', 'Senior', '456-789-0123', 'Other'),
('P22998744', 9, 'Ava', 'Hernandez', 'ahernandez@pvamu.edu', 'Senior', '901-234-5678', 'Female'),
('P22998745', 14, 'Benjamin', 'Thomas', 'bthomas@pvamu.edu', 'Senior', '456-789-0123', 'Male'),
('P22998746', 4, 'Harper', 'Lee', 'hlee@pvamu.edu', 'Senior', '901-234-5678', 'Female'),
('P22998747', 9, 'Matthew', 'Lewis', 'mlewis@pvamu.edu', 'Senior', '456-789-0123', 'Male'),
('P23019801', 2, 'Noah', 'Smith', 'nsmith@pvamu.edu', 'Junior', '123-456-7890', 'Male'),
('P23019802', 2, 'Mabel', 'Johnson', 'mjohnson@pvamu.edu', 'Junior', '234-567-8901', 'Male'),
('P23019803', 2, 'Charlotte', 'Brown', 'cbrown@pvamu.edu', 'Graduate', '345-678-9012', 'Female'),
('P23019804', 2, 'Logan', 'Martinez', 'lmartinez@pvamu.edu', 'Graduate', '456-789-0123', 'Male'),
('P23019805', 2, 'Matthias', 'Clarke', 'mclarke@pvamu.edu', 'Junior', '567-890-1234', 'Female'),
('P23019806', 2, 'Olivia', 'Williyms', 'owilliyms@pvamu.edu', 'Sophomore', '678-901-2345', 'Female'),
('P23019807', 2, 'Isabella', 'Georgecia', 'igeorgecia@pvamu.edu', 'Sophomore', '789-012-3456', 'Female'),
('P23019808', 2, 'Alexander', 'Davis', 'adavis@pvamu.edu', 'Graduate', '890-123-4567', 'Male'),
('P23019809', 2, 'Mia', 'Rodriguez', 'mrodriguez@pvamu.edu', 'Sophomore', '901-234-5678', 'Other'),
('P23019810', 2, 'Sebastian', 'Martinez', 'smartinez@pvamu.edu', 'Sophomore', '012-345-6789', 'Male'),
('P23019811', 2, 'Emma', 'Wilson', 'ewilson@pvamu.edu', 'Freshman', '123-456-7890', 'Female'),
('P23019812', 2, 'Mason', 'Lee', 'mlee@pvamu.edu', 'Freshman', '234-567-8901', 'Male'),
('P23019813', 2, 'Emily', 'Gomez', 'egomez@pvamu.edu', 'Freshman', '345-678-9012', 'Female'),
('P23019814', 2, 'Lucas', 'Harris', 'lharris@pvamu.edu', 'Freshman', '456-789-0123', 'Male'),
('P23019815', 2, 'Abigail', 'Clark', 'aclark@pvamu.edu', 'Graduate', '567-890-1234', 'Female'),
('P23019816', 2, 'Sofia', 'Young', 'syoung@pvamu.edu', 'Freshman', '678-901-2345', 'Female'),
('P23019817', 2, 'Sophia', 'Lee', 'slee@pvamu.edu', 'Graduate', '789-012-3456', 'Female'),
('P23019818', 2, 'Michael', 'Robinson', 'mrobinson@pvamu.edu', 'Graduate', '890-123-4567', 'Male'),
('P23019819', 2, 'Amelia', 'Nelson', 'anelson@pvamu.edu', 'Graduate', '901-234-5678', 'Female'),
('P23019820', 2, 'Elijah', 'Cook', 'ecook@pvamu.edu', 'Graduate', '012-345-6789', 'Male'),
('P23019901', 1, 'David', 'Smith', 'dsmith@pvamu.edu', 'Graduate', '123-456-7890', 'Male'),
('P23019902', 1, 'Sophie', 'Johnson', 'sjohnson@pvamu.edu', 'Graduate', '234-567-8901', 'Female'),
('P23019903', 1, 'Christopher', 'Bryani', 'cbryani@pvamu.edu', 'Senior', '345-678-9012', 'Male'),
('P23019904', 1, 'Lily', 'Martine', 'lmartine@pvamu.edu', 'Sophomore', '456-789-0123', 'Female'),
('P23019905', 1, 'Daniel', 'Clark', 'dclark@pvamu.edu', 'Freshman', '567-890-1234', 'Male'),
('P23019906', 1, 'Grace', 'Williams', 'gwilliams@pvamu.edu', 'Freshman', '678-901-2345', 'Female'),
('P23019907', 1, 'Ryan', 'Garcia', 'rgarcia@pvamu.edu', 'Graduate', '789-012-3456', 'Male'),
('P23019908', 1, 'Chloe', 'Davis', 'cdavis@pvamu.edu', 'Graduate', '890-123-4567', 'Female'),
('P23019909', 1, 'Ethan', 'Rodriguez', 'erodriguez@pvamu.edu', 'Junior', '901-234-5678', 'Male'),
('P23019910', 1, 'Avery', 'Martinez', 'amartinez@pvamu.edu', 'Graduate', '612-345-6789', 'Other'),
('P23019911', 14, 'Oliver', 'Smith', 'osmith@pvamu.edu', 'Junior', '123-456-7890', 'Male'),
('P23019912', 14, 'Fella', 'Johnson', 'fjohnson@pvamu.edu', 'Graduate', '234-567-8901', 'Female'),
('P23019913', 14, 'Lucas', 'Brown', 'lbrown@pvamu.edu', 'Senior', '345-678-9012', 'Male'),
('P23019914', 14, 'Scarlett', 'Mcrtinez', 'smcrtinez@pvamu.edu', 'Sophomore', '456-789-0123', 'Female'),
('P23019915', 14, 'Mason', 'Clark', 'mclark@pvamu.edu', 'Freshman', '567-890-1234', 'Male'),
('P23019916', 14, 'Ava', 'Williams', 'awilliams@pvamu.edu', 'Graduate', '678-901-2345', 'Female'),
('P23019917', 14, 'Henry', 'Garcia', 'hgarcia@pvamu.edu', 'Graduate', '789-012-3456', 'Male'),
('P23019918', 14, 'Sophia', 'Davis', 'sdavis@pvamu.edu', 'Graduate', '890-123-4567', 'Female'),
('P23019919', 14, 'Liam', 'Rodriguez', 'lrodriguez@pvamu.edu', 'Junior', '901-234-5678', 'Male'),
('P23019920', 14, 'Amelia', 'Douglas', 'adouglas@pvamu.edu', 'Graduate', '012-345-6789', 'Other');

-- --------------------------------------------------------

--
-- Table structure for table `student_audit`
--

CREATE TABLE `student_audit` (
  `activity_id` int(11) NOT NULL,
  `studentID` varchar(255) NOT NULL,
  `programID` int(11) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `lastName` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `classification` varchar(255) NOT NULL,
  `phoneNumber` varchar(50) NOT NULL,
  `gender` varchar(10) NOT NULL,
  `action` enum('INSERT','UPDATE','DELETE','') NOT NULL,
  `activity_time` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `student_audit`
--

INSERT INTO `student_audit` (`activity_id`, `studentID`, `programID`, `firstName`, `lastName`, `email`, `classification`, `phoneNumber`, `gender`, `action`, `activity_time`) VALUES
(1, '2606003', 1, 'Joel', 'John', 'jj@pvamu.edu', 'Junior', '123-456-678', 'Male', 'INSERT', '2024-04-09 20:19:07'),
(2, '22998748', 11, 'Mark', 'Mail', 'mm@pvamu.edu', 'Sophomore', '123-432-123', 'Male', 'INSERT', '2024-04-09 20:39:34'),
(3, '22998748', 11, 'Mark', 'Mail', 'mm@pvamu.edu', 'Sophomore', '123-432-123', 'Male', 'UPDATE', '2024-04-09 20:45:43'),
(4, '2606003', 1, 'Joel', 'John', 'jj@pvamu.edu', 'Junior', '123-456-678', 'Male', 'UPDATE', '2024-04-09 20:45:43'),
(5, 'P22998748', 3, 'Chigil', 'Vandikye', 'chigil@pvamu.edu', 'Freshman', '123-456-234', 'Female', 'INSERT', '2024-04-09 20:47:45'),
(6, 'P22998748', 3, 'Chigil', 'Vandikye', 'chigil@pvamu.edu', 'Sophomore', '123-456-234', 'Female', 'UPDATE', '2024-04-09 23:32:32'),
(7, 'P22998748', 3, 'Chigil', 'Vandikye', 'chigil@pvamu.edu', 'Junior', '123-456-234', 'Female', 'UPDATE', '2024-04-09 23:32:54'),
(8, 'P22998748', 3, 'Chigil', 'Vandikye', 'chigil@pvamu.edu', 'Freshman', '123-456-234', 'Female', 'UPDATE', '2024-04-09 23:33:50'),
(9, 'P22998748', 3, 'Chigil', 'Vandikye', 'chigil@pvamu.edu', 'Graduate', '123-456-234', 'Female', 'UPDATE', '2024-04-09 23:33:58'),
(10, 'P22998748', 3, 'Chigil', 'Vandikye', 'chigil@pvamu.edu', 'Sophomore', '123-456-234', 'Female', 'UPDATE', '2024-04-09 23:34:10'),
(11, 'P22998748', 3, 'Chigil', 'Vandikye', 'chigil@pvamu.edu', 'Sophomore', '123-456-234', 'Female', 'UPDATE', '2024-04-09 23:43:34'),
(12, 'P22998748', 11, 'Vigil', 'Vandyke', 'vv@pvamu.edu', 'Freshman', '123-456-789', 'Male', 'INSERT', '2024-04-09 23:45:09'),
(13, 'P22998749', 11, 'Amaka', 'Cheire', 'aminwa@pvamu.edu', 'Freshman', '123-456-789', 'Female', 'INSERT', '2024-04-09 23:46:17'),
(14, 'P22998749', 11, 'Amaka', 'Cheery', 'aminwa@pvamu.edu', 'Freshman', '123-456-789', 'Female', 'UPDATE', '2024-04-09 23:46:29'),
(15, 'P22998749', 11, 'Amaka', 'Cheery', 'aminwa@pvamu.edu', 'Freshman', '123-456-789', 'Female', 'DELETE', '2024-04-09 23:46:52'),
(16, 'P23019801', 2, 'Noah', 'Smith', 'nsmith@pvamu.edu', 'Junior', '123-456-7890', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(17, 'P23019802', 2, 'Mabel', 'Johnson', 'mjohnson@pvamu.edu', 'Junior', '234-567-8901', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(18, 'P23019803', 2, 'Charlotte', 'Brown', 'cbrown@pvamu.edu', 'Graduate', '345-678-9012', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(19, 'P23019804', 2, 'Logan', 'Martinez', 'lmartinez@pvamu.edu', 'Graduate', '456-789-0123', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(20, 'P23019805', 2, 'Matthias', 'Clarke', 'mclarke@pvamu.edu', 'Junior', '567-890-1234', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(21, 'P23019806', 2, 'Olivia', 'Williyms', 'owilliyms@pvamu.edu', 'Sophomore', '678-901-2345', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(22, 'P23019807', 2, 'Isabella', 'Georgecia', 'igeorgecia@pvamu.edu', 'Sophomore', '789-012-3456', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(23, 'P23019808', 2, 'Alexander', 'Davis', 'adavis@pvamu.edu', 'Graduate', '890-123-4567', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(24, 'P23019809', 2, 'Mia', 'Rodriguez', 'mrodriguez@pvamu.edu', 'Sophomore', '901-234-5678', 'Other', 'INSERT', '2024-04-10 02:40:58'),
(25, 'P23019810', 2, 'Sebastian', 'Martinez', 'smartinez@pvamu.edu', 'Sophomore', '012-345-6789', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(26, 'P23019811', 2, 'Emma', 'Wilson', 'ewilson@pvamu.edu', 'Freshman', '123-456-7890', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(27, 'P23019812', 2, 'Mason', 'Lee', 'mlee@pvamu.edu', 'Freshman', '234-567-8901', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(28, 'P23019813', 2, 'Emily', 'Gomez', 'egomez@pvamu.edu', 'Freshman', '345-678-9012', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(29, 'P23019814', 2, 'Lucas', 'Harris', 'lharris@pvamu.edu', 'Freshman', '456-789-0123', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(30, 'P23019815', 2, 'Abigail', 'Clark', 'aclark@pvamu.edu', 'Graduate', '567-890-1234', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(31, 'P23019816', 2, 'Sofia', 'Young', 'syoung@pvamu.edu', 'Freshman', '678-901-2345', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(32, 'P23019817', 2, 'Sophia', 'Lee', 'slee@pvamu.edu', 'Graduate', '789-012-3456', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(33, 'P23019818', 2, 'Michael', 'Robinson', 'mrobinson@pvamu.edu', 'Graduate', '890-123-4567', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(34, 'P23019819', 2, 'Amelia', 'Nelson', 'anelson@pvamu.edu', 'Graduate', '901-234-5678', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(35, 'P23019820', 2, 'Elijah', 'Cook', 'ecook@pvamu.edu', 'Graduate', '012-345-6789', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(36, 'P23019901', 1, 'David', 'Smith', 'dsmith@pvamu.edu', 'Graduate', '123-456-7890', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(37, 'P23019902', 1, 'Sophie', 'Johnson', 'sjohnson@pvamu.edu', 'Graduate', '234-567-8901', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(38, 'P23019903', 1, 'Christopher', 'Bryani', 'cbryani@pvamu.edu', 'Senior', '345-678-9012', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(39, 'P23019904', 1, 'Lily', 'Martine', 'lmartine@pvamu.edu', 'Sophomore', '456-789-0123', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(40, 'P23019905', 1, 'Daniel', 'Clark', 'dclark@pvamu.edu', 'Freshman', '567-890-1234', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(41, 'P23019906', 1, 'Grace', 'Williams', 'gwilliams@pvamu.edu', 'Freshman', '678-901-2345', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(42, 'P23019907', 1, 'Ryan', 'Garcia', 'rgarcia@pvamu.edu', 'Graduate', '789-012-3456', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(43, 'P23019908', 1, 'Chloe', 'Davis', 'cdavis@pvamu.edu', 'Graduate', '890-123-4567', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(44, 'P23019909', 1, 'Ethan', 'Rodriguez', 'erodriguez@pvamu.edu', 'Junior', '901-234-5678', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(45, 'P23019910', 1, 'Avery', 'Martinez', 'amartinez@pvamu.edu', 'Graduate', '612-345-6789', 'Other', 'INSERT', '2024-04-10 02:40:58'),
(46, 'P23019911', 14, 'Oliver', 'Smith', 'osmith@pvamu.edu', 'Junior', '123-456-7890', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(47, 'P23019912', 14, 'Fella', 'Johnson', 'fjohnson@pvamu.edu', 'Graduate', '234-567-8901', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(48, 'P23019913', 14, 'Lucas', 'Brown', 'lbrown@pvamu.edu', 'Senior', '345-678-9012', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(49, 'P23019914', 14, 'Scarlett', 'Mcrtinez', 'smcrtinez@pvamu.edu', 'Sophomore', '456-789-0123', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(50, 'P23019915', 14, 'Mason', 'Clark', 'mclark@pvamu.edu', 'Freshman', '567-890-1234', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(51, 'P23019916', 14, 'Ava', 'Williams', 'awilliams@pvamu.edu', 'Graduate', '678-901-2345', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(52, 'P23019917', 14, 'Henry', 'Garcia', 'hgarcia@pvamu.edu', 'Graduate', '789-012-3456', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(53, 'P23019918', 14, 'Sophia', 'Davis', 'sdavis@pvamu.edu', 'Graduate', '890-123-4567', 'Female', 'INSERT', '2024-04-10 02:40:58'),
(54, 'P23019919', 14, 'Liam', 'Rodriguez', 'lrodriguez@pvamu.edu', 'Junior', '901-234-5678', 'Male', 'INSERT', '2024-04-10 02:40:58'),
(55, 'P23019920', 14, 'Amelia', 'Douglas', 'adouglas@pvamu.edu', 'Graduate', '012-345-6789', 'Other', 'INSERT', '2024-04-10 02:40:58'),
(56, '', 3, 'Joy', 'Onuoha', 'ou@gmail.com', 'Graduate', '09081728172', 'Female', 'INSERT', '2024-04-16 02:45:06'),
(57, 'P23019920', 14, 'Amelia', 'Douglas', 'adouglas@pvamu.edu', 'Freshman', '012-345-6789', 'Other', 'UPDATE', '2024-04-16 04:17:04'),
(58, 'P23019920', 14, 'Amelia', 'Douglas', 'adouglas@pvamu.edu', 'Graduate', '012-345-6789', 'Other', 'UPDATE', '2024-04-16 04:17:11'),
(59, 'P23019921', 1, 'Chioma', 'Jachi', 'chioma@gmail.com', 'Sophomore', '09081728172', 'Female', 'INSERT', '2024-04-16 10:52:23'),
(60, 'P23019921', 1, 'Chioma', 'Jachi', 'chioma@gmail.com', 'Sophomore', '09081728172', 'Female', 'DELETE', '2024-04-16 10:56:50'),
(61, 'P23019921', 8, 'Joy', 'Ukandu', 'uk@gmail.com', 'Sophomore', '09081728172', 'Female', 'INSERT', '2024-04-16 14:25:14'),
(62, 'P23019901', 1, 'David', 'Smith', 'dsmith@pvamu.edu', 'Graduate', '123-456-7890', 'Male', 'UPDATE', '2024-04-16 14:37:30'),
(63, 'P23019813', 2, 'Emily', 'Gomez', 'egomez@pvamu.edu', 'Freshman', '345-678-9012', 'Female', 'UPDATE', '2024-04-16 14:38:14'),
(64, 'P23019921', 8, 'Joy', 'Ukandu', 'uk@gmail.com', 'Sophomore', '09081728172', 'Female', 'DELETE', '2024-04-16 14:42:15'),
(65, 'P23019920', 14, 'Amelia', 'Douglas', 'adouglas@pvamu.edu', 'Graduate', '012-345-6789', 'Other', 'UPDATE', '2024-04-16 15:13:10');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `careertag`
--
ALTER TABLE `careertag`
  ADD PRIMARY KEY (`careerTagID`),
  ADD UNIQUE KEY `careerTitle` (`careerTitle`);

--
-- Indexes for table `course`
--
ALTER TABLE `course`
  ADD PRIMARY KEY (`courseCode`),
  ADD KEY `departmentCode` (`departmentCode`);

--
-- Indexes for table `courseoffering`
--
ALTER TABLE `courseoffering`
  ADD PRIMARY KEY (`courseCode`,`semesterID`),
  ADD KEY `semesterID` (`semesterID`),
  ADD KEY `instructorID` (`instructorID`);

--
-- Indexes for table `courserecommendation`
--
ALTER TABLE `courserecommendation`
  ADD PRIMARY KEY (`courseCode`,`careerTagCode`),
  ADD KEY `careerTagCode` (`careerTagCode`);

--
-- Indexes for table `courseregistration`
--
ALTER TABLE `courseregistration`
  ADD PRIMARY KEY (`registrationID`),
  ADD KEY `studentID` (`studentID`),
  ADD KEY `courseCode` (`courseCode`),
  ADD KEY `semesterID` (`semesterID`);

--
-- Indexes for table `degreeprogram`
--
ALTER TABLE `degreeprogram`
  ADD PRIMARY KEY (`programID`),
  ADD KEY `departmentCode` (`departmentCode`),
  ADD KEY `degreeAdvisor` (`degreeAdvisor`);

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`departmentCode`),
  ADD UNIQUE KEY `departmentName` (`departmentName`);

--
-- Indexes for table `instructor`
--
ALTER TABLE `instructor`
  ADD PRIMARY KEY (`instructorID`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `departmentCode` (`departmentCode`);

--
-- Indexes for table `prerequisite`
--
ALTER TABLE `prerequisite`
  ADD PRIMARY KEY (`courseID`,`prerequisitecourseID`),
  ADD KEY `prerequisitecourseID` (`prerequisitecourseID`);

--
-- Indexes for table `semester`
--
ALTER TABLE `semester`
  ADD PRIMARY KEY (`semesterID`);

--
-- Indexes for table `student`
--
ALTER TABLE `student`
  ADD PRIMARY KEY (`studentID`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `programID` (`programID`);

--
-- Indexes for table `student2`
--
ALTER TABLE `student2`
  ADD PRIMARY KEY (`studentID`),
  ADD KEY `programID` (`programID`);

--
-- Indexes for table `student_audit`
--
ALTER TABLE `student_audit`
  ADD PRIMARY KEY (`activity_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `student_audit`
--
ALTER TABLE `student_audit`
  MODIFY `activity_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `course`
--
ALTER TABLE `course`
  ADD CONSTRAINT `course_ibfk_1` FOREIGN KEY (`departmentCode`) REFERENCES `department` (`departmentCode`);

--
-- Constraints for table `courseoffering`
--
ALTER TABLE `courseoffering`
  ADD CONSTRAINT `courseoffering_ibfk_1` FOREIGN KEY (`courseCode`) REFERENCES `course` (`courseCode`),
  ADD CONSTRAINT `courseoffering_ibfk_2` FOREIGN KEY (`semesterID`) REFERENCES `semester` (`semesterID`),
  ADD CONSTRAINT `courseoffering_ibfk_3` FOREIGN KEY (`instructorID`) REFERENCES `instructor` (`instructorID`);

--
-- Constraints for table `courserecommendation`
--
ALTER TABLE `courserecommendation`
  ADD CONSTRAINT `courserecommendation_ibfk_1` FOREIGN KEY (`courseCode`) REFERENCES `course` (`courseCode`),
  ADD CONSTRAINT `courserecommendation_ibfk_2` FOREIGN KEY (`careerTagCode`) REFERENCES `careertag` (`careerTagID`);

--
-- Constraints for table `courseregistration`
--
ALTER TABLE `courseregistration`
  ADD CONSTRAINT `courseregistration_ibfk_1` FOREIGN KEY (`studentID`) REFERENCES `student` (`studentID`) ON UPDATE CASCADE,
  ADD CONSTRAINT `courseregistration_ibfk_2` FOREIGN KEY (`courseCode`) REFERENCES `course` (`courseCode`),
  ADD CONSTRAINT `courseregistration_ibfk_3` FOREIGN KEY (`semesterID`) REFERENCES `semester` (`semesterID`);

--
-- Constraints for table `degreeprogram`
--
ALTER TABLE `degreeprogram`
  ADD CONSTRAINT `degreeprogram_ibfk_1` FOREIGN KEY (`departmentCode`) REFERENCES `department` (`departmentCode`),
  ADD CONSTRAINT `degreeprogram_ibfk_2` FOREIGN KEY (`degreeAdvisor`) REFERENCES `instructor` (`instructorID`) ON DELETE SET NULL;

--
-- Constraints for table `instructor`
--
ALTER TABLE `instructor`
  ADD CONSTRAINT `instructor_ibfk_1` FOREIGN KEY (`departmentCode`) REFERENCES `department` (`departmentCode`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `prerequisite`
--
ALTER TABLE `prerequisite`
  ADD CONSTRAINT `prerequisite_ibfk_1` FOREIGN KEY (`courseID`) REFERENCES `course` (`courseCode`),
  ADD CONSTRAINT `prerequisite_ibfk_2` FOREIGN KEY (`prerequisitecourseID`) REFERENCES `course` (`courseCode`);

--
-- Constraints for table `student`
--
ALTER TABLE `student`
  ADD CONSTRAINT `student_ibfk_1` FOREIGN KEY (`programID`) REFERENCES `degreeprogram` (`programID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
