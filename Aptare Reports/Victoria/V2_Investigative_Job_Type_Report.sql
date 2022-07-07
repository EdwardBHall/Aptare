--Author: ehall@silexdata.com
--Last Modified: 06/07/2022
WITH t1 AS (
SELECT
COUNT(*),                         -- Included only to increase speed
jd.job_type,                      
jd.job_type_name                               
FROM apt_v_nbu_job_detail jd
WHERE jd.finish_date BETWEEN ${startDate} AND ${endDate}
AND jd.job_type NOT IN (121)      -- Remove NetBackup Code 121 Replication Duplicates
AND jd.server_id IN (${hosts})
GROUP BY 
jd.job_type,
jd.job_type_name
)
SELECT * FROM t1
ORDER BY 2, 3
