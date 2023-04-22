-- star schemas

--Drop all the tables if created
DROP Table FacultyDim CASCADE CONSTRAINTS PURGE;
DROP Table TimeDim CASCADE CONSTRAINTS PURGE;
DROP Table AgeGroupDim CASCADE CONSTRAINTS PURGE;
DROP Table CarDim_v1 CASCADE CONSTRAINTS PURGE;
DROP Table TeamCenterBridgeTable CASCADE CONSTRAINTS PURGE;
DROP Table MaintenanceTypeDim CASCADE CONSTRAINTS PURGE;
DROP Table MaintenanceTeamDim CASCADE CONSTRAINTS PURGE;
DROP Table ResearchCenterDim CASCADE CONSTRAINTS PURGE;
DROP Table AccidentInfoDim CASCADE CONSTRAINTS PURGE;
DROP Table CarAccidentBridgeTable CASCADE CONSTRAINTS PURGE;
DROP Table ErrorDim CASCADE CONSTRAINTS PURGE;

DROP Table Booking_Temp_Fact CASCADE CONSTRAINTS PURGE;
DROP Table BookingFact_v1 CASCADE CONSTRAINTS PURGE;
DROP Table MaintenanceFact CASCADE CONSTRAINTS PURGE;
DROP Table AccidentFact CASCADE CONSTRAINTS PURGE;

-- VERSION 1 STAR SCHEMA
-- CREATING DIMENSIONS

Create Table FacultyDim as
SELECT FacultyID, FacultyName, Zone
FROM Faculty;

Create Table TimeDim as
SELECT DISTINCT TO_CHAR(BOOKINGDATE, 'MONTH') AS "Month" 
FROM BOOKING ;

Create Table AgeGroupDim 
( AGEGROUPID varchar2(25),
AGEGROUPDESC varchar2(25),
AGEGROUPSTART number,
AGEGROUPEND number);

Insert into AgeGroupDim values ('Group1', 'Young adults', 18,35);
Insert into AgeGroupDim values ('Group2', 'middle-aged adults', 36,59);
Insert into AgeGroupDim values ('Group3', 'old-aged adults', 60,null);


Create Table CarDim_v1 as
SELECT RegistrationNO, CarBodyType, NumSeats
FROM Car;


Create Table MaintenanceTypeDim as
SELECT *
FROM MaintenanceType;

Create Table MaintenanceTeamDim as
SELECT T.TeamID, 1.0/count(R.CenterID) as WeightFactor, listagg(R.CenterID, '_') within group (order by R.CenterID) as ResearchCenterGroupList
FROM MaintenanceTeam T, BELONGTO B, RESEARCHCENTER R
WHERE T.TeamID = B.TeamID AND B.CenterID = R.CenterID
GROUP BY T.TeamID;

Create Table TeamCenterBridgeTable as
SELECT *
FROM BELONGTO;

Create Table ResearchCenterDim as
SELECT CenterID, CenterName
FROM ResearchCenter;

Create Table AccidentInfoDim as
SELECT A.AccidentID, A.AccidentZone, A.CAR_DAMAGE_SEVERITY, 1.0/count(C.RegistrationNO) as WeightFactor, listagg(C.RegistrationNO, '_') within group (order by C.RegistrationNO) as CarGroupList
FROM AccidentInfo A, CAR c, CARACCIDENT CA
WHERE A.AccidentID = CA.AccidentID AND CA.RegistrationNO = C.RegistrationNO
GROUP BY A.AccidentID, A.AccidentZone, A.CAR_DAMAGE_SEVERITY;

Create Table CarAccidentBridgeTable as
SELECT *
FROM CARACCIDENT;

Create Table ErrorDim as
SELECT ErrorCode, ErrorMessage
FROM Error;

--------------------------------------------------------------------------------
-- BOOKING FACT VERSION 1

create table Booking_Temp_Fact as
select c.registrationNo, f.facultyid, TO_CHAR(b.bookingdate,'Month') as Month, p.passengerage
from car c, faculty f, booking b, passenger p 
where
c.registrationNo = b.registrationNo and
b.passengerid = p.passengerid and
p.facultyid = f.facultyid
group by c.registrationNo, f.facultyid, b.bookingdate, p.passengerage;

alter table Booking_Temp_fact
add AgeGroupID varchar2(25);

Update Booking_Temp_fact
SET AgeGroupID = 
CASE
WHEN PassengerAge >= 18 and PassengerAge < 36 THEN 'Group1'
WHEN PassengerAge >= 36 and PassengerAge < 60 THEN 'Group2'
WHEN PassengerAge >= 60 THEN 'Group3'
END;

create table BookingFact_v1 as
select RegistrationNo, facultyID, Month, AgeGroupID, count(*) as Num_of_Bookings
from Booking_Temp_Fact
group by registrationNo, facultyID, Month, AgeGroupID;

--------------------------------------------------------------------------------
-- ACCIDENT FACT

Create table AccidentFact as
select a.accidentid, e.errorcode, count(a.accidentid) as Num_of_Accidents
from AccidentInfo a, error e
WHERE a.errorcode = e.errorcode
group by a.accidentid, e.errorcode;

--------------------------------------------------------------------------------
-- MAINTENANCE FACT

create table MaintenanceFact as
select mt.teamid, mt2.maintenancetype, c.registrationno, count(*) as Number_of_MaintenanceRecords, sum(m.maintenancecost) as Total_Maintenance_Cost 
from maintenanceteam mt, MAINTENANCETYPE mt2, car c, maintenance m
where m.teamid = mt.teamid AND m.maintenancetype = mt2.maintenancetype AND m.registrationno = c.registrationno
group by mt.teamid, mt2.maintenancetype, c.registrationno;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- VERSION 2 STAR SCHEMA

--Drop all the tables if created
DROP Table CarDim_v2 CASCADE CONSTRAINTS PURGE;
DROP Table PassengerDim CASCADE CONSTRAINTS PURGE;
DROP Table BookingDateDim CASCADE CONSTRAINTS PURGE;
DROP Table BookingTimeDim CASCADE CONSTRAINTS PURGE;
DROP Table BookingFact_v2 CASCADE CONSTRAINTS PURGE;


-- CREATING DIMENSIONS

Create Table CarDim_v2 as
SELECT *
FROM Car;


Create Table PassengerDim as
SELECT *
FROM Passenger;

Create Table BookingDateDim as
select distinct to_char(BookingDate, 'DD-MM-YYYY') as BookingDate
FROM Booking;


Create Table BookingTimeDim as
select distinct to_char(BookingDate, 'HH:MI') as BookingTime
FROM Booking;

--------------------------------------------------------------------------------
-- BOOKING FACT VERSION 2

create table BookingFact_v2 as 
select c.registrationNo, f.facultyid, to_char(b.BookingDate, 'DD-MM-YYYY') as BookingDate, to_char(b.BookingDate, 'HH:MI') as BookingTime, p.PASSENGERID, count(*) as Num_of_Bookings
from car c, faculty f, booking b, passenger p 
where
c.registrationNo = b.registrationNo and
b.passengerid = p.passengerid and
p.facultyid = f.facultyid
group by c.registrationNo, f.facultyid, to_char(b.BookingDate, 'DD-MM-YYYY'), to_char(b.BookingDate, 'HH:MI'), p.PASSENGERID;