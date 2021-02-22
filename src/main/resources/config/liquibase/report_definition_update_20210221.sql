DECLARE
	i_HEADER_FIELD CLOB;
	i_BODY_FIELD CLOB;
	i_TRAILER_FIELD CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;

BEGIN 

-- ATM Downtime Report (Branch and Coast)
delete from atm_downtime;

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Region","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Region","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"Terminal ID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Terminal ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"Terminal Name","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Terminal Name","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"Date Down","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Date Down","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"Time Down","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Time Down","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"Date Up","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Date Up","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"Time Up","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Time Up","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"Total Down Time","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Total Down Time","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"Cause","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cause","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"Specific Problem","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Specific Problem","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"TERMINAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"DATE DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"dd/MM/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","fieldName":"TIME DOWN","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"DATE UP","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"dd/MM/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":17,"sectionName":"17","fieldName":"TIME UP","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":18,"sectionName":"18","fieldName":"TOTAL DOWN TIME","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":19,"sectionName":"19","fieldName":"CAUSE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":20,"sectionName":"20","fieldName":"SPECIFIC PROBLEM","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]
');

i_BODY_QUERY := TO_CLOB('
SELECT
    AST.AST_ARE_NAME "REGION",
    AST.AST_TERMINAL_ID "TERMINAL",
    AST.AST_ALO_LOCATION_ID "LOCATION",
    TRUNC(ATD_START_TIMESTAMP) "DATE DOWN",
    TO_CHAR(ATD_START_TIMESTAMP,''hh24:mi:ss'') "TIME DOWN", 
    TRUNC(ATD_END_TIMESTAMP) "DATE UP",
    TO_CHAR(ATD_END_TIMESTAMP,''hh24:mi:ss'') "TIME UP", 
    extract(day from (ATD_END_TIMESTAMP - ATD_START_TIMESTAMP)) || '' day/s '' 
      || LPAD(extract(hour from (ATD_END_TIMESTAMP - ATD_START_TIMESTAMP)),2,0) 
      || '':'' || LPAD(extract(minute from (ATD_END_TIMESTAMP - ATD_START_TIMESTAMP)),2,0)
      || '':'' || extract(second from (ATD_END_TIMESTAMP - ATD_START_TIMESTAMP)) "TOTAL DOWN TIME",
    CASE WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Comms Event'' THEN ''Host''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''In supervisor mode'' THEN ''Replenish''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Power fail'' THEN ''PF''
          WHEN TRIM(ATD.ATD_DOWN_REASON) IN (''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'') THEN ''HW''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Cash dispenser faulty'' THEN ''OOC''
          WHEN TRIM(ATD.ATD_DOWN_REASON) = ''Cash availability status change'' THEN ''Cash''
          WHEN TRIM(ATD.ATD_DOWN_REASON) IN (''Operator request'', ''Exiting supervisor mode'') THEN ''Other''
      END AS "CAUSE",
      ATD.ATD_DOWN_REASON "SPECIFIC PROBLEM"
from 
    ATM_STATIONS AST
    JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD.ATD_AST_ID
WHERE 
    ATD.ATD_START_TIMESTAMP >= TO_DATE(''{From_Date}'', ''YYYYMMDD HH24:MI:SS'') AND ATD.ATD_END_TIMESTAMP < TO_DATE(''{To_Date}'',''YYYYMMDD HH24:MI:SS'')
	AND AST.AST_ACO_ID NOT IN (1722,1723)
ORDER BY
      AST.AST_ARE_NAME ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC,
      ATD.ATD_START_TIMESTAMP ASC
');
	  
UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY, RED_BODY_FIELDS = i_BODY_FIELD WHERE RED_NAME = 'ATM Downtime Report (Branch and Coast)';


-- ATM Cash Level

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Region","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Region","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"Terminal ID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Terminal ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"Location","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Location","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"Date of Loading","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Date of Loading","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"Load Amount (500)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Load Amount (500)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"Load Amount (100)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Load Amount (100)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"Load Amount (1000)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Load Amount (1000)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"Total Cash Loaded","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Total Cash Loaded","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":9,"sectionName":"9","fieldName":"Current Cash Level (500)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Current Cash Level (500)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"Current Cash Level (100)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Current Cash Level (100)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"Current Cash Level (1000)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Current Cash Level (1000)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"Cash Level (500)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cash Level (500)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"13","fieldName":"Cash Level (100)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cash Level (100)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"Cash Level (1000)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cash Level (1000)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"15","fieldName":"Total (PHP)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Total (PHP)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"LOAD %","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"LOAD %","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":17,"sectionName":"17","fieldName":"Classification","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Classification","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":18,"sectionName":"18","fieldName":"Cash Status","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cash Status","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":19,"sectionName":"19","fieldName":"Ops Status","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Ops Status","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":20,"sectionName":"20","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":21,"sectionName":"21","fieldName":"TERMINAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":22,"sectionName":"22","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":23,"sectionName":"23","fieldName":"DATE OF LOADING","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"dd/MM/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":24,"sectionName":"24","fieldName":"LOAD 500","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":25,"sectionName":"25","fieldName":"LOAD 100","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":26,"sectionName":"26","fieldName":"LOAD 1000","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":27,"sectionName":"27","fieldName":"TOTAL CASH LOADED","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":28,"sectionName":"28","fieldName":"CURRENT 500 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":29,"sectionName":"29","fieldName":"CURRENT 100 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":30,"sectionName":"30","fieldName":"CURRENT 1000 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":31,"sectionName":"31","fieldName":"CURRENT 500 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":32,"sectionName":"32","fieldName":"CURRENT 100 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":33,"sectionName":"33","fieldName":"CURRENT 1000 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":34,"sectionName":"34","fieldName":"TOTAL CASH VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":35,"sectionName":"35","fieldName":"LOAD PERCENTAGE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":36,"sectionName":"36","fieldName":"CLASSIFICATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":37,"sectionName":"37","fieldName":"CASH STATUS","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":38,"sectionName":"38","fieldName":"OPS STATUS","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]
');

