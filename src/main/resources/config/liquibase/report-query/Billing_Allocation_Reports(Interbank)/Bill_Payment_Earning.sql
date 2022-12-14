-- Tracking				Date			Name	Description
-- Rel-20210730			30-JUL-2021		KW		Revise

DECLARE
    i_HEADER_FIELDS_CBC CLOB;
    i_BODY_FIELDS_CBC CLOB;
    i_TRAILER_FIELDS_CBC CLOB;
    i_HEADER_FIELDS_CBS CLOB;
    i_BODY_FIELDS_CBS CLOB;
    i_TRAILER_FIELDS_CBS CLOB;
	i_BODY_QUERY CLOB;
	i_TRAILER_QUERY CLOB;
BEGIN 

-- Bills Payment Earnings (Per Branch)

-- CBC header/body/trailer fields
	i_HEADER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING CORPORATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"REPORT ID:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"8","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"9","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"10","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"11","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"12","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BILLS PAYMENT TRANSACTIONS AND INCOME (PER BRANCH)","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"7","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"EMPTY","fieldType":"String","delimiter":"","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"7","fieldName":"PER BRANCH","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true,"defaultValue":"PER BRANCH"},{"sequence":4,"sectionName":"8","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":5,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"EMPTY"},{"sequence":6,"sectionName":"10","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"33","fieldName":"THRU ATM","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"THRU ATM TERMINAL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"34","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"35","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"36","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"OVERALL","defaultValue":"OVER-ALL"},{"sequence":12,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true},{"sequence":13,"sectionName":"23","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"BRANCH FOR ALLOCATION","defaultValue":"BRANCH FOR ALLOCATION"},{"sequence":14,"sectionName":"24","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"26","fieldName":"Issuer","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ISSUER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"27","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"28","fieldName":"Acquirer","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ACQUIRER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"29","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"37","fieldName":"AS ACQUIRER","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS ACQUIRER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"38","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"39","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"40","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"30","fieldName":"TOTALS","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTALS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"43","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"45","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"46","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"47","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"ISSUER VOL","defaultValue":"TOTAL VOL"},{"sequence":28,"sectionName":"48","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"ISSUER FEE","defaultValue":"TOTAL FEE"},{"sequence":29,"sectionName":"49","fieldName":"ACQUIRER TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"50","fieldName":"ACQUIRER FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"TOTAL FEE"},{"sequence":31,"sectionName":"41","fieldName":"TERM NO","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERM NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"42","fieldName":"TERM NAME","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERM NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"44","fieldName":"VOL","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":34,"sectionName":"63","fieldName":"FEE","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":35,"sectionName":"51","fieldName":"TOTAL VOL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"52","fieldName":"TOTAL FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":37,"sectionName":"53","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":38,"sectionName":"54","fieldName":"BRANCH NAME","csvTxtLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":39,"sectionName":"57","fieldName":"ISSUER VOL","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":40,"sectionName":"58","fieldName":"ISSUER FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":41,"sectionName":"59","fieldName":"ACQUIRER VOL","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":42,"sectionName":"60","fieldName":"ACQUIRER FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":43,"sectionName":"64","fieldName":"TERM NO","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":44,"sectionName":"65","fieldName":"TERM NAME","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":45,"sectionName":"66","fieldName":"TERM ACQ VOL","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":46,"sectionName":"67","fieldName":"TERM ACQ FEE","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":47,"sectionName":"61","fieldName":"TOTAL VOL","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":48,"sectionName":"62","fieldName":"TOTAL FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true,"sumAmount":true}]');
	i_TRAILER_FIELDS_CBC := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false}]');

