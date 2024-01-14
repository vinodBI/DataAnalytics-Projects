/*Created new DB(Schema) "operation_analytics" */
/* import job_data.csv as table*/

SELECT * FROM operration_analytics.job_data;

/* ds column has text data create datestamp column using ds column and convert it into date format*/

alter table operration_analytics.job_data
add datestamp DATE;

UPDATE operration_analytics.job_data SET
datestamp = str_to_date(ds, '%m/%d/%Y');

/* drop ds column*/
ALTER TABLE operration_analytics.job_data
DROP column ds;

/*A. Calculate the number of jobs reviewed per hour for each day in November 2020. */
	/*test query

	select datestamp, count(job_id) as jobs, sum(time_spent/60.0) as jobs_reviewed_per_hour
	From operration_analytics.job_data
	Group by datestamp; */

SELECT datestamp, COUNT(job_id) / SUM(time_spent / 60.0) as jobs_per_hour
FROM operration_analytics.job_data
GROUP BY datestamp;

/*B. Throughput Analysis:
Objective: Calculate the 7-day rolling average of throughput (number of events per second). */
SELECT datestamp, 
       AVG(time_spent) OVER (ORDER BY datestamp ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as rolling_avg_throughput
FROM operration_analytics.job_data
WHERE MONTH(datestamp) = 11 AND YEAR(datestamp) = 2020;

/*C. Language Share Analysis:
Objective: Calculate the percentage share of each language in the last 30 days.*/
SELECT language, 
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM job_data WHERE datestamp >= (SELECT MAX(datestamp) FROM job_data) - INTERVAL 30 DAY) as percentage
FROM job_data
WHERE datestamp >= (SELECT MAX(datestamp) FROM job_data) - INTERVAL 30 DAY
GROUP BY language
Order by percentage desc;



/* D. Duplicate Rows Detection:
Objective: Identify duplicate rows in the data.*/
SELECT job_id, actor_id, event, language, time_spent, org, datestamp, COUNT(*)
FROM job_data
GROUP BY job_id, actor_id, event, language, time_spent, org, datestamp
HAVING COUNT(*) > 1;










