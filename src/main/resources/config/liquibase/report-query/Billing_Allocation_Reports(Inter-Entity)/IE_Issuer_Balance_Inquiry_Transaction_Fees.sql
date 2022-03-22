-- Tracking				Date			Name	Description
-- Revise report		25-JULY-2021	WY		Revise IE reports based on spec
-- Revise report 		22-AUG-2021		WY		Revise fee amount based on amount sent in Lady's email
-- JIRA 936				25-SEP-2021		WY		Fix blank report generated even with issuer transactions

DECLARE
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	
	
BEGIN 

	i_BODY_QUERY := TO_CLOB('SELECT
     SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
	 ABR.ABR_NAME "BRANCH NAME",
     COUNT(TXN.TRL_ID) "TOTAL COUNT",
     COUNT(TXN.TRL_ID) * 1.00 "TOTAL EXPENSE"
FROM
     TRANSACTION_LOG TXN
     LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
     LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 31
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
      AND {Txn_Date}
GROUP BY
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4),
      ABR.ABR_NAME
ORDER BY
      "BRANCH CODE" ASC
	');	
	
	i_TRAILER_QUERY := TO_CLOB('SELECT
      COUNT(TXN.TRL_ID) "TOTAL COUNT",
      COUNT(TXN.TRL_ID) * 1.00 "TOTAL EXPENSE"
FROM
      TRANSACTION_LOG TXN
WHERE
      TXN.TRL_TSC_CODE = 31
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
       AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_IE_Acqr_Inst_Id})
      AND {Txn_Date}
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Inter-Entity Issuer Balance Inquiry Transaction Fees';
	
END;
/