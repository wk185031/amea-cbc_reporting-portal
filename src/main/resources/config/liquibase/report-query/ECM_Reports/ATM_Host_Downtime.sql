-- Tracking				Date			Name	Description
-- Revise report		16-JULY-2021	WY		Revise report header data
-- JIRA 901				06-SEPT-2021	WY		Remove downtime for terminals 

DECLARE
	i_HEADER_FIELDS CLOB;
	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
   
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"ATM CENTER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ATM CENTER","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"ATM HOST DOWNTIME REPORT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ATM HOST DOWNTIME REPORT","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"FROM  :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM  :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"From Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"TO    :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO    :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"Report To Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE DOWN","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"DATE UP","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE UP","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"DOWN TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DOWN TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"UP TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"UP TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"TOTAL DOWNTIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DOWNTIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"HEALTH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"HEALTH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"SPECIFIC PROBLEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SPECIFIC PROBLEM","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"DATE DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"DATE UP","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TIME DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss a ","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"TIME UP","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss a ","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"TOTAL DOWN TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"HEALTH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"SPECIFIC PROBLEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	
	i_BODY_QUERY := TO_CLOB('
	SELECT
      "DATE DOWN","TIME DOWN",
      (SELECT ASH_BUSINESS_DAY FROM ATM_STATUS_HISTORY WHERE ASH_SEQ_NMBR > "DOWNTIME_SEQ_NO" AND ASH_AST_ID = "DOWNTIME_ID" 
	  AND ASH_COMM_STATUS IN (''Up'') order by ASH_TIMESTAMP fetch first 1 row only) as "DATE UP", 
      (SELECT ASH_TIMESTAMP FROM ATM_STATUS_HISTORY WHERE ASH_SEQ_NMBR > "DOWNTIME_SEQ_NO" AND ASH_AST_ID = "DOWNTIME_ID" 
	  AND ASH_COMM_STATUS IN (''Up'') order by ASH_TIMESTAMP fetch first 1 row only) as "TIME UP", 
      '''' AS "TOTAL DOWN TIME",
      "HEALTH","SPECIFIC PROBLEM"
FROM
      (SELECT ASH.ASH_BUSINESS_DAY AS "DATE DOWN",
	  ASH.ASH_TIMESTAMP AS "TIME DOWN",
	  ASH_SEQ_NMBR AS "DOWNTIME_SEQ_NO" ,
	  ASH_AST_ID AS "DOWNTIME_ID",
	  ASH.ASH_HEALTH "HEALTH",
	  ASH.ASH_SERVICE_STATE_REASON "SPECIFIC PROBLEM"
	  FROM ATM_STATIONS AST
      JOIN ATM_STATUS_HISTORY ASH ON AST.AST_ID = ASH.ASH_AST_ID
	  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
WHERE
      ASH.ASH_COMM_STATUS IN (''Down'')
      AND ASH.ASH_SERVICE_STATE_REASON IN (''Comms Event'')
      AND {Txn_Date}
	  AND DEO.DEO_NAME = {V_Deo_Name}
)ORDER BY
      "TIME DOWN" ASC');
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY
	where RED_NAME = 'ATM Host Downtime';
	
END;
/