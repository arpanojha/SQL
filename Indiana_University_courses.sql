-- Creating database with arpan ojha



CREATE DATABASE arpanojha3;

-- Connecting to database 
\c arpanojha3;

-- Relation schemas and instances for assignment 1

CREATE TABLE Student(sid integer,
                     sname text,
                     major text,
                     primary key (sid));


CREATE TABLE Course(cno integer,
                     cname text,
                     total integer,
                     max integer,
                     primary key (cno));


CREATE TABLE Prerequisite(cno integer,
                          prereq integer,
                          primary key (cno, prereq),
                          foreign key (cno) references Course (cno),
                          foreign key (prereq) references Course (cno));

CREATE TABLE hasTaken(sid integer,
                          cno integer,
                          primary key (sid, cno),
                          foreign key (sid) references Student (sid),
                          foreign key (cno) references Course (cno));

CREATE TABLE Enroll(sid integer,
                          cno integer,
                          primary key (sid, cno),
                          foreign key (sid) references Student (sid),
                          foreign key (cno) references Course (cno));

CREATE TABLE Waitlist(sid integer,
                          cno integer,
                          position integer,
                          primary key (sid, cno),
                          foreign key (sid) references Student (sid),
                          foreign key (cno) references Course (cno));



INSERT INTO Student VALUES
(1001,'Jean','CS'),
(1002,'Vidya', 'CS'),
(1003,'Anna', 'CS'),
(1004,'Qin', 'Seattle'),
(1005,'Megan', 'CS'),
(1006,'Ryan', 'CS'),
(1007,'Danielle','CS'),
(1008,'Emma', 'CS'),
(1009,'Hasan', 'CS'),
(1010,'Linda', 'CS'),
(1011,'Nick', 'CS'),
(1012,'Eric', 'CS'),
(1013,'Lisa', 'CS'), 
(1014,'Deepa', 'CS'), 
(1015,'Chris', 'CS'),
(1016,'YinYue', 'CS'),
(1017,'Latha', 'CS'),
(1018,'Arif', 'CS'),
(1019,'John', 'CS');

INSERT INTO Course VALUES
(561,'ADC',0,5),
(551,'EAI',0,50),
(540,'HRI',0,2 ),
(290,'PQC',0,1 ),
(590,'LAIDEL',0,10 ),
(505,'AA',0,20 ),
(657,'CV',0,2),
(520,'STAT',0,3 ),
(310,'PSD',0,2 ),
(322,'OOSD',0,70 );

INSERT INTO Prerequisite VALUES
(561,290),
(561,590),
(505,657),
(322,310),
(310,657),
(551,540),
(590,290);

INSERT INTO hasTaken VALUES
(1001,561),
(1001,290),
(1001,590),
(1001,657),
(1001,540),
(1002,540),
(1002,290),
(1003,310),
(1004,657),
(1005,505),
(1005,310);

-- insert into enroll

-- helper function to insert into enroll count
CREATE OR REPLACE FUNCTION return_if_count_prereq(cno1 INTEGER)
RETURNS TABLE(c INTEGER) AS
$$
    SELECT COUNT(DISTINCT(prereq)) FROM Prerequisite WHERE cno = cno1;
$$ LANGUAGE SQL;

-- helper function to insert into enroll count
CREATE OR REPLACE FUNCTION return_if_hastaken_prereq(sid1 INTEGER, cno1 INTEGER)
RETURNS TABLE(c INTEGER) AS
$$
    SELECT COUNT(DISTINCT(p.prereq)) FROM Prerequisite p, hasTaken m WHERE p.cno = cno1 AND m.sid = sid1 AND m.cno = p.prereq;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION check_enroll_insert_action()
