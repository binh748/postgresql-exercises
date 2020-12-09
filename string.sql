/* Contains my answers to the "String" exercises on pgexercises.com.
For some exercises, I've writen multiple answers where one is usually the
more elegant version. */

-- 1. Format the names of members

SELECT CONCAT(surname, ', ', firstname)
  FROM cd.members;

-- 2. Find facilities by a name prefix

SELECT *
  FROM cd.facilities
 WHERE name LIKE 'Tennis%';

-- 3. Perform a case-insensitive search

SELECT *
  FROM cd.facilities
 WHERE name ILIKE 'Tennis%';

 SELECT *
   FROM cd.facilities
  WHERE LOWER(name) LIKE 'tennis%';

-- 4. Find telephone numbers with parantheses

SELECT memid, telephone
  FROM cd.members
 WHERE telephone SIMILAR TO '\(___\)%';

 SELECT memid, telephone
   FROM cd.members
  WHERE telephone ~ '\(...\)';

-- 5. Pad zip codes with leading zeroes

SELECT LPAD(zipcode::char(5), 5, '0') AS zip
  FROM cd.members
 ORDER BY zip;
