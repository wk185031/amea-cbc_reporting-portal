-- Tracking				Date			Name	Description
-- Revise report		19-JULY-2021	WY		Revise report header data

DECLARE
	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;
   
BEGIN 

	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"TERMINALID","csvTxtLength":"50","pdfLength":"","fieldType":"String","delimiter":";","firstField":true,"bodyHeader":true,"defaultValue":"TERMINALID"},{"sequence":2,"sectionName":"2","fieldName":"IPADDRESS","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"IPADDRESS"},{"sequence":3,"sectionName":"3","fieldName":"IAP","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"IAP"},{"sequence":4,"sectionName":"4","fieldName":"LASTCONNECTED","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"LASTCONNECTED"},{"sequence":5,"sectionName":"5","fieldName":"REGION","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"REGION"},{"sequence":6,"sectionName":"6","fieldName":"Area","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"Area"},{"sequence":7,"sectionName":"7","fieldName":"Type","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"Type"},{"sequence":8,"sectionName":"8","fieldName":"Classification","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"Classification"},{"sequence":9,"sectionName":"9","fieldName":"LOCATION","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"LOCATION"},{"sequence":10,"sectionName":"10","fieldName":"CASSETTEPROFILE","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"CASSETTEPROFILE"},{"sequence":11,"sectionName":"11","fieldName":"NOTEMIX","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"NOTEMIX"},{"sequence":12,"sectionName":"12","fieldName":"REQUIREDSTATE","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"REQUIREDSTATE"},{"sequence":13,"sectionName":"13","fieldName":"ENCRYPTORSERIAL","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"ENCRYPTORSERIAL"},{"sequence":14,"sectionName":"14","fieldName":"ACTIVE","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"ACTIVE"},{"sequence":15,"sectionName":"15","fieldName":"LOGGING","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"LOGGING"},{"sequence":16,"sectionName":"16","fieldName":"USECONFIGURATIONS","csvTxtLength":"50","fieldType":"String","delimiter":";","bodyHeader":true,"defaultValue":"USECONFIGURATIONS","eol":true},{"sequence":17,"sectionName":"17","fieldName":"TERMINALID","csvTxtLength":"50","fieldType":"String","delimiter":";","firstField":true},{"sequence":18,"sectionName":"18","fieldName":"IPADDRESS","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":19,"sectionName":"19","fieldName":"IAP","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":20,"sectionName":"20","fieldName":"LASTCONNECTED","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":21,"sectionName":"21","fieldName":"REGION","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":22,"sectionName":"22","fieldName":"AREA","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":23,"sectionName":"23","fieldName":"Type","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":24,"sectionName":"24","fieldName":"Classification","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":25,"sectionName":"25","fieldName":"LOCATION","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":26,"sectionName":"26","fieldName":"CASSETTEPROFILE","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":27,"sectionName":"27","fieldName":"NOTEMIX","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":28,"sectionName":"28","fieldName":"REQUIREDSTATE","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":29,"sectionName":"29","fieldName":"ENCRYPTORSERIAL","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":30,"sectionName":"30","fieldName":"ACTIVE","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":31,"sectionName":"31","fieldName":"LOGGING","csvTxtLength":"50","fieldType":"String","delimiter":";"},{"sequence":32,"sectionName":"32","fieldName":"USECONFIGURATIONS","csvTxtLength":"50","fieldType":"String","delimiter":";","eol":true}]');
	
	i_BODY_QUERY := TO_CLOB('
	SELECT AST_TERMINAL_ID AS TERMINALID,
	AST_IP_ADDRESS AS IPADDRESS,
	ATS_IAP_NAME AS IAP,
	AST_LAST_UPDATE_TS AS LASTCONNECTED,
	AST_ARE_NAME AS REGION,
	AST_ALO_LOCATION_ID AS LOCATION,
	CASSETTE.ACP_CASS_TYPE AS CASSETTEPROFILE,
	AST_NOTE_MIX_CONSTANT AS NOTEMIX,
	AST_REQUIRED_STATE AS REQUIREDSTATE,
	AST_HKS_NAME AS ENCRYPTORSERIAL,
	AST_ACTIVE AS ACTIVE, 
	AST_LOGGING AS LOGGING,
	conf.ACO_NAME AS USECONFIGURATIONS
	FROM ATM_STATIONS station
	JOIN ATM_STATUS status on station.ast_id = status.ATS_AST_ID
	JOIN {AUTH_Schema}.ATM_CONFIGURATION_ITEMS@{DB_LINK_AUTH} items on items.ACI_ID = AST_ACP_ACI_ID
	JOIN {AUTH_Schema}.ATM_CASSETTE_PROFILES@{DB_LINK_AUTH} cassette on cassette.ACP_ACI_ID = items.ACI_ID
	JOIN {AUTH_Schema}.ATM_CONFIGURATIONS@{DB_LINK_AUTH} conf on conf.ACO_ID = station.AST_ACO_ID
	JOIN DEVICE_ESTATE_OWNER DEO ON station.AST_DEO_ID = DEO.DEO_ID
	WHERE DEO.DEO_NAME = {V_Deo_Name}
	ORDER BY station.AST_TERMINAL_ID');
	
	UPDATE REPORT_DEFINITION set 
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY
	where RED_NAME = 'ATM Stations';
	
END;
/