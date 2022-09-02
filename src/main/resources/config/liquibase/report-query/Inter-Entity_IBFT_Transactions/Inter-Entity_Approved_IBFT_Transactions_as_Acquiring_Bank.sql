-- Tracking				Date			Name	Description
-- Revise report		29-JULY-2021	WY		Revise report based on spec

DECLARE
    i_HEADER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"APPROVED IBFT TRANSACTIONS AS ACQUIRING BANK","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Name3","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"SUMMARY OF APPROVED IBFT TRANSACTIONS AS ACQUIRING BANK","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"File Name2","csvTxtLength":"51","pdfLength":"51","fieldType":"String","defaultValue":"INTER-ENTITY TRANSACTIONS","delimiter":";","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"fieldName":"Dummy","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"21","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_QUERY := TO_CLOB('SELECT {V_Acq_Name} AS "ACQUIRER BANK MNEM",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
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
      TXN.TRL_TSC_CODE IN (40, 42, 44, 48)
      AND TXN.TRL_TQU_ID IN (''F'')
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
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
      "ATM COUNT",
      "ATM",
      "IVRS COUNT",
      "IVRS",
      "TOTAL COUNT",
      SUM("ONLINE RETAIL" + "ONLINE CORPORATE" + "ATM" + "IVRS") "TOTAL"
FROM(
SELECT
      "BRANCH CODE",
      "BRANCH NAME",
      "TERMINAL",
      "LOCATION",
      COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL COUNT",
      5.00 * COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL",
      COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE COUNT",
      5.00 * COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE",
      COUNT("ATM COUNT") "ATM COUNT",
      5.00 * COUNT("ATM COUNT") "ATM",
      COUNT("IVRS COUNT") "IVRS COUNT",
      5.00 * COUNT("IVRS COUNT") "IVRS",
      SUM(NVL("ONLINE RETAIL COUNT", 0) + NVL("ONLINE CORPORATE COUNT", 0) + NVL("ATM COUNT", 0) + NVL("IVRS COUNT", 0) ) "TOTAL COUNT"
FROM (
SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
	  CASE WHEN TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id} AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971'' AND TXNC.TRL_ORIGIN_CHANNEL IN (''EBK'', ''MBK'') THEN 1 END AS "ONLINE RETAIL COUNT",
      CASE WHEN LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id} AND TXN.TRL_PAN = ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971'' 
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''EBK'', ''MBK'') THEN 1  END AS "ONLINE CORPORATE COUNT",
      CASE WHEN TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id} AND BRC.BRC_CODE IS NOT NULL THEN 1
               WHEN TXN.TRL_ISS_NAME = {V_IE_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Recv_Inst_Id} THEN 1
               WHEN TXN.TRL_ISS_NAME = {V_IE_Iss_Name} AND NVL(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), 0) NOT IN ({V_Recv_Inst_Id}) THEN 1
      END AS "ATM COUNT",
      CASE WHEN TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id} AND TXNC.TRL_ORIGIN_CHANNEL = ''IVR'' THEN 1 END AS "IVRS COUNT"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH  = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE IN (40, 42, 44, 48)
      AND TXN.TRL_TQU_ID IN (''F'')
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
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
      "ATM COUNT",
      "ATM",
      "IVRS COUNT",
      "IVRS",
      "TOTAL COUNT"
ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC
END');
	
	i_TRAILER_QUERY := TO_CLOB('SELECT
      "ONLINE RETAIL COUNT",
      "ONLINE RETAIL",
      "ONLINE CORPORATE COUNT",
      "ONLINE CORPORATE",
      "ATM COUNT",
      "ATM",
      "IVRS COUNT",
      "IVRS",
      "TOTAL COUNT",
      SUM("ONLINE RETAIL" + "ONLINE CORPORATE" + "ATM" + "IVRS") "TOTAL"
FROM(
SELECT
      COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL COUNT",
      5.00 * COUNT("ONLINE RETAIL COUNT") "ONLINE RETAIL",
      COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE COUNT",
      5.00 * COUNT("ONLINE CORPORATE COUNT") "ONLINE CORPORATE",
      COUNT("ATM COUNT") "ATM COUNT",
      5.00 * COUNT("ATM COUNT") "ATM",
      COUNT("IVRS COUNT") "IVRS COUNT",
      5.00 * COUNT("IVRS COUNT") "IVRS",
      SUM(NVL("ONLINE RETAIL COUNT", 0) + NVL("ONLINE CORPORATE COUNT", 0) + NVL("IVRS COUNT", 0) + NVL("ATM COUNT", 0)) "TOTAL COUNT"
FROM (
SELECT
       CASE WHEN TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id} AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''  AND TXNC.TRL_ORIGIN_CHANNEL IN (''EBK'', ''MBK'') THEN 1 END AS "ONLINE RETAIL COUNT",
      CASE WHEN LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id} AND TXN.TRL_PAN = ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
	  AND TXNC.TRL_ORIGIN_CHANNEL IN (''EBK'', ''MBK'') THEN 1  END AS "ONLINE CORPORATE COUNT",
      CASE WHEN TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id} AND BRC.BRC_CODE IS NOT NULL THEN 1
               WHEN TXN.TRL_ISS_NAME = {V_IE_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Recv_Inst_Id} THEN 1
               WHEN TXN.TRL_ISS_NAME = {V_IE_Iss_Name} AND NVL(LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0''), 0) NOT IN ({V_Recv_Inst_Id}) THEN 1
      END AS "ATM COUNT",
      CASE WHEN TXN.TRL_ISS_NAME = {V_Iss_Name} AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id} AND TXNC.TRL_ORIGIN_CHANNEL = ''IVR'' THEN 1 END AS "IVRS COUNT"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	  JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH  = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE IN (40, 42, 44, 48)
      AND TXN.TRL_TQU_ID IN (''F'')
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Txn_Date}
))
GROUP BY
      "ONLINE RETAIL COUNT",
      "ONLINE RETAIL",
      "ONLINE CORPORATE COUNT",
      "ONLINE CORPORATE",
      "ATM COUNT",
      "ATM",
      "IVRS COUNT",
      "IVRS",
      "TOTAL COUNT"');
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'Inter-Entity Approved IBFT Transactions as Acquiring Bank';
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') WHERE RED_NAME = 'Inter-Entity Approved IBFT Transactions as Acquiring Bank' AND red_ins_id = 2;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, '0010', '0112') WHERE RED_NAME = 'Inter-Entity Approved IBFT Transactions as Acquiring Bank' AND red_ins_id = 2;
	
END;
/