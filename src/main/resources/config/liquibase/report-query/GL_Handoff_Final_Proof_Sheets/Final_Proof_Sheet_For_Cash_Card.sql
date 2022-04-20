-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-742	25-JUN-2021		NY		Initial config from UAT environment
-- CBCAXUPISSLOG-645	28-JUN-2021		NY		Clean up for new introduced CBS GL Account set
-- Rel-20210805			05-Aug-2021		KW		Revise report based on specification
-- CBCAXUPISSLOG-947	28/Sep/2021		KW		Include other transactions
-- CBCAXUPISSLOG-947	14-Mar-2022		KW		Exclude OTC transaction for cash card
-- CBCAXUPISSLOG-1267	20-Apr-2022		KW		Include Cash Card Transactions for Inter-Entity

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Final Proof Sheet For Cash Card';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	i_PROCESSING_CLASS VARCHAR2(200) := 'my.com.mandrill.base.reporting.glHandoffFinalProofSheet.DefaultHandoffFinalProofSheet';
BEGIN 
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"FINAL PROOF SHEET","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"70","pdfLength":"70","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"47","pdfLength":"47","fieldType":"String","defaultValue":"FOR CASH_CARD","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL002P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL002P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DEBITS","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"DEBITS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"CREDITS","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"CREDITS","bodyHeader":true,"fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"GL ACCOUNT NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DEBIT","csvTxtLength":"39","pdfLength":"39","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"3","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"72","pdfLength":"72","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"62","pdfLength":"62","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"48","pdfLength":"48","fieldType":"String","defaultValue":"FINAL PROOF SHEET","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Division Name","csvTxtLength":"70","pdfLength":"70","fieldType":"String","defaultValue":"ALTERNATIVE CHANNELS DIVISION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"File Name2","csvTxtLength":"47","pdfLength":"47","fieldType":"String","defaultValue":"FOR CASH_CARD","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"GL002P","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"GL002P","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"BRANCH","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"53","pdfLength":"53","fieldType":"String","defaultValue":"GL ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"GL ACCOUNT NAME","csvTxtLength":"55","pdfLength":"55","fieldType":"String","defaultValue":"GL ACCOUNT NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"DEBITS","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"DEBITS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"CREDITS","csvTxtLength":"27","pdfLength":"27","fieldType":"String","defaultValue":"CREDITS","bodyHeader":true,"fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BRANCH CODE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"GL ACCOUNT NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"GL ACCOUNT NAME","csvTxtLength":"60","pdfLength":"60","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DEBIT","csvTxtLength":"39","pdfLength":"39","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Line1","csvTxtLength":"156","pdfLength":"156","fieldType":"String","defaultValue":"_","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"3","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"4","fieldName":"Asterisk1","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"5","fieldName":"TOTAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TOTAL","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"6","fieldName":"Asterisk2","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"***","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"7","fieldName":"TOTAL DEBIT","csvTxtLength":"72","pdfLength":"72","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"8","fieldName":"TOTAL CREDIT","csvTxtLength":"25","pdfLength":"25","fieldType":"Decimal","defaultValue":"","eol":true,"fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT 
	"GROUP_ID",
	"BRANCH CODE",
	"GL ACCOUNT NUMBER",
	"GL ACCOUNT NAME",
	SUM("DEBIT") "DEBIT",
	SUM("CREDIT") "CREDIT"
