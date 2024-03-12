-- Creating a new database to startwith --
create schema club_members_portfolio;
use club_members_portfolio;
DROP TABLE IF EXISTS club_member_info;
-- Creating a table where the data  can be further imported --
CREATE TABLE club_member_info (
    member_id SERIAL AUTO_INCREMENT,
    full_name VARCHAR(100),
    age INT,
    maritial_status VARCHAR(50),
    email VARCHAR(150),
    phone VARCHAR(20),
    full_address VARCHAR(150),
    job_title VARCHAR(100),
    membership_date VARCHAR(255),
    PRIMARY KEY (member_id)
);

 -- Loading the dataset inside the table which is in CSV format --
 -- The blank cells are set to NULL --
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/club_member_info.csv" into table club_member_info
fields terminated by ',' enclosed by '"' lines terminated by '\r\n' ignore 1 lines;
use club_members_portfolio;


-- STEP - 1 --
-- Lets analyse the table so that we could geth to know where the data is dirty --
SELECT 
    *
FROM
    club_members_portfolio.club_member_info;

-- Separating Full Name to First name and Last name --
-- It has some special charecters like $,-,? so to remove it, regexp_replace can be used --
-- To remove whitespaces trim function can be used -- 
SELECT 
    REGEXP_REPLACE(SUBSTRING_INDEX(TRIM(LOWER(full_name)), ' ', 1),
            '[^[:alnum:]]+',
            '') AS first_name
FROM
    club_members_portfolio.club_member_info;

-- Separating Last name and middle name if exists from the Full Name --
SELECT 
    SUBSTRING(LOWER(full_name) FROM INSTR(full_name, ' ') + 1) AS last_name
FROM
    club_members_portfolio.club_member_info;

-- Some ages has 3 digits which is inappropriate --
-- Removing the last digit from age column if 3 digit exists --
SELECT 
    CASE
        WHEN age = 0 THEN NULL
        WHEN age = 3 THEN FLOOR(age / 10)
        ELSE age
    END AS age
FROM
    club_members_portfolio.club_member_info;

-- trimming whitespaces --
SELECT 
    CASE
        WHEN TRIM(maritial_status) = '' THEN NULL
        ELSE TRIM(maritial_status)
    END AS maritial_status
FROM
    club_members_portfolio.club_member_info;
        
-- email address are case insensitive --
SELECT 
    TRIM(LOWER(email)) AS member_email
FROM
    club_members_portfolio.club_member_info;

-- some phone numbers are incomplete --
-- Assigning incomplete phone numbers to be NULL and trimming off whitespaces --
SELECT 
    CASE
        WHEN TRIM(phone) = '' THEN NULL
        WHEN LENGTH(TRIM(phone)) < 12 THEN NULL
        ELSE TRIM(phone)
    END AS phone
FROM
    club_members_portfolio.club_member_info;

-- spliting address into individual columns (address,city,state)--
-- lowercasing and trimming off whitespaces --
SELECT 
    SUBSTRING_INDEX(TRIM(LOWER(full_address)), ',', 1) AS street_address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(LOWER(full_address)), ',', 2),
            ',',
            - 1) AS city,
    SUBSTRING_INDEX(TRIM(LOWER(full_address)), ',', - 1) AS state
FROM
    club_members_portfolio.club_member_info;

-- job titles has roman numerals at end --
-- roman numerals are replaced with appropriate fields --
SELECT 
    CASE
        WHEN TRIM(LOWER(job_title)) = '' THEN NULL
        WHEN
            SUBSTRING_INDEX(TRIM(LOWER(job_title)), ' ', - 1) = 'i'
        THEN
            REPLACE(LOWER(job_title),
                ' i',
                ', level 1')
        WHEN
            SUBSTRING_INDEX(TRIM(LOWER(job_title)), ' ', - 1) = 'ii'
        THEN
            REPLACE(LOWER(job_title),
                ' ii',
                ', level 2')
        WHEN
            SUBSTRING_INDEX(TRIM(LOWER(job_title)), ' ', - 1) = 'iii'
        THEN
            REPLACE(LOWER(job_title),
                ' iii',
                ', level 3')
        WHEN
            SUBSTRING_INDEX(TRIM(LOWER(job_title)), ' ', - 1) = 'iv'
        THEN
            REPLACE(LOWER(job_title),
                ' iv',
                ', level 4')
        ELSE TRIM(LOWER(job_title))
    END AS occupation
