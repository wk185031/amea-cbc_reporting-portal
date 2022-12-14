-- Tracking					Date			Name	Description
-- Rel-20210805				05-Aug-2021		KW		Revise report based on specification
-- CBCAXUPISSLOG-806		20-OCT-2021		NY		Fix oracle error invalid numbers

DECLARE
    i_REPORT_NAME VARCHAR2(100) := 'Cash Card Daily Transaction';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 	 

	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"CASH CARD DAILY TRANSACTION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"CARD PRODUCT","csvTxtLength":"97","pdfLength":"97","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"000000011","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"000000011","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space3","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CIF","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"CIF","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"CARD NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":"CARD NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"ACCOUNT NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ACCOUNT NAME","csvTxtLength":"30","pdfLength":"30","fieldType":"String","defaultValue":"ACCOUNT NAME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TRAN","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"BEG. BALANCE","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"BEG. BALANCE","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"DEBIT AMOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"DEBIT AMOUNT","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"CREDIT AMOUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CREDIT AMOUNT","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"BALANCE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"BALANCE","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":true,"firstField":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"CUSTOMER ID","csvTxtLength":"12","pdfLength":"12","fieldType":"String","firstField":true,"defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"FROM ACCOUNT NO","csvTxtLength":"19","pdfLength":"19","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"ACCOUNT NAME","csvTxtLength":"37","pdfLength":"37","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"TRAN MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BEG. BALANCE","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","fieldFormat":"#,##0.00","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"DR AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","fieldFormat":"#,##0.00","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CR AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","fieldFormat":"#,##0.00","defaultValue":"","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"BALANCE","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBC := null;
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"CASH CARD DAILY TRANSACTION","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"CARD PRODUCT","csvTxtLength":"97","pdfLength":"97","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"000000011","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"000000011","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Space3","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"Space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CIF","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"CIF","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"CARD NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":"CARD NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"ACCOUNT NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ACCOUNT NAME","csvTxtLength":"30","pdfLength":"30","fieldType":"String","defaultValue":"ACCOUNT NAME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TRAN","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"BEG. BALANCE","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"BEG. BALANCE","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"DEBIT AMOUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"DEBIT AMOUNT","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"CREDIT AMOUNT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CREDIT AMOUNT","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"BALANCE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"BALANCE","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"TYPE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":true,"firstField":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"CUSTOMER ID","csvTxtLength":"12","pdfLength":"12","fieldType":"String","firstField":true,"defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"FROM ACCOUNT NO","csvTxtLength":"19","pdfLength":"19","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"ACCOUNT NAME","csvTxtLength":"37","pdfLength":"37","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"TRAN MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BEG. BALANCE","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","fieldFormat":"#,##0.00","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"DR AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","fieldFormat":"#,##0.00","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CR AMOUNT","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","fieldFormat":"#,##0.00","defaultValue":"","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"BALANCE","csvTxtLength":"16","pdfLength":"16","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBS := null;
 	    

  i_BODY_QUERY := TO_CLOB('
SELECT
    CUST.CUST_NUMBER "CUSTOMER ID",
    TXN.TRL_PAN "ATM CARD NUMBER",
    TXN.TRL_PAN_EKY_ID "TRL_PAN_EKY_ID",
    CPD.CPD_NAME "CARD PRODUCT",
    TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
    TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID "TRL_ACCOUNT_1_ACN_ID_EKY_ID",
    CRD.CRD_CARDHOLDER_NAME "ACCOUNT NAME",
    CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END "TRAN MNEM",
    CASE WHEN TXN.TRL_TSC_CODE IN (42, 43, 44, 45, 48, 52) THEN TRL_ACCOUNT_1_MAX_AVAILABLE
      WHEN (TXN.TRL_TQU_ID = ''R'' OR TXN.TRL_TSC_CODE = 22 OR TXN.TRL_TSC_CODE = 21) THEN (TRL_ACCOUNT_1_MAX_AVAILABLE - TXN.TRL_AMT_TXN - COALESCE(TXN.TRL_ACQ_CHARGE_AMT, TXN.TRL_ISS_CHARGE_AMT, 0)) 
      ELSE (TRL_ACCOUNT_1_MAX_AVAILABLE + TXN.TRL_AMT_TXN + COALESCE(TXN.TRL_ACQ_CHARGE_AMT, TXN.TRL_ISS_CHARGE_AMT, 0)) END "BEG. BALANCE",
    CASE WHEN (TXN.TRL_TSC_CODE != 22 AND TXN.TRL_TSC_CODE != 21 AND (TXN.TRL_TQU_ID = ''F'' OR TXN.TRL_TQU_ID = ''A'')) THEN (TXN.TRL_AMT_TXN + COALESCE(TXN.TRL_ACQ_CHARGE_AMT, TXN.TRL_ISS_CHARGE_AMT, 0)) ELSE 0 END "DR AMOUNT",
    CASE WHEN (TXN.TRL_TSC_CODE = 22 OR TXN.TRL_TSC_CODE = 21 OR TXN.TRL_TQU_ID = ''R'') THEN (TXN.TRL_AMT_TXN + COALESCE(TXN.TRL_ACQ_CHARGE_AMT, TXN.TRL_ISS_CHARGE_AMT, 0)) ELSE 0 END "CR AMOUNT",
    CASE WHEN TXN.TRL_TSC_CODE IN (42, 43, 44, 45, 48, 52) AND TXN.TRL_TQU_ID = ''R'' THEN (TRL_ACCOUNT_1_MAX_AVAILABLE  + TXN.TRL_AMT_TXN + COALESCE(TXN.TRL_ACQ_CHARGE_AMT, TXN.TRL_ISS_CHARGE_AMT, 0)) 
      WHEN TXN.TRL_TSC_CODE IN (42, 43, 44, 45, 48, 52) AND (TXN.TRL_TQU_ID = ''F'' OR TXN.TRL_TQU_ID = ''A'') THEN (TRL_ACCOUNT_1_MAX_AVAILABLE  - TXN.TRL_AMT_TXN - COALESCE(TXN.TRL_ACQ_CHARGE_AMT, TXN.TRL_ISS_CHARGE_AMT, 0)) 
      ELSE TXN.TRL_ACCOUNT_1_MAX_AVAILABLE END "BALANCE",
    TXN.TRL_SYSTEM_TIMESTAMP "TIME"
FROM
    TRANSACTION_LOG TXN
    JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
    LEFT JOIN CBC_TRAN_CODE CTR ON 
      CTR.CTR_CODE = CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000008882'') THEN 52  
      WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL) THEN 44  
      ELSE TXN.TRL_TSC_CODE END  
      AND CTR.CTR_CHANNEL = 
      	CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id})) THEN CONCAT(''I-'', TXNC.TRL_ORIGIN_CHANNEL) 
      	WHEN TXNC.TRL_ORIGIN_CHANNEL=''BRM'' THEN ''CDM''
      	ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR.CTR_DEBIT_CREDIT = CASE WHEN (TXN.TRL_TSC_CODE = 22 OR TXN.TRL_TSC_CODE = 21) THEN ''CREDIT'' ELSE ''DEBIT'' END
    JOIN ACCOUNT ACN ON TXN.TRL_ACCOUNT_1_ACN_ID = ACN.ACN_ACCOUNT_NUMBER
    JOIN ISSUER ISS ON ISS.ISS_ID = ACN.ACN_ISS_ID AND ISS.ISS_NAME = {V_Iss_Name}
    JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
    JOIN CARD CRD ON CAT.CAT_CRD_ID = CRD.CRD_ID
    JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
    JOIN CUSTOMER CUST ON CRD.CRD_CUST_ID = CUST.CUST_ID