FROM (
SELECT
	  GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
      ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE COALESCE(ABR.ABR_CODE, CCRD.CRD_BRANCH_CODE, NULL) END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_AMT_TXN "DEBIT",
      0 AS "CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID AND TXNC.TRL_ORIGIN_CHANNEL != ''OTC''
	  LEFT JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      JOIN CBC_GL_ENTRY GLE ON GLE.GLE_TRAN_TYPE =
        CASE WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and LPAD(txn.trl_frd_rev_inst_id,10,0) = ''0000008882'' THEN 52 
        WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and TXN.TRL_FRD_REV_INST_ID IS NOT NULL THEN 44
        ELSE TXN.TRL_TSC_CODE END 
         AND GLE.GLE_TRAN_CHANNEL=TXNC.TRL_ORIGIN_CHANNEL
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''N''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''CASH CARD'')       
		 --AND GLE.GLE_MAIN_DIRECTION = CASE WHEN TXN.TRL_TSC_CODE = 48 THEN ''INTER-ENTITY''
           AND GLE.GLE_MAIN_DIRECTION = CASE WHEN (TXN.TRL_TSC_CODE=1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(txn.trl_frd_rev_inst_id,10,0) != ''0000008882'')
           		OR (TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME = ''CBC'') THEN ''TRANSMITTING'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000000010'' THEN ''RECEIVING'' 
           WHEN (TXN.TRL_TSC_CODE < 40 OR TXN.TRL_TSC_CODE > 49) AND TXN.TRL_DEO_NAME ={V_IE_Deo_Name} THEN ''INTER-ENTITY''
           WHEN TXN.TRL_TSC_CODE NOT IN (142,143) AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''ISSUER''  
           ELSE ''ON-US'' END 
      AND NVL(GLE.GLE_BP_INCLUDE, ''*'') = CASE WHEN TXN.TRL_TSC_CODE IN (50,250) AND CBL.CBL_CODE IN (''019'',''063'',''065'',''067'') THEN CBL.CBL_CODE 
          ELSE ''*'' END 		   
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  LEFT JOIN CARD_CUSTOM CCRD ON CCRD.CRD_ID = CRD.CRD_ID
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  JOIN ISSUER ISS ON ISS.ISS_ID = CRD.CRD_ISS_ID AND ISS.ISS_NAME={V_Iss_Name}
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = 
        CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR_DEBIT_CREDIT = ''DEBIT''
	WHERE
      TXN.TRL_TQU_ID = ''F'' AND (TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'' OR TXNC.TRL_ORIGIN_CHANNEL=''OTC'')
      AND TXN.TRL_TSC_CODE NOT IN (21,41,45,250)
	  -- AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'',''BNT'',''OTC'')
      AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      -- AND TXN.TRL_ISS_NAME = {V_Iss_Name} 
	  AND NVL(CBL.CBL_SETTLEMENT_TYPE,''*'') =  CASE WHEN TXN.TRL_TSC_CODE IN (50,250) THEN ''AP'' ELSE ''*'' END
	  AND {Txn_Date}     
UNION ALL 
SELECT
	 GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
      ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE COALESCE(ABR.ABR_CODE, CCRD.CRD_BRANCH_CODE, NULL) END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      0 AS "DEBIT",
      TXN.TRL_AMT_TXN "CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID AND TXNC.TRL_ORIGIN_CHANNEL != ''OTC''
	  LEFT JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      JOIN CBC_GL_ENTRY GLE ON GLE.GLE_TRAN_TYPE =
        CASE WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and LPAD(txn.trl_frd_rev_inst_id,10,0) = ''0000008882'' THEN 52 
        WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and TXN.TRL_FRD_REV_INST_ID IS NOT NULL THEN 44
        ELSE TXN.TRL_TSC_CODE END 
         AND GLE.GLE_TRAN_CHANNEL=TXNC.TRL_ORIGIN_CHANNEL
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''N''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''CASH CARD'')       
		 --AND GLE.GLE_MAIN_DIRECTION = CASE WHEN TXN.TRL_TSC_CODE = 48 THEN ''INTER-ENTITY''
           AND GLE.GLE_MAIN_DIRECTION = CASE WHEN (TXN.TRL_TSC_CODE=1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(txn.trl_frd_rev_inst_id,10,0) != ''0000008882'')
           		OR (TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME = ''CBC'') THEN ''TRANSMITTING''  
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000000010'' THEN ''RECEIVING'' 
           WHEN (TXN.TRL_TSC_CODE < 40 OR TXN.TRL_TSC_CODE > 49) AND TXN.TRL_DEO_NAME ={V_IE_Deo_Name} THEN ''INTER-ENTITY''
           WHEN TXN.TRL_TSC_CODE NOT IN (142,143) AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''ISSUER''  
           ELSE ''ON-US'' END
	  AND NVL(GLE.GLE_BP_INCLUDE, ''*'') = CASE WHEN TXN.TRL_TSC_CODE IN (50,250) AND CBL.CBL_CODE IN (''019'',''063'',''065'',''067'') THEN CBL.CBL_CODE 
          ELSE ''*'' END 
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  LEFT JOIN CARD_CUSTOM CCRD ON CCRD.CRD_ID = CRD.CRD_ID
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN ISSUER ISS ON ISS.ISS_ID = CRD.CRD_ISS_ID AND ISS.ISS_NAME={V_Iss_Name}
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = 
        CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR_DEBIT_CREDIT = ''DEBIT''
	WHERE
      TXN.TRL_TQU_ID = ''F'' AND (TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'' OR TXNC.TRL_ORIGIN_CHANNEL=''OTC'')
      AND TXN.TRL_TSC_CODE NOT IN (21,41,45,250)
	  -- AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'',''BNT'',''OTC'')
      AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      -- AND TXN.TRL_ISS_NAME = {V_Iss_Name} 
	  AND NVL(CBL.CBL_SETTLEMENT_TYPE,''*'') =  CASE WHEN TXN.TRL_TSC_CODE IN (50,250) THEN ''AP'' ELSE ''*'' END
	  AND {Txn_Date}  
