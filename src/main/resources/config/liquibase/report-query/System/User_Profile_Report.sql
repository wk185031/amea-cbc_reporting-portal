-- Tracking					Date			Name	Description
-- CBCAXUPISSLOG-06			16-FEB-2022		LY		Initial Release

DECLARE

	i_BODY_FIELDS CLOB;
	i_BODY_QUERY CLOB;

BEGIN 
	  i_BODY_FIELDS := ('[{"sequence":1,"sectionName":"L1","fieldName":"User ID Label","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"User ID","firstField":true,"bodyHeader":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":2,"sectionName":"L2","fieldName":"User Name Label","fieldType":"String","delimiter":";","fieldFormat":"","defaultValue":"User Name","bodyHeader":true,"eol":false,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":3,"sectionName":"L3","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Branch/Location","bodyHeader":true,"fieldName":"Branch Label"},{"sequence":4,"sectionName":"L4","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Group/Role ID","bodyHeader":true,"fieldName":"Role_ID Label"},{"sequence":5,"sectionName":"L5","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Group/Role Name","bodyHeader":true,"fieldName":"Role_Name Label"},{"sequence":6,"sectionName":"L6","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Last Login Date/Time","bodyHeader":true,"fieldName":"Last_Login Label"},{"sequence":7,"sectionName":"L7","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Date User ID Created","bodyHeader":true,"fieldName":"Created_Date Label"},{"sequence":8,"sectionName":"L8","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Last Status","bodyHeader":true,"fieldName":"Last_Status Label"},{"sequence":9,"sectionName":"L9","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Status  (Active, Dormant, Disabled etc.)","bodyHeader":true,"fieldName":"Status Label"},{"sequence":10,"sectionName":"L10","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Status Change Date","bodyHeader":true,"fieldName":"Status_Change_Date Label"},{"sequence":11,"sectionName":"L11","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"defaultValue":"Last Password Change Date","bodyHeader":true,"eol":true,"fieldName":"Password_Change_Date Label"},{"sequence":12,"sectionName":"F1","fieldName":"User_ID","fieldType":"String","delimiter":";","fieldFormat":"","firstField":true,"leftJustified":true,"padFieldLength":0,"decrypt":false},{"sequence":13,"sectionName":"F2","fieldName":"Username","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"eol":false},{"sequence":14,"sectionName":"F3","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Branch"},{"sequence":15,"sectionName":"F4","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Role_ID"},{"sequence":16,"sectionName":"F5","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Role_Name"},{"sequence":17,"sectionName":"F6","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Last_Login"},{"sequence":18,"sectionName":"F7","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Created_Date"},{"sequence":19,"sectionName":"F8","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Last_Status"},{"sequence":20,"sectionName":"F9","fieldType":"String","delimiter":";","fieldFormat":"","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Status"},{"sequence":21,"sectionName":"F10","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Status_Change_Date"},{"sequence":22,"sectionName":"F11","fieldType":"Date","delimiter":";","fieldFormat":"MM/dd/yyyy","leftJustified":true,"padFieldLength":0,"decrypt":false,"fieldName":"Password_Change_Date","eol":true}]');  
	
	  i_BODY_QUERY := TO_CLOB('
	  	select
		    u.LOGIN as User_ID,
		    concat (concat(u.FIRST_NAME, '' ''), u.LAST_NAME) as Username,
		    b.BRC_NAME as Branch,
		    re.NAME as Role_ID,
		    re.DESCRIPTION as Role_Name,
		    ue.LAST_LOGIN_TS as Last_Login,
		    u.CREATED_DATE as Created_Date,
		    u.LAST_STATUS as Last_Status,
		    case when u.ACTIVATED = 1 then ''ACTIVE'' else NVL(u.DEACTIVATE_REASON, ''INACTIVE'') end as Status,
		    u.DEACTIVATE_DATE as Status_Change_Date,
		    u.RESET_DATE as Password_Change_Date
		    from JHI_USER u
		    left join USER_EXTRA ue on u.ID = ue.USER_ID
		    left join USER_EXTRA_BRANCHES ueb on ueb.USER_EXTRA_ID = ue.ID
		    left join BRANCH b on b.BRC_CODE = ueb.BRANCH_ID
		    left join USER_EXTRA_ROLES uer on uer.USER_EXTRAS_ID = ue.ID
		    left join ROLE_EXTRA re on uer.ROLES_ID = re.ID
		    order by u.LOGIN
		');
		
	  UPDATE REPORT_DEFINITION SET 
	    RED_BODY_FIELDS = i_BODY_FIELDS,
	  	RED_BODY_QUERY = i_BODY_QUERY 
	  WHERE RED_NAME = 'User Profile Report';
	  
END;
/