-- CBS header/body/trailer fields
	i_HEADER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"Bank Name","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"CHINA BANKING SAVINGS","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":2,"sectionName":"2","fieldName":"Report ID","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"REPORT ID:","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"8","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"9","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"10","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0},{"sequence":6,"sectionName":"11","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":7,"sectionName":"12","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":8,"sectionName":"3","fieldName":"Daily Billing Allocation","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DAILY BILLING ALLOCATION","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":9,"sectionName":"4","fieldName":"Frequency","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FREQUENCY:","firstField":false,"eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":10,"sectionName":"5","fieldName":"Title","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"BILLS PAYMENT TRANSACTIONS AND INCOME (PER BRANCH)","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":11,"sectionName":"6","fieldName":"Date","csvTxtLength":"11","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"DATE:","leftJustified":true,"padFieldLength":0},{"sequence":12,"sectionName":"7","fieldName":"As of Date Value","csvTxtLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yy","eol":false,"leftJustified":true,"padFieldLength":0},{"sequence":13,"sectionName":"13","fieldName":"EMPTY","fieldType":"String","delimiter":"","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0}]');
	i_BODY_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"1","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"2","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"7","fieldName":"PER BRANCH","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true,"defaultValue":"PER BRANCH"},{"sequence":4,"sectionName":"8","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false,"bodyHeader":true},{"sequence":5,"sectionName":"9","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"EMPTY"},{"sequence":6,"sectionName":"10","fieldName":"EMPTY","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":7,"sectionName":"33","fieldName":"THRU ATM","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"THRU ATM TERMINAL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"34","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"35","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"36","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"11","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"OVERALL","defaultValue":"OVER-ALL"},{"sequence":12,"sectionName":"12","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":true},{"sequence":13,"sectionName":"23","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"BRANCH FOR ALLOCATION","defaultValue":"BRANCH FOR ALLOCATION"},{"sequence":14,"sectionName":"24","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":15,"sectionName":"26","fieldName":"Issuer","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ISSUER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":16,"sectionName":"27","fieldName":"","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":17,"sectionName":"28","fieldName":"Acquirer","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"ACQUIRER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":18,"sectionName":"29","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":19,"sectionName":"37","fieldName":"AS ACQUIRER","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"AS ACQUIRER","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":20,"sectionName":"38","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":21,"sectionName":"39","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":22,"sectionName":"40","fieldName":"EMPTY","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":23,"sectionName":"30","fieldName":"TOTALS","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTALS","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":24,"sectionName":"43","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":25,"sectionName":"45","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":26,"sectionName":"46","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":27,"sectionName":"47","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"ISSUER VOL","defaultValue":"TOTAL VOL"},{"sequence":28,"sectionName":"48","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"ISSUER FEE","defaultValue":"TOTAL FEE"},{"sequence":29,"sectionName":"49","fieldName":"ACQUIRER TOTAL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TOTAL VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":30,"sectionName":"50","fieldName":"ACQUIRER FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"TOTAL FEE"},{"sequence":31,"sectionName":"41","fieldName":"TERM NO","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERM NO","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":32,"sectionName":"42","fieldName":"TERM NAME","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"TERM NAME","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":33,"sectionName":"44","fieldName":"VOL","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":34,"sectionName":"63","fieldName":"FEE","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":35,"sectionName":"51","fieldName":"TOTAL VOL","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"VOL","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":36,"sectionName":"52","fieldName":"TOTAL FEE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"FEE","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":37,"sectionName":"53","fieldName":"BRANCH CODE","csvTxtLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":38,"sectionName":"54","fieldName":"BRANCH NAME","csvTxtLength":"60","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":false,"leftJustified":false,"padFieldLength":0,"decrypt":false},{"sequence":39,"sectionName":"57","fieldName":"ISSUER VOL","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":40,"sectionName":"58","fieldName":"ISSUER FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":41,"sectionName":"59","fieldName":"ACQUIRER VOL","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":42,"sectionName":"60","fieldName":"ACQUIRER FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":43,"sectionName":"64","fieldName":"TERM NO","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":44,"sectionName":"65","fieldName":"TERM NAME","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":45,"sectionName":"66","fieldName":"TERM ACQ VOL","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":46,"sectionName":"67","fieldName":"TERM ACQ FEE","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","defaultValue":"","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":47,"sectionName":"61","fieldName":"TOTAL VOL","csvTxtLength":"10","fieldType":"Number","delimiter":";","fieldFormat":",","leftJustified":false,"padFieldLength":0,"decrypt":false,"sumAmount":true},{"sequence":48,"sectionName":"62","fieldName":"TOTAL FEE","csvTxtLength":"10","fieldType":"Decimal","delimiter":";","fieldFormat":"#,##0.00","leftJustified":false,"padFieldLength":0,"decrypt":false,"eol":true,"sumAmount":true}]');
	i_TRAILER_FIELDS_CBS := TO_CLOB('[{"sequence":1,"sectionName":"2","fieldType":"String","delimiter":"","fieldFormat":"","leftJustified":false,"padFieldLength":0,"decrypt":false}]');
	
	i_BODY_QUERY := TO_CLOB('
SELECT 
  "BRANCH CODE",
  "BRANCH NAME",
  "TERM NO",
  "TERM NAME",
  SUM("ACQUIRER VOL") AS "ACQUIRER VOL",
  SUM("ACQUIRER FEE") AS "ACQUIRER FEE",
  SUM("ISSUER VOL") AS "ISSUER VOL",
  SUM("ISSUER FEE") AS "ISSUER FEE",
  SUM("TERM ACQ VOL") AS "TERM ACQ VOL",
  SUM("TERM ACQ FEE") AS "TERM ACQ FEE",
  SUM("ACQUIRER VOL") + SUM("ISSUER VOL") AS "TOTAL VOL",
  SUM("ACQUIRER FEE") + SUM("ISSUER FEE") AS "TOTAL FEE"
FROM (
SELECT
     SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
     BRC.BRC_NAME "BRANCH NAME",
     ''-'' AS "TERM NO",
     ''-'' AS "TERM NAME",
     COUNT(TXN.TRL_ID) AS "ACQUIRER VOL",
     SUM(NVL(BF.ACQUIRER_SHARE, 3.5)) AS "ACQUIRER FEE",
     0 AS "TERM ACQ VOL",
     0 AS "TERM ACQ FEE",
     0 AS "ISSUER VOL",
     0 AS "ISSUER FEE"
FROM
     TRANSACTION_LOG TXN
     LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
     LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
     LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
     LEFT JOIN BRANCH BRC ON BRC.BRC_CODE = ABR.ABR_CODE
     LEFT JOIN BILLER_FEE BF ON BF.CODE = TXNC.TRL_BILLER_CODE
WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_BILLER_CODE NOT IN (''063'',''065'',''067'')
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      AND {Txn_Date}
GROUP BY
      SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4),
      BRC.BRC_NAME
UNION
SELECT
     NVL(BRC.BRC_CODE, TXNC.TRL_CARD_BRANCH) "BRANCH CODE",
     BRC.BRC_NAME "BRANCH NAME",
     ''-'' AS "TERM NO",
     ''-'' AS "TERM NAME",
     0 AS "ACQUIRER VOL",
     0 AS "ACQUIRER FEE",
     0 AS "TERM ACQ VOL",
     0 AS "TERM ACQ FEE",
     COUNT(TXN.TRL_ID) AS "ISSUER VOL",
     SUM(NVL(BF.ISSUER_SHARE, 2.5)) AS "ISSUER FEE"
FROM
     TRANSACTION_LOG TXN
     LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
     LEFT JOIN BRANCH BRC ON TXNC.TRL_CARD_BRANCH = BRC.BRC_CODE
     LEFT JOIN BILLER_FEE BF ON BF.CODE = TXNC.TRL_BILLER_CODE
WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_BILLER_CODE NOT IN (''063'',''065'',''067'')
      AND TXN.TRL_ISS_NAME={V_Iss_Name}
      AND {Txn_Date}
GROUP BY
      BRC.BRC_CODE,
      TXNC.TRL_CARD_BRANCH,
      BRC.BRC_NAME
UNION
SELECT
     SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) "BRANCH CODE",
     BRC.BRC_NAME "BRANCH NAME",
     SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, -4) AS "TERM NO",
     AST.AST_ALO_LOCATION_ID AS "TERM NAME",
     0 AS "ACQUIRER VOL",
     0 AS "ACQUIRER FEE",
     COUNT(TXN.TRL_ID) AS "TERM ACQ VOL",
     SUM(NVL(BF.ACQUIRER_SHARE, 3.5)) AS "TERM ACQ FEE",
     0 AS "ISSUER VOL",
     0 AS "ISSUER FEE"
