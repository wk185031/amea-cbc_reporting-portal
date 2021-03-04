DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- ATM Downtime Report (Branch and Coast)

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Region","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Region","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"Terminal ID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Terminal ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"Terminal Name","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Terminal Name","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"Date Down","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Date Down","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"Time Down","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Time Down","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"Date Up","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Date Up","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"Time Up","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Time Up","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"Total Down Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Total Down Time","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"Cause","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cause","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"Specific Problem","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Specific Problem","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TERMINAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"DATE DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"dd/MM/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","fieldName":"TIME DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"DATE UP","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"dd/MM/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":17,"sectionName":"17","fieldName":"TIME UP","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":18,"sectionName":"18","fieldName":"TOTAL DOWN TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":19,"sectionName":"19","fieldName":"CAUSE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":20,"sectionName":"20","fieldName":"SPECIFIC PROBLEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]
');

i_TRAILER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SUB TOTAL","csvTxtLength":"","fieldType":"String","delimiter":",","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');


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
WHERE 
    {Txn_Date}
	AND AST.AST_ACO_ID NOT IN (1722,1723)
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
      ATD.ATD_START_TIMESTAMP ASC
');
	  
UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY, RED_BODY_FIELDS = i_BODY_FIELD WHERE RED_NAME = 'ATM Downtime Report (Branch and Coast)';


i_TRAILER_QUERY := TO_CLOB('
SELECT TO_CHAR(EXTRACT(DAY    FROM t_interval), ''fm99999'') || '' day/s '' ||
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
      ATD.ATD_DOWN_REASON "SPECIFIC PROBLEM",
	  ATD.ATD_START_TIMESTAMP "START TIME",
      ATD.ATD_END_TIMESTAMP "END TIME"
from 
    ATM_STATIONS AST
    JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD.ATD_AST_ID
WHERE 
    {Txn_Date}
	AND AST.AST_ACO_ID NOT IN (1722,1723)
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
      ATD.ATD_DOWN_REASON "SPECIFIC PROBLEM",
	  ATD.ATD_START_TIMESTAMP "START TIME",
      ATD.ATD_END_TIMESTAMP "END TIME"
from 
    ATM_STATIONS AST
    JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD.ATD_AST_ID
WHERE 
    {Txn_Date}
	AND AST.AST_ACO_ID NOT IN (1722,1723)
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
END  
	');

UPDATE REPORT_DEFINITION set RED_TRAILER_FIELDS = i_TRAILER_FIELD, RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY WHERE RED_NAME = 'ATM Downtime Report (Branch and Coast)';

END;
/