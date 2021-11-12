-- Tracking					Date			Name	Description
-- Rel-20210805				05-Aug-2021		KW		Revise report based on specification

DECLARE
    i_REPORT_NAME VARCHAR2(100) := 'Cash Card Daily Transaction Summary';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 	 

	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"HEADER LINE 1","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CASH CARD","eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"HEADER LINE 2","pdfLength":"80","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"For the month of {current_month_year} - Per Branch / Bankwide","eol":true,"leftJustified":false,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CHANNEL HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHANNEL","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL DEBIT HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DEBIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"TOTAL CREDIT HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL CREDIT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"7","fieldName":"BRANCH CODE","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":5,"sectionName":"8","fieldName":"BRANCH NAME","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":9,"sectionName":"9","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true,"group":true},{"sequence":6,"sectionName":"4","fieldName":"CHANNEL","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"5","fieldName":"TOTAL DEBIT","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"6","fieldName":"TOTAL CREDIT","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');
 	i_TRAILER_FIELDS_CBC := null;
 	
 	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"HEADER LINE 1","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS CASH CARD","eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"HEADER LINE 2","pdfLength":"80","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"For the month of {current_month_year} - Per Branch / Bankwide","eol":true,"leftJustified":false,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CHANNEL HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHANNEL","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL DEBIT HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL DEBIT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"TOTAL CREDIT HEADER","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL CREDIT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"7","fieldName":"BRANCH CODE","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":5,"sectionName":"8","fieldName":"BRANCH NAME","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"group":true},{"sequence":9,"sectionName":"9","fieldName":"TRANSACTION GROUP","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true,"group":true},{"sequence":6,"sectionName":"4","fieldName":"CHANNEL","pdfLength":"30","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"5","fieldName":"TOTAL DEBIT","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"6","fieldName":"TOTAL CREDIT","pdfLength":"30","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');
 	i_TRAILER_FIELDS_CBS := null;
 	    

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
	  CPD.CPD_CODE in (''80'', ''81'', ''82'', ''83'')
      AND (TXN.TRL_TQU_ID = ''F'' OR (TXN.TRL_TQU_ID = ''A'' AND TXNC.TRL_ORIGIN_CHANNEL=''OTC''))  
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
	  AND TXN.TRL_SYSTEM_TIMESTAMP < {Txn_End_Date}
	group by 
  	  BRC.BRC_CODE, BRC.BRC_NAME,TXNC.TRL_ORIGIN_CHANNEL,TXNC.TRL_IS_CORPORATE_CARD
	order by BRC.BRC_CODE, BRC.BRC_NAME,"TRANSACTION GROUP" desc,TXNC.TRL_ORIGIN_CHANNEL
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