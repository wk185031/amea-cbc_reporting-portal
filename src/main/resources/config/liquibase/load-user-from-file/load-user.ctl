-- use this command to execute the control file: sqlldr userid=<username>/<password> control='<full path to .ctl file>'

LOAD DATA
INFILE '/tmp/cbc-report-load-user-sample.csv' "str '\r\n'" 
TRUNCATE
INTO TABLE LOAD_USER
fields terminated by ","
trailing nullcols
(
LOGIN_NAME,
EMAIL,
FIRST_NAME,
LAST_NAME,
BRANCH_CODE "CASE WHEN :BRANCH_CODE = 'ALL' then NULL ELSE :BRANCH_CODE END",
ROLE_NAME,
INSTITUTION_CODE
)