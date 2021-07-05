-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits

DECLARE
    i_BODY_FIELDS CLOB;
BEGIN 

-- List of ATM Withdrawals Report
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"SEQ","csvTxtLength":"7","pdfLength":"7","fieldType":"String","defaultValue":"SEQ","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TRACE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TRAN","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"ACCT","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"ACCT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BANK","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"CARD","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"ACCOUNT","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"TRANS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"RESPONSE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"RESPONSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"REMARKS","csvTxtLength":"21","pdfLength":"21","fieldType":"String","defaultValue":"REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"21","pdfLength":"21","fieldType":"String","firstField":false,"bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NO","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"NO","csvTxtLength":"7","pdfLength":"7","fieldType":"String","defaultValue":"NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"MNEM","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NUMBER","csvTxtLength":"21","pdfLength":"21","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"defaultValue":"AMOUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"DATE","csvTxtLength":"12","pdfLength":"12","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":26,"sectionName":"26","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"27","fieldName":"TRAN MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"FROM ACCOUNT NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"32","fieldName":"AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":34,"sectionName":"34","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_FIELDS = i_BODY_FIELDS
	where RED_NAME = 'List of ATM Withdrawals Report';
	
END;
/