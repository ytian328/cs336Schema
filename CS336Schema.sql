<-- Must create major table because major id=198 but what does 198 mean? needs majorName attribute "Computer Science"-->
CREATE TABLE UserTypeID (
userType INTEGER, <-- 1 Student 2 Instructor 3 Admin -->
userTypeName VARCHAR(12),
PRIMARY KEY(userType)
);

CREATE TABLE Majors (
majorid CHAR(3),
majorNname CHAR(20) NOT NULL,
PRIMARY KEY(majorid)
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
enrolled CHAR(5), <-- University Enrollment -->
grad CHAR(5) DEFAULT NULL,
PRIMARY KEY (ruid),
FOREIGN KEY (ruid) REFRENCES Students(ruid),
FOREIGN KEY (majorid) REFERENCES Majors(majorid)
)

CREATE TABLE Register (
ruid CHAR(9),
registerTime CHAR(9) <-- hopefully DB or JSP can record time -->
majorId CHAR(3), <-- for major only classes to check eligibility -->
cid CHAR(3),
secNum CHAR(2),
semester CHAR(2),<--format ex:FA -->
PRIMARY KEY (ruid,cid,secNum,semester),
FOREIGN KEY (ruid) REFRENCES Students (ruid),
FOREIGN KEY (cid,secNum,semester,year) REFRENCES Courses);


CREATE TABLE Recitation(
cid CHAR(3),
secNum CHAR(2),
maxEnroll INTEGER,
time CHAR(4),
roomid CHAR(3),
bldCode CHAR(3),
PRIMARY KEY (cid,secNum),
FOREIGN KEY (cid, secNum) REFRENCES Courses(cid, secNum),
FOREIGN KEY (roomid, bldCode) REFRENCES classRooms(roomid, bldCode)
);



CREATE TABLE Courses (
majorid CHAR(3), <-- "198" : "336" like mid:cid:sid -->
cid CHAR (3),
secNum CHAR(2),
year CHAR(4),
semesterid CHAR(2),
profID CHAR(9),
bldCode CHAR(3),
roomid CHAR(3),
maxEnroll INTEGER,
prereq VARCHAR(12),
PRIMARY KEY (majorid,cid,secNum,year,semester),
FOREIGN KEY (bldCode,roomid) REFERENCES ClassRooms(bldCode,roomid),
FOREIGN KEY (majorid) REFERENCES Majors (majorid),
FOREIGN KEY (profID) REFERENCES Users(ruid)
);

CREATE TABLE ClassRooms (
bldCode CHAR(3),
maxSeating INTEGER,
roomid CHAR(3),
PRIMARY KEY (bldCode,roomid)
);

<-- Need to connect response relationship from User to SPN -->
CREATE TABLE request(
	cid CHAR(3),
	secNum CHAR(2),
	ruid CHAR(9),
	time CHAR(15) ,
	status CHAR(20),
	reason CHAR(20),
	response CHAR(20) DEFAULT NULL, <- - If given an spn, itll appear here - ->
	FOREIGN KEY (cid, secNum) REFERENCES Courses(cid, secNum),
	FOREIGN KEY (ruid) REFERENCES Student(ruid)
);

CREATE TABLE spns (
	cid CHAR(3).
	secNum CHAR(2),
	quantity INTEGER,
	PRIMARY KEY(cid, secNum)
	FOREIGN KEY(cid, secNum) REFERENCES Course(cid, secNum)
);
<- - is it 10 spns per course or 10 per section? needs to be modified if 10 per course - ->







<--check and set the usertype when creating new user tuples in table Users-->
CREATE TRIGGER check_userType BEFORE INSERT ON Users
        	FOR EACH ROW
        	BEGIN
                    	IF NEW.ruid LIKE ‘1%’ THEN
                                	INSERT INTO User(ruid, name, netid, password, useryType)
                                	VALUES(NEW.ruid, NEW.name, NEW.netid, NEW.password, 1)
                    	ELSE IF NEW.ruid LIKE ‘2%’ THEN
                                	INSERT INTO User(ruid, name, netid, password, useryType)
                                	VALUES(NEW.ruid, NEW.name, NEW.netid, NEW.password, 3)
                    	ELSE IF NEW.ruid LIKE ‘3%’ THEN
                                	INSERT INTO User(ruid, name, netid, password, useryType)
                                	VALUES(NEW.ruid, NEW.name, NEW.netid, NEW.password, 3)
                    	END IF;
        	END;













