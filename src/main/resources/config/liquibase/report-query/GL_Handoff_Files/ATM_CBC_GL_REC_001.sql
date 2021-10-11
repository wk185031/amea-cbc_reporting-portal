-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-685	25-JUN-2021		NY		Initial config from UAT environment
-- CBCAXUPISSLOG-685	25-JUN-2021		NY		Fix CBS GL account printed in CBC GL report
-- CBCAXUPISSLOG-645	28-JUN-2021		NY		Clean up for new introduced CBS GL Account set
-- Rel-20210730			30-JUL-2021		KW		Fix according to spec

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'ATM CBC GL REC 001';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	i_PROCESSING_CLASS VARCHAR2(200) := 'my.com.mandrill.base.reporting.glHandoffFiles.DefaultGLHandoff';
BEGIN 

	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Record Type Indicator","csvTxtLength":"1","fieldType":"String","defaultValue":"H","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"File Upload Date","csvTxtLength":"8","fieldType":"Date","fieldFormat":"ddMMyyyy","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Source Application code","csvTxtLength":"3","fieldType":"String","defaultValue":"ATM","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"User ID of source application","csvTxtLength":"80","fieldType":"String","defaultValue":"GL_UPLOAD","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"File Type","csvTxtLength":"1","fieldType":"String","defaultValue":"G","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"File Name","csvTxtLength":"50","fieldType":"String","defaultValue":"","fieldFormat":"yyyyMMdd","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Filler","csvTxtLength":"1459","fieldType":"String","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Record Type Indicator","csvTxtLength":"1","fieldType":"String","defaultValue":"D","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"A/C Number","csvTxtLength":"16","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Currency Code of Account Number","csvTxtLength":"3","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Service Outlet","csvTxtLength":"8","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Part Tran Indicator","csvTxtLength":"1","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Tran Amount","csvTxtLength":"17","fieldType":"Decimal","fieldFormat":"0.00","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":7,"sectionName":"7","fieldName":"Tran Particular","csvTxtLength":"30","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"Account Report Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Reference Number","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Instrument Type","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Instrument Date","csvTxtLength":"10","fieldType":"String","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Instrument Alpha","csvTxtLength":"6","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Actual Instrument Number","csvTxtLength":"16","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"Navigation Flag (For HO Trans)","csvTxtLength":"1","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"Reference Amount","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"Reference Currency Code","csvTxtLength":"3","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"Rate Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"Rate","csvTxtLength":"15","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"Value Date","csvTxtLength":"10","fieldType":"String","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"GL Date","csvTxtLength":"10","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"Category Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"To / From Bank Code","csvTxtLength":"6","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"To / From Branch Code","csvTxtLength":"6","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"Advc. Extension Counter Code","csvTxtLength":"2","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"BAR Advice Gen Indicator","csvTxtLength":"1","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BAR Advice Number","csvTxtLength":"12","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"BAR Advice Date","csvTxtLength":"10","pdfLength":"","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"Bill Number","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"Header Text Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"Header Free Text","csvTxtLength":"30","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":31,"sectionName":"31","fieldName":"Particulars Line 1","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"Particulars Line 2","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"Particulars Line 3","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"Particulars Line 4","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"Particulars Line 5","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"Amount Line 1","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"Amount Line 2","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"Amount Line 3","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"Amount Line 4","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"Amount Line 5","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"Tran Remarks","csvTxtLength":"30","fieldType":"String","defaultValue":"ATM_UPLOAD","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"Payee Account Number","csvTxtLength":"16","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"Received BAR Advice Number","csvTxtLength":"12","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":44,"sectionName":"44","fieldName":"Received BAR Advice Date","csvTxtLength":"10","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"Original Transaction Date","csvTxtLength":"10","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"Original Transaction ID","csvTxtLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":47,"sectionName":"47","fieldName":"Original Part Transaction Serial Number","csvTxtLength":"4","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":48,"sectionName":"48","fieldName":"IBAN Number","csvTxtLength":"34","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":49,"sectionName":"49","fieldName":"Free text","csvTxtLength":"256","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":50,"sectionName":"50","fieldName":"Entity ID","csvTxtLength":"16","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":51,"sectionName":"51","fieldName":"Entity Type","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":52,"sectionName":"52","fieldName":"Flow ID","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":53,"sectionName":"53","fieldName":"Particulars Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":54,"sectionName":"54","fieldName":"Particulars 2","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":55,"sectionName":"55","fieldName":"Tran Type","csvTxtLength":"1","fieldType":"String","defaultValue":"T","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":56,"sectionName":"56","fieldName":"Tran Sub Type","csvTxtLength":"2","fieldType":"String","defaultValue":"BI","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":57,"sectionName":"57","fieldName":"Third Party Source Application Code","csvTxtLength":"3","fieldType":"String","defaultValue":"ATM","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":58,"sectionName":"58","fieldName":"Third Party Tran Remarks","csvTxtLength":"80","fieldType":"String","defaultValue":"ATM_UPLOAD","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":59,"sectionName":"59","fieldName":"Third Party Tran Description","csvTxtLength":"80","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":60,"sectionName":"60","fieldName":"Third Party User ID","csvTxtLength":"80","fieldType":"String","defaultValue":"GL_UPLOAD","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":61,"sectionName":"61","fieldName":"Transaction Reference Number","csvTxtLength":"80","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":62,"sectionName":"62","fieldName":"Third Party Account Number","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":63,"sectionName":"63","fieldName":"Third Party Account Name","csvTxtLength":"80","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":64,"sectionName":"64","fieldName":"ATM Bank ID","csvTxtLength":"4","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":65,"sectionName":"65","fieldName":"ATM Terminal ID","csvTxtLength":"4","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":66,"sectionName":"66","fieldName":"ATM Card Number","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID"},{"sequence":67,"sectionName":"67","fieldName":"Biller Code","csvTxtLength":"4","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":68,"sectionName":"68","fieldName":"Biller Subscription Number1","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":69,"sectionName":"69","fieldName":"Biller Subscription Number2","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":70,"sectionName":"70","fieldName":"TRAN_DATE","csvTxtLength":"10","fieldType":"String","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":71,"sectionName":"71","fieldName":"GROUP_ID","csvTxtLength":"20","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":72,"sectionName":"72","fieldName":"Profit Cost Center Code","csvTxtLength":"16","fieldType":"String","defaultValue":"05510","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":73,"sectionName":"73","fieldName":"OAP Ref Nbr","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Record Type Indicator","csvTxtLength":"1","fieldType":"String","defaultValue":"T","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"File Hash","csvTxtLength":"32","fieldType":"Decimal","defaultValue":"","fieldFormat":"0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Number of Data Records","csvTxtLength":"13","fieldType":"Number","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":4,"sectionName":"4","fieldName":"Filler","csvTxtLength":"1556","fieldType":"Number","eol":true,"leftJustified":true,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"}]');
	
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Record Type Indicator","csvTxtLength":"1","fieldType":"String","defaultValue":"H","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"File Upload Date","csvTxtLength":"8","fieldType":"Date","fieldFormat":"ddMMyyyy","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Source Application code","csvTxtLength":"3","fieldType":"String","defaultValue":"ATM","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"User ID of source application","csvTxtLength":"80","fieldType":"String","defaultValue":"GL_UPLOAD","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"File Type","csvTxtLength":"1","fieldType":"String","defaultValue":"G","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"File Name","csvTxtLength":"50","fieldType":"String","defaultValue":"","fieldFormat":"yyyyMMdd","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Filler","csvTxtLength":"1459","fieldType":"String","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Record Type Indicator","csvTxtLength":"1","fieldType":"String","defaultValue":"D","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"A/C Number","csvTxtLength":"16","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Currency Code of Account Number","csvTxtLength":"3","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Service Outlet","csvTxtLength":"8","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Part Tran Indicator","csvTxtLength":"1","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Tran Amount","csvTxtLength":"17","fieldType":"Decimal","fieldFormat":"0.00","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":7,"sectionName":"7","fieldName":"Tran Particular","csvTxtLength":"30","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"Account Report Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Reference Number","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Instrument Type","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Instrument Date","csvTxtLength":"10","fieldType":"String","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Instrument Alpha","csvTxtLength":"6","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Actual Instrument Number","csvTxtLength":"16","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"Navigation Flag (For HO Trans)","csvTxtLength":"1","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"Reference Amount","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"Reference Currency Code","csvTxtLength":"3","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"Rate Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"Rate","csvTxtLength":"15","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"Value Date","csvTxtLength":"10","fieldType":"String","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"GL Date","csvTxtLength":"10","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"Category Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"To / From Bank Code","csvTxtLength":"6","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"To / From Branch Code","csvTxtLength":"6","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"Advc. Extension Counter Code","csvTxtLength":"2","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"BAR Advice Gen Indicator","csvTxtLength":"1","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BAR Advice Number","csvTxtLength":"12","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"BAR Advice Date","csvTxtLength":"10","pdfLength":"","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"Bill Number","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"Header Text Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"Header Free Text","csvTxtLength":"30","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":31,"sectionName":"31","fieldName":"Particulars Line 1","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"Particulars Line 2","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"Particulars Line 3","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"Particulars Line 4","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"Particulars Line 5","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"Amount Line 1","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"Amount Line 2","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"Amount Line 3","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"Amount Line 4","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"Amount Line 5","csvTxtLength":"17","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"Tran Remarks","csvTxtLength":"30","fieldType":"String","defaultValue":"ATM_UPLOAD","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"Payee Account Number","csvTxtLength":"16","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"Received BAR Advice Number","csvTxtLength":"12","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":44,"sectionName":"44","fieldName":"Received BAR Advice Date","csvTxtLength":"10","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"Original Transaction Date","csvTxtLength":"10","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"Original Transaction ID","csvTxtLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":47,"sectionName":"47","fieldName":"Original Part Transaction Serial Number","csvTxtLength":"4","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":48,"sectionName":"48","fieldName":"IBAN Number","csvTxtLength":"34","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":49,"sectionName":"49","fieldName":"Free text","csvTxtLength":"256","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":50,"sectionName":"50","fieldName":"Entity ID","csvTxtLength":"16","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":51,"sectionName":"51","fieldName":"Entity Type","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":52,"sectionName":"52","fieldName":"Flow ID","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":53,"sectionName":"53","fieldName":"Particulars Code","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":54,"sectionName":"54","fieldName":"Particulars 2","csvTxtLength":"5","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":55,"sectionName":"55","fieldName":"Tran Type","csvTxtLength":"1","fieldType":"String","defaultValue":"T","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":56,"sectionName":"56","fieldName":"Tran Sub Type","csvTxtLength":"2","fieldType":"String","defaultValue":"BI","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":57,"sectionName":"57","fieldName":"Third Party Source Application Code","csvTxtLength":"3","fieldType":"String","defaultValue":"ATM","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":58,"sectionName":"58","fieldName":"Third Party Tran Remarks","csvTxtLength":"80","fieldType":"String","defaultValue":"ATM_UPLOAD","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":59,"sectionName":"59","fieldName":"Third Party Tran Description","csvTxtLength":"80","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":60,"sectionName":"60","fieldName":"Third Party User ID","csvTxtLength":"80","fieldType":"String","defaultValue":"GL_UPLOAD","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":61,"sectionName":"61","fieldName":"Transaction Reference Number","csvTxtLength":"80","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":62,"sectionName":"62","fieldName":"Third Party Account Number","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":63,"sectionName":"63","fieldName":"Third Party Account Name","csvTxtLength":"80","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":64,"sectionName":"64","fieldName":"ATM Bank ID","csvTxtLength":"4","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":65,"sectionName":"65","fieldName":"ATM Terminal ID","csvTxtLength":"4","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":66,"sectionName":"66","fieldName":"ATM Card Number","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID"},{"sequence":67,"sectionName":"67","fieldName":"Biller Code","csvTxtLength":"4","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":68,"sectionName":"68","fieldName":"Biller Subscription Number1","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":69,"sectionName":"69","fieldName":"Biller Subscription Number2","csvTxtLength":"40","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":70,"sectionName":"70","fieldName":"TRAN_DATE","csvTxtLength":"10","fieldType":"String","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":71,"sectionName":"71","fieldName":"GROUP_ID","csvTxtLength":"20","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":72,"sectionName":"72","fieldName":"Profit Cost Center Code","csvTxtLength":"16","fieldType":"String","defaultValue":"05510","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":73,"sectionName":"73","fieldName":"OAP Ref Nbr","csvTxtLength":"20","fieldType":"String","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Record Type Indicator","csvTxtLength":"1","fieldType":"String","defaultValue":"T","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"File Hash","csvTxtLength":"32","fieldType":"Decimal","defaultValue":"","fieldFormat":"0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Number of Data Records","csvTxtLength":"13","fieldType":"Number","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":4,"sectionName":"4","fieldName":"Filler","csvTxtLength":"1556","fieldType":"Number","eol":true,"leftJustified":true,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"}]');

	
	i_BODY_QUERY := TO_CLOB('
SELECT 
  "GROUP_ID",
  SUM("Tran Amount") "Tran Amount",
  "BRANCH CODE",
  "A/C Number",
  "Currency Code of Account Number",
  "Reference Currency Code",
  "Part Tran Indicator",
  "Tran Particular",
  "Third Party Tran Description"
FROM (
  SELECT
	  GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
	  TXN.TRL_AMT_TXN "Tran Amount",
	  CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
	  GLA.GLA_NUMBER "A/C Number",
	  ''PHP'' "Currency Code of Account Number",
	  ''PHP'' "Reference Currency Code",
	  ''D'' AS "Part Tran Indicator",
	  GLE.GLE_DEBIT_DESCRIPTION "Tran Particular",
	  GLE.GLE_DEBIT_DESCRIPTION "Third Party Tran Description"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE 
         AND GLE.GLE_TRAN_CHANNEL=''CDM''
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''N''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')       
		 AND GLE.GLE_MAIN_DIRECTION = CASE WHEN TXN.TRL_TSC_CODE = 48 THEN ''INTER-ENTITY''
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME = {V_Iss_Name} THEN ''TRANSMITTING'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_Acqr_Inst_Id} THEN ''RECEIVING'' 
           WHEN TXN.TRL_ISS_NAME ={V_IE_Iss_Name} THEN ''INTER-ENTITY'' 
           WHEN TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) != {V_Acqr_Inst_Id} THEN ''ISSUER''  
           ELSE ''ON-US'' END      
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''CDM'' AND CTR_DEBIT_CREDIT = ''DEBIT''
	WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE NOT IN (45,50,250)
      AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      AND TXN.TRL_DEO_NAME = {V_Deo_Name} 
	  AND {Txn_Date}  
UNION ALL 
SELECT
      GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
	  TXN.TRL_AMT_TXN "Tran Amount",
	  CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
	  GLA.GLA_NUMBER "A/C Number",
	  ''PHP'' "Currency Code of Account Number",
	  ''PHP'' "Reference Currency Code",
	  ''D'' AS "Part Tran Indicator",
	  GLE.GLE_DEBIT_DESCRIPTION "Tran Particular",
	  GLE.GLE_DEBIT_DESCRIPTION "Third Party Tran Description"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE 
         AND GLE.GLE_TRAN_CHANNEL=''CDM''
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''N''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')       
		 AND GLE.GLE_MAIN_DIRECTION = CASE WHEN TXN.TRL_ISS_NAME ={V_IE_Iss_Name} THEN ''INTER-ENTITY'' 
           WHEN TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXN.TRL_ISS_NAME ={V_Iss_Name} THEN ''ON-US'' END
         AND GLE.GLE_BP_INCLUDE = CASE WHEN CBL.CBL_CODE IN (''019'',''063'',''065'',''067'') THEN CBL.CBL_CODE ELSE ''*'' END            
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''CDM''
	WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE IN (50,250) 
      -- CBS include all settlement_type
      AND CBL.CBL_SETTLEMENT_TYPE IN (''AP'', ''WS'')
      AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Iss_Name}
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}  
	  AND {Txn_Date}
