-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-688	29-JUN-2021		NY		Initial config from UAT environment
-- CBCAXUPISSLOG-688	30-JUN-2021		NY		Update query following excel spec
-- CBCAXUPISSLOG-688	30-JUN-2021		NY		Fix missing condition
-- CBCAXUPISSLOG-688	01-JUL-2021		NY		Fix redundant row, catch inter-entity txn accordingly
-- CBCAXUPISSLOG-688	05-JUL-2021		NY		Fix recycler not showing on verification
-- CBCAXUPISSLOG-766	07-JUL-2021		NY		Exclude IBFT/Eload request ie 44/52 from acquirer/onus report, include IBFT withdrawal 01
-- CBCAXUPISSLOG-546	07-JUL-2021		NY		Correct tran mnem for IBFT withdrawal BTD/BTR
-- CBCAXUPISSLOG-766	12-JUL-2021		NY		Fix missing acquirer txn in report
-- CBCAXUPISSLOG-767	12-JUL-2021		NY		Fix reversal count into correct column

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- ATM Transaction List (Summary)
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"54","pdfLength":"54","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"56","pdfLength":"56","fieldType":"String","delimiter":";","defaultValue":"ATM TRANSACTION LIST SUMMARY","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"21","fieldName":"Space1","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"22","fieldName":"Space2","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"23","fieldName":"Space3","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"24","fieldName":"Space4","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"8","fieldName":"Space1","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"9","fieldName":"Space2","csvTxtLength":"69","pdfLength":"69","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"10","fieldName":"Space3","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"13","fieldName":"EFP001-03","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","defaultValue":"EFP001-03","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"14","fieldName":"Space4","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"15","fieldName":"Space5","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"16","fieldName":"Space6","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TRAN","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TRAN MNEM","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"APPROVED","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"APPROVED TRANSACT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"REJECTED","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"REJECTED TRANSACT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"TOTAL","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"TOTAL TRANSACT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"SHORT DISP/","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"SHORT DISP/ PART. REV","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"NO DISP/","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"NO DISP/ FULL REV","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"OVER","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"OVER DISPENSE","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"HARDWARE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","delimiter":";","defaultValue":"HARDWARE FAILURE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"CASH","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","defaultValue":"CASH DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"DEPOSITS/","csvTxtLength":"16","pdfLength":"16","fieldType":"String","delimiter":";","defaultValue":"DEPOSITS/ CHECK REQ","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"BILL PAYMENT/","csvTxtLength":"17","pdfLength":"17","fieldType":"String","delimiter":";","defaultValue":"BILL PAYMENT/ LOAN PAYMENT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TRANSFERS","csvTxtLength":"17","pdfLength":"17","fieldType":"String","delimiter":";","defaultValue":"TRANSFERS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"MNEM","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"TRANSACT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"TRANSACT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","fieldName":"TRANSACT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"TRANSACT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"TRANSACT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"TRANSACT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":17,"sectionName":"17","fieldName":"PART. REV","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","defaultValue":"PART. REV","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":18,"sectionName":"18","fieldName":"FULL REV","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"FULL REV","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":19,"sectionName":"19","fieldName":"DISPENSE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"DISPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":20,"sectionName":"20","fieldName":"FAILURE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"FAILURE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":21,"sectionName":"21","fieldName":"DISPENSED","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"DISPENSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":22,"sectionName":"22","fieldName":"CHECK REQ","csvTxtLength":"17","pdfLength":"17","fieldType":"String","delimiter":";","defaultValue":"CHECK REQ","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":23,"sectionName":"23","fieldName":"LOAN PAYMENT","csvTxtLength":"17","pdfLength":"17","fieldType":"String","delimiter":";","defaultValue":"LOAN PAYMENT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":24,"sectionName":"25","fieldName":"TRAN MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":25,"sectionName":"26","fieldName":"GOOD TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":26,"sectionName":"27","fieldName":"BAD TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":27,"sectionName":"28","fieldName":"TOTAL TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":28,"sectionName":"29","fieldName":"SHORT DISP","csvTxtLength":"11","pdfLength":"11","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":29,"sectionName":"30","fieldName":"NO DISP","csvTxtLength":"11","pdfLength":"11","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":30,"sectionName":"36","fieldName":"OVER DISPENSE","csvTxtLength":"11","pdfLength":"11","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":31,"sectionName":"37","fieldName":"HARDWARE FAILURE","csvTxtLength":"11","pdfLength":"11","fieldType":"Number","delimiter":";","defaultValue":"","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":32,"sectionName":"31","fieldName":"CASH DISPENSED","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":33,"sectionName":"32","fieldName":"DEPOSITS","csvTxtLength":"17","pdfLength":"17","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":34,"sectionName":"33","fieldName":"BILL/INS PAYMENTS","csvTxtLength":"17","pdfLength":"17","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":35,"sectionName":"35","fieldName":"TRANSFERS","csvTxtLength":"17","pdfLength":"17","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","delimiter":";","firstField":true,"eol":true,"defaultValue":"_","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"GOOD TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"BAD TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"TOTAL TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"SHORT DISP","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"NO DISP","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"OVER DISPENSE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"HARDWARE FAILURE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"CASH DISPENSED","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"DEPOSITS","csvTxtLength":"17","pdfLength":"17","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"BILL/INS PAYMENTS","csvTxtLength":"17","pdfLength":"17","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"TRANSFERS","csvTxtLength":"17","pdfLength":"17","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_BODY_QUERY := TO_CLOB('
SELECT
      "TRAN MNEM",
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("OVER DISPENSE") "OVER DISPENSE",
      0 "HARDWARE FAILURE",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      SUM("DEPOSITS") "DEPOSITS",
      SUM("BILL/INS PAYMENTS") "BILL/INS PAYMENTS",
      SUM("TRANSFERS") "TRANSFERS"
	FROM (
    -- Onus (exclude Transfer)
	SELECT DISTINCT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL 
      AND TXN.TRL_TSC_CODE NOT IN (40, 42, 43, 44, 52)
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
    UNION ALL
	-- Onus Transfer (debit)
    SELECT DISTINCT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 52)
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}	
    UNION ALL
	-- Onus Transfer (credit)
    SELECT DISTINCT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 52)
      AND CTR.CTR_DEBIT_CREDIT = ''CREDIT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
	)
	GROUP BY
      "TRAN MNEM"
	ORDER BY
      "TRAN MNEM" ASC
	START ACQ SELECT 
      "TRAN MNEM",
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("OVER DISPENSE") "OVER DISPENSE",
      0 "HARDWARE FAILURE",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      SUM("DEPOSITS") "DEPOSITS",
      SUM("BILL/INS PAYMENTS") "BILL/INS PAYMENTS",
      SUM("TRANSFERS") "TRANSFERS"
	FROM (
	SELECT DISTINCT
      -- Acquirer (exclude Transfer)
      CASE 
	    WHEN TRL_TQU_ID = ''R'' THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    ELSE (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	   END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	  JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_ACQ.CBA_CODE, 10, ''0'')
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL 
      AND TXN.TRL_TSC_CODE NOT IN (40, 42, 43, 44, 52)
      AND TXN.TRL_ISS_NAME IS NULL
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
    UNION ALL
	-- Acquirer Transfer (debit)
	SELECT DISTINCT
      CASE 
	    WHEN TRL_TQU_ID = ''R'' THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    ELSE (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') 
	   END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	  LEFT JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_ACQ.CBA_CODE, 10, ''0'')
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 52)
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND TXN.TRL_ISS_NAME IS NULL
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}	 	  
	)	
	GROUP BY
      "TRAN MNEM"
	ORDER BY
      "TRAN MNEM" ASC
	 END ACQ
	START ISS SELECT 
      "TRAN MNEM",
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("OVER DISPENSE") "OVER DISPENSE",
      0 "HARDWARE FAILURE",
      SUM("CASH DISPENSED") "CASH DISPENSED",
      SUM("DEPOSITS") "DEPOSITS",
      SUM("BILL/INS PAYMENTS") "BILL/INS PAYMENTS",
      SUM("TRANSFERS") "TRANSFERS"
	FROM (
    -- Issuer (exclude Transfer)
	SELECT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL 
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL 
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id}) 
      AND {Txn_Date}
    UNION ALL
	-- Issuer Transfer (debit)
    SELECT
       CASE 
        WHEN TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_TSC_CODE = 1 THEN ''BTR''
        WHEN TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_TSC_CODE = 1 THEN ''BTD''
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL 
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id}) 
      AND {Txn_Date}
    UNION ALL
	-- Issuer Transfer (credit)
    SELECT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL 
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL 
      AND CTR.CTR_DEBIT_CREDIT = ''CREDIT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id}) 
      AND {Txn_Date}
	)
	GROUP BY
      "TRAN MNEM"
	ORDER BY
      "TRAN MNEM" ASC
	END	
	');	
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("OVER DISPENSE") "OVER DISPENSE",
      0 "HARDWARE FAILURE",
      SUM("CASH DISPENSED" - "CASH DISP REV") "CASH DISPENSED",
      SUM("DEPOSITS" - "DEPOSITS REV") "DEPOSITS",
      SUM("BILL/INS PAYMENTS" - "BP REV") "BILL/INS PAYMENTS",
      SUM("TRANSFERS" - "TRANSFERS REV") "TRANSFERS"
	FROM (
    -- Onus (exclude Transfer)
	SELECT DISTINCT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS REV",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL 
      AND TXN.TRL_TSC_CODE NOT IN (40, 42, 43, 44, 52)
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
    UNION ALL
    -- Onus Transfer (credit)
    SELECT DISTINCT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS REV",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 52)
      AND CTR.CTR_DEBIT_CREDIT = ''CREDIT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
	)
	START ACQ SELECT
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("OVER DISPENSE") "OVER DISPENSE",
      0 "HARDWARE FAILURE",
      SUM("CASH DISPENSED" - "CASH DISP REV") "CASH DISPENSED",
      SUM("DEPOSITS" - "DEPOSITS REV") "DEPOSITS",
      SUM("BILL/INS PAYMENTS" - "BP REV") "BILL/INS PAYMENTS",
      SUM("TRANSFERS" - "TRANSFERS REV") "TRANSFERS"
	FROM (
    -- Acquirer (exclude Transfer)
	SELECT DISTINCT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS REV",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL 
      AND TXN.TRL_TSC_CODE NOT IN (40, 42, 43, 44, 52)
      AND CTR.CTR_CHANNEL = ''BNT''
      AND TXN.TRL_ISS_NAME IS NULL
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
    UNION ALL
    -- Acquirer Transfer (debit)
    SELECT DISTINCT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS REV",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 52)
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND TXN.TRL_ISS_NAME IS NULL
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
	  )
	  END ACQ
	  START ISS SELECT 
      SUM("GOOD TRANS") "GOOD TRANS",
      SUM("BAD TRANS") "BAD TRANS",
      COUNT("TOTAL TRANS") "TOTAL TRANS",
      0 "SHORT DISP",
      SUM("NO DISP") "NO DISP",
      SUM("OVER DISPENSE") "OVER DISPENSE",
      0 "HARDWARE FAILURE",
      SUM("CASH DISPENSED" - "CASH DISP REV") "CASH DISPENSED",
      SUM("DEPOSITS" - "DEPOSITS REV") "DEPOSITS",
      SUM("BILL/INS PAYMENTS" - "BP REV") "BILL/INS PAYMENTS",
      SUM("TRANSFERS" - "TRANSFERS REV") "TRANSFERS"
	FROM (
    -- Issuer (exclude Transfer)
	SELECT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS REV",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_ACQ.CBA_CODE, 10, ''0'')
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND {Txn_Date}
    UNION ALL
    -- Issuer Transfer (debit)
    SELECT
      CASE 
        WHEN TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_TSC_CODE = 1 THEN ''BTR''
        WHEN TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_TSC_CODE = 1 THEN ''BTD''
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID= ''R'' THEN 1 ELSE 0 END AS "NO DISP",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS REV",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_ACQ.CBA_CODE, 10, ''0'')
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL 
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND {Txn_Date}
    UNION ALL
    -- Issuer Transfer (credit)
    SELECT
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED < TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "SHORT DISP",
      CASE WHEN TXN.TRL_POST_COMPLETION_CODE is null AND TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_AMT_COMPLETED > TXN.TRL_AMT_TXN THEN 1 ELSE 0 END AS "OVER DISPENSE",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "GOOD TRANS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE > 0 THEN 1 ELSE 0 END AS "BAD TRANS",
      TXN.TRL_ID "TOTAL TRANS",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN 1 ELSE 0 END AS "NO DISP",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BP REV",
	  CASE WHEN TXN.TRL_POST_COMPLETION_CODE = ''R'' AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS REV",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (1, 128, 142, 143) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "CASH DISPENSED",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (21, 24, 26, 122) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "DEPOSITS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (50, 133) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "BILL/INS PAYMENTS",
      CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 AND TXN.TRL_TSC_CODE IN (40, 41, 42, 43, 44, 45, 46, 47, 52) THEN TXN.TRL_AMT_TXN ELSE 0 END AS "TRANSFERS"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_ACQ.CBA_CODE, 10, ''0'')
	WHERE
      TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL 
      AND CTR.CTR_DEBIT_CREDIT = ''CREDIT''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND {Txn_Date}
	)
	END
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM Transaction List (Summary)';
	
END;
/