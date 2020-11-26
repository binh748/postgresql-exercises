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
	((SELECT MAX(facid)+1
	  FROM cd.facilities), 'Spa', 20, 30, 100000, 800);

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
