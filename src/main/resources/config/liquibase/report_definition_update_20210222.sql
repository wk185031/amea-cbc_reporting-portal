DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- Approved Rejected Card Records
i_BODY_QUERY := TO_CLOB('
SELECT
	''ACCOUNT DLINKING'' AS FUNCTIONNAME,
	SALD.ADL_CREATED_TS AS ISSUE_DATE,
	IC.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	IC.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	SALD.ADL_CREATED_BY AS MAKER,
	SALD.ADL_UPDATED_BY AS CHECKER,
	SALD.ADL_REMARKS AS REMARKS,
	IC.CRD_CARDHOLDER_NAME AS CLIENTNAME,
	MS.STS_NAME AS STATUS
FROM
	DCMSADM.SUPPORT_ACCOUNT_DELINKING@DCMSUAT SALD
	JOIN DCMSADM.ISSUANCE_CLIENT_CARD_MAPPING@DCMSUAT ICCM ON SALD.ADL_CCM_ID = ICCM.CCM_ID
	JOIN DCMSADM.ISSUANCE_CARD@DCMSUAT IC ON ICCM.CCM_CLT_ID = IC.CRD_ID
	JOIN DCMSADM.MASTER_STATUS@DCMSUAT MS ON SALD.ADL_STS_ID=MS.STS_ID
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	TO_DATE(Sald.Adl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between TO_DATE({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90)
	AND SALD.ADL_INS_ID = 1
UNION ALL
Select
	''Request For Add On Card'' As FUNCTIONNAME,
	Rac.Aoc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Rac.Aoc_Created_By As Maker,
	Rac.Aoc_Updated_By As Checker,
	Rac.Aoc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Add_On_Card@DCMSUAT Rac
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Rac.Aoc_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Rac.Aoc_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Rac.Aoc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Rac.Aoc_Ins_Id = 1
UNION ALL
Select
	''ACCOUNT LINKING'' As FUNCTIONNAME,
	Acl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sal.Acl_Created_By As Maker,
	Sal.Acl_Updated_By As Checker,
	Sal.Acl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Account_Linking@DCMSUAT Sal
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sal.Acl_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT  Ms On Sal.Acl_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sal.Acl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sal.Acl_Ins_Id = 1
Union All
Select
	''Card Activation''As Functionname,
	Sac.Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sac.Caa_Created_By As Maker,
	Sac.Caa_Updated_By As Checker,
	Sac.Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Card_Activation@DCMSUAT Sac
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sac.Caa_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT  Ms On Sac.Caa_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sac.Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'')  Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date},''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sac.Caa_Ins_Id = 1
UNION ALL
Select
	''CARD RENEWAL'' As Functionname,
	Scr.Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scr.Crn_Created_By As Maker,
	Scr.Crn_Updated_By As Checker,
	Scr.Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Card_Renewal@DCMSUAT Scr
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scr.Crn_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT  Ms On Scr.Crn_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scr.Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scr.Crn_Ins_Id = 1
Union All
Select
	''CASH CARD ACTIVATION'' Functionname,
	Scca.Cc_Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scca.Cc_Caa_Created_By As Maker,
	Scca.Cc_Caa_Updated_By As Checker,
	Scca.Cc_Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Activation@DCMSUAT Scca
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scca.Cc_Caa_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scca.Cc_Caa_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scca.Cc_Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scca.Cc_Caa_Ins_Id = 1
Union All
Select
	''CASH CARD RENEWAL'' Functionname,
	Sccr.Cc_Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC ,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sccr.Cc_Crn_Created_By As Maker,
	Sccr.Cc_Crn_Updated_By As Checker,
	Sccr.Cc_Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Renewal@DCMSUAT Sccr
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sccr.Cc_Crn_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sccr.Cc_Crn_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sccr.Cc_Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sccr.Cc_Crn_Ins_Id = 1
UNION ALL
Select
	''CASH DEHOTLIST'' Functionname,
	Sccd.Cc_Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sccd.Cc_Dhl_Created_By As Maker,
	Sccd.Cc_Dhl_Updated_By As Checker,
	Sccd.Cc_Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Dehotlist@DCMSUAT Sccd
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sccd.Cc_Dhl_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sccd.Cc_Dhl_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sccd.Cc_Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sccd.Cc_Dhl_Ins_Id = 1
Union All
Select
	''HOTLIST'' Functionname,
	Scch.Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scch.Hot_Created_By As Maker,
	Scch.Hot_Updated_By As Checker,
	Scch.Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Hotlist@DCMSUAT Scch
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scch.Hot_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scch.Hot_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scch.Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scch.Hot_Ins_id = 1
Union All
Select
	''CASH CARD RESET PIN'' Functionname,
	Sccrp.Cc_Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sccrp.Cc_Rpc_Created_By As Maker,
	Sccrp.Cc_Rpc_Updated_By As Checker,
	Sccrp.Cc_Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Reset_Pin_Counter@DCMSUAT Sccrp
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sccrp.Cc_Rpc_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sccrp.Cc_Rpc_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sccrp.Cc_Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sccrp.Cc_Rpc_Ins_id = 1
UNION ALL
Select
	''CASH CARD HOTLIST'' Functionname,
	Scht.Cc_Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scht.Cc_Hot_Created_By As Maker,
	Scht.Cc_Hot_Updated_By As Checker,
	Scht.Cc_Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Hotlist@DCMSUAT Scht
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scht.Cc_Hot_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scht.Cc_Hot_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scht.Cc_Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scht.Cc_Hot_Ins_Id = 1
Union All
Select
	''REPIN'' Functionname,
	Sdrp.Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sdrp.Rep_Created_By As Maker,
	Sdrp.Rep_Updated_By As Checker,
	Sdrp.Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Repin@DCMSUAT Sdrp
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sdrp.Rep_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sdrp.Rep_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sdrp.Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sdrp.Rep_Ins_Id = 1
UNION ALL
Select
	''RESET PIN COUNTER'' Functionname,
	Srp.Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Srp.Rpc_Created_By As Maker,
	Srp.Rpc_Updated_By As Checker,
	Srp.Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Reset_Pin_Counter@DCMSUAT Srp
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Srp.Rpc_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Srp.Rpc_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Srp.Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Srp.Rpc_Ins_Id = 1
UNION ALL
Select
	''STOP CARD RENEWAL'' Functionname,
	Scrn.SRN_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scrn.SRN_Created_By As Maker,
	Scrn.SRN_Updated_By As Checker,
	Scrn.SRN_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_STOP_RENEWAL@DCMSUAT Scrn
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scrn.SRN_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scrn.SRN_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scrn.SRN_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scrn.Srn_Ins_Id = 1
UNION ALL
Select
	''Default Account Change'' As Functionnamesal,
	DAR_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Dac.DAR_Created_By As Maker,
	Dac.DAR_Updated_By As Checker,
	Dac.DAR_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Default_Acc_Req_Map@DCMSUAT Dac
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Dac.DAR_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Dac.DAR_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Dac.DAR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Dac.Dar_Ins_Id = 1
UNION ALL
Select
	''Transaction Limit Update Cash card'' As FunctionName,
	Scctlu.CC_Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scctlu.CC_TRM_Created_By As Maker,
	Scctlu.CC_TRM_Updated_By As Checker,
	Scctlu.CC_TRM_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Txn_Limit_Req_Map@DCMSUAT Scctlu
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scctlu.CC_TRM_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scctlu.CC_TRM_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scctlu.CC_TRM_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scctlu.Cc_Trm_Ins_Id = 1
UNION ALL
Select
	''Reset pin Cash card'' As Functionname,
	Srp.Cc_Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Srp.Cc_Rep_Created_By As Maker,
	Srp.Cc_Rep_Updated_By As Checker,
	Srp.Cc_Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Repin@DCMSUAT Srp
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Srp.Cc_Rep_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Srp.Cc_Rep_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Srp.Cc_Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Srp.Cc_Rep_Ins_Id = 1
UNION ALL
Select
	''Address Update'' As Functionname,
	Sarm.Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sarm.Aur_Created_By As Maker,
	Sarm.Aur_Updated_By As Checker,
	Sarm.Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Address_Update_Req_Map@DCMSUAT Sarm
	Join DCMSADM.ISSUANCE_CARD@DCMSUAT IC ON Sarm.AUR_CLT_ID = IC.CRD_ID
	JOIN DCMSADM.MASTER_STATUS@DCMSUAT MS ON Sarm.AUR_STS_ID=MS.STS_ID
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
WHERE
	To_Date(Sarm.Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sarm.Aur_Ins_Id = 1
UNION ALL
Select
	''Cash Card Address Update'' As Functionname,
	Sarcm.Cc_Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sarcm.Cc_Aur_Created_By As Maker,
	Sarcm.Cc_Aur_Updated_By As Checker,
	Sarcm.Cc_Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Add_Update_Req_Map@DCMSUAT Sarcm
	Join DCMSADM.ISSUANCE_CARD@DCMSUAT IC ON Sarcm.CC_AUR_CLT_ID = IC.CRD_ID
	JOIN DCMSADM.MASTER_STATUS@DCMSUAT MS ON Sarcm.CC_Aur_STS_ID=MS.STS_ID
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
WHERE
	To_Date(Sarcm.CC_Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sarcm.Cc_Aur_Ins_Id = 1
UNION ALL
Select
	''Dehotlist'' As Functionname,
	Sdhl.Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sdhl.Dhl_Created_By As Maker,
	Sdhl.Dhl_Updated_By As Checker,
	Sdhl.Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Dehotlist@DCMSUAT Sdhl
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sdhl.Dhl_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sdhl.Dhl_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sdhl.Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sdhl.Dhl_Ins_Id = 1
UNION ALL
Select
	''Transaction Limit Update'' As FunctionName,
	Stlu.Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Stlu.Trm_Created_By As Maker,
	Stlu.Trm_Updated_By As Checker,
	Stlu.Trm_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Txn_Limit_Request_Map@DCMSUAT Stlu
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT  Iccm On Stlu.Trm_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Stlu.Trm_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Stlu.Trm_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Stlu.Trm_Ins_Id = 1

');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'Approved Rejected Card Records';

-- Pending Approval Card Records
i_BODY_QUERY := TO_CLOB('
SELECT
	''ACCOUNT DLINKING'' AS FUNCTIONNAME,
	SALD.ADL_CREATED_TS AS ISSUE_DATE,
	IC.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	IC.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	SALD.ADL_CREATED_BY AS MAKER,
	SALD.ADL_UPDATED_BY AS CHECKER,
	SALD.ADL_REMARKS AS REMARKS,
	IC.CRD_CARDHOLDER_NAME AS CLIENTNAME,
	MS.STS_NAME AS STATUS
FROM
	DCMSADM.SUPPORT_ACCOUNT_DELINKING@DCMSUAT SALD
	JOIN DCMSADM.ISSUANCE_CLIENT_CARD_MAPPING@DCMSUAT ICCM ON SALD.ADL_CCM_ID = ICCM.CCM_ID
	JOIN DCMSADM.ISSUANCE_CARD@DCMSUAT IC ON ICCM.CCM_CLT_ID = IC.CRD_ID
	JOIN DCMSADM.MASTER_STATUS@DCMSUAT MS ON SALD.ADL_STS_ID=MS.STS_ID
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	TO_DATE(Sald.Adl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between TO_DATE({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID = 89
	AND SALD.ADL_INS_ID = 1
UNION ALL
Select
	''Request For Add On Card'' As FUNCTIONNAME,
	Rac.Aoc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Rac.Aoc_Created_By As Maker,
	Rac.Aoc_Updated_By As Checker,
	Rac.Aoc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Add_On_Card@DCMSUAT Rac
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Rac.Aoc_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Rac.Aoc_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Rac.Aoc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Rac.Aoc_Ins_Id = 1
UNION ALL
Select
	''ACCOUNT LINKING'' As FUNCTIONNAME,
	Acl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sal.Acl_Created_By As Maker,
	Sal.Acl_Updated_By As Checker,
	Sal.Acl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Account_Linking@DCMSUAT Sal
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sal.Acl_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT  Ms On Sal.Acl_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sal.Acl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sal.Acl_Ins_Id = 1
Union All
Select
	''Card Activation''As Functionname,
	Sac.Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sac.Caa_Created_By As Maker,
	Sac.Caa_Updated_By As Checker,
	Sac.Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Card_Activation@DCMSUAT Sac
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sac.Caa_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT  Ms On Sac.Caa_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sac.Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'')  Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date},''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sac.Caa_Ins_Id = 1
UNION ALL
Select
	''CARD RENEWAL'' As Functionname,
	Scr.Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scr.Crn_Created_By As Maker,
	Scr.Crn_Updated_By As Checker,
	Scr.Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Card_Renewal@DCMSUAT Scr
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scr.Crn_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT  Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT  Ms On Scr.Crn_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scr.Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scr.Crn_Ins_Id = 1
Union All
Select
	''CASH CARD ACTIVATION'' Functionname,
	Scca.Cc_Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scca.Cc_Caa_Created_By As Maker,
	Scca.Cc_Caa_Updated_By As Checker,
	Scca.Cc_Caa_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Activation@DCMSUAT Scca
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scca.Cc_Caa_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scca.Cc_Caa_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scca.Cc_Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scca.Cc_Caa_Ins_Id = 1
Union All
Select
	''CASH CARD RENEWAL'' Functionname,
	Sccr.Cc_Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC ,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sccr.Cc_Crn_Created_By As Maker,
	Sccr.Cc_Crn_Updated_By As Checker,
	Sccr.Cc_Crn_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Renewal@DCMSUAT Sccr
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sccr.Cc_Crn_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sccr.Cc_Crn_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sccr.Cc_Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccr.Cc_Crn_Ins_Id = 1
UNION ALL
Select
	''CASH DEHOTLIST'' Functionname,
	Sccd.Cc_Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sccd.Cc_Dhl_Created_By As Maker,
	Sccd.Cc_Dhl_Updated_By As Checker,
	Sccd.Cc_Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Dehotlist@DCMSUAT Sccd
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sccd.Cc_Dhl_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sccd.Cc_Dhl_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sccd.Cc_Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccd.Cc_Dhl_Ins_Id = 1
Union All
Select
	''HOTLIST'' Functionname,
	Scch.Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scch.Hot_Created_By As Maker,
	Scch.Hot_Updated_By As Checker,
	Scch.Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Hotlist@DCMSUAT Scch
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scch.Hot_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scch.Hot_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scch.Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scch.Hot_Ins_id = 1
Union All
Select
	''CASH CARD RESET PIN'' Functionname,
	Sccrp.Cc_Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sccrp.Cc_Rpc_Created_By As Maker,
	Sccrp.Cc_Rpc_Updated_By As Checker,
	Sccrp.Cc_Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Reset_Pin_Counter@DCMSUAT Sccrp
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sccrp.Cc_Rpc_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sccrp.Cc_Rpc_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sccrp.Cc_Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sccrp.Cc_Rpc_Ins_id = 1
UNION ALL
Select
	''CASH CARD HOTLIST'' Functionname,
	Scht.Cc_Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scht.Cc_Hot_Created_By As Maker,
	Scht.Cc_Hot_Updated_By As Checker,
	Scht.Cc_Hot_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Hotlist@DCMSUAT Scht
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scht.Cc_Hot_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scht.Cc_Hot_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scht.Cc_Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scht.Cc_Hot_Ins_Id = 1
Union All
Select
	''REPIN'' Functionname,
	Sdrp.Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sdrp.Rep_Created_By As Maker,
	Sdrp.Rep_Updated_By As Checker,
	Sdrp.Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Repin@DCMSUAT Sdrp
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sdrp.Rep_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sdrp.Rep_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sdrp.Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sdrp.Rep_Ins_Id = 1
UNION ALL
Select
	''RESET PIN COUNTER'' Functionname,
	Srp.Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Srp.Rpc_Created_By As Maker,
	Srp.Rpc_Updated_By As Checker,
	Srp.Rpc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Reset_Pin_Counter@DCMSUAT Srp
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Srp.Rpc_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Srp.Rpc_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Srp.Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Srp.Rpc_Ins_Id = 1
UNION ALL
Select
	''STOP CARD RENEWAL'' Functionname,
	Scrn.SRN_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scrn.SRN_Created_By As Maker,
	Scrn.SRN_Updated_By As Checker,
	Scrn.SRN_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_STOP_RENEWAL@DCMSUAT Scrn
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scrn.SRN_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scrn.SRN_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scrn.SRN_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scrn.Srn_Ins_Id = 1
UNION ALL
Select
	''Default Account Change'' As Functionnamesal,
	DAR_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Dac.DAR_Created_By As Maker,
	Dac.DAR_Updated_By As Checker,
	Dac.DAR_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Default_Acc_Req_Map@DCMSUAT Dac
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Dac.DAR_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Dac.DAR_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Dac.DAR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Dac.Dar_Ins_Id = 1
UNION ALL
Select
	''Transaction Limit Update Cash card'' As FunctionName,
	Scctlu.CC_Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Scctlu.CC_TRM_Created_By As Maker,
	Scctlu.CC_TRM_Updated_By As Checker,
	Scctlu.CC_TRM_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Txn_Limit_Req_Map@DCMSUAT Scctlu
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Scctlu.CC_TRM_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Scctlu.CC_TRM_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Scctlu.CC_TRM_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Scctlu.Cc_Trm_Ins_Id = 1
UNION ALL
Select
	''Reset pin Cash card'' As Functionname,
	Srp.Cc_Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Srp.Cc_Rep_Created_By As Maker,
	Srp.Cc_Rep_Updated_By As Checker,
	Srp.Cc_Rep_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Repin@DCMSUAT Srp
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Srp.Cc_Rep_Cam_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Srp.Cc_Rep_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Srp.Cc_Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Srp.Cc_Rep_Ins_Id = 1
UNION ALL
Select
	''Address Update'' As Functionname,
	Sarm.Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sarm.Aur_Created_By As Maker,
	Sarm.Aur_Updated_By As Checker,
	Sarm.Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Address_Update_Req_Map@DCMSUAT Sarm
	Join DCMSADM.ISSUANCE_CARD@DCMSUAT IC ON Sarm.AUR_CLT_ID = IC.CRD_ID
	JOIN DCMSADM.MASTER_STATUS@DCMSUAT MS ON Sarm.AUR_STS_ID=MS.STS_ID
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
WHERE
	To_Date(Sarm.Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sarm.Aur_Ins_Id = 1
UNION ALL
Select
	''Cash Card Address Update'' As Functionname,
	Sarcm.Cc_Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sarcm.Cc_Aur_Created_By As Maker,
	Sarcm.Cc_Aur_Updated_By As Checker,
	Sarcm.Cc_Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Add_Update_Req_Map@DCMSUAT Sarcm
	Join DCMSADM.ISSUANCE_CARD@DCMSUAT IC ON Sarcm.CC_AUR_CLT_ID = IC.CRD_ID
	JOIN DCMSADM.MASTER_STATUS@DCMSUAT MS ON Sarcm.CC_Aur_STS_ID=MS.STS_ID
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
WHERE
	To_Date(Sarcm.CC_Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sarcm.Cc_Aur_Ins_Id = 1
UNION ALL
Select
	''Dehotlist'' As Functionname,
	Sdhl.Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Sdhl.Dhl_Created_By As Maker,
	Sdhl.Dhl_Updated_By As Checker,
	Sdhl.Dhl_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Dehotlist@DCMSUAT Sdhl
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT Iccm On Sdhl.Dhl_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Sdhl.Dhl_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Sdhl.Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Sdhl.Dhl_Ins_Id = 1
UNION ALL
Select
	''Transaction Limit Update'' As FunctionName,
	Stlu.Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	INS.INS_CODE AS INSTITUTION_ID,
	Ic.CRD_KEY_ROTATION_NUMBER ROTATION_NUMBER,
	Stlu.Trm_Created_By As Maker,
	Stlu.Trm_Updated_By As Checker,
	Stlu.Trm_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Txn_Limit_Request_Map@DCMSUAT Stlu
	Join DCMSADM.Issuance_Client_Card_Mapping@DCMSUAT  Iccm On Stlu.Trm_Ccm_Id = Iccm.Ccm_Id
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Iccm.Ccm_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Stlu.Trm_Sts_Id=Ms.Sts_Id
	JOIN DCMSADM.MASTER_INSTITUTIONS@DCMSUAT INS ON IC.CRD_INS_ID = INS.INS_ID
Where
	To_Date(Stlu.Trm_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id = 89
	And Stlu.Trm_Ins_Id = 1
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'Pending Approval Card Records';



END;
/