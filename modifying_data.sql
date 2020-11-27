/* Contains my answers to the "Modifying data" exercises on pgexercises.com.
For some exercises, I've writen multiple answers where one is usually the
more elegant version. */

-- 1. Insert some data into a cost_table

INSERT INTO
  cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
  VALUES
    (9, 'Spa', 20, 30, 100000, 800);

-- 2. Insert multiple rows of data into a cost_table

INSERT INTO
	cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES
	(9, 'Spa', 20, 30, 100000, 800),
	(10, 'Squash Court 2', 3.5, 17.5, 5000, 80);

-- 3. Insert calculated data into a table

INSERT INTO
	cd.facilities(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES
	((SELECT MAX(facid)
	    FROM cd.facilities)+1, 'Spa', 20, 30, 100000, 800);

-- 4. Update some existing data

UPDATE cd.facilities
   SET initialoutlay = 10000
 WHERE name = 'Tennis Court 2';

-- 5. Update multiple rows and columns at the same time

-- When using a CASE clause to update rows, I always need to supply an ELSE condition
-- to tell SQL how to populate the column for when the condition is not met.
-- Usually, I'll just populate the column with its existing values in the ELSE condition.
 UPDATE cd.facilities
   SET membercost = (CASE WHEN name LIKE 'Tennis Court%' THEN 6 ELSE membercost END),
       guestcost = (CASE WHEN name LIKE 'Tennis Court%' THEN 30 ELSE guestcost END);

UPDATE cd.facilities
   SET membercost = 6,
       guestcost = 30
 WHERE name LIKE 'Tennis Court%';

-- 6. Update a row based on the contents of another row

UPDATE cd.facilities
   SET membercost = (SELECT membercost
					             FROM cd.facilities
					            WHERE name = 'Tennis Court 1') * 1.1,
	     guestcost = (SELECT guestcost
					            FROM cd.facilities
					           WHERE name = 'Tennis Court 1') * 1.1
 WHERE name = 'Tennis Court 2';

-- 7. Delete all bookings

TRUNCATE cd.bookings;

DELETE FROM cd.bookings;

-- 8. Delete a member from the cd.members table

DELETE FROM cd.members
 WHERE memid = 37;

-- 9. Delete based on subquery

DELETE FROM cd.members
 WHERE memid NOT IN (SELECT memid
					             FROM cd.bookings);

-- The below is a correlated subquery that reads like this:
-- For every row in cd.members, check if that row has a memid
-- that is in cd.bookings; if not, then delete that row.
DELETE FROM cd.members AS m
 WHERE NOT EXISTS
       (SELECT 1
          FROM cd.bookings
         WHERE memid = m.memid);
  
