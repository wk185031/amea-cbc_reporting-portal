-- Tracking				Date			Name	Description
-- Revised Report		06-JULY-2021	WY		Revised reports based on spec
-- Report revision		23-JUL-2021		NY		Update based on excel spec
-- Issuer				06-AUG-2021		NY		Use left join consistently to avoid data mismatch to master
-- Issuer				13-AUG-2021		NY		Remove mcc id 6011 check to match EFDLY006/EFDLY002/CASA (issuer)/TRAN, refer 854
-- Issuer				19-AUG-2021		NY		Exclude inter-entity per recent specification confirmation

DECLARE
    i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 
	
	i_BODY_QUERY := TO_CLOB('
	SELECT
      "BANK CODE",
      "BANK NAME",
      COUNT("NET COUNT") "NET COUNT",
      SUM("SumOfTxn") -  SUM("SumOfRev") "NET SETTLEMENT"
FROM (
SELECT
      SUBSTR(LPAD(TRL_ACQR_INST_ID, 10, ''0''), 7) "BANK CODE",
      CBA.CBA_NAME "BANK NAME",
      TXN.TRL_ID "NET COUNT",
      CASE WHEN TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "SumOfTxn",
	  CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "SumOfRev"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      LEFT JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0        	
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id}) 
	  AND (TXN.TRL_DEO_NAME != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id})   
      AND {Txn_Date}
	)
GROUP BY
      "BANK CODE",
      "BANK NAME"
ORDER BY
      "BANK CODE" ASC');
	  
	  i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT("ITEM") "NET COUNT",
      SUM("SumOfTxn") -  SUM("SumOfRev") "NET SETTLEMENT"
FROM(
	SELECT CASE WHEN TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0 THEN TXN.TRL_AMT_TXN ELSE 0 END AS "SumOfTxn",
	  CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN TXN.TRL_AMT_TXN ELSE 0 END AS "SumOfRev",
	  TXN.TRL_ID AS "ITEM"
FROM
      TRANSACTION_LOG TXN
      LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      LEFT JOIN CBC_BANK CBA ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA.CBA_CODE, 10, ''0'')
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0      	
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND TXN.TRL_ISS_NAME = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND (TXN.TRL_DEO_NAME != {V_IE_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_IE_Acqr_Inst_Id})
      AND {Txn_Date})');
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'ATM Withdrawal as Issuer Bank Summary';
	
END;
/