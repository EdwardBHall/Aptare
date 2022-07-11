--Author: ehall@silexdata.com
--Last Modified: 06/07/2022
WITH t1 AS (
SELECT
jd.job_id,                         -- Primary key in this view. Will this speed it up?
s.hostname master_server,          -- Master Server apt_v_server
jd.policy_name,
jd.client_id,                      
jd.summary_status                          
FROM apt_v_server s, apt_v_nbu_job_detail jd, apt_v_nbu_schedule sc   -- Job Detail contains Policy Name
WHERE jd.finish_date BETWEEN ${startDate} AND ${endDate}
AND jd.server_id IN (${hosts})                         -- Variable where master server can be set
AND jd.server_id = s.server_id                         -- Key between tables
AND jd.schedule_id = sc.schedule_id                    -- Key between tables
AND jd.job_type NOT IN(103, 114)    -- Exclude Catalog Backup and Tape Drive Cleaning
)
SELECT
t1.master_server,
t1.policy_name,
COUNT(t1.client_id),
COUNT(t1.policy_name),
SUM(CASE WHEN t1.summary_status = 2 THEN 1 ELSE 0 END ) Failed_Jobs   -- Show case statement usage
FROM t1
GROUP BY t1.master_server, t1.policy_name
ORDER BY t1.master_server
