DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- ATM List of Beep Payments
i_HEADER_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"ATM LIST OF BEEP PAYMENTS REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"21","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"csvTxtLength":"10","pdfLength":"10","defaultValue":""},{"sequence":9,"sectionName":"22","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"csvTxtLength":"10","pdfLength":"10","defaultValue":""},{"sequence":10,"sectionName":"23","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"csvTxtLength":"10","pdfLength":"10","defaultValue":"","eol":true},{"sequence":11,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"101","pdfLength":"101","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"13","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"14","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]
');

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No.","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No.","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Beep Ref No.","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Beep Ref No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No.","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Beep Card No.","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Beep Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Account Number","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account Number","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Trans Amount","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Trans Amount","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Trans Fee","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Trans Fee","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Tran Code Remarks","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Tran Code Remarks","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":false,"eol":true},{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"4","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"BEEP REF NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"BEEP CARD NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"CBC143"},{"sequence":23,"sectionName":"23","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"6","pdfLength":"6","fieldType":"Decimal","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"#,##0.00"},{"sequence":25,"sectionName":"25","fieldName":"TRAN FEE","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","fieldFormat":"#,##0.00","tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
');

i_TRAILER_QUERY := TO_CLOB('
SELECT
       SUM(TXN.TRL_AMT_TXN) "AMOUNT",
       SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) "TRAN FEE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 146
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE = ''ATM''
      AND {Branch_Code}
      AND {Txn_Date}
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR TXN.TRL_ISS_NAME = {V_Iss_Name})	
');

i_BODY_QUERY := TO_CLOB('
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_RRN "BEEP REF NO",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_CUSTOM_DATA "BEEP CARD NO",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ISS_CHARGE_AMT "TRAN FEE",
      ''00 - Approved'' "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 146
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE = ''ATM''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR TXN.TRL_ISS_NAME = {V_Iss_Name})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
');
  
UPDATE REPORT_DEFINITION SET RED_HEADER_FIELDS=i_HEADER_FIELD, RED_BODY_FIELDS=i_BODY_FIELD, RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY=i_TRAILER_QUERY WHERE RED_NAME = 'ATM List of Beep Payments';


