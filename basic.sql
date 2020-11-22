/* Contains my answers to the "Basic" exercises on pgexercises.com.
For some exercises, I've writen multiple answers where one is usually the
more elegant version. */

-- 1. Retrieve everything from a table

SELECT *
  FROM cd.facilities;

-- 2. Retrieve specific columns from a table

SELECT name, membercost
  FROM cd.facilities;

-- 3. Control which rows are retrieved

SELECT *
  FROM cd.facilities
 WHERE membercost > 0;

 -- 4. Control which rows are retrieved - part 2

 SELECT facid, name, membercost, monthlymaintenance
  FROM cd.facilities
 WHERE membercost > 0
   AND membercost < monthlymaintenance * 1/50;

-- 5. Basic string searches

SELECT *
  FROM cd.facilities
 WHERE name LIKE '%Tennis%';

 -- 6. Matching against multiple possible values

 SELECT *
   FROM cd.facilities
  WHERE facid in (1, 5);

SELECT *
  FROM cd.facilities
 WHERE facid = 1

 UNION ALL

 SELECT *
   FROM cd.facilities
  WHERE facid = 5;

-- 7. Classify results into buckets

SELECT name, CASE WHEN monthlymaintenance > 100 THEN 'expensive'
                  ELSE 'cheap' END AS cost
  FROM cd.facilities;

-- 8. Working with dates

SELECT memid, surname, firstname, joindate
  FROM cd.members
 WHERE joindate >= '2012-09-01';

-- 9. Removing duplicates, and ordering results

SELECT DISTINCT surname
  FROM cd.members
 ORDER BY surname
 LIMIT 10;

 -- 10. Combining results from multiple queries

 SELECT surname
  FROM cd.members

 UNION

SELECT name
  FROM cd.facilities;

-- 11. Simple aggregation

SELECT joindate AS latest
  FROM cd.members
 ORDER BY joindate DESC
 LIMIT 1;

SELECT MAX(joindate) AS latest
  FROM cd.members;

-- 12. More aggregation

SELECT firstname, surname, joindate
  FROM cd.members
 WHERE joindate = (SELECT MAX(joindate)
				   FROM cd.members);