i_BODY_QUERY := TO_CLOB('
select MAIN.*,
  CASE WHEN "LOAD PERCENTAGE" < 20 THEN ''LV''
  WHEN "LOAD PERCENTAGE" < 35 THEN ''M''
  WHEN "LOAD PERCENTAGE" < 40 THEN ''HV''
  WHEN "LOAD PERCENTAGE" < 45 THEN ''VIP'' END AS "CLASSIFICATION"
from (
select 
    AST.AST_ARE_NAME "REGION",
    AST.AST_TERMINAL_ID "TERMINAL",
    AST.AST_ALO_LOCATION_ID "LOCATION",
    DVT.LOAD_DATE "DATE OF LOADING",
    DVT.LOAD_100 * 100 "LOAD 100",
    DVT.LOAD_200 * 200 "LOAD 200",
    DVT.LOAD_500 * 500 "LOAD 500",
    DVT.LOAD_1000 * 1000 "LOAD 1000",
    (DVT.LOAD_100 * 100) + (DVT.LOAD_200 * 200) + (DVT.LOAD_500 * 500) + (DVT.LOAD_1000 * 1000) "TOTAL CASH LOADED", 
    ADS.POS_100 "CURRENT 100 POS",
    ADS.POS_200 "CURRENT 200 POS",
    ADS.POS_500 "CURRENT 500 POS",
    ADS.POS_1000 "CURRENT 1000 POS",
    ADS.POS_100 * 100 "CURRENT 100 VALUE",
    ADS.POS_200 * 200 "CURRENT 200 VALUE",
    ADS.POS_500 * 500 "CURRENT 500 VALUE",
    ADS.POS_1000 * 1000 "CURRENT 1000 VALUE",
    (ADS.POS_100 * 100) + (ADS.POS_200 * 200) + (ADS.POS_500 * 500) + (ADS.POS_1000 * 1000) "TOTAL CASH VALUE",
    round((ADS.POS_100 * 100 + ADS.POS_200 * 200 + ADS.POS_500 * 500 + ADS.POS_1000 * 1000)/(DVT.LOAD_100 * 100 + DVT.LOAD_200 * 200 + DVT.LOAD_500 * 500 + DVT.LOAD_1000 * 1000) * 100, 2) "LOAD PERCENTAGE",
    
    CASE WHEN ATS.ATS_CASH_DISPENSE_POSSIBLE = ''Yes'' THEN ''CASH LEVEL - GOOD'' ELSE ''FOR LOADING'' END AS "CASH STATUS",
    ATS.ATS_OPERATION_STATUS "OPS STATUS"
from ATM_STATIONS AST 
join ATM_STATUS ATS ON AST.AST_ID = ATS.ATS_AST_ID 
join (select ATO_AST_ID, L_DATE LOAD_DATE, sum(L_100) LOAD_100, sum(L_200) LOAD_200, sum(L_500) LOAD_500, sum(L_1000) LOAD_1000, 
  ROW_NUMBER() OVER (PARTITION BY ATO_AST_ID  ORDER BY L_DATE DESC) rn from 
  (select ATO_AST_ID, TRUNC(ATO_TIMESTAMP) L_DATE, 
    CASE WHEN ATO_DENOMINATION = 100 THEN ATO_COUNTER ELSE 0 END L_100,
    CASE WHEN ATO_DENOMINATION = 200 THEN ATO_COUNTER ELSE 0 END L_200,
    CASE WHEN ATO_DENOMINATION = 500 THEN ATO_COUNTER ELSE 0 END L_500,
    CASE WHEN ATO_DENOMINATION = 1000 THEN ATO_COUNTER ELSE 0 END L_1000
  from ATM_DEVICE_TOTALS  
  where trim(ato_event) in (''Replenishment load'',''Replenishment reject'')
  )
  group by ATO_AST_ID, L_DATE
) DVT on DVT.ATO_AST_ID = AST.AST_ID
join (select ADS_AST_ID, sum(CURR_100) POS_100, sum(CURR_200) POS_200, sum(CURR_500) POS_500, sum(CURR_1000) POS_1000 from (
  select ADS_AST_ID,
  CASE WHEN ADS_DEVICE_DESCRIPTION = ''100 (Currency PHP)'' THEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) ELSE 0 END CURR_100,
  CASE WHEN ADS_DEVICE_DESCRIPTION = ''200 (Currency PHP)'' THEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) ELSE 0 END CURR_200,
  CASE WHEN ADS_DEVICE_DESCRIPTION = ''500 (Currency PHP)'' THEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) ELSE 0 END CURR_500,
  CASE WHEN ADS_DEVICE_DESCRIPTION = ''1000 (Currency PHP)'' THEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) ELSE 0 END CURR_1000
  from ATM_DEVICE_STATUS 
  where ADS_DEVICE_ID in (''Cassette 1'',''Cassette 2'',''Cassette 3'',''Cassette 4''))
