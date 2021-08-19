-- Tracking				Date			Name	Description
-- Revise Report	 	25-JULY-2021	WY		Revise report according to requirement
-- JIRA 841				10-AUG-2021		WY		Maintain uniform date

DECLARE
	
	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	
BEGIN 

	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Region","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Region","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Terminal ID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Terminal ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Terminal Name","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Terminal Name","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Date/Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Date/Time","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"Exception Message","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Exception Message","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"TERMINAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"DATE TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"Date Time","delimiter":";","fieldFormat":"MM/dd/yyyy HH:mm","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"EXCEPTION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT
      AST.AST_ARE_NAME "REGION",
      AST.AST_TERMINAL_ID "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      AJL.AJL_TIMESTAMP "DATE TIME",
      AJL.AJL_EJ_DATA "EXCEPTION"
	FROM
      ATM_STATIONS AST
      JOIN ATM_JOURNAL_LOG AJL ON AST.AST_ID = AJL.AJL_AST_ID
	  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
      AND {Txn_Date}
	WHERE (AJL.AJL_EJ_DATA LIKE ''%*U*%'' OR AJL.AJL_EJ_DATA LIKE ''%*S*%'' OR AJL.AJL_EJ_DATA LIKE ''%*2*%'')
	AND DEO.DEO_NAME = {V_Deo_Name}
	ORDER BY
      AST.AST_ARE_NAME ASC,
      AST.AST_TERMINAL_ID ASC,
      AJL.AJL_TIMESTAMP ASC');
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY
	where RED_NAME = 'ATM Daily Exception Messages';
	
END;
/