-- script used to temporary disabling few of scheme report
-- to enable back, please use NY_enable_scheme_report_20210527.sql script
DELETE FROM REPORT_DEFINITION WHERE RED_NAME IN (
'CUP Share In Fee Income',
'JCB Share In Fee Income',
'VISA Share In Fee Income',
'MasterCard Share In Fee Income'
);