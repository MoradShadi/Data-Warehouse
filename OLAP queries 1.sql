-- OLAP QUERIES 

-- REPORT 1

select b.facultyID, b.month, sum(num_of_bookings) as Total_Bookings ,
to_char(sum(sum(num_of_bookings)) 
over (ORDER BY TO_DATE('01'||b.month||'0001','DD-Month-YYYY') ROWS UNBOUNDED PRECEDING), '9,999,999') AS Cumulative_Number_Of_Booking_Records
from BookingFact_v1 b, facultyDim f
where 
b.facultyID = f.facultyID and
f.FacultyID = 'FIT'
GROUP BY b.facultyID, b.month;



--------------------------------------------------------------------------------

-- REPORT 2

SELECT
DECODE(GROUPING(M.teamid), 1, 'All Teams', M.teamid) AS
"Team ID",
DECODE(GROUPING(C.CarBodyType), 1, 'All Car Body Types', C.CarBodyType) AS
"Car body type",
SUM(M.Number_of_MaintenanceRecords) AS "Total number of maintenance", 
SUM(M.Total_Maintenance_Cost) AS "Total maintenance cost"
FROM MaintenanceFact M , MaintenanceTeamDim MT, CarDim_v1 C
WHERE M.TeamID = MT.TeamID AND M.RegistrationNo = C.RegistrationNo AND M.TEAMID in ('T002','T003')
GROUP BY CUBE(M.TeamID, C.CarBodyType);


--------------------------------------------------------------------------------

-- REPORT 3

select f.errorcode, c.registrationno, c.carbodytype, sum(num_of_accidents) as Total_num_of_accidents , Dense_Rank() Over (partition by f.ErrorCode Order by sum(num_of_accidents) desc) as dense_rank
from AccidentFact f, AccidentInfoDim a, CarAccidentBridgeTable b, Cardim_v1 c, errordim e
where 
a.accidentID = f.accidentID and
f.errorcode = e.errorcode and
a.accidentID = b.accidentID and
b.registrationno = c.registrationno
group by f.errorcode, c.registrationno, c.carbodytype
order by errorcode asc, sum(num_of_accidents) desc;



--------------------------------------------------------------------------------

-- REPORT 4

SELECT C.CARBODYTYPE,
DECODE(GROUPING(A.AGEGROUPID), 1, 'All Age Groups', A.AGEGROUPID) AS "Age group ",
DECODE(GROUPING(F.FACULTYID), 1, 'All Faculties', F.FACULTYID) AS "Faculty ID",
SUM(B.NUM_OF_BOOKINGS) AS "Total number of bookings"
FROM AGEGROUPDIM A, CarDim_v1 C, FACULTYDIM F, BookingFact_v1 B
WHERE B.RegistrationNo = C.RegistrationNo AND B.AGEGROUPID = A.AGEGROUPID AND B.FACULTYID = F.FACULTYID AND C.CARBODYTYPE = 'People Mover' 
GROUP BY C.CARBODYTYPE, CUBE(A.AGEGROUPID, F.FACULTYID);

--------------------------------------------------------------------------------
