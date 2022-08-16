-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Initial from UAT env
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- Rel-20210823			22-AUG-2021		KW		Revise query
-- CBCAXUPISSLOG-932	29-SEP-2021		GS		Revise query, added scenario: Presenter Error (Cash Retract), Suspect Dispense, Transactions without Cash Taken
-- CBCAXUPISSLOG-932	05-OCT-2021		GS		Revise query, added scenario: Unable to Dispense
-- CBCAXUPISSLOG-1167   26-JUL-2022		LJL		Revise Branch Code/ Terminal / ATM_Branchs table

DECLARE

	i_REPORT_NAME VARCHAR2(100) := 'List of Possible Adjustments';
	i_PROCESSING_CLASS VARCHAR2(100) := 'my.com.mandrill.base.reporting.reportProcessor.BranchReportSplitFileProcessor';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"LIST OF POSSIBLE ADJUSTMENTS","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"111","pdfLength":"111","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"SEQ","csvTxtLength":"7","pdfLength":"7","fieldType":"String","defaultValue":"SEQ","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TRACE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TRAN","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"ACCT","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"ACCT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BANK","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"CARD","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"ACCOUNT","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"TRANS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"RESPONSE","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"RESPONSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"REMARKS","csvTxtLength":"23","pdfLength":"23","fieldType":"String","defaultValue":"REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"24","pdfLength":"24","fieldType":"String","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NO","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"NO","csvTxtLength":"7","pdfLength":"7","fieldType":"String","defaultValue":"NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"MNEM","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NUMBER","csvTxtLength":"21","pdfLength":"21","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"defaultValue":"AMOUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"35","fieldName":"TERMINAL","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":24,"sectionName":"23","fieldName":"DATE","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"24","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"25","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"26","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","defaultValue":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":28,"sectionName":"27","fieldName":"TRAN MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"28","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"29","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":31,"sectionName":"30","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"31","fieldName":"FROM ACCOUNT NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":33,"sectionName":"32","fieldName":"AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"33","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"34","fieldName":"COMMENT","csvTxtLength":"35","pdfLength":"35","fieldType":"String","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"81","pdfLength":"81","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"TOTAL :","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"56","pdfLength":"56","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"54","pdfLength":"54","fieldType":"String","defaultValue":"LIST OF POSSIBLE ADJUSTMENTS","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"BRANCH CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"BRANCH NAME","csvTxtLength":"111","pdfLength":"111","fieldType":"String","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"17","pdfLength":"17","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"EFP000-0","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"EFP000-0","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Space1","csvTxtLength":"120","pdfLength":"120","fieldType":"String","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"DATE","bodyHeader":true,"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"TIME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"SEQ","csvTxtLength":"7","pdfLength":"7","fieldType":"String","defaultValue":"SEQ","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"TRACE","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"TRACE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"TRAN","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TRAN","bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"ACCT","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"ACCT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"BANK","csvTxtLength":"17","pdfLength":"17","fieldType":"String","defaultValue":"BANK","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"CARD","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"ACCOUNT","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":"ACCOUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"TRANS","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"TRANS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"RESPONSE","csvTxtLength":"18","pdfLength":"18","fieldType":"String","defaultValue":"RESPONSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"REMARKS","csvTxtLength":"23","pdfLength":"23","fieldType":"String","defaultValue":"REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"24","pdfLength":"24","fieldType":"String","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"NO","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"NO","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"NO","csvTxtLength":"7","pdfLength":"7","fieldType":"String","defaultValue":"NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TYPE","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"MNEM","csvTxtLength":"16","pdfLength":"16","fieldType":"String","defaultValue":"MNEM","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"NUMBER","csvTxtLength":"21","pdfLength":"21","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"NUMBER","csvTxtLength":"19","pdfLength":"19","fieldType":"String","defaultValue":"NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"String","bodyHeader":true,"defaultValue":"AMOUNT","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"CODE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"35","fieldName":"TERMINAL","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"group":true,"decrypt":false},{"sequence":24,"sectionName":"23","fieldName":"DATE","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"24","fieldName":"TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"25","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","firstField":true,"defaultValue":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":27,"sectionName":"26","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"Number","defaultValue":"","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":28,"sectionName":"27","fieldName":"TRAN MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"28","fieldName":"TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"29","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":31,"sectionName":"30","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"31","fieldName":"FROM ACCOUNT NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":33,"sectionName":"32","fieldName":"AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"33","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":35,"sectionName":"34","fieldName":"COMMENT","csvTxtLength":"35","pdfLength":"35","fieldType":"String","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
 	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"81","pdfLength":"81","fieldType":"String","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"TOTAL :","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"TOTAL AMOUNT","csvTxtLength":"18","pdfLength":"18","fieldType":"Decimal","fieldFormat":"#,##0.00","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');


	i_BODY_QUERY := TO_CLOB('
	with TXN_ACTIVITY as (
  		select * from (select ATA_TRL_ID, ATA_TXN_STATE, ROW_NUMBER() OVER (partition by ATA_TRL_ID order by ATA_SEQ_NBR desc) "ROWCNT" from ATM_TXN_ACTIVITY_LOG 
    		where ATA_TRL_ID is not null 
    		and (ATA_TXN_STATE = ''Incorrect dispense (No reversal)'' OR ATA_TXN_STATE = ''Cash take timeout'' OR ATA_TXN_STATE LIKE ''Suspect dispense%'')
    		and ATA_LAST_UPDATE_TS >= TO_DATE({Txn_Start_Ts}, ''YYYYMMDD HH24:MI:SS'') AND ATA_LAST_UPDATE_TS < TO_DATE({Txn_End_Ts},''YYYYMMDD HH24:MI:SS'') 
  		) where ROWCNT = 1
	)
  , TXN_ACTIVITY_Condition as (
  		select * from (select ATA_TRL_ID, ATA_TXN_STATE, ATA_TXN_SEQ_NBR, ATA_AST_ID, ATA_BUS_DATE from ATM_TXN_ACTIVITY_LOG 
    		where (ATA_TXN_STATE = ''Failed dispense (Force post reversal)'' OR ATA_TXN_STATE = ''Command reject (Force post reversal)'' OR ATA_TXN_STATE LIKE ''Suspect dispense%'' OR ATA_TXN_STATE LIKE ''Cash take timeout%'')
    		and ATA_LAST_UPDATE_TS >= TO_DATE({Txn_Start_Ts}, ''YYYYMMDD HH24:MI:SS'') AND ATA_LAST_UPDATE_TS < TO_DATE({Txn_End_Ts},''YYYYMMDD HH24:MI:SS'') 
  		)
	)
  , TXN_ACTIVITY_Cash_Retract as (
  		select * from (select ATAL.ATA_TRL_ID, TXNACT.ATA_TXN_STATE, ATAL.ATA_TXN_SEQ_NBR, ATAL.ATA_AST_ID from ATM_TXN_ACTIVITY_LOG ATAL
        left join TXN_ACTIVITY_Condition TXNACT on TXNACT.ATA_BUS_DATE = ATAL.ATA_BUS_DATE AND TXNACT.ATA_TXN_SEQ_NBR = ATAL.ATA_TXN_SEQ_NBR AND TXNACT.ATA_AST_ID = ATAL.ATA_AST_ID
    		where ATAL.ATA_TRL_ID is not null 
			and (ATAL.ATA_TXN_STATE = ''Authorized'')
			and ATA_LAST_UPDATE_TS >= TO_DATE({Txn_Start_Ts}, ''YYYYMMDD HH24:MI:SS'') AND ATA_LAST_UPDATE_TS < TO_DATE({Txn_End_Ts},''YYYYMMDD HH24:MI:SS'') 
  		)
	)
    SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
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
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      CASE WHEN ATA.ATA_TXN_STATE IS NOT NULL THEN ATA.ATA_TXN_STATE 
        WHEN TXN.TRL_ACTION_RESPONSE_CODE = 907 THEN ''Issuer or Switch Inoperative''
        WHEN TXN.TRL_ACTION_RESPONSE_CODE = 909 THEN ''System Malfunction''
        WHEN TXN.TRL_ACTION_RESPONSE_CODE = 911 THEN ''Card Issuer Timed Out''
        ELSE '''' END AS "COMMENT",
      TXN.TRL_SYSTEM_TIMESTAMP "SYSTEM TIMESTAMP"
	FROM
      TRANSACTION_LOG TXN 
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN TXN_ACTIVITY ATA ON ATA.ATA_TRL_ID = TXN.TRL_EXT_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON 
        CTR.CTR_CODE = CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000008882'') THEN 52  
        WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL) THEN 44  
        ELSE TXN.TRL_TSC_CODE END  
        AND CTR.CTR_CHANNEL = CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' WHEN (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN CONCAT(''I-'', TXNC.TRL_ORIGIN_CHANNEL) ELSE TXNC.TRL_ORIGIN_CHANNEL END
        AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      WHERE
	  TXN.TRL_TQU_ID IN (''F'',''R'')
      AND (TXN.TRL_ACTION_RESPONSE_CODE IN (907,909,911)
      OR (
        ATA.ATA_TXN_STATE IS NOT NULL
      ))
      -- AND SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = {BRANCH_CODE}
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      AND TXNC.TRL_ORIGIN_CHANNEL in (''ATM'',''BRM'')
      AND TXN.TRL_TSC_CODE in (1,142,143)
      AND {Txn_Date}
  UNION ALL
  SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
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
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      CASE WHEN (ATA.ATA_TXN_STATE = ''Suspect dispense - Cash Retract (No reversal)'' OR ATA.ATA_TXN_STATE = ''Cash take timeout - Cash Retract'') THEN ''Cash Retract''
        WHEN (ATA.ATA_TXN_STATE = ''Failed dispense (Force post reversal)'' OR ATA.ATA_TXN_STATE = ''Command reject (Force post reversal)'') THEN ''Unable to Dispense''
        WHEN ATA.ATA_TXN_STATE IS NOT NULL THEN ATA.ATA_TXN_STATE 
        WHEN TXN.TRL_ACTION_RESPONSE_CODE = 907 THEN ''Issuer or Switch Inoperative''
        WHEN TXN.TRL_ACTION_RESPONSE_CODE = 909 THEN ''System Malfunction''
        WHEN TXN.TRL_ACTION_RESPONSE_CODE = 911 THEN ''Card Issuer Timed Out''
        ELSE '''' END AS "COMMENT",
      TXN.TRL_SYSTEM_TIMESTAMP "SYSTEM TIMESTAMP"
	FROM
      TRANSACTION_LOG TXN 
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN TXN_ACTIVITY_Cash_Retract ATA ON ATA.ATA_TRL_ID = TXN.TRL_EXT_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON 
        CTR.CTR_CODE = CASE WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = ''0000008882'') THEN 52  
        WHEN (TXNC.TRL_ORIGIN_CHANNEL=''BNT'' AND TXN.TRL_TSC_CODE = 1 AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL) THEN 44  
        ELSE TXN.TRL_TSC_CODE END  
        AND CTR.CTR_CHANNEL = CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' WHEN (TXN.TRL_TSC_CODE = 48 OR TXN.TRL_DEO_NAME = {V_IE_Deo_Name} OR TXN.TRL_ISS_NAME = {V_IE_Iss_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id} OR LPAD(TXN.TRL_FRD_REV_INST_ID, 10, 0) = {V_IE_Acqr_Inst_Id}) THEN CONCAT(''I-'', TXNC.TRL_ORIGIN_CHANNEL) ELSE TXNC.TRL_ORIGIN_CHANNEL END
        AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      LEFT JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      WHERE
  	  TXN.TRL_TQU_ID IN (''F'',''R'')
      AND ATA.ATA_TXN_STATE IS NOT NULL
      -- AND ABR.ABR_CODE = {BRANCH_CODE}
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      AND TXNC.TRL_ORIGIN_CHANNEL in (''ATM'',''BRM'')
      AND TXN.TRL_TSC_CODE in (1,142,143)
      AND {Txn_Date}
	ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC,
      "SYSTEM TIMESTAMP" ASC,
      "SEQ NUMBER" ASC,
      "TRACE NUMBER" ASC	
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