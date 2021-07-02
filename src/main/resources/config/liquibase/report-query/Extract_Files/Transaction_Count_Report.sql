-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-688	29-JUN-2021		NY		Initial config from UAT environment
-- CBCAXUPISSLOG-663	29-JUN-2021		WY		Change terminal number to 9999 and bank mnem refers to acquiring bank name for issuing tran
-- CBCAXUPISSLOG-688	30-JUN-2021		NY		Update query following excel spec
-- CBCAXUPISSLOG-688	30-JUN-2021		NY		Adding back tsc code 41, populate 0 count for short dispense
-- CBCAXUPISSLOG-688	01-JUL-2021		NY		Fix redundant row, catch inter-entity txn accordingly

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Transaction Count Report
	i_HEADER_FIELDS := TO_CLOB('[]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE","csvTxtLength":"8","fieldType":"Date","defaultValue":"","firstField":true,"bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"MM/dd/yy"},{"sequence":2,"sectionName":"2","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TERMINAL","csvTxtLength":"4","fieldType":"String","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","defaultValue":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"BANK MNEM","csvTxtLength":"3","fieldType":"String","defaultValue":"","fieldFormat":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","fieldFormat":"","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRAN MNEM","csvTxtLength":"3","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"BANK CODE","csvTxtLength":"4","fieldType":"String","bodyHeader":false,"defaultValue":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"32","fieldName":"BILLER MNEM","csvTxtLength":"4","pdfLength":"","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"33","fieldName":"SPACE","csvTxtLength":"2","pdfLength":"","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"11","fieldName":"APPROVED TRAN COUNT","csvTxtLength":"11","fieldType":"Number","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":14,"sectionName":"12","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","bodyHeader":false,"defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"13","fieldName":"REJECTED TRAN COUNT","csvTxtLength":"11","fieldType":"Number","bodyHeader":false,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":16,"sectionName":"14","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","defaultValue":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"15","fieldName":"TOTAL TRAN COUNT","csvTxtLength":"14","fieldType":"Number","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":18,"sectionName":"16","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"17","fieldName":"SHORT DISPENSE COUNT","csvTxtLength":"11","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"18","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"19","fieldName":"NO DISPENSE COUNT","csvTxtLength":"11","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"20","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"21","fieldName":"OVER DISPENSE COUNT","csvTxtLength":"11","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"22","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"23","fieldName":"HARDWARE FAILURE COUNT","csvTxtLength":"11","fieldType":"Number","delimiter":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"24","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"25","fieldName":"CASH DISPENSED","csvTxtLength":"16","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"26","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"27","fieldName":"DEPOSITS","csvTxtLength":"16","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"28","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"29","fieldName":"BILL PAYMENTS","csvTxtLength":"16","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"30","fieldName":"SPACE","csvTxtLength":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"31","fieldName":"TRANSFERS","csvTxtLength":"16","fieldType":"Decimal","delimiter":"","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELDS := TO_CLOB('[]');
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
      0 "SHORT DISPENSE COUNT",
      SUM("NO DISP") "NO DISPENSE COUNT",
      SUM("OVER DISPENSE") "OVER DISPENSE COUNT",
      0 "HARDWARE FAILURE COUNT",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      SUM("DEPOSITS") "DEPOSITS",
      SUM("BILL PAYMENTS") "BILL PAYMENTS",
      SUM("TRANSFERS") "TRANSFERS"
FROM (
SELECT DISTINCT
      TO_CHAR(TXN.TRL_DATETIME_LOCAL_TXN, ''yyyy-mm-dd'') "DATE", 
	  SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) AS "TERMINAL",
      CASE WHEN CBA.CBA_MNEM IS NOT NULL THEN CBA.CBA_MNEM ELSE '''' END AS "BANK MNEM",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
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
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE CTR.CTR_CHANNEL END)
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
	  LEFT JOIN CBC_BILLER CBL ON CBL.CBL_CODE = TXNC.TRL_BILLER_CODE
WHERE
	  TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR CBA_ACQ.CBA_MNEM = {V_Acq_Name})
      AND {Txn_Date}
UNION ALL
SELECT DISTINCT
      TO_CHAR(TXN.TRL_DATETIME_LOCAL_TXN, ''yyyy-mm-dd'') "DATE", 
	  CASE 
		WHEN TXN.TRL_ISS_NAME = {V_Iss_Name} AND CBA_ACQ.CBA_MNEM != {V_Acq_Name} THEN ''9999''			
		ELSE 
			SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) END AS "TERMINAL",
      CASE WHEN CBA.CBA_MNEM IS NOT NULL THEN CBA.CBA_MNEM ELSE '''' END AS "BANK MNEM",
      CASE 
	    WHEN TRL_TQU_ID = ''R''
	        THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    ELSE (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	   END AS "TRAN MNEM",
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
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE CTR.CTR_CHANNEL END)
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
	  LEFT JOIN CBC_BILLER CBL ON CBL.CBL_CODE = TXNC.TRL_BILLER_CODE
WHERE
	  TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME != {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR CBA_ACQ.CBA_MNEM = {V_Acq_Name})
      AND {Txn_Date}
UNION ALL
SELECT DISTINCT
      TO_CHAR(TXN.TRL_DATETIME_LOCAL_TXN, ''yyyy-mm-dd'') "DATE", 
	  CASE 
		WHEN TXN.TRL_ISS_NAME = {V_Iss_Name} AND CBA_ACQ.CBA_MNEM != {V_Acq_Name} THEN ''9999''				
		ELSE 
			SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) END AS "TERMINAL",
      CASE WHEN CBA.CBA_MNEM IS NOT NULL THEN CBA.CBA_MNEM ELSE '''' END AS "BANK MNEM",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
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
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
	  LEFT JOIN CBC_BILLER CBL ON CBL.CBL_CODE = TXNC.TRL_BILLER_CODE
WHERE
	  TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND CBA_ACQ.CBA_MNEM != {V_Acq_Name}
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
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Transaction Count Report';
	
END;
/