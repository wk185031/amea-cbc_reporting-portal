-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Control Report for PIN Mailer';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"CONTROL REPORT FOR PIN MAILER","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"97","pdfLength":"97","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","csvTxtLength":"9","pdfLength":"9","fieldType":"String","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":14,"sectionName":"14","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space1","csvTxtLength":"100","pdfLength":"100","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0,"delimiter":";"}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"10","fieldName":"TOTAL","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF PIN RECORDS GENERATED","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"11","fieldName":"TOTAL_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SPACE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"SPACE","csvTxtLength":"45","pdfLength":"45","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"TRAILER","csvTxtLength":"30","pdfLength":"30","eol":true,"defaultValue":"*** END OF REPORT ***"}]');
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"CONTROL REPORT FOR PIN MAILER","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"97","pdfLength":"97","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","csvTxtLength":"9","pdfLength":"9","fieldType":"String","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":14,"sectionName":"14","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space1","csvTxtLength":"100","pdfLength":"100","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0,"delimiter":";"}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"NEW","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"NUMBER OF PIN RECORDS GENERATED (NEW):","firstField":true},{"sequence":2,"sectionName":"2","fieldName":"NEW_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"REPLACEMENT","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF PIN RECORDS GENERATED (REPLACEMENT):","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"REPLACEMENT_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"PREGEN","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF PIN RECORDS GENERATED (PREGEN):","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"PREGEN_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"BULK","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF PIN RECORDS GENERATED (BULK UPLOAD):","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"BULK_UPLOADED_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"NEWLINE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":" ","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TOTAL","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL NUMBER OF PIN RECORDS GENERATED","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"TOTAL_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"SPACE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"SPACE","csvTxtLength":"45","pdfLength":"45","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"TRAILER","csvTxtLength":"30","pdfLength":"30","eol":true,"defaultValue":"*** END OF REPORT ***"}]');
	
	i_BODY_QUERY := TO_CLOB(
'SELECT 
  	(q1.New_Card_ATM + q1.New_Card_ATM_RENEWAL +q1.New_Cash_Card + q1.New_Cash_Card_RENEWAL + q1.DEBIT_BULK_UPLOADED_COUNT + 
    q1.DEBIT_BULK_UPLOADED_COUNT_RENEWAL + q1.CASH_CARD_BULK_UPLOADED_COUNT + q1.CASH_CARD_BULK_UPLOADED_COUNT_RENEWAL +q1.DEBIT_REPLACE 
	+q1.DEBIT_REPLACE_RENEWAL +q1.CASH_CARD_REPLACE + q1.CASH_CARD_REPLACE_RENEWAL + q1.DEBIT_PREGEN_COUNT + q1.DEBIT_PREGEN_COUNT_RENEWAL + q1.CASH_CARD_PREGEN_COUNT + q1.CASH_CARD_PREGEN_COUNT_RENEWAL) 
	AS TOTAL_COUNT
FROM
  	(SELECT
	--New Card
    	(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Ic.CRD_ID = req.DCR_CRD_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_REQUEST_TYPE=''Manual''
			AND req.DCR_CRN_ID IS NULL
    		AND req.DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS New_Card_ATM,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} Scr on Scr.CRN_ID = req.DCR_CRN_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_REQUEST_TYPE=''Manual''
    		 AND ExtractApprDate2(Scr.CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS New_Card_ATM_RENEWAL,
		 (SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} req
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Isc  On req.CCR_CLT_Id = Isc.CCM_CLT_ID
            join  {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Isc.Ccm_CRD_Id = Ic.Crd_Id
    		WHERE req.CCR_INS_ID = {Iss_Name}
			AND req.CCR_REQUEST_TYPE=''Manual''
			AND req.CCR_CRN_ID IS NULL
    		AND req.CCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS New_Cash_Card,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} req
			join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} Scr on Scr.CRN_ID = req.CCR_CRN_ID
    		WHERE req.CCR_INS_ID = {Iss_Name}
			AND req.CCR_REQUEST_TYPE=''Manual''
    		 AND ExtractApprDate2(Scr.CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS New_Cash_Card_RENEWAL,
		--    	Bulk Upload
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Ic.CRD_ID = req.DCR_CRD_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_REQUEST_TYPE=''Bulk upload''
			AND req.DCR_CRN_ID IS NULL
    		AND req.DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS DEBIT_BULK_UPLOADED_COUNT,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} Scr on Scr.CRN_ID = req.DCR_CRN_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_REQUEST_TYPE=''Bulk upload''
    		 AND ExtractApprDate2(Scr.CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS DEBIT_BULK_UPLOADED_COUNT_RENEWAL,
		    	(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} req
				Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Isc  On req.CCR_CLT_Id = Isc.CCM_CLT_ID
            join  {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Isc.Ccm_CRD_Id = Ic.Crd_Id
    		WHERE req.CCR_INS_ID = {Iss_Name}
			AND req.CCR_REQUEST_TYPE=''Bulk upload''
			AND req.CCR_CRN_ID IS NULL
    		AND req.CCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS CASH_CARD_BULK_UPLOADED_COUNT,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} req
			join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} Scr on Scr.CRN_ID = req.CCR_CRN_ID
    		WHERE req.CCR_INS_ID = {Iss_Name}
			AND req.CCR_REQUEST_TYPE=''Bulk upload''
    	 AND ExtractApprDate2(Scr.CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS CASH_CARD_BULK_UPLOADED_COUNT_RENEWAL,
				--  Replace  	
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Ic.CRD_ID = req.DCR_CRD_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_REQUEST_TYPE=''Replace''
			AND req.DCR_EMBOSSING_NAME IS NOT NULL
			AND req.DCR_CRN_ID IS NULL
    		AND req.DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS DEBIT_REPLACE,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} Scr on Scr.CRN_ID = req.DCR_CRN_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_REQUEST_TYPE=''Replace''
			AND req.DCR_EMBOSSING_NAME IS NOT NULL
    		 AND ExtractApprDate2(Scr.CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS DEBIT_REPLACE_RENEWAL,
		    	(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} req
				Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Isc  On req.CCR_CLT_Id = Isc.CCM_CLT_ID
            join  {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Isc.Ccm_CRD_Id = Ic.Crd_Id
    		WHERE req.CCR_INS_ID = {Iss_Name}
			AND req.CCR_REQUEST_TYPE=''Replace''
			AND req.CCR_EMBOSSING_NAME IS NOT NULL
			AND req.CCR_CRN_ID IS NULL
    		AND req.CCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS CASH_CARD_REPLACE,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} Scr on Scr.CRN_ID = req.DCR_CRN_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_REQUEST_TYPE=''Replace''
			AND req.DCR_EMBOSSING_NAME IS NOT NULL
    		 AND ExtractApprDate2(Scr.CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS CASH_CARD_REPLACE_RENEWAL,
		--  PREGEN COUNT	
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Ic.CRD_ID = req.DCR_CRD_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_EMBOSSING_NAME IS  NULL
			AND req.DCR_CRN_ID IS NULL
    		AND req.DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS DEBIT_PREGEN_COUNT,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
			join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} Scr on Scr.CRN_ID = req.DCR_CRN_ID
    		WHERE req.DCR_INS_ID = {Iss_Name}
			AND req.DCR_EMBOSSING_NAME IS  NULL
    		 AND ExtractApprDate2(Scr.CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS DEBIT_PREGEN_COUNT_RENEWAL,
		   (SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} req
				Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Isc  On req.CCR_CLT_Id = Isc.CCM_CLT_ID
            join  {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Isc.Ccm_CRD_Id = Ic.Crd_Id
    		WHERE req.CCR_INS_ID = {Iss_Name}
			AND req.CCR_EMBOSSING_NAME IS  NULL
			AND req.CCR_CRN_ID IS NULL
    		AND req.CCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS CASH_CARD_PREGEN_COUNT,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} req
			join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} Scr on Scr.CRN_ID = req.CCR_CRN_ID
    		WHERE req.CCR_INS_ID = {Iss_Name}
			AND req.CCR_EMBOSSING_NAME IS  NULL
    		 AND ExtractApprDate2(Scr.CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS CASH_CARD_PREGEN_COUNT_RENEWAL,
		(SELECT COUNT(*)
    		FROM {DCMS_Schema}.SUPPORT_REPIN@{DB_LINK_DCMS} req
    		WHERE req.REP_INS_ID = {Iss_Name}
    		 AND To_Date(Sdrp.Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
    	) AS RESET_PIN
  	From Dual
) q1
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