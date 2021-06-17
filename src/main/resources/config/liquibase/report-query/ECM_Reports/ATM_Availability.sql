-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-640 	17-JUN-2021		NY		Initial from UAT env

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- ATM Availability
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"ATM CENTER","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"ATM CENTER","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"CBC ATM AVAILABILITY REPORT (INTERNAL)","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"CBC ATM AVAILABILITY REPORT (INTERNAL)","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"FROM  :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"FROM  :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"From Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"Defect","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Defect","leftJustified":true,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"5%","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"5%","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","fieldName":"TO    :","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TO    :","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"Report To Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":",","fieldFormat":"MM/dd/yyyy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"Bancnet Standard","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"Bancnet Standard","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"95%","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"95%","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"REGION","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"BRANCH CODE","firstField":false,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"TERMINAL NO.","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"TERMINAL NO.","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"LOCATION","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"5","fieldName":"PERCENT AVAILABLE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"PERCENT AVAILABLE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"6","fieldName":"% UNAVAILABLE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"% UNAVAILABLE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"7","fieldName":"STANDARD","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","defaultValue":"STANDARD","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true},{"sequence":8,"sectionName":"8","fieldName":"REGION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"9","fieldName":"BRANCH CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"10","fieldName":"TERMINAL","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","fieldName":"LOCATION","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"12","fieldName":"AVAILABLE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"13","fieldName":"UNAVAILABLE","csvTxtLength":"10","pdfLength":"10","fieldType":"Decimal","delimiter":",","fieldFormat":"0.00","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"14","fieldName":"STANDARD","csvTxtLength":"10","pdfLength":"10","fieldType":"Number","delimiter":",","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_TRAILER_FIELDS := TO_CLOB('[]');
	i_BODY_QUERY := TO_CLOB('				
	with nonExistsStation as (
  select ash_ast_id, ash_operation_status,
    ROW_NUMBER() over (partition by ash_ast_id order by ash_timestamp DESC) as rn
  from atm_status_history 
  where ash_timestamp < TO_DATE({From_Date}, ''YYYYMMDD HH24:MI:SS'')
)
SELECT
    AST.AST_ARE_NAME "REGION",
    ABR.ABR_CODE "BRANCH CODE",
    SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
    AST.AST_ALO_LOCATION_ID "LOCATION",
    AST.AST_ID "STATION ID",
    case when NES.ASH_OPERATION_STATUS = ''In service'' then 0 else 100 end "UNAVAILABLE",
    case when NES.ASH_OPERATION_STATUS = ''In service'' then 100 else 0 end  "AVAILABLE",
    case when NES.ASH_OPERATION_STATUS = ''In service'' then ''1'' else ''0'' end "STANDARD"
FROM
    ATM_STATIONS AST
    JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
    LEFT JOIN nonExistsStation NES on AST.AST_ID = NES.ASH_AST_ID and NES.RN = 1
WHERE
	AST_ALO_LOCATION_ID NOT LIKE ({V_IE_Iss_Name} || ''%'')
	AND AST.AST_ACO_ID NOT IN (1722,1723)
    AND AST_ID NOT IN (
      select distinct(ATD_AST_ID) from ATM_DOWNTIME ATD WHERE {Txn_Date}
    )
UNION 
(SELECT
     AST.AST_ARE_NAME "REGION",
     ABR.ABR_CODE "BRANCH CODE",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     AST.AST_ID "STATION ID",
     round(SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / {Total_Day} * 100), 2) "UNAVAILABLE",
     NVL(round(100 - (SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / {Total_Day} * 100)), 2) , 100) "AVAILABLE",    
     CASE WHEN SUM((cast(atd_end_timestamp as DATE) - cast (atd_start_timestamp as DATE)) * 86400 / {Total_Day} * 100) < 5 THEN ''1'' ELSE ''0'' END "STANDARD"
FROM
      ATM_STATIONS AST
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN ATM_DOWNTIME ATD ON AST.AST_ID = ATD_AST_ID AND {Txn_Date}
WHERE
	AST_ALO_LOCATION_ID NOT LIKE ({V_IE_Iss_Name} || ''%'')
    AND AST.AST_ID in (select distinct(ASH_AST_ID) from ATM_STATUS_HISTORY) 
GROUP BY
      AST.AST_ARE_NAME,
      ABR.ABR_CODE,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID,
      AST.AST_ID
)
ORDER BY
      REGION  ASC,
      "BRANCH CODE" ASC,
      TERMINAL ASC,
      LOCATION ASC
	');
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'ATM Availability';
	
END;
/