-- Fee
 UNION ALL 
 SELECT
	  GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
      ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE COALESCE(ABR.ABR_CODE, CCRD.CRD_BRANCH_CODE, NULL) END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      CASE WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND TXN.TRL_FRD_REV_INST_ID IS NULL THEN TXN.TRL_ACQ_CHARGE_AMT 
        ELSE NVL(TXN.TRL_ISS_CHARGE_AMT,0) + NVL(TXN.TRL_ACQ_CHARGE_AMT,0) END "DEBIT",
      0 AS "CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID AND TXNC.TRL_ORIGIN_CHANNEL != ''OTC''
	  LEFT JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      JOIN CBC_GL_ENTRY GLE ON GLE.GLE_TRAN_TYPE =
        CASE WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and LPAD(txn.trl_frd_rev_inst_id,10,0) = ''0000008882'' THEN 52 
        WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and TXN.TRL_FRD_REV_INST_ID IS NOT NULL THEN 44
        ELSE TXN.TRL_TSC_CODE END 
         AND GLE.GLE_TRAN_CHANNEL=TXNC.TRL_ORIGIN_CHANNEL
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''Y''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''CASH CARD'')       
		 --AND GLE.GLE_MAIN_DIRECTION = CASE WHEN TXN.TRL_TSC_CODE = 48 THEN ''INTER-ENTITY''
           AND GLE.GLE_MAIN_DIRECTION = CASE WHEN (TXN.TRL_TSC_CODE=1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(txn.trl_frd_rev_inst_id,10,0) != ''0000008882'')
           		OR (TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME = ''CBC'') THEN ''TRANSMITTING'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000000010'' THEN ''RECEIVING'' 
           WHEN (TXN.TRL_TSC_CODE < 40 OR TXN.TRL_TSC_CODE > 49) AND TXN.TRL_DEO_NAME ={V_IE_Deo_Name} THEN ''INTER-ENTITY'' 
           WHEN TXN.TRL_TSC_CODE NOT IN (142,143) AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''ISSUER''  
           ELSE ''ON-US'' END
      AND NVL(GLE.GLE_BP_INCLUDE, ''*'') = CASE WHEN TXN.TRL_TSC_CODE IN (50,250) AND CBL.CBL_CODE IN (''019'',''063'',''065'',''067'') THEN CBL.CBL_CODE 
          ELSE ''*'' END 		   
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  LEFT JOIN CARD_CUSTOM CCRD ON CCRD.CRD_ID = CRD.CRD_ID
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN ISSUER ISS ON ISS.ISS_ID = CRD.CRD_ISS_ID AND ISS.ISS_NAME={V_Iss_Name}
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = 
        CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR_DEBIT_CREDIT = ''DEBIT''
	WHERE
      TXN.TRL_TQU_ID = ''F'' AND (TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'' OR TXNC.TRL_ORIGIN_CHANNEL=''OTC'')
      AND TXN.TRL_TSC_CODE NOT IN (21,41,45,250)
	  -- AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'',''BNT'',''OTC'')
      AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      -- AND TXN.TRL_ISS_NAME = {V_Iss_Name} 
	  AND NVL(CBL.CBL_SETTLEMENT_TYPE,''*'') =  CASE WHEN TXN.TRL_TSC_CODE IN (50,250) THEN ''AP'' ELSE ''*'' END
	  AND COALESCE(TXN.TRL_ISS_CHARGE_AMT,TXN.TRL_ACQ_CHARGE_AMT,0) > 0
	  AND {Txn_Date}   
