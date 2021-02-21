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

END;
/