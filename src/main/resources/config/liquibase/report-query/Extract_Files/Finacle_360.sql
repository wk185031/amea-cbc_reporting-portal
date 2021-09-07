-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-673	01-JULY-2021	WY		Fix empty report generated for Finacle 360
-- CBCAXUPISSLOG-673	06-JULY-2021	WY		Fix issue data generated in one single row
-- DCMS					22-AUG-2021		NY		Add date range by card created ts
-- DCMS					07-SEP-2021		NY		Query update by input from Opus, add status mapping to FCBS status

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Finacle 360
	i_HEADER_FIELDS := TO_CLOB('[]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"14","fieldName":"CIF ID","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CIF ID","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"15","fieldName":"BANK ID","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"BANK ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"16","fieldName":"CARD / IVRS NUMBER","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CARD / IVRS NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"17","fieldName":"ACCOUNT NUMBER","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"ACCOUNT NUMBER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"18","fieldName":"OPERATION FLAG","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"OPERATION FLAG","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"19","fieldName":"EMBOSSED NAME","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"EMBOSSED NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"20","fieldName":"CARD / IVRS TYPE","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CARD / IVRS TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"21","fieldName":"CARD SUBTYPE","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CARD SUBTYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"22","fieldName":"CARD / IVRS STATUS","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CARD / IVRS STATUS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"23","fieldName":"NO. OF JOINT ACCOUNT HOLDERS","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"NO. OF JOINT ACCOUNT HOLDERS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"24","fieldName":"CIF ID","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"CIF ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"25","fieldName":"ACCOUNT HOLDER TYPE","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"ACCOUNT HOLDER TYPE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"26","fieldName":"DEL / ADD / MOD FLAG","csvTxtLength":"50","fieldType":"String","delimiter":"|","defaultValue":"DEL / ADD / MOD FLAG","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"eol":true},{"sequence":14,"sectionName":"1","fieldName":"CIF","csvTxtLength":"50","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"2","fieldName":"BANK ID","csvTxtLength":"8","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"3","fieldName":"ATM CARD NUMBER","csvTxtLength":"19","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":17,"sectionName":"4","fieldName":"FROM ACCOUNT NO","csvTxtLength":"16","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":18,"sectionName":"5","fieldName":"OPERATION FLAG","csvTxtLength":"1","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"6","fieldName":"ACCOUNT NAME","csvTxtLength":"80","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"7","fieldName":"CARD TYPE","csvTxtLength":"5","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"8","fieldName":"CARD SUBTYPE","csvTxtLength":"5","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"9","fieldName":"CARD STATUS","csvTxtLength":"1","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"10","fieldName":"NO OF JOINT ACC HOLDERS","csvTxtLength":"2","fieldType":"Integer","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"11","fieldName":"CIF ID","csvTxtLength":"50","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"12","fieldName":"ACCOUNT HOLDER TYPE","csvTxtLength":"50","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"13","fieldName":"FLAG","csvTxtLength":"1","fieldType":"String","delimiter":"|","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"eol":true}]');
	i_TRAILER_FIELDS := TO_CLOB('[]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT 
	"CIF",
	"BANK ID",
	"ATM CARD NUMBER",
	"ROTATION_NUMBER",
	"INSTITUTION_ID",
	"FROM ACCOUNT NO",
	"OPERATION FLAG",
	"ACCOUNT NAME",
	"CARD TYPE",
	"CARD SUBTYPE",
	CASE WHEN "CARD STATUS" = ''Active'' THEN ''A''
	     WHEN "CARD STATUS" = ''Inactive'' THEN ''U''
         WHEN "CARD STATUS" = ''Stolen'' THEN ''S''
         WHEN "CARD STATUS" = ''Lost'' THEN ''L''
		 WHEN "CARD STATUS" = ''Blocked'' THEN ''B''
         WHEN "CARD STATUS" = ''Blocked-Exceeded PIN Tries'' THEN ''P''
         WHEN "CARD STATUS" = ''Replaced'' THEN ''R''
		 WHEN "CARD STATUS" = ''Closed'' THEN ''C''
		 WHEN "CARD STATUS" = ''Suspicious'' THEN ''F''
		 WHEN "CARD STATUS" = ''Closed due to Dormant'' THEN ''X''
		 WHEN "CARD STATUS" = ''Active but Idle'' THEN ''I''
		 WHEN "CARD STATUS" = ''Captured lost'' THEN ''E''
		 WHEN "CARD STATUS" = ''Damaged'' THEN ''D''
		 ELSE ''''
		END AS "CARD STATUS",
	"NO OF JOINT ACC HOLDERS",
    "JOINT ACC CIF",
	"JOINT ACCOUNT HOLDER TYPE",
	"JOINT ACC OPERATION FLAG"
FROM
(SELECT
	CLT.CLT_CIF_NUMBER AS "CIF",
	''{Iss_Name}'' AS "BANK ID",
	CRD.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
	CRD.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS "INSTITUTION_ID",
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	CASE WHEN DCR.DCR_REQUEST_TYPE = ''Manual'' THEN ''A'' ELSE ''M'' END AS "OPERATION FLAG",
	DCR.DCR_EMBOSSING_NAME AS "ACCOUNT NAME",
	''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
    STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
FROM
    {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} DCR 
    INNER JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} CRD ON CRD.CRD_ID = DCR.DCR_CRD_ID
	INNER JOIN {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT ON CLT.CLT_ID = DCR.DCR_CLT_ID
	INNER JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
	INNER JOIN {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS ON PRS.PRS_ID = DCR.DCR_PRS_ID
	INNER JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS_ID = CRD.CRD_STS_ID
	INNER JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON CRD.CRD_INS_ID = INS.INS_ID
WHERE 
	DCR.DCR_INS_ID = {Iss_Id} AND
	TRUNC(DCR.DCR_UPDATED_TS) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
SELECT
	CLT.CLT_CIF_NUMBER AS "CIF",
	''{Iss_Name}'' AS "BANK ID",
	CSH.CSH_CARD_NUMBER_ENC AS "ATM CARD NUMBER",
	CSH.CSH_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	CASE WHEN CCR.CCR_REQUEST_TYPE = ''Manual'' THEN ''A'' ELSE ''M'' END AS "OPERATION FLAG",
	CCR.CCR_EMBOSSING_NAME AS "ACCOUNT NAME",
	''CASH'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
FROM
    {DCMS_Schema}.ISSUANCE_CASH_CARD_REQUEST@{DB_LINK_DCMS} CCR
	INNER JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} CSH ON CSH.CSH_ID = CCR.CCR_CSH_ID
	INNER JOIN {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT ON CLT.CLT_ID = CCR.CCR_CLT_ID
	INNER JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
	INNER JOIN {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS ON PRS.PRS_ID = CCR.CCR_PRS_ID
	INNER JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS_ID = CSH.CSH_STS_ID
	INNER JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON CSH.CSH_INS_ID = INS.INS_ID
WHERE 
	CCR.CCR_INS_ID = {Iss_Id} AND
	TRUNC(CCR.CCR_UPDATED_TS) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
) TB
	WHERE TB."ROTATION_NUMBER" IS NOT NULL
ORDER BY
	TB.CIF, TB."ATM CARD NUMBER"		
	');	

	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Finacle 360';
	
END;
/