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
