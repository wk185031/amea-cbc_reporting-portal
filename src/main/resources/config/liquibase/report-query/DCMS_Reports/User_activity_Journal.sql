-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS
-- Rel-20210827			27-AUG-2021		KW		Revise query

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'User Activity Journal Report';
	i_REPORT_PROCESSING_CLASS VARCHAR2(100) := 'my.com.mandrill.base.reporting.dcmsAppRejPendCard.UserActivityJournalReport';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"USER ACTIVITY JOURNAL","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":2,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":3,"sectionName":"3","fieldName":"USER ID","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"USER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"FUNCTION","csvTxtLength":"35","pdfLength":"35","fieldType":"String","defaultValue":"FUNCTION","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"21","fieldName":"DESCRIPTION","csvTxtLength":"200","pdfLength":"200","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"16","fieldName":"CARD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null,"firstField":true},{"sequence":7,"sectionName":"15","fieldName":"CREATED_DATE","csvTxtLength":"20","pdfLength":"20","fieldType":"Date Time","delimiter":";","fieldFormat":"dd/MM/yyyy HH:mm","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"17","fieldName":"CREATED_BY","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"18","fieldName":"FUNCTION_NAME","csvTxtLength":"35","pdfLength":"35","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"20","fieldName":"DESCRIPTION","csvTxtLength":"200","pdfLength":"200","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]');
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"USER ACTIVITY JOURNAL","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":2,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":3,"sectionName":"3","fieldName":"USER ID","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"USER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"FUNCTION","csvTxtLength":"35","pdfLength":"35","fieldType":"String","defaultValue":"FUNCTION","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"21","fieldName":"DESCRIPTION","csvTxtLength":"200","pdfLength":"200","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"16","fieldName":"CARD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null,"firstField":true},{"sequence":7,"sectionName":"15","fieldName":"CREATED_DATE","csvTxtLength":"20","pdfLength":"20","fieldType":"Date Time","delimiter":";","fieldFormat":"dd/MM/yyyy HH:mm","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"17","fieldName":"CREATED_BY","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"18","fieldName":"FUNCTION_NAME","csvTxtLength":"35","pdfLength":"35","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"20","fieldName":"DESCRIPTION","csvTxtLength":"200","pdfLength":"200","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT 
  COALESCE(CARD_NUMBER_ENC, CUSTOMER_CIF_NUMBER) as CARD_NUMBER_ENC,
  CREATED_DATE,
  CREATED_BY,
  FUNCTION as "FUNCTION_NAME",
  DESCRIPTION,
  '''' as "CUSTOMER_NAME",
  CARD_KEY_ROTATION_NUMBER as "ROTATION_NUMBER",
  CASE WHEN INSTITUTION_ID = 1 THEN ''CBC'' ELSE ''CBS'' END as "INSTITUTION_ID"
FROM 
  DCMS_USER_ACTIVITY
WHERE 
   INSTITUTION_ID = {Iss_Name}
   AND CREATED_DATE >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') and CREATED_DATE < To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
ORDER BY CREATED_DATE	
	');	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_PROCESSING_CLASS = i_REPORT_PROCESSING_CLASS,
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_PROCESSING_CLASS = i_REPORT_PROCESSING_CLASS,
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	
END;
/