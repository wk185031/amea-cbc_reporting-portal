-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS
-- Rel-20210827			26-AUG-2021		WY		Revise report format and query

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Transmittal Release Report for All Branches';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 
	
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"",
"leftJustified":true,"padFieldLength":0,"firstField":true},
{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"",
"defaultValue":"0010 CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"eol":true},
{"sequence":3,"sectionName":"3","fieldName":"Space","csvTxtLength":"90","pdfLength":"90","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"",
"leftJustified":true,"padFieldLength":0,"firstField":true},
{"sequence":4,"sectionName":"4","fieldName":"File Name1","csvTxtLength":"120", "pdfLength":"120", "fieldType":"String","delimiter":"","fieldFormat":"",
"defaultValue":"NEW PINS TRANSMITTAL RELEASE REPORT - ALL BRANCHES","eol":true,"leftJustified":true,"padFieldLength":0},
{"sequence":5,"sectionName":"5","fieldName":"Space","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"",
"leftJustified":true,"padFieldLength":0,"firstField":true},
{"sequence":6,"sectionName":"6","fieldName":"As of Date Value","csvTxtLength":"20","pdfLength":"20","fieldType":"Date", "defaultValue":"","delimiter":"",
"fieldFormat":"dd MMM yyyy","leftJustified":false,"padFieldLength":0,"eol":true},
{"sequence":7,"sectionName":"7","fieldName":"Space", "csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","eol":true, 
"leftJustified":true, "padFieldLength":0},
{"sequence":8,"sectionName":"8", "fieldName":"Space", "csvTxtLength":"10", "pdfLength":"10", "fieldType":"String", "delimiter":"", "fieldFormat":"", "eol":true, 
"leftJustified":true,"padFieldLength":0}]');
	
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"5","pdfLength":"5", "fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"",
"firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":2,"sectionName":"2","fieldName":"Trx","csvTxtLength":"40","pdfLength":"40", "fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TRANS #",
"firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}, 
{"sequence":3,"sectionName":"3","fieldName":"Total","csvTxtLength":"30","pdfLength":"30","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TOTAL",
"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":4,"sectionName":"4","fieldName":"Date Received","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":"","fieldFormat":"",
"defaultValue":"DATE RECEIVED BY BRANCH","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},
{"sequence":5,"sectionName":"5","fieldName":"Bag No","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"BAG NO.",
"bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}, 	
{"sequence":6,"sectionName":"6","fieldName":"Space","csvTxtLength":"5","pdfLength":"5", "fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"",
"firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},	
{"sequence":7,"sectionName":"7","fieldName":"BRANCH_CODE","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,
"padFieldLength":0,"decrypt":false},	
{"sequence":8, "sectionName":"8", "fieldName":"TOTAL", "csvTxtLength":"30", "pdfLength":"30", "fieldType":"String","delimiter":"","fieldFormat":"", "leftJustified":true, 
"padFieldLength":0,"decrypt":false},
{"sequence":9, "sectionName":"9", "fieldName":"Date Received", "csvTxtLength":"50", "pdfLength":"50", "fieldType":"String","delimiter":"","fieldFormat":"", "leftJustified":true, 
"padFieldLength":0,"decrypt":false,"defaultValue":"____________________________"},
{"sequence":10, "sectionName":"10", "fieldName":"Bag No", "csvTxtLength":"50", "pdfLength":"50", "fieldType":"String","delimiter":"","fieldFormat":"", "leftJustified":true, 
"padFieldLength":0,"decrypt":false,"defaultValue":"____________________________","eol":true}]');
	
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"5", "pdfLength":"5", "fieldType":"String", "delimiter":"","fieldFormat":"","defaultValue":"","firstField":true,"leftJustified":true,"padFieldLength":0, "decrypt":false}, 
	{"sequence":2,"sectionName":"2","fieldName":"Grand Total","csvTxtLength":"40", "pdfLength":"40", "fieldType":"String", "delimiter":"","fieldFormat":"","defaultValue":"GRAND TOTAL :","firstField":false,"leftJustified":true,"padFieldLength":0, "decrypt":false}, 
	{"sequence":3,"sectionName":"3","fieldName":"TOTAL","csvTxtLength":"30", "pdfLength":"30", "fieldType":"String", "delimiter":"", "fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');
	
	i_BODY_QUERY := TO_CLOB('
	SELECT bc || ''-'' || update_date as BRANCH_CODE, COUNT(*) AS TOTAL FROM(
	select 
	  BRN_CODE as bc,
	  to_char(DCR_UPDATED_TS,''MMddYY'') as update_date
	from {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS}
	 join  {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  On CRD_ID = DCR_CRD_ID
	  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on DCR_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = DCR_BRN_ID
	  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = DCR_PRS_ID
	  join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = DCR_CLT_ID
	where 
	  INS_ID = {Iss_Id}
	  AND DCR_CRN_ID is null
	  AND DCR_STS_ID in (68,70)
	  AND DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''YYYYMMdd hh24:mi:ss'') AND TO_DATE({To_Date},''YYYYMMdd hh24:mi:ss'')
	union all
		select 
	  BRN_CODE as bc,
	  to_char(DCR_UPDATED_TS,''MMddYY'') as update_date
	from {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS}
	join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS}  on CRN_ID = DCR_CRN_ID
	  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on DCR_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = DCR_BRN_ID
	  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = DCR_PRS_ID
	  join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = DCR_CLT_ID
	where 
	  INS_ID = {Iss_Id}
	  AND DCR_STS_ID in (68,70)
	  AND ExtractApprDate2(CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date},''YYYY-MM-DD HH24:MI:SS'')
	  union all
	select 
	  BRN_CODE as bc,
	  to_char(CCR_UPDATED_TS,''MMddYY'') as update_date
	from {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS}
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}   On CCR_CLT_Id = CCM_CLT_ID
 join  {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  On Ccm_CRD_Id = Crd_Id
	  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CCR_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = CCR_BRN_ID
	  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = CCR_PRS_ID
	  left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = CCR_CLT_ID
	  left join {DCMS_Schema}.MASTER_CORPORATE_CLIENT@{DB_LINK_DCMS} on CCL_ID = CCR_CCL_ID
	where 
	  INS_ID = {Iss_Id}
	  AND CCR_CRN_ID is null
	  AND CCR_STS_ID in (68,70)
	  AND CCR_CREATED_TS BETWEEN TO_DATE({From_Date},''YYYYMMdd hh24:mi:ss'') AND TO_DATE({To_Date},''YYYYMMdd hh24:mi:ss'')
	  union all
	  	select 
	  BRN_CODE as bc,
	  to_char(CCR_UPDATED_TS,''MMddYY'') as update_date
	from {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS}
	 join  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} on CRN_ID = CCR_CRN_ID
	  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CCR_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = CCR_BRN_ID
	  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = CCR_PRS_ID
	  left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = CCR_CLT_ID
	  left join {DCMS_Schema}.MASTER_CORPORATE_CLIENT@{DB_LINK_DCMS} on CCL_ID = CCR_CCL_ID
	where 
	  INS_ID = {Iss_Id}
	  AND CCR_STS_ID in (68,70)
	  AND ExtractApprDate2(CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date},''YYYY-MM-DD HH24:MI:SS'')
	  )
	  GROUP BY bc, update_date
	  ORDER BY bc, update_date
	
	');	
	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = i_REPORT_NAME;
	
	UPDATE REPORT_DEFINITION SET RED_FILE_FORMAT = 'TXT,PDF' WHERE RED_NAME = i_REPORT_NAME;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, '0010', '0112') WHERE RED_NAME = i_REPORT_NAME AND red_ins_id = 2;
	
	update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') WHERE RED_NAME = i_REPORT_NAME AND red_ins_id = 2;
	
END;
/