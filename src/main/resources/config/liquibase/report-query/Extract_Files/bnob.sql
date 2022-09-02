-- Tracking				Date			Name	Description
-- Revised Report		06-JULY-2021	WY		Revised reports based on spec
-- Report revision		23-JUL-2021		NY		Revised reports based on spec
-- Acquirer				06-AUG-2021		NY		Use left join consistently to avoid data mismatch to master s

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 
	
	i_BODY_QUERY := TO_CLOB('				
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      SUM("A/R PER TERMINAL") "A/R PER TERMINAL",
      COUNT("ITEMS") "ITEMS",
      SUM("A/R PER TERMINAL") "TOTAL A/R AMOUNT"
FROM (
SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_AMT_TXN "A/R PER TERMINAL",
      TXN.TRL_ID "ITEMS"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''BNT''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME IS NULL
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})	  
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
)
GROUP BY
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL"
ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC		
	');	
	
	i_TRAILER_QUERY := TO_CLOB('SELECT
      SUM(TXN.TRL_AMT_TXN) "A/R PER TERMINAL",
      COUNT(TXN.TRL_ID) "ITEMS"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''BNT''
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
WHERE
      TXN.TRL_TSC_CODE IN (1, 128)
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_ISS_NAME IS NULL
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})	 
      AND {Txn_Date}
	  ');
	  
	  i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Filler","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"defaultValue":"9999"},{"sequence":2,"sectionName":"2","fieldName":"Filler","csvTxtLength":"46","pdfLength":"46","fieldType":"String","delimiter":"","defaultValue":"TOTAL OF ALL BRANCHES","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"A/R PER TERMINAL","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","delimiter":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"eol":true,"fieldFormat":"#,##0.00"}]');
	
	UPDATE REPORT_DEFINITION SET 
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'BNOB File';
	
END;
/