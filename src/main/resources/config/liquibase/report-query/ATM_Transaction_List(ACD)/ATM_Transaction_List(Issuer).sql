-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-688	29-JUN-2021		WY		Initial config from UAT environment
-- CBCAXUPISSLOG-688	30-JUN-2021		NY		Update query following excel spec
-- CBCAXUPISSLOG-688	01-JUL-2021		NY		Remove filter by BNT channel, to catch inter-entity accordingly
-- CBCAXUPISSLOG-527 	05-JUL-2021		GS		Modify Trace No pad length to 6 digits
-- CBCAXUPISSLOG-690	05-JUL-2021		NY		Populate 'to account type' with biller mnem if it is bill payment, network provider codes mnem if it is FT
-- CBCAXUPISSLOG-762	05-JUL-2021		NY		Bank Code Column in EFDLY002 must display the bank mnemonic of the issuing card
-- CBCAXUPISSLOG-762	05-JUL-2021		NY		Correct issuing bank mnem
-- CBCAXUPISSLOG-546	07-JUL-2021		NY		Correct tran mnem for IBFT withdrawal BTD/BTR
-- CBCAXUPISSLOG-762	13-JUL-2021		NY		Use issuing bank code, instead of bank mnem
-- CBCAXUPISSLOG-803	14-JUL-2021  	NY		Issuer credit transaction for other bank card at other bank atm should not include in master list
-- Master report		30-JUL-2021		NY		Work on various jira related to master report
-- Master report		01-AUG-2021		NY		Fix eload withdrawal not populate BPR/BRP, transaction code 44 is retrieved instead of from BN 01/41 only for IBFT
-- Master report		02-AUG-2021		NY		Fix Bill Payment wrong mnem/count, along with empty mnem in master reports
-- Master report		02-AUG-2021		NY		Use left join to cbc_bin/cbc_bank so that we still pull data with no bin
-- Master report		06-AUG-2021		NY		Various fix from cross checking finding and jira related issues
-- Master report		13-AUG-2021		NY		Left join to transaction_log_custom give unexpected result, revert to use join
-- Master report		20-AUG-2021		NY		Include back txn code 2, 22
-- CBCAXUPISSLOG-637	25-AUG-2021		NY		Exclude rejected reversal
-- Master report		31-AUG-2021		NY		Internal finding, wrong txn code
-- CBCAXUPISSLOG-550	14-SEP-2021		NY		Fix redundant ACI/ADI for txn code 40, BTC should not contain CBS as receiving bank
-- CBCAXUPISSLOG-937	26-OCT-2021		NY		Revert the 937 changes

DECLARE
	i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- ATM Transaction List (Issuer)

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"130","pdfLength":"130","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"REPORT ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"REPORT ID : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"EFP001-02","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"EFP001-02","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Type","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"File Type : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TXT","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"TXT","fieldFormat":"","delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"15","fieldName":"EMPTY","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"16","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"17","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"18","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"19","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"20","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"21","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"22","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"23","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"24","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"6","fieldName":"File Type","csvTxtLength":"131","pdfLength":"131","fieldType":"String","defaultValue":"Acquired International Transactions Log (Issuer)","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"7","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"8","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","defaultValue":"","eol":false,"delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"9","fieldName":"RunTime","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"RUNTIME : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"10","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm","csvTxtLength":"10","pdfLength":"10","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"11","fieldName":"TRAN DATE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","firstField":true,"delimiter":";","fieldFormat":"","defaultValue":"TRAN DATE : ","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"120","pdfLength":"120","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"13","fieldName":"Frequency","csvTxtLength":"11","pdfLength":"11","fieldType":"String","fieldFormat":"","delimiter":";","defaultValue":"Frequency : ","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"14","fieldName":"Daily","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"Daily","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ATM Code","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"ATM Code","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Bank Mnem","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"Bank Mnem","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"ATM Card No","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Bank Code","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Code","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"From Acct Type","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"From Acct Type","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"From Acct No","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"From Acct No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"To Acct Type","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"To Acct Type","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"To Acc No","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"To Acc No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"Amount","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Amount","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"Reply Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"Reply Code","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"Comment","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"Comment","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" ","bodyHeader":true,"eol":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"ATM CODE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"32","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":33,"sectionName":"33","fieldName":"BANK CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"FROM ACC TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":39,"sectionName":"39","fieldName":"TO ACC TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":41,"sectionName":"41","fieldName":"AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":43,"sectionName":"43","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[]');

