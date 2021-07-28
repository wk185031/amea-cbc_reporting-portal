-- Tracking				Date			Name	Description
-- Revise report		16-JULY-2021	WY		Revise report header data

DECLARE
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
   
BEGIN 

	i_BODY_QUERY := TO_CLOB('
SELECT
	AST.AST_ARE_NAME "REGION",
    AST.AST_TERMINAL_ID "TERMINAL",
    AST.AST_ALO_LOCATION_ID "LOCATION",
    TRUNC(ATD_START_TIMESTAMP) "DATE DOWN",
    TO_CHAR(ATD_START_TIMESTAMP,''hh24:mi:ss'') "TIME DOWN", 
    TRUNC(ATD_END_TIMESTAMP) "DATE UP",
    TO_CHAR(ATD_END_TIMESTAMP,''hh24:mi:ss'') "TIME UP", 
    extract(day from (ATD_END_TIMESTAMP - ATD_START_TIMESTAMP)) || '' day/s '' 
      || LPAD(extract(hour from (ATD_END_TIMESTAMP - ATD_START_TIMESTAMP)),2,0) 
      || '':'' || LPAD(extract(minute from (ATD_END_TIMESTAMP - ATD_START_TIMESTAMP)),2,0)
      || '':'' || extract(second from (ATD_END_TIMESTAMP - ATD_START_TIMESTAMP)) "TOTAL DOWN TIME",
    CASE WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Comms Event'' THEN ''Host''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''In supervisor mode'' THEN ''Replenish''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Power fail'' THEN ''PF''
          WHEN TRIM(ATD.ATD_DOWN_REASON) IN (''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'') THEN ''HW''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Cash dispenser faulty'' THEN ''OOC''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Cash availability status change'' THEN ''Cash''
          WHEN TRIM(ATD.ATD_DOWN_REASON) IN (''Operator request'', ''Exiting supervisor mode'') THEN ''Other''
      END AS "CAUSE",
      ATD.ATD_DOWN_REASON "SPECIFIC PROBLEM"
from 
    ATM_STATIONS AST
    JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD.ATD_AST_ID
	JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
WHERE 
    {Txn_Date}
	AND DEO.DEO_NAME = {V_Deo_Name}
	AND {Terminal}
	AND {DOWN_REASON}
ORDER BY
      AST.AST_ARE_NAME ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC,
	  CASE WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Comms Event'' THEN ''Host''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''In supervisor mode'' THEN ''Replenish''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Power fail'' THEN ''PF''
          WHEN TRIM(ATD.ATD_DOWN_REASON) IN (''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'') THEN ''HW''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Cash dispenser faulty'' THEN ''OOC''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Cash availability status change'' THEN ''Cash''
          WHEN TRIM(ATD.ATD_DOWN_REASON) IN (''Operator request'', ''Exiting supervisor mode'') THEN ''Other''
      END ASC,
      ATD.ATD_START_TIMESTAMP ASC');
	  
	  i_TRAILER_QUERY := TO_CLOB('SELECT TO_CHAR(EXTRACT(DAY    FROM t_interval), ''fm99999'') || '' day/s '' ||
       TO_CHAR(EXTRACT(HOUR   FROM t_interval), ''fm99'')    || '':'' ||
       TO_CHAR(EXTRACT(MINUTE FROM t_interval), ''fm99'')    || '':'' ||
       TO_CHAR(EXTRACT(SECOND FROM t_interval), ''fm99.000'')
       "SUB TOTAL"
       FROM ( SELECT
(numtodsinterval(sum(extract(day from ("END TIME" - "START TIME"))), ''day'') +
numtodsinterval(sum(extract(hour from ("END TIME" - "START TIME"))), ''hour'') +
numtodsinterval(sum(extract(minute from ("END TIME" - "START TIME"))), ''minute'') +
numtodsinterval(sum(extract(second from ("END TIME" - "START TIME"))), ''second'')) as t_interval from (
SELECT
    CASE WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Comms Event'' THEN ''Host''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''In supervisor mode'' THEN ''Replenish''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Power fail'' THEN ''PF''
          WHEN TRIM(ATD.ATD_DOWN_REASON) IN (''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'') THEN ''HW''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Cash dispenser faulty'' THEN ''OOC''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Cash availability status change'' THEN ''Cash''
          WHEN TRIM(ATD.ATD_DOWN_REASON) IN (''Operator request'', ''Exiting supervisor mode'') THEN ''Other''
      END AS "CAUSE",
	ATD.ATD_START_TIMESTAMP "START TIME",
    ATD.ATD_END_TIMESTAMP "END TIME"
from 
    ATM_STATIONS AST
    JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD.ATD_AST_ID
	JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
WHERE 
    {Txn_Date}
	AND DEO.DEO_NAME = {V_Deo_Name}
	AND {Terminal}
	AND {DOWN_REASON}
ORDER BY
      AST.AST_ARE_NAME ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC,
	  ATD.ATD_DOWN_REASON ASC,
      ATD.ATD_START_TIMESTAMP ASC
)
GROUP BY
"CAUSE"
)
STARTING SELECT TO_CHAR(EXTRACT(DAY    FROM t_interval), ''fm99999'') || '' day/s '' ||
       TO_CHAR(EXTRACT(HOUR   FROM t_interval), ''fm99'')    || '':'' ||
       TO_CHAR(EXTRACT(MINUTE FROM t_interval), ''fm99'')    || '':'' ||
       TO_CHAR(EXTRACT(SECOND FROM t_interval), ''fm99.000'')
       "SUB TOTAL"
       FROM ( SELECT
(numtodsinterval(sum(extract(day from ("END TIME" - "START TIME"))), ''day'') +
numtodsinterval(sum(extract(hour from ("END TIME" - "START TIME"))), ''hour'') +
numtodsinterval(sum(extract(minute from ("END TIME" - "START TIME"))), ''minute'') +
numtodsinterval(sum(extract(second from ("END TIME" - "START TIME"))), ''second'')) as t_interval from (
SELECT
    AST.AST_TERMINAL_ID "TERMINAL",
	ATD.ATD_START_TIMESTAMP "START TIME",
    ATD.ATD_END_TIMESTAMP "END TIME"
from 
    ATM_STATIONS AST
    JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD.ATD_AST_ID
	JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
WHERE 
    {Txn_Date}
	AND DEO.DEO_NAME = {V_Deo_Name}
    AND {Terminal}
ORDER BY
      AST.AST_ARE_NAME ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC,
	  ATD.ATD_DOWN_REASON ASC,
      ATD.ATD_START_TIMESTAMP ASC
)
GROUP BY
"TERMINAL"
)
END');
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'ATM Downtime Report (Branch and Coast)';
	
END;
/