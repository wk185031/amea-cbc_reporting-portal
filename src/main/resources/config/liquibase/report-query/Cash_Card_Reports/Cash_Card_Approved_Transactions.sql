-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- Rel-20210805			03-AUG-2021		KW		Revise report
-- CBCAXUPISSLOG-806		20-OCT-2021		NY		Fix oracle error invalid number
-- CBCAXUPISSLOG-1167   13-JUN-2022		LJL		Revise Branch Code/ Terminal / ATM_Branchs table

DECLARE
    i_REPORT_NAME VARCHAR2(100) := 'Cash Card Approved Transactions';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"CASH CARD APPROVED TRANSACTIONS REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"90","pdfLength":"90","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"CCDLY013","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"CCDLY013","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SEQ","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"SEQ","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TRACE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"CARD NUMBER","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"CARD NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ACQ","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"ACQ","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"DATE","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TIME","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRAN","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"FROM ACCOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"FROM ACCOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"TO ACCOUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TO ACCOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"DR AMOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"DR AMOUNT","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"CR AMOUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CR AMOUNT","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"NUMBER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"NUMBER","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"BANK","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"BANK","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"MNEM","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"NUMBER","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"TYPE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"NUMBER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"38","fieldName":"BRANCH CODE","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":26,"sectionName":"39","fieldName":"TRANSACTION GROUP","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":27,"sectionName":"40","fieldName":"TERMINAL","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":28,"sectionName":"41","fieldName":"CARD PRODUCT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":29,"sectionName":"25","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":true,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"26","fieldName":"TRACE NUMBER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"27","fieldName":"ATM CARD NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"28","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"29","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"30","fieldName":"TIME","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"31","fieldName":"TRAN MNEM","csvTxtLength":"5","pdfLength":"5","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"32","fieldName":"FROM ACC TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":38,"sectionName":"34","fieldName":"TO ACC TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"35","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":40,"sectionName":"36","fieldName":"DR AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","eol":false,"fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"37","fieldName":"CR AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","fieldFormat":"#,##0.00","defaultValue":"","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBC := null;
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"CASH CARD APPROVED TRANSACTIONS REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"90","pdfLength":"90","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"CCDLY013","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"CCDLY013","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SEQ","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"SEQ","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TRACE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"CARD NUMBER","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"CARD NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ACQ","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"ACQ","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"DATE","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TIME","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRAN","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"FROM ACCOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"FROM ACCOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"TO ACCOUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TO ACCOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"DR AMOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"DR AMOUNT","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"CR AMOUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CR AMOUNT","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"NUMBER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"NUMBER","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"BANK","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"BANK","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"MNEM","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"NUMBER","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"TYPE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"NUMBER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"38","fieldName":"BRANCH CODE","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":26,"sectionName":"39","fieldName":"TRANSACTION GROUP","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":27,"sectionName":"40","fieldName":"TERMINAL","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":28,"sectionName":"41","fieldName":"CARD PRODUCT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":29,"sectionName":"25","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":true,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"26","fieldName":"TRACE NUMBER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"27","fieldName":"ATM CARD NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"28","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"29","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"30","fieldName":"TIME","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"31","fieldName":"TRAN MNEM","csvTxtLength":"5","pdfLength":"5","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"32","fieldName":"FROM ACC TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":38,"sectionName":"34","fieldName":"TO ACC TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"35","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":40,"sectionName":"36","fieldName":"DR AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","eol":false,"fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"37","fieldName":"CR AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","fieldFormat":"#,##0.00","defaultValue":"","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBS := null;

	i_BODY_QUERY := TO_CLOB('
	SELECT
	  TXNC.TRL_CARD_BRANCH || ''  '' || BRC.BRC_NAME "BRANCH CODE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''ISSUER TRANSACTIONS''
        WHEN (TXN.TRL_TSC_CODE NOT IN (2,22) AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR TXN.TRL_FRD_REV_INST_ID = {V_IE_Acqr_Inst_Id})) THEN ''INTER-ENTITY TRANSACTIONS''
        ELSE ''ON-US TRANSACTIONS'' END AS "TRANSACTION GROUP",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN '' - '' ELSE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) || '' - '' || AST.AST_ALO_LOCATION_ID END "TERMINAL",
      CPD.CPD_NAME "CARD PRODUCT",
      TXN.TRL_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM AS "BANK MNEM",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE ''DF'' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 20 THEN ''CA'' ELSE ''DF'' END AS "TO ACC TYPE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN (TXN.TRL_TSC_CODE != 22 AND TXN.TRL_TSC_CODE != 21 AND (TXN.TRL_TQU_ID = ''F'' OR TXN.TRL_TQU_ID = ''A'')) THEN TXN.TRL_AMT_TXN ELSE 0 END "DR AMOUNT",
      CASE WHEN (TXN.TRL_TSC_CODE = 22 OR TXN.TRL_TSC_CODE = 21 OR TXN.TRL_TQU_ID = ''R'') THEN TXN.TRL_AMT_TXN ELSE 0 END "CR AMOUNT"
	FROM
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  LEFT JOIN CBC_TRAN_CODE CTR ON 
        CTR.CTR_CODE = CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000008882'') THEN 52  
        WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL) THEN 44  
        ELSE TXN.TRL_TSC_CODE END  
        AND CTR.CTR_CHANNEL = 
        	CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' AND (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id})) THEN ''I-CDM'' 
	      	WHEN (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id})) THEN CONCAT(''I-'', TXNC.TRL_ORIGIN_CHANNEL) 
	      	WHEN TXNC.TRL_ORIGIN_CHANNEL=''BRM'' THEN ''CDM''
	      	ELSE TXNC.TRL_ORIGIN_CHANNEL END
        AND CTR.CTR_DEBIT_CREDIT = CASE WHEN (TXN.TRL_TSC_CODE = 22 OR TXN.TRL_TSC_CODE = 21) THEN ''CREDIT'' ELSE ''DEBIT'' END
      JOIN ACCOUNT ACN ON TXN.TRL_ACCOUNT_1_ACN_ID = ACN.ACN_ACCOUNT_NUMBER
      JOIN ISSUER ISS ON ISS.ISS_ID = ACN.ACN_ISS_ID AND ISS.ISS_NAME = {V_Iss_Name}
      JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      JOIN CARD CRD ON CAT.CAT_CRD_ID = CRD.CRD_ID
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID	
      JOIN CARD_CUSTOM CST ON CST.CRD_ID = CRD.CRD_ID
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON LPAD(CBA.CBA_CODE,10,0) = LPAD(TXN.TRL_ACQR_INST_ID,10,0)
	  LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = CASE WHEN (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_Acqr_Inst_Id}) THEN SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) ELSE CST.CRD_BRANCH_CODE END
	WHERE
	  ((TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      	OR TXNC.TRL_ORIGIN_CHANNEL = ''OTC''
      	OR (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'')
      )
      AND TXN.TRL_TSC_CODE not in (26,41,246,250,251,252)     
      AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')     
      AND (TXN.TRL_TQU_ID = ''F''   OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0)) 
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Txn_Date}
    UNION ALL SELECT
      TXNC.TRL_CARD_BRANCH || ''  '' || BRC.BRC_NAME "BRANCH CODE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''ISSUER TRANSACTIONS''
        WHEN (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR TXN.TRL_FRD_REV_INST_ID = {V_IE_Acqr_Inst_Id}) THEN ''INTER-ENTITY TRANSACTIONS''
        ELSE ''ON-US TRANSACTIONS'' END AS "TRANSACTION GROUP",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN '' - '' ELSE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) || '' - '' || AST.AST_ALO_LOCATION_ID END "TERMINAL",
      CPD.CPD_NAME "CARD PRODUCT",
      TXN.TRL_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM AS "BANK MNEM",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE ''DF'' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 20 THEN ''CA'' ELSE ''DF'' END AS "TO ACC TYPE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DR AMOUNT",
      CASE WHEN TXN.TRL_TQU_ID = ''F'' OR TXN.TRL_TQU_ID = ''A'' THEN TXN.TRL_AMT_TXN ELSE 0 END "CR AMOUNT"
	FROM
	  TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  LEFT JOIN CBC_TRAN_CODE CTR ON 
        CTR.CTR_CODE = CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000008882'') THEN 52  
        WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL) THEN 44  
        ELSE TXN.TRL_TSC_CODE END  
        AND CTR.CTR_CHANNEL = 
        	CASE WHEN TXNC.TRL_ORIGIN_CHANNEL=''BNT'' THEN TXNC.TRL_ORIGIN_CHANNEL 
        	WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BRM'' AND (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id})) THEN ''I-CDM''
        	WHEN (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN CONCAT(''I-'', TXNC.TRL_ORIGIN_CHANNEL) 
        	WHEN TXNC.TRL_ORIGIN_CHANNEL=''BRM'' THEN ''CDM''
        	ELSE TXNC.TRL_ORIGIN_CHANNEL END
        AND CTR.CTR_DEBIT_CREDIT = ''CREDIT'' 
      JOIN ACCOUNT ACN ON TXN.TRL_ACCOUNT_2_ACN_ID = ACN.ACN_ACCOUNT_NUMBER
      JOIN ISSUER ISS ON ISS.ISS_ID = ACN.ACN_ISS_ID AND ISS.ISS_NAME = {V_Iss_Name}
      JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      JOIN CARD CRD ON CAT.CAT_CRD_ID = CRD.CRD_ID
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID	
      JOIN CARD_CUSTOM CST ON CST.CRD_ID = CRD.CRD_ID
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON LPAD(CBA.CBA_CODE,10,0) = LPAD(TXN.TRL_ACQR_INST_ID,10,0)
	  LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT  JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = CASE WHEN (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_Acqr_Inst_Id}) THEN SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) ELSE CST.CRD_BRANCH_CODE END
	WHERE
	  ((TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      	 OR TXNC.TRL_ORIGIN_CHANNEL = ''OTC''
      	OR (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'')
      )
	  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND (TXN.TRL_TQU_ID = ''F''  OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
	  AND txn.trl_tsc_code != 1
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0 
      AND {Txn_Date}
	ORDER BY
      "BRANCH CODE",
      "TRANSACTION GROUP",
      "TERMINAL",
      "CARD PRODUCT",
      "DATE",
      "TIME"		
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
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	
END;
/