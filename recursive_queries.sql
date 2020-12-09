/* Contains my answers to the "Recursive Queries" exercises on pgexercises.com.
For some exercises, I've writen multiple answers where one is usually the
more elegant version. */

-- 1. Find the upward recommendation chain for member ID 27

WITH RECURSIVE upward_recommender_chain AS (
  SELECT m1.recommendedby AS recommender, m2.firstname, m2.surname
    FROM cd.members AS m1
    JOIN cd.members AS m2
      ON m1.recommendedby = m2.memid
   WHERE m1.memid = 27

   UNION ALL

  SELECT m3.recommendedby AS recommender, m4.firstname, m4.surname
    FROM cd.members AS m3
    JOIN upward_recommender_chain AS u
  	  ON m3.memid = u.recommender
    JOIN cd.members AS m4
      ON m3.recommendedby = m4.memid
)
SELECT *
  FROM upward_recommender_chain
 ORDER BY recommender DESC;

-- Below solution is cleaner because I only need to get the recommender_ids
-- in my recursive CTEs and then get the firstname and surname of those recommender_ids
-- in my main query.

-- Can use UNION ALL becuase recommender chains shouldn't be circular; hence, all recommenders
-- in a single chain should be distinct

WITH RECURSIVE upward_recommender_chain AS (
  SELECT m1.recommendedby
    FROM cd.members AS m1
   WHERE m1.memid = 27

   UNION ALL

  SELECT m2.recommendedby
    FROM cd.members AS m2
    JOIN upward_recommender_chain AS u
  	  ON m2.memid = u.recommendedby
)

SELECT u.recommendedby AS recommender, m.firstname, m.surname
  FROM upward_recommender_chain AS u
  JOIN cd.members AS m
    ON u.recommendedby = m.memid
 ORDER BY 1 DESC;

-- 2. Find the downward recommendation chain for member ID 1

WITH RECURSIVE downward_rec_chain AS (
  SELECT m1.memid
    FROM cd.members AS m1
   WHERE m1.recommendedby = 1

   UNION ALL

  SELECT m2.memid
    FROM cd.members AS m2
    JOIN downward_rec_chain AS d
      ON m2.recommendedby = d.memid
)

SELECT d.memid, m.firstname, m.surname
  FROM downward_rec_chain AS d
  JOIN cd.members AS m
    ON d.memid = m.memid
 ORDER BY 1;

-- 3. Produce a CTE that can return the upward recommendation chain for any member

WITH RECURSIVE recommenders AS (
	SELECT m1.memid, m1.recommendedby
      FROM cd.members AS m1

     UNION ALL

    SELECT r.memid, m2.recommendedby
      FROM cd.members AS m2
      JOIN recommenders AS r
        ON m2.memid = r.recommendedby
)

SELECT r.memid AS member, r.recommendedby AS recommender, m.firstname, m.surname
  FROM recommenders AS r
  JOIN cd.members AS m
    ON r.recommendedby = m.memid
 WHERE r.memid IN (12, 22)
 ORDER BY member, recommender DESC;
