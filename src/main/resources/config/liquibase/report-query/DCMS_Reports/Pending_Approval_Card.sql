-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise 
-- Rel-20210827			27-AUG-2021		LJL		Revise 
-- Rel-20220322			22-MAR-2022		KW		Convert UTC timezone. Body field sourceTimezone not available via UI yet

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Pending Approval Card Records';
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
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"RECORDS PENDING APPROVAL","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"TODAY DATE","fieldName":"TODAY DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAY DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"15","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"16","fieldName":"AS OF DATE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"17","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"space","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"19","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"20","csvTxtLength":"96","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":18,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":19,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":20,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";","eol":true}]');
	
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":2,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"CUSTOMER","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CUSTOMER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"FUNCTION/","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"FUNCTION/","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"FROM DATA","fieldName":"FROM DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM DATA","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":6,"sectionName":"TO DATA","fieldName":"TO DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO DATA","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":7,"sectionName":"8","fieldName":"MAKER ID","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"MAKER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":8,"sectionName":"10","fieldName":"STATUS","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"STATUS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":9,"sectionName":"11","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":10,"sectionName":"12","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":11,"sectionName":"13","fieldName":"NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":12,"sectionName":"14","fieldName":"DESCRIPTION","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":13,"sectionName":"15","fieldName":"ISSUE_DATE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"MM/dd/yy HH:mm","sourceTimezone":"UTC","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"16","fieldName":"CRD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":15,"sectionName":"17","fieldName":"CLIENTNAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":16,"sectionName":"18","fieldName":"FUNCTIONNAME","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"FROM_DATA","fieldName":"FROM_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"TO_DATA","fieldName":"TO_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"22","fieldName":"MAKER","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"24","fieldName":"STATUS","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');

	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]');
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"RECORDS PENDING APPROVAL","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"TODAY DATE","fieldName":"TODAY DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAY DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"15","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"16","fieldName":"AS OF DATE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"17","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"space","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"19","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"20","csvTxtLength":"96","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":18,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":19,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":20,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";","eol":true}]');
	
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":2,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"CUSTOMER","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CUSTOMER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"FUNCTION/","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"FUNCTION/","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"FROM DATA","fieldName":"FROM DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM DATA","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"bodyHeader":true},{"sequence":6,"sectionName":"TO DATA","fieldName":"TO DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO DATA","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":7,"sectionName":"8","fieldName":"MAKER ID","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"MAKER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":8,"sectionName":"10","fieldName":"STATUS","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"STATUS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":9,"sectionName":"11","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":10,"sectionName":"12","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":11,"sectionName":"13","fieldName":"NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":12,"sectionName":"14","fieldName":"DESCRIPTION","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":13,"sectionName":"15","fieldName":"ISSUE_DATE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"MM/dd/yy HH:mm"","sourceTimezone":"UTC","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"16","fieldName":"CRD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":15,"sectionName":"17","fieldName":"CLIENTNAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":16,"sectionName":"18","fieldName":"FUNCTIONNAME","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"FROM_DATA","fieldName":"FROM_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"TO_DATA","fieldName":"TO_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"22","fieldName":"MAKER","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"24","fieldName":"STATUS","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');

	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]');
	
	i_BODY_QUERY := TO_CLOB('SELECT * FROM (
SELECT
	''ACCOUNT DLINKING'' AS FUNCTIONNAME,
	SALD.ADL_CREATED_TS AS ISSUE_DATE,
	IC.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	IC.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME AS MAKER,
	SALD.ADL_REMARKS AS REMARKS,
	IC.CRD_CARDHOLDER_NAME AS CLIENTNAME,
	SALD.ADL_BAC_ID AS FROM_DATA,
    '' '' TO_DATA,
	MS.STS_NAME AS STATUS,
	'''' as AUDIT_LOG
FROM
	{DCMS_Schema}.SUPPORT_ACCOUNT_DELINKING@{DB_LINK_DCMS} SALD
	JOIN {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} ICCM ON SALD.ADL_CCM_ID = ICCM.CCM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON ICCM.Ccm_CRD_Id = IC.CRD_ID
	JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON SALD.ADL_STS_ID=MS.STS_ID
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = ADL_CREATED_BY
Where
	TO_DATE(Sald.Adl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between TO_DATE({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID = 89
	AND SALD.ADL_INS_ID = {Iss_Name}
UNION ALL
Select
	''Request For Add On Card'' As FUNCTIONNAME,
	Rac.Aoc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Rac.Aoc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	 '' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Add_On_Card@{DB_LINK_DCMS} Rac
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Rac.Aoc_Clt_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Rac.Aoc_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = AOC_CREATED_BY
Where
	To_Date(Rac.Aoc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Rac.Aoc_Ins_Id = {Iss_Name}
UNION ALL
Select
	''ACCOUNT LINKING'' As FUNCTIONNAME,
	Acl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sal.Acl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
    '' '' FROM_DATA,
    CAST(ACL_AUDIT_LOG AS VARCHAR2(1000)) TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Account_Linking@{DB_LINK_DCMS} Sal
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sal.Acl_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Sal.Acl_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = ACL_CREATED_BY
Where
	To_Date(Sal.Acl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sal.Acl_Ins_Id = {Iss_Name}
Union All
Select
	''Card Activation''As Functionname,
	Sac.Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sac.Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Card_Activation@{DB_LINK_DCMS} Sac
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sac.Caa_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Sac.Caa_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CAA_CREATED_BY
Where
	To_Date(Sac.Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'')  Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC},''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sac.Caa_Ins_Id = {Iss_Name}
UNION ALL
Select
	''CARD RENEWAL'' As Functionname,
	Scr.Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Scr.Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Card_Renewal@{DB_LINK_DCMS} Scr
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scr.Crn_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Scr.Crn_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CRN_CREATED_BY
Where
	To_Date(Scr.Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scr.Crn_Ins_Id = {Iss_Name}
Union All
Select
	''CASH CARD ACTIVATION'' Functionname,
	Scca.Cc_Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Scca.Cc_Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Cc_Activation@{DB_LINK_DCMS} Scca
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scca.Cc_Caa_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scca.Cc_Caa_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_CAA_CREATED_BY
Where
	To_Date(Scca.Cc_Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scca.Cc_Caa_Ins_Id = {Iss_Name}
Union All
Select
	''CASH CARD RENEWAL'' Functionname,
	Sccr.Cc_Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC ,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sccr.Cc_Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Cc_Renewal@{DB_LINK_DCMS} Sccr
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccr.Cc_Crn_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccr.Cc_Crn_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_CRN_CREATED_BY
Where
	To_Date(Sccr.Cc_Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccr.Cc_Crn_Ins_Id = {Iss_Name}
UNION ALL
Select
	''CASH DEHOTLIST'' Functionname,
	Sccd.Cc_Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sccd.Cc_Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Cc_Dehotlist@{DB_LINK_DCMS} Sccd
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccd.Cc_Dhl_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccd.Cc_Dhl_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_DHL_CREATED_BY
Where
	To_Date(Sccd.Cc_Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccd.Cc_Dhl_Ins_Id = {Iss_Name}
Union All
Select
	''HOTLIST'' Functionname,
	Scch.Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Scch.Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Hotlist@{DB_LINK_DCMS} Scch
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scch.Hot_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scch.Hot_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = HOT_CREATED_BY
Where
	To_Date(Scch.Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scch.Hot_Ins_id = {Iss_Name}
Union All
Select
	''CASH CARD RESET PIN'' Functionname,
	Sccrp.Cc_Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sccrp.Cc_Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Cc_Reset_Pin_Counter@{DB_LINK_DCMS} Sccrp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccrp.Cc_Rpc_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccrp.Cc_Rpc_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_RPC_CREATED_BY
Where
	To_Date(Sccrp.Cc_Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccrp.Cc_Rpc_Ins_id = {Iss_Name}
UNION ALL
Select
	''CASH CARD HOTLIST'' Functionname,
	Scht.Cc_Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Scht.Cc_Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Cc_Hotlist@{DB_LINK_DCMS} Scht
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scht.Cc_Hot_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scht.Cc_Hot_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_HOT_CREATED_BY
Where
	To_Date(Scht.Cc_Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scht.Cc_Hot_Ins_Id = {Iss_Name}
Union All
Select
	''REPIN'' Functionname,
	Sdrp.Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sdrp.Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Repin@{DB_LINK_DCMS} Sdrp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdrp.Rep_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdrp.Rep_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = REP_CREATED_BY
Where
	To_Date(Sdrp.Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sdrp.Rep_Ins_Id = {Iss_Name}
UNION ALL
Select
	''RESET PIN COUNTER'' Functionname,
	Srp.Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Srp.Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Reset_Pin_Counter@{DB_LINK_DCMS} Srp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Srp.Rpc_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Rpc_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = RPC_CREATED_BY
Where
	To_Date(Srp.Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Srp.Rpc_Ins_Id = {Iss_Name}
UNION ALL
Select
	''STOP CARD RENEWAL'' Functionname,
	Scrn.SRN_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Scrn.SRN_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_STOP_RENEWAL@{DB_LINK_DCMS} Scrn
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scrn.SRN_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scrn.SRN_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = SRN_CREATED_BY
Where
	To_Date(Scrn.SRN_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scrn.Srn_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Default Account Change'' As Functionnamesal,
	DAR_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Dac.DAR_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Default_Acc_Req_Map@{DB_LINK_DCMS} Dac
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Dac.DAR_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Dac.DAR_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = DAR_CREATED_BY
Where
	To_Date(Dac.DAR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Dac.Dar_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Transaction Limit Update Cash card'' As FunctionName,
	Scctlu.CC_Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Scctlu.CC_TRM_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Cc_Txn_Limit_Req_Map@{DB_LINK_DCMS} Scctlu
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scctlu.CC_TRM_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scctlu.CC_TRM_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_TRM_CREATED_BY
Where
	To_Date(Scctlu.CC_TRM_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scctlu.Cc_Trm_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Reset pin Cash card'' As Functionname,
	Srp.Cc_Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Srp.Cc_Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Cc_Repin@{DB_LINK_DCMS} Srp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Srp.Cc_Rep_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Cc_Rep_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_REP_CREATED_BY
Where
	To_Date(Srp.Cc_Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Srp.Cc_Rep_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Address Update'' As Functionname,
	Sarm.Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sarm.Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Address_Update_Req_Map@{DB_LINK_DCMS} Sarm
	Join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON Sarm.AUR_CLT_ID = IC.CRD_ID
	JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON Sarm.AUR_STS_ID=MS.STS_ID
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = AUR_CREATED_BY
WHERE
	To_Date(Sarm.Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sarm.Aur_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Cash Card Address Update'' As Functionname,
	Sarcm.Cc_Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sarcm.Cc_Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Cc_Add_Update_Req_Map@{DB_LINK_DCMS} Sarcm
	Join {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON Sarcm.CC_AUR_CLT_ID = IC.CRD_ID
	JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON Sarcm.CC_Aur_STS_ID=MS.STS_ID
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_AUR_CREATED_BY
WHERE
	To_Date(Sarcm.CC_Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sarcm.Cc_Aur_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Dehotlist'' As Functionname,
	Sdhl.Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Sdhl.Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Dehotlist@{DB_LINK_DCMS} Sdhl
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdhl.Dhl_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdhl.Dhl_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = DHL_CREATED_BY
Where
	To_Date(Sdhl.Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sdhl.Dhl_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Transaction Limit Update'' As FunctionName,
	Stlu.Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	Stlu.Trm_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.Support_Txn_Limit_Request_Map@{DB_LINK_DCMS} Stlu
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}  Iccm On Stlu.Trm_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Stlu.Trm_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = TRM_CREATED_BY
Where
	To_Date(Stlu.Trm_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Stlu.Trm_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Cash Card Request'' As FunctionName,
	TO_CHAR (ICCR.CCR_Created_Ts) As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	ICCR.CCR_Remark As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} ICCR
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}  Iccm On ICCR.CCR_CLT_Id = Iccm.CCM_CLT_ID
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On ICCR.CCR_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CCR_CREATED_BY
Where
	To_Date(ICCR.CCR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And ICCR.CCR_Ins_Id = {Iss_Name}
UNION ALL
Select
	''Debit Card Request'' As FunctionName,
	TO_CHAR (IDCR.DCR_Created_Ts) As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
    STF1.STF_LOGIN_NAME AS MAKER,
	IDCR.DCR_Remark As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	'' '' FROM_DATA,
    '' '' TO_DATA,
	Ms.Sts_Name As Status,
	'''' as AUDIT_LOG
From
	{DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} IDCR
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}  Iccm On IDCR.DCR_CLT_Id = Iccm.CCM_CLT_ID
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_CRD_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On IDCR.DCR_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = DCR_CREATED_BY
Where
	To_Date(IDCR.DCR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And IDCR.DCR_Ins_Id = 1
	
UNION ALL
Select
	''CC WITHHELD AUTO RNW'' As FunctionName,
	TO_CHAR(TO_TIMESTAMP(Sccwith.CC_WAR_CREATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	ICC.CSH_CARD_NUMBER as CRD_NUMBER_ENC, 
	INS.INS_CODE AS INSTITUTION_ID,
	COALESCE(ICC.CSH_KEY_ROTATION_NUMBER, 1) ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	Sccwith.CC_WAR_REMARKS As Remarks,
	ICC.Csh_Cardholder_Name As CLIENT_NAME,
	'''' AS FROM_DATA,
    '''' AS TO_DATA,
	Ms.Sts_Name As Status,
	TO_CHAR(SUBSTR (CC_WAR_AUDIT_LOG,0,3999)) as AUDIT_LOG
From
	{DCMS_Schema}.SUPPORT_CC_WITHHELD_RENEWAL@{DB_LINK_DCMS} Sccwith
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccwith.CC_WAR_CAM_ID = ICCAM.CAM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccwith.CC_WAR_STS_ID=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_WAR_CREATED_BY
	Where
		To_Date(Sccwith.CC_WAR_CREATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
		AND STS_ID = 89
		And Sccwith.CC_WAR_INS_ID = {Iss_Name}
UNION ALL
Select
	''WITHHELD AUTO RNW'' As FunctionName,
	TO_CHAR(TO_TIMESTAMP(Swrnw.WAR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	COALESCE(Ic.CRD_KEY_ROTATION_NUMBER, 1) ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	Swrnw.WAR_REMARKS As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' AS FROM_DATA,
    '''' AS TO_DATA,
	Ms.Sts_Name As Status,
	TO_CHAR(SUBSTR (WAR_AUDIT_LOG,0,3999)) as AUDIT_LOG
From
	{DCMS_Schema}.SUPPORT_WITHHELD_RENEWAL@{DB_LINK_DCMS} Swrnw
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}  Iccm On Swrnw.WAR_CCM_ID = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Swrnw.WAR_STS_ID=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = WAR_CREATED_BY
Where
	To_Date(Swrnw.WAR_CREATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date_UTC}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID = 89
	And Swrnw.WAR_INS_ID = {Iss_Name}

) ORDER BY ISSUE_DATE
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