-- Tracking					Date			Name	Description
-- CBCAXUPISSLOG-1061		14-FEB-2022		KW		Create system category

insert into REPORT_CATEGORY(REC_ID,REC_NAME,REC_DESCRIPTION,REC_BRANCH_FLAG,CREATED_BY,CREATED_DATE,REC_SYSTEM)
  VALUES((SELECT MAX(REC_ID)+1 FROM REPORT_CATEGORY), 'System Reports', 'For system reports', 'master', 'system', CURRENT_TIMESTAMP, 1);