group by ADS_AST_ID 
) ADS on ADS_AST_ID = AST.AST_ID 
where AST.AST_ACO_ID NOT IN (1722,1723) AND DVT.rn = 1
ORDER BY 
    "REGION" ASC,
    "TERMINAL" ASC,
    "LOCATION" ASC,
    "DATE OF LOADING" ASC
) MAIN
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY, RED_BODY_FIELDS = i_BODY_FIELD WHERE RED_NAME = 'ATM Cash Level';


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
  AND {Branch_Code}
ORDER BY
  CPD.CPD_NAME ASC,
  CRDCT.CRD_BRANCH_CODE ASC,
  CUST.CUST_NUMBER ASC
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'Cash Card Balance';


-- Issuer ATM Withdrawal Expense

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH CODE","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BRANCH NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"BANCNET MEMBER BANKS","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"BANCNET MEMBER BANKS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"SUBTOTAL EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL COUNT","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"String","delimiter":";","defaultValue":"TOTAL EXPENSE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"8","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"defaultValue":"TOTAL INCOME"},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"50","fieldType":"String","delimiter":";","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"10","fieldName":"BRANCH NAME","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"11","fieldName":"ACQUIRER BANK MNEM","csvTxtLength":"50","fieldType":"String","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"12","fieldName":"SUBTOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":13,"sectionName":"13","fieldName":"SUBTOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":14,"sectionName":"14","fieldName":"TOTAL COUNT","csvTxtLength":"50","fieldType":"Number","delimiter":";","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"fieldFormat":","},{"sequence":15,"sectionName":"15","fieldName":"TOTAL EXPENSE","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"16","fieldName":"TOTAL INCOME","csvTxtLength":"50","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"eol":true}]
');

UPDATE REPORT_DEFINITION SET RED_BODY_FIELDS = i_BODY_FIELD WHERE RED_NAME = 'Issuer ATM Withdrawal Expense';

