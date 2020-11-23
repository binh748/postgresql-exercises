/* Contains my answers to the "Joins and Subqueries" exercises on pgexercises.com.
For some exercises, I've writen multiple answers where one is usually the
more elegant version. */

-- 1. Retrieve the start times of members' bookings

SELECT b.starttime
  FROM cd.members AS m
  JOIN cd.bookings AS b
 USING(memid)
 WHERE CONCAT(firstname, ' ', surname) = 'David Farrell';

 -- 2. Work out the start times of bookings for tennis courts

SELECT b.starttime AS start, f.name
  FROM cd.bookings AS b
  JOIN cd.facilities AS f
 USING(facid)
 WHERE f.name LIKE 'Tennis Court%'
   AND DATE_TRUNC('day', b.starttime) = '2012-09-21'
 ORDER BY b.starttime;

 -- 3. Produce a list of all members who have recommended another member

SELECT DISTINCT m2.firstname, m2.surname
  FROM cd.members AS m1
  JOIN cd.members AS m2
    ON m1.recommendedby = m2.memid
 ORDER BY m2.surname, m2.firstname;

 -- 4. Produce a list of all members, along with their recommender

SELECT m1.firstname AS memfname, m1.surname AS memsname,
        m2.firstname AS recfname, m2.surname AS recsname
 FROM cd.members AS m1
 LEFT JOIN cd.members AS m2
   ON m1.recommendedby = m2.memid
ORDER BY m1.surname, m1.firstname;

 -- 5. Produce a list of all members who have used a tennis court

SELECT DISTINCT CONCAT(m.firstname, ' ', m.surname) AS member,
       f.name AS facility
  FROM cd.members AS m
  JOIN cd.bookings AS b
    ON m.memid = b.memid
  JOIN cd.facilities AS f
    ON b.facid = f.facid
 WHERE f.name LIKE 'Tennis Court%'
 ORDER BY member, facility;

SELECT DISTINCT CONCAT(m.firstname, ' ', m.surname) AS member,
       f.name AS facility
  FROM cd.members AS m
  JOIN cd.bookings AS b
 USING(memid)
  JOIN cd.facilities AS f
 USING(facid)
 WHERE f.name LIKE 'Tennis Court%'
 ORDER BY member, facility;

 -- 6. Produce a list of costly bookings

-- Important thing here is to check if the booking is from a member or a guest,
-- which can easily be done using CASE statements

SELECT CONCAT(m.firstname, ' ', m.surname) AS member,
       f.name AS facility,
       CASE WHEN m.memid = 0 THEN f.guestcost * b.slots
	        ELSE f.membercost * b.slots END AS cost
  FROM cd.members AS m
  JOIN cd.bookings AS b
 USING(memid)
  JOIN cd.facilities AS f
 USING(facid)
 WHERE DATE_TRUNC('day', starttime) = '2012-09-14'
   AND CASE WHEN m.memid = 0 THEN f.guestcost * b.slots
	        ELSE f.membercost * b.slots END > 30;

-- 7. Produce a list of all members, along with their recommender, using no joins.

SELECT DISTINCT CONCAT(m1.firstname, ' ', m1.surname) AS member,
        (SELECT CONCAT(m2.firstname, ' ', m2.surname) AS recommender
		       FROM cd.members AS m2
		      WHERE m1.recommendedby = m2.memid)
  FROM cd.members AS m1
 ORDER BY member;

-- 8. Produce a list of costly bookings, using a subquery

SELECT member, facility, cost
  FROM (SELECT CONCAT(m.firstname, ' ', m.surname) AS member,
       		   f.name AS facility,
               CASE WHEN m.memid = 0 THEN f.guestcost * b.slots
	                ELSE f.membercost * b.slots END AS cost
		  FROM cd.members AS m
		  JOIN cd.bookings AS b
	   USING(memid)
		  JOIN cd.facilities AS f
	   USING(facid)
     WHERE DATE_TRUNC('day', starttime) = '2012-09-14') AS cost_table
 WHERE cost > 30
 ORDER BY cost DESC;
