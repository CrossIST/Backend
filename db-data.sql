-- =====================================================
-- UNIVERSITY MANAGEMENT SYSTEM DATABASE STRUCTURE
-- =====================================================

-- Drop and recreate database
DROP DATABASE IF EXISTS university_mgmt;
CREATE DATABASE university_mgmt 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE university_mgmt;

SET FOREIGN_KEY_CHECKS=0;
-- =====================================================
-- MASTER TABLES
-- =====================================================

-- University Master
CREATE TABLE university (
    university_id INT AUTO_INCREMENT PRIMARY KEY,
    university_name VARCHAR(255) NOT NULL,
    university_code VARCHAR(20) UNIQUE NOT NULL,
    address TEXT,
    contact_info JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_university_code (university_code)
);

-- Mode Master (Distance/Online)
CREATE TABLE mode (
    mode_id INT AUTO_INCREMENT PRIMARY KEY,
    mode_name VARCHAR(50) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_mode_active (is_active)
);

-- Regulation Master
CREATE TABLE regulation (
    regulation_id INT AUTO_INCREMENT PRIMARY KEY,
    regulation_code VARCHAR(20) UNIQUE NOT NULL,
    year INT NOT NULL,
    description TEXT,
    mode_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mode_id) REFERENCES mode(mode_id),
    INDEX idx_regulation_year (year),
    INDEX idx_regulation_mode (mode_id),
    INDEX idx_regulation_active (is_active)
);

-- Degree Master
CREATE TABLE degree (
    degree_id INT AUTO_INCREMENT PRIMARY KEY,
    degree_code VARCHAR(20) UNIQUE NOT NULL,
    degree_name VARCHAR(100) NOT NULL,
    description TEXT,
    duration_years INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_degree_code (degree_code),
    INDEX idx_degree_active (is_active)
);

-- Branch Master
CREATE TABLE branch (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(255) NOT NULL,
    branch_code VARCHAR(20) NOT NULL,
    degree_id INT NOT NULL,
    mode_id INT NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (degree_id) REFERENCES degree(degree_id),
    FOREIGN KEY (mode_id) REFERENCES mode(mode_id),
    UNIQUE KEY uk_branch_degree_mode (branch_code, degree_id, mode_id),
    INDEX idx_branch_degree (degree_id),
    INDEX idx_branch_mode (mode_id),
    INDEX idx_branch_active (is_active)
);

-- Semester Master
CREATE TABLE semester (
    semester_id INT AUTO_INCREMENT PRIMARY KEY,
    semester_number INT NOT NULL,
    semester_name VARCHAR(50),
    degree_id INT NOT NULL,
    regulation_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (degree_id) REFERENCES degree(degree_id),
    FOREIGN KEY (regulation_id) REFERENCES regulation(regulation_id),
    UNIQUE KEY uk_semester_degree_regulation (semester_number, degree_id, regulation_id),
    INDEX idx_semester_degree (degree_id),
    INDEX idx_semester_regulation (regulation_id)
);

-- Subject Master
CREATE TABLE subject (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(20) NOT NULL,
    subject_name VARCHAR(255) NOT NULL,
    credits INT NOT NULL DEFAULT 0,
    max_marks INT NOT NULL DEFAULT 100,
    semester_id INT NOT NULL,
    regulation_id INT NOT NULL,
    type ENUM('CT', 'PW') NOT NULL DEFAULT 'CT',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (semester_id) REFERENCES semester(semester_id),
    FOREIGN KEY (regulation_id) REFERENCES regulation(regulation_id),
    UNIQUE KEY uk_subject_semester_regulation (subject_code, semester_id, regulation_id),
    INDEX idx_subject_code (subject_code),
    INDEX idx_subject_semester (semester_id),
    INDEX idx_subject_regulation (regulation_id),
    INDEX idx_subject_type (type)
);

-- Academic Year Master
CREATE TABLE academic_year (
    academic_year_id INT AUTO_INCREMENT PRIMARY KEY,
    year_name VARCHAR(20) UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_academic_year_name (year_name),
    INDEX idx_academic_year_active (is_active)
);

-- Grade Classification Master
CREATE TABLE grade_classification (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_name VARCHAR(50) NOT NULL,
    min_percentage DECIMAL(5,2) NOT NULL,
    max_percentage DECIMAL(5,2) NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_grade_range (min_percentage, max_percentage)
);

-- =====================================================
-- MAIN TRANSACTION TABLES
-- =====================================================

-- Results Table
CREATE TABLE result (
    result_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reg_number VARCHAR(50) NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    subject_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    branch_id INT NOT NULL,
    semester_id INT NOT NULL,
    university_id INT NOT NULL,
    regulation_id INT NOT NULL,
    subject_code VARCHAR(20) NOT NULL,
    im_marks INT DEFAULT 0,
    um_marks VARCHAR(10) DEFAULT '0',
    total_marks INT DEFAULT 0,
    result_status ENUM('PASS', 'FAIL') NOT NULL,
    type ENUM('CT', 'PW') NOT NULL DEFAULT 'CT',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subject(subject_id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_year(academic_year_id),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id),
    FOREIGN KEY (semester_id) REFERENCES semester(semester_id),
    FOREIGN KEY (university_id) REFERENCES university(university_id),
    FOREIGN KEY (regulation_id) REFERENCES regulation(regulation_id),
    UNIQUE KEY uk_result_unique (reg_number, subject_id, academic_year_id, semester_id),
    INDEX idx_result_reg_number (reg_number),
    INDEX idx_result_student_name (student_name),
    INDEX idx_result_subject (subject_id),
    INDEX idx_result_academic_year (academic_year_id),
    INDEX idx_result_branch (branch_id),
    INDEX idx_result_semester (semester_id),
    INDEX idx_result_university (university_id),
    INDEX idx_result_regulation (regulation_id),
    INDEX idx_result_subject_code (subject_code),
    INDEX idx_result_status (result_status),
    INDEX idx_result_type (type),
    INDEX idx_result_composite (branch_id, semester_id, academic_year_id, result_status),
    INDEX idx_result_student_composite (reg_number, student_name, academic_year_id)
);

-- Student Summary Table
CREATE TABLE student_summary (
    summary_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reg_number VARCHAR(50) NOT NULL,
    student_name VARCHAR(255) NOT NULL,
    semester_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    branch_id INT NOT NULL,
    cgpa DECIMAL(4,2) DEFAULT 0.00,
    sgpa DECIMAL(4,2) DEFAULT 0.00,
    total_credits INT DEFAULT 0,
    earned_credits INT DEFAULT 0,
    overall_result ENUM('PASS', 'FAIL') NOT NULL,
    class_obtained VARCHAR(50),
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (semester_id) REFERENCES semester(semester_id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_year(academic_year_id),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id),
    UNIQUE KEY uk_student_semester_year (reg_number, semester_id, academic_year_id),
    INDEX idx_summary_reg_number (reg_number),
    INDEX idx_summary_student_name (student_name),
    INDEX idx_summary_semester (semester_id),
    INDEX idx_summary_academic_year (academic_year_id),
    INDEX idx_summary_branch (branch_id),
    INDEX idx_summary_cgpa (cgpa),
    INDEX idx_summary_result (overall_result)
);

-- =====================================================
-- TEMPORARY DATA LOAD TABLE
-- =====================================================
CREATE TABLE result_temp (
    temp_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Student info
    reg_number VARCHAR(50) NOT NULL,         
    student_name VARCHAR(255) NOT NULL,      
    
    -- Subject info
    subject_code VARCHAR(20) NOT NULL,       
    im_marks INT DEFAULT 0,                  
    um_marks VARCHAR(10),                    
    total_marks INT DEFAULT 0,               
    result_status ENUM('P','F') NOT NULL,    
    
    -- Academic info
    academic_year VARCHAR(20) NOT NULL,      
    branch_name VARCHAR(255) NOT NULL,       
    semester_number INT NOT NULL,            
    type VARCHAR(10) DEFAULT 'REG',          
    university_code VARCHAR(20) NOT NULL,    
    degree_code VARCHAR(20) NOT NULL,        
    regulation_code VARCHAR(20) NOT NULL,    
    
    -- Batch tracking
    batch_id BIGINT NOT NULL,          -- Match parent table type
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- FK constraint
    CONSTRAINT fk_result_temp_batch
        FOREIGN KEY (batch_id) REFERENCES import_batch_summary(batch_id)
        ON DELETE CASCADE
);




