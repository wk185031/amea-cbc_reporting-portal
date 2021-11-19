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
	CASE WHEN "ROTATION_NUMBER" IS NULL THEN 1 ELSE "ROTATION_NUMBER" END "ROTATION_NUMBER",
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
	CASE WHEN CRD.CRD_KEY_ROTATION_NUMBER IS NOT NULL THEN CRD.CRD_KEY_ROTATION_NUMBER ELSE 1 END "ROTATION_NUMBER",
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
	LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
	LEFT JOIN {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS ON PRS.PRS_ID = DCR.DCR_PRS_ID
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
	CASE WHEN CSH.CSH_KEY_ROTATION_NUMBER IS NOT NULL THEN CSH.CSH_KEY_ROTATION_NUMBER ELSE 1 END "ROTATION_NUMBER",
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
	LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
	LEFT JOIN {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS ON PRS.PRS_ID = CCR.CCR_PRS_ID
	INNER JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS_ID = CSH.CSH_STS_ID
	INNER JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON CSH.CSH_INS_ID = INS.INS_ID
WHERE 
	CCR.CCR_INS_ID = {Iss_Id} AND
	TRUNC(CCR.CCR_UPDATED_TS) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
--Activated Pre-Gen
UNION ALL
	SELECT CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  CRD.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
  CASE WHEN CRD.CRD_KEY_ROTATION_NUMBER IS NOT NULL THEN CRD.CRD_KEY_ROTATION_NUMBER ELSE 1 END "ROTATION_NUMBER",
	INS.INS_CODE AS "INSTITUTION_ID",
  BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
 ''M'' AS "OPERATION FLAG",
  CRD.CRD_EMBOSSING_NAME AS "ACCOUNT NAME",
  ''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
    STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
 from {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} CRD
 left join {DCMS_Schema}.ISSUANCE_BULK_CARD_REQUEST@{DB_LINK_DCMS} on CRD_BCR_ID = BCR_NUMBER
 left join {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} ON CRD_ID = CCM_CRD_ID
 join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on CCM_CLT_ID = CLT_ID
 left join {DCMS_Schema}.MASTER_CORPORATE_CLIENT@{DB_LINK_DCMS} on CCL_ID = Crd_CCL_ID
 join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS on BCR_INS_ID = INS.INS_ID
 join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = BCR_BRN_ID
 left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = BCR_PRS_ID
 JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS_ID = CRD.CRD_STS_ID
 LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
where 
  BCR_INS_ID = {Iss_Id}
  AND BCR_STS_ID not in (67,69)
  AND TRUNC(BCR_UPDATED_TS) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
SELECT CLT.CLT_CIF_NUMBER AS "CIF",
	''{Iss_Name}'' AS "BANK ID",
	CSH.CSH_CARD_NUMBER_ENC AS "ATM CARD NUMBER",
	CASE WHEN CSH.CSH_KEY_ROTATION_NUMBER IS NOT NULL THEN CSH.CSH_KEY_ROTATION_NUMBER ELSE 1 END "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	CSH.CSH_EMBOSSING_NAME AS "ACCOUNT NAME",
	''CASH'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
    from {DCMS_Schema}.ISSUANCE_CASH_CARD @{DB_LINK_DCMS} CSH
	left join {DCMS_Schema}.ISSUANCE_BULK_CARD_REQUEST@{DB_LINK_DCMS} on CSH_BCR_ID = BCR_NUMBER
	left join {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} ON CSH_ID = CCM_CRD_ID
	left join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on CCM_CLT_ID = CLT.CLT_ID
	left join {DCMS_Schema}.MASTER_CORPORATE_CLIENT@{DB_LINK_DCMS} on CCL_ID = CSH_CCL_ID
	join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS on BCR_INS_ID = INS_ID
	join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = BCR_BRN_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS_ID = BCR_PRS_ID
    LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
  LEFT JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS_ID = CSH.CSH_STS_ID
  where 
  BCR_INS_ID = {Iss_Id}
  AND BCR_STS_ID not in (67,69)
  AND TRUNC(BCR_UPDATED_TS) BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
--CARD ACTIVATION
select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  Ic.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
	Ic.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	IC.CRD_EMBOSSING_NAME AS "ACCOUNT NAME",
	''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
From
	{DCMS_Schema}.Support_Card_Activation@{DB_LINK_DCMS} Sac
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sac.Caa_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS}  Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on Iccm.CCM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS}  Ms On Sac.Caa_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
    LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = IC.CRD_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = IC.CRD_STS_ID
	where Sac.Caa_Sts_Id IN (91) And Sac.Caa_Ins_Id = {Iss_Id}
	AND TO_DATE(Sac.CAA_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  ICC.CSH_CARD_NUMBER_ENC AS "ATM CARD NUMBER",
	ICC.CSH_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	ICC.CSH_EMBOSSING_NAME AS "ACCOUNT NAME",
	''CASH'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
  From
	{DCMS_Schema}.Support_CC_Activation@{DB_LINK_DCMS} Scca
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Scca.Cc_Caa_Cam_Id = ICCAM.CAM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on ICCAM.CAM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scca.Cc_Caa_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
    LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = ICC.CSH_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = ICC.CSH_STS_ID
	where  Scca.Cc_Caa_Sts_Id IN ( 91)
	And Scca.Cc_Caa_Ins_Id = {Iss_Id}
	AND TO_DATE(Scca.CC_CAA_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
	UNION ALL
--RESET PIN COUNTER
   select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  Ic.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
	Ic.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	IC.CRD_EMBOSSING_NAME AS "ACCOUNT NAME",
	''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
	from {DCMS_Schema}.Support_Reset_Pin_Counter@{DB_LINK_DCMS} Srp
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Srp.Rpc_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on Iccm.CCM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Srp.Rpc_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = IC.CRD_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = IC.CRD_STS_ID
	where STS.STS_ID IN ( 91) And Srp.Rpc_Ins_Id = {Iss_Id}
	AND TO_DATE(Srp.RPC_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
   select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  ICC.CSH_CARD_NUMBER_ENC AS "ATM CARD NUMBER",
	ICC.CSH_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	ICC.CSH_EMBOSSING_NAME AS "ACCOUNT NAME",
	''CASH'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
  From
	{DCMS_Schema}.Support_CC_Reset_Pin_Counter@{DB_LINK_DCMS}  Sccrp
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccrp.Cc_Rpc_Cam_Id = ICCAM.CAM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on ICCAM.CAM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccrp.Cc_Rpc_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
    LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = ICC.CSH_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = ICC.CSH_STS_ID
	where STS.STS_ID IN ( 91)
	And Sccrp.Cc_Rpc_Ins_Id = {Iss_Id}
	AND TO_DATE(Sccrp.CC_RPC_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
--HOTLIST
  select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  Ic.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
	Ic.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	IC.CRD_EMBOSSING_NAME AS "ACCOUNT NAME",
	''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
   from {DCMS_Schema}.Support_Hotlist@{DB_LINK_DCMS} Scch
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Scch.Hot_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on Iccm.CCM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scch.Hot_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = IC.CRD_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = IC.CRD_STS_ID
	where STS.STS_ID IN ( 91) And Scch.Hot_Ins_Id = {Iss_Id}
	AND TO_DATE(Scch.HOT_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
  select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  ICC.CSH_CARD_NUMBER_ENC AS "ATM CARD NUMBER",
	ICC.CSH_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	ICC.CSH_EMBOSSING_NAME AS "ACCOUNT NAME",
	''CASH'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
  From
	{DCMS_Schema}.Support_CC_Hotlist@{DB_LINK_DCMS} Scht
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Scht.CC_HOT_CAM_ID = ICCAM.CAM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on ICCAM.CAM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Scht.Cc_Hot_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
    LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = ICC.CSH_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = ICC.CSH_STS_ID
	where STS.STS_ID IN ( 91) And Scht.Cc_Hot_Ins_Id = {Iss_Id}
	AND TO_DATE(Scht.CC_HOT_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
--Dehotlist
  select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  Ic.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
	Ic.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	IC.CRD_EMBOSSING_NAME AS "ACCOUNT NAME",
	''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
	from {DCMS_Schema}.Support_Dehotlist@{DB_LINK_DCMS} Sdhl
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sdhl.Dhl_Ccm_Id = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on Iccm.CCM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sdhl.Dhl_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = IC.CRD_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = IC.CRD_STS_ID
	where STS.STS_ID IN (91) And Sdhl.Dhl_Ins_Id = {Iss_Id}
	AND TO_DATE(Sdhl.DHL_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
  select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  ICC.CSH_CARD_NUMBER_ENC AS "ATM CARD NUMBER",
	ICC.CSH_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	ICC.CSH_EMBOSSING_NAME AS "ACCOUNT NAME",
	''CASH'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
  From
	{DCMS_Schema}.Support_CC_Dehotlist@{DB_LINK_DCMS} Sccd
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccd.CC_DHL_CAM_ID = ICCAM.CAM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on ICCAM.CAM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccd.Cc_Dhl_Sts_Id=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
    LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = ICC.CSH_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = ICC.CSH_STS_ID
	where STS.STS_ID IN ( 91) And Sccd.Cc_Dhl_Ins_Id = {Iss_Id}
	AND TO_DATE(Sccd.CC_DHL_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
--Close card
  select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  Ic.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
	Ic.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	IC.CRD_EMBOSSING_NAME AS "ACCOUNT NAME",
	''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
	from {DCMS_Schema}.SUPPORT_CLOSE_CARD@{DB_LINK_DCMS} Sccard
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On Sccard.CCD_CCM_ID = Iccm.Ccm_Id
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on Iccm.CCM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccard.CCD_STS_ID=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = IC.CRD_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = IC.CRD_STS_ID
	where STS.STS_ID IN (74) And Sccard.ccd_Ins_Id = {Iss_Id}
	AND TO_DATE(Sccard.CCD_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
  select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  ICC.CSH_CARD_NUMBER_ENC AS "ATM CARD NUMBER",
	ICC.CSH_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	ICC.CSH_EMBOSSING_NAME AS "ACCOUNT NAME",
	''CASH'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
  From
	{DCMS_Schema}.SUPPORT_CC_CLOSE@{DB_LINK_DCMS} Sccclo
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD_ACC_MAPPING@{DB_LINK_DCMS} ICCAM On Sccclo.CC_CCD_CAM_ID = ICCAM.CAM_ID
	JOIN {DCMS_Schema}.ISSUANCE_CASH_CARD@{DB_LINK_DCMS} ICC ON ICCAM.CAM_CSH_ID = ICC.CSH_ID
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on ICCAM.CAM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On Sccclo.CC_CCD_STS_ID=Ms.Sts_Id
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON ICC.CSH_INS_ID = INS.INS_ID
   LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
   left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = ICC.CSH_PRS_ID
   JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = ICC.CSH_STS_ID
   where STS.STS_ID IN (74) And Sccclo.CC_CCD_INS_ID = {Iss_Id}
   AND TO_DATE(Sccclo.CC_CCD_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
  select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  Ic.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
	Ic.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	IC.CRD_EMBOSSING_NAME AS "ACCOUNT NAME",
	''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
	from {DCMS_Schema}.SUPPORT_ACCOUNT_DELINKING@{DB_LINK_DCMS} SALD
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On SALD.ADL_CCM_ID = ICCM.CCM_ID
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on Iccm.CCM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On SALD.ADL_STS_ID=MS.STS_ID
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = IC.CRD_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = IC.CRD_STS_ID
	where SALD.adl_Ins_Id = {Iss_Id}
	AND TO_DATE(SALD.ADL_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
UNION ALL
	select CLT.CLT_CIF_NUMBER AS "CIF",
  ''{Iss_Name}'' AS "BANK ID",
  Ic.CRD_NUMBER_ENC AS "ATM CARD NUMBER",
	Ic.CRD_KEY_ROTATION_NUMBER "ROTATION_NUMBER",
	INS.INS_CODE AS INSTITUTION_ID,
	BAC.BAC_ACCOUNT_NUMBER AS "FROM ACCOUNT NO",
	''M'' AS "OPERATION FLAG",
	IC.CRD_EMBOSSING_NAME AS "ACCOUNT NAME",
	''ATM'' AS "CARD TYPE",
	PRS.PRS_CODE AS "CARD SUBTYPE",
	STS.STS_NAME AS "CARD STATUS",
	'''' AS "NO OF JOINT ACC HOLDERS",
	'''' AS "JOINT ACC CIF",
	'''' AS "JOINT ACCOUNT HOLDER TYPE",
	'''' AS "JOINT ACC OPERATION FLAG"
	from {DCMS_Schema}.SUPPORT_ACCOUNT_LINKING@{DB_LINK_DCMS} SAL
	Join {DCMS_Schema}.Issuance_Client_Card_Mapping@{DB_LINK_DCMS} Iccm On SAL.ACL_CCM_ID = ICCM.CCM_ID
	Join {DCMS_Schema}.Issuance_Card@{DB_LINK_DCMS} Ic On Iccm.Ccm_Crd_Id = Ic.Crd_Id
	join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} CLT on Iccm.CCM_CLT_ID = CLT.CLT_ID
	Join {DCMS_Schema}.Master_Status@{DB_LINK_DCMS} Ms On SAL.ACL_STS_ID=MS.STS_ID
	JOIN {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} INS ON IC.CRD_INS_ID = INS.INS_ID
	LEFT JOIN {DCMS_Schema}.ISSUANCE_BANK_ACCOUNT@{DB_LINK_DCMS} BAC ON BAC.BAC_CLT_ID = CLT.CLT_ID
    left join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} PRS on PRS.PRS_ID = IC.CRD_PRS_ID
    JOIN {DCMS_Schema}.MASTER_STATUS@{DB_LINK_DCMS} STS ON STS.STS_ID = IC.CRD_STS_ID
	where SAL.ACL_INS_ID = {Iss_Id}
	AND TO_DATE(SAL.ACL_UPDATED_TS,''YYYY-MM-DD HH24:MI:SS'') BETWEEN TO_DATE({From_Date},''dd-MM-YY hh24:mi:ss'') AND TO_DATE({To_Date},''dd-MM-YY hh24:mi:ss'')
) TB
where TB."CIF" IS NOT NULL
ORDER BY
	TB.CIF, TB."ATM CARD NUMBER"');	

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