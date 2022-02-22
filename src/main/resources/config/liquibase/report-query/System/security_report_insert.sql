-- Tracking					Date			Name	Description
-- CBCAXUPISSLOG-1061		14-FEB-2022		KW		Create system category

insert into report_definition (RED_REC_ID,RED_NAME,RED_DESCRIPTION,RED_FILE_NAME_PREFIX,RED_FILE_FORMAT,RED_FILE_LOCATION,RED_PROCESSING_CLASS,RED_FREQUENCY,RED_HEADER_FIELDS,RED_BODY_FIELDS,RED_BODY_QUERY,RED_BRANCH_FLAG,RED_DAILY_SCHEDULE_TIME,RED_INS_ID,CREATED_BY,CREATED_DATE,RED_BY_BUSINESS_DATE,RED_SYSTEM)
  values((select REC_ID from REPORT_CATEGORY where REC_NAME='System Reports'), 'User Profile Report', 'User Profile Report', 'User_Profile', 'CSV,', '/authentic/reporting-portal/reports/22', 'my.com.mandrill.base.cbc.processor.SimpleReportProcessor','Daily', 
    '[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"USER PROFILE REPORT","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]', 
    '[{"sequence":1,"sectionName":"1","fieldName":"User ID Label","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"User ID","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"User Name Label","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"User Name","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"3","fieldName":"User_ID","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"4","fieldName":"User_Name","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true}]',
    'select login as User_ID, first_name as User_Name from jhi_user',
    'master',
    current_timestamp,
    22,
    'system',
    current_timestamp,
    0,
    1
  );
  
  
insert into report_definition (RED_REC_ID,RED_NAME,RED_DESCRIPTION,RED_FILE_NAME_PREFIX,RED_FILE_FORMAT,RED_FILE_LOCATION,RED_PROCESSING_CLASS,RED_FREQUENCY,RED_HEADER_FIELDS,RED_BRANCH_FLAG,RED_DAILY_SCHEDULE_TIME,RED_INS_ID,CREATED_BY,CREATED_DATE,RED_BY_BUSINESS_DATE,RED_SYSTEM)
  values((select REC_ID from REPORT_CATEGORY where REC_NAME='System Reports'), 'List of Groups Roles Report', 'List of Groups Roles Report', 'Groups_Roles', 'CSV,', '/authentic/reporting-portal/reports/22', 'my.com.mandrill.base.cbc.processor.SimpleReportProcessor','Daily', 
    '[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"LIST OF GROUPS ROLES REPORT","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]', 
    'master',
    current_timestamp,
    22,
    'system',
    current_timestamp,
    0,
    1
);

insert into report_definition (RED_REC_ID,RED_NAME,RED_DESCRIPTION,RED_FILE_NAME_PREFIX,RED_FILE_FORMAT,RED_FILE_LOCATION,RED_PROCESSING_CLASS,RED_FREQUENCY,RED_HEADER_FIELDS,RED_BRANCH_FLAG,RED_DAILY_SCHEDULE_TIME,RED_INS_ID,CREATED_BY,CREATED_DATE,RED_BY_BUSINESS_DATE,RED_SYSTEM)
  values((select REC_ID from REPORT_CATEGORY where REC_NAME='System Reports'), 'System User Activity Report', 'User Activity Report', 'User Activity', 'CSV,', '/authentic/reporting-portal/reports/22', 'my.com.mandrill.base.cbc.processor.SimpleReportProcessor','Daily', 
    '[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","defaultValue":"0010","firstField":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","csvTxtLength":"50","pdfLength":"50","fieldType":"String","defaultValue":"CHINA BANK CORPORATION","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","csvTxtLength":"60","pdfLength":"60","fieldType":"String","defaultValue":"USER ACTIVITY REPORT","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":4,"sectionName":"4","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","defaultValue":"RUN DATE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":5,"sectionName":"5","fieldName":"RunDate Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","defaultValue":"","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"5","pdfLength":"5","fieldType":"String","defaultValue":"","eol":true,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":8,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"firstField":true},{"sequence":9,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"10","fieldName":"SPACE","csvTxtLength":"96","pdfLength":"96","fieldType":"String","defaultValue":"","firstField":false,"leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":11,"sectionName":"11","fieldName":"Time","csvTxtLength":"14","pdfLength":"14","fieldType":"String","defaultValue":"TIME","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":12,"sectionName":"12","fieldName":"Time Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","fieldFormat":"HH:mm:ss","leftJustified":true,"padFieldLength":0,"delimiter":";"},{"sequence":13,"sectionName":"13","fieldName":"Report Id","eol":true,"csvTxtLength":"9","pdfLength":"9","fieldType":"String","leftJustified":true,"padFieldLength":0,"delimiter":";","defaultValue":""},{"sequence":14,"sectionName":"Space1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"15","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"16","csvTxtLength":"100","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"17","fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TODAYS DATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"18","fieldName":"Todays Date Value","csvTxtLength":"19","pdfLength":"19","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"19","fieldName":"As Of Date","csvTxtLength":"14","pdfLength":"14","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS OF DATE","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"20","fieldName":"As of Date Value","csvTxtLength":"16","pdfLength":"16","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]', 
    'master',
    current_timestamp,
    22,
    'system',
    current_timestamp,
    0,
    1
);