-- =====================================================
-- INITIAL DATA LOAD
-- =====================================================

-- Universities
REPLACE INTO university (university_name, university_code, address) VALUES 
('Anna University', 'AU', 'Chennai, Tamil Nadu'),
('Other University', 'OU', 'Location');

-- Modes
REPLACE INTO mode (mode_name, description) VALUES 
('Distance', 'Distance Learning Mode'),
('Online', 'Online Learning Mode');

-- Regulations
REPLACE INTO regulation (regulation_code, year, mode_id) VALUES 
('REG2018', 2018, 1),
('REG2023', 2023, 1),
('REG2021', 2021, 2);

-- Degrees
REPLACE INTO degree (degree_code, degree_name, duration_years) VALUES 
('MBA', 'Master of Business Administration', 2),
('MCA', 'Master of Computer Applications', 2),
('MCA3', 'Master of Computer Applications (3 Years)', 3),
('MSC', 'Master of Science (Computer Science)', 2);

-- Grade Classification
REPLACE INTO grade_classification (grade_name, min_percentage, max_percentage, description) VALUES 
('First Class with Distinction', 75.00, 100.00, 'Above 75%'),
('First Class', 60.00, 74.99, '60% to 75%'),
('Second Class', 50.00, 59.99, '50% to 60%'),
('Pass Class', 40.00, 49.99, '40% to 50%');

-- Academic Years
REPLACE INTO academic_year (year_name, start_date, end_date) VALUES 
('2020-21-June', '2020-06-01', '2022-05-31'),
('2020-21-Jan', '2021-01-01', '2022-12-31'),
('2021-22-June', '2021-06-01', '2023-05-31'),
('2021-22-Jan', '2022-01-01', '2023-12-31'),
('2022-23-June', '2022-06-01', '2024-05-31'),
('2022-23-Jan', '2023-01-01', '2024-12-31'),
('2023-24-June', '2023-06-01', '2025-05-31'),
('2023-24-Jan', '2024-01-01', '2025-12-31'),
('2024-25-June', '2024-06-01', '2026-05-31'),
('2024-25-Jan', '2025-01-01', '2026-12-31'),
('2025-26-June', '2025-06-01', '2027-05-31'),
('2025-26-Jan', '2026-01-01', '2027-12-31');

-- Branches
REPLACE INTO branch (branch_name, branch_code, degree_id, mode_id, description) VALUES 
('General Management', 'GM_DIST', 1, 1, 'MBA - General Management (Distance)'),
('Technology Management', 'TM_DIST', 1, 1, 'MBA - Technology Management (Distance)'),
('Marketing Management', 'MM_DIST', 1, 1, 'MBA - Marketing Management (Distance)'),
('Human Resource Management', 'HRM_DIST', 1, 1, 'MBA - Human Resource Management (Distance)'),
('Financial Service Management', 'FSM_DIST', 1, 1, 'MBA - Financial Service Management (Distance)'),
('Health Service Management', 'HSM_DIST', 1, 1, 'MBA - Health Service Management (Distance)'),
('Operations Management', 'OM_DIST', 1, 1, 'MBA - Operations Management (Distance)'),
('MCA 2 Years', 'MCA2_DIST', 2, 1, 'MCA 2 Years (Distance)'),
('MCA 3 Years', 'MCA3_DIST', 3, 1, 'MCA 3 Years (Distance)'),
('MSC Computer Science', 'MSC_CS_DIST', 4, 1, 'MSc Computer Science (Distance)'),
('Business Analytics', 'BA_ON', 1, 2, 'MBA - Business Analytics (Online)'),
('General Management', 'GM_ON', 1, 2, 'MBA - General Management (Online)');

-- =====================================================
-- MBA (4 Semesters)
-- =====================================================
REPLACE INTO semester (semester_number, semester_name, degree_id, regulation_id) VALUES
-- REG2018
(1, 'Semester 1', 1, 1), (2, 'Semester 2', 1, 1), (3, 'Semester 3', 1, 1), (4, 'Semester 4', 1, 1),
-- REG2023
(1, 'Semester 1', 1, 2), (2, 'Semester 2', 1, 2), (3, 'Semester 3', 1, 2), (4, 'Semester 4', 1, 2),
-- REG2021
(1, 'Semester 1', 1, 3), (2, 'Semester 2', 1, 3), (3, 'Semester 3', 1, 3), (4, 'Semester 4', 1, 3);

-- =====================================================
-- MCA 2 Years (4 Semesters)
-- =====================================================
REPLACE INTO semester (semester_number, semester_name, degree_id, regulation_id) VALUES
-- REG2018
(1, 'Semester 1', 2, 1), (2, 'Semester 2', 2, 1), (3, 'Semester 3', 2, 1), (4, 'Semester 4', 2, 1),
-- REG2023
(1, 'Semester 1', 2, 2), (2, 'Semester 2', 2, 2), (3, 'Semester 3', 2, 2), (4, 'Semester 4', 2, 2),
-- REG2021
(1, 'Semester 1', 2, 3), (2, 'Semester 2', 2, 3), (3, 'Semester 3', 2, 3), (4, 'Semester 4', 2, 3);

-- =====================================================
-- MCA 3 Years (6 Semesters)
-- =====================================================
REPLACE INTO semester (semester_number, semester_name, degree_id, regulation_id) VALUES
-- REG2018
(1, 'Semester 1', 3, 1), (2, 'Semester 2', 3, 1), (3, 'Semester 3', 3, 1),
(4, 'Semester 4', 3, 1), (5, 'Semester 5', 3, 1), (6, 'Semester 6', 3, 1),
-- REG2023
(1, 'Semester 1', 3, 2), (2, 'Semester 2', 3, 2), (3, 'Semester 3', 3, 2),
(4, 'Semester 4', 3, 2), (5, 'Semester 5', 3, 2), (6, 'Semester 6', 3, 2),
-- REG2021
(1, 'Semester 1', 3, 3), (2, 'Semester 2', 3, 3), (3, 'Semester 3', 3, 3),
(4, 'Semester 4', 3, 3), (5, 'Semester 5', 3, 3), (6, 'Semester 6', 3, 3);

-- =====================================================
-- MSc Computer Science (4 Semesters)
-- =====================================================
REPLACE INTO semester (semester_number, semester_name, degree_id, regulation_id) VALUES
-- REG2018
(1, 'Semester 1', 4, 1), (2, 'Semester 2', 4, 1), (3, 'Semester 3', 4, 1), (4, 'Semester 4', 4, 1),
-- REG2023
(1, 'Semester 1', 4, 2), (2, 'Semester 2', 4, 2), (3, 'Semester 3', 4, 2), (4, 'Semester 4', 4, 2),
-- REG2021
(1, 'Semester 1', 4, 3), (2, 'Semester 2', 4, 3), (3, 'Semester 3', 4, 3), (4, 'Semester 4', 4, 3);

------------------------------------------------------------------------------------
-- Subjects oer course
------------------------------------------------------------------------------------

