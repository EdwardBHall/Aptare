---Author:  Karl McHale
---Date: June, 2022
---Modified: June 2022
---Title/Purpose: Backup Totals Report
---
WITH 
NBU1 AS (                                              --- NBU Jobs only 
SELECT
n.master_host_name server_name,
n.server_id,
n.job_id,
n.client_id, --validate field name  add this PK
n.client_host_name client_name,
n.job_type_name,
n.nbr_of_files,
n.vendor_status,
n.summary_status,
n.start_date,
n.finish_date
FROM apt_v_nbu_job_detail n
WHERE n.finish_date BETWEEN ${startDate} AND ${endDate} --- This could be set to on week prior instead
AND n.server_id IN (${hosts})                         --- Variable where master server can be set
AND n.job_type IN(101, 102, 103, 107, 112, 130, 138)  --- FB, DIFF, Cat, Dup, App, Snap, Auto
AND n.vendor_status != 150                            --- Jobs not canceled by an administrator
AND n.IS_ACTIVE = 'N'                                 --- Only count completed Jobs
),
FNBU as (                                             --- All NBU jobs picked up
SELECT server_name, server_id, COUNT(job_id) jobs,
COUNT(DISTINCT client_name) clients,
SUM(nbr_of_files) nbr_of_files,
SUM(DECODE(summary_status,'0','1')) successful_jobs,
SUM(DECODE(summary_status,'1','1')) partial_jobs,
SUM(DECODE(summary_status,'2','1')) failed_jobs
FROM NBU1
GROUP BY server_name, server_id --client_name, job_type_name
),
NBU3 AS( --- still missing pct failed
SELECT
FB2.SERVER_NAME,  --should this be 
FB2.JOBS,
FB2.CLIENTS,
FB2.NBR_OF_FILES,
FB2.SUCCESSFUL_JOBS,
FB2.PARTIAL_JOBS,
FB2.FAILED_JOBS,
ROUND(FB2.SUCCESSFUL_JOBS/FB2.JOBS * 100,2)  SUCC_PCT,
ROUND(FB2.PARTIAL_JOBS/FB2.JOBS * 100,2) PART_PCT,
ROUND(FB2.FAILED_JOBS/FB2.JOBS * 100, 2) Fail_PCT
FROM FNBU FB2
)
SELECT * FROM NBU3