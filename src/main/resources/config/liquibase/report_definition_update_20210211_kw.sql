DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- ATM Availability
	i_BODY_QUERY := TO_CLOB('
	SELECT
     AST.AST_ARE_NAME "REGION",
     ABR.ABR_CODE "BRANCH CODE",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     AST.AST_ID "STATION ID",
     round(SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / {Total_Day} * 100), 2) "UNAVAILABLE",
     NVL(round(100 - (SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / {Total_Day} * 100)), 2) , 100) "AVAILABLE",    
     CASE WHEN SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / {Total_Day} * 100) < 5 THEN ''1'' ELSE ''0'' END "STANDARD"
FROM
      ATM_STATIONS AST
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD_AST_ID AND {Txn_Date} 
WHERE
	AST_ALO_LOCATION_ID NOT LIKE ''CBS%''
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
      AST.AST_ALO_LOCATION_ID ASC');
	  
	  UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'ATM Availability';


-- Control Report for PIN Mailer
i_BODY_QUERY := TO_CLOB('
SELECT q1.New_Card AS NEW_COUNT,
	q1.Replacement_Card AS REPLACEMENT_COUNT,
	NVL(q1.Pre_Generated_Card,0) AS PREGEN_COUNT,
	q1.Bulk_Uploaded_Card_Records AS BULK_UPLOADED_COUNT,
  	(New_Card + Replacement_Card + NVL(Pre_Generated_Card,0) + Bulk_Uploaded_Card_Records) AS TOTAL_COUNT
FROM
  	(SELECT
    	(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
    		INNER JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} crd
    		ON req.DCR_CRD_ID = crd.CRD_ID
    		Where crd.crd_pin_offset IS Not Null
    		AND req.DCR_INS_ID = {Iss_Name}
    		AND req.DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS New_Card,
    	(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
    		INNER JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} crd
    		On Req.Dcr_Crd_Id = Crd.Crd_Id
    		WHERE req.DCR_REQUEST_TYPE = ''Auto Renewal'' OR req.DCR_REQUEST_TYPE=''Renew'' OR req.DCR_REQUEST_TYPE=''Replace''
    		And Crd.Crd_Pin_Offset Is Not Null
    		AND req.DCR_INS_ID = {Iss_Name}
    		And Req.Dcr_Created_Ts Between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS Replacement_Card ,
    	(SELECT Count(crd_id)
    		From {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}
    		Where Crd_Bcr_Id Like ''B%'' And Crd_Pin_Offset Is Not Null
    		AND Crd_Ins_id = {Iss_Name}
    		AND crd_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS Pre_Generated_Card,
    	(SELECT COUNT(*)
    		FROM {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} req
    		INNER JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} crd
    		ON req.DCR_CRD_ID = crd.CRD_ID
    		WHERE req.DCR_REQ_FROM_BATCH = 1 OR DCR_REQUEST_TYPE=''Bulk upload''
    		And Crd.crd_pin_offset Is Not Null
    		AND req.DCR_INS_ID = {Iss_Name}
    		AND req.DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS Bulk_Uploaded_Card_Records
  	From Dual
) q1
');

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"NEW","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"NUMBER OF PIN RECORDS GENERATED (NEW):","firstField":true},{"sequence":2,"sectionName":"2","fieldName":"NEW_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"REPLACEMENT","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF PIN RECORDS GENERATED (REPLACEMENT):","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"REPLACEMENT_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"PREGEN","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF PIN RECORDS GENERATED (PREGEN):","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"PREGEN_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"BULK","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF PIN RECORDS GENERATED (BULK UPLOAD):","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"BULK_UPLOADED_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"NEWLINE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":" ","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TOTAL","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL NUMBER OF PIN RECORDS GENERATED","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"TOTAL_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]
');

update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_BODY_FIELDS = i_BODY_FIELD where RED_NAME = 'Control Report for PIN Mailer';

-- Control Report for Embossed Records
i_BODY_QUERY := TO_CLOB('
SELECT 
	q1.New_Card AS NEW_COUNT,
	q1.Replacement_Card AS REPLACEMENT_COUNT,
	NVL(q1.Pre_Generated_Card,0) AS PREGEN_COUNT,
	q1.Bulk_Uploaded_Card_Records AS BULK_UPLOADED_COUNT,
	(New_Card + Replacement_Card + NVL(Pre_Generated_Card,0) + Bulk_Uploaded_Card_Records) AS TOTAL_COUNT
FROM
	(SELECT
    	(SELECT COUNT(*)
    		FROM DCMSADM.ISSUANCE_DEBIT_CARD_REQUEST@DCMSUAT req
    		INNER JOIN DCMSADM.ISSUANCE_CARD@DCMSUAT crd
    		ON req.DCR_CRD_ID = crd.CRD_ID
    		WHERE crd.CRD_EMB_ID IS NOT NULL
    		AND req.DCR_INS_ID = 1
    		AND req.DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS New_Card,
    	(SELECT COUNT(*)
    		FROM DCMSADM.support_card_renewal@DCMSUAT
    		WHERE CRN_STS_ID = 91
    		AND CRN_INS_ID = 1
    		AND TO_DATE(CRN_CREATED_TS, ''YYYY-MM-DD hh24:mi:ss'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS Replacement_Card ,
    	(SELECT SUM(BCR_NUMBER_OF_CARDS)
    		FROM DCMSADM.ISSUANCE_BULK_CARD_REQUEST@DCMSUAT
    		WHERE BCR_STS_ID = 70
    		AND BCR_INS_ID = 1
    		AND BCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS Pre_Generated_Card,
    	(SELECT COUNT(*)
    		FROM DCMSADM.ISSUANCE_DEBIT_CARD_REQUEST@DCMSUAT req
    		INNER JOIN DCMSADM.ISSUANCE_CARD@DCMSUAT crd
    		ON req.DCR_CRD_ID = crd.CRD_ID
    		WHERE req.DCR_REQ_FROM_BATCH = 1
    		AND crd.CRD_EMB_ID IS NOT NULL
    		AND req.DCR_INS_ID = 1
    		AND req.DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
    	) AS Bulk_Uploaded_Card_Records
  	FROM dual
 ) q1
');

i_BODY_FIELD := TO_CLOB('
	[{"sequence":1,"sectionName":"15","fieldName":"NEW","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF EMBOSSED RECORDS GENERATED (NEW):","firstField":true,"bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"16","fieldName":"NEW_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"17","fieldName":"REPLACEMENT","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF EMBOSSED RECORDS GENERATED (REPLACEMENT):","firstField":true,"bodyHeader":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"18","fieldName":"REPLACEMENT_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"PREGEN","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF EMBOSSED RECORDS GENERATED (PRE-GENERATED):","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"PREGEN_COUNT","csvTxtLength":"15","pdfLength":"15","eol":true},{"sequence":7,"sectionName":"7","fieldName":"BULK","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"NUMBER OF EMBOSSED RECORDS GENERATED (BULK UPLOAD):","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"BULK_UPLOADED_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"19","fieldName":"NEWLINE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":" ","firstField":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TOTAL","csvTxtLength":"60","pdfLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL NUMBER OF EMBOSSED RECORDS GENERATED:","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"TOTAL_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false}]
');

update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY, RED_BODY_FIELDS = i_BODY_FIELD where RED_NAME = 'Control Report for Embossed Records';


-- Cash Card Production Report per Branch
i_BODY_QUERY := TO_CLOB('
select
	brn.brn_code as BRANCH_CODE,
	brn.brn_name as BRANCH_NAME,
	count(case when
			csh.csh_emb_id is null and
			csh.csh_pin_offset is null and
			csh.csh_created_ts between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
			then 1 end) as ENROLLMENTS,
	count(case when
			csh.csh_emb_id is not null and
			csh.csh_pin_offset is null and
			emb.emb_created_ts between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
			then 1 end) as PRODUCED,
	count(case when
			csh.csh_emb_id is not null and
			csh.csh_sts_id = 72 and
			csh.csh_status_date is not null and 
			TO_DATE(csh.csh_status_date, ''dd-MM-YY hh24:mi:ss'') between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
			then 1 end) as ACTIVATED
from
	{DCMS_Schema}.issuance_cash_card_request@{DB_LINK_DCMS} ccr
	inner join {DCMS_Schema}.issuance_cash_card@{DB_LINK_DCMS} csh on csh.csh_id = ccr.ccr_csh_id
	inner join {DCMS_Schema}.master_branches@{DB_LINK_DCMS} brn on brn.brn_id = ccr.ccr_brn_id
	left join {DCMS_Schema}.issuance_embossing_file@{DB_LINK_DCMS} emb on emb.emb_id = csh.csh_emb_id
where
	ccr.ccr_ins_id = {Iss_Id}
group by
	brn.brn_code, brn.brn_name
');

update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Cash Card Production Report per Branch';


-- Cash Card Production Report per Company
i_BODY_QUERY := TO_CLOB('
select
	ccl.ccl_company_code as COMPANY_CODE,
	ccl.ccl_company_name as COMPANY_NAME,
	count(case when
			csh.csh_emb_id is null and
			csh.csh_pin_offset is null and
			csh.csh_created_ts between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
			then 1 end) as ENROLLMENTS,
	count(case when
			csh.csh_emb_id is not null and
			csh.csh_pin_offset is null and
			emb.emb_created_ts between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
			then 1 end) as PRODUCED,
	count(case when
			csh.csh_emb_id is not null and
			csh.csh_sts_id = 72 and
			csh.csh_status_date is not null and 
			TO_DATE(csh.csh_status_date, ''dd-MM-YY hh24:mi:ss'') between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
			then 1 end) as ACTIVATED
from
	{DCMS_Schema}.issuance_cash_card_request@{DB_LINK_DCMS} ccr
	inner join {DCMS_Schema}.issuance_cash_card@{DB_LINK_DCMS} csh on csh_id = ccr.ccr_csh_id
	inner join {DCMS_Schema}.master_corporate_client@{DB_LINK_DCMS} ccl on ccl.ccl_id = ccr.ccr_ccl_id
	left join {DCMS_Schema}.issuance_embossing_file@{DB_LINK_DCMS} emb on emb.emb_id = csh.csh_emb_id
where
	ccr.ccr_ins_id = {Iss_Id}
group by
	ccl.ccl_company_code, ccl.ccl_company_name
');

update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Cash Card Production Report per Company';


-- Pending Approval Card Records
i_BODY_QUERY := TO_CLOB('
SELECT
	''ACCOUNT DLINKING'' AS FUNCTIONNAME,
	SALD.ADL_CREATED_TS AS ISSUE_DATE,
	IC.CRD_NUMBER_ENC,
	SALD.ADL_CREATED_BY AS MAKER,
	SALD.ADL_UPDATED_BY AS CHECKER,
	SALD.ADL_REMARKS AS REMARKS,
	IC.CRD_CARDHOLDER_NAME AS CLIENTNAME,
	MS.STS_NAME AS STATUS
FROM
	{DCMS_Schema}.SUPPORT_ACCOUNT_DELINKING@{DB_LINK_DCMS} SALD
	JOIN {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} ICCM ON SALD.ADL_CCM_ID = ICCM.CCM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON ICCM.CCM_CLT_ID = IC.CRD_ID
	JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON SALD.ADL_STS_ID=MS.STS_ID
Where
	TO_DATE(Sald.Adl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between TO_DATE({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID = 89
	AND SALD.ADL_INS_ID = {Iss_Name}
UNION ALL
Select
	''Request For Add On Card'' As FUNCTIONNAME,
	Rac.Aoc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Rac.Aoc_Created_By As Maker,
	Rac.Aoc_Updated_By As Checker,
	Rac.Aoc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Add_On_Card@{DB_LINK_DCMS} Rac
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Rac.Aoc_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Rac.Aoc_Sts_Id=Ms.Sts_Id
Where
	To_Date(Rac.Aoc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Rac.Aoc_Ins_Id = {Iss_Name}
UNION ALL
Select
	''ACCOUNT LINKING'' As FUNCTIONNAME,
	Acl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sal.Acl_Created_By As Maker,
	Sal.Acl_Updated_By As Checker,
	Sal.Acl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Account_Linking@{DB_LINK_DCMS} Sal
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sal.Acl_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Sal.Acl_Sts_Id=Ms.Sts_Id
Where
	To_Date(Sal.Acl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sal.Acl_Ins_Id = {Iss_Name}
Union All
Select
	''Card Activation''As Functionname,
	Sac.Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sac.Caa_Created_By As Maker,
	Sac.Caa_Updated_By As Checker,
	Sac.Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Card_Activation@{DB_LINK_DCMS} Sac
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sac.Caa_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Sac.Caa_Sts_Id=Ms.Sts_Id
Where
	To_Date(Sac.Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'')  Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date},''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sac.Caa_Ins_Id = {Iss_Name}
UNION ALL
Select
	''CARD RENEWAL'' As Functionname,
	Scr.Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Scr.Crn_Created_By As Maker,
	Scr.Crn_Updated_By As Checker,
	Scr.Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Card_Renewal@{DB_LINK_DCMS} Scr
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scr.Crn_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Scr.Crn_Sts_Id=Ms.Sts_Id
Where
	To_Date(Scr.Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scr.Crn_Ins_Id = {Iss_Name}
Union All
Select
	''CASH CARD ACTIVATION'' Functionname,
	Scca.Cc_Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC As Cardno,
	Scca.Cc_Caa_Created_By As Maker,
	Scca.Cc_Caa_Updated_By As Checker,
	Scca.Cc_Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Cc_Activation@{DB_LINK_DCMS} Scca
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scca.Cc_Caa_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scca.Cc_Caa_Sts_Id=Ms.Sts_Id
Where
	To_Date(Scca.Cc_Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scca.Cc_Caa_Ins_Id = {Iss_Name}
Union All
Select
	''CASH CARD RENEWAL'' Functionname,
	Sccr.Cc_Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC ,
	Sccr.Cc_Crn_Created_By As Maker,
	Sccr.Cc_Crn_Updated_By As Checker,
	Sccr.Cc_Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Cc_Renewal@{DB_LINK_DCMS} Sccr
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccr.Cc_Crn_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccr.Cc_Crn_Sts_Id=Ms.Sts_Id
Where
	To_Date(Sccr.Cc_Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccr.Cc_Crn_Ins_Id = {Iss_Name}
UNION ALL
Select
	''CASH DEHOTLIST'' Functionname,
	Sccd.Cc_Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sccd.Cc_Dhl_Created_By As Maker,
	Sccd.Cc_Dhl_Updated_By As Checker,
	Sccd.Cc_Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Cc_Dehotlist@{DB_LINK_DCMS} Sccd
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccd.Cc_Dhl_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccd.Cc_Dhl_Sts_Id=Ms.Sts_Id
Where
	To_Date(Sccd.Cc_Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccd.Cc_Dhl_Ins_Id = {Iss_Name}
Union All
Select
	''HOTLIST'' Functionname,
	Scch.Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Scch.Hot_Created_By As Maker,
	Scch.Hot_Updated_By As Checker,
	Scch.Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Hotlist@{DB_LINK_DCMS} Scch
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scch.Hot_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scch.Hot_Sts_Id=Ms.Sts_Id
Where
	To_Date(Scch.Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scch.Hot_Ins_id = {Iss_Name}
Union All
Select
	''CASH CARD RESET PIN'' Functionname,
	Sccrp.Cc_Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sccrp.Cc_Rpc_Created_By As Maker,
	Sccrp.Cc_Rpc_Updated_By As Checker,
	Sccrp.Cc_Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Cc_Reset_Pin_Counter@{DB_LINK_DCMS} Sccrp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccrp.Cc_Rpc_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccrp.Cc_Rpc_Sts_Id=Ms.Sts_Id
Where
	To_Date(Sccrp.Cc_Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccrp.Cc_Rpc_Ins_id = {Iss_Name}
UNION ALL
Select
	''CASH CARD HOTLIST'' Functionname,
	Scht.Cc_Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Scht.Cc_Hot_Created_By As Maker,
	Scht.Cc_Hot_Updated_By As Checker,
	Scht.Cc_Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Cc_Hotlist@{DB_LINK_DCMS} Scht
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scht.Cc_Hot_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scht.Cc_Hot_Sts_Id=Ms.Sts_Id
Where
	To_Date(Scht.Cc_Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scht.Cc_Hot_Ins_Id = {Iss_Name}
Union All
Select
	''REPIN'' Functionname,
	Sdrp.Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sdrp.Rep_Created_By As Maker,
	Sdrp.Rep_Updated_By As Checker,
	Sdrp.Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Repin@{DB_LINK_DCMS} Sdrp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdrp.Rep_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdrp.Rep_Sts_Id=Ms.Sts_Id
Where
	To_Date(Sdrp.Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sdrp.Rep_Ins_Id = {Iss_Name}
UNION ALL
Select
	''RESET PIN COUNTER'' Functionname,
	Srp.Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Srp.Rpc_Created_By As Maker,
	Srp.Rpc_Updated_By As Checker,
	Srp.Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Reset_Pin_Counter@{DB_LINK_DCMS} Srp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Srp.Rpc_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Rpc_Sts_Id=Ms.Sts_Id
Where
	To_Date(Srp.Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Srp.Rpc_Ins_Id = {Iss_Name}
UNION ALL
Select
	''STOP CARD RENEWAL'' Functionname,
	Scrn.SRN_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Scrn.SRN_Created_By As Maker,
	Scrn.SRN_Updated_By As Checker,
	Scrn.SRN_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_STOP_RENEWAL@{DB_LINK_DCMS} Scrn
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scrn.SRN_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scrn.SRN_Sts_Id=Ms.Sts_Id
Where
	To_Date(Scrn.SRN_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scrn.Srn_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Default Account Change'' As Functionnamesal,
	DAR_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Dac.DAR_Created_By As Maker,
	Dac.DAR_Updated_By As Checker,
	Dac.DAR_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Default_Acc_Req_Map@{DB_LINK_DCMS} Dac
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Dac.DAR_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Dac.DAR_Sts_Id=Ms.Sts_Id
Where
	To_Date(Dac.DAR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Dac.Dar_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Transaction Limit Update Cash card'' As FunctionName,
	Scctlu.CC_Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Scctlu.CC_TRM_Created_By As Maker,
	Scctlu.CC_TRM_Updated_By As Checker,
	Scctlu.CC_TRM_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Cc_Txn_Limit_Req_Map@{DB_LINK_DCMS} Scctlu
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scctlu.CC_TRM_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scctlu.CC_TRM_Sts_Id=Ms.Sts_Id
Where
	To_Date(Scctlu.CC_TRM_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scctlu.Cc_Trm_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Reset pin Cash card'' As Functionname,
	Srp.Cc_Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Srp.Cc_Rep_Created_By As Maker,
	Srp.Cc_Rep_Updated_By As Checker,
	Srp.Cc_Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Cc_Repin@{DB_LINK_DCMS} Srp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Srp.Cc_Rep_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Cc_Rep_Sts_Id=Ms.Sts_Id
Where
	To_Date(Srp.Cc_Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Srp.Cc_Rep_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Address Update'' As Functionname,
	Sarm.Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sarm.Aur_Created_By As Maker,
	Sarm.Aur_Updated_By As Checker,
	Sarm.Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Address_Update_Req_Map@{DB_LINK_DCMS} Sarm
	Join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON Sarm.AUR_CLT_ID = IC.CRD_ID
	JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON Sarm.AUR_STS_ID=MS.STS_ID
WHERE
	To_Date(Sarm.Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sarm.Aur_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Cash Card Address Update'' As Functionname,
	Sarcm.Cc_Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sarcm.Cc_Aur_Created_By As Maker,
	Sarcm.Cc_Aur_Updated_By As Checker,
	Sarcm.Cc_Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Cc_Add_Update_Req_Map@{DB_LINK_DCMS} Sarcm
	Join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON Sarcm.CC_AUR_CLT_ID = IC.CRD_ID
	JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON Sarcm.CC_Aur_STS_ID=MS.STS_ID
WHERE
	To_Date(Sarcm.CC_Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sarcm.Cc_Aur_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Dehotlist'' As Functionname,
	Sdhl.Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sdhl.Dhl_Created_By As Maker,
	Sdhl.Dhl_Updated_By As Checker,
	Sdhl.Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Dehotlist@{DB_LINK_DCMS} Sdhl
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdhl.Dhl_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdhl.Dhl_Sts_Id=Ms.Sts_Id
Where
	To_Date(Sdhl.Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sdhl.Dhl_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Transaction Limit Update'' As FunctionName,
	Stlu.Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Stlu.Trm_Created_By As Maker,
	Stlu.Trm_Updated_By As Checker,
	Stlu.Trm_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	{DCMS_Schema}.Support_Txn_Limit_Request_Map@{DB_LINK_DCMS} Stlu
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}  Iccm On Stlu.Trm_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Stlu.Trm_Sts_Id=Ms.Sts_Id
Where
	To_Date(Stlu.Trm_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Stlu.Trm_Ins_Id = {Iss_Name}
	
');

update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Pending Approval Card Records';

END;
/