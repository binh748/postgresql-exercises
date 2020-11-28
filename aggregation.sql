/* Contains my answers to the "Aggregation" exercises on pgexercises.com.
For some exercises, I've writen multiple answers where one is usually the
more elegant version. */

-- 1. Count the number of facilities

SELECT COUNT(*)
  FROM cd.facilities;

-- 2. Count the number of expensive facilities

SELECT COUNT(*)
  FROM cd.facilities
 WHERE guestcost >= 10;

-- 3. Count the number of recommendations each member makes

SELECT recommendedby, COUNT(*)
  FROM cd.members
 WHERE recommendedby IS NOT NULL
 GROUP BY recommendedby
 ORDER BY recommendedby;

-- 4. List the total slots booked per facility

SELECT facid, SUM(slots) AS "Total Slots"
  FROM cd.bookings
 GROUP BY facid
 ORDER BY facid;

-- 5. List the total slots booked per facility in a given month

SELECT facid, SUM(slots) AS "Total Slots"
  FROM cd.bookings
 WHERE DATE_TRUNC('month', starttime) = '2012-09-01'
 GROUP BY 1
 ORDER BY 2;

-- 6. List the total slots booked per facility per month

SELECT facid, DATE_PART('month', starttime) AS month, SUM(slots) AS "Total Slots"
  FROM cd.bookings
 WHERE DATE_PART('year', starttime) = '2012'
 GROUP BY 1, 2
 ORDER BY 1, 2;

-- 7. Find the count of members who have made at least one booking

SELECT COUNT(*)
  FROM (SELECT memid, COUNT(*)
		      FROM cd.bookings
		     GROUP BY 1
		    HAVING COUNT(*) > 0) AS more_than_one_booking;

SELECT COUNT(DISTINCT memid)
  FROM cd.bookings;

-- 8. List facilities with more than 1000 slots booked

SELECT facid, SUM(slots) AS "Total Slots"
  FROM cd.bookings
 GROUP BY 1
HAVING SUM(slots) > 1000
 ORDER BY 1;

-- 9. Find the total revenue of each facility

SELECT f.name, SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
				                ELSE f.membercost * b.slots END) AS revenue
  FROM cd.bookings AS b
  JOIN cd.facilities AS f
 USING(facid)
 GROUP BY 1
 ORDER BY 2;

-- 10. Find facilities with a total revenue less than 1000

SELECT f.name, SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
				        ELSE f.membercost * b.slots END) AS revenue
  FROM cd.bookings AS b
  JOIN cd.facilities AS f
 USING(facid)
 GROUP BY 1
HAVING SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
				ELSE f.membercost * b.slots END) < 1000
 ORDER BY 2;

SELECT name, revenue
  FROM (SELECT f.name, SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
				        ELSE f.membercost * b.slots END) AS revenue
  	      FROM cd.bookings AS b
          JOIN cd.facilities AS f
         USING(facid)
         GROUP BY 1) AS revenue_agg
 WHERE revenue < 1000
 ORDER BY revenue;

-- 11. Output the facility id that has the highest number of slots booked

WITH slots_agg AS (
  SELECT facid, SUM(slots) AS "Total Slots"
	  FROM cd.bookings
   GROUP BY 1
)

SELECT facid, "Total Slots"
  FROM slots_agg
 WHERE "Total Slots" = (SELECT MAX("Total Slots")
						              FROM slots_agg);

-- 12. List the total slots booked per facility per month, part 2

SELECT facid, DATE_PART('month', starttime) AS month, SUM(slots) AS slots
  FROM cd.bookings
 WHERE DATE_PART('year', starttime) = '2012'
 GROUP BY ROLLUP(facid, month)
 ORDER BY 1, 2;

-- 13. List the total hours booked per named facility

SELECT f.facid, f.name, ROUND(SUM(b.slots * 30.0 / 60.0), 2) AS "Total Hours"
  FROM cd.bookings AS b
  JOIN cd.facilities AS f
 USING(facid)
 GROUP BY 1, 2
 ORDER BY 1;

-- 14. List each member's first booking after September 1st 2012

-- Because of the inner join, any members who don't have a booking will
-- not be included in the result set
SELECT m.surname, m.firstname, m.memid, MIN(b.starttime) AS starttime
  FROM cd.members AS m
  JOIN cd.bookings AS b
 USING(memid)
 WHERE starttime >= '2012-09-01'
 GROUP BY 1, 2, 3
 ORDER BY 3;

-- 15. Produce a list of member names, with each row containing the total member count

SELECT COUNT(*) OVER(), firstname, surname
  FROM cd.members
 ORDER BY joindate;

-- 16. Produced a numbered list of members

SELECT ROW_NUMBER() OVER(ORDER BY joindate), firstname, surname
  FROM cd.members
 ORDER BY 1;

-- 17. Output the facility id that has the highest number of slots booked, again

WITH rank_slots AS (
  SELECT facid, SUM(slots) AS total, RANK() OVER(ORDER BY SUM(slots) DESC) AS "rank"
    FROM cd.bookings
   GROUP BY 1
)

SELECT facid, total
  FROM rank_slots
 WHERE "rank" = 1;
