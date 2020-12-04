/* Contains my answers to the "Datetime" exercises on pgexercises.com.
For some exercises, I've writen multiple answers where one is usually the
more elegant version. */

-- 1. Produce a timestamp for 1 a.m. on the 31st of August 2012

SELECT '2012-08-31 01:00:00'::timestamp;

SELECT timestamp '2012-08-31 01:00:00';

-- 2. Subtract timestamps from each other

SELECT timestamp '2012-08-31 01:00:00' - timestamp '2012-07-30 01:00:00' AS interval;

-- 3. Generate a list of all the dates in October 2012

SELECT GENERATE_SERIES(timestamp '2012-10-1', timestamp '2012-10-31', '1 day') AS ts;

-- 4. Get the day of the month from a timestamp

SELECT DATE_PART('day', timestamp '2012-08-31') AS date_part;

SELECT EXTRACT(day FROM timestamp '2012-08-31') AS date_part;

-- 5. Work out the number of seconds between timestamps

-- Extracting the epoch converts the interval into number of seconds and a timestamp
-- to the number of seconds since epoch, which is Jan 1, 1970

SELECT EXTRACT(EPOCH FROM timestamp '2012-09-02 00:00:00' - timestamp '2012-08-31 01:00:00') AS date_part;

-- 6. Work out the number of days in each month of 2012

SELECT DATE_PART('month', months) AS month, (months + INTERVAL '1 month') - months AS length
  FROM (SELECT GENERATE_SERIES(timestamp '2012-01-01', timestamp '2012-12-31', '1 month') AS months) AS cal

-- 7. Work out the number of days remaining in the month

SELECT (DATE_TRUNC('month', timestamp '2012-02-11 01:00:00') + INTERVAL '1 month') - DATE_TRUNC('day', timestamp '2012-02-11 01:00:00') AS remaining;

SELECT (DATE_TRUNC('month', test) + INTERVAL '1 month') - DATE_TRUNC('day', test) AS remaining
  FROM (SELECT timestamp '2012-02-11 01:00:00' AS test) AS ts;

-- 8. Work out the end time of bookings

SELECT starttime, starttime + (INTERVAL '30 minutes' * slots) AS endtime
  FROM cd.bookings
 ORDER BY endtime DESC, starttime DESC
 LIMIT 10;

-- 9. Return a count of bookings for each month

SELECT DATE_TRUNC('month', starttime) AS month, COUNT(*)
  FROM cd.bookings
 GROUP BY 1
 ORDER BY 1;
