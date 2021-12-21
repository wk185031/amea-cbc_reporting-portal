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
	
	i_BODY_QUERY := TO_CLOB('
		select 
  SUM(NEW_CARD_COUNT + BULK_UPLOAD_COUNT + REPLACE_COUNT + RENEW_COUNT + PREGEN_COUNT + REPIN_COUNT) AS TOTAL_COUNT
from (
-- ATM Manual
select 
  count(*) as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  0 as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} 
   join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} on CRD_ID = DCR_CRD_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on DCR_INS_ID = INS_ID
Join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on  DCR_PRS_ID= PRS_ID
where 
  DCR_INS_ID = {Iss_Name}
  AND DCR_CRN_ID is null
  AND DCR_REQUEST_TYPE = ''Manual''
  AND DCR_STS_ID not in (67,69)
  AND CRD_KIT_NUMBER IS NULL
  AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(DCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all 
-- ATM Bulk Upload
select 
  0 as NEW_CARD_COUNT,
  count(*) as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  0 as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} 
   join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} on CRD_ID = DCR_CRD_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on DCR_INS_ID = INS_ID
where 
  DCR_INS_ID = {Iss_Name}
  AND DCR_CRN_ID is null
  AND DCR_REQUEST_TYPE = ''Bulk upload''
  AND DCR_STS_ID not in (67,69)
  AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(DCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all 
-- ATM Replace
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  count(*) as REPLACE_COUNT,
  0 as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CRN_INS_ID = INS_ID
  join {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} on CRN_ID = DCR_CRN_ID
   join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} on CRD_ID = DCR_CRD_ID  
where 
  CRN_INS_ID = {Iss_Name}
  AND DCR_REQUEST_TYPE = ''Replace''
  AND CRN_STS_ID = 91
  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all
-- ATM Renew
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  count(*) as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CRN_INS_ID = INS_ID
  join {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} on CRN_ID = DCR_CRN_ID
   join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} on CRD_ID = DCR_CRD_ID
where 
  CRN_INS_ID = {Iss_Name}
  AND DCR_REQUEST_TYPE = ''Renew''
  AND CRN_STS_ID = 91
  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all
-- ATM Renew Bulk
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  count(*) as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.ISSUANCE_RENEWAL_BULK_CARDS@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on RBC_INS_ID = INS_ID
  join {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} on RBC_ID = DCR_RBC_ID
   join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} on CRD_ID = DCR_CRD_ID
where 
  RBC_INS_ID = {Iss_Name}
  AND DCR_REQUEST_TYPE = ''Renew''
  AND RBC_STS_ID = 68
  AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(RBC_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all 
-- ATM Pregen
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  0 as RENEW_COUNT,
  count(*) as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} 
   join {DCMS_Schema}.ISSUANCE_BULK_CARD_REQUEST@{DB_LINK_DCMS} on CRD_BCR_ID = BCR_NUMBER
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on BCR_INS_ID = INS_ID
where 
  BCR_INS_ID = {Iss_Name}
  AND BCR_STS_ID not in (67,69)
  AND CRD_KIT_NUMBER IS NOT NULL
  AND CRD_IS_LINKED NOT IN (''1'')
  AND CRD_LIFE_CYCLE NOT IN (5)
  AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(BCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all   
-- ATM Repin
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  0 as RENEW_COUNT,
  0 as PREGEN_COUNT,
  count(*) as REPIN_COUNT
from {DCMS_Schema}.SUPPORT_REPIN@{DB_LINK_DCMS}
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on REP_INS_ID = INS_ID
where 
  REP_INS_ID = {Iss_Name}
  AND REP_STS_ID = 91
  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(REP_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all 
-- Cash Card Manual
select 
  count(*) as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  0 as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} 
   join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} on CSH_ID = CCR_CSH_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CCR_INS_ID = INS_ID
