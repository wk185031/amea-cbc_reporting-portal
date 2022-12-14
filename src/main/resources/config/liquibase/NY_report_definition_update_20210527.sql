DECLARE
    i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Transaction Count Report
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE","csvTxtLength":"8","fieldType":"Date","defaultValue":"","firstField":true,"bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"MM/dd/yy"},{"sequence":2,"sectionName":"2","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TERMINAL","csvTxtLength":"4","fieldType":"String","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","defaultValue":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"BANK MNEM","csvTxtLength":"3","fieldType":"String","defaultValue":"","fieldFormat":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","fieldFormat":"","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRAN MNEM","csvTxtLength":"3","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"BANK CODE","csvTxtLength":"4","fieldType":"String","bodyHeader":false,"defaultValue":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"32","fieldName":"BILLER MNEM","csvTxtLength":"4","pdfLength":"","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"33","fieldName":"SPACE","csvTxtLength":"2","pdfLength":"","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"11","fieldName":"APPROVED TRAN COUNT","csvTxtLength":"11","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":14,"sectionName":"12","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"13","fieldName":"REJECTED TRAN COUNT","csvTxtLength":"11","fieldType":"Number","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":16,"sectionName":"14","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"15","fieldName":"TOTAL TRAN COUNT","csvTxtLength":"14","fieldType":"Number","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":18,"sectionName":"16","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"17","fieldName":"SHORT DISPENSE COUNT","csvTxtLength":"11","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"18","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"19","fieldName":"NO DISPENSE COUNT","csvTxtLength":"11","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"20","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"21","fieldName":"OVER DISPENSE COUNT","csvTxtLength":"11","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"22","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"23","fieldName":"HARDWARE FAILURE COUNT","csvTxtLength":"11","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"24","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"25","fieldName":"CASH DISPENSED","csvTxtLength":"16","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"26","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"27","fieldName":"DEPOSITS","csvTxtLength":"16","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"28","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"29","fieldName":"BILL PAYMENTS","csvTxtLength":"16","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"30","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"31","fieldName":"TRANSFERS","csvTxtLength":"16","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_BODY_QUERY := TO_CLOB('		
SELECT
      "DATE",
      "TERMINAL",
      "BANK MNEM",
      "TRAN MNEM",
	  "BILLER MNEM",
      "BANK CODE",
      SUM("APPROVED TRAN COUNT") "APPROVED TRAN COUNT",
      SUM("REJECTED TRAN COUNT") "REJECTED TRAN COUNT",
      COUNT("TOTAL TRAN COUNT") "TOTAL TRAN COUNT",
      SUM("SHORT DISP") "SHORT DISPENSE COUNT",
      SUM("NO DISP") "NO DISPENSE COUNT",
      SUM("OVER DISPENSE") "OVER DISPENSE COUNT",
      0 "HARDWARE FAILURE COUNT",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      SUM("DEPOSITS") "DEPOSITS",
      SUM("BILL PAYMENTS") "BILL PAYMENTS",
      SUM("TRANSFERS") "TRANSFERS"
FROM (
SELECT DISTINCT
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      CASE WHEN CBA.CBA_MNEM IS NOT NULL THEN CBA.CBA_MNEM ELSE '''' END AS "BANK MNEM",
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (SELECT CTR_CODE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = ''BNT'')
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT in (''DEBIT'', ''CREDIT'') AND ROWNUM=1)
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_POST_COMPLETION_CODE IS NULL AND TXN.TRL_TSC_CODE IN (SELECT CTR_CODE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = ''BNT'')
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT in (''DEBIT'', ''CREDIT'') AND ROWNUM=1)
	    WHEN TXN.TRL_ISS_NAME IS NOT NULL AND TXN.TRL_POST_COMPLETION_CODE = ''R'' 
	        THEN CTR.CTR_REV_MNEM 
		ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
	  CBL.CBL_MNEM AS "BILLER MNEM",
      CASE WHEN CBA.CBA_CODE IS NOT NULL THEN LPAD(CBA.CBA_CODE, 4, 0) ELSE '''' END AS "BANK CODE",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "APPROVED TRAN COUNT",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "REJECTED TRAN COUNT",
      TXN.TRL_ID "TOTAL TRAN COUNT",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	  LEFT JOIN CBC_BILLER CBL ON CBL.CBL_CODE = TXNC.TRL_BILLER_CODE
WHERE
TXN.TRL_TQU_ID = ''F''
      AND (TXN.TRL_FRD_REV_INST_ID IS NULL OR 
      CASE 
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (SELECT CTR_CODE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = ''BNT'')
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT in (''DEBIT'', ''CREDIT'') AND ROWNUM=1)
	    WHEN TXN.TRL_ISS_NAME IS NULL AND TXN.TRL_POST_COMPLETION_CODE IS NULL AND TXN.TRL_TSC_CODE IN (SELECT CTR_CODE FROM CBC_TRAN_CODE WHERE CTR_CHANNEL = ''BNT'')
	        THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT in (''DEBIT'', ''CREDIT'') AND ROWNUM=1)
	    WHEN TXN.TRL_ISS_NAME IS NOT NULL AND TXN.TRL_POST_COMPLETION_CODE = ''R''
	        THEN CTR.CTR_REV_MNEM 
		  ELSE CTR.CTR_MNEM END != ''BWD'')
	 AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR TXN.TRL_ISS_NAME = {V_Iss_Name})
      AND {Txn_Date}
)
GROUP BY
      "DATE",
      "TERMINAL",
      "BANK MNEM",
      "TRAN MNEM",
	  "BILLER MNEM",
      "BANK CODE"
ORDER BY
      "TRAN MNEM" ASC,
      "TERMINAL" ASC,
      "BANK CODE" ASC
	');
	
	UPDATE REPORT_DEFINITION set RED_BODY_FIELDS = i_BODY_FIELDS,RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Transaction Count Report';
	
END;
/