# Employee Attendance and Payroll System

A SQL-based backend system for managing employee attendance, calculating salaries, handling payroll, and enforcing access control.

## Features

- Employee and job title management with hourly rate tracking.
- Daily attendance logging (check-in/check-out).
- Automated salary calculation based on:
  - Total hours worked.
  - Overtime.
  - Absences and deductions.
- Payroll record generation per employee, per month.
- Role-based access control for HR users.


## Database Schema

### Tables:
- JobTitles: Stores job roles and hourly rates.
- Employees: Basic employee information and job title reference.
- Attendance: Daily check-in/out logs and status (Present, Absent, Late, Overtime).
- Payroll: Stores monthly salary details (base salary, overtime, deductions, net pay).

### Stored Procedure:
- CalculateSalary: Takes 'EmployeeID' and 'Month', then calculates and inserts a payroll record.

##  User Access

- hr_user:
  -  Read/Write access to: 'Employees', 'Payroll'.
  -  No access to: 'Attendance'.

## Technologies Used

- MySQL RDBMS.

##  Setup Instructions

1. Clone this repository.
2. Import the SQL script into your RDBMS.
3. Run the stored procedures or test queries as needed.
