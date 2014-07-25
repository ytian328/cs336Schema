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
	ON DELETE NO ACTION
); <-- add ruid and UserType && Created new table UserTypeID -->
<-- ANY Thoughts? Before User decides to create account how do we decide what userType they are assigned ? can't allow them to select their own. ->
<--Yuan: suppose initialy different users are assigned to ruid with different initials, then our system can recongnize their type by their ruid-->

CREATE TABLE Students (
ruid CHAR(9),
netid VARCHAR(15),
name VARCHAR(15),
passWord VARCHAR(15),
majorid CHAR(3),
PRIMARY KEY (ruid),
FOREIGN KEY (ruid) REFRENCES Users(ruid)
	ON DELETE NO ACTION,
FOREIGN KEY (majorid) REFRENCES Majors(majorid)
	ON DELETE NO ACTION
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
PRIMARY KEY (ruid,cid),<--Yuan: I add cid here considering that one student may have taken several course, thus will have several grades for differnt course-->
FOREIGN KEY (ruid) REFRENCES Students(ruid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
FOREIGN KEY (cid) REFERENCES Course(cid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
FOREIGN KEY (majorid) REFERENCES Majors(majorid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
);

CREATE TABLE Register (
ruid CHAR(9),
registerTime DATETIME <-- hopefully DB or JSP can record time --><Yuan: I changed the type of registerTime, just incase we need to compare it with the deadline of registration>
majorId CHAR(3), <-- for major only classes to check eligibility -->
cid CHAR(3),
secNum CHAR(2),
semester CHAR(2),<--format ex:FA -->
spNum CHAE(5) DEFAULT NULL, <--Yuan: I add ane more attr here. considering when spn is required for registration, there should be some place to put it in-->
PRIMARY KEY (ruid,cid,secNum,semester),
FOREIGN KEY (ruid) REFRENCES Students (ruid)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
FOREIGN KEY (cid,secNum,semester,year) REFRENCES Courses
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
);


CREATE TABLE Recitation(
cid CHAR(3),
secNum CHAR(2),
maxEnroll INTEGER,
time CHAR(4),
roomid CHAR(3),
bldCode CHAR(3),
PRIMARY KEY (cid,secNum),
FOREIGN KEY (cid, secNum) REFRENCES Courses(cid, secNum)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION,
FOREIGN KEY (roomid, bldCode) REFRENCES classRooms(roomid, bldCode)
	ON DELETE NO ACTION
	ON UPDATE NO ACTION
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
deadline DATETIME,
prereq VARCHAR(12),<--Yuan: Do we need to make preq a single talbe? what if one course has two or more prereq?-->
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
	time CHAR(15),
	status CHAR(20),
	reason CHAR(20),
	response CHAR(20) DEFAULT NULL, <- - If given an spn, itll appear here - ->
	FOREIGN KEY (cid, secNum) REFERENCES Courses(cid, secNum)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	FOREIGN KEY (ruid) REFERENCES Student(ruid)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
);

CREATE TABLE spns (
	cid CHAR(3).
	secNum CHAR(2),
	quantity INTEGER,
	PRIMARY KEY(cid, secNum)
	FOREIGN KEY(cid, secNum) REFERENCES Course(cid, secNum)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
);
<- - is it 10 spns per course or 10 per section? needs to be modified if 10 per course - ->







<--Yuan: check and set the usertype when creating new user tuples in table Users-->
CREATE TRIGGER check_userType BEFORE INSERT ON Users
        	FOR EACH ROW
        	BEGIN
                    	IF NEW.ruid LIKE ‘1%’ THEN
                                	INSERT INTO User(ruid, name, netid, password, useryType)
                                	VALUES(NEW.ruid, NEW.name, NEW.netid, NEW.password, '1')
                    	ELSEIF NEW.ruid LIKE ‘2%’ THEN
                                	INSERT INTO User(ruid, name, netid, password, useryType)
                                	VALUES(NEW.ruid, NEW.name, NEW.netid, NEW.password, '2')
                    	ELSEIF NEW.ruid LIKE ‘3%’ THEN
                                	INSERT INTO User(ruid, name, netid, password, useryType)
                                	VALUES(NEW.ruid, NEW.name, NEW.netid, NEW.password, '3')
                    	END IF;
        	END;

<--Yuan: check if students need spn to register the course. two conditions: 1 late registration, 2 prereq overwrite, not sure if the code works... really need help-->
CREATE TRIGGER check_register BEFORE INSERT ON Register
	FOR EACH ROW
	BEGIN
		IF NEW.registerTime > Course.deadline <--deadline past-->
			OR 
			0 = (SELECT COUNT(T.cid)
			FROM Transcript T, Course C, NEW
			WHERE NEW.cid = C.cid AND NEW.ruid = T.ruid AND T.cid = C.prereq) <--the prereq course is not taken-->
			OR
			'C' >= (SELECT T.grade
			FROM Transcript T, Course C, NEW
			WHERE NEW.cid = C.cid AND NEW.ruid = T.ruid AND T.cid = C.prereq) <--the grade is lower than required-->
			THEN INSERT INTO Register(ruid, registerTime, majorId, cid, secNum, semester, spNum) <--spn need to be provided but how to check if this spNum matches the one provided in the request?-->
                     		VALUES(NEW.ruid, NEW.registerTime, NEW.majorId, NEW.cid, NEW.secNum, NEW.semester, NEW.spNum);
			
		ELSE INSERT INTO Register(ruid, registerTime, majorId, cid, secNum, semester,spNum)<--can register without spNum-->
                     VALUES(NEW.ruid, NEW.registerTime, NEW.majorId, NEW.cid, NEW.secNum, NEW.semester);
	END;

<--Yuan: before add tuples in request, check if all 10 spn's for such section are used out, if not, add the tuple, if yes reject the action-->
CREATE TRIGGER check_request_spn BEFORE INSERT ON request
	FOR EACH ROW
	BEGIN
		IF 10 <= (SELECT COUNT(R.response)
			FROM request R, NEW
			WHERE R.cid = NEW.cid AND R.secNum = NEW.secNum AND R.response <> NULL)
			THEN
			NO ACTION
		ELSE INSERT INTO request(cid, secNum, ruid, time, status, reason, response)
			VALUES(NEW.cid, NEW.secNum, NEW.ruid, NEW.time, NEW.status, NEW.reason);
	END;
	
<--Yuan: before prof. give spn to student, check if all spn's are used out-->
CREATE TRIGGER check_give_spn BEFORE UPDATE ON request
	FOR EACH ROW 
	BEGIN
		IF 10 <=(SELECT COUNT(*)
			FROM request R
			WHERE OLD.cid = R.cid AND OLD.secNum = R.secNum AND R.response <> NULL)
		THEN
		NO ACTION
		ELSE SET OLD.response = NEW.response;
	END;


<--can professor change the response in request when request.response is not NULL? Can student delete their spn request? Any idea?-->


