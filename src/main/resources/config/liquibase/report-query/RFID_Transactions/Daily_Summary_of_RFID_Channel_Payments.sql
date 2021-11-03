-- Tracking				Date			Name	Description
-- Report revision		30-JUL-2021		LJL		Update based on excel spec
-- Report revision		23-AUG-201		LJL	Update query tp cater IE
DECLARE
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
	
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	
	i_BODY_QUERY_CBC CLOB;
	i_TRAILER_QUERY_CBC CLOB;
	i_BODY_QUERY_CBS CLOB;
	i_TRAILER_QUERY_CBS CLOB;
BEGIN 


-- CBC header/body/trailer fields

i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"DAILY SUMMARY OF RFID CHANNEL PAYMENTS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"Space1","fieldName":"space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"Space2","fieldName":"space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"Space3","fieldName":"space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"Space4","fieldName":"space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"Space5","fieldName":"space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"Space6","fieldName":"space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"eol":true},{"sequence":14,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"51","pdfLength":"51","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"13","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":26,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');

i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"RFID TRANSACTION FEE (10.00/txn)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"RFID TRANSACTION FEE (10.00/txn)"},{"sequence":5,"sectionName":"5","fieldName":"BRANCH","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TERM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TERM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ATM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldName":"CDM","defaultValue":"CDM"},{"sequence":12,"sectionName":"12","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"BRM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"17","fieldName":"FEE SHARE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"FEE SHARE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"VOLUME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOLUME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TOTAL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"CBC","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CBC","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"24","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"25","fieldName":"RFID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"RFID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"26","fieldName":"VOLUME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOLUME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TOTAL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"CBC","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CBC","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"29","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"30","fieldName":"RFID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"RFID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"31","fieldName":"VOLUME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOLUME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TOTAL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"CBC","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CBC","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":34,"sectionName":"34","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":35,"sectionName":"35","fieldName":"RFID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"RFID","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"36","fieldName":"CBC","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"CBC","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"FATP","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"FATP","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"TERMINAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"BRANCH NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"ATM COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"ATM TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"ATM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":44,"sectionName":"44","fieldName":"CDM COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"CDM TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"CDM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":47,"sectionName":"47","fieldName":"BRM COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":48,"sectionName":"48","fieldName":"BRM TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":49,"sectionName":"49","fieldName":"BRM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":50,"sectionName":"50","fieldName":"FEE SHARE CBC","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":51,"sectionName":"51","fieldName":"FEE SHARE FATP","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');

i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"OVER - ALL TOTAL","csvTxtLength":"28","pdfLength":"28","fieldType":"String","defaultValue":"OVER - ALL TOTAL","firstField":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ATM COUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"ATM TOTAL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"ATM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"CDM COUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"CDM TOTAL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"CDM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"BRM COUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"BRM TOTAL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"BRM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"FEE SHARE CBC","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","eol":false,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"FEE SHARE FATP","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');


-- CBS header/body/trailer fields

i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"DAILY SUMMARY OF RFID CHANNEL PAYMENTS REPORT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"Space1","fieldName":"space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"Space2","fieldName":"space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"Space3","fieldName":"space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"Space4","fieldName":"space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"Space5","fieldName":"space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"Space6","fieldName":"space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"eol":true},{"sequence":14,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"51","pdfLength":"51","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"13","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":26,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');

i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"RFID TRANSACTION FEE (10.00/txn)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"RFID TRANSACTION FEE (10.00/txn)"},{"sequence":5,"sectionName":"5","fieldName":"BRANCH","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TERM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TERM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ATM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldName":"CDM","defaultValue":"CDM"},{"sequence":12,"sectionName":"12","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"BRM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"17","fieldName":"FEE SHARE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"FEE SHARE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"VOLUME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOLUME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TOTAL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"CBS","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CBS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"24","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"25","fieldName":"RFID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"RFID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"26","fieldName":"VOLUME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOLUME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TOTAL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"CBS","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CBS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"29","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"30","fieldName":"RFID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"RFID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"31","fieldName":"VOLUME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOLUME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TOTAL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"CBS","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CBS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":34,"sectionName":"34","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":35,"sectionName":"35","fieldName":"RFID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"RFID","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"36","fieldName":"CBS","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"CBS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"FATP","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"FATP","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"TERMINAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"BRANCH NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"ATM COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"ATM TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"ATM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":44,"sectionName":"44","fieldName":"CDM COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"CDM TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"CDM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":47,"sectionName":"47","fieldName":"BRM COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":48,"sectionName":"48","fieldName":"BRM TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":49,"sectionName":"49","fieldName":"BRM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":50,"sectionName":"50","fieldName":"FEE SHARE CBS","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":51,"sectionName":"51","fieldName":"FEE SHARE FATP","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');

