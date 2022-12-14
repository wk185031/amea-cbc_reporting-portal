-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- Report revision 		06-JUL-2021		LJL		Revise report based on spec
-- CBCAXUPISSLOG-896	31-AUG-2021		LJL		Separate On-Us and Inter-entity report

DECLARE
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
i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"ATM LIST OF BEEP INQUIRY REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"21","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"22","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"23","fieldName":"Space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"24","fieldName":"Space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"25","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"101","pdfLength":"101","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"13","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"14","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]');


i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No.","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No.","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Beep Ref No.","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Beep Ref No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No.","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Beep Card No.","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Beep Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Account Number","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account Number","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Trans Fee (DR)","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Trans Fee (DR)","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Trans Fee (CR)","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Trans Fee (CR)","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Tran Code Remarks","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Tran Code Remarks","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":false,"eol":true},{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"BEEP REF NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"BEEP CARD NO","csvTxtLength":"18","pdfLength":"8","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"CBC143","padFieldType":"Leading","padFieldValue":"Spaces"},{"sequence":23,"sectionName":"23","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"24","fieldName":"TRAN FEE DR","csvTxtLength":"6","pdfLength":"6","fieldType":"Decimal","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"#,##0.00"},{"sequence":25,"sectionName":"25","fieldName":"TRAN FEE CR","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","fieldFormat":"#,##0.00","tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');


i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"140","pdfLength":"140","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Space2","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","firstField":false,"eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Space3","csvTxtLength":"17","pdfLength":"17","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Space4","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"Space7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"Space8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"Space9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TOTAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"TOTAL"},{"sequence":11,"sectionName":"11","fieldName":"TRAN FEE DR","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"TRAN FEE CR","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"TOTAL","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
-- CBS header/body/trailer fields

i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"ATM LIST OF BEEP INQUIRY REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"21","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"22","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"23","fieldName":"Space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"24","fieldName":"Space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"25","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"101","pdfLength":"101","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"13","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"14","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]');


i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No.","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No.","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Beep Ref No.","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Beep Ref No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No.","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Beep Card No.","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Beep Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Account Number","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account Number","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Trans Fee (DR)","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Trans Fee (DR)","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Trans Fee (CR)","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Trans Fee (CR)","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Tran Code Remarks","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Tran Code Remarks","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":false,"eol":true},{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"BEEP REF NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"BEEP CARD NO","csvTxtLength":"18","pdfLength":"8","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"CBC143","padFieldType":"Leading","padFieldValue":"Spaces"},{"sequence":23,"sectionName":"23","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"24","fieldName":"TRAN FEE DR","csvTxtLength":"6","pdfLength":"6","fieldType":"Decimal","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"#,##0.00"},{"sequence":25,"sectionName":"25","fieldName":"TRAN FEE CR","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","fieldFormat":"#,##0.00","tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');


i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"140","pdfLength":"140","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"Space2","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","firstField":false,"eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"Space3","csvTxtLength":"17","pdfLength":"17","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Space4","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"Space7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"Space8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"Space9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TOTAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"TOTAL"},{"sequence":11,"sectionName":"11","fieldName":"TRAN FEE DR","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"TRAN FEE CR","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"TOTAL","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');



-- Query Part
i_BODY_QUERY := TO_CLOB('
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      CASE 
	 WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_RRN "BEEP REF NO",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_CUSTOM_DATA "BEEP CARD NO",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TQU_ID = ''F'' THEN TXN.TRL_ISS_CHARGE_AMT END AS "TRAN FEE DR",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_ISS_CHARGE_AMT END AS "TRAN FEE CR",
     ARC.ARC_NAME "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  Left join cbc_bin cbi on CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN) 
      Left join cbc_bank cba on CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE =''145''
      AND TXN.TRL_TQU_ID =''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE = ''ATM''
     AND cba.cba_mnem = {V_Iss_Name}
	  AND  (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND {Branch_Code}
      AND {Branch_Name}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
START SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      CASE  
		WHEN TXN.TRL_TQU_ID = ''R'' THEN ''BBC'' ELSE ''BBI'' END AS "TRAN MNEM",
      TXN.TRL_RRN "BEEP REF NO",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_CUSTOM_DATA "BEEP CARD NO",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TQU_ID = ''F'' THEN TXN.TRL_ISS_CHARGE_AMT END AS "TRAN FEE DR",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_ISS_CHARGE_AMT END AS "TRAN FEE CR",
     ARC.ARC_NAME "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  Left join cbc_bin cbi on CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN) 
      Left join cbc_bank cba on CBI.CBI_CBA_ID = CBA.CBA_ID
  JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''BNT''
JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE =''145''
      AND TXN.TRL_TQU_ID =''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE = ''ATM''
AND (cba.cba_mnem = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
	  OR cba.cba_mnem = {V_IE_Iss_Name}
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id}))  
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND {Branch_Code}
      AND {Branch_Name}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
END
');


i_TRAILER_QUERY :=TO_CLOB('

SELECT
       SUM(NVL("TRAN FEE DR", 0)) "TRAN FEE DR",
       SUM(NVL("TRAN FEE CR", 0)) "TRAN FEE CR",
       SUM(NVL("TRAN FEE DR", 0)) - SUM(NVL("TRAN FEE CR", 0)) "TOTAL"
FROM(
SELECT
      CASE WHEN TXN.TRL_TQU_ID = ''F'' THEN TXN.TRL_ISS_CHARGE_AMT END AS "TRAN FEE DR",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_ISS_CHARGE_AMT END AS "TRAN FEE CR"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  Left join cbc_bin cbi on CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN) 
      Left join cbc_bank cba on CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = ''145''
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE = ''ATM''
    AND cba.cba_mnem = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Branch_Name}
      AND {Txn_Date})
START SELECT       
       SUM(NVL("TRAN FEE DR", 0)) "TRAN FEE DR",
       SUM(NVL("TRAN FEE CR", 0)) "TRAN FEE CR",
       SUM(NVL("TRAN FEE DR", 0)) - SUM(NVL("TRAN FEE CR", 0)) "TOTAL"
FROM(
SELECT
      CASE WHEN TXN.TRL_TQU_ID = ''F'' THEN TXN.TRL_ISS_CHARGE_AMT END AS "TRAN FEE DR",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_ISS_CHARGE_AMT END AS "TRAN FEE CR"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  Left join cbc_bin cbi on CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN) 
      Left join cbc_bank cba on CBI.CBI_CBA_ID = CBA.CBA_ID
     JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''BNT''
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = ''145''
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE = ''ATM''
 AND (cba.cba_mnem = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
	  OR cba.cba_mnem = {V_IE_Iss_Name}
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id}))   
      AND {Branch_Code}
      AND {Branch_Name}
      AND {Txn_Date})
END

');


	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM List of Beep Inquiry' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM List of Beep Inquiry' AND RED_INS_ID = 2;
	
END;
/