/* We want to reward our users who have been around the longest
   Finding the 5 oldest users */

SELECT *
FROM users
ORDER BY created_at
LIMIT 5;

/* What day of the week do most users register on?
   We need to figure out when to schedule an ad campgain */

SELECT 
	DAYNAME(created_at) AS day_of_the_week,
	COUNT(*) AS total_registrations
FROM users
GROUP BY day_of_the_week
ORDER BY total_registrations DESC
LIMIT 2;

/* Version 2 */

SELECT 
	DATE_FORMAT(created_at,'%W') AS day_of_the_week,
    COUNT(*) AS total_registrations
FROM users
GROUP BY 1
ORDER BY 2 DESC
LIMIT 2;

/* We want to target our inactive users with an email campaign.
Find the users who have never posted a photo */

SELECT username
FROM users
LEFT JOIN photos
	ON users.id = photos.user_id
WHERE photos.image_url IS NULL;
 
 /* We're running a new contest to see who can get the most likes on a single photo.
 WHO WON??!! */
 
 SELECT 
	users.username,
	photos.id, 
	photos.image_url, 
    COUNT(*) AS total
FROM photos
INNER JOIN likes
	ON likes.photo_id = photos.id
INNER JOIN users
	ON photos.user_id = users.id
GROUP BY photos.id
ORDER BY total DESC 
LIMIT 1;

/* Our Investors want to know...
How many times does the average user post? */
/* Total number of photos/ Total number of users */

SELECT ROUND((SELECT COUNT(*) FROM photos) / (SELECT COUNT(*) FROM users), 2) AS avg;

/* user ranking by postings higher to lower */

SELECT 
	users.username, 
	COUNT(photos.image_url) AS number_of_photos_shared
FROM users
JOIN photos 
	ON users.id = photos.user_id
GROUP BY users.id
ORDER BY number_of_photos_shared DESC;

/* Total posts by users (longer version of SELECT COUNT(*) FROM photos) */

SELECT 
	SUM(user_posts.total_posts_per_user)
FROM (SELECT 
		users.username, 
        COUNT(photos.image_url) AS total_posts_per_user
	  FROM users
      JOIN photos 
		ON users.id = photos.user_id
      GROUP BY users.id) AS user_posts;
      
/* Total number of users who have posted at least one time */

SELECT 
	COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM users
JOIN photos 
	ON users.id = photos.user_id;

/* A brand wants to know which hashtags to use in a post.
What are the top 5 most commonly used hashtags? */

SELECT 
	tags.tag_name,
    COUNT(tag_name) AS total
FROM tags
JOIN photo_tags 
	ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC
LIMIT 5;

/* We have a small problem with bots on our site...
Find users who have liked every single photo on the site */

SELECT 
	username,
    COUNT(*) AS num_likes
FROM users 
INNER JOIN likes
	ON users.id = likes.user_id
GROUP BY username
HAVING num_likes = (SELECT COUNT(*) FROM photos);

/* We also have a problem with celebrities.
Find users who have never commented on a photo */

SELECT COUNT(DISTINCT users.id)
FROM users
LEFT JOIN comments 
ON users.id = comments.user_id
WHERE comment_text IS NULL;

/* Mega Challenges */
/* Are we overrun by bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have liked every photo */

SELECT tableA.total_A AS 'Number Of Users who never commented',
		ROUND((tableA.total_A/(SELECT COUNT(*) FROM users)),2)*100 AS '%',
		tableB.total_B AS 'Number of Users who likes every photos',
		ROUND((tableB.total_B/(SELECT COUNT(*) FROM users)),2)*100 AS '%'
FROM
	( 	SELECT COUNT(DISTINCT users.id) AS total_A
		FROM users
		LEFT JOIN comments 
			ON users.id = comments.user_id
		WHERE comment_text IS NULL
	) AS tableA
	JOIN 
    (	SELECT COUNT(*) AS total_B
		FROM
			(	
				SELECT 
				username,
				COUNT(*) AS num_likes
				FROM users 
				INNER JOIN likes
					ON users.id = likes.user_id
				GROUP BY username
				HAVING num_likes = (SELECT COUNT(*) FROM photos)
			) AS total_number_users_likes_every_photos
	)AS tableB;

/*Find users who have ever commented on a photo*/

SELECT 
	DISTINCT users.id,
    username
FROM users
JOIN comments 
	ON users.id = comments.user_id
ORDER BY users.id;

/*Are we overrun with bots and celebrity accounts?
Find the percentage of our users who have either never commented on a photo or have commented on photos before*/

SELECT tableA.total_A AS 'Number Of Users who never commented',
		ROUND((tableA.total_A/(SELECT COUNT(*) FROM users)),2)*100 AS '%',
		tableB.total_B AS 'Number of Users who commented on photos',
		ROUND((tableB.total_B/(SELECT COUNT(*) FROM users)),2)*100 AS '%'
FROM
	( 
		 	SELECT 
				COUNT(DISTINCT users.id) AS total_A
			FROM users
			LEFT JOIN comments 
				ON users.id = comments.user_id
			WHERE comment_text IS NULL
	) 	AS tableA
	JOIN
	(
			SELECT 
				COUNT(*) AS total_B 
                FROM
				(	SELECT 
                        DISTINCT users.id
					FROM users
					JOIN comments 
						ON users.id = comments.user_id
				)	AS total_number_users_with_comments
	)	AS tableB









 






