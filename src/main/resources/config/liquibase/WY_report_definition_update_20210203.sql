DECLARE
	i_BODY_FIELD CLOB;
	i_BODY_QUERY CLOB;
	
BEGIN 

-- ATM Availability
   	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REGION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"TERMINAL NO.","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERMINAL NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"LOCATION","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"PERCENT AVAILABLE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"PERCENT AVAILABLE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"% UNAVAILABLE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"% UNAVAILABLE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"STANDARD","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"STANDARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true},{"sequence":8,"sectionName":"8","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TERMINAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"AVAILABLE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"UNAVAILABLE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"STANDARD","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true}]');
	
	
	i_BODY_QUERY := TO_CLOB('
	SELECT
     AST.AST_ARE_NAME "REGION",
     ABR.ABR_CODE "BRANCH CODE",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     AST.AST_ID "STATION ID",
     round(SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100), 2) "UNAVAILABLE",
     NVL(round(100 - (SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100)), 2) , 100) "AVAILABLE",    
     CASE WHEN SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100) < 5 THEN ''1'' ELSE ''0'' END "STANDARD"
FROM
      ATM_STATIONS AST
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD_AST_ID AND {Txn_Date} 
GROUP BY
      AST.AST_ARE_NAME,
      ABR.ABR_CODE,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID,
      AST.AST_ID
ORDER BY
      AST.AST_ARE_NAME  ASC,
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_FIELDS = i_BODY_FIELD , RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'ATM Availability';
	
END;
/