--MSC-2018
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5101', 'Computer Organization', 2, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5102', 'Problem Solving and Programming', 2, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5103', 'Database Management System', 2, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5104', 'Software Engineering', 2, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5105', 'Mathematical Foundation for Computer Science', 4, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5106', 'Computer Programming Lab', 2, 100, 1, 1, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5201', 'Data Structures', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5202', 'Operating Systems', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5203', 'Computer Networks', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5204', 'Artificial Intelligence', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5205', 'Data Structures Lab', 2, 100, 2, 1, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5301', 'Compiler Design', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5302', 'Machine Learning', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5303', 'Web Technology', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5304', 'Mobile Computing', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5305', 'Web Technology Lab', 2, 100, 3, 1, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5401', 'Cryptography and Network Security', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5402', 'Cloud Computing', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5403', 'Big Data Analytics', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5404', 'Internet of Things', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5405', 'Big Data Analytics Lab', 2, 100, 4, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS5406', 'Project Work', 6, 100, 4, 1, 'PW', TRUE);

--MSC-2023
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8101', 'Computer Organization', 4, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8102', 'Python Programming', 3, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8103', 'Advanced Database Technology', 4, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8104', 'Object Oriented Software Engineering', 3, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8105', 'Mathematical Foundations of Computer Science', 4, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8106', 'Python Programming Lab', 2, 100, 1, 2, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8201', 'Data Structures and Algorithms', 4, 100, 2, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8202', 'Operating Systems', 3, 100, 2, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8203', 'Computer Networks', 4, 100, 2, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8204', 'Artificial Intelligence and Machine Learning', 4, 100, 2, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8205', 'Data Structures and Algorithms Lab', 2, 100, 2, 2, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8301', 'Compiler Design', 4, 100, 3, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8302', 'Deep Learning', 4, 100, 3, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8303', 'Web Technology', 3, 100, 3, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8304', 'Mobile Application Development', 3, 100, 3, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8305', 'Web Technology Lab', 2, 100, 3, 2, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8401', 'Cyber Security', 3, 100, 4, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8402', 'Cloud Computing', 4, 100, 4, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8403', 'Big Data Analytics', 4, 100, 4, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8404', 'Internet of Things', 4, 100, 4, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8405', 'Mini Project', 2, 100, 4, 2, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DCS8406', 'Major Project Work', 6, 100, 4, 2, 'PW', TRUE);

--MCA-2018(2YRS)
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5101', 'Mathematical Foundation for Computer Applications', 4, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5102', 'Problem Solving and Programming', 4, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5103', 'Digital Computer Fundamentals', 4, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5104', 'Database Management Systems', 4, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5105', 'Accounting and Financial Management', 4, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5106', 'Problem Solving and Programming Lab', 2, 100, 1, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5107', 'Database Management Systems Lab', 2, 100, 1, 1, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5201', 'Data Structures', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5202', 'Computer Architecture', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5203', 'Operating Systems', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5204', 'Object Oriented Programming', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5205', 'Data Structures Lab', 2, 100, 2, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5206', 'Object Oriented Programming Lab', 2, 100, 2, 1, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5301', 'Design and Analysis of Algorithms', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5302', 'Computer Networks', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5303', 'Software Engineering', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5304', 'Programming in Java', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5305', 'Java Programming Lab', 2, 100, 3, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5306', 'Operating Systems Lab', 2, 100, 3, 1, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5401', 'Advanced Java Programming', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5402', 'Compiler Design', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5403', 'Advanced Operating Systems', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5404', 'Web Technology', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5405', 'Web Technology Lab', 2, 100, 4, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA5406', 'Mini Project', 2, 100, 4, 1, 'PW', TRUE);

--MCA-2018(3YRS)
-- SEMESTER 1
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5101', 'Mathematical Foundations of Computer Science', 4, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5102', 'Problem Solving and Programming', 2, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5103', 'Database Management System', 2, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5104', 'Software Engineering', 2, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5105', 'Computer Organization & Design', 2, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5111', 'Programming Lab', 2, 100, 1, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5112', 'Database Management System Lab', 2, 100, 1, 1, 'PW', TRUE);

-- SEMESTER 2
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5201', 'Computer Networks', 4, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5202', 'Operating System', 2, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5203', 'Data Structures and Algorithms', 2, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5204', 'Computer Graphics and Multimedia Systems', 2, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5205', 'Object Oriented Programming', 2, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5211', 'Data Structures using C++ Lab', 2, 100, 2, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5212', 'Operating System Lab', 2, 100, 2, 1, 'PW', TRUE);

-- SEMESTER 3
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5301', 'Web Programming', 2, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5302', 'Object Oriented Analysis and Design', 2, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5303', 'Data Warehousing and Mining', 4, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5304', 'Security Practice', 2, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('E1', 'Elective I', 2, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5311', 'Security Lab', 2, 100, 3, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5312', 'Web Programming Lab', 2, 100, 3, 1, 'PW', TRUE);

-- SEMESTER 4
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5401', 'Unix and Network Programming', 4, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5402', 'Enterprise Application Development', 2, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5403', '.NET Programming', 2, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('E2', 'Elective II', 2, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('E3', 'Elective III', 2, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5411', 'Enterprise Application Development Lab', 2, 100, 4, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5412', '.NET Programming Lab', 2, 100, 4, 1, 'PW', TRUE);

-- SEMESTER 5
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5501', 'Web Services', 2, 100, 5, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5502', 'Software Project Management', 4, 100, 5, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5503', 'Mobile Application Development', 2, 100, 5, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5504', 'Communication Skills', 2, 100, 5, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('E4', 'Elective IV', 2, 100, 5, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5511', 'Web Services Lab', 2, 100, 5, 1, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5512', 'Mobile Application Development Lab', 2, 100, 5, 1, 'PW', TRUE);

-- SEMESTER 6
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('E5', 'Elective V', 2, 100, 6, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5601', 'Cloud Services', 2, 100, 6, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('DMC5611', 'Project Work', 12, 100, 6, 1, 'PW', TRUE);

--MCA-2023
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8101', 'Mathematical Foundations of Computer Applications', 4, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8102', 'Python Programming', 4, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8103', 'Computer Architecture', 3, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8104', 'Database Management Systems', 3, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8105', 'Accounting and Financial Management', 3, 100, 1, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8106', 'Python Programming Lab', 2, 100, 1, 2, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8107', 'Database Management Systems Lab', 2, 100, 1, 2, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8201', 'Data Structures and Algorithms', 4, 100, 2, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8202', 'Operating Systems', 3, 100, 2, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8203', 'Object Oriented Programming in Java', 4, 100, 2, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8204', 'Computer Networks', 3, 100, 2, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8205', 'Data Structures and Algorithms Lab', 2, 100, 2, 2, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8206', 'Java Programming Lab', 2, 100, 2, 2, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8301', 'Design and Analysis of Algorithms', 4, 100, 3, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8302', 'Software Engineering', 3, 100, 3, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8303', 'Artificial Intelligence and Machine Learning', 4, 100, 3, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8304', 'Compiler Design', 3, 100, 3, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8305', 'AI & ML Lab', 2, 100, 3, 2, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8306', 'Operating Systems Lab', 2, 100, 3, 2, 'PW', TRUE);

REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8401', 'Advanced Web Technology', 4, 100, 4, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8402', 'Cloud Computing', 3, 100, 4, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8403', 'Big Data Analytics', 3, 100, 4, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8404', 'Internet of Things', 3, 100, 4, 2, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8405', 'Web Technology Lab', 2, 100, 4, 2, 'PW', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('MCA8406', 'Major Project Work', 6, 100, 4, 2, 'PW', TRUE);
--MBA-BA(ONLINE)
-- SEMESTER 1
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1101', 'Management Concepts and Organization Behavior', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1102', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1103', 'Human Resource Management', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1104', 'Marketing Management', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1105', 'Financial Management', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1106', 'Operations Management', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1107', 'Statistical Methods for Decision Making', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1108', 'R Programming', 3, 100, 1, 1, 'CT', TRUE);

-- SEMESTER 2
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1201', 'Data Mining and Business Intelligence', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1202', 'Multivariate Data Analysis', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1203', 'Legal Aspects for Business', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1204', 'Python Programming', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1205', 'Time Series Analysis', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1206', 'Big Data Analytics', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1207', 'Optimization Techniques', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1208', 'Stochastic Modeling', 3, 100, 2, 1, 'CT', TRUE);