Join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on  CCR_PRS_ID= PRS_ID
where 
  CCR_INS_ID = {Iss_Name}
  AND CCR_CRN_ID is null
  AND CCR_REQUEST_TYPE = ''Manual''
  AND CCR_STS_ID not in (67,69)
  AND CSH_KIT_NUMBER IS NULL
  AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(CCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all 
-- CashCard Bulk Upload
select 
  0 as NEW_CARD_COUNT,
  count(*) as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  0 as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} 
   join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} on CSH_ID = CCR_CSH_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CCR_INS_ID = INS_ID
where 
  CCR_INS_ID = {Iss_Name}
  AND CCR_CRN_ID is null
  AND CCR_REQUEST_TYPE = ''Bulk upload''
  AND CCR_STS_ID not in (67,69)
  AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(CCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all 
-- CashCard Replace
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  count(*) as REPLACE_COUNT,
  0 as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.SUPPORT_CC_RENEWAL@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CC_CRN_INS_ID = INS_ID
  join {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} on CC_CRN_ID = CCR_CRN_ID
   join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} on CSH_ID = CCR_CSH_ID
where 
  CC_CRN_INS_ID = {Iss_Name}
  AND CCR_REQUEST_TYPE = ''Replace''
  AND CC_CRN_STS_ID = 91
  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CC_CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all
-- CashCard Renew
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  count(*) as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.SUPPORT_CC_RENEWAL@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CC_CRN_INS_ID = INS_ID
  join {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} on CC_CRN_ID = CCR_CRN_ID
   join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} on CSH_ID = CCR_CSH_ID
where 
  CC_CRN_INS_ID = {Iss_Name}
  AND CCR_REQUEST_TYPE = ''Renew''
  AND CC_CRN_STS_ID = 91
  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CC_CRN_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all 
-- CashCard Pregen
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  0 as RENEW_COUNT,
  count(*) as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} 
   join {DCMS_Schema}.ISSUANCE_BULK_CARD_REQUEST@{DB_LINK_DCMS} on CSH_BCR_ID = BCR_NUMBER
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on BCR_INS_ID = INS_ID
where 
  BCR_INS_ID = {Iss_Name}
  AND CSH_KIT_NUMBER IS NOT NULL
  AND CSH_IS_LINKED NOT IN (''1'')
  AND BCR_STS_ID not in (67,69)
  AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(BCR_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all
-- CashCard Renew Bulk
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  count(*) as RENEW_COUNT,
  0 as PREGEN_COUNT,
  0 as REPIN_COUNT
from {DCMS_Schema}.ISSUANCE_RENEWAL_BULK_CARDS@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on RBC_INS_ID = INS_ID
  join {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} on RBC_ID = CCR_RBC_ID
   join {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} on CSH_ID = CCR_CSH_ID
where 
  RBC_INS_ID = {Iss_Name}
  AND CCR_REQUEST_TYPE = ''Renew''
  AND RBC_STS_ID = 68
  AND {DCMS_Schema}.GetApprDate@{DB_LINK_DCMS}(RBC_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
union all   
-- CashCard Repin
select 
  0 as NEW_CARD_COUNT,
  0 as BULK_UPLOAD_COUNT,
  0 as REPLACE_COUNT,
  0 as RENEW_COUNT,
  0 as PREGEN_COUNT,
  count(*) as REPIN_COUNT
from {DCMS_Schema}.SUPPORT_CC_REPIN@{DB_LINK_DCMS}
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CC_REP_INS_ID = INS_ID
where 
  CC_REP_INS_ID = {Iss_Name}
  AND CC_REP_STS_ID = 91
  AND {DCMS_Schema}.GetSupportApprDate@{DB_LINK_DCMS}(CC_REP_AUDIT_LOG) BETWEEN TO_DATE({From_Date},''DD-MM-YY HH24:MI:SS'') AND TO_DATE({To_Date},''DD-MM-YY HH24:MI:SS'') - 1
)	
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