-- Tracking				Date			Name	Description
-- Rel-20210805			05-Aug-2021		KW		Revise report based on specification
-- CBCAXUPISSLOG-806	20-OCT-2021		NY		Fix oracle error invalid number

DECLARE
    i_REPORT_NAME VARCHAR2(100) := 'Cash Card Successful and Unsuccessful Statistics per Channel';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"CASH CARD SUCCESSFUL AND UNSUCCESSFUL","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"61","pdfLength":"61","fieldType":"String","defaultValue":"TRANSACTIONS STATISTICS PER CHANNEL","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CHANNEL","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","defaultValue":"CHANNEL","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TXN TYPE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","defaultValue":"TXN TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"SUCC TXN COUNT","csvTxtLength":"21","pdfLength":"21","fieldType":"String","delimiter":";","defaultValue":"SUCC TXN COUNT","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"SUCC TXN AMT","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"SUCC TXN AMT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"UNSUC TXN COUNT","csvTxtLength":"21","pdfLength":"21","fieldType":"String","delimiter":";","defaultValue":"UNSUC TXN COUNT","firstField":false,"bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"UNSUC TXN AMT","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"UNSUC TXN AMT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL TXN COUNT","csvTxtLength":"21","pdfLength":"21","fieldType":"String","delimiter":";","defaultValue":"TOTAL TXN COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL TXN AMT","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"TOTAL TXN AMT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"CHANNEL","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"TRANSACTION TYPE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"SUCC TXN COUNT","csvTxtLength":"14","pdfLength":"14","fieldType":"Number","delimiter":";","fieldFormat":",","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"SUCC TXN AMT","csvTxtLength":"19","pdfLength":"19","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"UNSUCC TXN COUNT","csvTxtLength":"21","pdfLength":"21","fieldType":"Number","eol":false,"delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"UNSUCC TXN AMT","csvTxtLength":"19","pdfLength":"19","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TOTAL TXN COUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"TOTAL TXN AMT","csvTxtLength":"19","pdfLength":"19","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBC := null;
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","defaultValue":"CASH CARD SUCCESSFUL AND UNSUCCESSFUL","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"File Name2","csvTxtLength":"61","pdfLength":"61","fieldType":"String","defaultValue":"TRANSACTIONS STATISTICS PER CHANNEL","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CHANNEL","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","defaultValue":"CHANNEL","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TXN TYPE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","defaultValue":"TXN TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"SUCC TXN COUNT","csvTxtLength":"21","pdfLength":"21","fieldType":"String","delimiter":";","defaultValue":"SUCC TXN COUNT","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"SUCC TXN AMT","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"SUCC TXN AMT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"UNSUC TXN COUNT","csvTxtLength":"21","pdfLength":"21","fieldType":"String","delimiter":";","defaultValue":"UNSUC TXN COUNT","firstField":false,"bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"UNSUC TXN AMT","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"UNSUC TXN AMT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL TXN COUNT","csvTxtLength":"21","pdfLength":"21","fieldType":"String","delimiter":";","defaultValue":"TOTAL TXN COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL TXN AMT","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"TOTAL TXN AMT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"CHANNEL","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"TRANSACTION TYPE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"SUCC TXN COUNT","csvTxtLength":"14","pdfLength":"14","fieldType":"Number","delimiter":";","fieldFormat":",","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"SUCC TXN AMT","csvTxtLength":"19","pdfLength":"19","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"UNSUCC TXN COUNT","csvTxtLength":"21","pdfLength":"21","fieldType":"Number","eol":false,"delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"UNSUCC TXN AMT","csvTxtLength":"19","pdfLength":"19","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TOTAL TXN COUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"TOTAL TXN AMT","csvTxtLength":"19","pdfLength":"19","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBS := null;
 	    

  i_BODY_QUERY := TO_CLOB('
SELECT  
  "CHANNEL",
  "TRANSACTION TYPE",
  SUM("SUCC TXN COUNT") AS "SUCC TXN COUNT",
  SUM("SUCC TXN AMT") "SUCC TXN AMT",
  SUM("UNSUCC TXN COUNT") AS "UNSUCC TXN COUNT",
  SUM("UNSUCC TXN AMT") "UNSUCC TXN AMT",
  SUM("SUCC TXN COUNT") + SUM("UNSUCC TXN COUNT") "TOTAL TXN COUNT",
  SUM("SUCC TXN AMT") + SUM("UNSUCC TXN AMT") "TOTAL TXN AMT"
FROM (
SELECT
  CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN ''ChinaBank ATM'' 
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN ''ChinaBank CDM'' 
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''ChinaBank BRM''
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''EBK'' THEN ''ChinaBank Online''
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''MBK'' THEN ''Mobile Banking''
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''IVR'' THEN ''Tellerphone''
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND TXN.TRL_ACQR_INST_ID = ''0000009990'' THEN ''BancNet Online'' 
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''Other Bank ATM'' 
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CBS'' THEN ''DCMS'' 
  ELSE TXNC.TRL_ORIGIN_CHANNEL END AS "CHANNEL",
  CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END "TRANSACTION TYPE",
  CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "SUCC TXN COUNT",
  CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END "SUCC TXN AMT",
  CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE != 0 THEN 1 ELSE 0 END AS "UNSUCC TXN COUNT",
  CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE != 0 THEN TXN.TRL_AMT_TXN ELSE 0 END "UNSUCC TXN AMT"
FROM
  TRANSACTION_LOG TXN
  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
  LEFT JOIN CBC_TRAN_CODE CTR ON 
      CTR.CTR_CODE = CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000008882'') THEN 52  
      WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL) THEN 44  
      ELSE TXN.TRL_TSC_CODE END  
      AND CTR.CTR_CHANNEL = 
      	CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id})) THEN CONCAT(''I-'', TXNC.TRL_ORIGIN_CHANNEL) 
      	WHEN TXNC.TRL_ORIGIN_CHANNEL=''BRM'' THEN ''CDM''
      	ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR.CTR_DEBIT_CREDIT = CASE WHEN (TXN.TRL_TSC_CODE = 22 OR TXN.TRL_TSC_CODE = 21) THEN ''CREDIT'' ELSE ''DEBIT'' END
  JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_1_ACN_ID
  JOIN ISSUER ISS ON ACN.ACN_ISS_ID = ISS.ISS_ID AND ISS.ISS_NAME = {V_Iss_Name}
  JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
  JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
  JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
  ((TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      OR (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'')
    )
    AND TXN.TRL_TSC_CODE not in (26,41,246,250,251,252)
  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
  AND (TXN.TRL_TQU_ID = ''F'' OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
  AND {Txn_Date}
UNION ALL 
SELECT
  CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''ATM'' THEN ''ChinaBank ATM'' 
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CDM'' THEN ''ChinaBank CDM'' 
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''ChinaBank BRM''
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''EBK'' THEN ''ChinaBank Online''
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''MBK'' THEN ''Mobile Banking''
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''IVR'' THEN ''Tellerphone''
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND TXN.TRL_ACQR_INST_ID = ''0000009990'' THEN ''BancNet Online'' 
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''Other Bank ATM'' 
  WHEN TXNC.TRL_ORIGIN_CHANNEL = ''CBS'' THEN ''DCMS'' 
  ELSE TXNC.TRL_ORIGIN_CHANNEL END AS "CHANNEL",
  CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END "TRANSACTION TYPE",
  CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN 1 ELSE 0 END AS "SUCC TXN COUNT",
  CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END "SUCC TXN AMT",
  CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE != 0 THEN 1 ELSE 0 END AS "UNSUCC TXN COUNT",
  CASE WHEN TXN.TRL_ACTION_RESPONSE_CODE != 0 THEN TXN.TRL_AMT_TXN ELSE 0 END "UNSUCC TXN AMT"
FROM
  TRANSACTION_LOG TXN
  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
  LEFT JOIN CBC_TRAN_CODE CTR ON 
      CTR.CTR_CODE = CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000008882'') THEN 52  
      WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL) THEN 44  
      ELSE TXN.TRL_TSC_CODE END  
      AND CTR.CTR_CHANNEL = 
      	CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id})) THEN CONCAT(''I-'', TXNC.TRL_ORIGIN_CHANNEL) 
      	WHEN TXNC.TRL_ORIGIN_CHANNEL=''BRM'' THEN ''CDM''
      	ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR.CTR_DEBIT_CREDIT = ''CREDIT''
  JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = TXN.TRL_ACCOUNT_2_ACN_ID
  JOIN ISSUER ISS ON ACN.ACN_ISS_ID = ISS.ISS_ID AND ISS.ISS_NAME = {V_Iss_Name}
  JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
  JOIN CARD CRD ON CRD.CRD_ID = CAT.CAT_CRD_ID
  JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
WHERE
  ((TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      OR (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'')
    )
  AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
  AND (TXN.TRL_TQU_ID = ''F'' OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
  AND txn.trl_tsc_code != 1
  AND {Txn_Date}
)
GROUP BY
  "CHANNEL",
  "TRANSACTION TYPE"
ORDER BY
  "CHANNEL",
  "TRANSACTION TYPE"
  '); 
  
  i_TRAILER_QUERY := null; 

	UPDATE REPORT_DEFINITION SET 
	    RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;	  
END;

/