UNION ALL 
SELECT
	 GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
      ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE COALESCE(ABR.ABR_CODE, CCRD.CRD_BRANCH_CODE, NULL) END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      0 AS "DEBIT",
      CASE WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' AND TXN.TRL_FRD_REV_INST_ID IS NULL THEN TXN.TRL_ACQ_CHARGE_AMT 
        ELSE NVL(TXN.TRL_ISS_CHARGE_AMT,0) + NVL(TXN.TRL_ACQ_CHARGE_AMT,0) END "CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID AND TXNC.TRL_ORIGIN_CHANNEL != ''OTC''
	  LEFT JOIN (SELECT DISTINCT CBL_CODE,CBL_MNEM,CBL_SETTLEMENT_TYPE FROM CBC_BILLER) CBL ON LPAD(TXNC.TRL_BILLER_CODE, 3, ''0'') = LPAD(CBL.CBL_CODE, 3, ''0'')
      JOIN CBC_GL_ENTRY GLE ON GLE.GLE_TRAN_TYPE =
        CASE WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and LPAD(txn.trl_frd_rev_inst_id,10,0) = ''0000008882'' THEN 52 
        WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and TXN.TRL_FRD_REV_INST_ID IS NOT NULL THEN 44
        ELSE TXN.TRL_TSC_CODE END 
         AND GLE.GLE_TRAN_CHANNEL=TXNC.TRL_ORIGIN_CHANNEL
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''Y''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''CASH CARD'')       
		 --AND GLE.GLE_MAIN_DIRECTION = CASE WHEN TXN.TRL_TSC_CODE = 48 THEN ''INTER-ENTITY''
           AND GLE.GLE_MAIN_DIRECTION = CASE WHEN (TXN.TRL_TSC_CODE=1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(txn.trl_frd_rev_inst_id,10,0) != ''0000008882'')
           		OR (TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME = ''CBC'') THEN ''TRANSMITTING'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXN.TRL_TSC_CODE >= 40 and TXN.TRL_TSC_CODE <= 49 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000000010'' THEN ''RECEIVING'' 
           WHEN (TXN.TRL_TSC_CODE < 40 OR TXN.TRL_TSC_CODE > 49) AND TXN.TRL_DEO_NAME ={V_IE_Deo_Name} THEN ''INTER-ENTITY''
           WHEN TXN.TRL_TSC_CODE NOT IN (142,143) AND TXN.TRL_ISS_NAME IS NULL THEN ''ACQUIRER'' 
           WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' THEN ''ISSUER''  
           ELSE ''ON-US'' END 
	  AND NVL(GLE.GLE_BP_INCLUDE, ''*'') = CASE WHEN TXN.TRL_TSC_CODE IN (50,250) AND CBL.CBL_CODE IN (''019'',''063'',''065'',''067'') THEN CBL.CBL_CODE 
          ELSE ''*'' END 
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  LEFT JOIN CARD_CUSTOM CCRD ON CCRD.CRD_ID = CRD.CRD_ID
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN ISSUER ISS ON ISS.ISS_ID = CRD.CRD_ISS_ID AND ISS.ISS_NAME={V_Iss_Name}
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = 
        CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR_DEBIT_CREDIT = ''DEBIT''
	WHERE
      TXN.TRL_TQU_ID = ''F'' AND (TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'' OR TXNC.TRL_ORIGIN_CHANNEL=''OTC'')
      AND TXN.TRL_TSC_CODE NOT IN (21,41,45,250)
	  -- AND TXNC.TRL_ORIGIN_CHANNEL IN (''ATM'',''CDM'',''BRM'',''BNT'',''OTC'')
      AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
      -- AND TXN.TRL_ISS_NAME = {V_Iss_Name} 
	  AND NVL(CBL.CBL_SETTLEMENT_TYPE,''*'') =  CASE WHEN TXN.TRL_TSC_CODE IN (50,250) THEN ''AP'' ELSE ''*'' END
	  AND COALESCE(TXN.TRL_ISS_CHARGE_AMT,TXN.TRL_ACQ_CHARGE_AMT,0) > 0
	  AND {Txn_Date} 
-- CREDIT
UNION ALL 
SELECT
	  GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
      ''D'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE CCRD.CRD_BRANCH_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      TXN.TRL_AMT_TXN "DEBIT",
      0 AS "CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID AND TXNC.TRL_ORIGIN_CHANNEL != ''OTC''
      JOIN CBC_GL_ENTRY GLE ON GLE.GLE_TRAN_TYPE =
        CASE WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and LPAD(txn.trl_frd_rev_inst_id,10,0) = ''0000008882'' THEN 52 
        WHEN TXN.TRL_TSC_CODE = 41 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and TXN.TRL_FRD_REV_INST_ID IS NOT NULL THEN 44
        ELSE TXN.TRL_TSC_CODE END 
         AND GLE.GLE_TRAN_CHANNEL=TXNC.TRL_ORIGIN_CHANNEL
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''N''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''CASH CARD'')       
		 AND GLE.GLE_MAIN_DIRECTION = ''RECEIVING''
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_DEBIT_ACCOUNT = GLA.GLA_NAME
      JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = 
        CASE WHEN TXN.TRL_TSC_CODE=21 THEN TXN.TRL_ACCOUNT_1_ACN_ID 
        ELSE TXN.TRL_ACCOUNT_2_ACN_ID END
      JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      JOIN CARD CRD ON CRD.CRD_ID = CAT_CRD_ID  
      JOIN CARD_CUSTOM CCRD ON CCRD.CRD_ID = CRD.CRD_ID
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN ISSUER ISS ON ISS.ISS_ID = ACN.ACN_ISS_ID and ISS.ISS_NAME = {V_Iss_Name}
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = 
        CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR_DEBIT_CREDIT = ''CREDIT''
	WHERE
      TXN.TRL_TQU_ID = ''F'' AND (TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'' OR TXNC.TRL_ORIGIN_CHANNEL=''OTC'')
      AND TXN.TRL_TSC_CODE IN (21,41,48)
	  -- EBK and MBK to be excluded for now until CR on segregation of transaction finalized
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''MBK'',''EBK'')
      AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND {Txn_Date}      
