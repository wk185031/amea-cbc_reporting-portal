-- Tracking					Date			Name	Description
-- CBCAXUPISSLOG-06			16-FEB-2022		LY		Initial Release
-- CBCAXUPISSLOG-1061		18-FEB-2022		WY		Add txn date 

DECLARE

	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;

BEGIN 
	  i_BODY_FIELDS := ('[{"sequence":1,"sectionName":"L1","fieldName":"User_ID Label","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"User ID"},{"sequence":2,"sectionName":"L2","fieldName":"Username Label","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"User Name"},{"sequence":3,"sectionName":"L3","fieldName":"Date_Time Label","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Date/Time"},{"sequence":4,"sectionName":"L4","fieldName":"Function_Desc Label","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Function Description"},{"sequence":5,"sectionName":"L5","fieldName":"Activity Label","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"Activity","bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":6,"sectionName":"L6","fieldName":"Details Label","fieldType":"String","delimiter":";","fieldFormat":"","bodyHeader":true,"eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Details"},{"sequence":7,"sectionName":"F1","fieldName":"User_ID","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":8,"sectionName":"F2","fieldName":"Username","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":9,"sectionName":"F3","fieldName":"Date_Time","fieldType":"Date Time","delimiter":";","fieldFormat":"dd/MM/yyyy HH:mm","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":10,"sectionName":"F4","fieldName":"Function_Desc","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":11,"sectionName":"F5","fieldName":"Activity","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":12,"sectionName":"F6","fieldName":"Details","fieldType":"String","delimiter":";","fieldFormat":"","eol":true,"leftJustified":true,"padFieldLength":0,"decrypt":false}]');  
	
	  i_BODY_QUERY := TO_CLOB('select 
		ju1.LOGIN as User_ID,
		concat (concat(ju1.FIRST_NAME, '' ''), ju1.LAST_NAME) as Username,
		jpae1.EVENT_DATE as Date_Time,
		substr (jpae1.EVENT_TYPE, 1, instr(jpae1.EVENT_TYPE, ''_'')-1) as Function_Desc,
		substr (jpae1.EVENT_TYPE, instr(jpae1.EVENT_TYPE, ''_'')+1, length(jpae1.EVENT_TYPE)) as Activity,
		jpaed1.VALUE as Details
		from JHI_USER ju1
		join JHI_PERSISTENT_AUDIT_EVENT jpae1 on ju1.LOGIN = jpae1.PRINCIPAL
		join JHI_PERSISTENT_AUDIT_EVT_DATA jpaed1 on jpae1.EVENT_ID = jpaed1.EVENT_ID
		where jpaed1.NAME = ''details''
		AND {Txn_Date}');
		
	  UPDATE REPORT_DEFINITION SET 
	    RED_BODY_FIELDS = i_BODY_FIELDS,
	  	RED_BODY_QUERY = i_BODY_QUERY 
	  WHERE RED_NAME = 'System User Activity Report';
	  
END;
/