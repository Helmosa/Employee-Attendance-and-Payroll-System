CREATE DATABASE employment_system;
USE employment_system;

# Job titles and hourly rates table
CREATE TABLE JobTitles (
    JobTitleID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(50) NOT NULL,
    HourlyRate DECIMAL(5,2) NOT NULL
);

# Employees table
CREATE TABLE Employees (
    EmployeeID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(10) NOT NULL,
    LastName VARCHAR(10) NOT NULL,
    JobTitleID INT UNSIGNED NOT NULL,
    FOREIGN KEY (JobTitleID) REFERENCES JobTitles(JobTitleID)
);

# Attendance table
CREATE TABLE Attendance (
    AttendanceID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT UNSIGNED,
    TodayDate DATE NOT NULL,
    CheckIn TIME NOT NULL,
    CheckOut TIME NOT NULL,
    Status ENUM('Present', 'Absent', 'Late', 'Overtime') NOT NULL,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

# Payroll data table
CREATE TABLE Payroll (
    PayrollID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT UNSIGNED,
    PayMonth DATE NOT NULL,
    BaseSalary DECIMAL(10,2),
    OvertimeHours DECIMAL(5,2),
    Deductions DECIMAL(10,2),
    NetPay DECIMAL(10,2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
DELIMITER //
CREATE PROCEDURE CalculateSalary(IN p_EmployeeID INT, IN p_Month DATE)
BEGIN
    DECLARE rate DECIMAL(8,2);
    DECLARE totalHours DECIMAL(8,2) DEFAULT 0;
    DECLARE overtimeDays INT DEFAULT 0;
    DECLARE absentDays INT DEFAULT 0;
    DECLARE baseSalary DECIMAL(10,2);
    DECLARE netPay DECIMAL(10,2);

    -- Get hourly rate
    SELECT jt.HourlyRate INTO rate
    FROM Employees e
    JOIN JobTitles jt ON e.JobTitleID = jt.JobTitleID
    WHERE e.EmployeeID = p_EmployeeID;

    -- Get attendance data in a single query
    SELECT
        SUM(CASE WHEN Status = 'Present' THEN TIMESTAMPDIFF(HOUR, CheckIn, CheckOut) ELSE 0 END),
        SUM(CASE WHEN Status = 'Overtime' THEN 1 ELSE 0 END),
        SUM(CASE WHEN Status = 'Absent' THEN 1 ELSE 0 END)
    INTO totalHours, overtimeDays, absentDays
    FROM Attendance
    WHERE EmployeeID = p_EmployeeID
      AND DATE_FORMAT(Date, '%Y-%m') = DATE_FORMAT(p_Month, '%Y-%m');

    -- Compute salaries
    SET baseSalary = totalHours * rate;
    SET netPay = baseSalary + (overtimeDays * 2 * rate * 1.5) - (absentDays * 20);

    -- Insert into Payroll
    INSERT INTO Payroll (EmployeeID, PayMonth, BaseSalary, OvertimeHours, Deductions, NetPay)
    VALUES (p_EmployeeID, p_Month, baseSalary, overtimeDays * 2, absentDays * 20, netPay);
END;
//
DELIMITER ;
;
-- Create a user for HR
CREATE USER 'hr_user'@'localhost' IDENTIFIED BY 'StrongPassword123';

-- Grant read/write access to employee and payroll data
GRANT SELECT, INSERT, UPDATE ON Employees TO 'hr_user'@'localhost';
GRANT SELECT, INSERT, UPDATE ON Payroll TO 'hr_user'@'localhost';

-- Revoke access to attendance data
REVOKE SELECT, INSERT, UPDATE, DELETE ON Attendance FROM 'hr_user'@'localhost';