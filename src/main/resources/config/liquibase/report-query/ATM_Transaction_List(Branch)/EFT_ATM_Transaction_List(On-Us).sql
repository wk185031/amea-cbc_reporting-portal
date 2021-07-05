-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits

DECLARE
    i_BODY_FIELDS CLOB;
BEGIN 

-- EFT - ATM Transaction List (On-Us)
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SEQ","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"SEQ","firstField":true,"bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"TRACE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"ATM CARD NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"ATM CARD NUMBER","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"DATE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"TRAN","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"ACCOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"TYPE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"AMOUNT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"AMOUNT","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"VOID","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"VOID","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"COMMENT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMMENT","bodyHeader":true,"eol":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NUMBER","firstField":true,"bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"MNEM","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","firstField":true,"defaultValue":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","padFieldLength":"6"},{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","defaultValue":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","padFieldLength":"6"},{"sequence":18,"sectionName":"18","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros","padFieldLength":"19"},{"sequence":19,"sectionName":"19","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0,"padFieldType":null,"padFieldValue":null},{"sequence":20,"sectionName":"20","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":21,"sectionName":"21","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":22,"sectionName":"22","fieldName":"FROM ACCOUNT NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros","padFieldLength":"16","tagValue":null},{"sequence":23,"sectionName":"23","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":24,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":25,"sectionName":"25","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"3","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0}]');
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_FIELDS = i_BODY_FIELDS
	where RED_NAME = 'EFT - ATM Transaction List (On-Us)';
	
END;
/