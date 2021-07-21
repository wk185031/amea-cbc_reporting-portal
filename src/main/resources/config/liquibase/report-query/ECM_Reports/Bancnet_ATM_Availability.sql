-- Tracking				Date			Name	Description
-- Revise report		19-JULY-2021	WY		Revise report according to the spec

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 


	i_BODY_QUERY := TO_CLOB('				
	SELECT
     ABR.ABR_CODE "BRANCH CODE",
     SUBSTR(AST.AST_TERMINAL_ID, -4) "TERMINAL",
     AST.AST_ALO_LOCATION_ID "LOCATION",
     '''' "HOUR",
     '''' "MINUTE",
     SUM(TO_CHAR(ASH_TIMESTAMP,''HH24'')) AS "OUTAGE HOUR",
     SUM(TO_CHAR(ASH_TIMESTAMP,''MI'')) AS "OUTAGE MINUTE",
     '''' "PERCENTATE"
FROM
      ATM_STATIONS AST
      JOIN ATM_BRANCHES ABR ON AST.AST_ABR_ID = ABR.ABR_ID
      JOIN ATM_STATUS_HISTORY ASH ON AST.AST_ID = ASH.ASH_AST_ID
	  JOIN DEVICE_ESTATE_OWNER DEO ON AST.AST_DEO_ID = DEO.DEO_ID
WHERE
      ASH.ASH_COMM_STATUS = ''Down''
      AND ASH.ASH_SERVICE_STATE_REASON IN (''Comms Event'', ''In supervisor mode'', ''Power fail'',
      ''Card reader faulty'', ''Cash dispenser faulty'', ''Encryptor faulty'', ''Cash dispenser faulty'',
      ''Cash availability status change'', ''Operator request'')
      AND {Txn_Date}
	  AND DEO.DEO_NAME = {V_Deo_Name}
GROUP BY
      ABR.ABR_CODE,
      AST.AST_TERMINAL_ID,
      AST.AST_ALO_LOCATION_ID
ORDER BY
      ABR.ABR_CODE ASC,
      AST.AST_TERMINAL_ID ASC,
      AST.AST_ALO_LOCATION_ID ASC
	');
	
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_QUERY = i_BODY_QUERY
	where RED_NAME = 'BancNet ATM Availability';
	
END;
/