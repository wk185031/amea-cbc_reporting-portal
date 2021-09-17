-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS
-- Rel-20210827			27-AUG-2021		KW		Revise query

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Approved Rejected Card Records';
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
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"APPROVED/REJECTED CARD RECORDS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":2,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"CUSTOMER NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","defaultValue":"CUSTOMER NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"FUNCTION","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"FUNCTION /","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"17","fieldName":"FROM DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM DATA","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"18","fieldName":"TO DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO DATA","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"8","fieldName":"MAKER ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"MAKER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":8,"sectionName":"19","fieldName":"CHECKER ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHECKER ID","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":9,"sectionName":"10","fieldName":"STATUS","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"STATUS","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":10,"sectionName":"21","fieldName":"REMARKS","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"EMPTY","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":12,"sectionName":"27","fieldName":"EMPTY","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"28","fieldName":"EMPTY","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"DESCRIPTION","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":15,"sectionName":"15","fieldName":"ISSUE_DATE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"16","fieldName":"CRD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":17,"sectionName":"17","fieldName":"CLIENT_NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"18","fieldName":"FUNCTION_NAME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"25","fieldName":"FROM_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":false},{"sequence":20,"sectionName":"26","fieldName":"TO_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"22","fieldName":"MAKER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"23","fieldName":"CHECKER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"24","fieldName":"STATUS","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"20","fieldName":"REMARKS","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]');
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"APPROVED/REJECTED CARD RECORDS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":2,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"CUSTOMER NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","defaultValue":"CUSTOMER NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"FUNCTION","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"FUNCTION /","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"17","fieldName":"FROM DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM DATA","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"18","fieldName":"TO DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO DATA","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"8","fieldName":"MAKER ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"MAKER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":8,"sectionName":"19","fieldName":"CHECKER ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHECKER ID","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":9,"sectionName":"10","fieldName":"STATUS","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"STATUS","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":10,"sectionName":"21","fieldName":"REMARKS","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"EMPTY","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":12,"sectionName":"27","fieldName":"EMPTY","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"28","fieldName":"EMPTY","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"DESCRIPTION","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":15,"sectionName":"15","fieldName":"ISSUE_DATE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"16","fieldName":"CRD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":17,"sectionName":"17","fieldName":"CLIENT_NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"18","fieldName":"FUNCTION_NAME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"25","fieldName":"FROM_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":false},{"sequence":20,"sectionName":"26","fieldName":"TO_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"22","fieldName":"MAKER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"23","fieldName":"CHECKER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"24","fieldName":"STATUS","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"20","fieldName":"REMARKS","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT * FROM (
SELECT
	''ACCOUNT DELINK'' AS FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(SALD.ADL_CREATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') AS ISSUE_DATE,
	IC.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	IC.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	SALD.ADL_REMARKS AS REMARKS,
	IC.CRD_CARDHOLDER_NAME AS CLIENT_NAME,
	ADL_BAC_ID FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
FROM
	{DCMS_Schema}.SUPPORT_ACCOUNT_DELINKING@{DB_LINK_DCMS} SALD
	JOIN {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} ICCM ON SALD.ADL_CCM_ID = ICCM.CCM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON ICCM.CCM_CRD_ID = IC.CRD_ID
	JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON SALD.ADL_STS_ID=MS.STS_ID
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = ADL_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = ADL_UPDATED_BY
Where
	TO_DATE(Sald.Adl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between TO_DATE({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	AND SALD.ADL_INS_ID = {Iss_Name}
UNION ALL
Select
	''ACCOUNT LINKING'' As FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Acl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As ISSUE_DATE,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Sal.Acl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    CAST(ACL_BAC_ID AS VARCHAR2(1000)) TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Account_Linking@{DB_LINK_DCMS} Sal
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sal.Acl_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Sal.Acl_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = ACL_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = ACL_UPDATED_BY
Where
	To_Date(Sal.Acl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Sal.Acl_Ins_Id = {Iss_Name}
Union All
Select
	''CARD ACTIVATION'' As FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Sac.Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Sac.Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Card_Activation@{DB_LINK_DCMS} Sac
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sac.Caa_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Sac.Caa_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CAA_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CAA_UPDATED_BY
Where
	To_Date(Sac.Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'')  Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date},''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Sac.Caa_Ins_Id = {Iss_Name}
UNION ALL
Select
	''CARD ACTIVATION'' FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Scca.Cc_Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Scca.Cc_Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Cc_Activation@{DB_LINK_DCMS} Scca
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scca.Cc_Caa_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scca.Cc_Caa_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_CAA_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_CAA_UPDATED_BY
Where
	To_Date(Scca.Cc_Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Scca.Cc_Caa_Ins_Id = {Iss_Name}
Union All
Select
	''CARD RENEWAL'' As FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Scr.Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Scr.Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Card_Renewal@{DB_LINK_DCMS} Scr
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scr.Crn_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Scr.Crn_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CRN_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CRN_UPDATED_BY
Where
	To_Date(Scr.Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Scr.Crn_Ins_Id = {Iss_Name}
Union All
Select
	''CARD RENEWAL'' FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Sccr.Cc_Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC ,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Sccr.Cc_Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Cc_Renewal@{DB_LINK_DCMS} Sccr
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccr.Cc_Crn_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccr.Cc_Crn_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_CRN_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_CRN_UPDATED_BY
Where
	To_Date(Sccr.Cc_Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Sccr.Cc_Crn_Ins_Id = {Iss_Name}	
Union All
Select
	''HOTLIST'' FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Scch.Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Scch.Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Hotlist@{DB_LINK_DCMS} Scch
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scch.Hot_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scch.Hot_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = HOT_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = HOT_UPDATED_BY
Where
	To_Date(Scch.Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Scch.Hot_Ins_Id = {Iss_Name}	
UNION ALL
Select
	''HOTLIST'' FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Scht.Cc_Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Scht.Cc_Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Cc_Hotlist@{DB_LINK_DCMS} Scht
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scht.Cc_Hot_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scht.Cc_Hot_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_HOT_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_HOT_UPDATED_BY
Where
	To_Date(Scht.Cc_Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Scht.Cc_Hot_Ins_Id = {Iss_Name}	
UNION ALL
Select
	''DEHOTLIST'' As FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Sdhl.Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Sdhl.Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Dehotlist@{DB_LINK_DCMS} Sdhl
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdhl.Dhl_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdhl.Dhl_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = DHL_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = DHL_UPDATED_BY
Where
	To_Date(Sdhl.Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Sdhl.Dhl_Ins_Id = {Iss_Name}	
UNION ALL
Select
	''DEHOTLIST'' FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Sccd.Cc_Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Sccd.Cc_Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Cc_Dehotlist@{DB_LINK_DCMS} Sccd
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccd.Cc_Dhl_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccd.Cc_Dhl_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_DHL_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_DHL_UPDATED_BY
Where
	To_Date(Sccd.Cc_Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Sccd.Cc_Dhl_Ins_Id = {Iss_Name}
UNION ALL
Select
	''RESET PIN COUNTER'' FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Srp.Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Srp.Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Reset_Pin_Counter@{DB_LINK_DCMS} Srp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Srp.Rpc_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Rpc_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = RPC_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = RPC_UPDATED_BY
Where
	To_Date(Srp.Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Srp.Rpc_Ins_Id = {Iss_Name}
Union All
Select
	''RESET PIN COUNTER'' FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Sccrp.Cc_Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Sccrp.Cc_Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Cc_Reset_Pin_Counter@{DB_LINK_DCMS} Sccrp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccrp.Cc_Rpc_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccrp.Cc_Rpc_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_RPC_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_RPC_UPDATED_BY
Where
	To_Date(Sccrp.Cc_Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Sccrp.Cc_Rpc_Ins_Id = {Iss_Name}
Union All
Select
	''REPIN'' FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Sdrp.Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Sdrp.Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Repin@{DB_LINK_DCMS} Sdrp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdrp.Rep_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdrp.Rep_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = REP_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = REP_UPDATED_BY
Where
	To_Date(Sdrp.Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Sdrp.Rep_Ins_Id = {Iss_Name}
UNION ALL
Select
	''REPIN'' As FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Srp.Cc_Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Srp.Cc_Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Cc_Repin@{DB_LINK_DCMS} Srp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Srp.Cc_Rep_Cam_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Cc_Rep_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_REP_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_REP_UPDATED_BY
Where
	To_Date(Srp.Cc_Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Srp.Cc_Rep_Ins_Id = {Iss_Name}
UNION ALL
Select
	''CHANGE ACCOUNT'' As FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(DAR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Dac.DAR_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Default_Acc_Req_Map@{DB_LINK_DCMS} Dac
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Dac.DAR_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Dac.DAR_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = DAR_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = DAR_UPDATED_BY
Where
	To_Date(Dac.DAR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Dac.Dar_Ins_Id = {Iss_Name}
UNION ALL
Select
	''UPDATE LIMIT'' As FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(Stlu.Trm_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	Stlu.Trm_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.Support_Txn_Limit_Request_Map@{DB_LINK_DCMS} Stlu
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}  Iccm On Stlu.Trm_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Stlu.Trm_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = TRM_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = TRM_UPDATED_BY
Where
	To_Date(Stlu.Trm_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And Stlu.Trm_Ins_Id = {Iss_Name}
UNION ALL
Select
	''UPDATE CIF'' As FUNCTION_NAME,
	TO_CHAR(TO_TIMESTAMP(FCR.FCR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	STF1.STF_LOGIN_NAME As Maker,
	STF2.STF_LOGIN_NAME As Checker,
	FCR.FCR_COMMENT As Remarks,
	Ic.Crd_Cardholder_Name As CLIENT_NAME,
	'''' FROM_DATA,
    '''' TO_DATA,
	CASE WHEN Ms.Sts_Id = 91 THEN ''Approved'' ELSE Ms.Sts_Name END As Status
From
	{DCMS_Schema}.SUPPORT_FETCH_CIF_REQUEST@{DB_LINK_DCMS} FCR
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On FCR.FCR_CLT_ID = Iccm.Ccm_CLT_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On FCR.FCR_STS_ID=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = FCR_CREATED_BY
    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = FCR_UPDATED_BY
Where
	To_Date(FCR.FCR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90, 91)
	And FCR.FCR_Ins_Id = {Iss_Name}
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