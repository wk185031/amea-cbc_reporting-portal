-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-688	29-JUN-2021		WY		Initial config from UAT environment
-- CBCAXUPISSLOG-688	30-JUN-2021		NY		Update query following excel spec
-- CBCAXUPISSLOG-688	01-JUL-2021		NY		Fix redundant row and catch inter-entity in acquiring
-- CBCAXUPISSLOG-758	02-JUL-2021		NY		Fix wrong header/body fields
-- CBCAXUPISSLOG-688	05-JUL-2021		NY		Fix recycler txn not showing on verification
-- CBCAXUPISSLOG-690	05-JUL-2021		NY		Populate 'to account type' with biller mnem if it is bill payment, network provider codes mnem if it is FT
-- CBCAXUPISSLOG-766	07-JUL-2021		NY		Exclude IBFT/Eload request ie 44/52 from acquirer/onus report, include IBFT withdrawal 01
-- CBCAXUPISSLOG-546	07-JUL-2021		NY		Correct tran mnem for IBFT withdrawal BTD/BTR
-- CBCAXUPISSLOG-766	10-JUL-2021		NY		Fix fund transfer has duplicate entries ie AXD/AXC AID/AIC
-- CBCAXUPISSLOG-766	12-JUL-2021		NY		Fix missing acquirer txn in report
-- CBCAXUPISSLOG-766	14-JUL-2021		NY 		Fix 44 tran code mnem not printed
-- CBCAXUPISSLOG-773	27-JUL-2021		NY		Get onus cheque book amount from TRL_ISS_CHARGE_AMT
-- Master report		30-JUL-2021		NY		Work on various jira related to master report
-- Master report		31-JUL-2021		NY		Fix RFID records print individual report not in master reports
-- Master report		02-AUG-2021		NY		Fix Bill Payment wrong mnem/count, along with empty mnem in master reports
-- Master report		02-AUG-2021		NY		Use left join to cbc_bin/cbc_bank so that we still pull data with no bin
-- Master report		06-AUG-2021		NY		Various fix from cross checking finding and jira related issues
-- Master report		10-AUG-2021		NY		Cater cash card fund transfer debit leg from EBK/MBK
-- Master report		13-AUG-2021		NY		Include null cbc_bin records, onus/acq ibft/eload to use 44/52 instead of 01 for catching the debit leg
-- Master report		15-AUG-2021		NY		Fix acquiring prepaid reload printing APR, instead of BPR
-- Master report		17-AUG-2021		NY		Fix wrong RFID decline count
-- CBCAXUPISSLOG-885	20-AUG-2021		NY		Use bank mnem instead of code in "Iss Bank Code" column	
-- Master report		20-AUG-2021		NY		Include back txn code 2, 22
-- Master report 		22-AUG-2021		NY		Fix cross checking to cash card transactions
-- Master report		23-AUG-2021		NY		Cater credit leg for txn code 44 and 48
-- Master report		24-AUG-2021		NY		Fix missing txn code 43
-- CBCAXUPISSLOG-769	25-AUG-2021		NY		Differentiate MAA/EAA for txn code 126
-- CBCAXUPISSLOG-637	25-AUG-2021		NY		Exclude failed reversal
-- CBCAXUPISSLOG-769	27-AUG-2021		NY		Join atm_txn_activity log to trl_ext_id instead of trl_id
-- CBCAXUPISSLOG-688	27-AUG-2021		NY		Txn 44 from BRM to populate CTD instead of BTD
-- CBCAXUPISSLOG-860	30-AUG-2021		NY		Fix IE txn populate as BBL instead of AIL for beep reload
-- CBCAXUPISSLOG-550	14-SEP-2021		NY		Fix AWI/AWR populate for other bank card as well instead of only IE
-- CBCAXUPISSLOG-688	17-SEP-2021		NY		Fix acq debit transfer not using bancnet mnem
-- CBCAXUPISSLOG-769	20-SEP-2021		NY 		MBK activation to use tsc code 127 from recent ATM fix, segregate accordingly from 126
-- CBCAXUPISSLOG-929	21-SEP-2021		NY		Fix eload acq not appear 
-- CBCAXUPISSLOG-688	11-OCT-2021		NY		Fix missing BRM inter-entity txn code 40 CDI
	
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

