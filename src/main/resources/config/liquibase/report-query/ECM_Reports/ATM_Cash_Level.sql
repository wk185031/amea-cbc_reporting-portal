-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-640 	17-JUN-2021		NY		Initial from UAT env
-- CBCAXUPISSLOG-640	17-JUN-2021		NY		Use device_estate_owner table to filter CBC/CBS atm stations
-- JIRA 841				10-AUG-2021		WY		Maintain uniform date
-- JIRA 806				21-OCT-2021		WY		Fix divisor zero error when 

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- ATM Cash Level
	i_HEADER_FIELDS := TO_CLOB('[]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Region","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Region","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":2,"sectionName":"2","fieldName":"Terminal ID","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Terminal ID","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":3,"sectionName":"3","fieldName":"Location","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Location","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":4,"sectionName":"4","fieldName":"Date of Loading","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Date of Loading","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":5,"sectionName":"5","fieldName":"Load Amount (500)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Load Amount (500)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":6,"sectionName":"6","fieldName":"Load Amount (100)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Load Amount (100)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"Load Amount (1000)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Load Amount (1000)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":8,"sectionName":"39","fieldName":"Load Amount (200)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Load Amount (200)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"8","fieldName":"Total Cash Loaded","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Total Cash Loaded","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":10,"sectionName":"9","fieldName":"Current Cash Level (500)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Current Cash Level (500)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":11,"sectionName":"10","fieldName":"Current Cash Level (100)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Current Cash Level (100)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":12,"sectionName":"11","fieldName":"Current Cash Level (1000)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Current Cash Level (1000)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":13,"sectionName":"40","fieldName":"Current Cash Level (200)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Current Cash Level (200)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"12","fieldName":"Cash Level (500)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cash Level (500)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":15,"sectionName":"13","fieldName":"Cash Level (100)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cash Level (100)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":16,"sectionName":"14","fieldName":"Cash Level (1000)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cash Level (1000)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":17,"sectionName":"44","fieldName":"Cash Level (200)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Cash Level (200)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"15","fieldName":"Total (PHP)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Total (PHP)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":19,"sectionName":"16","fieldName":"LOAD %","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"LOAD %","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":20,"sectionName":"17","fieldName":"Classification","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Classification","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":21,"sectionName":"18","fieldName":"Cash Status","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Cash Status","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":22,"sectionName":"46","fieldName":"Deposit Amount (500)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Deposit Amount (500)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"48","fieldName":"Deposit Amount (100)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Deposit Amount (100)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"47","fieldName":"Deposit Amount (1000)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Deposit Amount (1000)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"49","fieldName":"Deposit Amount (200)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Deposit Amount (200)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"50","fieldName":"Total Cash Deposited","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Total Deposits (PHP)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"41","fieldName":"Deposit Position (500)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Deposit (500)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":28,"sectionName":"42","fieldName":"Deposit Position (100)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Deposit (100)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":29,"sectionName":"43","fieldName":"Deposit Position (1000)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Deposit (1000)","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"45","fieldName":"Deposit Position (200)","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Deposit Position (200)","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":31,"sectionName":"19","fieldName":"Ops Status","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","defaultValue":"Ops Status","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":32,"sectionName":"20","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":33,"sectionName":"21","fieldName":"TERMINAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":34,"sectionName":"22","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":35,"sectionName":"23","fieldName":"DATE OF LOADING","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":36,"sectionName":"24","fieldName":"LOAD 500","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":37,"sectionName":"25","fieldName":"LOAD 100","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":38,"sectionName":"26","fieldName":"LOAD 1000","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":39,"sectionName":"51","fieldName":"LOAD 200","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":40,"sectionName":"27","fieldName":"TOTAL CASH LOADED","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":41,"sectionName":"28","fieldName":"CURRENT 500 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":42,"sectionName":"29","fieldName":"CURRENT 100 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":43,"sectionName":"30","fieldName":"CURRENT 1000 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":44,"sectionName":"52","fieldName":"CURRENT 200 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":45,"sectionName":"31","fieldName":"CURRENT 500 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":46,"sectionName":"32","fieldName":"CURRENT 100 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":47,"sectionName":"33","fieldName":"CURRENT 1000 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":48,"sectionName":"53","fieldName":"CURRENT 200 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":49,"sectionName":"34","fieldName":"TOTAL CASH VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":50,"sectionName":"35","fieldName":"LOAD PERCENTAGE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":51,"sectionName":"36","fieldName":"CLASSIFICATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":52,"sectionName":"37","fieldName":"CASH STATUS","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null},{"sequence":53,"sectionName":"54","fieldName":"DEPOSIT 500 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":54,"sectionName":"55","fieldName":"DEPOSIT 100 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":55,"sectionName":"56","fieldName":"DEPOSIT 1000 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":56,"sectionName":"57","fieldName":"DEPOSIT 200 VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":57,"sectionName":"58","fieldName":"TOTAL DEPOSIT VALUE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":58,"sectionName":"59","fieldName":"DEPOSIT 500 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":59,"sectionName":"60","fieldName":"DEPOSIT 100 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":60,"sectionName":"61","fieldName":"DEPOSIT 1000 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":61,"sectionName":"62","fieldName":"DEPOSIT 200 POS","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":62,"sectionName":"38","fieldName":"OPS STATUS","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null}]');
	i_TRAILER_FIELDS := TO_CLOB('[]');
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
    CASE WHEN DVT.LOAD_100 <> 0 and DVT.LOAD_200 <> 0 and  DVT.LOAD_500 <> 0 and DVT.LOAD_1000 <> 0
    THEN round((ADS.POS_100 * 100 + ADS.POS_200 * 200 + ADS.POS_500 * 500 + ADS.POS_1000 * 1000)/
    (DVT.LOAD_100 * 100 + DVT.LOAD_200 * 200 + DVT.LOAD_500 * 500 + DVT.LOAD_1000 * 1000) * 100, 2)
    ELSE round(ADS.POS_100 * 100 + ADS.POS_200 * 200 + ADS.POS_500 * 500 + ADS.POS_1000 * 1000)
    END "LOAD PERCENTAGE",
    CASE WHEN ATS.ATS_CASH_DISPENSE_POSSIBLE = ''Yes'' THEN ''CASH LEVEL - GOOD'' ELSE ''FOR LOADING'' END AS "CASH STATUS",
    NVL(ATNC.DPOS_100,0) "DEPOSIT 100 POS",
    NVL(ATNC.DPOS_200,0) "DEPOSIT 200 POS",
    NVL(ATNC.DPOS_500,0) "DEPOSIT 500 POS",
    NVL(ATNC.DPOS_1000,0) "DEPOSIT 1000 POS",
    NVL(ATNC.DPOS_100,0) * 100 "DEPOSIT 100 VALUE",
    NVL(ATNC.DPOS_200,0) * 200 "DEPOSIT 200 VALUE",
    NVL(ATNC.DPOS_500,0) * 500 "DEPOSIT 500 VALUE",
    NVL(ATNC.DPOS_1000,0) * 1000 "DEPOSIT 1000 VALUE",   
    (NVL(ATNC.DPOS_100,0) * 100) + (NVL(ATNC.DPOS_200,0) * 200) + (NVL(ATNC.DPOS_500,0) * 500) + (NVL(ATNC.DPOS_1000,0) * 1000) "TOTAL DEPOSIT VALUE",
    ATS.ATS_OPERATION_STATUS "OPS STATUS"