-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"130","pdfLength":"130","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"REPORT ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"REPORT ID : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"EFP001-02","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"EFP001-02","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Type","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"File Type : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TXT","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"TXT","fieldFormat":"","delimiter":";","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"15","fieldName":"EMPTY","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"16","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"17","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"18","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"19","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"20","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"21","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"22","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"23","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"24","fieldName":"EMPTY","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"6","fieldName":"File Type","csvTxtLength":"131","pdfLength":"131","fieldType":"String","defaultValue":"Acquired International Transactions Log (Issuer)","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"7","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"8","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","defaultValue":"","eol":false,"delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"9","fieldName":"RunTime","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"RUNTIME : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"10","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm","csvTxtLength":"10","pdfLength":"10","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":21,"sectionName":"11","fieldName":"TRAN DATE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","firstField":true,"delimiter":";","fieldFormat":"","defaultValue":"TRAN DATE : ","leftJustified":true,"padFieldLength":0},{"sequence":22,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"120","pdfLength":"120","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":23,"sectionName":"13","fieldName":"Frequency","csvTxtLength":"11","pdfLength":"11","fieldType":"String","fieldFormat":"","delimiter":";","defaultValue":"Frequency : ","leftJustified":true,"padFieldLength":0},{"sequence":24,"sectionName":"14","fieldName":"Daily","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"Daily","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"ATM Code","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"ATM Code","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Bank Mnem","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","defaultValue":"Bank Mnem","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Seq No","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"Trace No","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"ATM Card No","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Bank Code","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Bank Code","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"From Acct Type","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"From Acct Type","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"From Acct No","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"From Acct No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"To Acct Type","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"To Acct Type","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"To Acc No","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"To Acc No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"Amount","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Amount","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"Reply Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"Reply Code","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"Comment","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"Comment","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" ","bodyHeader":true,"eol":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"ATM CODE","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":29,"sectionName":"29","fieldName":"BANK MNEM","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":30,"sectionName":"30","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":32,"sectionName":"32","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":33,"sectionName":"33","fieldName":"BANK CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":37,"sectionName":"37","fieldName":"FROM ACC TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":39,"sectionName":"39","fieldName":"TO ACC TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":41,"sectionName":"41","fieldName":"AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":42,"sectionName":"42","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":43,"sectionName":"43","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT * FROM(
-- Issuer (exclude Transfer)
SELECT
      DISTINCT TXN.TRL_TQU_ID "TXN QUALIFIER",
      CBA_ACQ.CBA_NAME "BANK NAME ACQ",
      CONCAT(LPAD(CBA_ACQ.CBA_CODE, 4, ''0''),  TXN.TRL_CARD_ACPT_TERMINAL_IDENT) "ATM CODE",
      CBA_ACQ.CBA_MNEM "BANK MNEM",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      LPAD(CBA_ACQ.CBA_CODE, 4, ''0'') "BANK CODE ACQ",
      CBA.CBA_MNEM "BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_SYSTEM_TIMESTAMP "TIMESTAMP",
      CASE 
		WHEN TXN.TRL_TSC_CODE = 90 THEN ''PIN''
		WHEN TXN.TRL_TSC_CODE = 126 THEN ''EAA'' 
		WHEN TXN.TRL_TSC_CODE = 127 THEN ''MAA'' 
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''R'' AND CTRI.CTR_REV_MNEM IS NOT NULL THEN CTRI.CTR_REV_MNEM 
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''F'' AND CTRI.CTR_MNEM IS NOT NULL THEN CTRI.CTR_MNEM  
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE 
        WHEN TXN.TRL_TSC_CODE IN (50, 250) THEN CBL.CBL_MNEM
        WHEN TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882'' THEN CBA_REV.CBA_MNEM
		WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 10 THEN ''SA'' 
		WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 20 THEN ''CA'' 
		ELSE '''' END AS "TO ACC TYPE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''BNT''
	  LEFT JOIN CBC_TRAN_CODE CTRI ON TXN.TRL_TSC_CODE = CTRI.CTR_CODE AND CTRI.CTR_CHANNEL = (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''I-CDM'' ELSE ''I-'' || TXNC.TRL_ORIGIN_CHANNEL END)
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN CBC_BILLER CBL ON CBL.CBL_ID = (SELECT MIN(CBL_ID) FROM CBC_BILLER WHERE CBL_CODE = TXNC.TRL_BILLER_CODE)
      LEFT JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_ACQ.CBA_CODE, 10, ''0'')
      LEFT JOIN CBC_BANK CBA_REV ON LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_REV.CBA_CODE, 10, ''0'')
	WHERE
	  (TXN.TRL_TQU_ID IN (''F'', ''C'') OR (TXN.TRL_TQU_ID IN (''A'') AND TXN.TRL_TSC_CODE IN (90,126,127)) OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_FRD_REV_INST_ID IS NULL 
	  AND TXN.TRL_TSC_CODE NOT IN (2, 22)
      AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != ''12345''
      AND COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '''') = {V_Iss_Name}
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND {Bank_Code}
      AND {Txn_Date}
UNION ALL
-- Issuer Transfer (debit)
SELECT DISTINCT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      CBA_ACQ.CBA_NAME "BANK NAME ACQ",
      CONCAT(LPAD(CBA_ACQ.CBA_CODE, 4, ''0''),  TXN.TRL_CARD_ACPT_TERMINAL_IDENT) "ATM CODE",
      CBA_ACQ.CBA_MNEM "BANK MNEM",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      LPAD(CBA_ACQ.CBA_CODE, 4, ''0'') "BANK CODE ACQ",
      CBA.CBA_MNEM "BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_SYSTEM_TIMESTAMP "TIMESTAMP",
      CASE
		WHEN TXN.TRL_TSC_CODE = 90 THEN ''PIN''
		WHEN TXN.TRL_TSC_CODE = 126 THEN ''EAA'' 
		WHEN TXN.TRL_TSC_CODE = 127 THEN ''MAA'' 
        WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''R'' AND CTRI.CTR_REV_MNEM IS NOT NULL THEN CTRI.CTR_REV_MNEM 
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''F'' AND CTRI.CTR_MNEM IS NOT NULL THEN CTRI.CTR_MNEM 
		WHEN TXN.TRL_TQU_ID = ''R'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = ''0000008882'' AND TXN.TRL_TSC_CODE = 1 THEN ''BRP''
        WHEN TXN.TRL_TQU_ID = ''F'' AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = ''0000008882'' AND TXN.TRL_TSC_CODE = 1 THEN ''BPR'' 
        WHEN TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_TSC_CODE = 1 THEN ''BTR''
        WHEN TXN.TRL_TQU_ID = ''F'' AND TXN.TRL_TSC_CODE = 1 THEN ''BTD''
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE 
        WHEN TXN.TRL_TSC_CODE IN (50, 250) THEN CBL.CBL_MNEM
        WHEN TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882'' THEN CBA_REV.CBA_MNEM
		WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 10 THEN ''SA'' 
		WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 20 THEN ''CA'' 
		ELSE '''' END AS "TO ACC TYPE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''BNT'' AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      LEFT JOIN CBC_TRAN_CODE CTRI ON TXN.TRL_TSC_CODE = CTRI.CTR_CODE AND CTRI.CTR_CHANNEL = (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''I-CDM'' ELSE ''I-'' || TXNC.TRL_ORIGIN_CHANNEL END)
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN CBC_BILLER CBL ON CBL.CBL_ID = (SELECT MIN(CBL_ID) FROM CBC_BILLER WHERE CBL_CODE = TXNC.TRL_BILLER_CODE)
      LEFT JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_ACQ.CBA_CODE, 10, ''0'')
      LEFT JOIN CBC_BANK CBA_REV ON LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_REV.CBA_CODE, 10, ''0'')
	WHERE
	  (TXN.TRL_TQU_ID IN (''F'', ''C'') OR (TXN.TRL_TQU_ID IN (''A'') AND TXN.TRL_TSC_CODE IN (90,126,127)) OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_TSC_CODE NOT IN (44, 52)
      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL 
      AND (CTR.CTR_DEBIT_CREDIT = ''DEBIT'' or CTRI.CTR_DEBIT_CREDIT = ''DEBIT'')
      AND COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '''') = {V_Iss_Name} 
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND {Bank_Code}
      AND {Txn_Date}
UNION ALL
-- Issuer Transfer (credit)
SELECT DISTINCT
      TXN.TRL_TQU_ID "TXN QUALIFIER",
      CBA_ACQ.CBA_NAME "BANK NAME ACQ",
      CONCAT(LPAD(CBA_ACQ.CBA_CODE, 4, ''0''),  TXN.TRL_CARD_ACPT_TERMINAL_IDENT) "ATM CODE",
      CBA_ACQ.CBA_MNEM "BANK MNEM",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      LPAD(CBA_ACQ.CBA_CODE, 4, ''0'') "BANK CODE ACQ",
      CBA.CBA_MNEM "BANK CODE",
      TXN.TRL_SYSTEM_TIMESTAMP "DATE",
      TXN.TRL_SYSTEM_TIMESTAMP "TIME",
      TXN.TRL_SYSTEM_TIMESTAMP "TIMESTAMP",
      CASE 
		WHEN TXN.TRL_TSC_CODE = 90 THEN ''PIN''
		WHEN TXN.TRL_TSC_CODE = 126 THEN ''EAA'' 
		WHEN TXN.TRL_TSC_CODE = 127 THEN ''MAA'' 
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''R'' AND CTRI.CTR_REV_MNEM IS NOT NULL THEN CTRI.CTR_REV_MNEM 
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''F'' AND CTRI.CTR_MNEM IS NOT NULL THEN CTRI.CTR_MNEM 
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE 
        WHEN TXN.TRL_TSC_CODE IN (50, 250) THEN CBL.CBL_MNEM
        WHEN TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') != ''0000008882'' THEN CBA_REV.CBA_MNEM
		WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 10 THEN ''SA'' 
		WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 20 THEN ''CA'' 
		ELSE '''' END AS "TO ACC TYPE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = ''BNT'' AND CTR.CTR_DEBIT_CREDIT = ''CREDIT''
      LEFT JOIN CBC_TRAN_CODE CTRI ON TXN.TRL_TSC_CODE = CTRI.CTR_CODE AND CTRI.CTR_CHANNEL = (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''I-CDM'' ELSE ''I-'' || TXNC.TRL_ORIGIN_CHANNEL END)
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN CBC_BILLER CBL ON CBL.CBL_ID = (SELECT MIN(CBL_ID) FROM CBC_BILLER WHERE CBL_CODE = TXNC.TRL_BILLER_CODE)
      LEFT JOIN CBC_BANK CBA_ACQ ON LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_ACQ.CBA_CODE, 10, ''0'')
      LEFT JOIN CBC_BANK CBA_REV ON LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_REV.CBA_CODE, 10, ''0'')
	WHERE
	  (TXN.TRL_TQU_ID IN (''F'', ''C'') OR (TXN.TRL_TQU_ID IN (''A'') AND TXN.TRL_TSC_CODE IN (90,126,127)) OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_TSC_CODE NOT IN (44, 52)
      AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL 
      AND (CTR.CTR_DEBIT_CREDIT = ''CREDIT'' or CTRI.CTR_DEBIT_CREDIT = ''CREDIT'')
      AND COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '''') = {V_Iss_Name} 
      AND (TXN.TRL_DEO_NAME != {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') != {V_Acqr_Inst_Id})
      AND CBA.CBA_MNEM = {V_Iss_Name}
      AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Recv_Inst_Id}
      AND {Bank_Code}
      AND {Txn_Date}
	)
	ORDER BY
      "BANK NAME ACQ" ASC,
      "TIMESTAMP" ASC,
      "SEQ NUMBER" ASC,
      "TRACE NUMBER" ASC
	');	
	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM Transaction List (Issuer)' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM Transaction List (Issuer)' AND RED_INS_ID = 2;
	
END;
/