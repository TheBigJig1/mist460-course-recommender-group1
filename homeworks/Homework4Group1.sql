-- Homework 4 - Group 1
-- Authors: Nada Mikky, Jaxon Fielding, Olivia Gottlieb
-- Description: Deliverable file, contains Stored Procedures, UDFs, and Triggers for MIS assignment
USE MIST460_RelationalDatabase_Lastname;
GO

-- Stored Procedures, User Defined Functions, Triggers

/* =================================================================================
   1. As a student
   I would like to know all the course offerings for the current semester for a 
   particular course so that I can enroll in the offering that fits my schedule.
   DONE by NADA
================================================================================= */
CREATE OR ALTER PROCEDURE procFindCurrentSemesterCourseOfferingsForSpecifiedCourse
(
    @subjectCode NVARCHAR(10),
    @courseNumber NVARCHAR(10)
)
AS 
BEGIN
    SELECT C.SubjectCode,
           C.CourseNumber,
           CO.CRN,
           CO.CourseOfferingSemester,
           CO.CourseOfferingYear
    FROM Course C
    INNER JOIN CourseOffering CO
        ON C.CourseID = CO.CourseID
    WHERE C.SubjectCode = @subjectCode
      AND C.CourseNumber = @courseNumber
      AND CO.CourseOfferingYear = DATEPART(YEAR, SYSDATETIME())
      AND CO.CourseOfferingSemester = dbo.fnFindCurrentSemester();
END;
GO

-- Helper function to get the current semester based on month
CREATE OR ALTER FUNCTION fnFindCurrentSemester()
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @semester NVARCHAR(20);

    IF DATEPART(MONTH, SYSDATETIME()) IN (8, 9, 10, 11, 12)
        SET @semester = 'Fall';
    ELSE IF DATEPART(MONTH, SYSDATETIME()) IN (1, 2, 3, 4, 5)
        SET @semester = 'Spring';
    ELSE
        SET @semester = 'Summer';

    RETURN @semester;
END;
GO

/* -- Test for 1st user story: 
   -- Shows all MIST 460 offerings for the current semester.
 
 EXEC procFindCurrentSemesterCourseOfferingsForSpecifiedCourse 
       @subjectCode = 'MIST', 
       @courseNumber = '460';
*/


/* =================================================================================
   2. As a student
   I would like to know the highly recommended jobs from alums who were in my major 
   (name/email/industry/job title) so that I can contact the alums.
   DONE by NADA
   Improvment: give name of alum to be addressed
   - Ask student for level of recommendatoin they're looking for 
================================================================================= */
CREATE OR ALTER PROCEDURE dbo.procGetRecommendedJobsByMajor
    @Major NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT U.Email AS AlumEmail,
           J.JobDescription,
           J.Industry AS JobIndustry,
           RJ.RecommendationLevel
    FROM Alum A
    JOIN AppUser U ON A.AlumID = U.AppUserID
    JOIN AlumJob RJ ON A.AlumID = RJ.AlumID
    JOIN Job J ON RJ.JobID = J.JobID
    ORDER BY U.Email;
END;
GO

-- 2. Example test: Gives a list of alumnis (emails, jobPositions and recommendation level
-- EXEC dbo.procGetRecommendedJobsByMajor @Major = 'MIST';




/* =================================================================================
    3. When a student is assigned a grade for a Course Offering, the student's GPA should include that grade.
    (As a student, need to know that their GPA is correctly calculated and current).
    DONE BY Jaxon
================================================================================= */

-- Convert a letter grade to grade points (4.000 scale)
CREATE OR ALTER FUNCTION ufnGetGradePoints(@Letter NCHAR(2))
RETURNS DECIMAL(4,3)
AS
BEGIN
    DECLARE @GPA DECIMAL(4,3);
    SET @Letter = UPPER(TRIM(@Letter));
    SET @GPA = CASE @Letter
                WHEN 'A'  THEN 4.000
                WHEN 'B'  THEN 3.000
                WHEN 'C'  THEN 2.000
                WHEN 'D'  THEN 1.000
                WHEN 'F'  THEN 0.000
                ELSE NULL
            END;
    RETURN @GPA;    
END;
GO

-- Trigger 
CREATE OR ALTER TRIGGER trgAfterInsertUpdateGrade
ON dbo.RegistrationCourseOffering
AFTER INSERT, UPDATE
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @StudentId INT, @NewGPA DECIMAL(4,3);

    IF EXISTS (SELECT 1 FROM inserted WHERE FinalGrade IS NOT NULL)
    BEGIN
        -- Get the StudentId from the inserted rows
        SELECT TOP 1 @StudentId = r.StudentId
        FROM inserted i
        JOIN dbo.Registration r ON i.RegistrationID = r.RegistrationID; 

        -- Calculate the new GPA
        SELECT @NewGPA = AVG(dbo.ufnGetGradePoints(i.FinalGrade))
        FROM dbo.RegistrationCourseOffering i
        JOIN dbo.Registration r ON i.RegistrationID = r.RegistrationID
        WHERE r.StudentId = @StudentId AND i.FinalGrade IS NOT NULL;
        
        -- Update the Student's GPA
        UPDATE dbo.Student
        SET GPA = @NewGPA
        WHERE StudentId = @StudentId;
    END
END;
GO


/* -- Test Example:
DECLARE @StudentID INT = 1; 
DECLARE @TargetRCOID INT;

-- See current GPA and that student's course offerings
SELECT StudentID, GPA AS CurrentGPA_Before
FROM Student
WHERE StudentID = @StudentID;

SELECT rco.RegistrationCourseOfferingID,
       rco.FinalGrade,
       rco.RegistrationID
FROM RegistrationCourseOffering rco
JOIN Registration r ON rco.RegistrationID = r.RegistrationID
WHERE r.StudentID = @StudentID
ORDER BY rco.RegistrationCourseOfferingID;

-- Choose a specific RegistrationCourseOffering row to grade and update
SELECT TOP (2) @TargetRCOID = rco.RegistrationCourseOfferingID
FROM RegistrationCourseOffering rco
JOIN Registration r ON rco.RegistrationID = r.RegistrationID
WHERE r.StudentID = @StudentID;

UPDATE rco
SET FinalGrade = 'A'
FROM RegistrationCourseOffering rco
WHERE rco.RegistrationCourseOfferingID = @TargetRCOID;

-- Show GPA after trigger fires.
SELECT StudentID, GPA AS CurrentGPA_After
FROM Student
WHERE StudentID = @StudentID;

SELECT rco.RegistrationCourseOfferingID,
       rco.FinalGrade,
       rco.RegistrationID
FROM RegistrationCourseOffering rco
JOIN Registration r ON rco.RegistrationID = r.RegistrationID
WHERE r.StudentID = @StudentID
ORDER BY rco.RegistrationCourseOfferingID;

GO 
-- End test */

/* =================================================================================
    4. When a student rates a course offering, the average course offering rating should include that rating.
    (As an instructor, need to know that the course rating is correct and current).
    DONE BY OLIVIA
================================================================================= */
