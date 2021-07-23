-- Tracking				Date			Name	Description
-- Report revision		23-JUL-2021		NY		Initial

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Approved IBFT Transactions as Acquiring Bank
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"APPROVED IBFT TRANSACTIONS AS ACQUIRING BANK","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Name3","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"SUMMARY OF APPROVED IBFT TRANSACTIONS AS ACQUIRING BANK","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"File Name2","csvTxtLength":"51","pdfLength":"51","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"21","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ORIG BANK","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ORIG BANK","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ISSUER/TRANSMITTING BANK","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"ISSUER/TRANSMITTING BANK","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"RECEIVING BANK","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"defaultValue":"RECEIVING BANK","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"MNEM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":" MNEM","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"BRANCH","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"BRANCH","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"TERM ID","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" TERM ID","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" TIME","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NO.","csvTxtLength":"32","pdfLength":"32","fieldType":"String","defaultValue":" SEQ NO.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"CARD NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":" CARD NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"TRAN AMOUNT","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" TRAN AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"MNEM","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" MNEM","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"BRANCH","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ACCOUNT NO.","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"ACCOUNT NO.","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"MNEM","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"MNEM","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"BRANCH","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"ACCOUNT NO.","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"defaultValue":"ACCOUNT NO.","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BRANCH CODE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"SEQ NUMBER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"30","fieldName":"ATM CARD NUMBER","csvTxtLength":"16","pdfLength":"16","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"AMOUNT","csvTxtLength":"23","pdfLength":"23","fieldType":"Decimal","delimiter":";","firstField":false,"fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"ISSUER BANK MNEM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"ISSUER BRANCH NAME","csvTxtLength":"26","pdfLength":"26","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"FROM ACCOUNT NO","csvTxtLength":"24","pdfLength":"24","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"35","fieldName":"RECEIVING BANK MNEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"RECEIVING BRANCH NAME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"TO ACCOUNT NO","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":38,"sectionName":"38","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"IBFT TRANSACTION FEE (6.00/txn)","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"IBFT TRANSACTION FEE (6.00/txn)","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"BRANCH","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"TERM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TERM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":44,"sectionName":"44","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"ONLINE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ONLINE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":47,"sectionName":"47","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":48,"sectionName":"48","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":49,"sectionName":"49","fieldName":"ATM","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"ATM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":50,"sectionName":"50","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":51,"sectionName":"51","fieldName":"TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"Srtring","delimiter":";","defaultValue":"TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":52,"sectionName":"52","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":53,"sectionName":"53","fieldName":"NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":54,"sectionName":"54","fieldName":"NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":55,"sectionName":"55","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":56,"sectionName":"56","fieldName":"RETAIL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"RETAIL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":57,"sectionName":"57","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":58,"sectionName":"58","fieldName":"CORPORATE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"CORPORATE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":59,"sectionName":"59","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":60,"sectionName":"60","fieldName":"RETAIL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"RETAIL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":61,"sectionName":"61","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":62,"sectionName":"62","fieldName":"INC","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"INC","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":63,"sectionName":"63","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":64,"sectionName":"64","fieldName":"TERMINAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":65,"sectionName":"65","fieldName":"BRANCH NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":66,"sectionName":"66","fieldName":"ONLINE RETAIL COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":67,"sectionName":"67","fieldName":"ONLINE RETAIL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":68,"sectionName":"68","fieldName":"ONLINE CORPORATE COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":69,"sectionName":"69","fieldName":"ONLINE CORPORATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":70,"sectionName":"70","fieldName":"ATM RETAIL COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":71,"sectionName":"71","fieldName":"ATM RETAIL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":72,"sectionName":"72","fieldName":"TOTAL COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":73,"sectionName":"73","fieldName":"TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"OVER - ALL TOTAL","csvTxtLength":"28","pdfLength":"28","fieldType":"String","defaultValue":"OVER - ALL TOTAL","firstField":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ONLINE RETAIL COUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"ONLINE RETAIL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"ONLINE CORPORATE COUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"ONLINE CORPORATE","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM RETAIL COUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"ATM RETAIL","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"TOTAL COUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Number","delimiter":";","eol":false,"fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"TOTAL","csvTxtLength":"19","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_BODY_QUERY := TO_CLOB('
SELECT
      ''CBC'' AS "ACQUIRER BANK MNEM",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      {Field_Criteria}
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      {Join_Criteria}
WHERE
      TXN.TRL_TSC_CODE = 44
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = ''0000000010''
      AND {IBFT_Criteria}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      "ONLINE RETAIL COUNT",
      "ONLINE RETAIL",
      "ONLINE CORPORATE COUNT",
      "ONLINE CORPORATE",
      "ATM RETAIL COUNT",
      "ATM RETAIL",
      "TOTAL COUNT",
      SUM("ONLINE RETAIL" + "ONLINE CORPORATE" + "ATM RETAIL") "TOTAL"
