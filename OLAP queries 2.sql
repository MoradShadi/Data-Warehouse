-- OLAP QUERIES 

-- REPORT 5

SELECT 
DECODE(GROUPING(F.FacultyName), 1, 'All Faculty', F.FacultyName) As "Faculty",
DECODE(GROUPING(C.CarBodyType), 1, 'All Car Type', C.CarBodyType) AS "Car BodyType",
DECODE(GROUPING(B.Month), 1, 'All year', B.Month) AS "Month",
SUM(B.NUM_OF_BOOKINGS) AS "Total number of bookings"
FROM FacultyDIM F, CarDim_v1 C , BOOKINGFACT_v1 B
WHERE B.RegistrationNo = C.RegistrationNo AND B.FacultyID = F.FacultyID
GROUP BY ROLLUP(F.FacultyName, C.CarBodyType, B.Month)
ORDER BY F.FacultyName, C.CarBodyType, TO_DATE(B.Month, 'MM');



--------------------------------------------------------------------------------

-- REPORT 6

SELECT C.NumSeats,
DECODE(GROUPING(A.AGEGROUPID), 1, 'All Age Groups', A.AGEGROUPID) AS "Age group",
DECODE(GROUPING(B.Month), 1, 'All year', B.Month) AS "Month",
SUM(B.NUM_OF_BOOKINGS) AS "Total number of bookings"
FROM AGEGROUPDIM A, CarDim_v1 C , BookingFact_v1 B
WHERE B.RegistrationNo = C.RegistrationNo AND B.AGEGROUPID = A.AGEGROUPID
GROUP BY C.NumSeats, ROLLUP(A.AGEGROUPID, B.Month)
ORDER BY C.NumSeats, A.AGEGROUPID, TO_DATE(B.Month, 'MM');


--------------------------------------------------------------------------------

-- REPORT 7

SELECT 
F.FacultyName, B.Month,
TO_CHAR(SUM(B.NUM_OF_BOOKINGS),'9,999,999,999' )AS "Total number of bookings",
TO_CHAR (AVG(SUM(B.NUM_OF_BOOKINGS)) OVER 
(ORDER BY F.FacultyName, TO_DATE(B.Month, 'MM') 
ROWS 2 PRECEDING),'9,999,999,999') AS "Moving 3 Month Avg"
FROM FacultyDIM F, BOOKINGFACT_v1 B
WHERE B.FacultyID = F.FacultyID
GROUP BY F.FacultyName, B.Month;



--------------------------------------------------------------------------------

-- REPORT 8

SELECT MT.MAINTENANCEDESCRIPTION,T.TEAMID, to_char(SUM(M.TOTAL_MAINTENANCE_COST), '9,999,999,999') AS "Maintenance cost",
to_char(SUM(SUM(M.TOTAL_MAINTENANCE_COST)) OVER (PARTITION BY MT.MAINTENANCEDESCRIPTION ORDER BY MT.MAINTENANCEDESCRIPTION, T.TEAMID ROWS UNBOUNDED PRECEDING),
'9,999,999,999') AS CUM_MT_COST
FROM MAINTENANCETEAMDIM T, MAINTENANCETYPEDIM MT, MAINTENANCEFACT M
WHERE M.TEAMID = T.TEAMID AND M.MAINTENANCETYPE = MT.MAINTENANCETYPE
GROUP BY MT.MAINTENANCEDESCRIPTION, T.TEAMID;