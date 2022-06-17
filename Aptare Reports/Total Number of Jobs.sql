---Author: Edward Hall
---Date: June, 2022
---Modified: June 2022
---Title/Purpose: Backup Totals Report
---
WITH
NBU1 AS ( --- NBU Jobs only
SELECT
n.master_host_name server_name,
n.server_id,
n.job_id,
n.client_host_name client_name,
n.job_type_name,
n.nbr_of_files,
n.vendor_state,
n.vendor_status,
n.summary_status,
n.start_date,
n.finish_date
FROM apt_v_nbu_job n
WHERE n.finish_date BETWEEN ${startDate} AND ${endDate} --- This could be set to on week prior instead
AND n.server_id IN (${hosts}) --- Variable where master server can be set
AND n.job_type IN(101, 102, 103, 107, 112, 130, 138) --- FB, DIFF, Cat, Dup, App, Snap, Auto
AND n.vendor_status != 150 --- Jobs not canceled by an administrator
AND n.IS_ACTIVE = 'N' --- Only count completed Jobs
),



/* COUNTS */
FNBU as ( --- All NBU jobs picked up
SELECT server_name, server_id, client_name, job_type_name,
COUNT(job_id) jobs,
COUNT(DISTINCT client_name) clients,
SUM(nbr_of_files) nbr_of_files,
NVL(SUM(DECODE(summary_status,'0','1')),0) successful_jobs,
NVL(SUM(DECODE(summary_status,'1','1')),0) partial_jobs,
NVL(SUM(DECODE(summary_status,'2','1')),0) failed_jobs
FROM NBU1
GROUP BY server_name, server_id, client_name, job_type_name
),
/* FINAL METRICS :testing final status*/
FINAL1 AS (
SELECT FNBU.*,
ROUND((successful_jobs/jobs)*100, 2) success_pct,
ROUND((failed_jobs/jobs)*100, 2) failed_pct
FROM FNBU
),
FINAL2 AS (
SELECT
server_name,
clients,
jobs,
nbr_of_files,
successful_jobs,
partial_jobs,
failed_jobs,
success_pct,
failed_pct
FROM FINAL1
)



SELECT * FROM FINAL2