-- ATM List of Beep Inquiry
i_HEADER_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"ATM LIST OF BEEP INQUIRY REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"101","pdfLength":"101","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]
');

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No.","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No.","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Beep Ref No.","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Beep Ref No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No.","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Beep Card No.","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Beep Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Account Number","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account Number","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Trans Fee (DR)","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Trans Fee (DR)","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Trans Fee (CR)","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Trans Fee (CR)","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Tran Code Remarks","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Tran Code Remarks","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":false,"eol":true},{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"4","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"BEEP REF NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"BEEP CARD NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"CBC143"},{"sequence":23,"sectionName":"23","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"24","fieldName":"TRAN FEE DR","csvTxtLength":"6","pdfLength":"6","fieldType":"Decimal","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"#,##0.00"},{"sequence":25,"sectionName":"25","fieldName":"TRAN FEE CR","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","fieldFormat":"#,##0.00","tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
');

i_TRAILER_QUERY := TO_CLOB('
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
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 145
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE = ''ATM''
      AND (TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_DEO_NAME = {V_Deo_Name})
      AND {Branch_Code}
      AND {Txn_Date})	
');

i_BODY_QUERY := TO_CLOB('
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
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
      ''00 - Approved'' "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 145
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE = ''ATM''
      AND (TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_DEO_NAME = {V_Deo_Name})
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
');
  
UPDATE REPORT_DEFINITION SET RED_HEADER_FIELDS=i_HEADER_FIELD, RED_BODY_FIELDS=i_BODY_FIELD, RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY=i_TRAILER_QUERY WHERE RED_NAME = 'ATM List of Beep Inquiry';

-- ATM List of Cardless Withdrawal
i_HEADER_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"ATM LIST OF CARDLESS WITHDRAWAL REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Name2","csvTxtLength":"54","pdfLength":"54","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ATM SUMMARY OF CARDLESS WITHDRAWAL REPORT","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"101","pdfLength":"101","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"21","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]
');

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No.","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No.","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Beep Ref No.","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Beep Ref No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No.","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Beep Card No.","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Beep Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Account Number","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account Number","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Trans Amount","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Trans Amount","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Trans Fee","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Trans Fee","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Tran Code Remarks","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Tran Code Remarks","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":false,"eol":true},{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"4","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"BEEP REF NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"BEEP CARD NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"CBC143"},{"sequence":23,"sectionName":"23","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"6","pdfLength":"6","fieldType":"Decimal","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"#,##0.00"},{"sequence":25,"sectionName":"25","fieldName":"TRAN FEE","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","fieldFormat":"#,##0.00","tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"28","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"29","fieldName":"NOW","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NOW","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"30","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"31","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"32","fieldName":"JUMP","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"JUMP","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"33","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":34,"sectionName":"34","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":35,"sectionName":"35","fieldName":"SUB-TOTAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SUB-TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"36","fieldName":"CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":37,"sectionName":"37","fieldName":"NAME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":38,"sectionName":"38","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":39,"sectionName":"39","fieldName":"AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AMT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":40,"sectionName":"40","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":41,"sectionName":"41","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":42,"sectionName":"42","fieldName":"AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AMT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":43,"sectionName":"43","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":44,"sectionName":"44","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":45,"sectionName":"45","fieldName":"AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AMT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":46,"sectionName":"46","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":47,"sectionName":"47","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":48,"sectionName":"48","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":49,"sectionName":"49","fieldName":"NOW VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":50,"sectionName":"50","fieldName":"NOW AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":51,"sectionName":"51","fieldName":"NOW FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":52,"sectionName":"52","fieldName":"JUMP VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":53,"sectionName":"53","fieldName":"JUMP AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":54,"sectionName":"54","fieldName":"JUMP FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":55,"sectionName":"55","fieldName":"TOTAL VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":56,"sectionName":"56","fieldName":"TOTAL AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":57,"sectionName":"57","fieldName":"TOTAL FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]
');

i_TRAILER_QUERY := TO_CLOB('
SELECT
       SUM(TXN.TRL_AMT_TXN) "AMOUNT",
       SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) "TRAN FEE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_DEO_NAME = {V_Deo_Name})
      AND {Branch_Code}
      AND {Txn_Criteria}
      AND {Txn_Date}
START SELECT
      COUNT("NOW VOL") "NOW VOL",
      SUM("NOW AMT") "NOW AMT",
      SUM("NOW FEE") "NOW FEE",
      COUNT("JUMP VOL") "JUMP VOL",
      SUM("JUMP AMT") "JUMP AMT",
      SUM("JUMP FEE") "JUMP FEE",
      COUNT("NOW VOL") + COUNT("JUMP VOL") "TOTAL VOL",
      SUM("NOW AMT") + SUM("JUMP AMT") "TOTAL AMT",
      SUM("NOW FEE") + SUM("JUMP FEE") "TOTAL FEE"
FROM(
      SELECT
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_ID END AS "NOW VOL",
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_AMT_TXN END AS "NOW AMT",
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) END AS "NOW FEE",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_ID END AS "JUMP VOL",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_AMT_TXN END AS "JUMP AMT",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) END AS "JUMP FEE"
FROM
      TRANSACTION_LOG TXN
WHERE
      TXN.TRL_TSC_CODE IN (142, 143)
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_DEO_NAME = {V_Deo_Name})
      AND {Txn_Date}
)
END
');

