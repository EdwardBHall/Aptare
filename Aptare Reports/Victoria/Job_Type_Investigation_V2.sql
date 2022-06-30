--Author: ehall@silexdata.com
--Last Modified: 06/01/2022
WITH t1 AS (
SELECT
jd.job_id,                         -- Included only as primary speed key
jd.job_type AS type,                       -- Only included to speed query not needed to use host scope
jd.job_type_name AS name,                  -- Diff, Full etc
jd.start_date,                     -- Start Date used only in scope selection not displayed
jd.finish_date                     -- End Date used only in scope selection not displayed
FROM apt_v_server s, apt_v_nbu_job_detail jd
WHERE jd.finish_date BETWEEN ${startDate} AND ${endDate}
AND jd.server_id = s.server_id
AND s.server_id IN (${hosts})      -- Variable where the master server can be set
),
t2 AS (
SELECT
type,
name
FROM t1
GROUP BY type, name
)
SELECT * FROM t2
ORDER BY type
