use operration_analytics;
/* Create Users table */
create table users(user_id	int,
				   created_at datetime,
                   company_id int,
                   language	varchar(40),
                   activated_at datetime,
                   state varchar(40)
                   );
alter table users change created_at created_at varchar(50);
alter table users change activated_at activated_at varchar(50);
/* add data from users.csv file into created table*/
SHOW VARIABLES LIKE "secure_file_priv";
/*LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv' 
INTO TABLE USERS 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
ignore 1 rows */
/* change data type for columns created above and copy the data of date columns */
 select * from users;
 alter table users add created_at2 datetime;
 update users set created_at2 = str_to_date(created_at, '%d-%m-%Y %H:%i');
 alter table users add activated_at2 datetime;
 update users set activated_at2 = str_to_date(activated_at, '%d-%m-%Y %H:%i');
 alter table users drop column created_at;
 alter table users drop column activated_at;
 alter table users rename column created_at2 to created_at;
 alter table users rename column activated_at2 to activated_at;
 /*------------------------------------------------/
 /*Create events table and enter the data */
 create table events(
					 user_id int,
                     occurred_at varchar(50),
                     event_type	varchar(50),
                     event_name	varchar(50),
                     location varchar(50),
                     device	varchar(50),
                     user_type varchar(50)
                     );
                     
show columns from events;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/events.csv' 
INTO TABLE events 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
ignore 1 rows;

alter table events add occured_at2 datetime;
update events set occured_at2 = str_to_date(occurred_at, '%d-%m-%Y %H:%i');
alter table events drop column occurred_at;
alter table events rename column occured_at2 to occured_at;
select * from events;

/*-------------------------------------------------*/
/*create email_events table and enter the data*/
create table email_events(
							user_id	int null,
                            occurred_at varchar(50) null,
                            action varchar(50) null,
                            user_type int null
                            );
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/email_events.csv'
INTO TABLE email_events 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
ignore 1 rows;
alter table email_events add occured_at2 datetime;
update email_events set occured_at2 = str_to_date(occurred_at, '%d-%m-%Y %H:%i');
alter table email_events drop column occurred_at;
alter table email_events rename column occured_at2 to occured_at;

select * from email_events;
/*Weekly User Engagement:
•	Objective: Measure the activeness of users on a weekly basis
*/
SELECT CONCAT(YEAR(occured_at), ' Week -', WEEK(occured_at)) as week, COUNT(*) as num_events
FROM events
GROUP BY week
ORDER BY week DESC, num_events DESC;

/*User Growth Analysis:
•	Objective: Analyze the growth of users over time for a product.
*/
SELECT DATE_FORMAT(created_at, '%Y-%u') as week, COUNT(*) as new_users
FROM users
GROUP BY week
ORDER BY week;

SELECT 
    curr.week, 
    curr.new_users, 
    curr.new_users + IFNULL(SUM(prev.new_users), 0) as cumulative_users
FROM 
    (SELECT DATE_FORMAT(created_at, '%Y-%u') as week, COUNT(*) as new_users
     FROM users
     GROUP BY week) curr
LEFT JOIN 
    (SELECT DATE_FORMAT(created_at, '%Y-%u') as week, COUNT(*) as new_users
     FROM users
     GROUP BY week) prev
ON curr.week > prev.week
GROUP BY curr.week, curr.new_users
ORDER BY curr.week;

/*
Weekly Retention Analysis:
Objective: Analyze the retention of users on a weekly basis after signing up for a product.
*/
SELECT 
    DATE_FORMAT(u.created_at, '%Y-%u') as sign_up_week,
    COUNT(DISTINCT u.user_id) as sign_ups,
    COUNT(DISTINCT CASE WHEN e.occured_at BETWEEN u.created_at AND DATE_ADD(u.created_at, INTERVAL 7 DAY) THEN u.user_id END) as week_1,
    COUNT(DISTINCT CASE WHEN e.occured_at BETWEEN DATE_ADD(u.created_at, INTERVAL 7 DAY) AND DATE_ADD(u.created_at, INTERVAL 14 DAY) THEN u.user_id END) as week_2,
    COUNT(DISTINCT CASE WHEN e.occured_at BETWEEN DATE_ADD(u.created_at, INTERVAL 14 DAY) AND DATE_ADD(u.created_at, INTERVAL 21 DAY) THEN u.user_id END) as week_3
FROM 
    users u
LEFT JOIN 
    events e ON u.user_id = e.user_id
GROUP BY 
    sign_up_week
ORDER BY 
    sign_up_week;

/*Weekly Engagement Per Device:
Objective: Measure the activeness of users on a weekly basis per device.*/
SELECT DATE_FORMAT(occured_at, '%Y-%u') as week, device, COUNT(*) as num_events
FROM events
GROUP BY week, device
ORDER BY week DESC, num_events DESC;

/*Email Engagement Analysis:
Objective: Analyze how users are engaging with the email service.*/
SELECT user_id,
       COUNT(CASE WHEN action = 'sent_weekly_digest' THEN 1 END) as sent_weekly_digest,
       COUNT(CASE WHEN action = 'email_open' THEN 1 END) as email_open
FROM email_events
GROUP BY user_id;
