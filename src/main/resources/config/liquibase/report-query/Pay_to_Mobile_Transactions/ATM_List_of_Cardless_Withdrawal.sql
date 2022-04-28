-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- JIRA 945				27-SEP-2021		WY		Fix report bugs

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'ATM List of Cardless Withdrawal';
    i_BODY_FIELDS CLOB;
	i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- ATM List of Cardless Withdrawal
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},
{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":3,"sectionName":"3","fieldName":"Seq No.","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":4,"sectionName":"4","fieldName":"Trace No.","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":6,"sectionName":"6","fieldName":"Tran Ref No.","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Tran Ref No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":8,"sectionName":"8","fieldName":"ATM Card No.","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},

{"sequence":10,"sectionName":"10","fieldName":"Account Number","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Account Number","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":11,"sectionName":"11","fieldName":"Trans Amount","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Trans Amount","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":12,"sectionName":"12","fieldName":"Trans Fee","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Trans Fee","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":13,"sectionName":"13","fieldName":"Tran Code Remarks","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Tran Code Remarks","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":false,"eol":true},
{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},
{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},
{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},
{"sequence":18,"sectionName":"18","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":19,"sectionName":"19","fieldName":"TRAN REF NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":20,"sectionName":"20","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":21,"sectionName":"21","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},

{"sequence":23,"sectionName":"23","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},
{"sequence":24,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"6","pdfLength":"6","fieldType":"Decimal","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"#,##0.00"},
{"sequence":25,"sectionName":"25","fieldName":"TRAN FEE","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","fieldFormat":"#,##0.00","tagValue":null},
{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},
{"sequence":27,"sectionName":"27","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":28,"sectionName":"28","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":29,"sectionName":"29","fieldName":"NOW","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NOW","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":30,"sectionName":"30","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":31,"sectionName":"31","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":32,"sectionName":"32","fieldName":"JUMP","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"JUMP","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":33,"sectionName":"33","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":34,"sectionName":"34","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":35,"sectionName":"35","fieldName":"SUB-TOTAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SUB-TOTAL","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":36,"sectionName":"36","fieldName":"CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":37,"sectionName":"37","fieldName":"NAME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":38,"sectionName":"38","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":39,"sectionName":"39","fieldName":"AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AMT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":40,"sectionName":"40","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":41,"sectionName":"41","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":42,"sectionName":"42","fieldName":"AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AMT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":43,"sectionName":"43","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":44,"sectionName":"44","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":45,"sectionName":"45","fieldName":"AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AMT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":46,"sectionName":"46","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":47,"sectionName":"47","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":48,"sectionName":"48","fieldName":"BRANCH NAME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":49,"sectionName":"49","fieldName":"NOW VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":50,"sectionName":"50","fieldName":"NOW AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":51,"sectionName":"51","fieldName":"NOW FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":52,"sectionName":"52","fieldName":"JUMP VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":53,"sectionName":"53","fieldName":"JUMP AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":54,"sectionName":"54","fieldName":"JUMP FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":55,"sectionName":"55","fieldName":"TOTAL VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":56,"sectionName":"56","fieldName":"TOTAL AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":57,"sectionName":"57","fieldName":"TOTAL FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"140","pdfLength":"140","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":2,"sectionName":"2","fieldName":"Space2","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","firstField":false,"eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":3,"sectionName":"3","fieldName":"Space3","csvTxtLength":"17","pdfLength":"17","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":4,"sectionName":"4","fieldName":"Space4","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":5,"sectionName":"5","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":6,"sectionName":"6","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":7,"sectionName":"7","fieldName":"Space7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":8,"sectionName":"8","fieldName":"Space8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},

{"sequence":10,"sectionName":"10","fieldName":"TOTAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"TOTAL"},
{"sequence":11,"sectionName":"11","fieldName":"AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":12,"sectionName":"12","fieldName":"TRAN FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true},
{"sequence":13,"sectionName":"13","fieldName":"OVER - ALL AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"OVER - ALL AMT","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":14,"sectionName":"14","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","fieldName":"NOW VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":16,"sectionName":"16","fieldName":"NOW AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":17,"sectionName":"17","fieldName":"NOW FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":18,"sectionName":"18","fieldName":"JUMP VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":19,"sectionName":"19","fieldName":"JUMP AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":20,"sectionName":"20","fieldName":"JUMP FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":21,"sectionName":"21","fieldName":"TOTAL VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":22,"sectionName":"22","fieldName":"TOTAL AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},
{"sequence":23,"sectionName":"23","fieldName":"TOTAL FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');

	i_BODY_QUERY := TO_CLOB('SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      CASE WHEN ABR.ABR_NAME IS NOT NULL THEN ABR.ABR_NAME ELSE BRC.BRC_NAME END AS "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_RRN "TRAN REF NO",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      NVL(TXN.TRL_ISS_CHARGE_AMT, 0) "TRAN FEE",
      CASE 
      WHEN TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = ''0'' THEN ''Full Reversal''
      WHEN TXN.TRL_TQU_ID NOT IN (''R'') AND TXN.TRL_ACTION_RESPONSE_CODE = ''0'' THEN ''''
      ELSE ARC.ARC_NAME END "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
	  LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
WHERE
	  TXN.TRL_TSC_CODE IN (142, 143)
      AND (TXN.TRL_TQU_ID IN (''F'') OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Criteria}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT,
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
      NVL(SUM("NOW AMT"),0) + NVL(SUM("JUMP AMT"),0) "TOTAL AMT",
      NVL(SUM("NOW FEE"),0) + NVL(SUM("JUMP FEE"),0) "TOTAL FEE"
FROM(
      SELECT DISTINCT
            SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
            ABR.ABR_NAME "BRANCH NAME",
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_ID END AS "NOW VOL",
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN TXN.TRL_AMT_TXN END AS "NOW AMT",
            CASE WHEN TXN.TRL_TSC_CODE = 142 THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) END AS "NOW FEE",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_ID END AS "JUMP VOL",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN TXN.TRL_AMT_TXN END AS "JUMP AMT",
            CASE WHEN TXN.TRL_TSC_CODE = 143 THEN NVL(TXN.TRL_ISS_CHARGE_AMT, 0) END AS "JUMP FEE"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	  LEFT JOIN BRANCH ISS_BRC ON TXNC.TRL_CARD_BRANCH  = ISS_BRC.BRC_CODE
	  LEFT JOIN TRANSACTION_LOG TXN_A ON TXN.TRL_RRN = TXN_A.TRL_RRN AND TXN_A.TRL_TQU_ID = ''A''
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC_A ON TXN_A.TRL_ID=TXNC_A.TRL_ID
	  LEFT JOIN BRANCH ISS_BRC_A ON TXNC_A.TRL_CARD_BRANCH  = ISS_BRC_A.BRC_CODE  
WHERE
      TXN.TRL_TSC_CODE IN (142, 143)
      AND TXN.TRL_TQU_ID IN (''F'') 
	  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	  
      AND {Branch_Code}
      AND {Txn_Date}
	  AND {SUMMARY}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME"
ORDER BY
      "BRANCH CODE"
END');

	i_TRAILER_QUERY := TO_CLOB('SELECT
       SUM(TXN.TRL_AMT_TXN) "AMOUNT",
       SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) "TRAN FEE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
	  TXN.TRL_TSC_CODE IN (142, 143)
      AND TXN.TRL_TQU_ID IN (''F'') 
	  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND {Branch_Code}
	  AND {Branch_Name}
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
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
      TXN.TRL_TSC_CODE IN (142, 143)
      AND TXN.TRL_TQU_ID IN (''F'') 
	  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND {Txn_Date}
	  AND {SUMMARY}
)
END');

	UPDATE REPORT_DEFINITION set 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = i_REPORT_NAME;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') WHERE RED_NAME = i_REPORT_NAME AND red_ins_id = 2;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, '0010', '0112') WHERE RED_NAME = i_REPORT_NAME AND red_ins_id = 2;
	
END;
/