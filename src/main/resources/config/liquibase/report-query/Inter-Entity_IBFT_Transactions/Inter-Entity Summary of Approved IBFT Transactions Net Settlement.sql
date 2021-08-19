-- Tracking				Date			Name	Description
-- Revise report		29-JULY-2021	WY		Revise report based on spec
-- Revise report		14-AUG-2021		WY		Add inter-entity in the header

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_BODY_QUERY CLOB;
    i_TRAILER_QUERY CLOB;
    
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"SUMMARY OF NET SETTLEMENT","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"61","pdfLength":"61","fieldType":"String","defaultValue":"APPROVED IBFT INTER-ENTITY TRANSACTIONS","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_QUERY := TO_CLOB('START ISSUING
SELECT
      (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
	  (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) || '' '' ||
      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
      COUNT(TXN.TRL_ID) "TRANSMITTING COUNT",
      SUM(TXN.TRL_AMT_TXN) "TRANSMITTING TOTAL",
      0 "RECEIVING COUNT",
      0 "RECEIVING TOTAL"
FROM
      TRANSACTION_LOG TXN
      join TRANSACTION_LOG_CUSTOM TXNC on TXN.TRL_ID=TXNC.TRL_ID
	  join BRANCH BRC on TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE 
WHERE
      TXN.TRL_TSC_CODE IN (41, 44, 48, 49)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_IE_Recv_Inst_Id}
      AND {Bank_Code}
      AND {Txn_Date}
GROUP BY
      TXN.TRL_FRD_REV_INST_ID
ORDER BY
      "BANK NAME" ASC
END ISSUING
START RECEIVING
SELECT
      CBA.CBA_CODE "BANK CODE",
      CBA.CBA_CODE || '' '' || CBA.CBA_NAME "BANK NAME",
      0 "TRANSMITTING COUNT",
      0 "TRANSMITTING TOTAL",
      COUNT(TXN.TRL_ID) "RECEIVING COUNT",
      SUM(TXN.TRL_AMT_TXN) "RECEIVING TOTAL"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
      TXN.TRL_TSC_CODE IN (41, 44, 48, 49)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME = {V_IE_Iss_Name}
      AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Recv_Inst_Id}
      AND {Bank_Code}
      AND {Txn_Date}
GROUP BY
      CBA.CBA_CODE,
      CBA.CBA_NAME
ORDER BY
      "BANK NAME" ASC
END RECEIVING');
	
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY
	where RED_NAME = 'Inter-Entity Summary of Approved IBFT Transactions Net Settlement';
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') WHERE RED_NAME = 'Inter-Entity Summary of Approved IBFT Transactions Net Settlement' AND red_ins_id = 2;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, '0010', '0112') WHERE RED_NAME = 'Inter-Entity Summary of Approved IBFT Transactions Net Settlement' AND red_ins_id = 2;
	
END;
/