UNION ALL 
SELECT
      GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
	  TXN.TRL_AMT_TXN "Tran Amount",
	  CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
	  GLA.GLA_NUMBER "A/C Number",
	  ''PHP'' "Currency Code of Account Number",
	  ''PHP'' "Reference Currency Code",
	  ''C'' AS "Part Tran Indicator",
	  GLE.GLE_DEBIT_DESCRIPTION "Tran Particular",
	  GLE.GLE_DEBIT_DESCRIPTION "Third Party Tran Description"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE 
         AND GLE.GLE_TRAN_CHANNEL=''CDM''
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''N''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')       
		 AND GLE.GLE_MAIN_DIRECTION = CASE WHEN TXN.TRL_TSC_CODE = 48 THEN ''INTER-ENTITY''
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME = {V_Iss_Name} THEN ''TRANSMITTING'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_Acqr_Inst_Id} THEN ''RECEIVING'' 
           WHEN TXN.TRL_ISS_NAME ={V_IE_Iss_Name} THEN ''INTER-ENTITY'' 
           WHEN TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) != {V_Acqr_Inst_Id} THEN ''ISSUER''  
           ELSE ''ON-US'' END      
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''CDM'' AND CTR_DEBIT_CREDIT = ''DEBIT''
	WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE NOT IN (45,50,250)
      AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Iss_Name}
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}  
	  AND {Txn_Date}    
