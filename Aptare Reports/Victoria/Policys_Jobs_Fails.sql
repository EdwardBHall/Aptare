--Author: ehall@silexdata.com
--Last Modified: 07/11/2022
WITH t1 AS (
SELECT
jd.job_id,                         -- Primary key in this view. Used to count # of APTARE Jobs
s.hostname master_server,          -- Master Server apt_v_server
NVL(jd.policy_name,'NO POLICY') policy_name,           -- Display no policy if not in policy
jd.client_id,                     
jd.summary_status                          
FROM apt_v_server s, apt_v_nbu_job_detail jd           -- Job Detail contains Policy Name
WHERE jd.finish_date BETWEEN ${startDate} AND ${endDate}
AND jd.server_id IN (${hosts})                         -- Variable where master server can be set
AND jd.server_id = s.server_id                         -- Key between tables
AND jd.job_type NOT IN(103, 114)                       -- Exclude Catalog & Tape Cleaning
)
SELECT
t1.master_server,                   -- Name of Master Server
t1.policy_name,                     -- Name of Policy
COUNT(t1.client_id),                -- # of Clients in Policy
COUNT(t1.job_id),                   -- # of Jobs in Policy
SUM(CASE WHEN t1.summary_status = 2 THEN 1 ELSE 0 END ) Failed_Jobs   -- # of Failed Jobs
FROM t1
GROUP BY t1.master_server, t1.policy_name
ORDER BY 1, 2
