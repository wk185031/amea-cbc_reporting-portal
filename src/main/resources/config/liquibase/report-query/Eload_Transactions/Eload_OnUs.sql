-- Tracking					    Date			Name	Description
-- Eload Reports Specification	02-JUL-2021		GS		Modify and restructure the logic of Eload Reports
-- CBCAXUPISSLOG-527 			05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- 								14-JUL-2021		KW		Split into OnUs Acq Iss

DECLARE
	i_HEADER_FIELDS CLOB;
	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- Approved Eload On-Us Transactions
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","pdfLength":"57","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"APPROVED ELOAD ON-US TRANSACTIONS","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Name2","csvTxtLength":"53","pdfLength":"53","fieldType":"String","delimiter":";","defaultValue":"SUMMARY OF APPROVED ELOAD ON-US TRANSACTIONS","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"22","fieldName":"EMPTY","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"64","pdfLength":"64","fieldType":"String","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"11","fieldName":"File Name3","csvTxtLength":"47","pdfLength":"47","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"12","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"13","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"14","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":";","defaultValue":"","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"15","fieldName":"Space1","csvTxtLength":"40","pdfLength":"40","fieldType":"String","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"16","fieldName":"Space2","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"17","fieldName":"Space3","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"18","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"19","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"20","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"21","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Space2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Space3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TRACE","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"TRACE","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"BRANCH","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"BRANCH","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"TRANSMITTING","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRANSMITTING","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Space6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"TRANS","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"TRANS","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"RECEIVING","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"RECEIVING","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"DATE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"DATE","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"SEQ NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":"SEQ NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","bodyHeader":true,"delimiter":";","defaultValue":"NO","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"CARD NO","csvTxtLength":"22","pdfLength":"22","fieldType":"String","defaultValue":"CARD NO","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"String","defaultValue":"AMOUNT","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"ACCOUNT NO","bodyHeader":true,"delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":22,"sectionName":"22","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":23,"sectionName":"23","fieldName":"ISSUER BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":25,"sectionName":"25","fieldName":"ATM CARD NUMBER","csvTxtLength":"22","pdfLength":"22","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":26,"sectionName":"26","fieldName":"AMOUNT","csvTxtLength":"26","pdfLength":"26","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","eol":true,"leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":28,"sectionName":"28","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"BRANCH","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"TERM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"TERM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"BRANCH","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","defaultValue":"BRANCH","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":31,"sectionName":"31","fieldName":"CODE","csvTxtLength":"27","pdfLength":"27","fieldType":"String","delimiter":";","defaultValue":"CODE","bodyHeader":true,"eol":false,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"NO","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NO","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"NAME","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"VOL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"VOL","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"AMOUNT","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"defaultValue":"AMOUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"BRANCH NAME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":39,"sectionName":"39","fieldName":"TRAN COUNT","csvTxtLength":"25","pdfLength":"25","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"AMOUNT","csvTxtLength":"27","pdfLength":"27","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');

	i_BODY_QUERY := TO_CLOB('
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "ISSUER BRANCH CODE",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      COUNT(TXN.TRL_ID) "TRAN COUNT",
      SUM(TXN.TRL_AMT_TXN) "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
GROUP BY
      ABR.ABR_CODE,
      ABR.ABR_NAME,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC
END
	');
	
	i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
START SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
WHERE
      TXN.TRL_TSC_CODE = 52
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Txn_Date}
END
	');
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Approved Eload On-Us Transactions';	  

END;
/