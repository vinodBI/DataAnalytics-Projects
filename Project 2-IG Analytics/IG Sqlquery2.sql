CREATE DATABASE ig_clonejob_datajob_datajob_data;
USE ig_clone;
/*Users*/
CREATE TABLE users (
    id INT AUTO_INCREMENT UNIQUE PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW ()
);
/*Photos*/
CREATE TABLE photos(
	id INT AUTO_INCREMENT PRIMARY KEY,
	image_url VARCHAR(355) NOT NULL,
	user_id INT NOT NULL,
	created_dat TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id)
);
/*Comments*/
CREATE TABLE comments(
	id INT AUTO_INCREMENT PRIMARY KEY,
	comment_text VARCHAR(255) NOT NULL,
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id)
);
/*Likes*/
CREATE TABLE likes(
	user_id INT NOT NULL,
	photo_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY(user_id) REFERENCES users(id),
	FOREIGN KEY(photo_id) REFERENCES photos(id),
	PRIMARY KEY(user_id,photo_id)
);
/*follows*/
CREATE TABLE follows(
	follower_id INT NOT NULL,
	followee_id INT NOT NULL,
	created_at TIMESTAMP DEFAULT NOW(),
	FOREIGN KEY (follower_id) REFERENCES users(id),
	FOREIGN KEY (followee_id) REFERENCES users(id),
	PRIMARY KEY(follower_id,followee_id)
);
/*Tags*/
CREATE TABLE tags(
	id INTEGER AUTO_INCREMENT PRIMARY KEY,
	tag_name VARCHAR(255) UNIQUE NOT NULL,
	created_at TIMESTAMP DEFAULT NOW()
);
/*junction table: Photos - Tags*/
CREATE TABLE photo_tags (
    photo_id INT NOT NULL,
    tag_id INT NOT NULL,
    FOREIGN KEY (photo_id)
        REFERENCES photos (id),
    FOREIGN KEY (tag_id)
        REFERENCES tags (id),
    PRIMARY KEY (photo_id , tag_id)
);
select * from tags;
/*1. Loyal User Reward: The marketing team wants to reward the most loyal users, i.e., those who have been using the platform for the longest time. 
Your Task: Identify the five oldest users on Instagram from the provided database.*/
SELECT 
    *
FROM
    users
ORDER BY created_at ASC
LIMIT 5;
/*Inactive User Engagement: The team wants to encourage inactive users to start posting by sending them promotional emails.
Your Task: Identify users who have never posted a single photo on Instagram.*/
SELECT 
    username
FROM
    users u
        LEFT JOIN
    photos p ON u.id = p.user_id
WHERE
    p.user_id IS NULL;
/*Contest Winner Declaration: The team has organized a contest where the user with the most likes on a single photo wins.
Your Task: Determine the winner of the contest and provide their details to the team.*/
show tables;

SELECT users.username, photos.user_id, likes.photo_id, COUNT(*) as total_likes
FROM likes
JOIN photos ON likes.photo_id = photos.id
JOIN users ON photos.user_id = users.id
GROUP BY photos.user_id, likes.photo_id
ORDER BY total_likes DESC
LIMIT 1;
/*Hashtag Research: A partner brand wants to know the most popular hashtags to use in their posts to reach the most people.
Your Task: Identify and suggest the top five most commonly used hashtags on the platform.*/
/* test query - select tag_id, count(tag_id) as tag_count from photo_tags group by tag_id order by tag_count DESC Limit 5; */
SELECT 
    tags.tag_name,
    photo_tags.tag_id,
    COUNT(*) AS value_occurance
FROM
    photo_tags
        JOIN
    tags ON photo_tags.tag_id = tags.id
GROUP BY photo_tags.tag_id
ORDER BY value_occurance DESC
LIMIT 5;

/*Ad Campaign Launch: The team wants to know the best day of the week to launch ads.
Your Task: Determine the day of the week when most users register on Instagram. Provide insights on when to schedule an ad campaign.*/
SELECT DAYNAME(created_at) as day_of_week, COUNT(*) as total_users
FROM users
GROUP BY day_of_week
ORDER BY total_users DESC
;

/*User Engagement: Investors want to know if users are still active and posting on Instagram or if they are making fewer posts.
Your Task: Calculate the average number of posts per user on Instagram. Also, provide the total number of photos on Instagram divided by the total number of users.*/
/*Calculate the average number of posts per user on Instagram*/
SELECT user_id, COUNT(*) as total_posts
FROM photos
GROUP BY user_id
ORDER BY total_posts DESC;

/*provide the total number of photos on Instagram divided by the total number of users.*/
SELECT AVG(post_count) as average_posts_per_user
FROM (
    SELECT user_id, COUNT(*) as post_count
    FROM photos
    GROUP BY user_id
) as user_posts;

/*Bots & Fake Accounts: Investors want to know if the platform is crowded with fake and dummy accounts.
Your Task: Identify users (potential bots) who have liked every single photo on the site, as this is not typically possible for a normal user.*/
SELECT users.username, user_id
FROM likes join users on likes.user_id = id
GROUP BY user_id
HAVING COUNT(DISTINCT photo_id) = (SELECT COUNT(*) FROM photos);

/*SQL  statement to find out if users are making fewer posts, you can compare the count of photos they have posted in different time periods. For example, you can compare the number of photos posted in the last month with the number of photos posted in the previous month.*/
SELECT last_month.user_id, last_month_posts, IFNULL(previous_month_posts, 0) as previous_month_posts
FROM (
    SELECT user_id, COUNT(*) as last_month_posts
    FROM photos
    WHERE MONTH(created_dat) = MONTH(CURRENT_DATE - INTERVAL 2 MONTH)
    AND YEAR(created_dat) = YEAR(CURRENT_DATE - INTERVAL 2 MONTH)
    GROUP BY user_id
) as last_month
LEFT JOIN (
    SELECT user_id, COUNT(*) as previous_month_posts
    FROM photos
    WHERE MONTH(created_dat) = MONTH(CURRENT_DATE - INTERVAL 5 MONTH)
    AND YEAR(created_dat) = YEAR(CURRENT_DATE - INTERVAL 5 MONTH)
    GROUP BY user_id
) as previous_month ON last_month.user_id = previous_month.user_id;

