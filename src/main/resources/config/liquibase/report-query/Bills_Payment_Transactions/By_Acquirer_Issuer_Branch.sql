-- Tracking					Date			Name	Description
-- Report Revise			04-JUL-2021		KW		Revise report based on specification
-- 							14-JUL-2021		KW		Solve duplicate due to multiple biller with same code
-- Rel-20210730				28-JUL-2021		KW		Revise Acq and Iss condition after confirmation from CBC

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Daily Payment Transaction Report by Acquirer/Issuer Branch';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_BODY_QUERY_CBS CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 	

	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","defaultValue":"DAILY PAYMENT TRANSACTION REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"21","fieldName":"Space1","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"22","fieldName":"Space 2","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"23","fieldName":"Space 3","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"BY ACQUIRER/ISSUER BRANCH","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"24","fieldName":"Space 1","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"25","fieldName":"Space 2","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"26","fieldName":"Space 3","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"13","fieldName":"EFP003-01","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"EFP003-01","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"16","fieldName":"Space3","csvTxtLength":"37","pdfLength":"37","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"27","fieldName":"Space 1","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"28","fieldName":"Space 2","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"29","fieldName":"Space 3","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":26,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":27,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":28,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":29,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACCOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"BANK","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"BANK CODE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TERMINAL","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"TERMINAL NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"COMPANY","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"COMPANY CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"MN","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"MN","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"POSTING","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"POSTING DATE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TIME","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"SEQUENCE","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"SEQUENCE NUMBER","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"TRANSACTION","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"TRANSACTION AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"SUBSCRIBER","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"SUBSCRIBER ACCOUNT NUMBER","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"CODE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"CODE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"DATE","csvTxtLength":"32","pdfLength":"32","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"AMOUNT","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"ACCOUNT NUMBER","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"20","fieldName":"BANK CODE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"TERMINAL","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"BILLER MNEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"MN","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"SEQ NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"27","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"SUBSCRIBER ACCT NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"BILLERSUBN"},{"sequence":29,"sectionName":"29","fieldName":"IS ISSUING","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":" ","leftJustified":false,"padFieldLength":0,"decrypt":false}]');
 	i_TRAILER_FIELDS_CBC := null;
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","defaultValue":"DAILY PAYMENT TRANSACTION REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"21","fieldName":"Space1","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"22","fieldName":"Space 2","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"23","fieldName":"Space 3","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"BY ACQUIRER/ISSUER BRANCH","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"24","fieldName":"Space 1","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"25","fieldName":"Space 2","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"26","fieldName":"Space 3","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"13","fieldName":"EFP003-01","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"EFP003-01","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"16","fieldName":"Space3","csvTxtLength":"37","pdfLength":"37","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"27","fieldName":"Space 1","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"28","fieldName":"Space 2","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"29","fieldName":"Space 3","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":26,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":27,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":28,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":29,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACCOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"BANK","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"BANK CODE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TERMINAL","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"TERMINAL NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"COMPANY","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"COMPANY CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"MN","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"MN","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"POSTING","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"POSTING DATE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TIME","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"SEQUENCE","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"SEQUENCE NUMBER","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"TRANSACTION","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"TRANSACTION AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"SUBSCRIBER","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"SUBSCRIBER ACCOUNT NUMBER","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"CODE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"CODE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"DATE","csvTxtLength":"32","pdfLength":"32","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"AMOUNT","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"ACCOUNT NUMBER","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"20","fieldName":"BANK CODE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"TERMINAL","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"BILLER MNEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"MN","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"SEQ NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"27","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"SUBSCRIBER ACCT NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"BILLERSUBN"},{"sequence":29,"sectionName":"29","fieldName":"IS ISSUING","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":" ","leftJustified":false,"padFieldLength":0,"decrypt":false}]');
 	i_TRAILER_FIELDS_CBS := null;
 	    
  i_BODY_QUERY := TO_CLOB('
SELECT * FROM (
    SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      TXNC.TRL_ORIGIN_CHANNEL "CHANNEL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      LPAD(CBA.CBA_CODE, 4, 0) "BANK CODE",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL",
      CBL.CBL_MNEM "BILLER MNEM",
      CBL.CBL_SETTLEMENT_TYPE "MN",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_AMT_TXN  "AMOUNT",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXNC.TRL_CARD_BRANCH "CARD BRANCH",
      0 "IS ISSUING"
    FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      LEFT JOIN (select CBL_CODE, CBL_NAME, CBL_SETTLEMENT_TYPE, CBL_MNEM, ROW_NUMBER() OVER (partition by CBL_CODE order by cbl_id) "ROWCNT" from CBC_BILLER) CBL ON CBL.ROWCNT=1 
        AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID      
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID 
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''   
	  AND TXN.TRL_DEO_NAME = {V_Deo_Name}
	  AND (TXN.TRL_ISS_NAME IS NULL OR TXN.TRL_ISS_NAME={V_IE_Iss_Name})
      AND {Txn_Date}
    UNION
    SELECT
      BRC.BRC_CODE "BRANCH CODE",
      BRC.BRC_NAME "BRANCH NAME",
      TXNC.TRL_ORIGIN_CHANNEL "CHANNEL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      LPAD(CBA.CBA_CODE, 4, 0) "BANK CODE",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL",
      CBL.CBL_MNEM "BILLER MNEM",
      CBL.CBL_SETTLEMENT_TYPE "MN",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_AMT_TXN  "AMOUNT",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXNC.TRL_CARD_BRANCH "CARD BRANCH",
      1 "IS ISSUING"
    FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      LEFT JOIN (select CBL_CODE, CBL_NAME, CBL_SETTLEMENT_TYPE, CBL_MNEM, ROW_NUMBER() OVER (partition by CBL_CODE order by cbl_id) "ROWCNT" from CBC_BILLER) CBL ON CBL.ROWCNT=1 
        AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID       
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''   
      AND (TXN.TRL_ISS_NAME = {V_Iss_Name} AND (TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name}))
      AND  {Txn_Date}
    )
    ORDER BY
      "BRANCH CODE","IS ISSUING","DATE", "TIME"
  
  '); 
   i_BODY_QUERY_CBS := TO_CLOB('
SELECT * FROM (
    SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      TXNC.TRL_ORIGIN_CHANNEL "CHANNEL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      LPAD(CBA.CBA_CODE, 4, 0) "BANK CODE",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL",
      CBL.CBL_MNEM "BILLER MNEM",
      ''AP'' "MN",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_AMT_TXN  "AMOUNT",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXNC.TRL_CARD_BRANCH "CARD BRANCH",
      0 "IS ISSUING"
    FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      LEFT JOIN (select CBL_CODE, CBL_NAME, CBL_SETTLEMENT_TYPE, CBL_MNEM, ROW_NUMBER() OVER (partition by CBL_CODE order by cbl_id) "ROWCNT" from CBC_BILLER) CBL ON CBL.ROWCNT=1 
        AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID      
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID 
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''   
	  AND TXN.TRL_DEO_NAME = {V_Deo_Name}
	  AND (TXN.TRL_ISS_NAME IS NULL OR TXN.TRL_ISS_NAME={V_IE_Iss_Name})
      AND {Txn_Date}
    UNION
    SELECT
      BRC.BRC_CODE "BRANCH CODE",
      BRC.BRC_NAME "BRANCH NAME",
      TXNC.TRL_ORIGIN_CHANNEL "CHANNEL",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      LPAD(CBA.CBA_CODE, 4, 0) "BANK CODE",
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT "TERMINAL",
      CBL.CBL_MNEM "BILLER MNEM",
      ''AP'' "MN",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_AMT_TXN  "AMOUNT",
      TXN.TRL_CUSTOM_DATA "SUBSCRIBER ACCT NUMBER",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXNC.TRL_CARD_BRANCH "CARD BRANCH",
      1 "IS ISSUING"
    FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      LEFT JOIN (select CBL_CODE, CBL_NAME, CBL_SETTLEMENT_TYPE, CBL_MNEM, ROW_NUMBER() OVER (partition by CBL_CODE order by cbl_id) "ROWCNT" from CBC_BILLER) CBL ON CBL.ROWCNT=1 
        AND LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID       
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
    WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''   
      AND (TXN.TRL_ISS_NAME = {V_Iss_Name} AND (TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name}))
      AND  {Txn_Date}
    )
    ORDER BY
      "BRANCH CODE","IS ISSUING","DATE", "TIME"
  
  '); 
	UPDATE REPORT_DEFINITION SET 
	    RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY_CBS,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
END;
/