WHERE
    ((TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      OR TXNC.TRL_ORIGIN_CHANNEL = ''OTC''
      OR (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'')
    )
    AND TXN.TRL_TSC_CODE not in (26,41,246,250,251,252)
    AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
    AND (TXN.TRL_TQU_ID = ''F''  OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
    AND TXN.TRL_ACTION_RESPONSE_CODE = 0
    AND {Card_Product}
    AND {Txn_Date}
UNION ALL
SELECT
    CUST.CUST_NUMBER "CUSTOMER ID",
    CRD.CRD_PAN "ATM CARD NUMBER",
    TXN.TRL_PAN_EKY_ID "CRD_PAN_EKY_ID",
    CPD.CPD_NAME "CARD PRODUCT",
    TXN.TRL_ACCOUNT_2_ACN_ID "FROM ACCOUNT NO",
    TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID "TRL_ACCOUNT_1_ACN_ID_EKY_ID",
    CRD.CRD_CARDHOLDER_NAME "ACCOUNT NAME",
    CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END "TRAN MNEM",
    ABS(TRL_ACCOUNT_2_MAX_AVAILABLE) "BEG. BALANCE",
    CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END "DR AMOUNT",
    CASE WHEN (TXN.TRL_TQU_ID = ''F'' OR TXN.TRL_TQU_ID = ''A'') THEN TXN.TRL_AMT_TXN ELSE 0 END "CR AMOUNT",
    ABS(TRL_ACCOUNT_2_MAX_AVAILABLE) + TXN.TRL_AMT_TXN "BALANCE",
    TXN.TRL_SYSTEM_TIMESTAMP "TIME"
FROM
    TRANSACTION_LOG TXN
    JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
    LEFT JOIN CBC_TRAN_CODE CTR ON 
      CTR.CTR_CODE = CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000008882'') THEN 52  
      WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL) THEN 44  
      ELSE TXN.TRL_TSC_CODE END  
      AND CTR.CTR_CHANNEL = 
      	CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id})) THEN CONCAT(''I-'', TXNC.TRL_ORIGIN_CHANNEL) 
      	WHEN TXNC.TRL_ORIGIN_CHANNEL=''BRM'' THEN ''CDM''
      	ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR.CTR_DEBIT_CREDIT = ''CREDIT''
    JOIN ACCOUNT ACN ON TXN.TRL_ACCOUNT_2_ACN_ID = ACN.ACN_ACCOUNT_NUMBER
    JOIN ISSUER ISS ON ISS.ISS_ID = ACN.ACN_ISS_ID AND ISS.ISS_NAME = {V_Iss_Name}
    JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
    JOIN CARD CRD ON CAT.CAT_CRD_ID = CRD.CRD_ID
    JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
    JOIN CUSTOMER CUST ON CRD.CRD_CUST_ID = CUST.CUST_ID
WHERE
    ((TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      OR TXNC.TRL_ORIGIN_CHANNEL = ''OTC''
      OR (TXNC.TRL_ORIGIN_CHANNEL != ''BNT'' AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'')
    )
    AND CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
    AND (TXN.TRL_TQU_ID = ''F''  OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
    AND txn.trl_tsc_code != 1
    AND TXN.TRL_ACTION_RESPONSE_CODE = 0
    AND {Card_Product}
    AND {Txn_Date}
ORDER BY
    "CARD PRODUCT" ASC,
    "ACCOUNT NAME" ASC,
    "TIME" ASC
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