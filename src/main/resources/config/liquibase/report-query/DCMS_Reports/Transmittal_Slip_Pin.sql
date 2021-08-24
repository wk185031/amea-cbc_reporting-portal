-- Tracking				Date			Name	Description
-- Rel-20210812			12-AUG-2021		KW		Revise DCMS
-- Rel-20210823			21-AUG-2021		KW		Fix decryption and enhance sql
-- Rel-20210823			21-AUG-2021		GS		Revise the sql and the format of report header

DECLARE
	i_REPORT_NAME VARCHAR2(100) := 'Transmittal Slip for new PINs';
	i_FILE_FORMAT VARCHAR2(20) := 'PDF,TXT,';
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","fieldType":"Number","delimiter":"","defaultValue":"0010","leftJustified":true,"padFieldLength":0,"firstField":true,"pdfLength":"6"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"CHINA BANK CORPORATION","eol":false,"leftJustified":true,"padFieldLength":0,"pdfLength":"57"},{"sequence":3,"sectionName":"3","fieldName":"File Name","csvTxtLength":"55","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TRANSMITTAL SLIP - NEW PINS","eol":false,"leftJustified":true,"padFieldLength":0,"pdfLength":"55"},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"fieldName":"PAGE","defaultValue":"PAGE","csvTxtLength":"5","pdfLength":"5"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"Number","delimiter":"","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","csvTxtLength":"122","pdfLength":"122","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":"","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"eol":true},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"TO","csvTxtLength":"4","pdfLength":"4","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TO:","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"BRANCH NAME","csvTxtLength":"30","pdfLength":"30","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"BRANCH CODE","csvTxtLength":"114","pdfLength":"114","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","firstField":false,"eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"FR","csvTxtLength":"125","pdfLength":"125","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"FR: EDP","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Date","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"DATE","leftJustified":true,"padFieldLength":0,"eol":false},{"sequence":19,"sectionName":"19","fieldName":"As of Date Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"eol":true},{"sequence":20,"sectionName":"20","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"defaultValue":"","fieldName":""},{"sequence":21,"sectionName":"21","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"defaultValue":"","fieldName":""},{"sequence":22,"sectionName":"22","fieldName":"ACK 1","csvTxtLength":"108","pdfLength":"108","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"PLEASE ACKNOWLEDGE RECEIPT OF THE FOLLOWING PIN MAILERS","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":23,"sectionName":"23","fieldName":"ACK 2","csvTxtLength":"96","pdfLength":"96","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"AND RETURN DUPLICATE COPY TO US","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CARD PRODUCT","csvTxtLength":"20","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"20"},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","csvTxtLength":"6","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"6","eol":true},{"sequence":3,"sectionName":"3","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Account Name","csvTxtLength":"74","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"ACCOUNT NAME","bodyHeader":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"firstField":true,"pdfLength":"74"},{"sequence":5,"sectionName":"5","fieldName":"Remarks","csvTxtLength":"30","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"REMARKS","bodyHeader":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true,"pdfLength":"30"},{"sequence":6,"sectionName":"6","fieldName":"ACCOUNT_NAME","csvTxtLength":"74","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"firstField":true,"pdfLength":"74","decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"REMARKS","csvTxtLength":"30","fieldType":"String","delimiter":"","fieldFormat":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true,"pdfLength":"30"},{"sequence":8,"sectionName":"8","fieldName":"Space","fieldType":"String","delimiter":"","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"100","pdfLength":"100","firstField":true}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Total For Branch","csvTxtLength":"17","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TOTAL FOR BRANCH ","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"17"},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"20","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"20"},{"sequence":3,"sectionName":"7","fieldName":"Colon","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":": ","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"3","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"10","eol":true},{"sequence":5,"sectionName":"4","fieldName":"Prepared By","csvTxtLength":"40","fieldType":"String","delimiter":"","defaultValue":"PREPARED BY:","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"pdfLength":"40"},{"sequence":6,"sectionName":"6","fieldName":"Date Received","csvTxtLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"DATE RECEIVED:","leftJustified":false,"padFieldLength":0,"decrypt":false,"pdfLength":"40"},{"sequence":7,"sectionName":"5","fieldName":"Received By","csvTxtLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"RECEIVED BY:","leftJustified":false,"padFieldLength":0,"decrypt":false,"pdfLength":"40","eol":true}]');
	
