-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- JIRA 945				27-SEP-2021		WY		Fix report bugs

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'List of Moving Cash Transactions';
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"LIST OF MOVING CASH TRANSACTION REPORT","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":4,"sectionName":"4","fieldName":"File Name2","csvTxtLength":"54","pdfLength":"54","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"SUMMARY OF MOVING CASH TRANSACTIONS REPORT","leftJustified":true,"padFieldLength":0},
{"sequence":5,"sectionName":"5","fieldName":"File Name2","csvTxtLength":"54","pdfLength":"54","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"LIST OF PENDING MOVING CASH TRANSACTION REPORT","leftJustified":true,"padFieldLength":0},
{"sequence":6,"sectionName":"6","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":7,"sectionName":"7","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":8,"sectionName":"8","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":10,"sectionName":"10","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":11,"sectionName":"11","fieldName":"BRANCH NAME","csvTxtLength":"101","pdfLength":"101","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":12,"sectionName":"12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space1","leftJustified":true,"padFieldLength":0},
{"sequence":13,"sectionName":"13","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":14,"sectionName":"14","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":15,"sectionName":"15","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":16,"sectionName":"16","fieldName":"Space2","csvTxtLength":"100","pdfLength":"100","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":17,"sectionName":"17","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space3","leftJustified":true,"padFieldLength":0},
{"sequence":18,"sectionName":"18","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldName":"Space4","leftJustified":true,"padFieldLength":0},
{"sequence":19,"sectionName":"19","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":20,"sectionName":"20","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":21,"sectionName":"21","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","delimiter":";","leftJustified":true,"padFieldLength":0},
{"sequence":22,"sectionName":"22","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","delimiter":";","leftJustified":true,"padFieldLength":0}]');


	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No.","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No.","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Tran Rref No.","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Tran Ref No.","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Bank Mnem","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Mnem","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"ATM Card No.","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Source Acct No.","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Source Acct No.","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"To Mobile Number","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"To Mobile Number","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"Trans Amount","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Trans Amount","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"Trans Fee (CR)","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Trans Fee (CR)","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Tran Code Remarks","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Tran Code Remarks","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":false,"eol":true},{"sequence":14,"sectionName":"14","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":17,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"18","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"TRAN REF NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":23,"sectionName":"23","fieldName":"TO MOBILE NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"6","pdfLength":"6","fieldType":"Decimal","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":"#,##0.00"},{"sequence":25,"sectionName":"25","fieldName":"TRAN FEE","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","delimiter":";","leftJustified":false,"padFieldLength":"0","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros","fieldFormat":"#,##0.00","tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"28","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"29","fieldName":"VOLUME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOLUME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"30","fieldName":"AMOUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AMOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":31,"sectionName":"31","fieldName":"FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"32","fieldName":"TXN TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"33","fieldName":"Savings","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"defaultValue":"Savings"},{"sequence":34,"sectionName":"34","fieldName":"SA VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":35,"sectionName":"35","fieldName":"SA AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"36","fieldName":"SA FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":37,"sectionName":"37","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":38,"sectionName":"38","fieldName":"Current","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Current","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":39,"sectionName":"39","fieldName":"CA VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":40,"sectionName":"40","fieldName":"CA AMT","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":41,"sectionName":"41","fieldName":"CA FEE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	
	i_BODY_QUERY := TO_CLOB('SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CMV.CMV_TXN_REF_NO "TRAN REF NO",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CMV.CMV_RECV_MOBILE "TO MOBILE NO",
      TXN.TRL_AMT_TXN "AMOUNT",
      NVL(TXN.TRL_ISS_CHARGE_AMT, 0) "TRAN FEE",
      CASE 
      WHEN TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = ''0'' THEN ''Full Reversal''
	  WHEN TXN.TRL_TQU_ID = ''A'' THEN CMV.CMV_STATUS
      WHEN TXN.TRL_TQU_ID NOT IN (''R'') AND TXN.TRL_ACTION_RESPONSE_CODE = ''0'' THEN ''''
      ELSE ARC.ARC_NAME END "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN CBC_MOVING_CASH CMV ON TXN.TRL_RRN = CMV.CMV_TXN_REF_NO
	  LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
WHERE
      TXN.TRL_TSC_CODE = 143
      AND (TXN.TRL_TQU_ID IN (''F'') OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC
START SELECT ''ATM WITHDRAWAL'' "TXN TYPE", SUM("SA VOL") "SA VOL",
	SUM("SA AMT") "SA AMT",
	SUM("SA FEE") "SA FEE",
	SUM("CA VOL") "CA VOL",
	SUM("CA AMT") "CA AMT",
	SUM("CA FEE") "CA FEE"
FROM(SELECT ATP_ISO_ID,
	CASE WHEN ATP.ATP_ISO_ID IN (0, 10) THEN COUNT(TXN.TRL_ID) ELSE 0 END AS "SA VOL",
	CASE WHEN ATP.ATP_ISO_ID IN (0, 10) THEN SUM(TXN.TRL_AMT_TXN) ELSE 0 END AS "SA AMT",
	CASE WHEN ATP.ATP_ISO_ID IN (0, 10) THEN SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) ELSE 0 END AS "SA FEE",
	CASE WHEN ATP.ATP_ISO_ID = 20 THEN COUNT(TXN.TRL_ID) ELSE 0 END AS "CA VOL",
	CASE WHEN ATP.ATP_ISO_ID = 20 THEN SUM(TXN.TRL_AMT_TXN) ELSE 0 END AS "CA AMT",
	CASE WHEN ATP.ATP_ISO_ID = 20 THEN SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) ELSE 0 END AS "CA FEE"
	FROM TRANSACTION_LOG TXN
	JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
	JOIN ACCOUNT_TYPE ATP ON TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = ATP.ATP_ID
	LEFT JOIN CBC_MOVING_CASH CMV ON TXN.TRL_RRN = CMV.CMV_TXN_REF_NO
WHERE
	  TXN.TRL_TSC_CODE = 143
	  AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
	  AND {Txn_Date}
GROUP BY ATP.ATP_ISO_ID)
END BODY
SELECT CMV.CMV_CREATED_TS "DATE",
  CMV.CMV_CREATED_TS "TIME",
  NULL "SEQ NUMBER",
  SUBSTR(CMV.CMV_TXN_REF_NO, 7, 6) "TRACE NUMBER",
  ''MPM'' AS "TRAN MNEM",
  CMV.CMV_TXN_REF_NO "TRAN REF NO",
  NULL "ATM CARD NUMBER",
  CMV.CMV_FROM_ACC_NO "FROM ACCOUNT NO",
  CASE WHEN ACC.ACN_ACCOUNT_NUMBER_EKY_ID IS NOT NULL THEN ACC.ACN_ACCOUNT_NUMBER_EKY_ID ELSE 1314 END "TRL_ACCOUNT_1_ACN_ID_EKY_ID",
  CMV.CMV_RECV_MOBILE "TO MOBILE NO",
  CMV.CMV_AMOUNT "AMOUNT",
  NVL(CMV.CMV_TXN_FEE, 0) "TRAN FEE",
  CMV.CMV_STATUS "COMMENT"
  FROM CBC_MOVING_CASH CMV 
  LEFT JOIN ACCOUNT ACC ON CMV.CMV_FROM_ACC_NO = ACC.ACN_ACCOUNT_NUMBER
  WHERE CMV.CMV_TXN_RECV_MODE = ''02''
  AND {Deposit_Date}
END DEPOSIT
SELECT ''PENDING DEPOSIT TO ACCOUNT'' "TXN TYPE", SUM("SA VOL") "SA VOL",
	SUM("SA AMT") "SA AMT",
	SUM("SA FEE") "SA FEE",
	SUM("CA VOL") "CA VOL",
	SUM("CA AMT") "CA AMT",
	SUM("CA FEE") "CA FEE"
FROM(SELECT CMV_FROM_ACC_TYPE,
CASE WHEN CMV_FROM_ACC_TYPE IN (0, 10) THEN COUNT(CMV_ID) ELSE 0 END AS "SA VOL",
CASE WHEN CMV_FROM_ACC_TYPE IN (0, 10) THEN SUM(CMV_AMOUNT) ELSE 0 END AS "SA AMT",
CASE WHEN CMV_FROM_ACC_TYPE IN (0, 10) THEN SUM(NVL(CMV_TXN_FEE, 0)) ELSE 0 END AS "SA FEE",
CASE WHEN CMV_FROM_ACC_TYPE = 20 THEN COUNT(CMV_ID) ELSE 0 END AS "CA VOL",
CASE WHEN CMV_FROM_ACC_TYPE = 20 THEN SUM(CMV_AMOUNT) ELSE 0 END AS "CA AMT",
CASE WHEN CMV_FROM_ACC_TYPE = 20 THEN SUM(NVL(CMV_TXN_FEE, 0)) ELSE 0 END AS "CA FEE"
FROM CBC_MOVING_CASH CMV
WHERE CMV_TXN_RECV_MODE = ''02''
AND {Deposit_Date}
AND CMV.CMV_STATUS = ''PENDING''
GROUP BY CMV_FROM_ACC_TYPE)
END SUMMARY');

	i_TRAILER_QUERY := TO_CLOB('SELECT
       SUM(TXN.TRL_AMT_TXN) "AMOUNT",
       SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) "TRAN FEE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
	  LEFT JOIN CBC_MOVING_CASH CMV ON TXN.TRL_RRN = CMV.CMV_TXN_REF_NO
WHERE
      TXN.TRL_TSC_CODE = 143
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Txn_Date}
START SELECT SUM("SA VOL") "SA VOL",
	SUM("SA AMT") "SA AMT",
	SUM("SA FEE") "SA FEE",
	SUM("CA VOL") "CA VOL",
	SUM("CA AMT") "CA AMT",
	SUM("CA FEE") "CA FEE"
FROM(SELECT 
	CASE WHEN ATP.ATP_ISO_ID IN (0, 10) THEN COUNT(TXN.TRL_ID) ELSE 0 END AS "SA VOL",
	CASE WHEN ATP.ATP_ISO_ID IN (0, 10) THEN SUM(TXN.TRL_AMT_TXN) ELSE 0 END AS "SA AMT",
	CASE WHEN ATP.ATP_ISO_ID IN (0, 10) THEN SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) ELSE 0 END AS "SA FEE",
	CASE WHEN ATP.ATP_ISO_ID = 20 THEN COUNT(TXN.TRL_ID) ELSE 0 END AS "CA VOL",
	CASE WHEN ATP.ATP_ISO_ID = 20 THEN SUM(TXN.TRL_AMT_TXN) ELSE 0 END AS "CA AMT",
	CASE WHEN ATP.ATP_ISO_ID = 20 THEN SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) ELSE 0 END AS "CA FEE"
	FROM TRANSACTION_LOG TXN
	JOIN ACCOUNT_TYPE ATP ON TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = ATP.ATP_ID
	LEFT JOIN CBC_MOVING_CASH CMV ON TXN.TRL_RRN = CMV.CMV_TXN_REF_NO
WHERE
	  TXN.TRL_TSC_CODE = 143
	  AND (TXN.TRL_TQU_ID = ''F'' OR (TXN.TRL_TQU_ID = ''A'' AND CMV.CMV_STATUS IN (''PENDING'',''EXPIRED'',''BLOCKED'',''CANCELLED'')))
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
	  AND TXN.TRL_ACTION_RESPONSE_CODE = 0
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
	  AND {Txn_Date}
GROUP BY ATP.ATP_ISO_ID
UNION ALL
SELECT CASE WHEN CMV_FROM_ACC_TYPE IN (0, 10) THEN COUNT(CMV_ID) ELSE 0 END AS "SA VOL",
CASE WHEN CMV_FROM_ACC_TYPE IN (0, 10) THEN SUM(CMV_AMOUNT) ELSE 0 END AS "SA AMT",
CASE WHEN CMV_FROM_ACC_TYPE IN (0, 10) THEN SUM(NVL(CMV_TXN_FEE, 0)) ELSE 0 END AS "SA FEE",
CASE WHEN CMV_FROM_ACC_TYPE = 20 THEN COUNT(CMV_ID) ELSE 0 END AS "CA VOL",
CASE WHEN CMV_FROM_ACC_TYPE = 20 THEN SUM(CMV_AMOUNT) ELSE 0 END AS "CA AMT",
CASE WHEN CMV_FROM_ACC_TYPE = 20 THEN SUM(NVL(CMV_TXN_FEE, 0)) ELSE 0 END AS "CA FEE"
FROM CBC_MOVING_CASH CMV
WHERE CMV_TXN_RECV_MODE = ''02''
AND CMV.CMV_STATUS IN (''PENDING'',''EXPIRED'',''BLOCKED'',''CANCELLED'')
AND {Deposit_Date}
GROUP BY CMV_FROM_ACC_TYPE)
END BODY
SELECT SUM(CMV.CMV_AMOUNT) "AMOUNT", SUM(NVL(CMV.CMV_TXN_FEE, 0)) "TRAN FEE"
 FROM CBC_MOVING_CASH CMV 
 WHERE CMV.CMV_TXN_RECV_MODE = ''02''
 AND {Deposit_Date}
END DEPOSIT');
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = i_REPORT_NAME ;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') WHERE RED_NAME = i_REPORT_NAME AND red_ins_id = 2;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, '0010', '0112') WHERE RED_NAME = i_REPORT_NAME AND red_ins_id = 2;
	
END;
/