FROM(
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL COUNT",
      6.00 * COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL",
      COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE COUNT",
      6.00 * COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE",
      COUNT("ATM RETAIL COUNT") "ATM RETAIL COUNT",
      6.00 * COUNT("ATM RETAIL COUNT") "ATM RETAIL",
      SUM(NVL("ONLINE RETAIL COUNT", 0) + NVL("ONLINE CORPORATE COUNT", 0) + NVL("ATM RETAIL COUNT", 0)) "TOTAL COUNT"
FROM (
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      CASE WHEN TXN.TRL_ISS_NAME = ''CBC'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000000112'' AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971'' THEN 1 END AS "ONLINE RETAIL COUNT",
      CASE WHEN LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000000112'' AND TXN.TRL_PAN = ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971'' THEN 1  END AS "ONLINE CORPORATE COUNT",
      CASE WHEN TXN.TRL_ISS_NAME = ''CBC'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000000112'' THEN 1
               WHEN TXN.TRL_ISS_NAME IS NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = ''0000000010'' THEN 1
               WHEN TXN.TRL_ISS_NAME IS NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') NOT IN (''0000000010'', ''0000000112'') THEN 1
      END AS "ATM RETAIL COUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 44
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
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
      "ONLINE RETAIL COUNT",
      "ONLINE RETAIL",
      "ONLINE CORPORATE COUNT",
      "ONLINE CORPORATE",
      "ATM RETAIL COUNT",
      "ATM RETAIL",
      "TOTAL COUNT"
ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC
END
	');	
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      "ONLINE RETAIL COUNT",
      "ONLINE RETAIL",
      "ONLINE CORPORATE COUNT",
      "ONLINE CORPORATE",
      "ATM RETAIL COUNT",
      "ATM RETAIL",
      "TOTAL COUNT",
      SUM("ONLINE RETAIL" + "ONLINE CORPORATE" + "ATM RETAIL") "TOTAL"
FROM(
SELECT
      COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL COUNT",
      6.00 * COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL",
      COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE COUNT",
      6.00 * COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE",
      COUNT("ATM RETAIL COUNT") "ATM RETAIL COUNT",
      6.00 * COUNT("ATM RETAIL COUNT") "ATM RETAIL",
      SUM(NVL("ONLINE RETAIL COUNT", 0) + NVL("ONLINE CORPORATE COUNT", 0) + NVL("ATM RETAIL COUNT", 0)) "TOTAL COUNT"
FROM (
SELECT
      CASE WHEN TXN.TRL_ISS_NAME = ''CBC'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000000112'' AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971'' THEN 1 END AS "ONLINE RETAIL COUNT",
      CASE WHEN LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000000112'' AND TXN.TRL_PAN = ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971'' THEN 1  END AS "ONLINE CORPORATE COUNT",
      CASE WHEN TXN.TRL_ISS_NAME = ''CBC'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000000112'' THEN 1
               WHEN TXN.TRL_ISS_NAME IS NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = ''0000000010'' THEN 1
               WHEN TXN.TRL_ISS_NAME IS NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') NOT IN (''0000000010'', ''0000000112'') THEN 1
      END AS "ATM RETAIL COUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 44
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Txn_Date}
))
GROUP BY
      "ONLINE RETAIL COUNT",
      "ONLINE RETAIL",
      "ONLINE CORPORATE COUNT",
      "ONLINE CORPORATE",
      "ATM RETAIL COUNT",
      "ATM RETAIL",
      "TOTAL COUNT"	
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Approved IBFT Transactions as Acquiring Bank';
	
END;
/