-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","fieldType":"Number","delimiter":"","defaultValue":"0112","leftJustified":true,"padFieldLength":0,"firstField":true,"pdfLength":"6"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"57","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"CHINA BANK SAVINGS","eol":false,"leftJustified":true,"padFieldLength":0,"pdfLength":"57"},{"sequence":3,"sectionName":"3","fieldName":"File Name","csvTxtLength":"55","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TRANSMITTAL SLIP - NEW PINS","eol":false,"leftJustified":true,"padFieldLength":0,"pdfLength":"55"},{"sequence":4,"sectionName":"4","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"fieldName":"PAGE","defaultValue":"PAGE","csvTxtLength":"5","pdfLength":"5"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"Number","delimiter":"","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","csvTxtLength":"122","pdfLength":"122","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"9","fieldName":"RunDate","csvTxtLength":"11","pdfLength":"11","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":"","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"eol":true},{"sequence":13,"sectionName":"13","fieldName":"","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":14,"sectionName":"14","fieldName":"TO","csvTxtLength":"4","pdfLength":"4","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TO:","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":15,"sectionName":"15","fieldName":"BRANCH NAME","csvTxtLength":"30","pdfLength":"30","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","firstField":false,"eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","fieldName":"BRANCH CODE","csvTxtLength":"114","pdfLength":"114","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","firstField":false,"eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"FR","csvTxtLength":"125","pdfLength":"125","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"FR: EDP","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Date","csvTxtLength":"8","pdfLength":"8","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"DATE","leftJustified":true,"padFieldLength":0,"eol":false},{"sequence":19,"sectionName":"19","fieldName":"As of Date Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"eol":true},{"sequence":20,"sectionName":"20","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"defaultValue":"","fieldName":""},{"sequence":21,"sectionName":"21","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"defaultValue":"","fieldName":""},{"sequence":22,"sectionName":"22","fieldName":"ACK 1","csvTxtLength":"108","pdfLength":"108","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"PLEASE ACKNOWLEDGE RECEIPT OF THE FOLLOWING PIN MAILERS","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":23,"sectionName":"23","fieldName":"ACK 2","csvTxtLength":"96","pdfLength":"96","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"AND RETURN DUPLICATE COPY TO US","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"CARD PRODUCT","csvTxtLength":"20","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"20"},{"sequence":2,"sectionName":"2","fieldName":"TOTAL","csvTxtLength":"6","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"6","eol":true},{"sequence":3,"sectionName":"3","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":"","fieldFormat":"","firstField":true,"eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"Account Name","csvTxtLength":"74","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"ACCOUNT NAME","bodyHeader":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"firstField":true,"pdfLength":"74"},{"sequence":5,"sectionName":"5","fieldName":"Remarks","csvTxtLength":"30","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"REMARKS","bodyHeader":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true,"pdfLength":"30"},{"sequence":6,"sectionName":"6","fieldName":"ACCOUNT_NAME","csvTxtLength":"74","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"firstField":true,"pdfLength":"74","decryptionKey":null,"tagValue":null},{"sequence":7,"sectionName":"7","fieldName":"REMARKS","csvTxtLength":"30","fieldType":"String","delimiter":"","fieldFormat":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true,"pdfLength":"30"},{"sequence":8,"sectionName":"8","fieldName":"Space","fieldType":"String","delimiter":"","fieldFormat":"","eol":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"csvTxtLength":"100","pdfLength":"100","firstField":true}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Total For Branch","csvTxtLength":"17","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"TOTAL FOR BRANCH ","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"17"},{"sequence":2,"sectionName":"2","fieldName":"BRANCH NAME","csvTxtLength":"20","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"20"},{"sequence":3,"sectionName":"7","fieldName":"Colon","csvTxtLength":"1","pdfLength":"1","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":": ","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"3","fieldName":"OVER-ALL TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"pdfLength":"10","eol":true},{"sequence":5,"sectionName":"4","fieldName":"Prepared By","csvTxtLength":"40","fieldType":"String","delimiter":"","defaultValue":"PREPARED BY:","firstField":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"decryptionKey":null,"tagValue":null,"pdfLength":"40"},{"sequence":6,"sectionName":"6","fieldName":"Date Received","csvTxtLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"DATE RECEIVED:","leftJustified":false,"padFieldLength":0,"decrypt":false,"pdfLength":"40"},{"sequence":7,"sectionName":"5","fieldName":"Received By","csvTxtLength":"40","fieldType":"String","delimiter":"","fieldFormat":"","defaultValue":"RECEIVED BY:","leftJustified":false,"padFieldLength":0,"decrypt":false,"pdfLength":"40","eol":true}]');
	
	i_BODY_QUERY := TO_CLOB('
select CLT_FIRST_NAME as FIRST_NAME,
  CLT_MIDDLE_NAME as MIDDLE_NAME,
  CLT_LAST_NAME as LAST_NAME,
  '''' as ACCOUNT_NAME,
  CLT_KEY_ROTATION_NO as "ROTATION_NUMBER",
  INS_CODE AS INSTITUTION_ID,
  ''NEW'' as REMARKS,
  BRN_CODE as Branch_Code,
  BRN_NAME as Branch_Name,
  PRS_NAME as PROGRAM_NAME
from {DCMS_Schema}.ISSUANCE_DEBIT_CARD_REQUEST@{DB_LINK_DCMS} 
  join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = DCR_CLT_ID
  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = DCR_BRN_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = DCR_PRS_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on DCR_INS_ID = INS_ID
where DCR_STS_ID = 70
  AND DCR_INS_ID = {Iss_Id}
  AND DCR_CREATED_TS BETWEEN TO_DATE({From_Date},''YYYYMMdd hh24:mi:ss'') AND TO_DATE({To_Date},''YYYYMMdd hh24:mi:ss'')
union all
select
  CLT_FIRST_NAME as FIRST_NAME,
  CLT_MIDDLE_NAME as MIDDLE_NAME,
  CLT_LAST_NAME as LAST_NAME,
  '''' as ACCOUNT_NAME,
  CLT_KEY_ROTATION_NO as "ROTATION_NUMBER",
  INS_CODE AS INSTITUTION_ID,
  ''REPLACEMENT'' as Remarks,
  BRN_CODE as Branch_Code,
  BRN_NAME as Branch_Name,
  PRS_NAME as PROGRAM_NAME
from {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = CRN_BRN_ID  
  join {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} on CCM_ID = CRN_CCM_ID
  join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = CCM_CLT_ID
  join {DCMS_Schema}.issuance_card@{DB_LINK_DCMS} on CRD_ID = CCM_CRD_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = CRD_PRS_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CRD_INS_ID = INS_ID
where CRN_STS_ID = 88
  AND CRN_INS_ID = {Iss_Id}
  AND CRN_CREATED_TS BETWEEN TO_DATE({From_Date},''YYYYMMdd hh24:mi:ss'') AND TO_DATE({To_Date},''YYYYMMdd hh24:mi:ss'')
union all 
select
  CLT_FIRST_NAME as FIRST_NAME,
  CLT_MIDDLE_NAME as MIDDLE_NAME,
  CLT_LAST_NAME as LAST_NAME,
  '''' as ACCOUNT_NAME,
  CLT_KEY_ROTATION_NO as "ROTATION_NUMBER",
  INS_CODE AS INSTITUTION_ID,
  ''PIN REGENERATION'' as Remarks,
  BRN_CODE as Branch_Code,
  BRN_NAME as Branch_Name,
  PRS_NAME as PROGRAM_NAME
from {DCMS_Schema}.SUPPORT_REPIN@{DB_LINK_DCMS} 
  join {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} on BRN_ID = REP_BRN_ID
  join {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} on CCM_ID = REP_CCM_ID
  join {DCMS_Schema}.ISSUANCE_CLIENT@{DB_LINK_DCMS} on CLT_ID = CCM_CLT_ID
  join {DCMS_Schema}.issuance_card@{DB_LINK_DCMS} on CRD_ID = CCM_CRD_ID
  join {DCMS_Schema}.CARD_PROGRAM_SETUP@{DB_LINK_DCMS} on PRS_ID = CRD_PRS_ID
  join {DCMS_Schema}.MASTER_INSTITUTIONS@{DB_LINK_DCMS} on CRD_INS_ID = INS_ID
where REP_STS_ID = 88
  AND REP_INS_ID = {Iss_Id}
  AND REP_CREATED_TS BETWEEN TO_DATE({From_Date},''YYYYMMdd hh24:mi:ss'') AND TO_DATE({To_Date},''YYYYMMdd hh24:mi:ss'')
	');	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_FILE_FORMAT = i_FILE_FORMAT
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY,
		RED_FILE_FORMAT = i_FILE_FORMAT
	WHERE RED_NAME = i_REPORT_NAME AND RED_INS_ID = 2;
	
END;
/