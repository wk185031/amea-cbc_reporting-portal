-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS
-- Rel-20210827			26-AUG-2021		WY		Revise report format and query
-- Rel-20220322			22-MAR-2022		KW		Convert UTC timezone

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Transmittal Release Report for All Branches';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 
	
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Space","csvTxtLength":"100","pdfLength":"70","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"100","pdfLength":"70","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"0010 CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"eol":true},{"sequence":3,"sectionName":"3","fieldName":"Space","csvTxtLength":"90","pdfLength":"60","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":4,"sectionName":"4","fieldName":"File Name1","csvTxtLength":"120","pdfLength":"70","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"NEW PINS TRANSMITTAL RELEASE REPORT - ALL BRANCHES","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Space","csvTxtLength":"100","pdfLength":"70","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":6,"sectionName":"6","fieldName":"As of Date Value","csvTxtLength":"20","pdfLength":"20","fieldType":"Date","defaultValue":"","delimiter":"","fieldFormat":"dd MMM yyyy","leftJustified":false,"padFieldLength":0,"eol":true},{"sequence":7,"sectionName":"7","fieldName":"Space","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"Space","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":"","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
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
---- ATM Manual, ATM Bulk Upload
	SELECT bc || ''-'' || update_date as BRANCH_CODE, COUNT(*) AS TOTAL FROM(
	select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(DCR_AUDIT_LOG),''MMddYY'') as update_date
	from {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS}
	 join  {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  On CRD_ID = DCR_CRD_ID
	  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on DCR_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = DCR_BRN_ID
	  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = DCR_PRS_ID
	  LEFT join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = DCR_CLT_ID
	where 
	  INS_ID = {Iss_Id}
	  AND DCR_CRN_ID is null
 	  and DCR_REQUEST_TYPE IN (''Manual'',''Bulk upload'')
	  AND DCR_STS_ID not in (67,69)
	  AND CRD_KIT_NUMBER IS NULL
	 AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(DCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')-1
	union all
-- ATM Renew, ATM Replace
		select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CRN_AUDIT_LOG),''MMddYY'') as update_date
	from  {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS}  
	left join {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} on CRN_ID = DCR_CRN_ID
     join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} on CRD_ID = DCR_CRD_ID 
	  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on DCR_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = DCR_BRN_ID
	  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = DCR_PRS_ID
	  join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = DCR_CLT_ID
	where 
   DCR_INS_ID = {Iss_Id}
	  AND CRN_STS_ID = 91
AND DCR_REQUEST_TYPE IN (''Renew'',''Replace'')
	  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')-1
	  union all
--Cash Card Manual, Cash Card Bulk Upload
	select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(CCR_AUDIT_LOG),''MMddYY'') as update_date
	from {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS}
  join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} on CSH_ID = CCR_CSH_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CCR_INS_ID = INS_ID
  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = CCR_BRN_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = CCR_PRS_ID
  left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = CCR_CLT_ID
  left join {DCMS_Schema}.MASTER_CORPORATE_CLIENT@{DB_LINK_DCMS} on CCL_ID = CCR_CCL_ID
	where 
   CCR_CRN_ID is null
 and CCR_INS_ID = {Iss_Id}
  AND CCR_CRN_ID is null
  AND CCR_STS_ID not in (67,69)
 AND CCR_REQUEST_TYPE IN (''Manual'',''Bulk upload'')
 AND CSH_KIT_NUMBER IS NULL
	   AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(CCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')-1
	   union all
--CASH CARD RENEW, REPLACE
	  	select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CC_CRN_AUDIT_LOG),''MMddYY'') as update_date
	from {DCMS_Schema}.SUPPORT_CC_RENEWAL@{DB_LINK_DCMS} 
  left join {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} on CC_CRN_ID = CCR_CRN_ID
   join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} on CSH_ID = CCR_CSH_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CCR_INS_ID = INS_ID
  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = CCR_BRN_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = CCR_PRS_ID
  left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = CCR_CLT_ID
  left join {DCMS_Schema}.MASTER_CORPORATE_CLIENT@{DB_LINK_DCMS} on CCL_ID = CCR_CCL_ID
	where 
  CCR_INS_ID = {Iss_Id}
   AND CC_CRN_STS_ID = 91
AND CCR_REQUEST_TYPE IN (''Renew'',''Replace'')
	 AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CC_CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')-1	  
	 union all