FROM
    club_members_portfolio.club_member_info;
            
 
 -- datatype of membership date is convered into date from string --
SELECT 
    DATE_FORMAT(STR_TO_DATE(membership_date, '%d-%m-%Y'),
            '%Y-%m-%d')
FROM
    club_members_portfolio.club_member_info;

SELECT 
    membership_date
FROM
    club_members_portfolio.club_member_info;
  
 
 -- STEP-2--
 use club_members_portfolio;
 drop table if exists cleaned_member_info;
 -- Creating a copy of orginal table to implement changes that we analyzed --
CREATE TABLE cleaned_member_info AS (SELECT member_id,
    REGEXP_REPLACE(SUBSTRING_INDEX(TRIM(LOWER(full_name)), ' ', 1),
            '[^[:alnum:]]+',
            '') AS first_name,
    SUBSTRING(LOWER(full_name) FROM INSTR(full_name, ' ') + 1) AS last_name,
    CASE
        WHEN age = 0 THEN NULL
        WHEN age = 3 THEN FLOOR(age / 10)
        ELSE age
    END AS age,
    CASE
        WHEN TRIM(maritial_status) = '' THEN NULL
        ELSE TRIM(maritial_status)
    END AS maritial_status,
    TRIM(LOWER(email)) AS member_email,
    CASE
        WHEN TRIM(phone) = '' THEN NULL
        WHEN LENGTH(TRIM(phone)) < 12 THEN NULL
        ELSE TRIM(phone)
    END AS phone,
    SUBSTRING_INDEX(TRIM(LOWER(full_address)), ',', 1) AS street_address,
    SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(LOWER(full_address)), ',', 2),
            ',',
            - 1) AS city,
    SUBSTRING_INDEX(TRIM(LOWER(full_address)), ',', - 1) AS state,
    CASE
        WHEN TRIM(LOWER(job_title)) = '' THEN NULL
        WHEN
            SUBSTRING_INDEX(TRIM(LOWER(job_title)), ' ', - 1) = 'i'
        THEN
            REPLACE(LOWER(job_title),
                ' i',
                ', level 1')
        WHEN
            SUBSTRING_INDEX(TRIM(LOWER(job_title)), ' ', - 1) = 'ii'
        THEN
            REPLACE(LOWER(job_title),
                ' ii',
                ', level 2')
        WHEN
            SUBSTRING_INDEX(TRIM(LOWER(job_title)), ' ', - 1) = 'iii'
        THEN
            REPLACE(LOWER(job_title),
                ' iii',
                ', level 3')
        WHEN
            SUBSTRING_INDEX(TRIM(LOWER(job_title)), ' ', - 1) = 'iv'
        THEN
            REPLACE(LOWER(job_title),
                ' iv',
                ', level 4')
        ELSE TRIM(LOWER(job_title))
    END AS occupation,
    DATE_FORMAT(STR_TO_DATE(membership_date, '%d-%m-%Y'),
            '%Y-%m-%d') AS membership_date FROM
    club_members_portfolio.club_member_info);
 
 -- check table output --
SELECT 
    *
FROM
    cleaned_member_info;
 
 -- A few members show membership_date year in the 1900's -- 
-- Changing the year into the 2000's --
UPDATE cleaned_member_info 
SET 
    membership_date = DATE_FORMAT('2000-01-01', '%Y-%m-%d')
WHERE
    membership_date < '2000-01-01';
 
-- checking for duplicates --
SELECT 
    member_email, COUNT(member_email)
FROM
    cleaned_member_info
GROUP BY member_email
HAVING COUNT(member_email) > 1;
  
  -- removing duplicates--    
DELETE A FROM cleaned_member_info AS A
        INNER JOIN
    cleaned_member_info AS B 
WHERE
    A.member_id < B.member_id
    AND A.member_email = B.member_email;
    
 
        
        
        
        