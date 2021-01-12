DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- Cash Card Balance
	i_BODY_QUERY := TO_CLOB('		
    SELECT
      BRC.BRC_CODE "BRANCH CODE",
      BRC.BRC_NAME "BRANCH NAME",
      CUST.CUST_NUMBER "CUSTOMER ID",
      CRD.CRD_CARDHOLDER_NAME "CUSTOMER NAME",
      CRD.CRD_PAN "ATM CARD NUMBER",
      CRD.CRD_PAN_EKY_ID,
      ACN.ACN_ACCOUNT_NUMBER "FROM ACCOUNT NO",
      ACN.ACN_ACCOUNT_NUMBER_EKY_ID,
      CPD.CPD_NAME "CARD PRODUCT",
      NVL(ACN.ACN_BALANCE_1,0) AS "BALANCE"
	FROM
	  CARD CRD
	  JOIN CARD_CUSTOM CRDCT ON CRD.CRD_ID = CRDCT.CRD_ID
	  JOIN CARD_PRODUCT CPD ON CRD.CRD_CPD_ID = CPD.CPD_ID
	  JOIN BRANCH BRC ON CRDCT.CRD_BRANCH_CODE = BRC.BRC_CODE
	  LEFT JOIN CUSTOMER CUST ON CRD.CRD_CUST_ID = CUST.CUST_ID
	  LEFT JOIN CARD_ACCOUNT CAT ON CRD.CRD_ID = CAT.CAT_CRD_ID
	  LEFT JOIN ACCOUNT ACN ON CAT.CAT_ACN_ID = ACN.ACN_ID           
	WHERE
	  CPD.CPD_CODE IN (''80'',''81'',''82'',''83'')
	  AND {Card_Product}
	  AND {Branch_Code}
	ORDER BY
	  CPD.CPD_NAME ASC,
	  CRDCT.CRD_BRANCH_CODE ASC,
	  CUST.CUST_NUMBER ASC	
	');

	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Cash Card Balance';

-- Cash Card Daily Transaction Summary
	i_HEADER_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"HEADER LINE 1","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CASH CARD","eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"HEADER LINE 2","pdfLength":"80","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"For the month of {current_month_year} - Per Branch / Bankwide","eol":true,"leftJustified":false,"padFieldLength":0}]');
	
	i_BODY_FIELD := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CHANNEL HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHANNEL","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL DEBIT HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DEBIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"TOTAL CREDIT HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL CREDIT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"7","fieldName":"BRANCH CODE","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":5,"sectionName":"8","fieldName":"BRANCH NAME","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":9,"sectionName":"9","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true,"group":true},{"sequence":6,"sectionName":"4","fieldName":"CHANNEL","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"5","fieldName":"TOTAL DEBIT","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"6","fieldName":"TOTAL CREDIT","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');
	
	i_BODY_QUERY := TO_CLOB('
	select 
  	  BRC.BRC_CODE "BRANCH CODE",
  	  BRC.BRC_NAME "BRANCH NAME",
  	  case when TXNC.TRL_IS_CORPORATE_CARD = 0 then ''CASH CARD RETAIL'' else ''CASH CARD CORPORATE'' end "TRANSACTION GROUP",
  	  TXNC.TRL_ORIGIN_CHANNEL "CHANNEL",
  	  sum(ACN.ACN_BALANCE_1) "BALANCE",
  	  TXNC.TRL_IS_CORPORATE_CARD "RETAIL_CORPORATE",
  	  sum(case when CTR.CTR_DEBIT_CREDIT = ''DEBIT'' then TXN.TRL_AMT_TXN else 0 end) "TOTAL DEBIT",
  	  sum(case when CTR.CTR_DEBIT_CREDIT = ''CREDIT'' then TXN.TRL_AMT_TXN else 0 end) "TOTAL CREDIT"
	from 
	  TRANSACTION_LOG txn 
	  left join CARD CRD on TXN.TRL_PAN=CRD.CRD_PAN 
	  left join TRANSACTION_LOG_CUSTOM TXNC on TXN.TRL_ID=TXNC.TRL_ID
	  left join BRANCH BRC on TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE 
	  left join CARD_ACCOUNT CAT on CRD.CRD_ID=CAT.CAT_CRD_ID 
	  left join ACCOUNT ACN on CAT.CAT_ACN_ID=ACN.ACN_ID 
	  left join CARD_PRODUCT CPD on CRD.CRD_CPD_ID=CPD.CPD_ID 
	  left join CBC_TRAN_CODE CTR on TXN.TRL_TSC_CODE=CTR.CTR_CODE and TXNC.TRL_ORIGIN_CHANNEL=CTR.CTR_CHANNEL 
	where 
  	  CPD.CPD_CODE in (''80'',''81'',''82'',''83'')
	group by 
  	  BRC.BRC_CODE, BRC.BRC_NAME,TXNC.TRL_ORIGIN_CHANNEL,TXNC.TRL_IS_CORPORATE_CARD
	order by BRC.BRC_CODE, BRC.BRC_NAME,TXNC.TRL_ORIGIN_CHANNEL
	');

	update REPORT_DEFINITION set red_header_fields=i_HEADER_FIELD where RED_NAME = 'Cash Card Daily Transaction Summary';
	update REPORT_DEFINITION set red_body_fields=i_BODY_FIELD where RED_NAME = 'Cash Card Daily Transaction Summary';
	update REPORT_DEFINITION set RED_BODY_QUERY = i_BODY_QUERY where RED_NAME = 'Cash Card Daily Transaction Summary';

END;
/