DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- List of Possible Adjustments
	i_BODY_QUERY := TO_CLOB('		
    SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CTR.CTR_MNEM "TRAN MNEM",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "TYPE",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      substr(ATA.ATA_TXN_STATE, 1, INSTR(ATA.ATA_TXN_STATE, ''('') - 1) "COMMENT"
	FROM
      ATM_TXN_ACTIVITY_LOG ATA
      JOIN TRANSACTION_LOG TXN ON ATA.ATA_TRL_ID = TXN.TRL_ID 
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	WHERE
      TXN.TRL_POST_COMPLETION_CODE IS NULL 
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      AND (
        ATA.ATA_TXN_STATE like ''%(Reversal)'' OR 
        ATA.ATA_TXN_STATE like ''%(Reversal completed)'' OR 
        ATA.ATA_TXN_STATE like ''%(Force post reversal)'' OR 
        ATA.ATA_TXN_STATE like ''%(Force post partial reversal)'' OR
        ATA.ATA_TXN_STATE like ''%(Force post partial reversal)'' OR
        ATA.ATA_TXN_STATE like ''%(Partial reversal completed)'' OR 
        ATA.ATA_TXN_STATE like ''%unknown dispense reported''
      )
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
	ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC,
      TXN.TRL_RRN ASC	
	');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'List of Possible Adjustments';




-- ATM Availability
	i_BODY_QUERY := TO_CLOB('		
    SELECT
     AST.AST_ARE_NAME "REGION",
     ABR.ABR_CODE "BRANCH CODE",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     AST.AST_ID "STATION ID",
     round(SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100), 2) "UNAVAILABLE",
     round(100 - (SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100)), 2) "AVAILABLE",    
     CASE WHEN SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / ({Total_Day} * 24 * 60 * 60) * 100) < 5 THEN ''1'' ELSE ''0'' END "STANDARD"
FROM
      ATM_STATIONS AST
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD_AST_ID
WHERE
      {Txn_Date}
GROUP BY
      AST.AST_ARE_NAME,
      ABR.ABR_CODE,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID,
      AST.AST_ID
ORDER BY
      AST.AST_ARE_NAME  ASC,
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC	
	');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'ATM Availability';
	update report_definition set red_header_fields='[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"ATM CENTER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"ATM CENTER","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"CBC ATM AVAILABILITY REPORT (INTERNAL)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CBC ATM AVAILABILITY REPORT (INTERNAL)","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"FROM  :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FROM  :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"From Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Defect","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Defect","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"5%","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"5%","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"TO    :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TO    :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"To Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Bancnet Standard","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Bancnet Standard","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"95%","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"95%","eol":true,"leftJustified":true,"padFieldLength":0}]' where RED_NAME = 'ATM Availability';
    update report_definition set red_body_fields=replace(red_body_fields, '"delimiter":";"', '"delimiter":","') where RED_NAME = 'ATM Availability';

END;
/