UNION ALL 
SELECT
	 GLE.GLE_DEBIT_DESCRIPTION AS "GROUP_ID",
      ''C'' AS "DEBIT CREDIT",
      CASE WHEN LENGTH(GLA.GLA_NUMBER) > 10 THEN SUBSTR(GLA.GLA_NUMBER, 1, 4) ELSE CCRD.CRD_BRANCH_CODE END "BRANCH CODE",
      GLA.GLA_NUMBER "GL ACCOUNT NUMBER",
      GLA.GLA_NAME "GL ACCOUNT NAME",
      0 AS "DEBIT",
      TXN.TRL_AMT_TXN "CREDIT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID AND TXNC.TRL_ORIGIN_CHANNEL != ''OTC''
      JOIN CBC_GL_ENTRY GLE ON GLE.GLE_TRAN_TYPE =
        CASE WHEN TXN.TRL_TSC_CODE = 1 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and LPAD(txn.trl_frd_rev_inst_id,10,0) = ''0000008882'' THEN 52 
        WHEN TXN.TRL_TSC_CODE = 41 AND TXNC.TRL_ORIGIN_CHANNEL = ''BNT'' and TXN.TRL_FRD_REV_INST_ID IS NOT NULL THEN 44
        ELSE TXN.TRL_TSC_CODE END 
         AND GLE.GLE_TRAN_CHANNEL=TXNC.TRL_ORIGIN_CHANNEL
         AND GLE.GLE_ENTRY_ENABLED = ''Y''
         AND NVL(GLE.GLE_SVC_ENABLED,''N'') = ''N''
         AND GLE.GLE_GLT_ID = (SELECT GLT_ID FROM CBC_GL_TRANSACTION WHERE GLT_NAME = ''CASH CARD'')       
		 AND GLE.GLE_MAIN_DIRECTION = ''RECEIVING''
      JOIN CBC_GL_ACCOUNT GLA ON GLE.GLE_CREDIT_ACCOUNT = GLA.GLA_NAME
      JOIN ACCOUNT ACN ON ACN.ACN_ACCOUNT_NUMBER = 
        CASE WHEN TXN.TRL_TSC_CODE=21 THEN TXN.TRL_ACCOUNT_1_ACN_ID 
        ELSE TXN.TRL_ACCOUNT_2_ACN_ID END
      JOIN CARD_ACCOUNT CAT ON CAT.CAT_ACN_ID = ACN.ACN_ID
      JOIN CARD CRD ON CRD.CRD_ID = CAT_CRD_ID  
      JOIN CARD_CUSTOM CCRD ON CCRD.CRD_ID = CRD.CRD_ID
      JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
      JOIN ISSUER ISS ON ISS.ISS_ID = ACN.ACN_ISS_ID and ISS.ISS_NAME = {V_Iss_Name}
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = 
        CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END
      AND CTR_DEBIT_CREDIT = ''CREDIT''
	WHERE
      TXN.TRL_TQU_ID = ''F'' AND (TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345'' OR TXNC.TRL_ORIGIN_CHANNEL=''OTC'')
      AND TXN.TRL_TSC_CODE IN (21,41,48)
	  -- EBK and MBK to be excluded for now until CR on segregation of transaction finalized
	  AND TXNC.TRL_ORIGIN_CHANNEL NOT IN (''MBK'',''EBK'')
      AND NVL(CPD.CPD_CODE,0) IN (''80'',''81'',''82'',''83'')
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND GLA.GLA_INSTITUTION = {V_Gla_Inst}
	  AND {Txn_Date}  
)
GROUP BY
	  "GROUP_ID",
	  "DEBIT CREDIT",
      "BRANCH CODE",
      "GL ACCOUNT NUMBER",
      "GL ACCOUNT NAME"   
 ORDER BY    
      "GROUP_ID", 
	  "DEBIT CREDIT" DESC,
	  "BRANCH CODE"	
	');	
	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
	    RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	
END;
/