-- Acquirer ATM Withdrawal Income
i_BODY_QUERY := TO_CLOB('
SELECT
     ABR.ABR_CODE "BRANCH CODE",
     ABR.ABR_NAME "BRANCH NAME",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     CBA.CBA_MNEM "ISSUER BANK MNEM",
     COUNT(TXN.TRL_ID) "SUBTOTAL COUNT",
     COUNT(TXN.TRL_ID) * 12.00 "SUBTOTAL INCOME",
     COUNT(TXN.TRL_ID) "TOTAL COUNT",
     COUNT(TXN.TRL_ID) * 12.00 "TOTAL INCOME"
FROM
     TRANSACTION_LOG TXN
     JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
     JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
     JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
     JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
     JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
WHERE
      TXN.TRL_TSC_CODE = 1
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXN.TRL_ISS_NAME IS NULL
      AND {Txn_Date}
GROUP BY
      ABR.ABR_CODE,
      ABR.ABR_NAME,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID,
      CBA.CBA_MNEM
ORDER BY
      "BRANCH CODE" ASC,
      "TERMINAL" ASC
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY WHERE RED_NAME = 'Acquirer ATM Withdrawal Income';

-- Issuer Balance Inquiry Transaction Fees
i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","defaultValue":"Report ID:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"48","pdfLength":"48","fieldType":"String","delimiter":";","defaultValue":"FREQUENCY:","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"FileName1","csvTxtLength":"63","pdfLength":"63","fieldType":"String","defaultValue":"INQUIRY TRANSACTIONS AND EXPENSE AS ISSUER (PER BRANCH AND BANK)","delimiter":";","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0}]
');

UPDATE REPORT_DEFINITION SET RED_BODY_FIELDS = i_BODY_FIELD WHERE RED_NAME = 'Issuer Balance Inquiry Transaction Fees';

