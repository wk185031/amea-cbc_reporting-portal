-- Tracking				Date			Name	Description
-- Revise report		19-JULY-2021	WY		Revise report header data

DECLARE
	i_HEADER_FIELDS CLOB;
	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
   
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"fieldName":"Out Of Cash Report","eol":true,"defaultValue":"Out Of Cash Report"},{"sequence":2,"sectionName":"2","fieldName":"Start Date","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Start Date","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"From Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"End Date","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"End Date","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Report To Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Region","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Region","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"Terminal ID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Terminal ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"Terminal Name","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Terminal Name","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"Cass 1 Position","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Cass 1 Position","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"Cass 2 Position","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Cass 2 Position","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"Cass 3 Position","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Cass 3 Position","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"Date Down","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Date Down","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"Time Down","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Time Down","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"Date Up","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Date Up","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"Time Up","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Time Up","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"Total Down Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"Total Down Time","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"TERMINAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","fieldName":"CASS 1 POSITION","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"CASS 2 POSITION","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":17,"sectionName":"17","fieldName":"CASS 3 POSITION","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":18,"sectionName":"18","fieldName":"DATE DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":"MM/dd/yyyy"},{"sequence":19,"sectionName":"19","fieldName":"TIME DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":"HH:mm:ss a"},{"sequence":20,"sectionName":"20","fieldName":"DATE UP","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":"MM/dd/yyyy"},{"sequence":21,"sectionName":"21","fieldName":"TIME UP","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":"HH:mm:ss a"},{"sequence":22,"sectionName":"22","fieldName":"TOTAL DOWN TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	
	i_BODY_QUERY := TO_CLOB('SELECT
      AST.AST_ARE_NAME "REGION",
      AST.AST_TERMINAL_ID "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
	    "CASS 1 POSITION",
	    "CASS 2 POSITION",
	    "CASS 3 POSITION",
      CASE WHEN "CASS 1 DATE DOWN" IS NOT NULL THEN "CASS 1 DATE DOWN"
           WHEN "CASS 2 DATE DOWN" IS NOT NULL THEN "CASS 2 DATE DOWN"
           WHEN "CASS 3 DATE DOWN" IS NOT NULL THEN "CASS 3 DATE DOWN"
      END AS "DATE DOWN",
      CASE WHEN "CASS 1 TIME DOWN" IS NOT NULL THEN "CASS 1 TIME DOWN"
           WHEN "CASS 2 TIME DOWN" IS NOT NULL THEN "CASS 2 TIME DOWN"
           WHEN "CASS 3 TIME DOWN" IS NOT NULL THEN "CASS 3 TIME DOWN"
      END AS "TIME DOWN",
      CASE WHEN "CASS 1 DATE UP" IS NOT NULL THEN "CASS 1 DATE UP"
           WHEN "CASS 2 DATE UP" IS NOT NULL THEN "CASS 2 DATE UP"
           WHEN "CASS 3 DATE UP" IS NOT NULL THEN "CASS 3 DATE UP"
      END AS "DATE UP",
      CASE WHEN "CASS 1 TIME UP" IS NOT NULL THEN "CASS 1 TIME UP"
           WHEN "CASS 2 TIME UP" IS NOT NULL THEN "CASS 2 TIME UP"
           WHEN "CASS 3 TIME UP" IS NOT NULL THEN "CASS 3 TIME UP"
      END AS "TIME UP",
      '''' "TOTAL DOWN TIME"
FROM
      ATM_STATIONS AST
	  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
JOIN
(SELECT
      ADS_AST_ID,
      ADS_LAST_UPDATE_TS,
      (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) "CASS 1 POSITION",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) < 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 1 DATE DOWN",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) < 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 1 TIME DOWN",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) > 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 1 DATE UP",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) > 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 1 TIME UP"
      FROM ATM_DEVICE_STATUS
      WHERE
      ADS_DEVICE_ID = ''Cassette 1''
) ADS ON ADS.ADS_AST_ID = AST.AST_ID
JOIN
(SELECT
      ADS_AST_ID,
      ADS_LAST_UPDATE_TS,
      (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) "CASS 2 POSITION",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) < 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 2 DATE DOWN",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) < 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 2 TIME DOWN",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) > 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 2 DATE UP",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) > 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 2 TIME UP"
      FROM ATM_DEVICE_STATUS
      WHERE
      ADS_DEVICE_ID = ''Cassette 2''
) ADS ON ADS.ADS_AST_ID = AST.AST_ID
JOIN
(SELECT
      ADS_AST_ID,
      ADS_LAST_UPDATE_TS,
      (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) "CASS 3 POSITION",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) < 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 3 DATE DOWN",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) < 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 3 TIME DOWN",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) > 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 3 DATE UP",
      CASE WHEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) > 0 THEN ADS_LAST_UPDATE_TS END AS "CASS 3 TIME UP"
      FROM ATM_DEVICE_STATUS
      WHERE
      ADS_DEVICE_ID = ''Cassette 3''
) ADS ON ADS.ADS_AST_ID = AST.AST_ID
WHERE
      {Txn_Date}
	  AND DEO.DEO_NAME = {V_Deo_Name}
ORDER BY
      AST.AST_ARE_NAME ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC');
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY
	where RED_NAME = 'Out of Cash';
	
END;
/