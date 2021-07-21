-- Tracking				Date			Name	Description
-- Revise report		16-JULY-2021	WY		Revise report header data

DECLARE
	i_HEADER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
   
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ATM CENTER STATISTICAL REPORT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ATM CENTER STATISTICAL REPORT","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0,"eol":true},{"sequence":5,"sectionName":"5","fieldName":"FROM :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"From Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"TO   :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO   :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Report To Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_QUERY := TO_CLOB('SELECT "CODE",SUM(SECONDS) AS SECOND, TRUNC((SUM(SECONDS)/3600),2) AS HOUR, "PERCENTAGE" FROM(
	SELECT 
	TRUNC(extract(day from ("UPTIME" - "DOWNTIME"))*24*60*60 +
	extract(hour from ("UPTIME" - "DOWNTIME"))*60*60 +
	extract(minute from ("UPTIME" - "DOWNTIME"))*60 +
	extract(second from ("UPTIME" - "DOWNTIME"))) AS SECONDS,
	"CODE" , 0.00 AS "PERCENTAGE"
	FROM(
	SELECT
		  CASE WHEN TRIM(ASH.ASH_SERVICE_STATE_REASON) = ''Comms Event'' THEN ''Host''
				   WHEN TRIM(ASH.ASH_SERVICE_STATE_REASON) = ''Power fail'' THEN ''PF''
				   WHEN TRIM(ASH.ASH_SERVICE_STATE_REASON) IN (''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'') THEN ''HW''
				   ELSE ''OTHER''
		  END AS "CODE",
		  ASH.ASH_COMM_STATUS "STATUS",
		  ASH.ASH_TIMESTAMP "DOWNTIME",
		  ash.ASH_SEQ_NMBR, ash.ASH_AST_ID,
		  (SELECT A.ASH_AST_ID FROM ATM_STATUS_HISTORY A WHERE A.ASH_AST_ID =  ash.ASH_AST_ID FETCH FIRST 1 ROW ONLY) AS ONEID,
		  (SELECT ASHUP.ASH_TIMESTAMP FROM ATM_STATUS_HISTORY ASHUP 
		  WHERE ASHUP.ASH_AST_ID =  ash.ASH_AST_ID 
		  AND ASHUP.ASH_SEQ_NMBR > ASH.ASH_SEQ_NMBR
		  AND ASHUP.ASH_TIMESTAMP >= ASH.ASH_TIMESTAMP
		  and ASHUP.ASH_COMM_STATUS = ''Up''
		  FETCH FIRST 1 ROW ONLY) "UPTIME"
	FROM
		  ATM_STATIONS AST
		  JOIN ATM_STATUS_HISTORY ASH ON AST.AST_ID = ASH.ASH_AST_ID
		  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
	WHERE
		  ASH.ASH_COMM_STATUS = ''Down''
		  AND ASH.ASH_SERVICE_STATE_REASON IN (''Comms Event'', ''In supervisor mode'', ''Power fail'',
		  ''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'', ''Cash dispenser faulty'',
		  ''Cash availability status change'', ''Operator request'')
		  AND {Txn_Date}
		  AND DEO.DEO_NAME = {V_Deo_Name}
	))
	GROUP BY "CODE","PERCENTAGE"');
	
	i_TRAILER_QUERY := TO_CLOB('SELECT TRUNC((SUM(SECONDS))) AS SECOND, TRUNC((SUM(SECONDS)/3600),2) AS HOUR FROM(
		SELECT 
		TRUNC(extract(day from ("UPTIME" - "DOWNTIME"))*24*60*60 +
		extract(hour from ("UPTIME" - "DOWNTIME"))*60*60 +
		extract(minute from ("UPTIME" - "DOWNTIME"))*60 +
		extract(second from ("UPTIME" - "DOWNTIME"))) AS SECONDS,
		"CODE", 0.00 AS "PERCENTAGE"
		FROM(
		SELECT
			  CASE WHEN TRIM(ASH.ASH_SERVICE_STATE_REASON) = ''Comms Event'' THEN ''Host''
					   WHEN TRIM(ASH.ASH_SERVICE_STATE_REASON) = ''Power fail'' THEN ''PF''
					   WHEN TRIM(ASH.ASH_SERVICE_STATE_REASON) IN (''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'') THEN ''HW''
					   ELSE ''OTHER''
			  END AS "CODE",
			  ASH.ASH_COMM_STATUS "STATUS",
			  ASH.ASH_TIMESTAMP "DOWNTIME",
			  ash.ASH_SEQ_NMBR, ash.ASH_AST_ID,
			  (SELECT A.ASH_AST_ID FROM ATM_STATUS_HISTORY A WHERE A.ASH_AST_ID =  ash.ASH_AST_ID FETCH FIRST 1 ROW ONLY) AS ONEID,
			  (SELECT ASHUP.ASH_TIMESTAMP FROM ATM_STATUS_HISTORY ASHUP 
			  WHERE ASHUP.ASH_AST_ID =  ash.ASH_AST_ID 
			  AND ASHUP.ASH_SEQ_NMBR > ASH.ASH_SEQ_NMBR
			  AND ASHUP.ASH_TIMESTAMP >= ASH.ASH_TIMESTAMP
			  and ASHUP.ASH_COMM_STATUS = ''Up''
			  FETCH FIRST 1 ROW ONLY) "UPTIME"
		FROM
			  ATM_STATIONS AST
			  JOIN ATM_STATUS_HISTORY ASH ON AST.AST_ID = ASH.ASH_AST_ID
			  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
		WHERE
			  ASH.ASH_COMM_STATUS = ''Down''
			  AND ASH.ASH_SERVICE_STATE_REASON IN (''Comms Event'', ''In supervisor mode'', ''Power fail'',
			  ''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'', ''Cash dispenser faulty'',
			  ''Cash availability status change'', ''Operator request'')
			  AND {Txn_Date}
			 AND DEO.DEO_NAME = {V_Deo_Name}
		))');
		
		UPDATE REPORT_DEFINITION set 
			RED_HEADER_FIELDS = i_HEADER_FIELDS,
			RED_BODY_QUERY = i_BODY_QUERY,
			RED_TRAILER_QUERY = i_TRAILER_QUERY
		where RED_NAME = 'Downtime Causes';
	
END;
/