FROM
     TRANSACTION_LOG TXN
     LEFT JOIN TRANSACTION_LOG_CUSTOM TXNC ON TXN.TRL_ID=TXNC.TRL_ID
     LEFT JOIN ATM_STATIONS AST ON TXN.TRL_CARD_ACPT_TERMINAL_IDENT = AST.AST_TERMINAL_ID
     LEFT JOIN ATM_BRANCHES ABR ON ABR.ABR_ID = (SELECT MIN(ABR_ID) FROM ATM_BRANCHES WHERE SUBSTR(TXN.TRL_CARD_ACPT_TERMINAL_IDENT, 1, 4) = ABR_CODE)
     LEFT JOIN BRANCH BRC ON ABR.ABR_CODE = BRC.BRC_CODE
     LEFT JOIN BILLER_FEE BF ON BF.CODE = TXNC.TRL_BILLER_CODE
WHERE
      TXN.TRL_TSC_CODE IN (50, 250)
      AND TXN.TRL_TQU_ID = ''F''
      AND TXN.TRL_ACTION_RESPONSE_CODE = ''0''
      AND NVL(TXN.TRL_POST_COMPLETION_CODE, ''O'') != ''R''
      AND TXNC.TRL_BILLER_CODE NOT IN (''063'',''065'',''067'')
      AND TXN.TRL_DEO_NAME = {V_Deo_Name}
      AND {Txn_Date}
GROUP BY
      TXN.TRL_CARD_ACPT_TERMINAL_IDENT,
      BRC.BRC_NAME,
      AST.AST_ALO_LOCATION_ID
) 
GROUP BY "BRANCH CODE", "BRANCH NAME", "TERM NO", "TERM NAME"
ORDER BY "BRANCH CODE", "TERM NO"
	');
	
	i_TRAILER_QUERY := null;
	
	UPDATE REPORT_DEFINITION SET 
	    RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.billingAllocationReportsInterBank.BillsPaymentEarningsProcessor',
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBC,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBC,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBC,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Bills Payment Earnings (Per Branch)' AND RED_INS_ID = 22;
	
	UPDATE REPORT_DEFINITION SET 
		RED_PROCESSING_CLASS = 'my.com.mandrill.base.reporting.billingAllocationReportsInterBank.BillsPaymentEarningsProcessor',
		RED_HEADER_FIELDS = i_HEADER_FIELDS_CBS,
		RED_BODY_FIELDS = i_BODY_FIELDS_CBS,
		RED_TRAILER_FIELDS = i_TRAILER_FIELDS_CBS,
		RED_BODY_QUERY = i_BODY_QUERY,
		RED_TRAILER_QUERY = i_TRAILER_QUERY
	WHERE RED_NAME = 'Bills Payment Earnings (Per Branch)' AND RED_INS_ID = 2;
	
END;
/