-- insert 1 set of CBS report definition
insert into report_definition (RED_REC_ID,RED_NAME,RED_DESCRIPTION,RED_FILE_NAME_PREFIX,RED_FILE_FORMAT,RED_FILE_LOCATION,RED_PROCESSING_CLASS,RED_FREQUENCY,RED_GENERATED_PATH_CSV,RED_GENERATED_PATH_TXT,RED_GENERATED_PATH_PDF,RED_GENERATED_FILENAME_CSV,RED_GENERATED_FILENAME_TXT,RED_GENERATED_FILENAME_PDF,RED_HEADER_FIELDS,RED_BODY_FIELDS,RED_TRAILER_FIELDS,RED_BODY_QUERY,RED_TRAILER_QUERY,RED_BRANCH_FLAG,RED_DAILY_SCHEDULE_TIME,RED_INS_ID,CREATED_BY,CREATED_DATE,LAST_MODIFIED_BY,LAST_MODIFIED_DATE)
(select RED_REC_ID,RED_NAME,RED_DESCRIPTION,RED_FILE_NAME_PREFIX,RED_FILE_FORMAT,RED_FILE_LOCATION,RED_PROCESSING_CLASS,RED_FREQUENCY,RED_GENERATED_PATH_CSV,RED_GENERATED_PATH_TXT,RED_GENERATED_PATH_PDF,RED_GENERATED_FILENAME_CSV,RED_GENERATED_FILENAME_TXT,RED_GENERATED_FILENAME_PDF,RED_HEADER_FIELDS,RED_BODY_FIELDS,RED_TRAILER_FIELDS,RED_BODY_QUERY,RED_TRAILER_QUERY,RED_BRANCH_FLAG,RED_DAILY_SCHEDULE_TIME,2,CREATED_BY,CREATED_DATE,LAST_MODIFIED_BY,LAST_MODIFIED_DATE from report_definition);

-- update string 'CHINA BANK CORPORATION' to 'CHINA BANK SAVINGS'
update report_definition set red_header_fields = REPLACE(red_header_fields, 'CHINA BANK CORPORATION', 'CHINA BANK SAVINGS') where red_ins_id = 2;
-- update string '0010' to '0112'
update report_definition set red_header_fields = REPLACE(red_header_fields, '0010', '0112') where red_ins_id = 2;