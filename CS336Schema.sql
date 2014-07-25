<-- Must create major table because major id=198 but what does 198 mean? needs majorName attribute "Computer Science"-->
CREATE TABLE UserTypeID (
userType INTEGER, <-- 1 Student 2 Instructor 3 Admin -->
userTypeName VARCHAR(12),
PRIMARY KEY(userType)
);


CREATE TABLE Users (
ruid CHAR(9),
name VARCHAR(15),
netid VARCHAR(15) NOT NULL,
passWord VARCHAR(15) NOT NULL,
userType INTEGER,
PRIMARY KEY (ruid),
UNIQUE (netid),
FOREIGN KEY (userType) REFRENCES UserTypeID(userType)
); <-- add ruid and UserType && Created new table UserTypeID -->
<-- ANY Thoughts? Before User decides to create account how do we decide what userType they are assigned ? can't allow them to select their own. ->


CREATE TABLE Students (
ruid CHAR(9),
netid VARCHAR(15),
name VARCHAR(15),
passWord VARCHAR(15),
majorid CHAR(3),
PRIMARY KEY (ruid),
FOREIGN KEY (ruid) REFRENCES Users(ruid),
FOREIGN KEY (majorid) REFRENCES Majors(majorid)
);

CREATE TABLE Transcript (
ruid CHAR(9),
semester CHAR(2),
cid CHAR(3),
year CHAR(2),
grade CHAR(2),
majorid CHAR(3),
PRIMARY KEY (ruid),
FOREIGN KEY (ruid) REFRENCES Students(ruid),

);
<-- possible Transcript and KeepTrans can be Merged -->
<-- create keep Transcript table w/ attributes enrolled and Graduation(Format (ex:FA/12) -->
CREATE TABLE KeepTrans (
ruid CHAR(9),
enrolled CHAR(5), <-- University Enrollment -->
grad CHAR(5) DEFAULT NULL,
PRIMARY KEY (ruid),
FOREIGN KEY (ruid) REFRENCES Students(ruid),
FOREIGN KEY (ruid) REFRENCES Transcripts(ruid)
);

CREATE TABLE Register (
ruid CHAR(9),
registerTime CHAR(9) <-- hopefully DB or JSP can record time -->
majorId CHAR(3), <-- for major only classes to check eligibility -->
cid CHAR(3),
secNum CHAR(2),
semester CHAR(2),<--format ex:FA -->
PRIMARY KEY (ruid,cid,secNum,semester),
FOREIGN KEY (ruid) REFRENCES Students (ruid),
FOREIGN KEY (cid,secNum,semester,year) REFRENCES Courses
);

CREATE TABLE CourseSec (
cid CHAR(9),
secNum CHAR(2),
PRIMARY KEY (cid,secNum),
FOREIGN KEY (cid) REFRENCES Courses(cid)
);   <-- + seperate section  -->
<--OR like-->

CREATE TABLE CourseSec ( <- 

cid CHAR(3),
secNum CHAR(2),
time CHAR(4),
roomid CHAR(3),
bldCode CHAR(3),
PRIMARY KEY (cid,secNum),
FOREIGN KEY (cid) REFRENCES Courses(cid),
FOREIGN KEY (roomid) REFRENCES classRooms(roomid) 
<-- Relationship between sections and ClassRoom required for this -->
); <-- also what if course has 2 different lectures not just sectional for recitation? ---->
<--------------------------------------------->
CREATE TABLE Courses (
majorid CHAR(3), <-- "198" : "336" like mid:cid:sid -->
cid CHAR (3),
secNum CHAR(2),
year CHAR(4),
semester CHAR(2),
profID CHAR(9),
bldCode CHAR(3),
roomid CHAR(3),
maxEnroll INTEGER,
prereq VARCHAR(12),
PRIMARY KEY (majorid,cid,secNum,year,semester),
FOREIGN KEY (bldCode,roomid) REFRENCES ClassRooms(bldCode,roomid),
FOREIGN KEY (majorid) REFRENCES Majors (majorid),
FOREIGN KEY (profID) REFRENCES Users(ruid)
);

CREATE TABLE ClassRooms (
bldCode CHAR(3),
maxSeating INTEGER,
roomid CHAR(3),
PRIMARY KEY (bldCode,roomid)
);

<-- Need to connect response relationship from User to SPN -->










