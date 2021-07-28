-- Tracking				Date			Name	Description
-- Revise report		16-JULY-2021	WY		Revise report header data

DECLARE
	i_HEADER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
   
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"ATM CENTER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ATM CENTER","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"ATM HOST DOWNTIME REPORT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ATM HOST DOWNTIME REPORT","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"FROM  :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM  :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"From Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"TO    :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO    :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"Report To Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_QUERY := TO_CLOB('
	SELECT
      CASE WHEN ASH.ASH_COMM_STATUS = ''Down'' THEN ASH.ASH_TIMESTAMP END AS "DATE DOWN",
      CASE WHEN ASH.ASH_COMM_STATUS = ''Up'' THEN ASH.ASH_TIMESTAMP END AS "DATE UP",
      CASE WHEN ASH.ASH_COMM_STATUS = ''Down'' THEN ASH.ASH_TIMESTAMP END AS "TIME DOWN",
      CASE WHEN ASH.ASH_COMM_STATUS = ''Up'' THEN ASH.ASH_TIMESTAMP END AS "TIME UP",
      '''' AS "TOTAL DOWN TIME",
      ASH.ASH_HEALTH "HEALTH",
      ASH.ASH_SERVICE_STATE_REASON "SPECIFIC PROBLEM"
FROM
      ATM_STATIONS AST
      JOIN ATM_STATUS_HISTORY ASH ON AST.AST_ID = ASH.ASH_AST_ID
	  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
WHERE
      ASH.ASH_COMM_STATUS IN (''Up'', ''Down'')
      AND ASH.ASH_SERVICE_STATE_REASON IN (''Comms Event'', ''In supervisor mode'', ''Power fail'',
      ''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'', ''Cash dispenser faulty'',
      ''Cash availability status change'', ''Operator request'')
      AND {Txn_Date}
	  AND DEO.DEO_NAME = {V_Deo_Name}
ORDER BY
      ASH.ASH_TIMESTAMP ASC');
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY
	where RED_NAME = 'ATM Host Downtime';
	
END;
/