from {AUTH_Schema}.ATM_STATIONS@{DB_LINK_AUTH} AST 
join {AUTH_Schema}.DEVICE_ESTATE_OWNER@{DB_LINK_AUTH} DEO ON AST.AST_DEO_ID = DEO.DEO_ID
join {AUTH_Schema}.ATM_STATUS@{DB_LINK_AUTH} ATS ON AST.AST_ID = ATS.ATS_AST_ID 
join (select ATO_AST_ID, L_DATE LOAD_DATE, sum(L_100) LOAD_100, sum(L_200) LOAD_200, sum(L_500) LOAD_500, sum(L_1000) LOAD_1000, 
  ROW_NUMBER() OVER (PARTITION BY ATO_AST_ID  ORDER BY L_DATE DESC) rn from 
  (select ATO_AST_ID, TRUNC(ATO_TIMESTAMP) L_DATE, 
    CASE WHEN ATO_DENOMINATION = 100 THEN ATO_COUNTER ELSE 0 END L_100,
    CASE WHEN ATO_DENOMINATION = 200 THEN ATO_COUNTER ELSE 0 END L_200,
    CASE WHEN ATO_DENOMINATION = 500 THEN ATO_COUNTER ELSE 0 END L_500,
    CASE WHEN ATO_DENOMINATION = 1000 THEN ATO_COUNTER ELSE 0 END L_1000
  from {AUTH_Schema}.ATM_DEVICE_TOTALS@{DB_LINK_AUTH}  
  where trim(ato_event) in (''Replenishment load'',''Replenishment reject'',''Replenishment load (F)'',''Replenishment reject (F)'')
  )
  group by ATO_AST_ID, L_DATE
) DVT on DVT.ATO_AST_ID = AST.AST_ID
join (select ADS_AST_ID, sum(CURR_100) POS_100, sum(CURR_200) POS_200, sum(CURR_500) POS_500, sum(CURR_1000) POS_1000 from (
  select ADS_AST_ID,
  CASE WHEN ADS_DEVICE_DESCRIPTION = ''100 (Currency PHP)'' THEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) ELSE 0 END CURR_100,
  CASE WHEN ADS_DEVICE_DESCRIPTION = ''200 (Currency PHP)'' THEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) ELSE 0 END CURR_200,
  CASE WHEN ADS_DEVICE_DESCRIPTION = ''500 (Currency PHP)'' THEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) ELSE 0 END CURR_500,
  CASE WHEN ADS_DEVICE_DESCRIPTION = ''1000 (Currency PHP)'' THEN (ADS_DEVICE_ADDITIONAL_DATA - ADS_DEVICE_DATA) ELSE 0 END CURR_1000
  from {AUTH_Schema}.ATM_DEVICE_STATUS@{DB_LINK_AUTH} 
  where ADS_DEVICE_ID in (''Cassette 1'',''Cassette 2'',''Cassette 3'',''Cassette 4''))
