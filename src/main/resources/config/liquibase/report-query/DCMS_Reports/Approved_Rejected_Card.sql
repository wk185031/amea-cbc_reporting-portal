-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS
-- Rel-20210827			27-AUG-2021		KW		Revise query
-- 						11-NOV-2021		AM		844: Approved/Rejected	
-- Rel-20211204			12-DEC-2021		AM		844: Approved/Rejected								

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Approved Rejected Card Records';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_BODY_QUERY_2 CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"APPROVED/REJECTED CARD RECORDS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":2,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD/ACCOUNT/REF No","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"CUSTOMER NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","defaultValue":"CUSTOMER/CARD TRANSACTION SET NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"CARD TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"CARD TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"FUNCTION","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"FUNCTION /","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"FROM DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM DATA","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"TO DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO DATA","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"MAKER ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"MAKER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":9,"sectionName":"9","fieldName":"CHECKER ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHECKER ID","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":10,"sectionName":"10","fieldName":"STATUS","csvTxtLength":"7","pdfLength":"7","fieldType":"String","defaultValue":"STATUS","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"REMARKS","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"EMPTY","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"EMPTY","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"EMPTY","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","fieldName":"EMPTY","csvTxtLength":"10","pdfLength":"10","fieldType":"String","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":16,"sectionName":"16","fieldName":"DESCRIPTION","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":17,"sectionName":"17","fieldName":"ISSUE_DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"18","fieldName":"CRD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":19,"sectionName":"19","fieldName":"CLIENT_NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":20,"sectionName":"20","fieldName":"CARD_TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"tagValue":null},{"sequence":21,"sectionName":"21","fieldName":"FUNCTION_NAME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"22","fieldName":"FROM_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":false},{"sequence":23,"sectionName":"23","fieldName":"TO_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"24","fieldName":"MAKER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"25","fieldName":"CHECKER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"26","fieldName":"STATUS","csvTxtLength":"7","pdfLength":"7","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"27","fieldName":"REMARKS","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]');
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0112","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"APPROVED/REJECTED CARD RECORDS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":2,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD/ACCOUNT/REF No","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"CUSTOMER NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","defaultValue":"CUSTOMER/CARD TRANSACTION SET NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"CARD TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"CARD TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"FUNCTION","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"FUNCTION /","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"FROM DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FROM DATA","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"TO DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TO DATA","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"8","fieldName":"MAKER ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"MAKER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":9,"sectionName":"9","fieldName":"CHECKER ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHECKER ID","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":10,"sectionName":"10","fieldName":"STATUS","csvTxtLength":"7","pdfLength":"7","fieldType":"String","defaultValue":"STATUS","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"REMARKS","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"REMARKS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"EMPTY","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"EMPTY","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"EMPTY","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"15","fieldName":"EMPTY","csvTxtLength":"10","pdfLength":"10","fieldType":"String","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":16,"sectionName":"16","fieldName":"DESCRIPTION","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":17,"sectionName":"17","fieldName":"ISSUE_DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"18","fieldName":"CRD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":19,"sectionName":"19","fieldName":"CLIENT_NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":20,"sectionName":"20","fieldName":"CARD_TYPE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"tagValue":null},{"sequence":21,"sectionName":"21","fieldName":"FUNCTION_NAME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"22","fieldName":"FROM_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":false},{"sequence":23,"sectionName":"23","fieldName":"TO_DATA","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"24","fieldName":"MAKER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"25","fieldName":"CHECKER","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"26","fieldName":"STATUS","csvTxtLength":"7","pdfLength":"7","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"27","fieldName":"REMARKS","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]');
	
	i_BODY_QUERY := TO_CLOB('
		SELECT * FROM (
		SELECT
			''ACCOUNT DE-LINKING'' AS FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(SALD.ADL_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') AS ISSUE_DATE,
			IC.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			IC.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			SALD.ADL_REMARKS AS REMARKS,
			IC.CRD_CARDHOLDER_NAME AS CLIENT_NAME,
			ADL_BAC_ID FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		FROM
			{DCMS_Schema}.SUPPORT_ACCOUNT_DELINKING@{DB_LINK_DCMS} SALD
			JOIN {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} ICCM ON SALD.ADL_CCM_ID = ICCM.CCM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON ICCM.CCM_CRD_ID = IC.CRD_ID
			JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON SALD.ADL_STS_ID=MS.STS_ID
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = ADL_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = ADL_UPDATED_BY
		Where
			TO_DATE(SALD.ADL_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between TO_DATE({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			AND SALD.ADL_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''ACCOUNT LINKING'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(ACL_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As ISSUE_DATE,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			SAL.Acl_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    CAST(ACL_BAC_ID AS VARCHAR2(1000)) TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Account_Linking@{DB_LINK_DCMS} SAL
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On SAL.Acl_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On SAL.Acl_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = ACL_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = ACL_UPDATED_BY
		Where
			To_Date(SAL.ACL_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And SAL.Acl_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''ADDRESS UPDATE'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(AUR.AUR_Updated_Ts, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			AUR.AUR_REMARKS As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_ADDRESS_UPDATE_REQ_MAP@{DB_LINK_DCMS} AUR
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On AUR.AUR_CLT_ID = Iccm.Ccm_CLT_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On AUR.AUR_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = AUR_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = AUR_UPDATED_BY
		Where
			To_Date(AUR.AUR_Updated_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And AUR.AUR_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select
			''CARD ACTIVATION'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sac.CAA_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sac.Caa_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Card_Activation@{DB_LINK_DCMS} Sac
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sac.Caa_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Sac.Caa_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CAA_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CAA_UPDATED_BY
		Where
			To_Date(Sac.CAA_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'')  Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date},''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sac.Caa_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select
			''CARD RENEWAL'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Scr.CRN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Scr.Crn_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Card_Renewal@{DB_LINK_DCMS} Scr
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scr.Crn_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Scr.Crn_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CRN_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CRN_UPDATED_BY
		Where
			To_Date(Scr.CRN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Scr.Crn_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''CC CARD ACTIVATION'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Scca.CC_CAA_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Scca.Cc_Caa_Remarks As Remarks,
			Icc.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
			'''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_CC_Activation@{DB_LINK_DCMS} Scca
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Scca.Cc_Caa_Cam_Id = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			--Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scca.Cc_Caa_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_CAA_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_CAA_UPDATED_BY
		Where
			To_Date(Scca.CC_CAA_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND Scca.Cc_Caa_Sts_Id IN (90, 91)
			And Scca.Cc_Caa_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''CC ADDRESS UPDATE'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccadd.CC_AUR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccadd.CC_AUR_REMARKS As Remarks,
			ICC.CSH_CARDHOLDER_NAME As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_CC_ADD_UPDATE_REQ_MAP@{DB_LINK_DCMS} Sccadd
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccadd.CC_AUR_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccadd.CC_AUR_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_AUR_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_AUR_UPDATED_BY
		Where
			To_Date(Sccadd.CC_AUR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccadd.CC_AUR_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''CC CLOSE CARD'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccclo.CC_CCD_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccclo.CC_CCD_REMARKS As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_CC_CLOSE@{DB_LINK_DCMS} Sccclo
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccclo.CC_CCD_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccclo.CC_CCD_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_CCD_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_CCD_UPDATED_BY
		Where
			To_Date(Sccclo.CC_CCD_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccclo.CC_CCD_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''CC DEHOTLIST'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccd.CC_DHL_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccd.Cc_Dhl_Remarks As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		  '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_CC_Dehotlist@{DB_LINK_DCMS} Sccd
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccd.CC_DHL_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccd.Cc_Dhl_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_DHL_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_DHL_UPDATED_BY
		Where
			To_Date(Sccd.CC_DHL_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccd.Cc_Dhl_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''CC HOTLIST'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Scht.CC_HOT_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Scht.Cc_Hot_Remarks As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_CC_Hotlist@{DB_LINK_DCMS} Scht
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Scht.CC_HOT_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scht.Cc_Hot_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_HOT_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_HOT_UPDATED_BY
		Where
			To_Date(Scht.CC_HOT_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Scht.Cc_Hot_Ins_Id = {Iss_Name}	
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select
			''CC CARD RENEWAL'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccr.CC_CRN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccr.Cc_Crn_Remarks As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_CC_Renewal@{DB_LINK_DCMS} Sccr
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccr.CC_CRN_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccr.Cc_Crn_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_CRN_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_CRN_UPDATED_BY
		Where
			To_Date(Sccr.CC_CRN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccr.Cc_Crn_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''CC REPIN'' As FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Srp.CC_REP_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Srp.Cc_Rep_Remarks As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_CC_Repin@{DB_LINK_DCMS} Srp
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Srp.CC_REP_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Cc_Rep_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_REP_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_REP_UPDATED_BY
		Where
			To_Date(Srp.CC_REP_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Srp.Cc_Rep_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select
			''CC RESET PIN COUNTER'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccrp.CC_RPC_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccrp.Cc_Rpc_Remarks As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			TO_CHAR(CC_OLD_PIN_COUNTER) FROM_DATA,
		    ''0'' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_CC_Reset_Pin_Counter@{DB_LINK_DCMS} Sccrp
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccrp.Cc_Rpc_Cam_Id = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccrp.Cc_Rpc_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_RPC_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_RPC_UPDATED_BY
		Where
			To_Date(Sccrp.CC_RPC_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccrp.Cc_Rpc_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select
			''CC STOP CARD RENEWAL'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccsr.CC_SRN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccsr.CC_SRN_REMARKS As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_CC_STOP_RENEWAL@{DB_LINK_DCMS} Sccsr
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccsr.CC_SRN_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccsr.CC_SRN_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_SRN_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_SRN_UPDATED_BY
		Where
			To_Date(Sccsr.CC_SRN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccsr.CC_SRN_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select
			''CC TXN LIMIT UPDATE'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Scctxn.CC_TRM_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Scctxn.CC_TRM_REMARKS As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_CC_TXN_LIMIT_REQ_MAP@{DB_LINK_DCMS} Scctxn
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Scctxn.CC_TRM_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scctxn.CC_TRM_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_TRM_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_TRM_UPDATED_BY
		Where
			To_Date(Scctxn.CC_TRM_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Scctxn.CC_TRM_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select
			''CC UPD EMBOSS NAME'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccuen.UEN_CC_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccuen.UEN_CC_REMARKS As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_CC_UPDATE_EMBOSS_NAME@{DB_LINK_DCMS} Sccuen
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON Sccuen.UEN_CC_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccuen.UEN_CC_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = UEN_CC_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = UEN_CC_UPDATED_BY
		Where
			To_Date(Sccuen.UEN_CC_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccuen.UEN_CC_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select
			''CC WITHHELD AUTO RNW'' FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccwith.CC_WAR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			ICC.CSH_CARD_NUMBER, 
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccwith.CC_WAR_REMARKS As Remarks,
			ICC.Csh_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_CC_WITHHELD_RENEWAL@{DB_LINK_DCMS} Sccwith
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccwith.CC_WAR_CAM_ID = ICCAM.CAM_ID
			JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccwith.CC_WAR_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CC_WAR_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CC_WAR_UPDATED_BY
		Where
			To_Date(Sccwith.CC_WAR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccwith.CC_WAR_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		');	
	
	i_BODY_QUERY_2 := TO_CLOB('Union All
		Select
			''CLOSE CARD'' FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sccard.CCD_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sccard.CCD_REMARKS As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_CLOSE_CARD@{DB_LINK_DCMS} Sccard
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccard.CCD_CCM_ID = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccard.CCD_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CCD_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CCD_UPDATED_BY
		Where
			To_Date(Sccard.CCD_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sccard.CCD_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''DEFAULT ACC CHANGE'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(DAR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Dac.DAR_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Default_Acc_Req_Map@{DB_LINK_DCMS} Dac
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Dac.DAR_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Dac.DAR_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = DAR_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = DAR_UPDATED_BY
		Where
			To_Date(Dac.DAR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Dac.Dar_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''DEHOTLIST'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sdhl.DHL_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sdhl.Dhl_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Dehotlist@{DB_LINK_DCMS} Sdhl
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdhl.Dhl_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdhl.Dhl_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = DHL_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = DHL_UPDATED_BY
		Where
			To_Date(Sdhl.DHL_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sdhl.Dhl_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select 
			''FETCH CIF'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(FCR.FCR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			COALESCE(Ic.CRD_KEY_ROTATION_NUMBER, 0) ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			FCR.FCR_COMMENT As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_FETCH_CIF_REQUEST@{DB_LINK_DCMS} FCR
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On FCR.FCR_CLT_ID = Iccm.Ccm_CLT_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On FCR.FCR_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = FCR_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = FCR_UPDATED_BY
		Where
			To_Date(FCR.FCR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And FCR.FCR_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select 
			''HOTLIST'' FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Scch.HOT_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Scch.Hot_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Hotlist@{DB_LINK_DCMS} Scch
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scch.Hot_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scch.Hot_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = HOT_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = HOT_UPDATED_BY
		Where
			To_Date(Scch.HOT_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Scch.Hot_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		Union All
		Select 
			''REPIN'' FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Sdrp.REP_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Sdrp.Rep_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Repin@{DB_LINK_DCMS} Sdrp
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdrp.Rep_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdrp.Rep_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = REP_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = REP_UPDATED_BY
		Where
			To_Date(Sdrp.REP_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Sdrp.Rep_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select 
			''RESET PIN COUNTER'' FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Srp.RPC_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Srp.Rpc_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			TO_CHAR(OLD_PIN_COUNTER) FROM_DATA,
		    ''0'' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Reset_Pin_Counter@{DB_LINK_DCMS} Srp
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Srp.Rpc_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Rpc_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = RPC_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = RPC_UPDATED_BY
		Where
			To_Date(Srp.RPC_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Srp.Rpc_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''STOP CARD RENEWAL'' FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Ssrnw.SRN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Ssrnw.SRN_REMARKS As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_STOP_RENEWAL@{DB_LINK_DCMS} Ssrnw
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Ssrnw.SRN_CCM_ID = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Ssrnw.SRN_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = SRN_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = SRN_UPDATED_BY
		Where
			To_Date(Ssrnw.SRN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Ssrnw.SRN_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''TXN LIMIT UPDATE'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Stlu.TRM_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Stlu.Trm_Remarks As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.Support_Txn_Limit_Request_Map@{DB_LINK_DCMS} Stlu
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}  Iccm On Stlu.Trm_Ccm_Id = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Stlu.Trm_Sts_Id=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = TRM_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = TRM_UPDATED_BY
		Where
			To_Date(Stlu.TRM_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Stlu.Trm_Ins_Id = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''UPD EMBOSS NAME'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Suemb.UEN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Suemb.UEN_REMARKS As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_UPDATE_EMBOSS_NAME@{DB_LINK_DCMS} Suemb
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Suemb.UEN_CRD_ID = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Suemb.UEN_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = UEN_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = UEN_UPDATED_BY
		Where
			To_Date(Suemb.UEN_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Suemb.UEN_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		Select
			''WITHHELD AUTO RNW'' As FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			TO_CHAR(TO_TIMESTAMP(Swrnw.WAR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			Ic.CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			Swrnw.WAR_REMARKS As Remarks,
			Ic.Crd_Cardholder_Name As CLIENT_NAME,
			'''' FROM_DATA,
		    '''' TO_DATA,
			CASE WHEN Ms.Sts_Id = 91 THEN ''A'' WHEN Ms.Sts_Id = 90 THEN ''R'' ELSE Ms.Sts_Name END As Status
		From
			{DCMS_Schema}.SUPPORT_WITHHELD_RENEWAL@{DB_LINK_DCMS} Swrnw
			Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS}  Iccm On Swrnw.WAR_CCM_ID = Iccm.Ccm_Id
			Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
			Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Swrnw.WAR_STS_ID=Ms.Sts_Id
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = WAR_CREATED_BY
		    LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = WAR_UPDATED_BY
		Where
			To_Date(Swrnw.WAR_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
			AND STS_ID IN (90, 91)
			And Swrnw.WAR_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
		UNION ALL
		--new card debit
		SELECT DISTINCT
			''NEW CARD'' AS FUNCTION_NAME,
			''DEBIT'' AS CARD_TYPE,
			CASE WHEN STS_ID = 70 THEN TO_CHAR(IDCR.DCR_APPROVED_TS, ''MM/DD/YY HH24:MI'')
		    ELSE TO_CHAR(IDCR.DCR_UPDATED_TS, ''MM/DD/YY HH24:MI'') END AS ISSUE_DATE,
			CASE WHEN IDCR.DCR_STS_ID IN (68,69) THEN IDCR.DCR_NUMBER ELSE 
			--{DCMS_Schema}.get_accno@{DB_LINK_DCMS}(IDCR.DCR_ID)
			 JSON_VALUE(IDCR.DCR_CIF_RESPONSE, ''$.bankAccountCollection[0].bacAccountNumber[0]'')
			-- {DCMS_Schema}.get_accno@{DB_LINK_DCMS}(IDCR.DCR_CIF_RESPONSE) 
				END AS ACC_NO,
			INS.INS_CODE AS INSTITUTION_ID,
			IC.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			IDCR.DCR_REMARK AS REMARKS,
			IC.CRD_CARDHOLDER_NAME AS CLIENT_NAME,
			'''' FROM_DATA,
			'''' TO_DATA,
			CASE WHEN IDCR.DCR_STS_ID IN (68,70) THEN ''A'' WHEN IDCR.DCR_STS_ID = 69 THEN ''R'' ELSE Ms.Sts_Name END As Status
		FROM
			{DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} IDCR
			LEFT JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON IC.CRD_BCR_ID = IDCR.DCR_NUMBER
			JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON IDCR.DCR_STS_ID = MS.STS_ID
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IDCR.DCR_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = IDCR.DCR_CREATED_BY
		    JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = IDCR.DCR_UPDATED_BY
		Where
			(IDCR.DCR_STS_ID IN (68,70) AND IDCR.DCR_APPROVED_TS >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And IDCR.DCR_APPROVED_TS <= To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
		    OR IDCR.DCR_STS_ID = 69 AND IDCR.DCR_UPDATED_TS >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And IDCR.DCR_UPDATED_TS <= To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'') )
		  AND IDCR.DCR_REQUEST_TYPE NOT IN (''Renew'', ''Replace'')
			AND IDCR.DCR_INS_ID = {Iss_Name}
		UNION ALL
		--new cash card
		SELECT DISTINCT
			''NEW CARD'' AS FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
			CASE WHEN ICCR.CCR_STS_ID = 70 THEN TO_CHAR(ICCR.CCR_APPROVED_TS, ''MM/DD/YY HH24:MI'')
		    ELSE TO_CHAR(ICCR.CCR_UPDATED_TS, ''MM/DD/YY HH24:MI'') END AS ISSUE_DATE,
			CASE WHEN ICCR.CCR_STS_ID IN (68,69) THEN ICCR.CCR_NUMBER WHEN ICCR.CCR_STS_ID = 70 THEN ICCA.CAC_ACCOUNT_NUMBER END ,
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			ICCR.CCR_REMARK AS REMARKS,
			ICC.CSH_CARDHOLDER_NAME AS CLIENT_NAME,
			'''' FROM_DATA,
			'''' TO_DATA,
			CASE WHEN ICCR.CCR_STS_ID IN (68,70) THEN ''A'' WHEN ICCR.CCR_STS_ID = 69 THEN ''R'' ELSE Ms.Sts_Name END As Status
		FROM
			{DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} ICCR 
			LEFT JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICC.CSH_BCR_ID = ICCR.CCR_NUMBER
		    LEFT JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCM ON ICCM.CAM_CSH_ID = ICCR.CCR_CSH_ID
		    LEFT JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACCOUNT@{DB_LINK_DCMS} ICCA ON ICCA.CAC_ID = ICCM.CAM_CAC_ID
			JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON ICCR.CCR_STS_ID=MS.STS_ID
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICCR.CCR_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = ICCR.CCR_CREATED_BY
		    JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = ICCR.CCR_UPDATED_BY
		Where
		    (ICCR.CCR_STS_ID IN (68,70) AND ICCR.CCR_APPROVED_TS >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And ICCR.CCR_APPROVED_TS <= To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
		    OR ICCR.CCR_STS_ID = 69 AND ICCR.CCR_UPDATED_TS >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And ICCR.CCR_UPDATED_TS <= To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'') )
			AND ICCR.CCR_REQUEST_TYPE NOT IN (''Renew'', ''Replace'')
			AND ICCR.CCR_INS_ID = {Iss_Name}
		UNION ALL
		--new bulk/pregen 
		SELECT DISTINCT
			''NEW CARD'' AS FUNCTION_NAME,
		  	CASE WHEN IC.CRD_BCR_ID IS NOT NULL THEN ''DEBIT'' ELSE ''CASH'' END AS CARD_TYPE,
			CASE WHEN IBCR.BCR_STS_ID = 70 THEN TO_CHAR(IBCR.BCR_APPROVED_TS, ''MM/DD/YY HH24:MI'')
		    ELSE TO_CHAR(IBCR.BCR_UPDATED_TS, ''MM/DD/YY HH24:MI'') END AS ISSUE_DATE,
			IBCR.BCR_NUMBER,
			INS.INS_CODE AS INSTITUTION_ID,
			CASE WHEN IC.CRD_BCR_ID IS NOT NULL THEN IC.CRD_KEY_ROTATION_NUMBER 
        		ELSE ICC.CSH_KEY_ROTATION_NUMBER END AS ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			CONCAT(''No of Card = '', IBCR.BCR_NUMBER_OF_CARDS) AS REMARKS,
			CASE WHEN IC.CRD_BCR_ID IS NOT NULL THEN IC.CRD_CARDHOLDER_NAME
        		ELSE ICC.CSH_CARDHOLDER_NAME END AS CLIENT_NAME,
			'''' FROM_DATA,
			'''' TO_DATA,
			CASE WHEN IBCR.BCR_STS_ID IN (68,70) THEN ''A'' WHEN IBCR.BCR_STS_ID = 69 THEN ''R'' ELSE Ms.Sts_Name END As Status
		FROM
			{DCMS_Schema}.ISSUANCE_BULK_CARD_REQUEST@{DB_LINK_DCMS} IBCR
			LEFT JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} IC ON IC.CRD_BCR_ID = IBCR.BCR_NUMBER
			LEFT JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICC.CSH_BCR_ID = IBCR.BCR_NUMBER
			JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON IBCR.BCR_STS_ID = MS.STS_ID
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IBCR.BCR_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = IBCR.BCR_CREATED_BY
		    JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = IBCR.BCR_UPDATED_BY
		Where
			(IBCR.BCR_STS_ID IN (68,70) AND IBCR.BCR_APPROVED_TS >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And IBCR.BCR_APPROVED_TS <= To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
		    OR IBCR.BCR_STS_ID = 69 AND IBCR.BCR_UPDATED_TS >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And IBCR.BCR_UPDATED_TS <= To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'') )
			AND IBCR.BCR_INS_ID = {Iss_Name}
	UNION ALL
		SELECT
				''UPDATE CC ACC STS'' AS FUNCTION_NAME,
				''CASH'' AS CARD_TYPE,
				TO_CHAR(CAC.CAC_UPDATED_TS, ''MM/DD/YY HH24:MI'') AS ISSUE_DATE,
				CAC.CAC_ACCOUNT_NUMBER,
				INS.INS_CODE AS INSTITUTION_ID,
				COALESCE(CAC.CAC_KEY_ROTATION_NUMBER, ICC.CSH_KEY_ROTATION_NUMBER) ROTATION_NUMBER,
				STF1.STF_LOGIN_NAME As Maker,
				STF2.STF_LOGIN_NAME As Checker,
				CAC.CAC_REMARK AS REMARKS,
				ICC.CSH_CARDHOLDER_NAME AS CLIENT_NAME,
				MS_FROM.Sts_Name FROM_DATA,
        		MS_TO.Sts_Name TO_DATA,
				CASE WHEN CAC.CAC_REQ_STS_ID = 68 THEN ''A'' WHEN CAC.CAC_REQ_STS_ID = 69 THEN ''R'' ELSE Ms.Sts_Name END As Status
			FROM
				{DCMS_Schema}.ISSUANCE_CASH_CARD_ACCOUNT_REQUEST@{DB_LINK_DCMS} CAC
	      		JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACCOUNT@{DB_LINK_DCMS} CCA ON CCA.CAC_ID = CAC.CAC_ACCOUNT_ID
        		JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} CAM ON CAM.CAM_CAC_ID = CCA.CAC_ID
	      		JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICC.CSH_ID = CAM.CAM_CSH_ID
				JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON CAC.CAC_STS_ID=MS.STS_ID
        		JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS_FROM ON CAC.CAC_OLD_STS_ID=MS_FROM.STS_ID
        		JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS_TO ON CAC.CAC_STS_ID=MS_TO.STS_ID
				JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON CAC.CAC_INS_ID = INS.INS_ID
				JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CAC.CAC_CREATED_BY
	      JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CAC.CAC_UPDATED_BY
			Where
	      CAC.CAC_UPDATED_TS >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And CAC.CAC_UPDATED_TS <= To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	      AND CAC.CAC_REQ_STS_ID IN (68,69)
				AND CAC.CAC_INS_ID = {Iss_Name}
				AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
	UNION ALL
		SELECT
			''UPDATE CC BAL'' AS FUNCTION_NAME,
			''CASH'' AS CARD_TYPE,
      		TO_CHAR(TO_TIMESTAMP(CCB.CCB_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As Issue_Date,
			CCB.CCB_NUMBER,
			INS.INS_CODE AS INSTITUTION_ID,
			ICC.CSH_KEY_ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			CCB.CCB_REMARK AS REMARKS,
			ICC.CSH_CARDHOLDER_NAME AS CLIENT_NAME,
			'''' FROM_DATA,
      		CASE WHEN CCB_TRN_TYPE = ''Debit'' THEN CONCAT( ''-'', TO_CHAR(CCB_AMOUNT) )  
         		WHEN CCB_TRN_TYPE = ''Credit'' THEN CONCAT( ''+'', TO_CHAR(CCB_AMOUNT) ) END AS TO_DATA,
			CASE WHEN CCB.CCB_STS_ID = 68 THEN ''A'' WHEN CCB.CCB_STS_ID = 69 THEN ''R'' ELSE Ms.Sts_Name END As Status
		FROM
			{DCMS_Schema}.ISSUANCE_CASH_CARD_BALANCE@{DB_LINK_DCMS} CCB
      		JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} CAM ON CAM.CAM_ID = CCB.CCB_CAM_ID
      		JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICC.CSH_ID = CAM.CAM_CSH_ID
			JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON CCB.CCB_STS_ID = MS.STS_ID
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON CCB.CCB_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CCB.CCB_CREATED_BY
      		JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CCB.CCB_UPDATED_BY
		Where
			To_Date(CCB.CCB_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
        	AND CCB.CCB_INS_ID = {Iss_Name}
			AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)	
	UNION ALL
		SELECT
			''CARD STS MTN'' AS FUNCTION_NAME,
			CSM.CSM_CRD_TYPE AS CARD_TYPE,
      		TO_CHAR(CSM.CSM_UPDATED_TS, ''MM/DD/YY HH24:MI'') As ISSUE_DATE,
			CSM.CSM_CRD_NUMBER_ENC,
			INS.INS_CODE AS INSTITUTION_ID,
			CSM.CSM_KEY_ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			CSM.CSM_REMARK AS REMARKS,
			CASE WHEN CSM.CSM_CRD_TYPE = ''DEBIT'' THEN CRD.CRD_CARDHOLDER_NAME ELSE CSH.CSH_CARDHOLDER_NAME END AS CLIENT_NAME,
			MS_FROM.STS_NAME AS FROM_DATA,
      		MS_TO.STS_NAME AS TO_DATA,
			CASE WHEN CSM.CSM_REQ_STS_ID = 68 THEN ''A'' WHEN CSM.CSM_REQ_STS_ID = 69 THEN ''R'' ELSE Ms.Sts_Name END As Status
		FROM
			{DCMS_Schema}.ISSUANCE_CARD_STATUS_MAINTENANCE@{DB_LINK_DCMS} CSM
      		LEFT JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} CRD ON CRD.CRD_ID = CSM.CSM_CRD_ID
			LEFT JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} CSH ON CSH.CSH_ID = CSM.CSM_CRD_ID
			LEFT JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS ON CSM.CSM_REQ_STS_ID = MS.STS_ID
			LEFT JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS_FROM ON CSM.CSM_CRD_CURRENT_STATUS = MS_FROM.STS_ID
      		LEFT JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} MS_TO ON CSM.CSM_CRD_NEW_STATUS = MS_TO.STS_ID
			JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON CSM.CSM_INS_ID = INS.INS_ID
			JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = CSM.CSM_CREATED_BY
      		JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = CSM.CSM_UPDATED_BY
		Where
    		CSM.CSM_UPDATED_TS >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And CSM.CSM_UPDATED_TS <= To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
     	 	AND CSM.CSM_REQ_STS_ID IN (68,69)
       		AND CSM.CSM_INS_ID = {Iss_Name}
	UNION ALL
			SELECT 
	     	''MODIFY CIF'' AS FUNCTION_NAME,
		  	''DEBIT'' AS CARD_TYPE,
	      	TO_CHAR(MOC_UPDATED_TS, ''MM/DD/YY HH24:MI'') As ISSUE_DATE,
		  	MOC.MOC_REQUEST_NUMBER,
		  	INS.INS_CODE AS INSTITUTION_ID,
			Ic.CRD_KEY_ROTATION_NUMBER,
			STF1.STF_LOGIN_NAME As Maker,
			STF2.STF_LOGIN_NAME As Checker,
			TO_CHAR(MOC.MOC_REMARKS) AS REMARKS,
			IC.Crd_Cardholder_Name AS CLIENT_NAME,
			TO_CHAR(MOC.MOC_OLD_CIF_NUMBER) FROM_DATA,
      		TO_CHAR(MOC.MOC_CIF_NUMBER) TO_DATA,
			CASE WHEN MOC.MOC_STS_ID = 68 THEN ''A'' WHEN MOC.MOC_STS_ID = 69 THEN ''R'' ELSE Ms.Sts_Name END As Status 
		FROM 
			{DCMS_Schema}.ISSUANCE_MODIFY_CIF@{DB_LINK_DCMS} MOC 
	  			LEFT JOIN {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On MOC.MOC_CLT_ID = Iccm.Ccm_CLT_Id
				LEFT JOIN {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
				JOIN {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On MOC.MOC_STS_ID=Ms.Sts_Id
				JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON MOC.MOC_INS_ID = INS.INS_ID
				JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF1 ON STF1.STF_ID = MOC_CREATED_BY
	      LEFT JOIN {DCMS_Schema}.USER_STAFF@{DB_LINK_DCMS} STF2 ON STF2.STF_ID = MOC_UPDATED_BY
		WHERE
		MOC_UPDATED_TS >= To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And MOC_UPDATED_TS <= To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'') AND
		--To_Date(MOC_UPDATED_TS, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'') AND
		MOC_STS_ID IN (68,69)
		AND MOC.MOC_INS_ID = {Iss_Name}
		AND (STF1.STF_IS_SUP IS NULL OR STF1.STF_IS_SUP != 1)
	UNION ALL 
	  SELECT 
	    FUNCTION, 
	    '''' AS CARD_TYPE,
		TO_CHAR(TO_DATE(JSON_VALUE(DETAILS, ''$.date_update''), ''YYYY-MM-DD HH24:MI:SS''), ''MM/DD/YY HH24:MI'') As ISSUE_DATE,
		null,
		JSON_VALUE(DETAILS, ''$.ins_code''),
		null,
		JSON_VALUE(DETAILS, ''$.maker'') AS MAKER,
		JSON_VALUE(DETAILS, ''$.checker'') AS CHECKER,
		'''',
		JSON_VALUE(DETAILS, ''$.cts_name'')  as CTS_NAME,
	    '''' FROM_DATA,
	    '''' TO_DATA,
	    JSON_VALUE(DETAILS, ''$.status'') AS STATUS
	    FROM DCMS_USER_ACTIVITY WHERE  FUNCTION = ''UPD TXN SET''
		AND INSTITUTION_ID = {Iss_Name}
		AND CREATED_DATE >= To_Timestamp({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') and CREATED_DATE < To_Timestamp({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	) ORDER BY ISSUE_DATE');
	
		dbms_lob.append(i_BODY_QUERY,i_BODY_QUERY_2);
		
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