SELECT * FROM TAB;

BEGIN
    for i in (select 'drop table '||table_name||' CASCADE CONSTRAINTS PURGE' tbl from user_tables)
    loop
        execute immediate i.tbl;
    end loop;
end;
/

SELECT * FROM recycleBin;
PURGE RECYCLEBIN;

DROP TABLE Booking CASCADE CONSTRAINTS PURGE;
DROP TABLE Passenger CASCADE CONSTRAINTS PURGE;
DROP TABLE Faculty CASCADE CONSTRAINTS PURGE;
DROP TABLE Error CASCADE CONSTRAINTS PURGE;
DROP TABLE ACCIDENTINFO CASCADE CONSTRAINTS PURGE;
DROP TABLE CARACCIDENT CASCADE CONSTRAINTS PURGE;
DROP TABLE CAR CASCADE CONSTRAINTS PURGE;
DROP TABLE RESEARCHCENTER CASCADE CONSTRAINTS PURGE;
DROP TABLE BELONGTO CASCADE CONSTRAINTS PURGE;
DROP TABLE MAINTENANCETEAM CASCADE CONSTRAINTS PURGE;
DROP TABLE MAINTENANCE CASCADE CONSTRAINTS PURGE;
DROP TABLE MAINTENANCETYPE CASCADE CONSTRAINTS PURGE;


--DATA CLEANING

SELECT * 
FROM moncity.maintenance 
WHERE MAINTENANCEID is NULL OR maintenancedate is NULL OR maintenancecost is NULL OR registrationno is NULL OR teamid is NULL OR maintenancetype is NULL;

SELECT * 
FROM moncity.maintenance 
WHERE registrationno NOT IN (SELECT registrationno FROM moncity.CAR);

SELECT * 
FROM moncity.maintenance 
WHERE teamid NOT IN (SELECT teamid FROM moncity.MAINTENANCETEAM);

SELECT * 
FROM moncity.maintenance 
WHERE maintenancetype NOT IN (SELECT maintenancetype FROM MONCITY.MAINTENANCETYPE);

SELECT * 
FROM moncity.maintenance 
WHERE maintenancecost < 0;

SELECT MAINTENANCEID
FROM moncity.maintenance
GROUP BY MAINTENANCEID
HAVING COUNT(*) > 1;


SELECT maintenancedate, maintenancecost, registrationno, teamid, maintenancetype
FROM moncity.maintenance
GROUP BY maintenancedate, maintenancecost, registrationno, teamid, maintenancetype
HAVING COUNT(*) > 1;

create table MAINTENANCE as
select  * from moncity.maintenance;

Update MAINTENANCE
SET maintenancecost = 200
WHERE maintenanceid = 'M2000';

SELECT * FROM MAINTENANCE WHERE MAINTENANCEID = 'M2000';
--------------------------------------------------------------------------------
SELECT * 
FROM moncity.researchcenter 
WHERE CENTERID is NULL OR CENTERNAME is NULL OR PHONE is NULL OR OPENINGHOUR is NULL;

SELECT CENTERID
FROM moncity.researchcenter
GROUP BY CENTERID
HAVING COUNT(*) > 1;

SELECT CENTERNAME, PHONE, OPENINGHOUR
FROM moncity.researchcenter
GROUP BY CENTERNAME, PHONE, OPENINGHOUR
HAVING COUNT(*) > 1;

CREATE TABLE RESEARCHCENTER AS
select distinct * from moncity.researchcenter ORDER BY CENTERID;

--------------------------------------------------------------------------------

SELECT * 
FROM MONCITY.BELONGTO 
WHERE TEAMID is NULL OR CENTERID is NULL;

SELECT * 
FROM MONCITY.BELONGTO  
WHERE TEAMID NOT IN (SELECT TEAMID FROM MONCITY.MAINTENANCETEAM);

SELECT * 
FROM MONCITY.BELONGTO  
WHERE CENTERID NOT IN (SELECT CENTERID FROM moncity.researchcenter);

