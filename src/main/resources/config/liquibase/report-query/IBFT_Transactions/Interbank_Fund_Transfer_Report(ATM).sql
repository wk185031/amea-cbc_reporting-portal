-- Tracking				Date			Name	Description
-- Report revision		23-JUL-2021		NY		Initial
-- Report revision		26-JUL-2021		NY		Revised reports based on spec
-- CBCAXUPISSLOG-822	04-AUG-2021		NY		Fix IBFT transmitting not appear in report
-- IBFT					06-AUG-2021		NY		Use left join consistently to avoid data mismatch to master
-- IBFT					15-AUG-2021		NY		Get stan if dest_stan null
-- CBCAXUPISSLOG-531	14-SEP-2021		NY		Acquiring IBFT include both CBC/CBS instead of only CBC

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

-- Interbank Fund Transfer Report (ATM)

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"INTERBANK FUND TRANSFER REPORT (ATM)","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"51","pdfLength":"51","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"EFP016-01","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"EFP016-01","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ORIG BANK","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ISSUER/TRANSMITTING BANK","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"RECEIVING BANK","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"MNEM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"BRANCH","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"TERM ID","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NO.","csvTxtLength":"32","pdfLength":"32","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"CARD NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"TRAN AMOUNT","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"MNEM","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ACCOUNT NO.","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"MNEM","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"ACCOUNT NO.","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BRANCH CODE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"SEQ NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"30","fieldName":"ATM CARD NUMBER","csvTxtLength":"16","pdfLength":"16","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"AMOUNT","csvTxtLength":"23","pdfLength":"23","fieldType":"Decimal","delimiter":";","firstField":false,"fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"ISSUER BANK MNEM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"ISSUER BRANCH NAME","csvTxtLength":"26","pdfLength":"26","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"FROM ACCOUNT NO","csvTxtLength":"24","pdfLength":"24","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"35","fieldName":"RECEIVING BANK MNEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"RECEIVING BRANCH NAME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"TO ACCOUNT NO","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[]');
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"INTERBANK FUND TRANSFER REPORT (ATM)","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"51","pdfLength":"51","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"EFP016-01","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"EFP016-01","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ORIG BANK","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ISSUER/TRANSMITTING BANK","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"RECEIVING BANK","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"MNEM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"BRANCH","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"TERM ID","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NO.","csvTxtLength":"32","pdfLength":"32","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"CARD NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"TRAN AMOUNT","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"MNEM","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ACCOUNT NO.","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"MNEM","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"ACCOUNT NO.","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BRANCH CODE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"SEQ NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"30","fieldName":"ATM CARD NUMBER","csvTxtLength":"16","pdfLength":"16","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"AMOUNT","csvTxtLength":"23","pdfLength":"23","fieldType":"Decimal","delimiter":";","firstField":false,"fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"ISSUER BANK MNEM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"ISSUER BRANCH NAME","csvTxtLength":"26","pdfLength":"26","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"FROM ACCOUNT NO","csvTxtLength":"24","pdfLength":"24","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"35","fieldName":"RECEIVING BANK MNEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"RECEIVING BRANCH NAME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"TO ACCOUNT NO","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[]');
	
	i_BODY_QUERY := TO_CLOB('
START ACQUIRING
SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      {V_Acq_Name} "ACQUIRER BANK MNEM",
      CBA.CBA_MNEM "ISSUER BANK MNEM",
      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "RECEIVING BANK MNEM",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 44
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME IS NULL
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
END ACQUIRING
START ISSUING
SELECT
      TXNC.TRL_CARD_BRANCH "ISSUER BRANCH CODE",
      BRC.BRC_NAME "ISSUER BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      COALESCE(TXN.TRL_STAN, TXN.TRL_DEST_STAN, NULL) "SEQ NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "ACQUIRER BANK MNEM",
      {V_Acq_Name} AS "ISSUER BANK MNEM",
      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "RECEIVING BANK MNEM",
      (SELECT LPAD(CBA_CODE, 4, ''0'') FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
      AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882''
      AND {Bank_Code}
      AND {Branch_Code}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_STAN ASC
END ISSUING
START RECEIVING
SELECT
      {Receiving_Branch_Code} "RECEIVING BRANCH CODE",
      {Branch_Name} "RECEIVING BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      COALESCE(TXN.TRL_STAN, TXN.TRL_DEST_STAN, NULL) "SEQ NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "ACQUIRER BANK MNEM",
      CBA.CBA_MNEM "ISSUER BANK MNEM",
      {V_Iss_Name} AS "RECEIVING BANK MNEM",
      (SELECT LPAD(CBA_CODE, 4, ''0'') FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
      TXN.TRL_TSC_CODE = 41
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Recv_Inst_Id}
      AND {Bank_Code}
      AND {To_Account}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_STAN ASC
END RECEIVING
	');	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Interbank Fund Transfer Report (ATM)' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Interbank Fund Transfer Report (ATM)' AND RED_INS_ID = 2;
	
END;
/