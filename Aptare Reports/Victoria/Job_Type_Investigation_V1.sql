--Author: ehall@silexdata.com
--Last Modified: 06/01/2022
SELECT
--MAX(COUNT(*)) records,
jd.job_id                          -- Included only as primary speed key
MAX(jd.job_type) crap,
jd.job_type,                       -- Only included to speed query not needed to use host scope
jd.job_type_name,                  -- Diff, Full etc
jd.start_date,                     -- Start Date used only in scope selection not displayed
jd.finish_date                     -- End Date used only in scope selection not displayed
FROM apt_v_server s, apt_v_nbu_job_detail jd
WHERE jd.finish_date BETWEEN ${startDate} AND ${endDate}
AND s.server_id IN (${hosts})      -- Variable where master server can be set
GROUP BY jd.job_type