i_BODY_QUERY := TO_CLOB('
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_RRN "BEEP REF NO",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_CUSTOM_DATA "BEEP CARD NO",
	  TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      NVL(TXN.TRL_ISS_CHARGE_AMT, 0) "TRAN FEE",
      ''00 - Approved'' "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_DEO_NAME = {V_Deo_Name})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Criteria}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
START SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      COUNT("NOW VOL") "NOW VOL",
      SUM("NOW AMT") "NOW AMT",
      SUM("NOW FEE") "NOW FEE",
      COUNT("JUMP VOL") "JUMP VOL",
      SUM("JUMP AMT") "JUMP AMT",
      SUM("JUMP FEE") "JUMP FEE",
      COUNT("NOW VOL") + COUNT("JUMP VOL") "TOTAL VOL",
      SUM("NOW AMT") + SUM("JUMP AMT") "TOTAL AMT",
      SUM("NOW FEE") + SUM("JUMP FEE") "TOTAL FEE"
FROM(
      SELECT
            {Branch_Code} "BRANCH CODE",
            {Branch_Name} "BRANCH NAME",
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_ID END AS "NOW VOL",
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_AMT_TXN END AS "NOW AMT",
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) END AS "NOW FEE",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_ID END AS "JUMP VOL",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_AMT_TXN END AS "JUMP AMT",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) END AS "JUMP FEE"
FROM
      TRANSACTION_LOG TXN
      {Join_Criteria}
WHERE
      TXN.TRL_TSC_CODE IN (142, 143)
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_ISS_NAME = {V_Iss_Name} AND TXN.TRL_DEO_NAME = {V_Deo_Name})
      AND {Branch_Code}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME"
ORDER BY
      "BRANCH CODE"
END
');

UPDATE REPORT_DEFINITION SET RED_HEADER_FIELDS=i_HEADER_FIELD, RED_BODY_FIELDS=i_BODY_FIELD, RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY=i_TRAILER_QUERY WHERE RED_NAME = 'ATM List of Cardless Withdrawal';

-- CAM List of Beep Payments
i_HEADER_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"CAM LIST OF BEEP PAYMENTS REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"21","fieldName":"EMPTY","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"22","fieldName":"EMPTY","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"23","fieldName":"EMPTY","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"101","pdfLength":"101","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"13","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"14","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"16","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]
');

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No.","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No.","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Beep Ref No.","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Beep Ref No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No.","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Beep Card No.","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Beep Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Account Number","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account Number","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Trans Amount","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Trans Amount","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Trans Fee","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Trans Fee","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Tran Code Remarks","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Tran Code Remarks","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":false,"eol":true},{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"4","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"BEEP REF NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"BEEP CARD NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"TRL_CUSTOM_DATA_EKY_ID","tagValue":"CBC143"},{"sequence":23,"sectionName":"23","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"6","pdfLength":"6","fieldType":"Decimal","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"#,##0.00"},{"sequence":25,"sectionName":"25","fieldName":"TRAN FEE","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","fieldFormat":"#,##0.00","tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]
');

i_TRAILER_QUERY := TO_CLOB('
SELECT
       SUM(TXN.TRL_AMT_TXN) "AMOUNT",
       SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) "TRAN FEE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 146
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE IN (''CDM'',''BRM'')
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR TXN.TRL_ISS_NAME = {V_Iss_Name})
      AND {Branch_Code}
      AND {Txn_Date}
');

i_BODY_QUERY := TO_CLOB('
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_RRN "BEEP REF NO",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_CUSTOM_DATA "BEEP CARD NO",
      TXN.TRL_CUSTOM_DATA_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ISS_CHARGE_AMT "TRAN FEE",
      ''00 - Approved'' "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 146
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND AST.AST_TERMINAL_TYPE IN (''CDM'',''BRM'')
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR TXN.TRL_ISS_NAME = {V_Iss_Name})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
');

UPDATE REPORT_DEFINITION SET RED_HEADER_FIELDS=i_HEADER_FIELD, RED_BODY_FIELDS=i_BODY_FIELD, RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY=i_TRAILER_QUERY WHERE RED_NAME = 'CAM List of Beep Payments';

END;
/