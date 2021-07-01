-- Tracking				Date			Name	Description
-- CBCAXUPISSLOG-672 	15-JUN-2021		NY		Initial from UAT env
-- CBCAXUPISSLOG-672 	15-JUN-2021		NY		Replace hardcoded dblink/db schema to parameterized string

DECLARE
	i_HEADER_FIELDS CLOB;
    i_BODY_FIELDS CLOB;
    i_TRAILER_FIELDS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Monthly Card File Report
	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Code","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"0100","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Bank Name","pdfLength":"62","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"csvTxtLength":"62","defaultValue":"CHINA BANKING CORPORATION"},{"sequence":3,"sectionName":"3","fieldName":"File Name1","pdfLength":"48","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"MONTHLY CARD FILE REPORT","leftJustified":true,"padFieldLength":0,"csvTxtLength":"48"},{"sequence":4,"sectionName":"4","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"fieldName":"Todays Date","csvTxtLength":"15","pdfLength":"15","defaultValue":"TODAYS DATE"},{"sequence":5,"sectionName":"5","fieldName":"Todays Date Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","defaultValue":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"6","fieldName":"PAGE","csvTxtLength":"5","pdfLength":"5","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"PAGE","leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"7","fieldName":"Page Number","csvTxtLength":"6","pdfLength":"6","fieldType":"Number","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"8","fieldName":"","csvTxtLength":"100","pdfLength":"100","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"18","csvTxtLength":"12","pdfLength":"12","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"18","csvTxtLength":"4","pdfLength":"4","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"10","fieldName":"As Of Date","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"csvTxtLength":"15","pdfLength":"15","defaultValue":"AS OF DATE"},{"sequence":12,"sectionName":"11","fieldName":"As of Date Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"12","fieldName":"EFP012-01","csvTxtLength":"9","pdfLength":"9","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"EFP012-01","eol":true,"leftJustified":false,"padFieldLength":0},{"sequence":14,"sectionName":"13","fieldName":"","csvTxtLength":"96","pdfLength":"96","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":15,"sectionName":"19","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0},{"sequence":16,"sectionName":"20","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":17,"sectionName":"14","fieldName":"RunDate","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"RUNDATE","leftJustified":true,"padFieldLength":0},{"sequence":18,"sectionName":"15","fieldName":"RunDate Value","csvTxtLength":"11","pdfLength":"11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","leftJustified":true,"padFieldLength":0},{"sequence":19,"sectionName":"16","fieldName":"Time","csvTxtLength":"6","pdfLength":"6","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TIME","leftJustified":true,"padFieldLength":0},{"sequence":20,"sectionName":"17","fieldName":"Time Value","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"HH:mm:ss","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldName":"Branch","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BRANCH","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"3","fieldName":"Branch Name","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"csvTxtLength":"40","pdfLength":"40","defaultValue":"BRANCH NAME","bodyHeader":true},{"sequence":3,"sectionName":"4","fieldName":"Active","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ACTIVE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"5","fieldName":"Inactive","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"INACTIVE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"6","fieldName":"Renewed","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"RENEWED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"7","fieldName":"Replaced","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"REPLACED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"8","fieldName":"Closed","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CLOSED","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":false},{"sequence":8,"sectionName":"23","fieldName":"Total Count","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL COUNT","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"11","fieldName":"CD","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CD","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"23","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"12","fieldName":"Cards","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CARDS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"13","fieldName":"Cards","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CARDS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"14","fieldName":"Cards","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CARDS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":14,"sectionName":"15","fieldName":"Cards","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CARDS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"16","fieldName":"Cards","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CARDS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true},{"sequence":16,"sectionName":"20","fieldName":"BRANCH_CODE","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"21","fieldName":"BRANCH_NAME","csvTxtLength":"40","pdfLength":"40","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"22","fieldName":"ACTIVE_CARDS","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"23","fieldName":"INACTIVE_CARDS","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"24","fieldName":"RENEWED_CARDS","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"25","fieldName":"REPLACED_CARDS","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"26","fieldName":"CLOSED_CARDS","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":false},{"sequence":23,"sectionName":"24","fieldName":"TOTAL_COUNT","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');
	i_TRAILER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"8","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true,"fieldName":"Space1"},{"sequence":2,"sectionName":"9","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":false,"padFieldLength":0,"decrypt":false,"fieldName":"Space2"},{"sequence":3,"sectionName":"1","fieldName":"Grand Total","csvTxtLength":"20","pdfLength":"20","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"GRAND TOTAL: ","firstField":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":4,"sectionName":"2","fieldName":"TOTAL_ACTIVE","csvTxtLength":"21","pdfLength":"21","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":5,"sectionName":"3","fieldName":"TOTAL_INACTIVE","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"4","fieldName":"TOTAL_RENEWED","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"5","fieldName":"TOTAL_REPLACED","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"6","fieldName":"TOTAL_CLOSED","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":false},{"sequence":9,"sectionName":"7","fieldName":"TOTAL_TOTAL","csvTxtLength":"15","pdfLength":"15","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true}]');
	i_BODY_QUERY := TO_CLOB('		
select
                report_summary.BRANCH_CODE,
                report_summary.BRANCH_NAME,
                report_summary.ACTIVE_CARDS,
                report_summary.INACTIVE_CARDS,
                report_summary.RENEWED_CARDS,
                report_summary.REPLACED_CARDS,
                report_summary.CLOSED_CARDS as CLOSED_CARDS,
                (select report_summary.ACTIVE_CARDS + report_summary.INACTIVE_CARDS from dual) AS TOTAL_COUNT from
                (SELECT
                        (SELECT BRN_CODE FROM {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} WHERE BRN_ID = CRD.CRD_BRN_ID) AS BRANCH_CODE,
                        (SELECT BRN_NAME FROM {DCMS_Schema}.MASTER_BRANCHES@{DB_LINK_DCMS} WHERE BRN_ID = CRD.CRD_BRN_ID) AS BRANCH_NAME,
                        (SELECT COUNT(CRD_ACTIVE.CRD_BRN_ID)
                          FROM {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} CRD_ACTIVE
                          WHERE CRD_ACTIVE.CRD_BRN_ID =  CRD.CRD_BRN_ID AND CRD_ACTIVE.CRD_STS_ID = 72
                          AND trunc(CRD_ACTIVE.crd_created_ts)
                          between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
                          )AS ACTIVE_CARDS,

                        (SELECT COUNT(CRD_INACTIVE.CRD_BRN_ID)
                          FROM {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} CRD_INACTIVE
                          WHERE CRD_INACTIVE.CRD_BRN_ID = CRD.CRD_BRN_ID AND CRD_INACTIVE.CRD_STS_ID = 71
                          AND trunc(CRD_INACTIVE.crd_created_ts)
                          between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
                         )AS INACTIVE_CARDS,

                        (SELECT COUNT(*) FROM {DCMS_Schema}.SUPPORT_CARD_RENEWAL@{DB_LINK_DCMS} RNWL
                        INNER JOIN {DCMS_Schema}.ISSUANCE_CLIENT_CARD_MAPPING@{DB_LINK_DCMS} CCM ON RNWL.CRN_CCM_ID = CCM.CCM_ID
                        INNER JOIN {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} SUB_CRD ON CCM.CCM_CRD_ID = SUB_CRD.CRD_ID
                        WHERE SUB_CRD.CRD_BRN_ID = CRD.CRD_BRN_ID AND RNWL.CRN_STS_ID = 1
                         ) AS RENEWED_CARDS,

                    (SELECT COUNT(CRD_INACTIVE.CRD_BRN_ID)
                          FROM {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} CRD_INACTIVE
                          WHERE CRD_INACTIVE.CRD_BRN_ID = CRD.CRD_BRN_ID AND CRD_INACTIVE.CRD_STS_ID = 77
                          AND trunc(CRD_INACTIVE.crd_created_ts)
                          between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
                          ) AS REPLACED_CARDS,


                                (SELECT COUNT(CRD_CLOSED.CRD_BRN_ID)
                          FROM {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} CRD_CLOSED
                          WHERE CRD_CLOSED.CRD_BRN_ID =  CRD.CRD_BRN_ID AND CRD_CLOSED.CRD_STS_ID = 74
                          AND trunc(CRD_CLOSED.crd_created_ts)
                          between To_Date({From_Date},''dd-MM-YY hh24:mi:ss'') And To_Date({To_Date},''dd-MM-YY hh24:mi:ss'')
                          ) AS CLOSED_CARDS


                    FROM {DCMS_Schema}.ISSUANCE_CARD@{DB_LINK_DCMS} CRD WHERE CRD.CRD_PRS_ID = 3 AND CRD.CRD_INS_ID = 1
                    GROUP BY CRD.CRD_BRN_ID
                    ORDER BY BRANCH_CODE) report_summary
	');
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS,
		RED_BODY_FIELDS = i_BODY_FIELDS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	where RED_NAME = 'Monthly Card File Report';
	
END;
/