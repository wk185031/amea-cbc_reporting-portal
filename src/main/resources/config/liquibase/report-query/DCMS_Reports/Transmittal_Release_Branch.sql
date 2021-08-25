-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS

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
select
    tb.branch_code || ''-'' || update_date as BRANCH_CODE,
    count(tb.account_name)as TOTAL from
    ((SELECT
    (SELECT CLT_FIRST_NAME || '' ''|| CLT_MIDDLE_NAME || '' '' || CLT_LAST_NAME FROM {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} WHERE CLT_ID = DCR_CLT_ID) AS ACCOUNT_NAME,
    ''NEW'' AS REMARKS,
    (select brn_name from {DCMS_Schema}.master_branches@{DB_LINK_DCMS} where BRN_ID = DCR_BRN_ID) as Branch_Name,
    (select brn_code from {DCMS_Schema}.master_branches@{DB_LINK_DCMS} where BRN_ID = DCR_BRN_ID) as Branch_Code,
	 to_char(DCR_UPDATED_TS,''MMddYY'') as update_date,
    (SELECT PRS_NAME FROM {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} WHERE PRS_ID = DCR_PRS_ID) AS PROGRAM_NAME
    FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} WHERE DCR_STS_ID = 70)
    union
    (select
    clt.CLT_FIRST_NAME || '' '' ||clt.CLT_MIDDLE_NAME || '' '' || clt.CLT_LAST_NAME as Account_Name,
    ''REPLACEMENT'' as Remarks,
     (select brn_name from {DCMS_Schema}.master_branches@{DB_LINK_DCMS} where BRN_ID = REN.CRN_BRN_ID) as Branch_Name,
     (select brn_code from {DCMS_Schema}.master_branches@{DB_LINK_DCMS} where BRN_ID = REN.CRN_BRN_ID) as Branch_Code,
	  to_char(crd.CRD_UPDATED_TS,''MMddYY'')as update_date,
     (SELECT PRS_NAME FROM {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} WHERE PRS_ID = crd.CRD_PRS_ID) AS PROGRAM_NAME
     from {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} ren
     inner join {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} ccm on CCM.CCM_ID = ren.CRN_CCM_ID
     inner join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} clt on CLT.CLT_ID = ccm.CCM_CLT_ID
     inner join {DCMS_Schema}.issuance_card@{DB_LINK_DCMS} crd on crd.CRD_ID = ccm.CCM_CRD_ID
     where ren.CRN_STS_ID = 88)
     union
     (select
     rclt.CLT_FIRST_NAME || '' '' ||rclt.CLT_MIDDLE_NAME || '' ''|| rclt.CLT_LAST_NAME as Account_Name,
     ''PIN REGENERATION'' as Remarks,
     (select brn_name from {DCMS_Schema}.master_branches@{DB_LINK_DCMS} where BRN_ID = rpin.REP_BRN_ID) as Branch_Name,
     (select brn_code from {DCMS_Schema}.master_branches@{DB_LINK_DCMS} where BRN_ID = rpin.REP_BRN_ID) as Branch_Code,
	 to_char(crd.CRD_UPDATED_TS,''MMddYY'')as update_date,
     (SELECT PRS_NAME FROM {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} WHERE PRS_ID = crd.CRD_PRS_ID) AS PROGRAM_NAME
     from {DCMS_Schema}.SUPPORT_REPIN@{DB_LINK_DCMS} rpin
     inner join {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} rccm on rccm.CCM_ID = rpin.REP_CCM_ID
     inner join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} rclt on rclt.CLT_ID = rccm.CCM_CLT_ID
     inner join {DCMS_Schema}.issuance_card@{DB_LINK_DCMS} crd on crd.CRD_ID = rccm.CCM_CRD_ID
     where rpin.REP_STS_ID = 88)) tb group by tb.branch_code, update_date
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