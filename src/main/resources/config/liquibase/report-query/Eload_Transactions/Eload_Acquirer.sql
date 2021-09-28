-- Tracking					    Date			Name	Description
-- Eload Reports Specification	02-JUL-2021		GS		Modify and restructure the logic of Eload Reports
-- CBCAXUPISSLOG-527 			05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- 								14-JUL-2021		KW		Split into OnUs Acq Iss
-- CBCAXUPISSLOG-849			06-AUG-2021		NY		Exclude reversal as report dont have mnemonic to distinguish thoses
-- Eload						06-AUG-2021		NY		Use left join consistently to avoid data mismatch to master
-- Eload 						07-AUG-2021		NY		Fix empty report
-- Eload						12-AUG-2021		NY		Fix column not fully display in excel
-- Eload						15-AUG-2021		NY		Parameterized acq bank
-- CBCAXUPISSLOG-935			28-AUG-2021		NY		Exclude approved with post completion code R

DECLARE

    i_HEADER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 
	  
-- Approved Eload Acquirer Transactions

-- CBC header fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"APPROVED ELOAD TRANSACTIONS AS ACQUIRING BANK","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Name2","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"SUMMARY OF APPROVED ELOAD TRANSACTIONS AS ACQUIRING BANK","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"22","fieldName":"Empty","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"23","fieldName":"Empty","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"24","fieldName":"Empty","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"25","fieldName":"Empty","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"64","pdfLength":"64","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"11","fieldName":"File Name3","csvTxtLength":"47","pdfLength":"47","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"12","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"13","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"14","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"15","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"16","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"17","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"18","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"19","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"20","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"21","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
-- CBS header fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"APPROVED ELOAD TRANSACTIONS AS ACQUIRING BANK","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Name2","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"SUMMARY OF APPROVED ELOAD TRANSACTIONS AS ACQUIRING BANK","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"22","fieldName":"Empty","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"23","fieldName":"Empty","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"24","fieldName":"Empty","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"25","fieldName":"Empty","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"64","pdfLength":"64","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"11","fieldName":"File Name3","csvTxtLength":"47","pdfLength":"47","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"12","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"13","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"14","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"15","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"16","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"17","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"18","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"19","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"20","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":25,"sectionName":"21","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ACQUIRING BANK","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","defaultValue":"ACQUIRING BANK","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Space4","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Space5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"TRACE","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"TRACE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"BRANCH","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"TRANSMITTING","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRANSMITTING","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"TRANS","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"TRANS","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"RECEIVING","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"RECEIVING","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"fieldFormat":"","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"BRAN","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"BRAN","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"TERM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TERM","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" DATE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"SEQ NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" SEQ NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":" NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CARD NO","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":" CARD NO","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":" AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":" ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"4","pdfLength":"4","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"32","fieldName":"ISSUER BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":34,"sectionName":"34","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"35","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"ISSUER BANK","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"ISSUER BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"Space10","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"COUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"AMOUNT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":41,"sectionName":"41","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"NAME","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":43,"sectionName":"43","fieldName":"Space11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":44,"sectionName":"44","fieldName":"Space12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":45,"sectionName":"45","fieldName":"BANK CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":46,"sectionName":"46","fieldName":"BANK NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":47,"sectionName":"47","fieldName":"TRAN COUNT","csvTxtLength":"25","pdfLength":"25","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"fieldFormat":","},{"sequence":48,"sectionName":"48","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');

	i_BODY_QUERY := TO_CLOB('
SELECT
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "ISSUER BRANCH CODE",
      ABR.ABR_CODE "BRANCH CODE",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      {V_Acq_Name} AS "ACQUIRER BANK MNEM",
      CBA.CBA_CODE AS "BANK CODE",
      CBA.CBA_NAME AS "BANK NAME",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Bank_Code}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      CBA.CBA_CODE AS "BANK CODE",
      CBA.CBA_NAME AS "BANK NAME",
      COUNT(TXN.TRL_ID) "TRAN COUNT",
      SUM(TXN.TRL_AMT_TXN) "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Txn_Date}
GROUP BY
      CBA.CBA_CODE,
      CBA.CBA_NAME
ORDER BY
      CBA.CBA_CODE ASC
END
	');

	i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Bank_Code}
      AND {Txn_Date}
START SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Txn_Date}
END
	');
	
	UPDATE REPORT_DEFINITION SET 
	    RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Approved Eload Acquirer Transactions' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
	    RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Approved Eload Acquirer Transactions' AND RED_INS_ID = 2;

	
END;
/