-- Approved InstaPay Transactions As Transmitting Bank
i_BODY_QUERY := TO_CLOB('
SELECT
      TXNC.TRL_ORIGIN_CHANNEL "CHANNEL",
      BRC.BRC_CODE "ISSUER BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "ACQUIRER BANK MNEM",
      (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 46
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
      AND {Channel}
      AND {Bank_Code}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      {Bank_Code}
      COUNT("TRAN COUNT") "TRAN COUNT",
      SUM("AMOUNT") "AMOUNT",
      1.00 * COUNT("TRAN COUNT") AS "BANCNET FEE",
      9.00 * COUNT("TRAN COUNT") AS "INSTAPAY INCOME"
FROM(
SELECT
      {Channel}
      TXN.TRL_ID "TRAN COUNT",
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN 
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
WHERE
      TXN.TRL_TSC_CODE = 46
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
      AND {Txn_Date}
)
{Txn_Criteria}
END
');

i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
WHERE
      TXN.TRL_TSC_CODE = 46
      AND TXN.TRL_TQU_ID IN (''F'', ''R'')
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
      AND {Channel}
      AND {Bank_Code}
      AND {Txn_Date}
START SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT",
      SUM(1.00 * COUNT(TXN.TRL_ID)) AS "BANCNET FEE",
      SUM(9.00 * COUNT(TXN.TRL_ID)) AS "INSTAPAY INCOME"
FROM
      TRANSACTION_LOG TXN
WHERE
      TXN.TRL_TSC_CODE = 46
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
      AND {Txn_Date}
GROUP BY
      TXN.TRL_AMT_TXN,
      TXN.TRL_ID
END
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY WHERE RED_NAME = 'Approved InstaPay Transactions As Transmitting Bank';


-- Approved Pesonet Transactions As Transmitting Bank
i_BODY_QUERY := TO_CLOB('
SELECT
      TXNC.TRL_ORIGIN_CHANNEL "CHANNEL",
      BRC.BRC_CODE "ISSUER BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) "TERMINAL",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      (SELECT CBA_MNEM FROM CBC_BANK WHERE LPAD(TXN.TRL_ACQR_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "ACQUIRER BANK MNEM",
      (SELECT CBA_CODE FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK CODE",
      (SELECT CBA_NAME FROM CBC_BANK WHERE LPAD(TXN.TRL_FRD_REV_INST_ID, 10, ''0'') = LPAD(CBA_CODE, 10, ''0'')) AS "BANK NAME",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      TXN.TRL_ACCOUNT_2_ACN_ID "TO ACCOUNT NO",
      TXN.TRL_ACCOUNT_2_ACN_ID_EKY_ID,
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
      JOIN CARD CRD ON TXN.TRL_PAN = CRD.CRD_PAN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
      JOIN BRANCH BRC ON CRD.CRD_CUSTOM_DATA = BRC.BRC_CODE
WHERE
      TXN.TRL_TSC_CODE = 47
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
      AND {Channel}
      AND {Bank_Code}
      AND {Txn_Date}
ORDER BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT ASC,
      TXN.TRL_SYSTEM_TIMESTAMP ASC,
      TXN.TRL_DEST_STAN ASC
START SELECT
      {Bank_Code}
      COUNT("TRAN COUNT") "TRAN COUNT",
      SUM("AMOUNT") "AMOUNT",
      1.00 * COUNT("TRAN COUNT") AS "PCHC FEE",
      9.00 * COUNT("TRAN COUNT") AS "PESONET INCOME"
FROM(
SELECT
      {Channel}
      TXN.TRL_ID "TRAN COUNT",
      TXN.TRL_AMT_TXN "AMOUNT"
FROM
      TRANSACTION_LOG TXN
	  JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID = TXNC.TRL_ID
WHERE
      TXN.TRL_TSC_CODE = 47
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
      AND {Txn_Date}
)
{Txn_Criteria}
END
');

i_TRAILER_QUERY := TO_CLOB('
SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL"
FROM
      TRANSACTION_LOG TXN
WHERE
      TXN.TRL_TSC_CODE = 47
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
      AND {Channel}
      AND {Bank_Code}
      AND {Txn_Date}
START SELECT
      COUNT(TXN.TRL_ID) "TOTAL TRAN",
      SUM(TXN.TRL_AMT_TXN) "TOTAL AMOUNT",
      SUM(1.00 * COUNT(TXN.TRL_ID)) AS "PCHC FEE",
      SUM(9.00 * COUNT(TXN.TRL_ID)) AS "PESONET INCOME"
FROM
      TRANSACTION_LOG TXN
WHERE
      TXN.TRL_TSC_CODE = 47
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ISS_NAME = ''CBC''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND TXN.TRL_PAN != ''FD4CD08B482F7961EA66FBEA7C7583B541F82B3E6A915B4D7E9191D8FC5FB971''
      AND {Txn_Date}
GROUP BY
      TXN.TRL_AMT_TXN,
      TXN.TRL_ID
END
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY WHERE RED_NAME = 'Approved Pesonet Transactions As Transmitting Bank';

-- List of Moving Cash Transactions
i_BODY_QUERY := TO_CLOB('
SELECT
      ABR.ABR_CODE "BRANCH CODE",
      ABR.ABR_NAME "BRANCH NAME",
      SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
      AST.AST_ALO_LOCATION_ID "LOCATION",
      TXN.TRL_DATETIME_LOCAL_TXN "DATE",
      TXN.TRL_DATETIME_LOCAL_TXN "TIME",
      TXN.TRL_DEST_STAN "SEQ NUMBER",
      SUBSTR(TXN.TRL_RRN, 7, 6) "TRACE NUMBER",
      CASE WHEN TXN.TRL_TQU_ID = ''R'' THEN CTR.CTR_REV_MNEM ELSE CTR.CTR_MNEM END AS "TRAN MNEM",
      CMC.CMV_TXN_REF_NO "TRAN REF NO",
      CBA.CBA_MNEM "BANK MNEM",
      TXN.TRL_PAN "ATM CARD NUMBER",
      TXN.TRL_PAN_EKY_ID,
      TXN.TRL_ACCOUNT_1_ACN_ID "FROM ACCOUNT NO",
      TXN.TRL_ACCOUNT_1_ACN_ID_EKY_ID,
      CMC.CMV_RECV_MOBILE "TO MOBILE NO",
      TXN.TRL_AMT_TXN "AMOUNT",
      NVL(TXN.TRL_ISS_CHARGE_AMT, 0) "TRAN FEE",
      ''00 - Approved'' "COMMENT"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CBC_MOVING_CASH CMC ON TXN.TRL_RRN = CMC.CMv_TXN_REF_NO
WHERE
      TXN.TRL_TSC_CODE = 143
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
');

i_TRAILER_QUERY := TO_CLOB('
SELECT
       SUM(TXN.TRL_AMT_TXN) "AMOUNT",
       SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) "TRAN FEE"
FROM
      TRANSACTION_LOG TXN
      JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
      JOIN CBC_TRAN_CODE CTR ON TXN.TRL_TSC_CODE = CTR.CTR_CODE AND TXNC.TRL_ORIGIN_CHANNEL = CTR.CTR_CHANNEL
      JOIN CBC_BIN CBI ON TXNC.TRL_CARD_BIN = CBI.CBI_BIN
      JOIN CBC_BANK CBA ON CBI.CBI_CBA_ID = CBA.CBA_ID
      JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      LEFT JOIN CBC_MOVING_CASH CMC ON TXN.TRL_RRN = CMC.CMV_TXN_REF_NO
WHERE
      TXN.TRL_TSC_CODE = 143
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Branch_Code}
      AND {Txn_Date}
START SELECT
      CASE WHEN ATP.ATP_ISO_ID = 10 THEN COUNT(TXN.TRL_ID) ELSE 0 END AS "SA VOL",
      CASE WHEN ATP.ATP_ISO_ID = 10 THEN SUM(TXN.TRL_AMT_TXN) ELSE 0 END AS "SA AMT",
      CASE WHEN ATP.ATP_ISO_ID = 10 THEN SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) ELSE 0 END AS "SA FEE",
      CASE WHEN ATP.ATP_ISO_ID = 20 THEN COUNT(TXN.TRL_ID) ELSE 0 END AS "CA VOL",
      CASE WHEN ATP.ATP_ISO_ID = 20 THEN SUM(TXN.TRL_AMT_TXN) ELSE 0 END AS "CA AMT",
      CASE WHEN ATP.ATP_ISO_ID = 20 THEN SUM(NVL(TXN.TRL_ISS_CHARGE_AMT, 0)) ELSE 0 END AS "CA FEE"
FROM
      TRANSACTION_LOG TXN
      JOIN ACCOUNT_TYPE ATP ON TXN.TRL_ACCOUNT_TYPE_1_ATP_ID = ATP.ATP_ID
WHERE
      TXN.TRL_TSC_CODE = 143
      AND TXN.TRL_TQU_ID = ''F''
	  AND NVL(TXN.TRL_POST_COMPLETION_CODE, '' '') != ''R''
      AND TXN.TRL_ACTION_RESPONSE_CODE = 0
      AND {Txn_Date}
GROUP BY
      ATP.ATP_ISO_ID
END
');

UPDATE REPORT_DEFINITION SET RED_BODY_QUERY = i_BODY_QUERY, RED_TRAILER_QUERY = i_TRAILER_QUERY WHERE RED_NAME = 'List of Moving Cash Transactions';


-- Pending Approval Card Records
i_HEADER_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"RECORDS PENDING APPROVAL","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"97","pdfLength":"97","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":"<Report Id>"}]
');

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":2,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"CUSTOMER","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CUSTOMER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"FUNCTION/","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"FUNCTION/","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"8","fieldName":"MAKER ID","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"MAKER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":6,"sectionName":"10","fieldName":"STATUS","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"STATUS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":7,"sectionName":"11","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":8,"sectionName":"12","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":9,"sectionName":"13","fieldName":"NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":10,"sectionName":"14","fieldName":"DESCRIPTION","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":11,"sectionName":"15","fieldName":"ISSUE_DATE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"16","fieldName":"CRD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":13,"sectionName":"17","fieldName":"CLIENTNAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"18","fieldName":"FUNCTIONNAME","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"22","fieldName":"MAKER","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"24","fieldName":"STATUS","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]
');

UPDATE REPORT_DEFINITION SET RED_HEADER_FIELDS = i_HEADER_FIELD, RED_BODY_FIELDS = i_BODY_FIELD WHERE RED_NAME = 'Pending Approval Card Records';

-- Approved Rejected Card Records
i_HEADER_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"APPROVED/REJECTED CARD RECORDS","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"97","pdfLength":"97","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":"<Report Id>"}]
');

i_BODY_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"DATE/TIME","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"DATE/TIME","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";","fieldFormat":""},{"sequence":2,"sectionName":"2","fieldName":"CARD NO","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"CARD NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"CUSTOMER","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CUSTOMER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"FUNCTION/","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"FUNCTION/","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":5,"sectionName":"8","fieldName":"MAKER ID","csvTxtLength":"12","pdfLength":"12","fieldType":"String","defaultValue":"MAKER ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":6,"sectionName":"10","fieldName":"STATUS","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"STATUS","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":7,"sectionName":"11","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","firstField":true,"bodyHeader":true,"fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":8,"sectionName":"12","fieldName":"","csvTxtLength":"20","pdfLength":"20","fieldType":"String","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":9,"sectionName":"13","fieldName":"NAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":10,"sectionName":"14","fieldName":"DESCRIPTION","csvTxtLength":"25","pdfLength":"25","fieldType":"String","defaultValue":"DESCRIPTION","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"delimiter":";"},{"sequence":11,"sectionName":"15","fieldName":"ISSUE_DATE","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"16","fieldName":"CRD_NUMBER_ENC","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":true,"decryptionKey":"DCMS_ENCRYPTION_KEY","tagValue":null},{"sequence":13,"sectionName":"17","fieldName":"CLIENTNAME","csvTxtLength":"50","pdfLength":"50","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"18","fieldName":"FUNCTIONNAME","csvTxtLength":"25","pdfLength":"25","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"22","fieldName":"MAKER","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"24","fieldName":"STATUS","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]
');

i_TRAILER_FIELD := TO_CLOB('
[{"sequence":1,"sectionName":"1","fieldName":"TOTAL ITEM","csvTxtLength":"21","pdfLength":"21","defaultValue":"TOTAL NUMBER OF ITEMS:","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"7","pdfLength":"7","eol":true}]
');

i_BODY_QUERY := TO_CLOB('
SELECT
	''ACCOUNT DLINKING'' AS FUNCTIONNAME,
	SALD.ADL_CREATED_TS AS ISSUE_DATE,
	IC.CRD_NUMBER_ENC,
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
Where
	TO_DATE(Sald.Adl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between TO_DATE({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') AND TO_DATE({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	AND STS_ID IN (88, 90)
	AND SALD.ADL_INS_ID = 1
UNION ALL
Select
	''Request For Add On Card'' As FUNCTIONNAME,
	Rac.Aoc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Rac.Aoc_Created_By As Maker,
	Rac.Aoc_Updated_By As Checker,
	Rac.Aoc_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Add_On_Card@DCMSUAT Rac
	Join DCMSADM.Issuance_Card@DCMSUAT Ic On Rac.Aoc_Clt_Id = Ic.Crd_Id
	Join DCMSADM.Master_Status@DCMSUAT Ms On Rac.Aoc_Sts_Id=Ms.Sts_Id
Where
	To_Date(Rac.Aoc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Rac.Aoc_Ins_Id = 1
UNION ALL
Select
	''ACCOUNT LINKING'' As FUNCTIONNAME,
	Acl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Sal.Acl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sal.Acl_Ins_Id = 1
Union All
Select
	''Card Activation''As Functionname,
	Sac.Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Sac.Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'')  Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date},''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sac.Caa_Ins_Id = 1
UNION ALL
Select
	''CARD RENEWAL'' As Functionname,
	Scr.Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Scr.Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scr.Crn_Ins_Id = 1
Union All
Select
	''CASH CARD ACTIVATION'' Functionname,
	Scca.Cc_Caa_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC As Cardno,
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
Where
	To_Date(Scca.Cc_Caa_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scca.Cc_Caa_Ins_Id = 1
Union All
Select
	''CASH CARD RENEWAL'' Functionname,
	Sccr.Cc_Crn_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC ,
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
Where
	To_Date(Sccr.Cc_Crn_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sccr.Cc_Crn_Ins_Id = 1
UNION ALL
Select
	''CASH DEHOTLIST'' Functionname,
	Sccd.Cc_Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Sccd.Cc_Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sccd.Cc_Dhl_Ins_Id = 1
Union All
Select
	''HOTLIST'' Functionname,
	Scch.Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Scch.Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scch.Hot_Ins_id = 1
Union All
Select
	''CASH CARD RESET PIN'' Functionname,
	Sccrp.Cc_Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Sccrp.Cc_Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sccrp.Cc_Rpc_Ins_id = 1
UNION ALL
Select
	''CASH CARD HOTLIST'' Functionname,
	Scht.Cc_Hot_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Scht.Cc_Hot_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scht.Cc_Hot_Ins_Id = 1
Union All
Select
	''REPIN'' Functionname,
	Sdrp.Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Sdrp.Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sdrp.Rep_Ins_Id = 1
UNION ALL
Select
	''RESET PIN COUNTER'' Functionname,
	Srp.Rpc_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Srp.Rpc_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Srp.Rpc_Ins_Id = 1
UNION ALL
Select
	''STOP CARD RENEWAL'' Functionname,
	Scrn.SRN_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Scrn.SRN_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scrn.Srn_Ins_Id = 1
UNION ALL
Select
	''Default Account Change'' As Functionnamesal,
	DAR_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Dac.DAR_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Dac.Dar_Ins_Id = 1
UNION ALL
Select
	''Transaction Limit Update Cash card'' As FunctionName,
	Scctlu.CC_Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Scctlu.CC_TRM_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Scctlu.Cc_Trm_Ins_Id = 1
UNION ALL
Select
	''Reset pin Cash card'' As Functionname,
	Srp.Cc_Rep_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Srp.Cc_Rep_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Srp.Cc_Rep_Ins_Id = 1
UNION ALL
Select
	''Address Update'' As Functionname,
	Sarm.Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sarm.Aur_Created_By As Maker,
	Sarm.Aur_Updated_By As Checker,
	Sarm.Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Address_Update_Req_Map@DCMSUAT Sarm
	Join DCMSADM.ISSUANCE_CARD@DCMSUAT IC ON Sarm.AUR_CLT_ID = IC.CRD_ID
	JOIN DCMSADM.MASTER_STATUS@DCMSUAT MS ON Sarm.AUR_STS_ID=MS.STS_ID
WHERE
	To_Date(Sarm.Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sarm.Aur_Ins_Id = 1
UNION ALL
Select
	''Cash Card Address Update'' As Functionname,
	Sarcm.Cc_Aur_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
	Sarcm.Cc_Aur_Created_By As Maker,
	Sarcm.Cc_Aur_Updated_By As Checker,
	Sarcm.Cc_Aur_Remarks As Remarks,
	Ic.Crd_Cardholder_Name As Clientname,
	Ms.Sts_Name As Status
From
	DCMSADM.Support_Cc_Add_Update_Req_Map@DCMSUAT Sarcm
	Join DCMSADM.ISSUANCE_CARD@DCMSUAT IC ON Sarcm.CC_AUR_CLT_ID = IC.CRD_ID
	JOIN DCMSADM.MASTER_STATUS@DCMSUAT MS ON Sarcm.CC_Aur_STS_ID=MS.STS_ID
WHERE
	To_Date(Sarcm.CC_Aur_Created_Ts ,''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sarcm.Cc_Aur_Ins_Id = 1
UNION ALL
Select
	''Dehotlist'' As Functionname,
	Sdhl.Dhl_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Sdhl.Dhl_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Sdhl.Dhl_Ins_Id = 1
UNION ALL
Select
	''Transaction Limit Update'' As FunctionName,
	Stlu.Trm_Created_Ts As Issue_Date,
	Ic.CRD_NUMBER_ENC,
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
Where
	To_Date(Stlu.Trm_Created_Ts, ''YYYY-MM-DD HH24:MI:SS'') Between To_Date({From_Date}, ''YYYY-MM-DD HH24:MI:SS'') And To_Date({To_Date}, ''YYYY-MM-DD HH24:MI:SS'')
	And Sts_Id IN (88, 90)
	And Stlu.Trm_Ins_Id = 1
');

INSERT INTO REPORT_DEFINITION (RED_ID, RED_REC_ID, RED_NAME, RED_DESCRIPTION, RED_FILE_NAME_PREFIX, RED_FILE_FORMAT, RED_FILE_LOCATION, RED_PROCESSING_CLASS, RED_HEADER_FIELDS, RED_BODY_FIELDS, RED_TRAILER_FIELDS, RED_BODY_QUERY, RED_TRAILER_QUERY, RED_FREQUENCY, CREATED_BY, CREATED_DATE, RED_BRANCH_FLAG, RED_DAILY_SCHEDULE_TIME, RED_INS_ID) VALUES (
	(select max(red_id)+1 from report_definition), 
	(select REC_ID from REPORT_CATEGORY where REC_NAME = 'DCMS Reports'), 
	'Approved Rejected Card Records', 
	'Lists card records processed that are approved or rejected', 
	'Approved Rejected Card Records', 
	'PDF,CSV,', 
	'/tmp/Reporting/reports/DCMS Reports/', 
	'my.com.mandrill.base.reporting.dcmsAppRejPendCard.DCMSApproveRejectPendingCardReport', 
	i_HEADER_FIELD, 
	i_BODY_FIELD, 
	i_TRAILER_FIELD, 
	i_BODY_QUERY, 
	null, 
	'Daily', 
	'mandrill', 
	CURRENT_TIMESTAMP, 
	'master', 
	CURRENT_TIMESTAMP, 
	(select id  from institution  where name = 'ChinaBank (CBC)'));


END;
/