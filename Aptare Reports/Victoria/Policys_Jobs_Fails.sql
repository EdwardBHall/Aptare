--Author: ehall@silexdata.com
--Last Modified: 06/07/2022
WITH t1 AS (
SELECT 
jd.server_id, 
s.hostname master_server,          -- Master Server apt_v_server
jd.client_id,                      -- Only included to speed query UN-SELECTED IN FORMATTING
jd.client_host_name,               -- Client Server Name
s.host_type,                       -- Client Server Type VM or Guest, Host etc          -- 
jd.job_type_name,                  -- Diff, Full etc
jd.summary_status,
TO_CHAR(jd.start_date, 'MM/DD/YYYY, HH24:MI:SS') AS job_start_date,   -- Displayed Date
TO_CHAR(jd.finish_date,'MM/DD/YYYY, HH24:MI:SS') AS job_finish_date,  -- Displayed Date
--DECODE(jd.summary_status, 0,'Success', 1,'Partial',2,'Failed','No Status'), --Job_Status,                                    
NVL(jd.policy_name,'No Policy') policy,                     -- Display no policy if not in policy
NVL(sc.schedule_name,'No Schedule') schedule                -- Display no Schedule if not in Schedule
FROM apt_v_server s, apt_v_nbu_job_detail jd, apt_v_nbu_schedule sc   -- Job Detail contains Policy Name
WHERE jd.finish_date BETWEEN ${startDate} AND ${endDate}
AND jd.server_id IN (${hosts})                         -- Variable where master server can be set
AND jd.server_id = s.server_id                         -- Key between tables
AND jd.schedule_id = sc.schedule_id                    -- Key between tables
AND jd.job_type NOT IN(103, 114)    -- Exclude Catalog Backup and Tape Drive Cleaning
)
SELECT
t1.master_server,
t1.policy,
COUNT(t1.client_id),
COUNT(t1.policy),
SUM(CASE WHEN t1.summary_status = 2 THEN 1 ELSE 0 END ) Failed_Jobs
FROM t1
GROUP BY t1.master_server, t1.policy
ORDER BY t1.master_server