SELECT TEAMID, CENTERID
FROM moncity.BELONGTO
GROUP BY TEAMID, CENTERID
HAVING COUNT(*) > 1;

CREATE TABLE BELONGTO AS
SELECT * FROM MONCITY.BELONGTO;

--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.MAINTENANCETEAM 
WHERE TEAMID is NULL OR TEAMLEADER is NULL OR PHONE is NULL;

SELECT TEAMID
FROM moncity.MAINTENANCETEAM
GROUP BY TEAMID
HAVING COUNT(*) > 1;

SELECT TEAMLEADER,PHONE
FROM moncity.MAINTENANCETEAM
GROUP BY TEAMLEADER, PHONE
HAVING COUNT(*) > 1;

CREATE TABLE MAINTENANCETEAM AS
SELECT * FROM MONCITY.MAINTENANCETEAM;

--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.MAINTENANCETYPE 
WHERE MAINTENANCETYPE is NULL OR MAINTENANCEDESCRIPTION is NULL;

SELECT MAINTENANCETYPE
FROM moncity.MAINTENANCETYPE
GROUP BY MAINTENANCETYPE
HAVING COUNT(*) > 1;

SELECT MAINTENANCEDESCRIPTION
FROM moncity.MAINTENANCETYPE
GROUP BY MAINTENANCEDESCRIPTION
HAVING COUNT(*) > 1;

CREATE TABLE MAINTENANCETYPE AS
SELECT * FROM MONCITY.MAINTENANCETYPE;

--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.CAR 
WHERE REGISTRATIONNO is NULL OR CARMODEL is NULL OR MANUFACTURINGYEAR is NULL OR CARBODYTYPE is NULL OR NUMSEATS is NULL;

SELECT REGISTRATIONNO
FROM moncity.CAR
GROUP BY REGISTRATIONNO
HAVING COUNT(*) > 1;

SELECT CARMODEL, MANUFACTURINGYEAR, CARBODYTYPE, NUMSEATS
FROM moncity.CAR
GROUP BY CARMODEL, MANUFACTURINGYEAR, CARBODYTYPE, NUMSEATS
HAVING COUNT(*) > 1;

CREATE TABLE CAR AS
SELECT * FROM MONCITY.CAR;

--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.Booking 
WHERE BOOKINGID is NULL OR REGISTRATIONNO is NULL OR BOOKINGDATE is NULL OR DEPARTUREZONE is NULL OR DESTINATIONZONE is NULL OR PASSENGERID is NULL;


SELECT * 
FROM MONCITY.Booking 
WHERE registrationno NOT IN (SELECT registrationno FROM moncity.CAR);

SELECT * 
FROM MONCITY.Booking 
WHERE PASSENGERID NOT IN (SELECT PASSENGERID FROM moncity.Passenger);

SELECT BOOKINGID
FROM moncity.Booking
GROUP BY BOOKINGID
HAVING COUNT(*) > 1;

SELECT REGISTRATIONNO, BOOKINGDATE, DEPARTUREZONE, DESTINATIONZONE, PASSENGERID
FROM moncity.Booking
GROUP BY REGISTRATIONNO, BOOKINGDATE, DEPARTUREZONE, DESTINATIONZONE, PASSENGERID
HAVING COUNT(*) > 1;

Select count(*) From MonCity.Booking;

CREATE TABLE BOOKING
AS SELECT DISTINCT *
FROM MonCity.Booking;

Select count(*) From Booking;
--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.Passenger 
WHERE PASSENGERID is NULL OR PASSENGERNAME is NULL OR PASSENGERROLE is NULL OR PASSENGERGENDER is NULL OR PASSENGERAGE is NULL OR FACULTYID is NULL;

SELECT * 
FROM MONCITY.Passenger 
WHERE FACULTYID NOT IN (SELECT FACULTYID FROM moncity.Faculty);