group by ADS_AST_ID 
) ADS on ADS_AST_ID = AST.AST_ID 
left join (
  select ADS_AST_ID, sum(D_500) DPOS_500, sum(D_100) DPOS_100, sum(D_1000) DPOS_1000, sum(D_200) DPOS_200 from (
    select ADS_AST_ID,
      CASE WHEN ATCV_NOTE_TYPE = ''05'' THEN ATCV_NOTE_COUNT ELSE 0 END D_500,
      CASE WHEN ATCV_NOTE_TYPE = ''06'' THEN ATCV_NOTE_COUNT ELSE 0 END D_100,
      CASE WHEN ATCV_NOTE_TYPE = ''07'' THEN ATCV_NOTE_COUNT ELSE 0 END D_1000,
      CASE WHEN ATCV_NOTE_TYPE = ''08'' THEN ATCV_NOTE_COUNT ELSE 0 END D_200
    from {AUTH_Schema}.ATM_DEVICE_STATUS@{DB_LINK_AUTH}
    join {AUTH_Schema}.ATM_SUMMARY_COUNTERS@{DB_LINK_AUTH} on ADS_DEVICE_ID=''Bunch Note Acceptor'' and ADS_ATNC_ID=ATNC_ID
    join {AUTH_Schema}.ATM_SUMMARY_VALUES@{DB_LINK_AUTH} on ATNC_ID = ATCV_ATNC_ID 
  )
  group by ADS_AST_ID 
) ATNC on ATNC.ADS_AST_ID = AST.AST_ID
where 
	DEO.DEO_NAME = {V_Deo_Name}
	AND DVT.rn = 1
ORDER BY 
    "REGION" ASC,
    "TERMINAL" ASC,
    "LOCATION" ASC,
    "DATE OF LOADING" ASC
) MAIN
	');
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'ATM Cash Level';
	
END;
/