--ATM REPIN
	  select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(REP_AUDIT_LOG),''MMddYY'') as update_date
	from {DCMS_Schema}.SUPPORT_REPIN@{DB_LINK_DCMS}
	left JOIN {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} on REP_CCM_ID = CCM_ID
left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CCM_CLT_ID = CLT_ID
   join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} ON CCM_CRD_ID  = CRD_ID
	  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on REP_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = REP_BRN_ID
	where 
 REP_INS_ID = {Iss_Id}
	  AND REP_STS_ID in (91)
	  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(REP_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')-1
union all
--CASH CARD REPIN
	  select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CC_REP_AUDIT_LOG),''MMddYY'') as update_date
	from {DCMS_Schema}.SUPPORT_CC_REPIN@{DB_LINK_DCMS}
left JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ON CC_REP_CAM_ID = CAM_ID
  left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CAM_CLT_ID = CLT_ID
   join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ON CAM_CSH_ID  = CSH_ID
join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CC_REP_INS_ID = INS_ID
  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = CC_REP_BRN_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID =  CSH_PRS_ID
  left join {DCMS_Schema}.MASTER_CORPORATE_CLIENT@{DB_LINK_DCMS} on CCL_ID = CSH_CCL_ID
	where 
  CC_REP_INS_ID = {Iss_Id}
  AND CC_REP_STS_ID = 91
	  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CC_REP_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')-1
	  UNION ALL
--ATM PRE-PREGEN
	  	  select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(BCR_AUDIT_LOG),''MMddYY'') as update_date
	from {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS}
	join {DCMS_Schema}.ISSUANCE_BULK_CARD_REQUEST@{DB_LINK_DCMS} on CRD_BCR_ID = BCR_NUMBER
	 join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on BCR_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = BCR_BRN_ID
	where 
  BCR_INS_ID = {Iss_Id}
  AND BCR_STS_ID not in (67,69)
  AND CRD_KIT_NUMBER IS NOT NULL
  AND CRD_IS_LINKED NOT IN (''1'')
AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(BCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')	-1 
	  UNION ALL
--CASH CARD PRE-PREGEN
	  	  select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(BCR_AUDIT_LOG),''MMddYY'') as update_date
from {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS}
join {DCMS_Schema}.ISSUANCE_BULK_CARD_REQUEST@{DB_LINK_DCMS} on CSH_BCR_ID = BCR_NUMBER
left join {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} ON CSH_ID = CCM_CRD_ID
left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CCM_CLT_ID = CLT_ID
	 join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on BCR_INS_ID = INS_ID
	  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = BCR_BRN_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = BCR_PRS_ID
  left join {DCMS_Schema}.MASTER_CORPORATE_CLIENT@{DB_LINK_DCMS} on CCL_ID = CSH_CCL_ID
	where 
  BCR_INS_ID = {Iss_Id}
  AND BCR_STS_ID not in (67,69)
  AND CSH_KIT_NUMBER IS NOT NULL
  AND CSH_IS_LINKED NOT IN (''1'')
AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(BCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')	-1
union all
--ATM Renew Bulk
select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(RBC_AUDIT_LOG),''MMddYY'') as update_date
from {DCMS_Schema}.ISSUANCE_RENEWAL_BULK_CARDS@{DB_LINK_DCMS}
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on RBC_INS_ID = INS_ID
  join {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} on RBC_ID = DCR_RBC_ID
  join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} on CRD_ID = DCR_CRD_ID
  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = RBC_BRN_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = RBC_PRS_ID
  left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = DCR_CLT_ID  
where 
  RBC_INS_ID = {Iss_Id}
  AND DCR_REQUEST_TYPE = ''Renew''
  AND RBC_STS_ID = 68
   AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(RBC_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')-1	
UNION ALL
--Cash Card Renew Bulk
select 
	  BRN_CODE as bc,
	  to_char({DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(RBC_AUDIT_LOG),''MMddYY'') as update_date
From {DCMS_Schema}.ISSUANCE_RENEWAL_BULK_CARDS@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on RBC_INS_ID = INS_ID
  join {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} on RBC_ID = CCR_RBC_ID
  join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} on CSH_ID = CCR_CSH_ID
  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = RBC_BRN_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = RBC_PRS_ID
  left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = CCR_CLT_ID  
where 
  RBC_INS_ID = {Iss_Id}
  AND CCR_REQUEST_TYPE = ''Renew''
  AND RBC_STS_ID = 68
   AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(RBC_AUDIT_LOG) BETWEEN TO_DATE({From_Date_UTC},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date_UTC},''DD-MM-YY HH24:MI:SS'')-1	 
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