SELECT PASSENGERID
FROM moncity.Passenger
GROUP BY PASSENGERID
HAVING COUNT(*) > 1;

SELECT PASSENGERNAME, PASSENGERROLE, PASSENGERGENDER, PASSENGERAGE, FACULTYID
FROM moncity.Passenger
GROUP BY PASSENGERNAME, PASSENGERROLE, PASSENGERGENDER, PASSENGERAGE, FACULTYID
HAVING COUNT(*) > 1;

Select count(*) From MonCity.Passenger;

CREATE TABLE Passenger
AS SELECT DISTINCT *
FROM MonCity.Passenger;


DELETE FROM Passenger WHERE PASSENGERID = 'U163';

Select count(*) From Passenger;
--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.Faculty 
WHERE FACULTYID is NULL OR FACULTYNAME is NULL OR ZONE is NULL;

SELECT FACULTYID
FROM moncity.Faculty
GROUP BY FACULTYID
HAVING COUNT(*) > 1;

SELECT FACULTYNAME
FROM moncity.Faculty
GROUP BY FACULTYNAME
HAVING COUNT(*) > 1;

Select count(*) From MonCity.Faculty;

CREATE TABLE Faculty
AS SELECT DISTINCT *
FROM MonCity.Faculty;

Select count(*) From Faculty;
--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.Error 
WHERE ERRORCODE is NULL OR ERRORMESSAGE is NULL;

SELECT ERRORCODE
FROM moncity.Error
GROUP BY ERRORCODE
HAVING COUNT(*) > 1;

SELECT ERRORMESSAGE
FROM moncity.Error
GROUP BY ERRORMESSAGE
HAVING COUNT(*) > 1;

Select count(*) From MonCity.Error;

CREATE TABLE Error
AS SELECT DISTINCT *
FROM MonCity.Error;

Select count(*) From Error;
--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.ACCIDENTINFO 
WHERE ACCIDENTID is NULL OR ACCIDENTZONE is NULL OR CAR_DAMAGE_SEVERITY is NULL OR ERRORCODE is NULL;

SELECT * 
FROM MONCITY.ACCIDENTINFO 
WHERE ERRORCODE NOT IN (SELECT ERRORCODE FROM moncity.Error);

SELECT * 
FROM MONCITY.ACCIDENTINFO 
WHERE ACCIDENTID NOT IN (SELECT ACCIDENTID FROM moncity.CARACCIDENT);

SELECT ACCIDENTID
FROM moncity.ACCIDENTINFO
GROUP BY ACCIDENTID
HAVING COUNT(*) > 1;

Select count(*) From MonCity.ACCIDENTINFO;

CREATE TABLE ACCIDENTINFO
AS SELECT DISTINCT *
FROM MonCity.ACCIDENTINFO;

DELETE FROM ACCIDENTINFO WHERE ACCIDENTID is NULL;
DELETE FROM ACCIDENTINFO WHERE ACCIDENTID = 'A2000';

Select count(*) From ACCIDENTINFO;
--------------------------------------------------------------------------------
SELECT * 
FROM MONCITY.CARACCIDENT 
WHERE REGISTRATIONNO is NULL OR ACCIDENTID is NULL;

SELECT * 
FROM MONCITY.CARACCIDENT 
WHERE REGISTRATIONNO NOT IN (SELECT REGISTRATIONNO FROM moncity.CAR);

SELECT * 
FROM MONCITY.CARACCIDENT 
WHERE ACCIDENTID NOT IN (SELECT ACCIDENTID FROM moncity.ACCIDENTINFO);

SELECT REGISTRATIONNO, ACCIDENTID
FROM moncity.CARACCIDENT
GROUP BY REGISTRATIONNO, ACCIDENTID
HAVING COUNT(*) > 1;

Select count(*) From MonCity.CARACCIDENT;

CREATE TABLE CARACCIDENT
AS SELECT DISTINCT *
FROM MonCity.CARACCIDENT;

Select count(*) From CARACCIDENT;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