UNION ALL 
SELECT
      GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
	  TXN.TRL_AMT_TXN "Tran Amount",
	  CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE ABR.ABR_CODE END "BRANCH CODE",
	  GLA.GLA_NUMBER "A/C Number",
	  ''PHP'' "Currency Code of Account Number",
	  ''PHP'' "Reference Currency Code",
	  ''C'' AS "Part Tran Indicator",
	  GLE.GLE_DEBIT_DESCRIPTION "Tran Particular",
	  GLE.GLE_DEBIT_DESCRIPTION "Third Party Tran Description"     
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      JOIN CBC_GL_ENTRY GLE ON TXN.TRL_TSC_CODE = GLE.GLE_TRAN_TYPE 
         AND GLE.GLE_TRAN_CHANNEL=''CDM''
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''N''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''Recycler'')       
		 AND GLE.GLE_MAIN_DIRECTION = CASE WHEN TXN.TRL_ISS_NAME ={V_IE_Iss_Name} THEN ''INTER-ENTITY'' 
           WHEN TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXN.TRL_ISS_NAME ={V_Iss_Name} THEN ''ON-US'' END
         AND GLE.GLE_BP_INCLUDE = CASE WHEN CBL.CBL_CODE IN (''019'',''063'',''065'',''067'') THEN CBL.CBL_CODE ELSE ''*'' END              
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''CDM''
	WHERE
      TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_TSC_CODE IN (50,250) 
      -- CBS include all settlement_type
      AND CBL.CBL_SETTLEMENT_TYPE IN (''AP'',''WS'')
      AND NVL(CPD.CPD_CODE,0) NOT IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_ORIGIN_CHANNEL IN (''CDM'',''BRM'')
      AND GLA.GLA_INSTITUTION = {V_Iss_Name}
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}  
	  AND {Txn_Date}
)
  GROUP BY
    "GROUP_ID",
    "BRANCH CODE",
    "A/C Number",
    "Currency Code of Account Number",
    "Part Tran Indicator",
    "Tran Particular",
    "Reference Currency Code",
    "Third Party Tran Description"
ORDER BY    
	  "GROUP_ID",
      "BRANCH CODE",
	  "Part Tran Indicator" DESC
	');	
	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	
END;
/