i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"OVER - ALL TOTAL","csvTxtLength":"28","pdfLength":"28","fieldType":"String","defaultValue":"OVER - ALL TOTAL","firstField":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ATM COUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"ATM TOTAL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"ATM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"CDM COUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"CDM TOTAL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"CDM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"BRM COUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"BRM TOTAL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"BRM FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"FEE SHARE CBS","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","eol":false,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"FEE SHARE FATP","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');


-- CBC Query Part
i_BODY_QUERY_CBC := TO_CLOB('START FIRST PAGE
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "ATM COUNT",
      "ATM TOTAL",
      "ATM FEE",
      "CDM COUNT",
      "CDM TOTAL",
      "CDM FEE",
      "BRM COUNT",
      "BRM TOTAL",
      "BRM FEE",
      "FEE SHARE CBC",
      "FEE SHARE FATP"
FROM(
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM FEE") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM FEE") "BRM FEE",
	  (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBC",
      (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT"))  "FEE SHARE FATP"
FROM (
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
       CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID =''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION"
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "ATM COUNT",
      "ATM TOTAL",
      "ATM FEE",
      "CDM COUNT",
      "CDM TOTAL",
      "CDM FEE",
      "BRM COUNT",
      "BRM TOTAL",
      "BRM FEE",
      "FEE SHARE CBC",
      "FEE SHARE FATP"
ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC
END FIRST PAGE
START SECOND PAGE
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "ATM COUNT",
      "ATM TOTAL",
      "ATM FEE",
      "CDM COUNT",
      "CDM TOTAL",
      "CDM FEE",
      "BRM COUNT",
      "BRM TOTAL",
      "BRM FEE",
      "FEE SHARE CBC",
      "FEE SHARE FATP"
FROM(
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM FEE") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM FEE") "BRM FEE",
	  (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBC",
      (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT"))  "FEE SHARE FATP"
FROM (
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
       CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID =''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND {Branch_Code}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME"
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "ATM COUNT",
      "ATM TOTAL",
      "ATM FEE",
      "CDM COUNT",
      "CDM TOTAL",
      "CDM FEE",
      "BRM COUNT",
      "BRM TOTAL",
      "BRM FEE",
      "FEE SHARE CBC",
      "FEE SHARE FATP"
ORDER BY
      "BRANCH CODE" ASC
END SECOND PAGE
START THIRD PAGE
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      COUNT("ATM COUNT") "ATM COUNT",
      (5.00 * COUNT("ATM COUNT")) "ATM TOTAL",
      (5.00 * COUNT("ATM COUNT")) "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      (5.00 * COUNT("CDM COUNT")) "CDM TOTAL",
      (5.00 * COUNT("CDM COUNT")) "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      (5.00 * COUNT("CDM COUNT")) "CDM TOTAL",
      (5.00 * COUNT("BRM COUNT")) "BRM FEE"
FROM (
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
	         CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH  = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID =''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND {Branch_Code}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME"
ORDER BY
      "BRANCH CODE" ASC
END THIRD PAGE');

i_TRAILER_QUERY_CBC :=TO_CLOB('SSTART FIRST PAGE
SELECT
      COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM COUNT") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM COUNT") "BRM FEE",
      (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBC",
     (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE FATP"
FROM (
SELECT
       CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND {Txn_Date}
)
END FIRST PAGE
START SECOND PAGE
SELECT
     COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM COUNT") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM COUNT") "BRM FEE",
      (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBC",
     (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE FATP"
FROM (
SELECT
       CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH  = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')	  
      AND {Txn_Date}
)
END SECOND PAGE
START THIRD PAGE
SELECT
      COUNT("ATM COUNT") "ATM COUNT",
      (5.00 * COUNT("ATM COUNT")) "ATM TOTAL",
      (5.00 * COUNT("ATM COUNT")) "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      (5.00 * COUNT("CDM COUNT")) "CDM TOTAL",
      (5.00 * COUNT("CDM COUNT")) "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      (5.00 * COUNT("CDM COUNT")) "CDM TOTAL",
      (5.00 * COUNT("BRM COUNT")) "BRM FEE",
      (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBC",
     (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE FATP"
FROM (
SELECT
       CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH  = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')	  
      AND {Txn_Date}
)
END THIRD PAGE');

-- CBS Query Part
i_BODY_QUERY_CBS := TO_CLOB('START FIRST PAGE
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "ATM COUNT",
      "ATM TOTAL",
      "ATM FEE",
      "CDM COUNT",
      "CDM TOTAL",
      "CDM FEE",
      "BRM COUNT",
      "BRM TOTAL",
      "BRM FEE",
      "FEE SHARE CBS",
      "FEE SHARE FATP"
FROM(
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM FEE") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM FEE") "BRM FEE",
	   (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBS",
      (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT"))  "FEE SHARE FATP"
FROM (
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
	  CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID =''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION"
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "ATM COUNT",
      "ATM TOTAL",
      "ATM FEE",
      "CDM COUNT",
      "CDM TOTAL",
      "CDM FEE",
      "BRM COUNT",
      "BRM TOTAL",
      "BRM FEE",
      "FEE SHARE CBS",
      "FEE SHARE FATP"
ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC
END FIRST PAGE
START SECOND PAGE
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "ATM COUNT",
      "ATM TOTAL",
      "ATM FEE",
      "CDM COUNT",
      "CDM TOTAL",
      "CDM FEE",
      "BRM COUNT",
      "BRM TOTAL",
      "BRM FEE",
      "FEE SHARE CBS",
      "FEE SHARE FATP"
FROM(
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
     COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM FEE") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM FEE") "BRM FEE",
	  (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBS",
      (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT"))  "FEE SHARE FATP"
FROM (
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
	  CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID =''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND {Branch_Code}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME"
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "ATM COUNT",
      "ATM TOTAL",
      "ATM FEE",
      "CDM COUNT",
      "CDM TOTAL",
      "CDM FEE",
      "BRM COUNT",
      "BRM TOTAL",
      "BRM FEE",
      "FEE SHARE CBS",
      "FEE SHARE FATP"
ORDER BY
      "BRANCH CODE" ASC
END SECOND PAGE
START THIRD PAGE
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM FEE") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM FEE") "BRM FEE"
FROM (
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
	  CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH  = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID =''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND {Branch_Code}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME"
ORDER BY
      "BRANCH CODE" ASC
END THIRD PAGE');

i_TRAILER_QUERY_CBS :=TO_CLOB('START FIRST PAGE
SELECT
      COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM FEE") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM FEE") "BRM FEE",
      (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBS",
     (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE FATP"
FROM (
SELECT
CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')
      AND {Txn_Date}
)
END FIRST PAGE
START SECOND PAGE
SELECT
      COUNT("ATM COUNT") "ATM COUNT",
      SUM("ATM TOTAL") "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      SUM("CDM TOTAL") "CDM TOTAL",
      SUM("CDM FEE") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      SUM("BRM TOTAL") "BRM TOTAL",
      SUM("BRM FEE") "BRM FEE",
       (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE CBS",
     (5.00 * COUNT("ATM COUNT") +  5.00 * COUNT("CDM COUNT") + 5.00 * COUNT("BRM COUNT")) "FEE SHARE FATP"
FROM (
SELECT
CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH  = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')	  
      AND {Txn_Date}
)
END SECOND PAGE
START THIRD PAGE
SELECT
     COUNT("ATM COUNT") "ATM COUNT",
      (5.00 * COUNT("ATM COUNT")) "ATM TOTAL",
      SUM("ATM FEE") "ATM FEE",
      COUNT("CDM COUNT") "CDM COUNT",
      (5.00 * COUNT("CDM COUNT")) "CDM TOTAL",
      SUM("CDM FEE") "CDM FEE",
      COUNT("BRM COUNT") "BRM COUNT",
      (5.00 * COUNT("BRM COUNT")) "BRM TOTAL",
      SUM("BRM FEE") "BRM FEE"
FROM (
SELECT
CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0))END AS "ATM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"CDM FEE",
		CASE WHEN  TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN (NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) END AS"BRM FEE",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN 1 END AS "ATM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "ATM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN 1 END AS "CDM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CDM TOTAL",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN 1 END AS "BRM COUNT",
      CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BRM TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH  = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 51
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
AND ((TXN.TRL_ISS_NAME = {V_Iss_Name}
AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id}))
OR (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})) 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'')	  
      AND {Txn_Date}
)
END THIRD PAGE');
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY_CBC,
		RED_TRAILER_QUERY = i_TRAILER_QUERY_CBC
	WHERE RED_NAME = 'Daily Summary of RFID Channel Payments' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY_CBS,
		RED_TRAILER_QUERY = i_TRAILER_QUERY_CBS
	WHERE RED_NAME = 'Daily Summary of RFID Channel Payments' AND RED_INS_ID = 2;
	
END;
/