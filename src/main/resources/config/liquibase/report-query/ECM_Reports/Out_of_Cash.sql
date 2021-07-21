-- Tracking				Date			Name	Description
-- Revise report		19-JULY-2021	WY		Revise report header data

DECLARE
	i_HEADER_FIELDS CLOB;
   
BEGIN 

	i_HEADER_FIELDS := TO_CLOB('[{"sequence":1,"sectionName":"1","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"fieldName":"Out Of Cash Report","eol":true,"defaultValue":"Out Of Cash Report"},{"sequence":2,"sectionName":"2","fieldName":"Start Date","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Start Date","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":3,"sectionName":"3","fieldName":"From Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"dd/MM/yyyy","eol":true,"leftJustified":true,"padFieldLength":0},{"sequence":4,"sectionName":"4","fieldName":"End Date","csvTxtLength":"10","pdfLength":"10","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"End Date","firstField":true,"leftJustified":true,"padFieldLength":0},{"sequence":5,"sectionName":"5","fieldName":"Report To Date","csvTxtLength":"10","pdfLength":"10","fieldType":"Date","delimiter":";","fieldFormat":"dd/MM/yyyy","eol":true,"leftJustified":true,"padFieldLength":0}]');
	
	UPDATE REPORT_DEFINITION set 
		RED_HEADER_FIELDS = i_HEADER_FIELDS
	where RED_NAME = 'Out of Cash';
	
END;
/