-- ATM Transaction List (On-Us/Acquirer)

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"130","pdfLength":"130","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"REPORT ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"REPORT ID : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"EFP001-01","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"EFP001-01","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Type","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"File Type : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TXT","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"TXT","fieldFormat":"","delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"File Type","csvTxtLength":"131","pdfLength":"131","fieldType":"String","defaultValue":"ATM Transaction Log (On-us/Acquirer)","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","defaultValue":"","eol":false,"delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"RunTime","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"RUNTIME : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm","csvTxtLength":"10","pdfLength":"10","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"TRAN DATE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","firstField":true,"delimiter":";","fieldFormat":"","defaultValue":"TRAN DATE : ","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"120","pdfLength":"120","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Frequency","csvTxtLength":"11","pdfLength":"11","fieldType":"String","fieldFormat":"","delimiter":";","defaultValue":"Frequency : ","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Daily","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"Daily","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Acq Term No","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Acq Term No","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Seq No","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Trace No","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ATM Card No","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Iss Bank Code","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Iss Bank Code","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"From Acct Type","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"From Acct Type","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"From Acct No","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"From Acct No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"To Acct Type","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"To Acct Type","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"To Acc No","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"To Acc No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Amount","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Amount","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"Reply Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"Reply Code","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"Comment","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"Comment","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" ","bodyHeader":true,"eol":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":29,"sectionName":"29","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"30","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"BANK CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"FROM ACC TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"TO ACC TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":39,"sectionName":"39","fieldName":"AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":41,"sectionName":"41","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[]');
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"130","pdfLength":"130","fieldType":"String","defaultValue":"CHINA BANK SAVINGS","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"REPORT ID","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"REPORT ID : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"EFP001-01","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"EFP001-01","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"File Type","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"File Type : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"TXT","csvTxtLength":"4","pdfLength":"4","fieldType":"String","defaultValue":"TXT","fieldFormat":"","delimiter":";","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"File Type","csvTxtLength":"131","pdfLength":"131","fieldType":"String","defaultValue":"ATM Transaction Log (On-us/Acquirer)","firstField":true,"delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"RUNDATE : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","defaultValue":"","eol":false,"delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"RunTime","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"RUNTIME : ","delimiter":";","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"Time Value","eol":true,"fieldType":"Date","fieldFormat":"HH:mm","csvTxtLength":"10","pdfLength":"10","delimiter":";","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"TRAN DATE","csvTxtLength":"11","pdfLength":"11","fieldType":"String","firstField":true,"delimiter":";","fieldFormat":"","defaultValue":"TRAN DATE : ","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"As of Date Value","csvTxtLength":"120","pdfLength":"120","fieldType":"Date","defaultValue":"","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Frequency","csvTxtLength":"11","pdfLength":"11","fieldType":"String","fieldFormat":"","delimiter":";","defaultValue":"Frequency : ","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"Daily","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":";","defaultValue":"Daily","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Acq Term No","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":"Acq Term No","firstField":true,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":2,"sectionName":"2","fieldName":"Seq No","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"Seq No","firstField":false,"bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":3,"sectionName":"3","fieldName":"Trace No","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"Trace No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":4,"sectionName":"4","fieldName":"ATM Card No","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"ATM Card No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":5,"sectionName":"5","fieldName":"Iss Bank Code","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"Iss Bank Code","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":6,"sectionName":"6","fieldName":"Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"Date","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":7,"sectionName":"7","fieldName":"Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"Time","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":8,"sectionName":"8","fieldName":"Tran Mnem","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"Tran Mnem","bodyHeader":true,"fieldFormat":"","delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":9,"sectionName":"9","fieldName":"From Acct Type","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":"From Acct Type","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":10,"sectionName":"10","fieldName":"From Acct No","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"From Acct No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":11,"sectionName":"11","fieldName":"To Acct Type","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"To Acct Type","bodyHeader":true,"eol":false,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":12,"sectionName":"12","fieldName":"To Acc No","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":"To Acc No","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":13,"sectionName":"13","fieldName":"Amount","csvTxtLength":"11","pdfLength":"11","fieldType":"String","defaultValue":"Amount","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":14,"sectionName":"14","fieldName":"Reply Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"Reply Code","bodyHeader":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":15,"sectionName":"15","fieldName":"Comment","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"Comment","bodyHeader":true,"eol":true,"delimiter":";","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":16,"sectionName":"16","fieldName":"","csvTxtLength":"9","pdfLength":"9","fieldType":"String","defaultValue":" ","firstField":true,"bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":17,"sectionName":"17","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":18,"sectionName":"18","fieldName":"","csvTxtLength":"15","pdfLength":"15","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":19,"sectionName":"19","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","bodyHeader":true,"delimiter":"","defaultValue":" ","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":20,"sectionName":"20","fieldName":"","csvTxtLength":"42","pdfLength":"42","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":21,"sectionName":"21","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":22,"sectionName":"22","fieldName":"","csvTxtLength":"10","pdfLength":"10","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":23,"sectionName":"23","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":24,"sectionName":"24","fieldName":"","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":25,"sectionName":"25","fieldName":"","csvTxtLength":"13","pdfLength":"13","fieldType":"String","defaultValue":" ","bodyHeader":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":26,"sectionName":"26","fieldName":"","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":" ","bodyHeader":true,"eol":true,"delimiter":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":27,"sectionName":"27","fieldName":"TERMINAL","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":28,"sectionName":"28","fieldName":"SEQ NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","firstField":false,"defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":29,"sectionName":"29","fieldName":"TRACE NUMBER","csvTxtLength":"8","pdfLength":"8","fieldType":"String","defaultValue":"","delimiter":";","leftJustified":false,"padFieldLength":"6","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":30,"sectionName":"30","fieldName":"ATM CARD NUMBER","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"19","decrypt":true,"decryptionKey":"TRL_PAN_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":31,"sectionName":"31","fieldName":"BANK CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":32,"sectionName":"32","fieldName":"DATE","csvTxtLength":"15","pdfLength":"15","fieldType":"Date","fieldFormat":"MM/dd/yyyy","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":33,"sectionName":"33","fieldName":"TIME","csvTxtLength":"13","pdfLength":"13","fieldType":"Date","fieldFormat":"HH:mm:ss","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":34,"sectionName":"34","fieldName":"TRAN MNEM","csvTxtLength":"7","pdfLength":"7","fieldType":"String","fieldFormat":"","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":35,"sectionName":"35","fieldName":"FROM ACC TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":36,"sectionName":"36","fieldName":"FROM ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_1_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":37,"sectionName":"37","fieldName":"TO ACC TYPE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","eol":false,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":38,"sectionName":"38","fieldName":"TO ACCOUNT NO","csvTxtLength":"18","pdfLength":"18","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"16","decrypt":true,"decryptionKey":"TRL_ACCOUNT_2_ACN_ID_EKY_ID","padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":39,"sectionName":"39","fieldName":"AMOUNT","csvTxtLength":"13","pdfLength":"13","fieldType":"Decimal","fieldFormat":"#,##0.00","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null},{"sequence":40,"sectionName":"40","fieldName":"VOID CODE","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":"3","decrypt":false,"decryptionKey":null,"padFieldType":"Leading","padFieldValue":"Zeros"},{"sequence":41,"sectionName":"41","fieldName":"COMMENT","csvTxtLength":"30","pdfLength":"30","fieldType":"String","eol":true,"delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT * FROM(
-- On-us (exclude Transfer)
SELECT
      DISTINCT TXN.TRL_TQU_ID "TXN QUALIFIER",
      CASE WHEN ABR.ABR_CODE IS NOT NULL THEN ABR.ABR_CODE ELSE BRC.BRC_CODE END AS "BRANCH CODE",
      CASE WHEN ABR.ABR_NAME IS NOT NULL THEN ABR.ABR_NAME ELSE BRC.BRC_NAME END AS "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      CASE WHEN AST.AST_ALO_LOCATION_ID IS NOT NULL THEN AST.AST_ALO_LOCATION_ID ELSE ABR.ABR_NAME END AS "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM "BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE 
		WHEN TXN.TRL_TSC_CODE = 90 THEN ''PIN'' 
		WHEN TXN.TRL_TSC_CODE = 126 THEN ''EAA'' 
        WHEN TXN.TRL_TSC_CODE = 127 THEN ''MAA'' 
		WHEN TXN.TRL_TSC_CODE = 129 THEN ''LST'' 
        WHEN TXN.TRL_TSC_CODE = 131 THEN ''FPC'' 
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE 
		WHEN TXN.TRL_TSC_CODE IN (50, 250) THEN CBL.CBL_MNEM
        WHEN TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND TXN.TRL_TSC_CODE != 52 THEN CBA_REV.CBA_MNEM
		WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 10 THEN ''SA'' 
		WHEN TXN.TRL_ACCOUNT_TYPE_2_ATP_ID = 20 THEN ''CA'' 
		ELSE '''' END AS "TO ACC TYPE",
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      CASE WHEN TXN.TRL_TSC_CODE = 122 THEN TXN.TRL_ISS_CHARGE_AMT ELSE TXN.TRL_AMT_TXN END AS "AMOUNT",
      TXN.TRL_ACTION_RESPONSE_CODE "VOID CODE",
      ARC.ARC_NAME "COMMENT"
	FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID      
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
      LEFT JOIN CBC_BILLER CBL ON CBL.CBL_ID = (SELECT MIN(CBL_ID) FROM CBC_BILLER WHERE CBL_CODE = TXNC.TRL_BILLER_CODE)
	  LEFT JOIN CBC_BANK CBA_REV ON LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_REV.CBA_CODE, 10, ''0'')
	WHERE
      (TXN.TRL_TQU_ID = ''F'' OR (TXN.TRL_TQU_ID = ''A'' AND TRL_TSC_CODE IN (90, 126, 127, 129, 131, 142, 143)) OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_FRD_REV_INST_ID IS NULL 
      AND TXN.TRL_TSC_CODE NOT IN (42, 44, 45, 46, 47, 48, 49, 52, 252)
	  AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != 12345
      AND COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '''') = {V_Iss_Name} 
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
UNION ALL
-- Onus Transfer (debit/credit)
SELECT
      DISTINCT TXN.TRL_TQU_ID "TXN QUALIFIER",
      CASE WHEN ABR.ABR_CODE IS NOT NULL THEN ABR.ABR_CODE ELSE BRC.BRC_CODE END AS "BRANCH CODE",
      CASE WHEN ABR.ABR_NAME IS NOT NULL THEN ABR.ABR_NAME ELSE BRC.BRC_NAME END AS "BRANCH NAME",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      CASE WHEN AST.AST_ALO_LOCATION_ID IS NOT NULL THEN AST.AST_ALO_LOCATION_ID ELSE ABR.ABR_NAME END AS "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM "BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE 
		WHEN TXN.TRL_TSC_CODE IN (48, 49) AND TXN.TRL_TQU_ID = ''R'' THEN CTRD.CTR_REV_MNEM
        WHEN TXN.TRL_TSC_CODE IN (48, 49) AND TXN.TRL_TQU_ID = ''F'' THEN CTRD.CTR_MNEM
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE 
		WHEN TXN.TRL_TSC_CODE IN (50, 250) THEN CBL.CBL_MNEM
        WHEN TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND TXN.TRL_TSC_CODE != 52 THEN CBA_REV.CBA_MNEM
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
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND CTR.CTR_CHANNEL = (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) AND CTR.CTR_CODE NOT IN (48, 49) AND CTR.CTR_DEBIT_CREDIT IN (''DEBIT'', ''CREDIT'')
      LEFT JOIN CBC_TRAN_CODE CTRD ON TXN.TRL_TSC_CODE = CTRD.CTR_CODE AND CTRD.CTR_CHANNEL = (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) AND CTRD.CTR_CODE IN (48, 49) AND CTRD.CTR_DEBIT_CREDIT = ''DEBIT''
	  LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID      
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
	  LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
      LEFT JOIN CBC_BILLER CBL ON CBL.CBL_ID = (SELECT MIN(CBL_ID) FROM CBC_BILLER WHERE CBL_CODE = TXNC.TRL_BILLER_CODE)
	  LEFT JOIN CBC_BANK CBA_REV ON LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_REV.CBA_CODE, 10, ''0'')
	WHERE
      (TXN.TRL_TQU_ID = ''F'' OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
	  AND TXN.TRL_FRD_REV_INST_ID IS NOT NULL
      AND TXN.TRL_TSC_CODE IN (42, 43, 44, 45, 46, 47, 48, 49, 51, 52)
      AND COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '''') = {V_Iss_Name} 
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
UNION ALL
-- Acquirer (exclude Transfer/Eload)
SELECT
      DISTINCT TXN.TRL_TQU_ID "TXN QUALIFIER",
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM "BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE
		WHEN (TXNC.TRL_IS_INTER_ENTITY = 1 OR (CBA.CBA_MNEM IS NOT NULL AND CBA.CBA_MNEM = {V_IE_Iss_Name})) AND TXN.TRL_TQU_ID = ''R'' AND CTRI.CTR_REV_MNEM IS NOT NULL THEN CTRI.CTR_REV_MNEM 
		WHEN (TXNC.TRL_IS_INTER_ENTITY = 1 OR (CBA.CBA_MNEM IS NOT NULL AND CBA.CBA_MNEM = {V_IE_Iss_Name})) AND TXN.TRL_TQU_ID = ''F'' AND CTRI.CTR_MNEM IS NOT NULL THEN CTRI.CTR_MNEM
	    WHEN TXN.TRL_TQU_ID = ''R'' AND (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') IS NOT NULL
			THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
		WHEN TXN.TRL_TQU_ID = ''F'' AND (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') IS NOT NULL
			THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
	    WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE
        WHEN TXN.TRL_TSC_CODE IN (50, 250) THEN CBL.CBL_MNEM
        WHEN TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND TXN.TRL_TSC_CODE != 52 THEN CBA_REV.CBA_MNEM
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
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL
	  LEFT JOIN CBC_TRAN_CODE CTRI ON TXN.TRL_TSC_CODE = CTRI.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''I-CDM'' ELSE ''I-'' || TXNC.TRL_ORIGIN_CHANNEL END) = CTRI.CTR_CHANNEL 
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
      LEFT JOIN CBC_BILLER CBL ON CBL.CBL_ID = (SELECT MIN(CBL_ID) FROM CBC_BILLER WHERE CBL_CODE = TXNC.TRL_BILLER_CODE)
	  LEFT JOIN CBC_BANK CBA_REV ON LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_REV.CBA_CODE, 10, ''0'')
	WHERE
      (TXN.TRL_TQU_ID IN (''F'', ''C'') OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_FRD_REV_INST_ID IS NULL
      AND TXN.TRL_TSC_CODE NOT IN (40, 42, 44, 45, 46, 47, 48, 49, 51, 52, 252)
      AND TXN.TRL_CARD_ACPT_TERMINAL_IDENT != 12345
      AND (TXN.TRL_ISS_NAME IS NULL OR COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '''') = {V_IE_Iss_Name})
	  AND (CBA.CBA_MNEM IS NULL OR CBA.CBA_MNEM != {V_Iss_Name})
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
UNION ALL
-- Acquirer Transfer/Eload (debit)
SELECT
      DISTINCT TXN.TRL_TQU_ID "TXN QUALIFIER",
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM "BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''R'' AND CTRI.CTR_REV_MNEM IS NOT NULL THEN CTRI.CTR_REV_MNEM 
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''F'' AND CTRI.CTR_MNEM IS NOT NULL THEN CTRI.CTR_MNEM
        WHEN TXN.TRL_TQU_ID = ''R'' AND (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') IS NOT NULL
			THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')
		WHEN TXN.TRL_TQU_ID = ''F'' AND (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'') IS NOT NULL
			THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''DEBIT'')  
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE
        WHEN TXN.TRL_TSC_CODE IN (50, 250) THEN CBL.CBL_MNEM
        WHEN TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND TXN.TRL_TSC_CODE != 52 THEN CBA_REV.CBA_MNEM
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
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL AND CTR.CTR_DEBIT_CREDIT = ''DEBIT''
      LEFT JOIN CBC_TRAN_CODE CTRI ON TXN.TRL_TSC_CODE = CTRI.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''I-CDM'' ELSE ''I-'' || TXNC.TRL_ORIGIN_CHANNEL END) = CTRI.CTR_CHANNEL AND CTRI.CTR_DEBIT_CREDIT = ''DEBIT''
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
      LEFT JOIN CBC_BILLER CBL ON CBL.CBL_ID = (SELECT MIN(CBL_ID) FROM CBC_BILLER WHERE CBL_CODE = TXNC.TRL_BILLER_CODE)
	  LEFT JOIN CBC_BANK CBA_REV ON LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_REV.CBA_CODE, 10, ''0'')
	WHERE
      (TXN.TRL_TQU_ID IN (''F'', ''C'') OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_TSC_CODE IN (40, 42, 43, 44, 45, 46, 47, 48, 49, 51, 52, 252)
      AND (TXN.TRL_ISS_NAME IS NULL OR COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '''') = {V_IE_Iss_Name})
	  AND (CBA.CBA_MNEM IS NULL OR CBA.CBA_MNEM != {V_Iss_Name})
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
	  AND (CTR.CTR_DEBIT_CREDIT = ''DEBIT'' or CTRI.CTR_DEBIT_CREDIT = ''DEBIT'')
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
UNION ALL
-- Acquirer Transfer/Eload (credit)
SELECT
      DISTINCT TXN.TRL_TQU_ID "TXN QUALIFIER",
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 9, 4) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      CBA.CBA_MNEM "BANK CODE",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      CASE
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''R'' AND CTRI.CTR_REV_MNEM IS NOT NULL THEN CTRI.CTR_REV_MNEM 
		WHEN TXNC.TRL_IS_INTER_ENTITY = 1 AND TXN.TRL_TQU_ID = ''F'' AND CTRI.CTR_MNEM IS NOT NULL THEN CTRI.CTR_MNEM  
        WHEN TXN.TRL_TQU_ID = ''R'' AND (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''CREDIT'') IS NOT NULL
			THEN (SELECT CTR_REV_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''CREDIT'')
		WHEN TXN.TRL_TQU_ID = ''F'' AND (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''CREDIT'') IS NOT NULL
			THEN (SELECT CTR_MNEM FROM CBC_TRAN_CODE WHERE CTR_CODE=TXN.TRL_TSC_CODE AND CTR_CHANNEL=''BNT'' AND CTR_DEBIT_CREDIT = ''CREDIT'')
		WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CASE WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 10 THEN ''SA'' WHEN TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = 20 THEN ''CA'' ELSE '''' END AS "FROM ACC TYPE",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CASE
        WHEN TXN.TRL_TSC_CODE IN (50, 250) THEN CBL.CBL_MNEM
        WHEN TXN.TRL_FRD_REV_INST_ID IS NOT NULL AND TXN.TRL_TSC_CODE != 52 THEN CBA_REV.CBA_MNEM
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
      LEFT JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''CDM'' ELSE TXNC.TRL_ORIGIN_CHANNEL END) = CTR.CTR_CHANNEL AND CTR.CTR_DEBIT_CREDIT = ''CREDIT''
      LEFT JOIN CBC_TRAN_CODE CTRI ON TXN.TRL_TSC_CODE = CTRI.CTR_CODE AND (CASE WHEN TXNC.TRL_ORIGIN_CHANNEL = ''BRM'' THEN ''I-CDM'' ELSE ''I-'' || TXNC.TRL_ORIGIN_CHANNEL END) = CTRI.CTR_CHANNEL AND CTRI.CTR_DEBIT_CREDIT = ''CREDIT''
      LEFT JOIN CBC_BIN CBI ON CBI.CBI_ID = (SELECT MIN(CBI_ID) FROM CBC_BIN WHERE CBI_BIN = TXNC.TRL_CARD_BIN)
      LEFT JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      LEFT JOIN AUTH_RESULT_CODE ARC ON TXN.TRL_ACTION_RESPONSE_CODE = ARC.ARC_CODE
      LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      LEFT JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4)
      LEFT JOIN CBC_BILLER CBL ON CBL.CBL_ID = (SELECT MIN(CBL_ID) FROM CBC_BILLER WHERE CBL_CODE = TXNC.TRL_BILLER_CODE)
	  LEFT JOIN CBC_BANK CBA_REV ON LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_REV.CBA_CODE, 10, ''0'')
	WHERE
      (TXN.TRL_TQU_ID IN (''F'', ''C'') OR (TXN.TRL_TQU_ID = ''R'' AND TXN.TRL_ACTION_RESPONSE_CODE = 0))
      AND TXN.TRL_TSC_CODE IN (44, 48)
	  AND (CTR.CTR_DEBIT_CREDIT = ''CREDIT'' or CTRI.CTR_DEBIT_CREDIT = ''CREDIT'')
      AND (TXN.TRL_ISS_NAME IS NULL OR COALESCE(CBA.CBA_MNEM, TXN.TRL_ISS_NAME, '''') = {V_IE_Iss_Name})
	  AND (CBA.CBA_MNEM IS NULL OR CBA.CBA_MNEM != {V_Iss_Name})
	  AND (TXN.TRL_DEO_NAME = {V_Deo_Name} OR LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = {V_Acqr_Inst_Id})
	  AND LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = {V_Recv_Inst_Id}
      AND {Branch_Code}
      AND {Terminal}
      AND {Txn_Date}
	)
	ORDER BY
      "BRANCH CODE" ASC,
      "BRANCH NAME" ASC,
      "TERMINAL" ASC,
      "DATE" ASC,
      "TIME" ASC,
      "SEQ NUMBER" ASC
	');	
	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM Transaction List (On-Us/Acquirer)' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'ATM Transaction List (On-Us/Acquirer)' AND RED_INS_ID = 2;
	
END;
/