RETURNS TRIGGER AS
$$
BEGIN
    IF (SELECT * FROM return_if_hastaken_prereq(NEW.sid,NEW.cno))=(SELECT * FROM return_if_count_prereq(NEW.cno))  AND (SELECT COUNT(e.sid) FROM Enroll e WHERE e.cno=NEW.cno) < (SELECT c.max FROM Course c WHERE c.cno=NEW.cno) THEN 
        UPDATE Course SET total=total+1 WHERE NEW.cno = cno; 
        RETURN NEW; 
    ELSEIF (SELECT * FROM return_if_hastaken_prereq(NEW.sid,NEW.cno))=(SELECT * FROM return_if_count_prereq(NEW.cno)) AND (SELECT COUNT(e.sid) FROM Enroll e WHERE e.cno=NEW.cno) >= (SELECT c.max FROM Course c WHERE c.cno=NEW.cno) THEN 
        INSERT INTO Waitlist VALUES(NEW.sid,NEW.cno,(SELECT CASE WHEN (SELECT COUNT(1) FROM waitlist w WHERE w.cno=New.cno)<1 THEN 1 ELSE (SELECT MAX(w.position)+1 FROM waitlist w WHERE w.cno=New.cno) END)); 
        RETURN NULL; 
    ELSE  
        RAISE EXCEPTION 'Insufficient prerequisites'; 
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_enroll_waitlist_definition
    BEFORE INSERT ON Enroll
    FOR EACH ROW
    EXECUTE PROCEDURE check_enroll_insert_action();

---deleting enroll
--helper function for delete
CREATE OR REPLACE FUNCTION return_min_sid(cno1 INTEGER)
RETURNS TABLE(c INTEGER) AS
$$
    SELECT m.sid FROM waitlist m WHERE m.cno = cno1 AND m.position = (SELECT MIN(m1.position) FROM waitlist m1 WHERE m1.cno = cno1);
$$ LANGUAGE SQL;

-- actual delete trigger
CREATE OR REPLACE FUNCTION delete_from_enroll_action()
RETURNS TRIGGER AS
$$
BEGIN
    IF (SELECT e.total FROM course e WHERE e.cno=OLD.cno) < (SELECT c.max FROM Course c WHERE c.cno=OLD.cno) THEN
        UPDATE Course SET total=total-1 WHERE OLD.cno = cno;
        RETURN NULL;
    ELSEIF (SELECT COUNT(e.sid) FROM Waitlist e WHERE e.cno=OLD.cno)>0 THEN
            UPDATE Course SET total=total-1 WHERE OLD.cno = cno;
            INSERT INTO Enroll(sid,cno) SELECT m.sid,m.cno FROM Waitlist m WHERE m.cno=OLD.cno AND m.position = (SELECT MIN(m1.position) FROM Waitlist m1 WHERE m1.cno=OLD.cno);
            DELETE FROM Waitlist w WHERE w.sid=(SELECT c FROM return_min_sid(OLD.cno)) AND W.cno=OLD.cno;
            RETURN NULL;
    ELSE
        UPDATE Course SET total=total-1 WHERE OLD.cno = cno;
        RETURN NULL;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER delete_from_enroll_definition
    AFTER DELETE ON Enroll
    FOR EACH ROW EXECUTE PROCEDURE delete_from_enroll_action();

-- checking condition 1 from problem 4 insert 
\qecho 'checking condition 1 from problem 4 insert'

insert into enroll values (1001,561);
insert into enroll values (1002,520);
\qecho 'enroll'
select * from enroll;
\qecho 'course'
select * from course;

-- This should fail
insert into enroll values (1002,561);

\qecho 'checking condition 2'
-- checking condition 2
insert into enroll values (1002,540);
insert into enroll values (1001,540);
insert into enroll values (1003,540);
insert into enroll values (1005,540);
insert into enroll values (1004,540);

insert into enroll values (1001,657);
insert into enroll values (1002,657);
insert into enroll values (1003,657);
insert into enroll values (1004,657);

\qecho 'enroll'
select * from enroll;
\qecho 'course'
select * from course;
\qecho 'waitlist'
select * from waitlist;

\qecho 'checking condition 3'
-- chrecking delete and condition 3
delete from enroll where sid = 1001 and cno=657;
delete from waitlist where sid=1003 and cno = 540;
delete from enroll where sid=1002 and cno=540;
\qecho 'enroll'
select * from enroll;
\qecho 'course'
select * from course;
\qecho 'waitlist'
select * from waitlist;
-- Connect to default database
\c postgres;

-- Drop database created for this assignment
DROP DATABASE arpanojha3 WITH (FORCE);;