-- SEMESTER 3
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1301', 'Enterprise Information System', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1302', 'Block Chain Technology', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1303', 'Business Analytics', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1304', 'Cloud Computing', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1305', 'Human Resource Analytics', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1306', 'Marketing and Social Media Web Analytics', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1307', 'Financial Analytics', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1308', 'Operations and Supply Chain Analytics', 3, 100, 3, 1, 'CT', TRUE);

-- SEMESTER 4
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1401', 'Artificial Intelligence', 3, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1402', 'Machine Learning', 3, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES ('OBA1403', 'Project Work', 12, 100, 4, 1, 'PW', TRUE);


--MBA-GM(ONLINE)
-- SEMESTER 1
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1101', 'Management Concepts and Organization Behavior', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1107', 'Statistical Methods for Decision Making', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1102', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1101', 'Accounting for Decision Making', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1203', 'Legal Aspects for Business', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1102', 'Communication Skills', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1104', 'Marketing Management', 3, 100, 1, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1103', 'Entrepreneurship Development', 3, 100, 1, 1, 'CT', TRUE);
-- SEMESTER 2
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1105', 'Financial Management', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1106', 'Operations Management', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1103', 'Human Resource Management', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1301', 'Enterprise Information System', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1207', 'Optimization Techniques', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1201', 'Business Research Methods', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1303', 'Business Analytics', 3, 100, 2, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1202', 'Event Management', 3, 100, 2, 1, 'CT', TRUE);
-- SEMESTER 3
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1301', 'Supply Chain Management', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1308', 'Operations and Supply Chain Analytics', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1302', 'Security Analysis and Portfolio Management', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1307', 'Financial Analytics', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1303', 'Integrated Marketing Communication', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1306', 'Marketing and Social Media Web Analytics', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1304', 'Strategic Human Resource Management', 3, 100, 3, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OBA1305', 'Human Resource Analytics', 3, 100, 3, 1, 'CT', TRUE);
-- SEMESTER 4
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1401', 'Strategic Management', 3, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1402', 'International Business', 3, 100, 4, 1, 'CT', TRUE);
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES 
('OGM1403', 'Project Work', 12, 100, 4, 1, 'PW', TRUE);
--MBA-2018
--GM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA5101', 'Management Concepts', 2, 100, 1, 1, 'CT', TRUE),
('DBA5102', 'Statistics for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5103', 'Economic Analysis for Business', 2, 100, 1, 1, 'CT', TRUE),
('DBA5104', 'Organizational Behaviour', 2, 100, 1, 1, 'CT', TRUE),
('DBA5105', 'Communication Skills', 2, 100, 1, 1, 'CT', TRUE),
('DBA5106', 'Accounting for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5107', 'Legal Aspects of Business', 2, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA5201', 'Production & Operations Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5202', 'Marketing Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA5203', 'Human Resource Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5204', 'Financial Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5205', 'Information Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5206', 'Quality Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5207', 'Business Research Methods', 4, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA5301', 'Applied Operations Research', 4, 100, 3, 1, 'CT', TRUE),
('DBA5302', 'International Business Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA5304', 'Enterprise Resource Planning', 2, 100, 3, 1, 'CT', TRUE),
('DBA5001', 'Integrated Marketing Communications', 2, 100, 3, 1, 'CT', TRUE),
('DBA5002', 'Consumer Behaviour', 2, 100, 3, 1, 'CT', TRUE),
('DBA5003', 'Training and Development', 2, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA5004', 'Industrial Relations and Labour Welfare', 2, 100, 4, 1, 'CT', TRUE),
('DBA5005', 'Strategic Investment and Financing Decisions', 2, 100, 4, 1, 'CT', TRUE),
('DBA5006', 'Indian Banking Financial System', 2, 100, 4, 1, 'CT', TRUE),
('DBA5007', 'Supply Chain Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5008', 'Materials Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5411', 'Project Work in the relevant specialization', 8, 200, 4, 1, 'PW', TRUE);
--TM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA5101', 'Management Concepts', 2, 100, 1, 1, 'CT', TRUE),
('DBA5102', 'Statistics for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5103', 'Economic Analysis for Business', 2, 100, 1, 1, 'CT', TRUE),
('DBA5104', 'Organizational Behaviour', 2, 100, 1, 1, 'CT', TRUE),
('DBA5105', 'Communication Skills', 2, 100, 1, 1, 'CT', TRUE),
('DBA5106', 'Accounting for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5107', 'Legal Aspects of Business', 2, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA5201', 'Production & Operations Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5202', 'Marketing Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA5203', 'Human Resource Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5204', 'Financial Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5205', 'Information Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5206', 'Quality Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5207', 'Business Research Methods', 4, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA5301', 'Applied Operations Research', 4, 100, 3, 1, 'CT', TRUE),
('DBA5302', 'International Business Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA5304', 'Enterprise Resource Planning', 2, 100, 3, 1, 'CT', TRUE),
('DBA5011', 'Technology Forecasting and Assessment', 2, 100, 3, 1, 'CT', TRUE),
('DBA5012', 'Technology Commercialization & Transfer', 2, 100, 3, 1, 'CT', TRUE),
('DBA5013', 'Research & Development Management', 2, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA5014', 'Intellectual Property Rights', 2, 100, 4, 1, 'CT', TRUE),
('DBA5015', 'Managing Technological Innovation', 2, 100, 4, 1, 'CT', TRUE),
('DBA5016', 'E-Business Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5017', 'Software Project & Quality Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5018', 'Data Mining & Business Intelligence', 2, 100, 4, 1, 'CT', TRUE),
('DBA5411', 'Project Work in the relevant specialization', 8, 200, 4, 1, 'PW', TRUE);
--MM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA5101', 'Management Concepts', 2, 100, 1, 1, 'CT', TRUE),
('DBA5102', 'Statistics for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5103', 'Economic Analysis for Business', 2, 100, 1, 1, 'CT', TRUE),
('DBA5104', 'Organizational Behaviour', 2, 100, 1, 1, 'CT', TRUE),
('DBA5105', 'Communication Skills', 2, 100, 1, 1, 'CT', TRUE),
('DBA5106', 'Accounting for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5107', 'Legal Aspects of Business', 2, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA5201', 'Production & Operations Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5202', 'Marketing Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA5203', 'Human Resource Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5204', 'Financial Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5205', 'Information Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5206', 'Quality Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5207', 'Business Research Methods', 4, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA5301', 'Applied Operations Research', 4, 100, 3, 1, 'CT', TRUE),
('DBA5302', 'International Business Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA5304', 'Enterprise Resource Planning', 2, 100, 3, 1, 'CT', TRUE),
('DBA5061', 'Marketing Research', 2, 100, 3, 1, 'CT', TRUE),
('DBA5062', 'Brand Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5063', 'Retail Management', 2, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA5064', 'Services Marketing', 2, 100, 4, 1, 'CT', TRUE),
('DBA5001', 'Integrated Marketing Communications', 2, 100, 4, 1, 'CT', TRUE),
('DBA5002', 'Consumer Behaviour', 2, 100, 4, 1, 'CT', TRUE),
('DBA5065', 'Customer Relationship Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5066', 'Marketing Analytics', 2, 100, 4, 1, 'CT', TRUE),
('DBA5411', 'Project Work in the relevant specialization', 8, 200, 4, 1, 'PW', TRUE);
--HRM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA5101', 'Management Concepts', 2, 100, 1, 1, 'CT', TRUE),
('DBA5102', 'Statistics for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5103', 'Economic Analysis for Business', 2, 100, 1, 1, 'CT', TRUE),
('DBA5104', 'Organizational Behaviour', 2, 100, 1, 1, 'CT', TRUE),
('DBA5105', 'Communication Skills', 2, 100, 1, 1, 'CT', TRUE),
('DBA5106', 'Accounting for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5107', 'Legal Aspects of Business', 2, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA5201', 'Production & Operations Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5202', 'Marketing Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA5203', 'Human Resource Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5204', 'Financial Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5205', 'Information Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5206', 'Quality Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5207', 'Business Research Methods', 4, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA5301', 'Applied Operations Research', 4, 100, 3, 1, 'CT', TRUE),
('DBA5302', 'International Business Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA5304', 'Enterprise Resource Planning', 2, 100, 3, 1, 'CT', TRUE),
('DBA5021', 'Managerial Behaviour and Effectiveness', 2, 100, 3, 1, 'CT', TRUE),
('DBA5022', 'Strategic HRM & Development', 2, 100, 3, 1, 'CT', TRUE),
('DBA5023', 'Performance Management', 2, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA5003', 'Training and Development', 2, 100, 4, 1, 'CT', TRUE),
('DBA5004', 'Industrial Relations and Labour Welfare', 2, 100, 4, 1, 'CT', TRUE),
('DBA5024', 'Organizational Theory, Design and Development', 2, 100, 4, 1, 'CT', TRUE),
('DBA5025', 'Social Psychology', 2, 100, 4, 1, 'CT', TRUE),
('DBA5026', 'Stress Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5411', 'Project Work in the relevant specialization', 8, 200, 4, 1, 'PW', TRUE);

--FSM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA5101', 'Management Concepts', 2, 100, 1, 1, 'CT', TRUE),
('DBA5102', 'Statistics for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5103', 'Economic Analysis for Business', 2, 100, 1, 1, 'CT', TRUE),
('DBA5104', 'Organizational Behaviour', 2, 100, 1, 1, 'CT', TRUE),
('DBA5105', 'Communication Skills', 2, 100, 1, 1, 'CT', TRUE),
('DBA5106', 'Accounting for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5107', 'Legal Aspects of Business', 2, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA5201', 'Production & Operations Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5202', 'Marketing Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA5203', 'Human Resource Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5204', 'Financial Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5205', 'Information Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5206', 'Quality Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5207', 'Business Research Methods', 4, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA5301', 'Applied Operations Research', 4, 100, 3, 1, 'CT', TRUE),
('DBA5302', 'International Business Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA5304', 'Enterprise Resource Planning', 2, 100, 3, 1, 'CT', TRUE),
('DBA5006', 'Indian Banking Financial System', 2, 100, 3, 1, 'CT', TRUE),
('DBA5031', 'Security Analysis and Portfolio Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5032', 'Hire Purchasing, Leasing and Venture Capital', 2, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA5033', 'Insurance & Risk Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5034', 'International Trade Finance', 2, 100, 4, 1, 'CT', TRUE),
('DBA5035', 'Financial Derivatives Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5005', 'Strategic Investment and Financing Decisions', 2, 100, 4, 1, 'CT', TRUE),
('DBA5036', 'Entrepreneurial Finance', 2, 100, 4, 1, 'CT', TRUE),
('DBA5411', 'Project Work in the relevant specialization', 8, 200, 4, 1, 'PW', TRUE);
--HSM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA5101', 'Management Concepts', 2, 100, 1, 1, 'CT', TRUE),
('DBA5102', 'Statistics for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5103', 'Economic Analysis for Business', 2, 100, 1, 1, 'CT', TRUE),
('DBA5104', 'Organizational Behaviour', 2, 100, 1, 1, 'CT', TRUE),
('DBA5105', 'Communication Skills', 2, 100, 1, 1, 'CT', TRUE),
('DBA5106', 'Accounting for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5107', 'Legal Aspects of Business', 2, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA5201', 'Production & Operations Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5202', 'Marketing Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA5203', 'Human Resource Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5204', 'Financial Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5205', 'Information Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5208', 'Services Quality Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5207', 'Business Research Methods', 4, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA5301', 'Applied Operations Research', 4, 100, 3, 1, 'CT', TRUE),
('DBA5302', 'International Business Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA5304', 'Enterprise Resource Planning', 2, 100, 3, 1, 'CT', TRUE),
('DBA5041', 'Materials Management & Logistics in Health Care', 2, 100, 3, 1, 'CT', TRUE),
('DBA5042', 'Management of Health Care Services', 2, 100, 3, 1, 'CT', TRUE),
('DBA5043', 'Health Insurance', 2, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA5044', 'Legal Aspects of Health Care', 2, 100, 4, 1, 'CT', TRUE),
('DBA5045', 'International Health Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5046', 'Medical Equipment Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5047', 'Medical Tourism', 2, 100, 4, 1, 'CT', TRUE),
('DBA5048', 'Medical Waste Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5411', 'Project Work in the relevant specialization', 8, 200, 4, 1, 'PW', TRUE);
--H&T
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA5101', 'Management Concepts', 2, 100, 1, 1, 'CT', TRUE),
('DBA5102', 'Statistics for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5103', 'Economic Analysis for Business', 2, 100, 1, 1, 'CT', TRUE),
('DBA5104', 'Organizational Behaviour', 2, 100, 1, 1, 'CT', TRUE),
('DBA5105', 'Communication Skills', 2, 100, 1, 1, 'CT', TRUE),
('DBA5106', 'Accounting for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5107', 'Legal Aspects of Business', 2, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA5201', 'Production & Operations Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5202', 'Marketing Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA5203', 'Human Resource Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5204', 'Financial Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5205', 'Information Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5208', 'Services Quality Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5207', 'Business Research Methods', 4, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA5301', 'Applied Operations Research', 4, 100, 3, 1, 'CT', TRUE),
('DBA5302', 'International Business Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA5304', 'Enterprise Resource Planning', 2, 100, 3, 1, 'CT', TRUE),
('DBA5051', 'Culture and Ethos', 2, 100, 3, 1, 'CT', TRUE),
('DBA5052', 'Room Division Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5053', 'Tourism and Travel Management', 2, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA5054', 'Food and Beverage Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5055', 'Event Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5056', 'Facility and Security Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5057', 'Food Safety and Quality', 2, 100, 4, 1, 'CT', TRUE),
('DBA5058', 'Destination Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5411', 'Project Work in the relevant specialization', 8, 200, 4, 1, 'PW', TRUE);


--OM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA5101', 'Management Concepts', 2, 100, 1, 1, 'CT', TRUE),
('DBA5102', 'Statistics for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5103', 'Economic Analysis for Business', 2, 100, 1, 1, 'CT', TRUE),
('DBA5104', 'Organizational Behaviour', 2, 100, 1, 1, 'CT', TRUE),
('DBA5105', 'Communication Skills', 2, 100, 1, 1, 'CT', TRUE),
('DBA5106', 'Accounting for Management', 4, 100, 1, 1, 'CT', TRUE),
('DBA5107', 'Legal Aspects of Business', 2, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA5201', 'Production & Operations Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5202', 'Marketing Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA5203', 'Human Resource Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5204', 'Financial Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5205', 'Information Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5206', 'Quality Management', 2, 100, 2, 1, 'CT', TRUE),
('DBA5207', 'Business Research Methods', 4, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA5301', 'Applied Operations Research', 4, 100, 3, 1, 'CT', TRUE),
('DBA5302', 'International Business Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA5304', 'Enterprise Resource Planning', 2, 100, 3, 1, 'CT', TRUE),
('DBA5007', 'Supply Chain Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5071', 'Logistics Management', 2, 100, 3, 1, 'CT', TRUE),
('DBA5072', 'Product Design & Development', 2, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA5073', 'Project Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5074', 'Robust Design', 2, 100, 4, 1, 'CT', TRUE),
('DBA5075', 'Business Process Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5008', 'Materials Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5076', 'Maintenance Management', 2, 100, 4, 1, 'CT', TRUE),
('DBA5411', 'Project Work in the relevant specialization', 8, 200, 4, 1, 'PW', TRUE);

--MBA-2023
--GM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA8101', 'Management Concepts and Organization Behavior', 4, 100, 1, 1, 'CT', TRUE),
('DBA8102', 'Statistical Methods for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8103', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE),
('DBA8104', 'Accounting for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8105', 'Legal Aspects for Business', 3, 100, 1, 1, 'CT', TRUE),
('DBA8106', 'Communication Skills', 3, 100, 1, 1, 'CT', TRUE),
('DBA8107', 'Entrepreneurship Development', 3, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA8201', 'Financial Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8202', 'Operations Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8203', 'Human Resource Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8204', 'Information Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8205', 'Quantitative Techniques for Decision Making', 4, 100, 2, 1, 'CT', TRUE),
('DBA8206', 'Marketing Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8207', 'Event Management', 3, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA8301', 'Business Research Methods', 4, 100, 3, 1, 'CT', TRUE),
('DBA8302', 'International Business', 4, 100, 3, 1, 'CT', TRUE),
('DBA8303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA8001', 'Consumer Behaviour', 3, 100, 3, 1, 'CT', TRUE),
('DBA8002', 'Strategic Human Resource Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8003', 'Indian Banking Financial System', 3, 100, 3, 1, 'CT', TRUE),
('DBA8004', 'Supply Chain Management', 3, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA8005', 'Business Analytics', 3, 100, 4, 1, 'CT', TRUE),
('DBA8006', 'Managing Technology Innovation', 3, 100, 4, 1, 'CT', TRUE),
('DBA8411', 'Project Work', 12, 400, 4, 1, 'PW', TRUE);
--MM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA8101', 'Management Concepts and Organization Behavior', 4, 100, 1, 1, 'CT', TRUE),
('DBA8102', 'Statistical Methods for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8103', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE),
('DBA8104', 'Accounting for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8105', 'Legal Aspects for Business', 3, 100, 1, 1, 'CT', TRUE),
('DBA8106', 'Communication Skills', 3, 100, 1, 1, 'CT', TRUE),
('DBA8107', 'Entrepreneurship Development', 3, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA8201', 'Financial Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8202', 'Operations Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8203', 'Human Resource Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8204', 'Information Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8205', 'Quantitative Techniques for Decision Making', 4, 100, 2, 1, 'CT', TRUE),
('DBA8206', 'Marketing Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8207', 'Event Management', 3, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA8301', 'Business Research Methods', 4, 100, 3, 1, 'CT', TRUE),
('DBA8302', 'International Business', 4, 100, 3, 1, 'CT', TRUE),
('DBA8303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA8007', 'Retail Marketing', 3, 100, 3, 1, 'CT', TRUE),
('DBA8001', 'Consumer Behaviour', 3, 100, 3, 1, 'CT', TRUE),
('DBA8008', 'Product & Brand Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8009', 'Integrated Marketing Communication', 3, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA8010', 'Customer Engagement Marketing', 3, 100, 4, 1, 'CT', TRUE),
('DBA8011', 'Digital Marketing', 3, 100, 4, 1, 'CT', TRUE),
('DBA8411', 'Project Work', 12, 400, 4, 1, 'PW', TRUE);
--HR M
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA8101', 'Management Concepts and Organization Behavior', 4, 100, 1, 1, 'CT', TRUE),
('DBA8102', 'Statistical Methods for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8103', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE),
('DBA8104', 'Accounting for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8105', 'Legal Aspects for Business', 3, 100, 1, 1, 'CT', TRUE),
('DBA8106', 'Communication Skills', 3, 100, 1, 1, 'CT', TRUE),
('DBA8107', 'Entrepreneurship Development', 3, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA8201', 'Financial Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8202', 'Operations Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8203', 'Human Resource Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8204', 'Information Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8205', 'Quantitative Techniques for Decision Making', 4, 100, 2, 1, 'CT', TRUE),
('DBA8206', 'Marketing Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8207', 'Event Management', 3, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA8301', 'Business Research Methods', 4, 100, 3, 1, 'CT', TRUE),
('DBA8302', 'International Business', 4, 100, 3, 1, 'CT', TRUE),
('DBA8303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA8012', 'Training & Development', 3, 100, 3, 1, 'CT', TRUE),
('DBA8013', 'Performance Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8014', 'Emotional Intelligence for Managerial Effectiveness', 3, 100, 3, 1, 'CT', TRUE),
('DBA8002', 'Strategic Human Resource Management', 3, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA8015', 'Talent Management', 3, 100, 4, 1, 'CT', TRUE),
('DBA8016', 'Industrial Relations and Labour Legislations', 3, 100, 4, 1, 'CT', TRUE),
('DBA8411', 'Project Work', 12, 400, 4, 1, 'PW', TRUE);
--FM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA8101', 'Management Concepts and Organization Behavior', 4, 100, 1, 1, 'CT', TRUE),
('DBA8102', 'Statistical Methods for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8103', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE),
('DBA8104', 'Accounting for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8105', 'Legal Aspects for Business', 3, 100, 1, 1, 'CT', TRUE),
('DBA8106', 'Communication Skills', 3, 100, 1, 1, 'CT', TRUE),
('DBA8107', 'Entrepreneurship Development', 3, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA8201', 'Financial Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8202', 'Operations Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8203', 'Human Resource Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8204', 'Information Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8205', 'Quantitative Techniques for Decision Making', 4, 100, 2, 1, 'CT', TRUE),
('DBA8206', 'Marketing Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8207', 'Event Management', 3, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA8301', 'Business Research Methods', 4, 100, 3, 1, 'CT', TRUE),
('DBA8302', 'International Business', 4, 100, 3, 1, 'CT', TRUE),
('DBA8303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA8003', 'Indian Banking Financial System', 3, 100, 3, 1, 'CT', TRUE),
('DBA8017', 'Financial Planning and Wealth Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8018', 'Security Analysis & Portfolio Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8019', 'Financial Derivatives', 3, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA8020', 'Behavioural Finance', 3, 100, 4, 1, 'CT', TRUE),
('DBA8021', 'International Finance', 3, 100, 4, 1, 'CT', TRUE),
('DBA8411', 'Project Work', 12, 400, 4, 1, 'PW', TRUE);
--TM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA8101', 'Management Concepts and Organization Behavior', 4, 100, 1, 1, 'CT', TRUE),
('DBA8102', 'Statistical Methods for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8103', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE),
('DBA8104', 'Accounting for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8105', 'Legal Aspects for Business', 3, 100, 1, 1, 'CT', TRUE),
('DBA8106', 'Communication Skills', 3, 100, 1, 1, 'CT', TRUE),
('DBA8107', 'Entrepreneurship Development', 3, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA8201', 'Financial Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8202', 'Operations Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8203', 'Human Resource Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8204', 'Information Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8205', 'Quantitative Techniques for Decision Making', 4, 100, 2, 1, 'CT', TRUE),
('DBA8206', 'Marketing Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8207', 'Event Management', 3, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA8301', 'Business Research Methods', 4, 100, 3, 1, 'CT', TRUE),
('DBA8302', 'International Business', 4, 100, 3, 1, 'CT', TRUE),
('DBA8303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA8022', 'Technology Forecasting Assessment', 3, 100, 3, 1, 'CT', TRUE),
('DBA8023', 'Technology Commercialization & Transfer', 3, 100, 3, 1, 'CT', TRUE),
('DBA8024', 'E- Business Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8006', 'Managing Technology Innovation', 3, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA8025', 'Intellectual Property Rights', 3, 100, 4, 1, 'CT', TRUE),
('DBA8026', 'Research and Development Management', 3, 100, 4, 1, 'CT', TRUE),
('DBA8411', 'Project Work', 12, 400, 4, 1, 'PW', TRUE);
--OM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA8101', 'Management Concepts and Organization Behavior', 4, 100, 1, 1, 'CT', TRUE),
('DBA8102', 'Statistical Methods for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8103', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE),
('DBA8104', 'Accounting for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8105', 'Legal Aspects for Business', 3, 100, 1, 1, 'CT', TRUE),
('DBA8106', 'Communication Skills', 3, 100, 1, 1, 'CT', TRUE),
('DBA8107', 'Entrepreneurship Development', 3, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA8201', 'Financial Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8202', 'Operations Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8203', 'Human Resource Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8204', 'Information Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8205', 'Quantitative Techniques for Decision Making', 4, 100, 2, 1, 'CT', TRUE),
('DBA8206', 'Marketing Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8207', 'Event Management', 3, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA8301', 'Business Research Methods', 4, 100, 3, 1, 'CT', TRUE),
('DBA8302', 'International Business', 4, 100, 3, 1, 'CT', TRUE),
('DBA8303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA8027', 'Product Design and Development', 3, 100, 3, 1, 'CT', TRUE),
('DBA8028', 'Materials Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8004', 'Supply Chain Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8029', 'Services Operations Management', 3, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA8030', 'Project Management', 3, 100, 4, 1, 'CT', TRUE),
('DBA8031', 'Logistics Management', 3, 100, 4, 1, 'CT', TRUE),
('DBA8411', 'Project Work', 12, 400, 4, 1, 'PW', TRUE);
--HCM
-- Insert all DBA subjects
REPLACE INTO subject (subject_code, subject_name, credits, max_marks, semester_id, regulation_id, type, is_active) VALUES
-- SEMESTER I
('DBA8101', 'Management Concepts and Organization Behavior', 4, 100, 1, 1, 'CT', TRUE),
('DBA8102', 'Statistical Methods for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8103', 'Managerial Economics', 3, 100, 1, 1, 'CT', TRUE),
('DBA8104', 'Accounting for Decision Making', 4, 100, 1, 1, 'CT', TRUE),
('DBA8105', 'Legal Aspects for Business', 3, 100, 1, 1, 'CT', TRUE),
('DBA8106', 'Communication Skills', 3, 100, 1, 1, 'CT', TRUE),
('DBA8107', 'Entrepreneurship Development', 3, 100, 1, 1, 'CT', TRUE),

-- SEMESTER II
('DBA8201', 'Financial Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8202', 'Operations Management', 4, 100, 2, 1, 'CT', TRUE),
('DBA8203', 'Human Resource Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8204', 'Information Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8205', 'Quantitative Techniques for Decision Making', 4, 100, 2, 1, 'CT', TRUE),
('DBA8206', 'Marketing Management', 3, 100, 2, 1, 'CT', TRUE),
('DBA8207', 'Event Management', 3, 100, 2, 1, 'CT', TRUE),

-- SEMESTER III
('DBA8301', 'Business Research Methods', 4, 100, 3, 1, 'CT', TRUE),
('DBA8302', 'International Business', 4, 100, 3, 1, 'CT', TRUE),
('DBA8303', 'Strategic Management', 4, 100, 3, 1, 'CT', TRUE),
('DBA8032', 'Hospital Planning and Administration', 3, 100, 3, 1, 'CT', TRUE),
('DBA8033', 'Management of Health Care Services', 3, 100, 3, 1, 'CT', TRUE),
('DBA8034', 'Medical Equipment Management', 3, 100, 3, 1, 'CT', TRUE),
('DBA8035', 'Hospital Support Services', 3, 100, 3, 1, 'CT', TRUE),

-- SEMESTER IV
('DBA8036', 'Medical Tourism', 3, 100, 4, 1, 'CT', TRUE),
('DBA8037', 'Medical Waste Management', 3, 100, 4, 1, 'CT', TRUE),
('DBA8411', 'Project Work', 12, 400, 4, 1, 'PW', TRUE);



-----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

-- Tracks each Excel/CSV upload batch
CREATE TABLE import_batch_summary (
    batch_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    file_name VARCHAR(255) NOT NULL,
    branch_code VARCHAR(50),
    academic_year VARCHAR(20),
    semester_number INT,
    total_records INT DEFAULT 0,
    processed BOOLEAN DEFAULT FALSE,
    errors INT DEFAULT 0,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP NULL
);

-- Logs invalid rows for review
CREATE TABLE import_errors (
    error_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT NOT NULL,
    reg_number VARCHAR(50),
    student_name VARCHAR(255),
    subject_code VARCHAR(20),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (batch_id) REFERENCES import_batch_summary(batch_id)
);

DELIMITER $$
CREATE PROCEDURE sp_register_batch (
    IN p_file_name VARCHAR(255),
    IN p_branch_code VARCHAR(50),
    IN p_academic_year VARCHAR(20),
    IN p_semester_number INT,
    OUT p_batch_id BIGINT
)
BEGIN
    REPLACE INTO import_batch_summary (file_name, branch_code, academic_year, semester_number)
    VALUES (p_file_name, p_branch_code, p_academic_year, p_semester_number);
    
    SET p_batch_id = LAST_INSERT_ID();
END$$
DELIMITER ;


-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Load Results from result_temp
-- (procedure sp_load_results from earlier)

DELIMITER $$

CREATE PROCEDURE sp_load_results (IN p_batch_id BIGINT)
BEGIN
    -- Declare all variables at the beginning
    DECLARE done INT DEFAULT 0;
    DECLARE v_reg VARCHAR(50);
    DECLARE v_name VARCHAR(255);
    DECLARE v_subject_code VARCHAR(20);
    DECLARE v_im INT;
    DECLARE v_um VARCHAR(10);
    DECLARE v_total INT;
    DECLARE v_status VARCHAR(10);
    DECLARE v_acad_year VARCHAR(20);
    DECLARE v_branch_name VARCHAR(255);
    DECLARE v_sem_number INT;
    DECLARE v_type VARCHAR(10);
    DECLARE v_univ_code VARCHAR(20);
    DECLARE v_degree_code VARCHAR(20);
    DECLARE v_reg_code VARCHAR(20);
    DECLARE v_ay_id INT;
    DECLARE v_branch_id INT;
    DECLARE v_sem_id INT;
    DECLARE v_univ_id INT;
    DECLARE v_reg_id INT;
    DECLARE v_subject_id INT;

    -- Cursor for rows in temp
    DECLARE cur CURSOR FOR
        SELECT reg_number, student_name, subject_code, im_marks, um_marks, total_marks, result_status,
               academic_year, branch_name, semester_number, type, university_code, degree_code, regulation_code
        FROM result_temp WHERE batch_id = p_batch_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_reg, v_name, v_subject_code, v_im, v_um, v_total, v_status,
                       v_acad_year, v_branch_name, v_sem_number, v_type, v_univ_code, v_degree_code, v_reg_code;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Lookup mappings (academic_year_id, branch_id, subject_id, etc.)
        SELECT academic_year_id INTO v_ay_id FROM academic_year WHERE year_name = v_acad_year LIMIT 1;
        SELECT branch_id INTO v_branch_id FROM branch WHERE branch_name = v_branch_name LIMIT 1;
        SELECT semester_id INTO v_sem_id FROM semester WHERE semester_number = v_sem_number LIMIT 1;
        SELECT university_id INTO v_univ_id FROM university WHERE university_code = v_univ_code LIMIT 1;
        SELECT regulation_id INTO v_reg_id FROM regulation WHERE regulation_code = v_reg_code LIMIT 1;
        SELECT subject_id INTO v_subject_id FROM subject WHERE subject_code = v_subject_code LIMIT 1;

        IF v_ay_id IS NULL OR v_branch_id IS NULL OR v_sem_id IS NULL OR v_univ_id IS NULL OR v_reg_id IS NULL OR v_subject_id IS NULL THEN
            REPLACE INTO import_errors (batch_id, reg_number, student_name, subject_code, error_message)
            VALUES (p_batch_id, v_reg, v_name, v_subject_code, 'Mapping failed (missing academic_year/branch/semester/university/regulation/subject)');
        ELSE
            -- INSERT INTO final result with ON DUPLICATE KEY UPDATE
            INSERT INTO result (
                reg_number, student_name, subject_id, academic_year_id, branch_id, semester_id,
                university_id, regulation_id, subject_code, im_marks, um_marks, total_marks, result_status, type
            ) VALUES (
                v_reg, v_name, v_subject_id, v_ay_id, v_branch_id, v_sem_id,
                v_univ_id, v_reg_id, v_subject_code, v_im, v_um, v_total, v_status, v_type
            )
            ON DUPLICATE KEY UPDATE
                im_marks = VALUES(im_marks),
                um_marks = VALUES(um_marks),
                total_marks = VALUES(total_marks),
                result_status = VALUES(result_status),
                updated_at = CURRENT_TIMESTAMP;
        END IF;
    END LOOP;
    CLOSE cur;

    -- Update batch as processed
    UPDATE import_batch_summary
    SET processed = TRUE, finished_at = CURRENT_TIMESTAMP,
        errors = (SELECT COUNT(*) FROM import_errors WHERE batch_id = p_batch_id)
    WHERE batch_id = p_batch_id;

    -- Recalculate student summaries
    CALL sp_calculate_student_summary();
END$$

DELIMITER ;

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- Generate Summary with SGPA & CGPA
-- (procedure sp_generate_summary from earlier)

DELIMITER $$

CREATE PROCEDURE sp_generate_summary()
BEGIN
    -- Option 1: Rebuild completely
    DELETE FROM student_summary;

    REPLACE INTO student_summary
        (reg_number, student_name, semester_id, academic_year_id, branch_id,
         cgpa, sgpa, total_credits, earned_credits, overall_result, class_obtained)
    SELECT
        r.reg_number,
        MAX(r.student_name),
        r.semester_id,
        r.academic_year_id,
        r.branch_id,

        -- ======================
        -- CGPA (cumulative GPA)
        -- ======================
        (
            SELECT ROUND(SUM(s2.credits *
                       (CASE
                           WHEN r2.result_status = 'PASS' THEN
                               (SELECT 10
                                FROM grade_classification g2
                                WHERE r2.total_marks BETWEEN g2.min_percentage AND g2.max_percentage
                                LIMIT 1)
                           ELSE 0
                        END)
                   ) / NULLIF(SUM(s2.credits),0), 2)
            FROM result r2
            JOIN subject s2 ON r2.subject_id = s2.subject_id
            WHERE r2.reg_number = r.reg_number
              AND r2.academic_year_id = r.academic_year_id
              AND r2.semester_id <= r.semester_id
        ) AS cgpa,

        -- ======================
        -- SGPA (semester GPA)
        -- ======================
        ROUND(SUM(s.credits *
            (CASE
                WHEN r.result_status = 'PASS' THEN
                    (SELECT 10
                     FROM grade_classification g
                     WHERE r.total_marks BETWEEN g.min_percentage AND g.max_percentage
                     LIMIT 1)
                ELSE 0
             END)) / NULLIF(SUM(s.credits),0), 2) AS sgpa,

        -- ======================
        -- Credits
        -- ======================
        SUM(s.credits) AS total_credits,
        SUM(CASE WHEN r.result_status = 'PASS' THEN s.credits ELSE 0 END) AS earned_credits,

        -- ======================
        -- Overall Result (FAIL if any subject failed)
        -- ======================
        CASE
            WHEN SUM(CASE WHEN r.result_status = 'FAIL' THEN 1 ELSE 0 END) > 0 THEN 'FAIL'
            ELSE 'PASS'
        END AS overall_result,

        -- ======================
        -- Class Obtained
        -- Based on average % across semester subjects
        -- ======================
        (SELECT grade_name
         FROM grade_classification g
         WHERE (AVG(r.total_marks)) BETWEEN g.min_percentage AND g.max_percentage
         LIMIT 1) AS class_obtained

    FROM result r
    JOIN subject s ON r.subject_id = s.subject_id
    GROUP BY r.reg_number, r.semester_id, r.academic_year_id, r.branch_id;
END$$

DELIMITER ;

--------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

DELIMITER $$

CREATE PROCEDURE sp_update_student_summary(
    IN p_semester_id INT,
    IN p_academic_year_id INT,
    IN p_branch_id INT
)
BEGIN
    -- Recalculate summary only for affected students
    INSERT INTO student_summary (
        reg_number, student_name, semester_id, academic_year_id, branch_id,
        cgpa, sgpa, total_credits, earned_credits, overall_result, class_obtained
    )
    SELECT 
        r.reg_number,
        r.student_name,
        r.semester_id,
        r.academic_year_id,
        r.branch_id,
        ROUND(SUM(r.total_marks) / SUM(s.max_marks) * 10, 2) AS cgpa,
        ROUND(SUM(r.total_marks) / SUM(s.max_marks) * 10, 2) AS sgpa,
        SUM(s.credits) AS total_credits,
        SUM(CASE WHEN r.result_status = 'PASS' THEN s.credits ELSE 0 END) AS earned_credits,
        CASE WHEN MIN(r.result_status) = 'PASS' THEN 'PASS' ELSE 'FAIL' END AS overall_result,
        (SELECT grade_name 
         FROM grade_classification g
         WHERE (ROUND(SUM(r.total_marks) / SUM(s.max_marks) * 100,2)) BETWEEN g.min_percentage AND g.max_percentage
         LIMIT 1) AS class_obtained
    FROM result r
    JOIN subject s ON r.subject_id = s.subject_id
    WHERE r.semester_id = p_semester_id 
      AND r.academic_year_id = p_academic_year_id
      AND r.branch_id = p_branch_id
    GROUP BY r.reg_number, r.student_name, r.semester_id, r.academic_year_id, r.branch_id
    ON DUPLICATE KEY UPDATE 
        cgpa = VALUES(cgpa),
        sgpa = VALUES(sgpa),
        total_credits = VALUES(total_credits),
        earned_credits = VALUES(earned_credits),
        overall_result = VALUES(overall_result),
        class_obtained = VALUES(class_obtained);
END$$

DELIMITER ;

-------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE sp_dashboard_upload(
    IN p_batch_id BIGINT,
    IN p_file_name VARCHAR(255),
    IN p_file_path VARCHAR(500),
    IN p_university_code VARCHAR(20),
    IN p_degree_code VARCHAR(20),
    IN p_regulation_code VARCHAR(20),
    IN p_uploaded_by VARCHAR(100)
)
BEGIN
    REPLACE INTO excel_upload_queue (
        batch_id, file_name, file_path, university_code, degree_code, regulation_code, uploaded_by
    ) VALUES (
        p_batch_id, p_file_name, p_file_path, p_university_code, p_degree_code, p_regulation_code, p_uploaded_by
    );
END$$

DELIMITER ;

--
--

DELIMITER $$

CREATE PROCEDURE sp_process_batch(
    IN p_batch_id BIGINT
)
BEGIN
    DECLARE v_rows INT DEFAULT 0;
    DECLARE error_message TEXT;
    
    -- 1. Check if batch exists in excel_upload_queue or import_batch_summary
    SELECT COUNT(*) INTO v_rows 
    FROM result_temp
    WHERE batch_id = p_batch_id;
    
    IF v_rows = 0 THEN
        SET error_message = CONCAT('Batch ', p_batch_id, ' not found in result_temp.');
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = error_message;
    END IF;
    
    -- 2. Load & validate results
    CALL sp_load_results(p_batch_id);
    
    -- 3. Update student summary (only affected semester/branch/year)
    -- Note: We need to check if sp_update_student_summary exists with the correct parameters
    -- The current implementation of sp_update_student_summary takes semester_id, academic_year_id, branch_id
    -- We might need to modify this call based on how we want to update summaries
    
    -- 4. Mark batch as completed
    UPDATE excel_upload_queue
    SET processing_status = 'COMPLETED', 
        upload_time = CURRENT_TIMESTAMP
    WHERE batch_id = p_batch_id;
    
    -- Optional: also mark in import_batch_summary if historical
    UPDATE import_batch_summary
    SET status = 'COMPLETED',
        import_end_time = CURRENT_TIMESTAMP
    WHERE batch_id = p_batch_id;
    
END$$

DELIMITER ;

SET FOREIGN_KEY_CHECKS=1;


