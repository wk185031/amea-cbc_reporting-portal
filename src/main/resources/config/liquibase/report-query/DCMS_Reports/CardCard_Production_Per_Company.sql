-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Cash Card Production Report per Company';
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
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"CASH CARD PRODUCTION REPORT PER COMPANY","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"97","pdfLength":"97","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","csvTxtLength":"9","pdfLength":"9","fieldType":"String","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"14","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space1","csvTxtLength":"100","pdfLength":"100","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0,"delimiter":";"}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"COMPANY CODE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMPANY CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"COMPANY NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","defaultValue":"COMPANY NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"PRODUCED","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"PRODUCED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"ACTIVATED","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ACTIVATED","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"COMPANY_CODE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"COMPANY_NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"PRODUCED","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"ACTIVATED","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELDS_CBC := null;
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"CASH CARD PRODUCTION REPORT PER COMPANY","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"97","pdfLength":"97","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","csvTxtLength":"9","pdfLength":"9","fieldType":"String","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"14","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Space1","csvTxtLength":"100","pdfLength":"100","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":17,"sectionName":"17","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":18,"sectionName":"18","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":19,"sectionName":"19","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":20,"sectionName":"20","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm:ss","csvTxtLength":"10","pdfLength":"10","leftJustified":true,"padFieldLength":0,"delimiter":";"}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"COMPANY CODE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"COMPANY CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"COMPANY NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","defaultValue":"COMPANY NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"PRODUCED","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"PRODUCED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"ACTIVATED","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ACTIVATED","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"COMPANY_CODE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"COMPANY_NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"PRODUCED","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"ACTIVATED","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELDS_CBS := null;
	
	i_BODY_QUERY := TO_CLOB('SELECT 
	ccl_company_code as COMPANY_CODE,
	ccl_company_name as COMPANY_NAME,
	sum(produced) as PRODUCED,
	sum(activated) as ACTIVATED
	from(
	--Manual issuance / Batch Upload / pre-gen card activation
	select 
	case when ccl_company_code is null then ''804'' else ccl_company_code end as ccl_company_code,
	case when ccl_company_name is null then ''Other'' else ccl_company_name end as ccl_company_name,
	count(case when csh.csh_emb_id is not null and CSH_KIT_NUMBER IS NULL then 1 end) as produced,
	count(case when CSH_KIT_NUMBER IS NOT NULL and CLT_CIF_NUMBER IS NOT NULL then 1 end) as activated
	FROM {DCMS_Schema}.issuance_cash_card_request@{DB_LINK_DCMS} ccr
	join {DCMS_Schema}.issuance_cash_card@{DB_LINK_DCMS} csh on csh.csh_id = ccr.ccr_csh_id
	left join {DCMS_Schema}.master_corporate_client@{DB_LINK_DCMS} ccl on ccl.ccl_id = ccr.ccr_ccl_id
	LEFT JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM ON CAM_CSH_ID = CSH_ID
	LEFT JOIN {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} ON CAM_CLT_ID = CLT_ID
	where ccr.ccr_ins_id = 1
	and FROM_TZ( CAST( ccr.ccr_created_ts AS TIMESTAMP ), ''UTC'' )
    AT TIME ZONE ''ASIA/MANILA'' BETWEEN To_Timestamp({From_Date}, ''DD-MM-YY HH24:MI:SS'') 
    AND To_Timestamp({To_Date}, ''DD-MM-YY HH24:MI:SS'')
	and ccr_cdt_id = (select cdt_id from {DCMS_Schema}.master_card_types@{DB_LINK_DCMS} where cdt_ins_id = 1 and cdt_type_name = ''Cash'')
	AND CCR_REQUEST_TYPE in (''Manual'',''Bulk upload'')
	AND CCR_STS_ID not in (67,69)
	group by ccl.ccl_company_code,ccl.ccl_company_name
	UNION ALL
	--Manual/BAU cc activation
	select
	case when ccl_company_code is null then ''804'' else ccl_company_code end as ccl_company_code,
	case when ccl_company_name is null then ''Other'' else ccl_company_name end as ccl_company_name,
	0 as produced,
	count(case when scca.cc_caa_id is not null then 1 end) as activated
	from {DCMS_Schema}.Support_CC_Activation@{DB_LINK_DCMS} Scca
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Scca.Cc_Caa_Cam_Id = ICCAM.CAM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
	left join {DCMS_Schema}.master_corporate_client@{DB_LINK_DCMS} ccl on ccl.ccl_id = icc.csh_ccl_id
	where Scca.Cc_Caa_Ins_Id = 1
	and csh_kit_number is null
	and Scca.Cc_Caa_Sts_Id IN (91)
	AND FROM_TZ( CAST( To_Date(Scca.CC_CAA_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') AS TIMESTAMP ), ''UTC'' )
    AT TIME ZONE ''ASIA/MANILA'' BETWEEN To_Timestamp({From_Date}, ''DD-MM-YY HH24:MI:SS'') 
    AND To_Timestamp({To_Date}, ''DD-MM-YY HH24:MI:SS'')  
	and csh_audit_log like ''%Status changed from Inactive to ACTIVE%''
	group by ccl.ccl_company_code,ccl.ccl_company_name
	UNION ALL
	--CC Pre-gen card
	select
	case when ccl_company_code is null then ''804'' else ccl_company_code end as ccl_company_code,
	case when ccl_company_name is null then ''Other'' else ccl_company_name end as ccl_company_name,
	count(case when csh.csh_emb_id is not null AND CLT_CIF_NUMBER IS NULL then 1 end) as produced,
	0 as activated
	from {DCMS_Schema}.ISSUANCE_BULK_CARD_REQUEST@{DB_LINK_DCMS}
	LEFT join {DCMS_Schema}.issuance_cash_card@{DB_LINK_DCMS} csh on CSH_BCR_ID = BCR_NUMBER
	LEFT join {DCMS_Schema}.master_branches@{DB_LINK_DCMS} brn on brn.brn_id = bcr_brn_id
	LEFT JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM ON CAM_CSH_ID = CSH_ID
	LEFT JOIN {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} ON CAM_CLT_ID = CLT_ID
  left join {DCMS_Schema}.master_corporate_client@{DB_LINK_DCMS} ccl on ccl.ccl_id = csh.csh_ccl_id
	where BCR_INS_ID = 1
	and FROM_TZ( CAST( bcr_created_ts AS TIMESTAMP ), ''UTC'' )
    AT TIME ZONE ''ASIA/MANILA'' BETWEEN To_Timestamp({From_Date}, ''DD-MM-YY HH24:MI:SS'') 
    AND To_Timestamp({To_Date}, ''DD-MM-YY HH24:MI:SS'')
	and bcr_cdt_id = (select cdt_id from {DCMS_Schema}.master_card_types@{DB_LINK_DCMS} where cdt_ins_id = 1 and cdt_type_name = ''Cash'')
  and bcr_sts_id not in (67,69)
	group by ccl.ccl_company_code,ccl.ccl_company_name)
	group by ccl_company_code,ccl_company_name
	order by ccl_company_code
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