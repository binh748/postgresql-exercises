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

-- 18. Rank members by (rounded) hours used

SELECT m.firstname, m.surname, ROUND(SUM(slots * 0.5), -1) AS hours,
       RANK() OVER(ORDER BY ROUND(SUM(slots * 0.5), -1) DESC) AS "rank"
  FROM cd.members AS m
  JOIN cd.bookings AS b
 USING(memid)
 GROUP BY 1, 2
 ORDER BY "rank", 2, 1;

-- 19. Find the top three revenue generating facilities

WITH facility_revenue AS (
  SELECT f.name, DENSE_RANK() OVER(ORDER BY SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
				                                             ELSE f.membercost * b.slots END) DESC) AS "rank"
    FROM cd.bookings AS b
    JOIN cd.facilities AS f
   USING(facid)
   GROUP BY 1
)

SELECT name, "rank"
  FROM facility_revenue
 WHERE "rank" IN (1, 2, 3)
 ORDER BY "rank", name;

-- 20. Classify facilities by value

WITH facility_revenue_thirds AS (
  SELECT f.name, NTILE(3) OVER(ORDER BY SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
                                                 ELSE f.membercost * b.slots END) DESC) AS thirds
    FROM cd.bookings AS b
    JOIN cd.facilities AS f
   USING(facid)
   GROUP BY 1
)

SELECT name, CASE WHEN thirds = 1 THEN 'high'
                  WHEN thirds = 2 THEN 'average'
				  ELSE 'low' END AS revenue
 FROM facility_revenue_thirds
ORDER BY thirds, name;

-- 21. Calculate the payback time for each facility

-- Because I linked the two tables together, I get a facility row for
-- each of the bookings, so when I sum initialoutlay and monthlymaintenance, I'm summing them up
-- multiple times for each booking, which is wrong. Beware of this!

-- If I don't include the column in the aggregate function, it won't be aggregated, so that's
-- how I can operate on aggregated columns and non-aggregated columns. But this only works
-- if I do GROUP BY facid (the table's primary key), which is a weird quirk to me. Not sure
-- why that works.

WITH initial_outlay AS (
  SELECT name, initialoutlay AS cost
    FROM cd.facilities
),
monthly_avg_profit AS (
  SELECT f.name, (SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
                           ELSE f.membercost * b.slots END) / 3 - f.monthlymaintenance) AS profit
    FROM cd.bookings AS b
    JOIN cd.facilities AS f
   USING(facid)
   GROUP BY f.facid
)

SELECT i.name, i.cost / m.profit AS months
  FROM initial_outlay AS i
  JOIN monthly_avg_profit AS m
 USING(name)
 ORDER BY 1;

-- 22. Calculate a rolling average of total revenue

-- Remember that a 15-day rolling average includes the current row,
-- hence why 14 PRECEDING instead of 15

-- Aggregations work in the OVER() clause, but not the aggregate function itself
-- For example, AVG(revenue) is going to compute the AVG revenue per booking without
-- any aggregation, whereas I want to compute the rolling average of daily revenue

-- Don't need to do COALESCE with AVG(d.revenue) because null values will be counted as 0
-- when I do the averaging

WITH all_dates AS (
  SELECT CAST(GENERATE_SERIES('2012-07-01'::timestamp, '2012-08-31', '1 day') AS date) AS date
),
daily_revenue AS (
  SELECT CAST(b.starttime AS date), SUM(CASE WHEN b.memid = 0 THEN f.guestcost * b.slots
                                             ELSE f.membercost * b.slots END) AS revenue
    FROM cd.bookings AS b
    JOIN cd.facilities AS f
   USING(facid)
   GROUP BY 1
),
rolling_revenue AS (SELECT a.date, AVG(d.revenue)
                                  OVER(ORDER BY a.date ASC
											                 ROWS BETWEEN 14 PRECEDING AND CURRENT ROW) AS revenue
                      FROM all_dates AS a
				              LEFT JOIN daily_revenue AS d
                        ON a.date = d.starttime
)
SELECT date, revenue
  FROM rolling_revenue
 WHERE date BETWEEN '2012-08-01' AND '2012-08-31'
 ORDER BY 1;
