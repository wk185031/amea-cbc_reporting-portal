-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- Report revision		25-JUL-2021		NY	 	Initial query, separate CBC/CBS report definition update
-- Report revision		25-JUL-2021		NY		Update based on excel spec
-- Onus					06-AUG-2021		NY		Use left join consistently to avoid data mismatch to master 
-- CBCAXUPISSLOG-637	25-AUG-2021		NY		Exclude failed reversal
-- CBCAXUPISSLOG-869	01-SEP-2021		NY		Fix blank tran mnem for txn from BRM
-- CBCAXUPISSLOG-868	02-SEP-2021		NY		Generate blank report with header if no data retrieved
-- CBCAXUPISSLOG-806	20-OCT-2021		NY		Fix oracle error invalid number
-- CBCAXUPISSLOG-1171	24-MAR-2022		WY		Add terminal name (location) in the report

DECLARE
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
	i_PROCESSING_CLASS VARCHAR2(200) := 'my.com.mandrill.base.reporting.reportProcessor.BranchReportSplitFileProcessor';
BEGIN 

-- EFT - ATM Transaction List (Other Branch)

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"EFT/ATM TRANSACTION LIST (OTHER BRANCH)","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"111","pdfLength":"111","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"EFC015-02","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"EFC015-02","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SEQ","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"SEQ","firstField":true,"bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"TRACE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"ATM CARD NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"ATM CARD NUMBER","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"DATE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"TRAN","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"ACCOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"TYPE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"AMOUNT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"AMOUNT","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"VOID","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"VOID","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"COMMENT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMMENT","bodyHeader":true,"eol":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NUMBER","firstField":true,"bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"MNEM","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":16,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":17,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","firstField":true,"defaultValue":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"6","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","defaultValue":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"6","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":19,"sectionName":"18","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldLength":"19","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"19","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":21,"sectionName":"20","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":22,"sectionName":"21","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":23,"sectionName":"22","fieldName":"FROM ACCOUNT NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldLength":"16","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"23","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":25,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":26,"sectionName":"25","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"3","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[]');

-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"EFT/ATM TRANSACTION LIST (OTHER BRANCH)","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"111","pdfLength":"111","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"EFC015-02","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"EFC015-02","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SEQ","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"SEQ","firstField":true,"bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"TRACE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"ATM CARD NUMBER","csvTxtLength":"24","pdfLength":"24","fieldType":"String","defaultValue":"ATM CARD NUMBER","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"DATE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"TRAN","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"ACCOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"TYPE","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"AMOUNT","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"AMOUNT","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"VOID","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"VOID","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"COMMENT","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMMENT","bodyHeader":true,"eol":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NUMBER","firstField":true,"bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"NUMBER","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"MNEM","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":16,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":17,"sectionName":"16","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","firstField":true,"defaultValue":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"6","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":18,"sectionName":"17","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","defaultValue":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"6","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":19,"sectionName":"18","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldLength":"19","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":20,"sectionName":"19","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":21,"sectionName":"20","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":22,"sectionName":"21","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":23,"sectionName":"22","fieldName":"FROM ACCOUNT NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","leftJustified":false,"decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldLength":"16","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":24,"sectionName":"23","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":25,"sectionName":"24","fieldName":"AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0},{"sequence":26,"sectionName":"25","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":"3","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"26","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"leftJustified":false,"decrypt":false,"decryptionKey":null,"padFieldLength":0}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[]');

	i_BODY_QUERY := TO_CLOB('		
	SELECT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) || '' - '' || AST.AST_ALO_LOCATION_ID "TERMINAL",
      --AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TYPE",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN ''Full Reversal'' WHEN TXN.TRL_ACTION_RESPONSE_CODE != 0 THEN ARC.ARC_NAME ELSE '''' END AS "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
      LEFT JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
      LEFT JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	WHERE
      TXN.TRL_TSC_CODE IN (1, 128, 31, 142, 143)
      AND (TXN.TRL_TQU_ID =''F'' OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND CPD.CPD_CODE NOT IN (''80'',''81'',''82'',''83'')
      AND SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) != TXNC.TRL_CARD_BRANCH
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345''
      -- AND ABR.ABR_CODE = {BRANCH_CODE}
      AND {Txn_Date}
	ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC	
	');	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS 
	WHERE RED_NAME = 'EFT - ATM Transaction List (Other Branch)' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_PROCESSING_CLASS = i_PROCESSING_CLASS 
	WHERE RED_NAME = 'EFT - ATM Transaction List (Other Branch)' AND RED_INS_ID = 2;
	
END;
/